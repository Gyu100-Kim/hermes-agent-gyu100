# 04. 에이전트의 두뇌 — AIAgent와 대화 루프 (1-C-2)

## 이 문서에서 다루는 큰 맥락

이 문서는 Hermes의 **심장**을 다룹니다. 사용자가 메시지 하나를 보내면, 에이전트는
LLM에게 물어보고 → LLM이 요청한 도구를 실행하고 → 그 결과를 다시 LLM에게 주고 →
다시 물어보는 과정을 **반복**합니다. 이 반복을 **도구 호출 루프(tool-calling
loop)** 라고 부르며, 코드에서는 `run_conversation`이라는 하나의 큰 함수(약 3,900줄)가
담당합니다. (배경 이론은 [tech_background/01_tool_calling.md](tech_background/01_tool_calling.md))

큰 흐름:
```
AIAgent (run_agent.py)  ← 에이전트 객체(상태 보관소)
  └─ run_conversation(...) (agent/conversation_loop.py)  ← 한 "턴"을 처리
       ├─ build_turn_context(...)      # 턴 준비(프롤로그)
       └─ while (예산이 남아있는 동안):  # 도구 호출 루프
            ├─ 모델 API 호출
            ├─ 도구 호출이면 → handle_function_call → registry.dispatch
            ├─ 결과를 messages에 추가
            └─ 필요 시 컨텍스트 압축
```

