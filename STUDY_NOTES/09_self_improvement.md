# 09. 자기개선 루프 — 스킬·메모리·큐레이터 (1-C-7)

## 이 문서에서 다루는 큰 맥락

Hermes의 이름값을 하는 핵심 특징은 **세션을 거듭하며 스스로 배운다**는 것입니다.
사람이 "이건 이렇게 해"라고 알려주거나(`/learn`), 에이전트가 스스로 유용한 절차를
발견하면 그것을 **스킬(SKILL.md)** 로 저장하고, 사용자의 취향·사실은 **메모리
(MEMORY.md/USER.md)** 로 기억합니다. 그리고 백그라운드 **큐레이터(curator)** 가
쌓인 스킬을 주기적으로 정비합니다.

이 문서가 다루는 축:
1. **스킬(SKILL.md) 구조** — 배운 절차를 어떻게 저장하는가
2. **`/learn`** (`agent/learn_prompt.py`) — 스킬을 만드는 프롬프트
3. **큐레이터** (`agent/curator.py`) — 스킬을 정비하는 백그라운드 작업
4. **메모리 매니저** (`agent/memory_manager.py`) — 기억 provider 오케스트레이션
5. **학습 그래프** (`agent/learning_graph.py`) — 배운 것을 시각화

배경 이론은 [tech_background/02_self_improving_agents.md](tech_background/02_self_improving_agents.md).

