# 용어 사전 — LLM 기초

[⬆ 사전 전체 목차로](README.md)

이 문서는 **LLM 기초** 범주의 용어 15개를 다룹니다. 설명 속 파란 링크를 누르면 해당 용어 항목으로 이동하며, 각 항목 끝의 "이 용어를 참조하는 항목"으로 되돌아올 수 있습니다.

## 이 문서의 용어

- [LLM (대규모 언어 모델)](#llm)
- [트랜스포머](#transformer)
- [어텐션](#attention)
- [토큰](#token)
- [컨텍스트 윈도우](#context-window)
- [시스템 프롬프트](#system-prompt)
- [프롬프트](#prompt)
- [프롬프트 캐싱](#prompt-caching)
- [KV 캐시](#kv-cache)
- [샘플링 / 온도](#sampling)
- [추론 모델 / 사고 과정](#reasoning-model)
- [환각](#hallucination)
- [그라운딩](#grounding)
- [보조 모델](#auxiliary-model)
- [임베딩](#embedding)

<a id="llm"></a>

### LLM (대규모 언어 모델)

**영문**: Large Language Model · **범주**: LLM 기초

방대한 텍스트로 학습되어, 입력 텍스트 다음에 올 [토큰](#token)을 예측하는 방식으로 글을 생성하는 AI 모델. Hermes의 두뇌 역할을 하며, [도구 호출](02_agent_core.md#tool-calling) 능력을 통해 텍스트 생성을 넘어 실제 행동을 수행합니다.

**하위 개념**: [보조 모델](#auxiliary-model) · [컨텍스트 윈도우](#context-window) · [임베딩](#embedding) · [그라운딩](#grounding) · [환각](#hallucination) · [프롬프트](#prompt) · [LLM 제공자](02_agent_core.md#provider) · [추론 모델 / 사고 과정](#reasoning-model) · [샘플링 / 온도](#sampling) · [토큰](#token) · [트랜스포머](#transformer)

**관련 용어**: [트랜스포머](#transformer)

**이 용어를 참조하는 항목**: [에이전트](02_agent_core.md#agent) · [Mixture-of-Agents (MoA)](02_agent_core.md#moa) · [검색 증강 (RAG)](06_state_retrieval.md#retrieval) · [토크나이저 (검색)](06_state_retrieval.md#tokenizer) · [도구 호출 (함수 호출)](02_agent_core.md#tool-calling)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="transformer"></a>

### 트랜스포머

**영문**: Transformer · **범주**: LLM 기초

2017년 논문 "Attention Is All You Need"에서 제안된 신경망 구조로, 현대 [LLM](#llm)의 표준 아키텍처. [어텐션](#attention) 메커니즘으로 문장 안의 단어 간 관계를 병렬로 계산합니다.

**상위 개념**: [LLM (대규모 언어 모델)](#llm)

**하위 개념**: [어텐션](#attention)

**관련 용어**: [어텐션](#attention)

**이 용어를 참조하는 항목**: [LLM (대규모 언어 모델)](#llm)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="attention"></a>

### 어텐션

**영문**: Attention · **범주**: LLM 기초

입력의 각 부분이 다른 부분을 '얼마나 참고할지'를 가중치로 계산하는 메커니즘. [컨텍스트 윈도우](#context-window) 안의 모든 토큰 쌍을 비교하므로, 컨텍스트가 길수록 계산 비용이 커집니다.

**상위 개념**: [트랜스포머](#transformer)

**하위 개념**: [KV 캐시](#kv-cache)

**관련 용어**: [컨텍스트 윈도우](#context-window)

**이 용어를 참조하는 항목**: [트랜스포머](#transformer)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="token"></a>

### 토큰

**영문**: Token · **범주**: LLM 기초

[LLM](#llm)이 텍스트를 처리하는 최소 단위. 대략 영어 단어의 3/4, 한국어 1~2글자 수준입니다. API 요금과 [컨텍스트 한도](#context-window) 모두 토큰 단위로 계산됩니다.

**상위 개념**: [LLM (대규모 언어 모델)](#llm)

**관련 용어**: [컨텍스트 윈도우](#context-window) · [프롬프트 캐싱](#prompt-caching)

**이 용어를 참조하는 항목**: [컨텍스트 윈도우](#context-window) · [LLM (대규모 언어 모델)](#llm) · [프롬프트](#prompt) · [샘플링 / 온도](#sampling)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="context-window"></a>

### 컨텍스트 윈도우

**영문**: Context Window · **범주**: LLM 기초

모델이 한 번의 호출에서 볼 수 있는 [토큰](#token)의 최대 개수. 대화형 API는 상태가 없어 매 호출마다 대화 전체를 다시 보내야 하므로, 대화가 길어지면 [컨텍스트 압축](04_prompt_context.md#context-compression)이 필요해집니다.

**상위 개념**: [LLM (대규모 언어 모델)](#llm)

**하위 개념**: [중간 소실 현상](04_prompt_context.md#lost-in-the-middle)

**관련 용어**: [토큰](#token) · [컨텍스트 압축](04_prompt_context.md#context-compression) · [중간 소실 현상](04_prompt_context.md#lost-in-the-middle)

**이 용어를 참조하는 항목**: [어텐션](#attention) · [컨텍스트 압축](04_prompt_context.md#context-compression) · [컨텍스트 엔지니어링](04_prompt_context.md#context-engineering) · [도구 결과 크기 상한](03_tool_system.md#max-result-size) · [모델 메타데이터](02_agent_core.md#model-metadata) · [토큰](#token)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="system-prompt"></a>

### 시스템 프롬프트

**영문**: System Prompt · **범주**: LLM 기초

대화 시작 시 모델에게 역할·규칙·맥락을 지정하는 특별한 메시지. Hermes에서는 세션당 한 번 조립되어 대화 내내 바이트 단위로 고정됩니다([프롬프트 캐싱](#prompt-caching) 보호). 재조립되는 유일한 예외는 [컨텍스트 압축](04_prompt_context.md#context-compression)입니다.

**상위 개념**: [프롬프트](#prompt)

**하위 개념**: [시스템 프롬프트 3계층](04_prompt_context.md#system-prompt-tiers)

**관련 용어**: [프롬프트 캐싱](#prompt-caching) · [SOUL.md](04_prompt_context.md#soul-md) · [시스템 프롬프트 3계층](04_prompt_context.md#system-prompt-tiers)

**이 용어를 참조하는 항목**: [컨텍스트 엔지니어링](04_prompt_context.md#context-engineering) · [프롬프트](#prompt)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="prompt"></a>

### 프롬프트

**영문**: Prompt · **범주**: LLM 기초

모델에 입력으로 주는 텍스트 전체. [시스템 프롬프트](#system-prompt) + 대화 이력 + 도구 결과가 모두 프롬프트에 포함되어 매 호출 전송됩니다.

**상위 개념**: [LLM (대규모 언어 모델)](#llm)

**하위 개념**: [프롬프트 캐싱](#prompt-caching) · [시스템 프롬프트](#system-prompt)

**관련 용어**: [시스템 프롬프트](#system-prompt) · [토큰](#token)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="prompt-caching"></a>

### 프롬프트 캐싱

**영문**: Prompt Caching · **범주**: LLM 기초

이전 호출과 앞부분(prefix)이 바이트 단위로 동일하면 그 구간의 계산([KV 캐시](#kv-cache))을 재사용해 비용·지연을 크게 줄이는 제공자 기능. Hermes의 최상위 설계 원칙 — 과거 컨텍스트를 바꾸거나 시스템 프롬프트를 중간에 재조립하면 캐시가 무효화되므로 금지됩니다.

**상위 개념**: [프롬프트](#prompt)

**관련 용어**: [KV 캐시](#kv-cache) · [역할 교대 불변식](02_agent_core.md#role-alternation) · [컨텍스트 압축](04_prompt_context.md#context-compression)

**이 용어를 참조하는 항목**: [컨텍스트 압축](04_prompt_context.md#context-compression) · [KV 캐시](#kv-cache) · [역할 교대 불변식](02_agent_core.md#role-alternation) · [시스템 프롬프트](#system-prompt) · [시스템 프롬프트 3계층](04_prompt_context.md#system-prompt-tiers) · [토큰](#token)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="kv-cache"></a>

### KV 캐시

**영문**: KV Cache · **범주**: LLM 기초

[어텐션](#attention) 계산의 중간 결과(Key/Value)를 저장해 두는 캐시. [프롬프트 캐싱](#prompt-caching)이 재사용하는 대상이 바로 이것입니다.

**상위 개념**: [어텐션](#attention)

**관련 용어**: [프롬프트 캐싱](#prompt-caching)

**이 용어를 참조하는 항목**: [프롬프트 캐싱](#prompt-caching)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="sampling"></a>

### 샘플링 / 온도

**영문**: Sampling / Temperature · **범주**: LLM 기초

모델이 다음 [토큰](#token)을 고를 때 확률분포에서 뽑는 과정. 온도(temperature)가 높을수록 다양하고 낮을수록 결정적입니다. [자기일관성](02_agent_core.md#self-consistency) 같은 기법은 샘플링의 다양성을 활용합니다.

**상위 개념**: [LLM (대규모 언어 모델)](#llm)

**관련 용어**: [자기일관성](02_agent_core.md#self-consistency)

**이 용어를 참조하는 항목**: [자기일관성](02_agent_core.md#self-consistency)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="reasoning-model"></a>

### 추론 모델 / 사고 과정

**영문**: Reasoning Model / Chain-of-Thought · **범주**: LLM 기초

답하기 전에 내부적으로 긴 사고 과정(chain-of-thought)을 생성하는 모델·기법. "단계별로 생각하기"가 정답률을 올린다는 2022년 CoT 연구에서 출발했으며, [ReAct](02_agent_core.md#react)의 이론적 토대 중 하나입니다.

**상위 개념**: [LLM (대규모 언어 모델)](#llm)

**관련 용어**: [ReAct 패턴](02_agent_core.md#react)

**이 용어를 참조하는 항목**: [ReAct 패턴](02_agent_core.md#react)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="hallucination"></a>

### 환각

**영문**: Hallucination · **범주**: LLM 기초

모델이 사실이 아닌 내용을 그럴듯하게 생성하는 현상. [도구 호출](02_agent_core.md#tool-calling)로 실제 데이터를 조회([그라운딩](#grounding))하면 완화할 수 있습니다.

**상위 개념**: [LLM (대규모 언어 모델)](#llm)

**관련 용어**: [그라운딩](#grounding) · [도구 호출 (함수 호출)](02_agent_core.md#tool-calling)

**이 용어를 참조하는 항목**: [그라운딩](#grounding)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="grounding"></a>

### 그라운딩

**영문**: Grounding · **범주**: LLM 기초

모델의 출력을 실제 세계의 근거(도구 결과, 검색 결과, 파일 내용)에 붙들어 매는 것. [ReAct](02_agent_core.md#react)에서 관찰(Observation)이 생각을 그라운딩하는 역할을 합니다.

**상위 개념**: [LLM (대규모 언어 모델)](#llm)

**관련 용어**: [환각](#hallucination) · [검색 증강 (RAG)](06_state_retrieval.md#retrieval) · [ReAct 패턴](02_agent_core.md#react)

**이 용어를 참조하는 항목**: [환각](#hallucination) · [ReAct 패턴](02_agent_core.md#react) · [웹 검색 도구](03_tool_system.md#web-search-tool)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="auxiliary-model"></a>

### 보조 모델

**영문**: Auxiliary Model · **범주**: LLM 기초

본 대화가 아닌 잡무(요약, 제목 생성, 백그라운드 정비)에 쓰는 값싸고 빠른 모델. Hermes에서는 [컨텍스트 압축](04_prompt_context.md#context-compression)의 요약과 [큐레이터](05_memory_self_improvement.md#curator) 실행에 사용됩니다.

**상위 개념**: [LLM (대규모 언어 모델)](#llm)

**관련 용어**: [컨텍스트 압축](04_prompt_context.md#context-compression) · [큐레이터](05_memory_self_improvement.md#curator)

**이 용어를 참조하는 항목**: [컨텍스트 압축](04_prompt_context.md#context-compression) · [큐레이터](05_memory_self_improvement.md#curator) · [비전 도구](03_tool_system.md#vision-tools)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="embedding"></a>

### 임베딩

**영문**: Embedding · **범주**: LLM 기초

텍스트를 의미를 담은 숫자 벡터로 변환한 것. [벡터 검색](06_state_retrieval.md#vector-search)의 기반이며, 비슷한 의미의 텍스트는 가까운 벡터가 됩니다.

**상위 개념**: [LLM (대규모 언어 모델)](#llm)

**관련 용어**: [벡터 검색](06_state_retrieval.md#vector-search)

**이 용어를 참조하는 항목**: [벡터 검색](06_state_retrieval.md#vector-search)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---