### 소목차
- [1. AIAgent — 상태를 담는 그릇](#1-aiagent--상태를-담는-그릇)
- [2. run_conversation — 한 턴의 시작](#2-run_conversation--한-턴의-시작)
- [3. 턴 준비: build_turn_context (프롤로그)](#3-턴-준비-build_turn_context-프롤로그)
- [4. 핵심 루프: while 조건 한 줄 뜯어보기](#4-핵심-루프-while-조건-한-줄-뜯어보기)
- [5. 루프 한 바퀴 안에서 일어나는 일](#5-루프-한-바퀴-안에서-일어나는-일)
- [6. 재시도·폴백·압축](#6-재시도폴백압축)
- [7. 왜 이렇게 큰 함수인가 (설계)](#7-왜-이렇게-큰-함수인가-설계)

---

## 1. AIAgent — 상태를 담는 그릇

`AIAgent`는 `run_agent.py`에 정의된, 에이전트의 모든 상태를 담는 클래스입니다.
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/run_agent.py" lines="400-406" />
```python
class AIAgent:
    """
    AI Agent with tool calling capabilities.

    This class manages the conversation flow, tool execution, and response handling
    for AI models that support function calling.
    """
```
(`run_agent.py` 400-406행)

생성자(`__init__`, 423행~)의 인자들이 에이전트의 성격을 결정합니다.
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/run_agent.py" lines="423-452" />
주요 인자:
- `base_url`, `api_key`, `provider`, `model` — 어떤 LLM을 어디로 호출할지.
- `api_mode` — API 형식(예: OpenAI chat completions / Responses / codex 등).
- `max_iterations: int = 90` (434행) — **도구 호출 루프의 최대 반복 횟수**.
  주석에 "서브에이전트와 공유(shared with subagents)"라고 되어 있습니다 → 위임 시
  자식들과 예산을 나눠 씁니다 ([05](05_tools.md)의 delegation 참고).
- `enabled_toolsets`/`disabled_toolsets` — 어떤 도구 묶음을 켤지.
- `session_id` — 이 에이전트가 붙은 세션(→ [06](06_state.md)).
- 각종 `*_callback` — 진행 상황을 프론트엔드(CLI/TUI/게이트웨이)로 흘려보내는 콜백.
  같은 코어가 여러 얼굴을 갖는 비결입니다: 표시는 콜백으로 위임.

> **개념: provider / api_mode** — Hermes는 특정 LLM 회사에 묶이지 않습니다.
> `provider`(openrouter, nous, anthropic, ...)와 `api_mode`(요청/응답 형식)를
> 조합해 다양한 백엔드를 같은 루프로 다룹니다. provider별 차이 흡수는 `agent/`의
> provider 어댑터들이 담당합니다.

`run_conversation` 자체는 `run_agent.py`에서 얇은 전달자(thin forwarder)로 남고,
실제 본문은 `agent/conversation_loop.py`로 **추출(extract)** 되어 있습니다
(`run_agent.py` 6613행). 이는 `AGENTS.md`가 장려하는 "god-file을 모듈로 쪼개기"의
실례입니다.

---

## 2. run_conversation — 한 턴의 시작

<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/agent/conversation_loop.py" lines="849-880" />
```python
def run_conversation(
    agent,
    user_message: Any,
    system_message: str = None,
    conversation_history: List[Dict[str, Any]] = None,
    task_id: str = None,
    stream_callback: Optional[callable] = None,
    persist_user_message: Optional[Any] = None,
    persist_user_timestamp: Optional[float] = None,
    moa_config: Optional[dict[str, Any]] = None,
) -> Dict[str, Any]:
```
(`agent/conversation_loop.py` 849-859행)

- 첫 인자 `agent`는 위의 `AIAgent` 인스턴스입니다. 함수는 이 객체의 속성을 읽고
  쓰며 상태를 공유합니다(파일 상단 docstring 8-9행 설명). 즉 이 함수는 사실상
  `AIAgent`의 메서드지만, 파일 크기 때문에 밖으로 뺀 것입니다.
- `user_message` — 이번 턴의 사용자 입력.
- `conversation_history` — 이전 대화(재개 시 SQLite에서 복원됨).
- `moa_config` — Mixture-of-Agents 설정(→ [tech_background/04_moa.md](tech_background/04_moa.md)).

함수 앞부분(881-899행)에서:
- MoA 턴이면 `decode_moa_turn`으로 설정을 분리(881-892행).
- **턴별 압축 상태 초기화**(897-899행) — 게이트웨이는 에이전트를 여러 턴에 걸쳐
  캐시하므로, 이전 턴의 압축 경계가 이번 턴으로 새어나가지 않게 리셋합니다.

---

## 3. 턴 준비: build_turn_context (프롤로그)

루프에 들어가기 전, "한 턴에 한 번만" 해야 하는 준비 작업을 모아둔 함수가
`build_turn_context`입니다.
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/agent/conversation_loop.py" lines="901-913" />
주석(901-908행)이 프롤로그가 하는 일을 나열합니다:
- stdio 가드, 재시도 카운터 리셋
- 사용자 메시지 살균(sanitization)
- todo/넛지(nudge) 하이드레이션
- **시스템 프롬프트 복원 또는 빌드** ← 프롬프트 캐시의 핵심(→ [07](07_prompt_context.md))
- **사전 압축(preflight compression)**
- `pre_llm_call` 플러그인 훅
- 외부 메모리 프리페치
- 크래시 대비 영속화

이 함수가 `agent`의 상태를 바꾸고, 루프가 읽어야 할 지역 변수들(`messages`,
`api_call_count` 등)을 돌려줍니다. 상세 구현은 `agent/turn_context.py`.

---

## 4. 핵심 루프: while 조건 한 줄 뜯어보기

Hermes 전체에서 가장 중요한 한 줄입니다.
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/agent/conversation_loop.py" lines="1009-1009" />
```python
while (api_call_count < agent.max_iterations and agent.iteration_budget.remaining > 0) or agent._budget_grace_call:
```
(`agent/conversation_loop.py` 1009행)

한 조각씩 풀어보면:
- `api_call_count < agent.max_iterations` — 지금까지 모델을 부른 횟수가 상한(기본
  90)보다 작아야 계속 돎. 무한 루프 방지.
- `agent.iteration_budget.remaining > 0` — **반복 예산(iteration budget)** 이
  남아 있어야 함. 이는 단순 카운터가 아니라, 부모/자식(위임) 에이전트가 **공유**하는
  예산입니다(`agent/iteration_budget.py`의 `IterationBudget`). 자식이 많이 쓰면
  부모가 쓸 몫이 줄어듭니다.
- `or agent._budget_grace_call` — 예산이 바닥나도 **딱 한 번 더(grace call)** 모델을
  부를 기회. 예산이 끝났을 때 "그래서 지금까지 뭘 했는지 정리해줘" 같은 마무리
  응답을 낼 수 있게 하는 안전장치입니다.

> **개념: 반복 예산(iteration budget)** — "모델을 몇 번 부를 수 있는가"를 하나의
> 통화(currency)처럼 관리하는 장치. 위임(delegation) 시 부모와 자식이 이 예산을
> 나눠 쓰므로, 자식 에이전트가 폭주해 비용이 무한정 늘어나는 것을 구조적으로
> 막습니다.

---

## 5. 루프 한 바퀴 안에서 일어나는 일

루프 본문 앞부분(1010-1044행)을 봅시다.
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/agent/conversation_loop.py" lines="1009-1044" />

1. **사용자 중간 개입(redirect) 처리** (1010-1018행): 모델이 일하는 도중 사용자가
   정정 메시지를 보냈으면(`_drain_pending_redirect`), `_apply_active_turn_redirect`로
   대화에 안전하게 끼워 넣습니다. 이때도 **역할 교대(role alternation)** 규칙과
   프롬프트 캐시를 깨지 않도록 세심하게 처리합니다(115-159행 참고).
2. **체크포인트 리셋** (1021행): 각 반복이 스냅샷을 한 번 찍을 수 있도록 초기화.
3. **인터럽트 확인** (1024-1029행): 사용자가 새 메시지를 보내 중단을 요청했으면
   루프를 빠져나감(`interrupted = True`).
4. **호출 횟수 증가** (1031-1033행).
5. **예산 소비 / grace 처리** (1038-1044행): grace call이면 플래그를 소비하고,
   아니면 `iteration_budget.consume()`로 예산을 하나 깎습니다. 실패하면
   "예산 소진" 메시지와 함께 루프 종료.
6. **step 콜백 발화** (1047행~): 게이트웨이 훅(`agent:step` 이벤트)에 진행을 알림.

그 뒤(문서로 다 옮기기엔 매우 긴 부분)에서 실제 **모델 API 호출**이 일어나고,
응답에 도구 호출(tool call)이 있으면 `handle_function_call`을 통해 도구가 실행되며,
그 결과가 `messages`에 추가되어 다음 반복의 입력이 됩니다. 도구 디스패치의 실제
메커니즘은 [05_tools.md](05_tools.md)에서 다룹니다.

---

## 6. 재시도·폴백·압축

루프 안에는 실제 세계의 지저분함을 다루는 방대한 로직이 들어 있습니다.

- **재시도(retry)** (1708행 `while retry_count < max_retries:`): API 호출이
  일시적 오류(rate-limit, overload, 연결 끊김)로 실패하면 백오프하며 다시 시도.
  오류 분류는 `agent/error_classifier.py`의 `classify_api_error`가 담당(43행 import).
- **폴백(fallback)**: 주 모델이 계속 실패하면 미리 설정한 다른 provider로 넘어감
  (CLI `hermes fallback`으로 설정, → [03](03_entrypoints.md)).
- **컨텍스트 압축(compression)**: 대화가 길어져 토큰 한도에 근접하면 중간 내용을
  요약으로 갈아끼움. import된 `PRE_API_COMPRESSION_STATUS_TEMPLATE` 등(31-39행)이
  이 과정의 상태 메시지 템플릿입니다. 상세는 [07](07_prompt_context.md)과
  [tech_background/03_context_compression.md](tech_background/03_context_compression.md).
- **오류 분류 정확성** (100-112행): 로컬 처리 모듈(`message_sanitization` 등)과
  API 호출 모듈(`chat_completion_helpers`)을 구분해, 일시적 API 오류를 "재시도 불가한
  로컬 버그"로 오분류하지 않도록 세심하게 관리합니다(#66267 언급).

---

## 7. 왜 이렇게 큰 함수인가 (설계)

`run_conversation`이 3,900줄에 달하는 것은 우연이 아닙니다. 이 한 함수 안에서:
- 모델 호출, 도구 실행, 재시도, 폴백, 압축, 인터럽트, 중간 개입, 예산 관리, 스트리밍,
  사후 훅이 **하나의 일관된 상태 기계**로 얽혀 돌아갑니다.

이들을 쪼개려면 수십 개의 지역 변수(대화 상태)를 여기저기로 넘겨야 해서 오히려
버그가 늘 수 있습니다. 그래서 순수 준비 로직(`build_turn_context`)이나 명확히
분리 가능한 헬퍼(메시지 살균, 오류 분류)는 밖으로 빼되, **핵심 상태 기계는 한
곳에** 두는 절충을 택했습니다. `AGENTS.md`가 강조하는 "역할 교대 불변식,
프롬프트 캐시 안정성"을 지키려면 이 상태들을 한 눈에 볼 수 있어야 하기 때문입니다.

다음 문서에서는 이 루프가 실제로 "도구를 실행"하는 계층으로 내려갑니다.
→ [05_tools.md](05_tools.md)
