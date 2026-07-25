# 용어 사전 — 크론·플러그인·부가 서브시스템

[⬆ 사전 전체 목차로](README.md)

이 문서는 분류(Content Class) **크론·플러그인·부가 서브시스템** 에 속한 용어 10개를 다룹니다.

- 설명 속 링크를 누르면 해당 용어 항목으로 이동합니다.
- **하위 개념** = 이 용어보다 더 **일반적인** 개념(먼저 알아두면 좋은 바탕 개념), **상위 개념** = 이 용어를 더 **특수화**한 개념(구체화·사례)입니다.
- 각 항목 끝의 "이 용어를 참조하는 항목"으로 원래 보던 곳으로 되돌아갈 수 있습니다.

## 이 문서의 용어

- [크론 (예약 작업)](#cron)
- [크론 스케줄러](#cron-scheduler)
- [플러그인](#plugin)
- [플러그인 훅](#plugin-hook)
- [관측성](#observability)
- [ACP 어댑터](#acp-adapter)
- [국제화 (i18n)](#i18n)
- [배치 러너](#batch-runner)
- [트리아지 스위퍼](#triage-sweeper)
- [트래젝토리 (실행 궤적)](#trajectory)

<a id="cron"></a>

### 크론 (예약 작업)

**영문**: Cron / Scheduled Tasks · **분류**: [크론·플러그인·부가 서브시스템](README.md#분류content-class)

자연어로 등록하는 예약 작업 시스템(`cron/`). "매일 아침 9시에 뉴스 요약해 줘" 같은 요청을 스케줄로 저장하고 때가 되면 에이전트 턴을 실행합니다.

> **예시**: "평일 아침 8시에 내 캘린더 요약해서 Telegram으로 보내줘"가 크론 작업으로 등록됩니다.

**상위 개념(더 특수)**: [크론 스케줄러](#cron-scheduler)

**관련 용어**: [크론 스케줄러](#cron-scheduler) · [SessionDB](06_state_retrieval.md#sessiondb)

**이 용어를 참조하는 항목**: [칸반 (다중 에이전트 보드)](02_agent_core.md#kanban) · [웹훅](07_gateway_interfaces.md#webhook)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="cron-scheduler"></a>

### 크론 스케줄러

**영문**: Cron Scheduler · **분류**: [크론·플러그인·부가 서브시스템](README.md#분류content-class)

등록된 작업의 다음 실행 시각을 계산하고 시간이 되면 실행을 트리거하는 내부 엔진(`cron/scheduler.py`).

**하위 개념(더 일반)**: [크론 (예약 작업)](#cron)

**이 용어를 참조하는 항목**: [크론 (예약 작업)](#cron)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="plugin"></a>

### 플러그인

**영문**: Plugin · **분류**: [크론·플러그인·부가 서브시스템](README.md#분류content-class)

코어를 수정하지 않고 기능을 확장하는 외부 모듈(`plugins/`, `~/.hermes/plugins/`). 메모리 제공자, 모델 제공자, 컨텍스트 엔진, 관측 도구 등이 플러그인으로 제공됩니다.

> **예시**: Mem0 메모리 백엔드를 쓰고 싶으면 코어 수정 없이 plugins/memory/mem0 플러그인만 설치하면 됩니다.

**상위 개념(더 특수)**: [관측성](#observability) · [플러그인 훅](#plugin-hook)

**관련 용어**: [플러그인 훅](#plugin-hook) · [메모리 제공자](05_memory_self_improvement.md#memory-provider) · [풋프린트 사다리](11_design_principles.md#footprint-ladder)

**이 용어를 참조하는 항목**: [컨텍스트 엔진](04_prompt_context.md#context-engine) · [풋프린트 사다리](11_design_principles.md#footprint-ladder) · [메모리 제공자](05_memory_self_improvement.md#memory-provider) · [스킬 허브](05_memory_self_improvement.md#skills-hub) · [스킨 (CLI 테마)](11_design_principles.md#skin) · [웹 대시보드](07_gateway_interfaces.md#web-dashboard)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="plugin-hook"></a>

### 플러그인 훅

**영문**: Plugin Hooks · **분류**: [크론·플러그인·부가 서브시스템](README.md#분류content-class)

코어가 정해진 시점(도구 실행 전후, 턴 종료 등)에 플러그인 코드를 호출해 주는 연결 지점. 구체적 소비자 없는 훅 추가는 '투기적 인프라'로 금지됩니다.

**하위 개념(더 일반)**: [플러그인](#plugin)

**이 용어를 참조하는 항목**: [플러그인](#plugin)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="observability"></a>

### 관측성

**영문**: Observability · **분류**: [크론·플러그인·부가 서브시스템](README.md#분류content-class)

시스템 내부에서 무슨 일이 일어나는지 로그·메트릭·트레이스로 들여다보는 능력. Hermes에서는 플러그인으로 제공되며, 옵트인 없는 외부 전송은 금지됩니다.

> **예시**: "어제 에이전트가 왜 느렸지?"를 로그·트레이스에서 '도구 X가 30초씩 걸렸다'로 추적하는 것이 관측성입니다.

**하위 개념(더 일반)**: [플러그인](#plugin)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="acp-adapter"></a>

### ACP 어댑터

**영문**: ACP Adapter · **분류**: [크론·플러그인·부가 서브시스템](README.md#분류content-class)

Hermes를 [ACP](08_protocols.md#acp) 호환 에이전트로 노출하는 어댑터(`acp_adapter/`). 프로토콜 메시지는 stdout으로, 로그는 stderr로 엄격히 분리하는 것이 핵심 규율입니다.

**하위 개념(더 일반)**: [ACP (에이전트 클라이언트 프로토콜)](08_protocols.md#acp)

**관련 용어**: [stdio 전송](08_protocols.md#stdio)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="i18n"></a>

### 국제화 (i18n)

**영문**: Internationalization · **분류**: [크론·플러그인·부가 서브시스템](README.md#분류content-class)

UI 문자열을 여러 언어로 제공하는 체계(`agent/i18n.py`). README도 중국어·우르두어 번역본이 있습니다.

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="batch-runner"></a>

### 배치 러너

**영문**: Batch Runner · **분류**: [크론·플러그인·부가 서브시스템](README.md#분류content-class)

여러 작업을 병렬로 처리하는 실행기(`batch_runner.py`). 연구·평가용 대량 실행에 사용됩니다.

**관련 용어**: [AIAgent 클래스](02_agent_core.md#aiagent)

**이 용어를 참조하는 항목**: [벤치마크 (평가)](13_model_learning.md#benchmark)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="triage-sweeper"></a>

### 트리아지 스위퍼

**영문**: Triage Sweeper · **분류**: [크론·플러그인·부가 서브시스템](README.md#분류content-class)

열린 PR·이슈를 자동으로 검토·분류하는 자동화 에이전트. '이미 구현됨/재현 불가/비일관' 세 사유로만 닫을 수 있고, 취향에 따른 거절 판단은 사람 몫으로 남깁니다.

> **예시**: AGENTS.md의 기여 루브릭이 스위퍼가 '닫으면 안 되는 경우'를 판단하는 기준으로 쓰입니다.

**하위 개념(더 일반)**: [에이전트](02_agent_core.md#agent)

**관련 용어**: [CI/CD](09_execution_infra.md#ci-cd)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="trajectory"></a>

### 트래젝토리 (실행 궤적)

**영문**: Trajectory · **분류**: [크론·플러그인·부가 서브시스템](README.md#분류content-class)

에이전트가 작업을 수행한 전체 기록(모델 호출, 도구 호출, 관찰의 시퀀스). 평가·디버깅·학습 데이터의 원천이며, Hermes의 trajectory_compressor 같은 연구 도구가 이를 다룹니다.

> **예시**: SWE-bench 평가에서 '이슈 → 40번의 도구 호출 → 패치 제출'까지의 전 과정 로그가 하나의 트래젝토리입니다.

**하위 개념(더 일반)**: [턴](02_agent_core.md#turn)

**관련 용어**: [벤치마크 (평가)](13_model_learning.md#benchmark) · [일화 기억](05_memory_self_improvement.md#episodic-memory)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---
