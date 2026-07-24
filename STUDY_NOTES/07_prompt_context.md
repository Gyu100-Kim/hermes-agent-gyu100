# 07. 프롬프트와 컨텍스트 관리 (1-C-5)

## 이 문서에서 다루는 큰 맥락

LLM은 **컨텍스트(context)** — 즉 매번 함께 보내는 텍스트 — 안에 담긴 내용만 압니다.
그래서 "무엇을, 어떤 순서로, 얼마나 안정적으로" 컨텍스트에 넣느냐가 에이전트의
품질과 비용을 좌우합니다. 이 문서는 Hermes의 컨텍스트 관리 4대 축을 봅니다:

1. **시스템 프롬프트 조립** (`agent/prompt_builder.py`) — 조각을 만들고
2. **3계층 프롬프트 구조** (`agent/system_prompt.py`) — 조각을 합치되 캐시를 지키고
3. **컨텍스트 압축** (`agent/context_compressor.py`) — 길어지면 요약하고
4. **컨텍스트 엔진 추상화** (`agent/context_engine.py`) — 압축 전략을 교체 가능하게

가장 중요한 개념은 **"대화별 프롬프트 캐싱은 신성하다"**(`AGENTS.md`)입니다.

### 소목차
- [1. 프롬프트 캐싱이 왜 신성한가](#1-프롬프트-캐싱이-왜-신성한가)
- [2. 3계층 프롬프트: stable / context / volatile](#2-3계층-프롬프트-stable--context--volatile)
- [3. prompt_builder — 조각 만들기 + 위협 스캔](#3-prompt_builder--조각-만들기--위협-스캔)
- [4. 컨텍스트 압축: 무엇을, 어떻게](#4-컨텍스트-압축-무엇을-어떻게)
- [5. 컨텍스트 엔진 추상화(ABC)와 생명주기](#5-컨텍스트-엔진-추상화abc와-생명주기)

---

## 1. 프롬프트 캐싱이 왜 신성한가

- **프롬프트 캐싱(prompt caching)**: 많은 LLM 제공자는 "이전에 본 것과 동일한
  프롬프트 앞부분(prefix)"을 다시 보내면, 그 부분을 훨씬 싸고 빠르게 처리합니다
  (캐시 재사용). 긴 대화는 매 턴 같은 시스템 프롬프트 + 앞선 대화를 다시 보내므로,
  이 캐시가 유지되면 비용이 극적으로 줄어듭니다.
- **깨지는 조건**: 과거 컨텍스트를 바꾸거나, 도구 묶음을 중간에 교체하거나, 시스템
  프롬프트를 재구성하면 prefix가 달라져 캐시가 **무효화**되고 비용이 배가됩니다.

그래서 `agent/system_prompt.py`의 첫 문장이 핵심 규칙을 못 박습니다:
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/agent/system_prompt.py" lines="1-9" />
```
The agent's system prompt is built once per session and reused across all
turns — only context compression triggers a rebuild. This keeps the
upstream prefix cache warm.
```
(`agent/system_prompt.py` 1-9행)

즉 시스템 프롬프트는 **세션 시작 시 한 번 만들고, 세션 내내 바이트 단위로 고정**
됩니다. 유일한 예외가 컨텍스트 압축입니다(4절). 재개(resume) 시에도
`sessions.system_prompt`([06](06_state.md))에서 그대로 복원해 캐시를 잇습니다.

---

## 2. 3계층 프롬프트: stable / context / volatile

시스템 프롬프트는 세 계층을 `\n\n`으로 이어 붙여 만듭니다.
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/agent/system_prompt.py" lines="10-20" />
(`agent/system_prompt.py` 10-20행)

- **stable(안정 계층)**: 정체성(SOUL.md 또는 `DEFAULT_AGENT_IDENTITY`), 도구
  안내, computer-use 안내, Nous 구독 블록, 도구 사용 강제 안내 + 모델별 운영 안내,
  스킬 프롬프트, 환경 힌트, 플랫폼 힌트. **가장 안정적이라 prefix 캐시의 몸통**입니다.
- **context(맥락 계층)**: 호출자가 준 `system_message` + 작업 디렉토리(`TERMINAL_CWD`)
  아래에서 발견한 컨텍스트 파일(AGENTS.md, .cursorrules 등).
- **volatile(휘발 계층)**: 메모리 스냅샷, `USER.md` 프로필, 외부 메모리 provider
  블록, 그리고 타임스탬프/세션/모델/provider 한 줄.

> **왜 이 순서인가 (설계 의도):** 캐시는 "앞에서부터 같아야" 재사용됩니다. 그래서
> 거의 안 변하는 것(stable)을 앞에, 자주 변하는 것(volatile: 시각 등)을 뒤에 둡니다.
> 이렇게 하면 휘발 계층이 바뀌어도 앞의 안정 계층 캐시는 최대한 살아남습니다. 이는
> "가장 안정적인 것을 프롬프트 앞쪽에" 라는 캐시 친화적 배치의 정석입니다.

`system_prompt.py`는 `agent/prompt_builder.py`에서 많은 조각 상수/함수를 가져옵니다
(30-47행): `DEFAULT_AGENT_IDENTITY`, `SKILLS_GUIDANCE`, `MEMORY_GUIDANCE`,
`PLATFORM_HINTS`, `TOOL_USE_ENFORCEMENT_GUIDANCE` 등. 또한 `_ra()`(53행~)로
`run_agent` 네임스페이스의 헬퍼(`load_soul_md` 등)를 지연 참조하는데, 이는 많은
테스트가 `run_agent.load_soul_md`를 패치하기 때문에 그 패치가 계속 먹히게 하려는
배려입니다.

---

## 3. prompt_builder — 조각 만들기 + 위협 스캔

`agent/prompt_builder.py`는 프롬프트 조각을 만드는 **상태 없는(stateless)** 헬퍼
모음입니다.
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/agent/prompt_builder.py" lines="1-5" />
```
System prompt assembly -- identity, platform hints, skills index, context files.
All functions are stateless. AIAgent._build_system_prompt() calls these ...
```
(`agent/prompt_builder.py` 1-5행)

여기서 특히 중요한 것이 **컨텍스트 파일 위협 스캔**입니다.
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/agent/prompt_builder.py" lines="37-45" />
(37-45행) — `AGENTS.md`, `.cursorrules`, `SOUL.md` 같은 파일은 시스템 프롬프트에
그대로 주입되는데, 만약 누군가 그 파일에 **프롬프트 인젝션(promptware)** 을 심어두면
에이전트가 탈취될 수 있습니다. 그래서 주입 전에 `tools/threat_patterns.py`의 공통
패턴으로 스캔하고, 매치되면 실제 내용 대신 플레이스홀더로 막습니다(내용은 프롬프트에
도달하지 못함). 이 패턴은 메모리 도구 스캐너, 도구 결과 구분자 시스템과 **단일
진실 소스(single source of truth)** 를 공유합니다.

> 이 설계는 "신뢰 경계(trust boundary)"를 명확히 합니다: 파일에서 온 콘텐츠는
> 잠재적으로 적대적일 수 있으므로, 프롬프트에 넣기 전 반드시 검사합니다.

---

## 4. 컨텍스트 압축: 무엇을, 어떻게

대화가 길어져 모델의 토큰 한도에 근접하면, 중간 내용을 **요약본**으로 갈아끼워
대화를 이어갑니다. 담당은 `agent/context_compressor.py`(약 5,400줄).
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/agent/context_compressor.py" lines="1-17" />
(`agent/context_compressor.py` 1-17행) 핵심 아이디어:

- **보조 모델 사용**(3-4행): 요약은 값싸고 빠른 **보조(auxiliary) 모델**에게 시킵니다.
  주 모델의 비싼 토큰을 요약에 낭비하지 않습니다. (`agent/auxiliary_client.py`의
  `call_llm`, 28행 import.)
- **머리와 꼬리 보호(head/tail protection)**(4-5, 13행): 대화의 맨 앞(작업 정의)과
  맨 뒤(최근 맥락)는 남기고 **중간만 요약**합니다. 꼬리는 고정 개수가 아니라
  토큰 예산 기반으로 보호합니다.
- **구조화된 요약 템플릿**(7-8행): "해결된 질문 / 미해결 질문"을 추적하는 구조화된
  형식으로 요약해 정보 손실을 줄입니다.
- **필터-안전 프리앰블**(9행): 요약기(summarizer)에게 이전 턴을 "지시가 아니라
  참고 자료(source material)"로 다루라고 명시해, 과거 지시가 새 지시로 오인되는
  것을 방지합니다. 과거 섹션 제목도 "Next Steps" 대신 "Historical(참고용)"로 바꿔
  활성 지시처럼 읽히지 않게 합니다(10행).
- **도구 출력 사전 정리**(14행): LLM 요약 전에 값싼 전처리로 도구 출력(대개 잡음)을
  먼저 쳐냅니다.
- **반복 압축 지원**(12행): 여러 번 압축돼도 이전 요약 정보를 보존하며 갱신합니다.

압축이 일어나면 [06](06_state.md)에서 본 것처럼 원본 메시지는 `active=0`/`compacted=1`로
표시되고, 세션은 `parent_session_id` 체인으로 분할됩니다. 배경 이론은
[tech_background/03_context_compression.md](tech_background/03_context_compression.md).

---

## 5. 컨텍스트 엔진 추상화(ABC)와 생명주기

압축 전략을 통째로 교체할 수 있도록, Hermes는 **추상 기반 클래스(ABC)** 로
"컨텍스트 엔진" 인터페이스를 정의합니다.
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/agent/context_engine.py" lines="1-26" />
(`agent/context_engine.py` 1-26행)

- 기본 구현은 4절의 `ContextCompressor`. 제3자 엔진(예: LCM)은 플러그인 시스템이나
  `plugins/context_engine/<name>/` 배치로 대체할 수 있습니다(5-7행).
- **설정 기반 선택**(9-10행): `config.yaml`의 `context.engine`으로 고름. 기본값은
  `"compressor"`. 한 번에 하나의 엔진만 활성.
- **엔진의 책임**(12-16행): 언제 압축할지 결정, 압축 수행, (선택) 에이전트가 부를
  도구 노출(예: `lcm_grep`), API 응답의 토큰 사용량 추적.
- **생명주기(lifecycle)**(18-26행): `on_session_start` → 매 응답 후
  `update_from_response` → 매 턴 후 `should_compress` 체크 → True면 `compress` →
  실제 세션 경계(CLI 종료/`/reset`/게이트웨이 만료)에서 `on_session_end`.
  **핵심 주의**(24-25행): `on_session_end`는 매 턴이 아니라 진짜 세션 경계에서만
  호출됩니다.

> **왜 ABC로 뽑았나 (설계 의도):** `AGENTS.md`는 "같은 카테고리의 확장 요구가 여러
> 개면 하나씩 머지하지 말고 ABC + 오케스트레이터를 설계하라"고 합니다. 컨텍스트
> 관리 전략(요약/DAG/LCM 등)은 연구가 활발한 영역이라, 코어를 건드리지 않고
> 실험을 갈아끼울 수 있도록 인터페이스를 먼저 고정한 것입니다.

다음 문서에서는 이 에이전트를 여러 메시징 플랫폼에 연결하는 **게이트웨이**를 봅니다.
→ [08_gateway.md](08_gateway.md)