### 소목차
- [1. 스킬이란 무엇인가 (SKILL.md)](#1-스킬이란-무엇인가-skillmd)
- [2. /learn — 경험을 스킬로](#2-learn--경험을-스킬로)
- [3. 스킬 작성 표준(HARDLINE)과 그 이유](#3-스킬-작성-표준hardline과-그-이유)
- [4. 큐레이터 — 스킬 정비 오케스트레이터](#4-큐레이터--스킬-정비-오케스트레이터)
- [5. 메모리 매니저 — 기억의 통합 지점](#5-메모리-매니저--기억의-통합-지점)
- [6. 학습 그래프 — 배운 것을 보이게](#6-학습-그래프--배운-것을-보이게)

---

## 1. 스킬이란 무엇인가 (SKILL.md)

- **스킬(skill)**: 특정 작업을 잘 하도록 적어둔 **절차적 지식**. 하나의 `SKILL.md`
  파일로 저장되며, 맨 위 **frontmatter**(YAML 메타데이터: name/description/version
  등)와 그 아래 **본문**(구체적 방법·명령·팁)으로 구성됩니다.
- 실제 예시로 `skills/creative/ascii-art/SKILL.md`를 봅시다.
  [`skills/creative/ascii-art/SKILL.md` 1-22행](../skills/creative/ascii-art/SKILL.md#L1-L22)
  ```markdown
  ---
  name: ascii-art
  description: "ASCII art: pyfiglet, cowsay, boxes, image-to-ascii."
  version: 4.0.0
  ...
  ---
  # ASCII Art Skill
  Multiple tools for different ASCII art needs...
  ```
  (`skills/creative/ascii-art/SKILL.md` 1-22행)
- **점진적 공개(progressive disclosure)**: 시스템 프롬프트에는 스킬의 **설명 한
  줄만** 색인되고([07](07_prompt_context.md)), 실제 본문은 `skill_view` 도구로
  필요할 때만 읽어옵니다. 그래서 스킬이 수백 개여도 매 턴 토큰을 잡아먹지 않습니다.
- 스킬 계층: `skills/`(기본 번들), `optional-skills/`(무거운/틈새, 기본 비활성),
  그리고 사용자/에이전트가 만든 프로파일 스킬.

> **왜 도구가 아니라 마크다운 파일인가 (설계 의도):** 새 능력을 코어 도구로 넣으면
> 매 API 호출마다 비용이 듭니다([05](05_tools.md)의 좁은 허리). 스킬은 텍스트
> 파일이라 **코어 스키마를 전혀 늘리지 않고** 능력을 무한히 추가할 수 있습니다.
> 이것이 "capability lives at the edges"의 핵심 구현입니다.

---

## 2. /learn — 경험을 스킬로

사용자가 `/learn`을 쓰면(또는 에이전트가 스스로), 방금 한 작업/문서/코드를 재사용
가능한 스킬로 정제합니다. 담당은 `agent/learn_prompt.py`.
[`agent/learn_prompt.py` 2-23행](../agent/learn_prompt.py#L2-L23)
(`agent/learn_prompt.py` 2-23행) 핵심 설계:

- `/learn`은 **열려 있습니다**(5-13행): 코드 디렉토리, API 문서 URL, 방금 대화에서
  한 워크플로, 붙여넣은 노트 등 사용자가 설명할 수 있는 무엇이든 대상.
- 이 모듈은 **하나의 프롬프트**를 만들어 살아있는 에이전트에게 시킵니다: (1) 사용자가
  지목한 출처를 **기존 도구**(`read_file`/`search_files`/`web_extract`/현재 대화)로
  수집하고, (2) `skill_manage`로 표준을 지킨 `SKILL.md`를 **한 개** 작성.
- **별도의 정제 엔진도, 모델-도구 발자국도 없습니다**(18-22행): 에이전트가 자기
  도구로 처리하므로 local/Docker/원격 백엔드에서 동일하게 동작하고, CLI/게이트웨이/
  대시보드의 모든 `/learn` 진입점이 `build_learn_prompt` 하나를 공유합니다.

> 이것은 [05](05_tools.md)의 "Footprint Ladder"에서 2번 rung(CLI 명령 + 스킬)을
> 그대로 실천한 예입니다: 새 기능을 코어가 아니라 "프롬프트 + 기존 도구"로 구현.

---

## 3. 스킬 작성 표준(HARDLINE)과 그 이유

`learn_prompt.py`는 스킬 작성 표준을 프롬프트에 박아 넣어, 에이전트가 유지보수자가
손으로 쓰듯 작성하게 만듭니다.
[`agent/learn_prompt.py` 34-45행](../agent/learn_prompt.py#L34-L45)
(34-45행) 가장 중요한 규칙:

- `description`은 **한 문장, 60자 이하**, 마침표로 끝, 마케팅 단어 금지, 스킬 이름
  반복 금지, 콜론 포함 시 큰따옴표로 감싸기.
- **왜 60자인가 (40-44행):** 시스템 프롬프트의 스킬 색인은 설명을 60자로 자르고
  **매 세션 로드**합니다. 60자를 넘으면 조용히 잘려 라우팅되지 않습니다. 즉 이건
  미관 문제가 아니라 **동작 정확성** 문제라, "문장을 쓰고 글자 수를 세서 넘으면
  줄여라"라고 못 박습니다.

> 이 규칙은 [07](07_prompt_context.md)의 프롬프트 캐시/토큰 예산과 직결됩니다.
> "배운 것"이 결국 시스템 프롬프트 색인에 들어가므로, 그 형식이 곧 비용과 라우팅
> 품질을 좌우합니다.

---

## 4. 큐레이터 — 스킬 정비 오케스트레이터

스킬이 계속 쌓이면 낡거나 중복되거나 안 쓰이는 것이 생깁니다. **큐레이터(curator)**
가 이를 백그라운드에서 정비합니다.
[`agent/curator.py` 1-20행](../agent/curator.py#L1-L20)
(`agent/curator.py` 1-20행)

- **비활성 트리거**(3-7행): 별도 cron 데몬 없이, 에이전트가 idle이고 마지막 큐레이터
  실행이 `interval_hours` 이전이면 `maybe_run_curator()`가 **포크된 AIAgent**를 띄워
  리뷰합니다.
- **책임**(9-13행): 파생된 스킬 활동 타임스탬프로 생명주기 상태 자동 전이;
  `skill_manage`로 핀 고정/보관/통합/패치할 수 있는 리뷰 에이전트 생성; 큐레이터
  상태(`last_run_at`, `paused` 등)를 `.curator_state`에 영속화.
- **엄격한 불변식(strict invariants)**(15-19행):
  - **에이전트가 만든 스킬만** 건드림(기본 번들 스킬은 보호).
  - **자동 삭제 절대 금지 — 보관(archive)만** 함. 보관은 복구 가능.
  - **핀 고정된(pinned) 스킬**은 모든 자동 전이를 우회.
  - **보조 클라이언트만** 사용 — 메인 세션의 프롬프트 캐시를 절대 건드리지 않음.

> 마지막 불변식이 특히 중요합니다: 큐레이터가 메인 대화의 프롬프트를 건드리면
> [07](07_prompt_context.md)의 "신성한 캐시"가 깨집니다. 그래서 별도의 보조 모델/
> 포크 에이전트로 완전히 분리해 돌립니다.

---

## 5. 메모리 매니저 — 기억의 통합 지점

스킬이 "방법"이라면, 메모리는 "사실/취향"입니다(예: 사용자 이름, 선호 언어).
`agent/memory_manager.py`가 여러 메모리 provider를 하나로 오케스트레이션합니다.
[`agent/memory_manager.py` 1-24행](../agent/memory_manager.py#L1-L24)
(`agent/memory_manager.py` 1-24행)

- **단일 통합 지점**(3-4행): 예전엔 백엔드별 코드가 흩어져 있었는데, 하나의
  매니저가 등록된 provider들에 위임하도록 정리했습니다.
- **외부 provider는 한 번에 하나만**(6-8행): 두 번째 외부 provider 등록은 경고와
  함께 거부됩니다. 도구 스키마 비대와 백엔드 충돌을 막기 위함(좁은 허리).
- **사용 패턴**(10-23행): 시스템 프롬프트에 `build_system_prompt()`로 기억을 넣고,
  턴 전에 `prefetch_all(user_message)`로 관련 기억을 당겨오고, 턴 후에
  `sync_all(...)`/`queue_prefetch_all(...)`로 갱신/선반입합니다.
- 기본 내장 provider는 `MEMORY.md`/`USER.md` 파일 기반이고, 플러그인으로
  Honcho/mem0/supermemory 등을 붙일 수 있습니다(`plugins/memory/`).
  Honcho의 변증법적 사용자 모델링은
  [tech_background/07_honcho_dialectic.md](tech_background/07_honcho_dialectic.md) 참고.

---

## 6. 학습 그래프 — 배운 것을 보이게

`agent/learning_graph.py`는 "시간이 지나며 무엇을 배웠는지"를 데스크톱에서
그래프로 보여줍니다.
[`agent/learning_graph.py` 1-14행](../agent/learning_graph.py#L1-L14)
(`agent/learning_graph.py` 1-14행)

- 노드: 베이스가 아닌 **학습/프로필 스킬**과 `MEMORY.md`/`USER.md`의 **기억 조각**을
  일급(first-class) 노드로 취급(3-5행).
- 엣지: 스킬 간 링크는 `related_skills` 선언에서(7행), 기억↔스킬 링크는 어휘
  겹침(lexical overlap)에서 파생(7-9행) → "내가 기억하는 것과 연결된 배운 스킬은
  무엇인가?"에 답할 수 있게.
- `SkillNode` 데이터클래스(28행~)에 `use_count`, `state`, `pinned`, `related` 등이
  담겨, 큐레이터의 생명주기 상태와도 연결됩니다.

다음 문서에서는 스케줄러·플러그인·ACP·프론트엔드 등 **부가 서브시스템**을 봅니다.
→ [10_subsystems.md](10_subsystems.md)
