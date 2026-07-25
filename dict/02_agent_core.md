# 용어 사전 — 에이전트 코어·대화 루프

[⬆ 사전 전체 목차로](README.md)

이 문서는 분류(Content Class) **에이전트 코어·대화 루프** 에 속한 용어 31개를 다룹니다.

- 설명 속 링크를 누르면 해당 용어 항목으로 이동합니다.
- **하위 개념** = 이 용어보다 더 **일반적인** 개념(먼저 알아두면 좋은 바탕 개념), **상위 개념** = 이 용어를 더 **특수화**한 개념(구체화·사례)입니다.
- 각 항목 끝의 "이 용어를 참조하는 항목"으로 원래 보던 곳으로 되돌아갈 수 있습니다.

## 이 문서의 용어

- [에이전트](#agent)
- [AIAgent 클래스](#aiagent)
- [도구 호출 (함수 호출)](#tool-calling)
- [도구 호출 루프](#tool-calling-loop)
- [run_conversation 루프](#run-conversation)
- [턴](#turn)
- [반복 예산](#iteration-budget)
- [그레이스 콜](#grace-call)
- [ReAct 패턴](#react)
- [역할 교대 불변식](#role-alternation)
- [메시지 프로토콜](#message-protocol)
- [tool_call_id](#tool-call-id)
- [병렬 도구 호출](#parallel-tool-calls)
- [재시도와 폴백](#retry-fallback)
- [LLM 제공자](#provider)
- [모델 메타데이터](#model-metadata)
- [크리덴셜 풀](#credential-pool)
- [Mixture-of-Agents (MoA)](#moa)
- [제안자/종합자](#proposer-aggregator)
- [앙상블](#ensemble)
- [자기일관성](#self-consistency)
- [LLM 심판](#llm-as-judge)
- [Mixture-of-Experts (MoE)](#moe)
- [서브에이전트 / 위임](#subagent)
- [델리게이션 (작업 위임)](#delegation)
- [칸반 (다중 에이전트 보드)](#kanban)
- [다중 에이전트 시스템](#multi-agent)
- [오케스트레이션](#orchestration)
- [휴먼 인 더 루프](#human-in-the-loop)
- [자율성 수준](#autonomy)
- [루프 종료 조건](#agent-loop-termination)

<a id="agent"></a>

### 에이전트

**영문**: Agent · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

[LLM](01_llm_basics.md#llm)이 [도구 호출](#tool-calling)을 통해 환경과 상호작용하며 여러 단계에 걸쳐 목표를 수행하는 시스템. 단발성 질문-답변 챗봇과 달리, 계획하고 행동하고 관찰 결과를 반영하는 루프를 반복합니다.

> **예시**: "이 저장소의 버그를 고쳐줘"라는 요청에 코드를 읽고, 수정하고, 테스트를 돌리고, 결과를 보고하는 것까지 해내는 시스템이 에이전트입니다.

**상위 개념(더 특수)**: [AIAgent 클래스](#aiagent) · [자율성 수준](#autonomy) · [휴먼 인 더 루프](#human-in-the-loop) · [Mixture-of-Agents (MoA)](#moa) · [다중 에이전트 시스템](#multi-agent) · [ReAct 패턴](#react) · [자기개선 에이전트](05_memory_self_improvement.md#self-improving-agent) · [서브에이전트 / 위임](#subagent) · [도구 호출 (함수 호출)](#tool-calling) · [트리아지 스위퍼](12_subsystems.md#triage-sweeper)

**관련 용어**: [LLM (대규모 언어 모델)](01_llm_basics.md#llm) · [도구 호출 루프](#tool-calling-loop) · [AIAgent 클래스](#aiagent)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="aiagent"></a>

### AIAgent 클래스

**영문**: AIAgent (run_agent.py) · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

Hermes의 에이전트 코어 클래스(`run_agent.py`). 모델/제공자/세션/도구/콜백 상태를 보관하고, [run_conversation](#run-conversation) 루프를 구동합니다. 기본 최대 반복 횟수는 90회입니다.

**하위 개념(더 일반)**: [에이전트](#agent)

**관련 용어**: [run_conversation 루프](#run-conversation) · [도구 호출 루프](#tool-calling-loop)

**이 용어를 참조하는 항목**: [에이전트](#agent) · [배치 러너](12_subsystems.md#batch-runner) · [HermesCLI](07_gateway_interfaces.md#hermes-cli) · [run_conversation 루프](#run-conversation)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="tool-calling"></a>

### 도구 호출 (함수 호출)

**영문**: Tool Calling / Function Calling · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

[LLM](01_llm_basics.md#llm)에게 함수 목록([도구 스키마](03_tool_system.md#tool-schema))을 알려주고, 모델이 자연어 대신 `{"name": ..., "arguments": ...}` 형태의 구조화된 호출을 내놓게 하는 기능. 텍스트 생성만 하던 모델이 실제 행동을 하게 만드는 관문입니다.

> **예시**: "서울 날씨 알려줘"에 모델이 `get_weather(city="Seoul")` 호출을 출력하고, 시스템이 실행 결과를 돌려주면 모델이 답을 완성합니다.

**하위 개념(더 일반)**: [에이전트](#agent)

**상위 개념(더 특수)**: [메시지 프로토콜](#message-protocol) · [병렬 도구 호출](#parallel-tool-calls) · [도구](03_tool_system.md#tool) · [도구 호출 루프](#tool-calling-loop)

**관련 용어**: [도구 스키마](03_tool_system.md#tool-schema) · [디스패치](03_tool_system.md#dispatch) · [ReAct 패턴](#react)

**이 용어를 참조하는 항목**: [에이전트](#agent) · [에이전트형 RAG](06_state_retrieval.md#agentic-rag) · [환각](01_llm_basics.md#hallucination) · [LLM (대규모 언어 모델)](01_llm_basics.md#llm) · [ReAct 패턴](#react) · [구조화 출력](01_llm_basics.md#structured-output)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="tool-calling-loop"></a>

### 도구 호출 루프

**영문**: Tool-Calling Loop · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

모델 호출 → 도구 실행 → 결과 반환 → 다시 모델 호출을 반복하는 에이전트의 심장 박동. 모델이 도구 호출 없이 최종 답을 내놓거나 [반복 예산](#iteration-budget)이 소진되면 종료됩니다.

> **예시**: 파일 읽기 → 버그 발견 → 수정 쓰기 → 테스트 실행 → 통과 확인 → 최종 보고. 이 여섯 단계가 한 루프에서 이어집니다.

**하위 개념(더 일반)**: [도구 호출 (함수 호출)](#tool-calling)

**상위 개념(더 특수)**: [루프 종료 조건](#agent-loop-termination) · [반복 예산](#iteration-budget) · [역할 교대 불변식](#role-alternation) · [run_conversation 루프](#run-conversation) · [턴](#turn)

**관련 용어**: [반복 예산](#iteration-budget) · [역할 교대 불변식](#role-alternation) · [run_conversation 루프](#run-conversation)

**이 용어를 참조하는 항목**: [에이전트](#agent) · [AIAgent 클래스](#aiagent) · [ReAct 패턴](#react)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="run-conversation"></a>

### run_conversation 루프

**영문**: run_conversation · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

Hermes의 대화 루프 구현(`agent/conversation_loop.py`). 재시도·폴백·[압축](04_prompt_context.md#context-compression)·[도구 디스패치](03_tool_system.md#dispatch)·사후 훅을 모두 포함하며, `while (api_call_count < max_iterations and budget.remaining > 0) or grace_call` 조건으로 돌아갑니다.

**하위 개념(더 일반)**: [도구 호출 루프](#tool-calling-loop)

**상위 개념(더 특수)**: [재시도와 폴백](#retry-fallback)

**관련 용어**: [AIAgent 클래스](#aiagent) · [턴](#turn) · [그레이스 콜](#grace-call)

**이 용어를 참조하는 항목**: [AIAgent 클래스](#aiagent) · [그레이스 콜](#grace-call) · [도구 호출 루프](#tool-calling-loop)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="turn"></a>

### 턴

**영문**: Turn · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

사용자 메시지 하나에 대해 에이전트가 응답을 완성하기까지의 한 사이클. 한 턴 안에 여러 번의 모델 호출과 도구 실행이 있을 수 있습니다.

**하위 개념(더 일반)**: [도구 호출 루프](#tool-calling-loop)

**상위 개념(더 특수)**: [트래젝토리 (실행 궤적)](12_subsystems.md#trajectory) · [턴 격리](11_design_principles.md#turn-isolation)

**관련 용어**: [역할 교대 불변식](#role-alternation) · [세션](06_state_retrieval.md#session)

**이 용어를 참조하는 항목**: [run_conversation 루프](#run-conversation) · [세션](06_state_retrieval.md#session)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="iteration-budget"></a>

### 반복 예산

**영문**: Iteration Budget · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

한 턴에서 허용되는 모델 호출 횟수의 상한. 무한 루프와 비용 폭주를 막는 안전장치이며, Hermes에서는 부모와 [서브에이전트](#subagent)가 예산을 공유합니다.

> **예시**: 예산이 90회인데 모델이 같은 오류를 내는 도구를 계속 부르면, 90회에서 강제 종료되어 비용 폭주를 막습니다.

**하위 개념(더 일반)**: [도구 호출 루프](#tool-calling-loop)

**상위 개념(더 특수)**: [그레이스 콜](#grace-call)

**관련 용어**: [그레이스 콜](#grace-call) · [델리게이션 (작업 위임)](#delegation)

**이 용어를 참조하는 항목**: [루프 종료 조건](#agent-loop-termination) · [서브에이전트 / 위임](#subagent) · [도구 호출 루프](#tool-calling-loop)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="grace-call"></a>

### 그레이스 콜

**영문**: Grace Call · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

[반복 예산](#iteration-budget)이 소진됐을 때, 어중간하게 끊기지 않도록 '마무리 답변을 만들기 위한 마지막 한 번의 호출'을 허용하는 장치.

**하위 개념(더 일반)**: [반복 예산](#iteration-budget)

**관련 용어**: [run_conversation 루프](#run-conversation)

**이 용어를 참조하는 항목**: [루프 종료 조건](#agent-loop-termination) · [반복 예산](#iteration-budget) · [run_conversation 루프](#run-conversation)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="react"></a>

### ReAct 패턴

**영문**: ReAct (Reason + Act) · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

생각(Thought) → 행동(Action) → 관찰(Observation)을 반복하는 에이전트 패턴(2022년 논문). 행동이 생각을 [그라운딩](01_llm_basics.md#grounding)하고 생각이 행동을 조직화합니다. 네이티브 [도구 호출](#tool-calling)은 이 패턴의 구조화된 후예입니다.

> **예시**: Thought: 파일을 먼저 봐야겠다 → Action: read_file → Observation: (파일 내용) → Thought: 12행이 문제다... 의 반복이 ReAct입니다.

**하위 개념(더 일반)**: [에이전트](#agent)

**관련 용어**: [도구 호출 루프](#tool-calling-loop) · [그라운딩](01_llm_basics.md#grounding) · [추론 모델 / 사고 과정](01_llm_basics.md#reasoning-model)

**이 용어를 참조하는 항목**: [그라운딩](01_llm_basics.md#grounding) · [추론 모델 / 사고 과정](01_llm_basics.md#reasoning-model) · [도구 호출 (함수 호출)](#tool-calling)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="role-alternation"></a>

### 역할 교대 불변식

**영문**: Role Alternation · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

assistant(도구 호출) → tool(결과) → assistant(다음 응답) 순서로 역할이 엄격히 교대해야 하는 규칙. 같은 역할이 연속되거나 합성 user 메시지를 중간에 끼우면 API 오류와 [캐시](01_llm_basics.md#prompt-caching) 무효화를 일으킵니다.

> **예시**: assistant(도구 호출) 바로 다음에 또 assistant 메시지를 넣으면 API가 거부합니다. 반드시 tool 결과가 사이에 있어야 합니다.

**하위 개념(더 일반)**: [도구 호출 루프](#tool-calling-loop)

**관련 용어**: [프롬프트 캐싱](01_llm_basics.md#prompt-caching) · [메시지 프로토콜](#message-protocol)

**이 용어를 참조하는 항목**: [메시지 프로토콜](#message-protocol) · [프롬프트 캐싱](01_llm_basics.md#prompt-caching) · [도구 호출 루프](#tool-calling-loop) · [턴](#turn)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="message-protocol"></a>

### 메시지 프로토콜

**영문**: Message Protocol (roles) · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

system/user/assistant/tool 네 가지 역할로 구성되는 대화 형식. 도구 결과는 tool 역할 메시지로 반환되며 [tool_call_id](#tool-call-id)로 어느 호출의 결과인지 짝지어집니다.

**하위 개념(더 일반)**: [도구 호출 (함수 호출)](#tool-calling)

**상위 개념(더 특수)**: [tool_call_id](#tool-call-id)

**관련 용어**: [역할 교대 불변식](#role-alternation) · [tool_call_id](#tool-call-id)

**이 용어를 참조하는 항목**: [역할 교대 불변식](#role-alternation)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="tool-call-id"></a>

### tool_call_id

**영문**: tool_call_id · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

모델이 낸 각 도구 호출에 부여되는 고유 식별자. [병렬 도구 호출](#parallel-tool-calls) 시 어떤 결과가 어떤 호출에 대응하는지 구분하는 데 필수입니다.

**하위 개념(더 일반)**: [메시지 프로토콜](#message-protocol)

**관련 용어**: [병렬 도구 호출](#parallel-tool-calls)

**이 용어를 참조하는 항목**: [메시지 프로토콜](#message-protocol) · [병렬 도구 호출](#parallel-tool-calls)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="parallel-tool-calls"></a>

### 병렬 도구 호출

**영문**: Parallel Tool Calls · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

모델이 독립적인 여러 도구를 한 응답에서 동시에 호출하는 기능. 서로 의존성이 없는 작업(여러 파일 읽기 등)의 지연을 줄입니다.

> **예시**: "세 파일을 비교해줘"에 모델이 read_file 세 개를 한 번에 호출하면, 순차 호출 대비 시간이 1/3로 줄어듭니다.

**하위 개념(더 일반)**: [도구 호출 (함수 호출)](#tool-calling)

**관련 용어**: [tool_call_id](#tool-call-id)

**이 용어를 참조하는 항목**: [tool_call_id](#tool-call-id)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="retry-fallback"></a>

### 재시도와 폴백

**영문**: Retry & Fallback · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

모델 API 오류(레이트리밋, 일시 장애) 시 재시도하고, 반복 실패 시 다른 모델/[제공자](#provider)로 갈아타는 복원 메커니즘. [크리덴셜 풀](#credential-pool)과 결합해 가용성을 높입니다.

> **예시**: Claude가 응답하지 않으면 잠시 후 재시도하고, 계속 실패하면 GPT로 갈아타 대화를 이어갑니다.

**하위 개념(더 일반)**: [run_conversation 루프](#run-conversation)

**관련 용어**: [LLM 제공자](#provider) · [크리덴셜 풀](#credential-pool)

**이 용어를 참조하는 항목**: [지수 백오프](01_llm_basics.md#backoff) · [크리덴셜 풀](#credential-pool) · [LLM 제공자](#provider) · [레이트리밋](01_llm_basics.md#rate-limit)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="provider"></a>

### LLM 제공자

**영문**: LLM Provider · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

OpenAI, Anthropic, Google 등 모델 API를 제공하는 회사/서비스. Hermes는 제공자 추상화 계층으로 서로 다른 API 형식을 통일해, 같은 루프에서 어떤 모델이든 쓸 수 있게 합니다.

> **예시**: 같은 "파일을 읽어줘" 요청이 OpenAI에서는 tools 형식, Anthropic에서는 tool_use 블록으로 표현되는데, 제공자 계층이 이 차이를 숨깁니다.

**하위 개념(더 일반)**: [LLM (대규모 언어 모델)](01_llm_basics.md#llm)

**상위 개념(더 특수)**: [크리덴셜 풀](#credential-pool) · [모델 메타데이터](#model-metadata) · [Nous Portal](11_design_principles.md#nous-portal)

**관련 용어**: [재시도와 폴백](#retry-fallback) · [모델 메타데이터](#model-metadata) · [Mixture-of-Agents (MoA)](#moa)

**이 용어를 참조하는 항목**: [제공자별 캐시 구현](01_llm_basics.md#context-caching-provider) · [오픈 웨이트 모델](13_model_learning.md#open-weights) · [레이트리밋](01_llm_basics.md#rate-limit) · [재시도와 폴백](#retry-fallback)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="model-metadata"></a>

### 모델 메타데이터

**영문**: Model Metadata · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

각 모델의 [컨텍스트 한도](01_llm_basics.md#context-window), 지원 기능(도구 호출, 비전), 가격 등의 정보. 압축 임계값 계산과 기능 분기에 사용됩니다.

**하위 개념(더 일반)**: [LLM 제공자](#provider)

**관련 용어**: [컨텍스트 윈도우](01_llm_basics.md#context-window)

**이 용어를 참조하는 항목**: [LLM 제공자](#provider)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="credential-pool"></a>

### 크리덴셜 풀

**영문**: Credential Pool · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

같은 [제공자](#provider)의 API 키를 여러 개 등록해 두고, 레이트리밋이나 잔액 소진 시 자동으로 다음 키로 회전(failover)하는 시스템.

> **예시**: API 키 3개를 등록해 두면, 1번 키가 레이트리밋에 걸렸을 때 자동으로 2번 키로 넘어갑니다.

**하위 개념(더 일반)**: [LLM 제공자](#provider)

**관련 용어**: [재시도와 폴백](#retry-fallback)

**이 용어를 참조하는 항목**: [Nous Portal](11_design_principles.md#nous-portal) · [레이트리밋](01_llm_basics.md#rate-limit) · [재시도와 폴백](#retry-fallback)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="moa"></a>

### Mixture-of-Agents (MoA)

**영문**: Mixture-of-Agents · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

여러 [LLM](01_llm_basics.md#llm)에게 같은 질문을 주고 그 답들을 다시 다른 LLM이 종합해 최종 답을 만드는 추론 시점 조합 기법. Hermes에서는 `/moa` 명령으로 명시적으로 호출합니다(비용이 크므로 기본 경로가 아님).

> **예시**: 같은 질문을 GPT·Claude·Gemini에게 묻고, 세 답변을 Claude가 읽고 종합해 최종 답을 만드는 것이 MoA입니다.

**하위 개념(더 일반)**: [에이전트](#agent)

**상위 개념(더 특수)**: [제안자/종합자](#proposer-aggregator)

**관련 용어**: [제안자/종합자](#proposer-aggregator) · [앙상블](#ensemble) · [Mixture-of-Experts (MoE)](#moe)

**이 용어를 참조하는 항목**: [앙상블](#ensemble) · [Mixture-of-Experts (MoE)](#moe) · [다중 에이전트 시스템](#multi-agent) · [오케스트레이션](#orchestration) · [LLM 제공자](#provider) · [자기일관성](#self-consistency) · [슬래시 명령](07_gateway_interfaces.md#slash-command)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="proposer-aggregator"></a>

### 제안자/종합자

**영문**: Proposer / Aggregator · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

[MoA](#moa)의 두 역할: 제안자(proposer)들이 초안을 내고, 종합자(aggregator)가 초안들을 읽고 하나의 개선된 답으로 합칩니다.

**하위 개념(더 일반)**: [Mixture-of-Agents (MoA)](#moa)

**관련 용어**: [LLM 심판](#llm-as-judge)

**이 용어를 참조하는 항목**: [LLM 심판](#llm-as-judge) · [Mixture-of-Agents (MoA)](#moa)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="ensemble"></a>

### 앙상블

**영문**: Ensemble · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

여러 모델의 예측을 결합해 단일 모델보다 나은 결과를 얻는 고전적 머신러닝 기법(배깅, 부스팅 등). [MoA](#moa)는 생성 태스크용 앙상블로 볼 수 있습니다.

**상위 개념(더 특수)**: [LLM 심판](#llm-as-judge) · [자기일관성](#self-consistency)

**관련 용어**: [Mixture-of-Agents (MoA)](#moa) · [자기일관성](#self-consistency)

**이 용어를 참조하는 항목**: [Mixture-of-Agents (MoA)](#moa)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="self-consistency"></a>

### 자기일관성

**영문**: Self-Consistency · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

같은 모델에서 여러 답을 [샘플링](01_llm_basics.md#sampling)해 다수결로 결정하는 기법. '여러 모델' 대신 '여러 시도'를 쓰는 [MoA](#moa)의 단순 버전입니다.

**하위 개념(더 일반)**: [앙상블](#ensemble)

**관련 용어**: [샘플링 / 온도](01_llm_basics.md#sampling) · [Mixture-of-Agents (MoA)](#moa)

**이 용어를 참조하는 항목**: [앙상블](#ensemble) · [샘플링 / 온도](01_llm_basics.md#sampling)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="llm-as-judge"></a>

### LLM 심판

**영문**: LLM-as-a-Judge · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

강한 LLM에게 후보 답변들을 채점·선택하게 하는 기법. [종합자](#proposer-aggregator) 대신 '심판'을 쓰는 변형이며 평가 벤치마크에서도 널리 쓰입니다.

**하위 개념(더 일반)**: [앙상블](#ensemble)

**관련 용어**: [제안자/종합자](#proposer-aggregator)

**이 용어를 참조하는 항목**: [벤치마크 (평가)](13_model_learning.md#benchmark) · [제안자/종합자](#proposer-aggregator)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="moe"></a>

### Mixture-of-Experts (MoE)

**영문**: Mixture-of-Experts · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

하나의 모델 내부에서 토큰마다 일부 파라미터(전문가)만 활성화하는 아키텍처. 이름이 비슷한 [MoA](#moa)(완성된 여러 모델의 외부 조합)와 자주 혼동되지만 완전히 다른 개념입니다.

> **예시**: Mixtral 8x7B는 내부에 전문가 8명을 두고 토큰마다 2명만 활성화하는 MoE 모델입니다. 이는 모델 내부 구조이지 MoA 같은 외부 조합이 아닙니다.

**관련 용어**: [Mixture-of-Agents (MoA)](#moa)

**이 용어를 참조하는 항목**: [Mixture-of-Agents (MoA)](#moa)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="subagent"></a>

### 서브에이전트 / 위임

**영문**: Subagent / Delegation · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

메인 에이전트가 하위 작업을 떼어 별도 에이전트 인스턴스에 맡기는 것. Hermes의 `delegate` 도구가 이를 수행하며, 부모와 [반복 예산](#iteration-budget)을 공유해 폭주를 막습니다.

> **예시**: "이 라이브러리의 문서를 조사해줘"를 서브에이전트에 맡기면, 조사 과정의 긴 컨텍스트가 메인 대화를 오염시키지 않습니다.

**하위 개념(더 일반)**: [에이전트](#agent)

**상위 개념(더 특수)**: [델리게이션 (작업 위임)](#delegation)

**관련 용어**: [델리게이션 (작업 위임)](#delegation) · [반복 예산](#iteration-budget)

**이 용어를 참조하는 항목**: [delegate 도구](03_tool_system.md#delegate-tool) · [반복 예산](#iteration-budget)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="delegation"></a>

### 델리게이션 (작업 위임)

**영문**: Delegation · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

복잡한 작업을 하위 작업으로 나눠 [서브에이전트](#subagent)에 맡기는 패턴. 컨텍스트를 분리해 메인 대화를 깨끗하게 유지하는 효과도 있습니다. 다중 에이전트 협업에는 [칸반](#kanban)이 사용됩니다.

**하위 개념(더 일반)**: [서브에이전트 / 위임](#subagent)

**상위 개념(더 특수)**: [칸반 (다중 에이전트 보드)](#kanban)

**관련 용어**: [칸반 (다중 에이전트 보드)](#kanban)

**이 용어를 참조하는 항목**: [delegate 도구](03_tool_system.md#delegate-tool) · [반복 예산](#iteration-budget) · [다중 에이전트 시스템](#multi-agent) · [오케스트레이션](#orchestration) · [서브에이전트 / 위임](#subagent)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="kanban"></a>

### 칸반 (다중 에이전트 보드)

**영문**: Kanban · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

여러 에이전트가 작업을 주고받는 내구성 있는 작업 보드. 디스패처가 작업을 배분하고 워커 에이전트들이 처리하는 다중 에이전트 협업 계층입니다.

**하위 개념(더 일반)**: [델리게이션 (작업 위임)](#delegation)

**관련 용어**: [크론 (예약 작업)](12_subsystems.md#cron)

**이 용어를 참조하는 항목**: [델리게이션 (작업 위임)](#delegation) · [다중 에이전트 시스템](#multi-agent)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="multi-agent"></a>

### 다중 에이전트 시스템

**영문**: Multi-Agent System · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

여러 [에이전트](#agent)가 역할을 나눠 협업하는 구조. 위임형([델리게이션](#delegation)), 보드형([칸반](#kanban)), 합의형([MoA](#moa)) 등 협업 방식이 다양합니다.

> **예시**: Hermes에서 디스패처 에이전트가 칸반 보드에 작업을 올리고 워커 에이전트들이 가져가 처리하는 구성이 다중 에이전트 시스템입니다.

**하위 개념(더 일반)**: [에이전트](#agent)

**상위 개념(더 특수)**: [오케스트레이션](#orchestration)

**관련 용어**: [델리게이션 (작업 위임)](#delegation) · [칸반 (다중 에이전트 보드)](#kanban) · [Mixture-of-Agents (MoA)](#moa)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="orchestration"></a>

### 오케스트레이션

**영문**: Orchestration · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

여러 에이전트·도구·단계의 실행 순서와 데이터 흐름을 조율하는 것. 중앙에서 흐름을 지휘하는 오케스트레이터가 있을 수도, 에이전트들이 자율적으로 조율할 수도 있습니다.

> **예시**: [MoA](#moa)에서 제안자들에게 질문을 뿌리고 답을 모아 종합자에게 넘기는 흐름 제어가 오케스트레이션입니다.

**하위 개념(더 일반)**: [다중 에이전트 시스템](#multi-agent)

**관련 용어**: [델리게이션 (작업 위임)](#delegation)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="human-in-the-loop"></a>

### 휴먼 인 더 루프

**영문**: Human-in-the-Loop · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

에이전트의 자동 실행 흐름 중간에 사람의 확인·개입 지점을 두는 설계. 위험한 행동 전 승인([명령 승인](10_security.md#command-approval))이 대표적입니다.

> **예시**: Hermes가 `rm -rf` 같은 명령 앞에서 멈추고 사용자에게 y/n을 묻는 것이 휴먼 인 더 루프입니다.

**하위 개념(더 일반)**: [에이전트](#agent)

**관련 용어**: [명령 승인](10_security.md#command-approval) · [자율성 수준](#autonomy)

**이 용어를 참조하는 항목**: [자율성 수준](#autonomy)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="autonomy"></a>

### 자율성 수준

**영문**: Autonomy Level · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

에이전트가 사람 확인 없이 얼마나 멀리까지 스스로 진행하는가의 정도. 낮으면 안전하지만 느리고, 높으면 빠르지만 위험합니다. Hermes에서는 [승인 계층](10_security.md#command-approval)~[YOLO 모드](10_security.md#yolo-mode) 사이에서 조절합니다.

> **예시**: '제안만 하는 코파일럿' < '승인받고 실행' < '[YOLO 모드](10_security.md#yolo-mode) 완전 자율' 순으로 자율성이 올라갑니다.

**하위 개념(더 일반)**: [에이전트](#agent)

**관련 용어**: [휴먼 인 더 루프](#human-in-the-loop) · [YOLO 모드](10_security.md#yolo-mode)

**이 용어를 참조하는 항목**: [휴먼 인 더 루프](#human-in-the-loop)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="agent-loop-termination"></a>

### 루프 종료 조건

**영문**: Loop Termination · **분류**: [에이전트 코어·대화 루프](README.md#분류content-class)

[도구 호출 루프](#tool-calling-loop)가 멈추는 조건들: ① 모델이 도구 호출 없이 최종 답을 냄(자연 종료), ② [반복 예산](#iteration-budget) 소진, ③ 오류 반복. 종료 조건 설계가 무한 루프와 미완성 답변 사이의 균형을 결정합니다.

> **예시**: 모델이 같은 실패를 반복하며 예산만 태우는 경우, [그레이스 콜](#grace-call)이 '지금까지의 결과로 마무리 답변'을 만들게 합니다.

**하위 개념(더 일반)**: [도구 호출 루프](#tool-calling-loop)

**관련 용어**: [반복 예산](#iteration-budget) · [그레이스 콜](#grace-call)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---
