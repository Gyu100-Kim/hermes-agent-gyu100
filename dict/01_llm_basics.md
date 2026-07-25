# 용어 사전 — LLM 기초

[⬆ 사전 전체 목차로](README.md)

이 문서는 분류(Content Class) **LLM 기초** 에 속한 용어 27개를 다룹니다.

- 설명 속 링크를 누르면 해당 용어 항목으로 이동합니다.
- **하위 개념** = 이 용어를 규정하는 데 필요한 더 **일반적·근본적인** 개념, **상위 개념** = 이 용어를 **활용해 만들어진** 더 특수한 개념입니다. (예: Attention → Transformer → LLM 순으로 상위)
- 각 항목의 **최초 등장** 연월은 상위/하위 판별의 참고 자료입니다(단, 상위 용어가 항상 늦게 생기는 것은 아닙니다).
- 각 항목 끝의 "이 용어를 참조하는 항목"으로 원래 보던 곳으로 되돌아갈 수 있습니다.

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
- [추론 (서빙)](#inference)
- [지연 시간](#latency)
- [응답 스트리밍](#streaming)
- [레이트리밋](#rate-limit)
- [지수 백오프](#backoff)
- [구조화 출력](#structured-output)
- [제약 디코딩](#constrained-decoding)
- [제공자별 캐시 구현](#context-caching-provider)
- [멀티모달](#multimodal)
- [비전 모델 (VLM)](#vision-model)
- [음성 인식 (STT)](#stt)
- [음성 합성 (TTS)](#tts)

<a id="llm"></a>

### LLM (대규모 언어 모델)

**영문**: Large Language Model · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2020-05

방대한 텍스트로 학습되어, 입력 텍스트 다음에 올 [토큰](#token)을 예측하는 방식으로 글을 생성하는 AI 모델. Hermes의 두뇌 역할을 하며, [도구 호출](02_agent_core.md#tool-calling) 능력을 통해 텍스트 생성을 넘어 실제 행동을 수행합니다.

> **예시**: GPT-4o, Claude, Gemini, Llama가 모두 LLM입니다. Hermes는 이들을 갈아 끼울 수 있는 부품처럼 다룹니다.

**하위 개념(더 일반·근본)**: [트랜스포머](#transformer) · [사전학습](13_model_learning.md#pretraining)

**상위 개념(이를 활용해 만든 개념)**: [에이전트](02_agent_core.md#agent) · [보조 모델](#auxiliary-model) · [벤치마크 (평가)](13_model_learning.md#benchmark) · [컨텍스트 윈도우](#context-window) · [그라운딩](#grounding) · [환각](#hallucination) · [추론 (서빙)](#inference) · [LLM 심판](02_agent_core.md#llm-as-judge) · [멀티모달](#multimodal) · [오픈 웨이트 모델](13_model_learning.md#open-weights) · [프롬프트](#prompt) · [LLM 제공자](02_agent_core.md#provider) · [추론 모델 / 사고 과정](#reasoning-model) · [검색 증강 (RAG)](06_state_retrieval.md#retrieval) · [샘플링 / 온도](#sampling) · [구조화 출력](#structured-output) · [도구 호출 (함수 호출)](02_agent_core.md#tool-calling)

**이 용어를 참조하는 항목**: [임베딩](#embedding) · [Mixture-of-Agents (MoA)](02_agent_core.md#moa) · [사전학습](13_model_learning.md#pretraining) · [토큰](#token) · [토크나이저 (검색)](06_state_retrieval.md#tokenizer) · [트랜스포머](#transformer)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="transformer"></a>

### 트랜스포머

**영문**: Transformer · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2017-06

2017년 논문 "Attention Is All You Need"에서 제안된 신경망 구조로, 현대 [LLM](#llm)의 표준 아키텍처. [어텐션](#attention) 메커니즘으로 문장 안의 단어 간 관계를 병렬로 계산합니다.

**하위 개념(더 일반·근본)**: [어텐션](#attention)

**상위 개념(이를 활용해 만든 개념)**: [LLM (대규모 언어 모델)](#llm) · [Mixture-of-Experts (MoE)](02_agent_core.md#moe)

**관련 용어**: [Mixture-of-Experts (MoE)](02_agent_core.md#moe)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="attention"></a>

### 어텐션

**영문**: Attention · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2014-09

입력의 각 부분이 다른 부분을 '얼마나 참고할지'를 가중치로 계산하는 메커니즘. [컨텍스트 윈도우](#context-window) 안의 모든 토큰 쌍을 비교하므로, 컨텍스트가 길수록 계산 비용이 커집니다.

**상위 개념(이를 활용해 만든 개념)**: [KV 캐시](#kv-cache) · [트랜스포머](#transformer)

**관련 용어**: [컨텍스트 윈도우](#context-window)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="token"></a>

### 토큰

**영문**: Token · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 1960년대(계산언어학)

[LLM](#llm)이 텍스트를 처리하는 최소 단위. 대략 영어 단어의 3/4, 한국어 1~2글자 수준입니다. API 요금과 [컨텍스트 한도](#context-window) 모두 토큰 단위로 계산됩니다.

> **예시**: "안녕하세요"는 모델에 따라 2~4개 토큰으로 쪼개집니다. 128k 컨텍스트 모델이란 토큰 128,000개까지 볼 수 있다는 뜻입니다.

**관련 용어**: [LLM (대규모 언어 모델)](#llm) · [컨텍스트 윈도우](#context-window) · [프롬프트 캐싱](#prompt-caching)

**이 용어를 참조하는 항목**: [컨텍스트 윈도우](#context-window) · [LLM (대규모 언어 모델)](#llm) · [프롬프트](#prompt) · [샘플링 / 온도](#sampling) · [응답 스트리밍](#streaming)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="context-window"></a>

### 컨텍스트 윈도우

**영문**: Context Window · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2017-06

모델이 한 번의 호출에서 볼 수 있는 [토큰](#token)의 최대 개수. 대화형 API는 상태가 없어 매 호출마다 대화 전체를 다시 보내야 하므로, 대화가 길어지면 [컨텍스트 압축](04_prompt_context.md#context-compression)이 필요해집니다.

> **예시**: 200k 토큰 윈도우 모델에서 대화가 190k에 도달하면, Hermes는 압축을 실행해 여유를 확보합니다.

**하위 개념(더 일반·근본)**: [LLM (대규모 언어 모델)](#llm)

**상위 개념(이를 활용해 만든 개념)**: [컨텍스트 엔지니어링](04_prompt_context.md#context-engineering) · [중간 소실 현상](04_prompt_context.md#lost-in-the-middle)

**관련 용어**: [토큰](#token) · [컨텍스트 압축](04_prompt_context.md#context-compression) · [중간 소실 현상](04_prompt_context.md#lost-in-the-middle)

**이 용어를 참조하는 항목**: [어텐션](#attention) · [컨텍스트 압축](04_prompt_context.md#context-compression) · [도구 결과 크기 상한](03_tool_system.md#max-result-size) · [모델 메타데이터](02_agent_core.md#model-metadata) · [토큰](#token)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="system-prompt"></a>

### 시스템 프롬프트

**영문**: System Prompt · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2019-11

대화 시작 시 모델에게 역할·규칙·맥락을 지정하는 특별한 메시지. Hermes에서는 세션당 한 번 조립되어 대화 내내 바이트 단위로 고정됩니다([프롬프트 캐싱](#prompt-caching) 보호). 재조립되는 유일한 예외는 [컨텍스트 압축](04_prompt_context.md#context-compression)입니다.

> **예시**: "너는 Hermes라는 어시스턴트다. 다음 규칙을 지켜라..."로 시작하는 보이지 않는 첫 메시지가 시스템 프롬프트입니다.

**하위 개념(더 일반·근본)**: [프롬프트](#prompt)

**상위 개념(이를 활용해 만든 개념)**: [시스템 프롬프트 3계층](04_prompt_context.md#system-prompt-tiers)

**관련 용어**: [프롬프트 캐싱](#prompt-caching) · [SOUL.md](04_prompt_context.md#soul-md) · [시스템 프롬프트 3계층](04_prompt_context.md#system-prompt-tiers)

**이 용어를 참조하는 항목**: [컨텍스트 엔지니어링](04_prompt_context.md#context-engineering) · [지시 튜닝](13_model_learning.md#instruction-tuning) · [페르소나](04_prompt_context.md#persona) · [프롬프트](#prompt)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="prompt"></a>

### 프롬프트

**영문**: Prompt · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2018-06

모델에 입력으로 주는 텍스트 전체. [시스템 프롬프트](#system-prompt) + 대화 이력 + 도구 결과가 모두 프롬프트에 포함되어 매 호출 전송됩니다.

**하위 개념(더 일반·근본)**: [LLM (대규모 언어 모델)](#llm)

**상위 개념(이를 활용해 만든 개념)**: [컨텍스트 엔지니어링](04_prompt_context.md#context-engineering) · [페르소나](04_prompt_context.md#persona) · [프롬프트 캐싱](#prompt-caching) · [프롬프트 인젝션](10_security.md#prompt-injection) · [ReAct 패턴](02_agent_core.md#react) · [시스템 프롬프트](#system-prompt)

**관련 용어**: [시스템 프롬프트](#system-prompt) · [토큰](#token)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="prompt-caching"></a>

### 프롬프트 캐싱

**영문**: Prompt Caching · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2023-11

이전 호출과 앞부분(prefix)이 바이트 단위로 동일하면 그 구간의 계산([KV 캐시](#kv-cache))을 재사용해 비용·지연을 크게 줄이는 제공자 기능. Hermes의 최상위 설계 원칙 — 과거 컨텍스트를 바꾸거나 시스템 프롬프트를 중간에 재조립하면 캐시가 무효화되므로 금지됩니다.

> **예시**: 10만 토큰 대화에서 캐시가 적중하면 입력 비용이 최대 90% 절감됩니다. 반대로 시스템 프롬프트 한 글자만 바뀌어도 전체 캐시가 무효화됩니다.

**하위 개념(더 일반·근본)**: [프롬프트](#prompt) · [KV 캐시](#kv-cache)

**상위 개념(이를 활용해 만든 개념)**: [제공자별 캐시 구현](#context-caching-provider)

**관련 용어**: [역할 교대 불변식](02_agent_core.md#role-alternation) · [컨텍스트 압축](04_prompt_context.md#context-compression)

**이 용어를 참조하는 항목**: [컨텍스트 압축](04_prompt_context.md#context-compression) · [KV 캐시](#kv-cache) · [지연 시간](#latency) · [역할 교대 불변식](02_agent_core.md#role-alternation) · [시스템 프롬프트](#system-prompt) · [시스템 프롬프트 3계층](04_prompt_context.md#system-prompt-tiers) · [토큰](#token)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="kv-cache"></a>

### KV 캐시

**영문**: KV Cache · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2019

[어텐션](#attention) 계산의 중간 결과(Key/Value)를 저장해 두는 캐시. [프롬프트 캐싱](#prompt-caching)이 재사용하는 대상이 바로 이것입니다.

**하위 개념(더 일반·근본)**: [어텐션](#attention)

**상위 개념(이를 활용해 만든 개념)**: [프롬프트 캐싱](#prompt-caching)

**관련 용어**: [프롬프트 캐싱](#prompt-caching)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="sampling"></a>

### 샘플링 / 온도

**영문**: Sampling / Temperature · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 1950년대(정보이론)

모델이 다음 [토큰](#token)을 고를 때 확률분포에서 뽑는 과정. 온도(temperature)가 높을수록 다양하고 낮을수록 결정적입니다. [자기일관성](02_agent_core.md#self-consistency) 같은 기법은 샘플링의 다양성을 활용합니다.

> **예시**: 온도 0이면 같은 질문에 거의 같은 답, 온도 1이면 매번 다른 표현의 답이 나옵니다.

**하위 개념(더 일반·근본)**: [LLM (대규모 언어 모델)](#llm)

**상위 개념(이를 활용해 만든 개념)**: [제약 디코딩](#constrained-decoding)

**관련 용어**: [자기일관성](02_agent_core.md#self-consistency)

**이 용어를 참조하는 항목**: [자기일관성](02_agent_core.md#self-consistency)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="reasoning-model"></a>

### 추론 모델 / 사고 과정

**영문**: Reasoning Model / Chain-of-Thought · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2024-09

답하기 전에 내부적으로 긴 사고 과정(chain-of-thought)을 생성하는 모델·기법. "단계별로 생각하기"가 정답률을 올린다는 2022년 CoT 연구에서 출발했으며, [ReAct](02_agent_core.md#react)의 이론적 토대 중 하나입니다.

**하위 개념(더 일반·근본)**: [LLM (대규모 언어 모델)](#llm)

**관련 용어**: [ReAct 패턴](02_agent_core.md#react)

**이 용어를 참조하는 항목**: [ReAct 패턴](02_agent_core.md#react)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="hallucination"></a>

### 환각

**영문**: Hallucination · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2020

모델이 사실이 아닌 내용을 그럴듯하게 생성하는 현상. [도구 호출](02_agent_core.md#tool-calling)로 실제 데이터를 조회([그라운딩](#grounding))하면 완화할 수 있습니다.

> **예시**: 존재하지 않는 논문 제목과 저자를 그럴듯하게 지어내는 것이 전형적인 환각입니다.

**하위 개념(더 일반·근본)**: [LLM (대규모 언어 모델)](#llm)

**관련 용어**: [그라운딩](#grounding) · [도구 호출 (함수 호출)](02_agent_core.md#tool-calling)

**이 용어를 참조하는 항목**: [그라운딩](#grounding)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="grounding"></a>

### 그라운딩

**영문**: Grounding · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2020

모델의 출력을 실제 세계의 근거(도구 결과, 검색 결과, 파일 내용)에 붙들어 매는 것. [ReAct](02_agent_core.md#react)에서 관찰(Observation)이 생각을 그라운딩하는 역할을 합니다.

**하위 개념(더 일반·근본)**: [LLM (대규모 언어 모델)](#llm)

**관련 용어**: [환각](#hallucination) · [검색 증강 (RAG)](06_state_retrieval.md#retrieval) · [ReAct 패턴](02_agent_core.md#react)

**이 용어를 참조하는 항목**: [환각](#hallucination) · [ReAct 패턴](02_agent_core.md#react) · [웹 검색 도구](03_tool_system.md#web-search-tool)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="auxiliary-model"></a>

### 보조 모델

**영문**: Auxiliary Model · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2023

본 대화가 아닌 잡무(요약, 제목 생성, 백그라운드 정비)에 쓰는 값싸고 빠른 모델. Hermes에서는 [컨텍스트 압축](04_prompt_context.md#context-compression)의 요약과 [큐레이터](05_memory_self_improvement.md#curator) 실행에 사용됩니다.

> **예시**: 메인 대화는 고성능 모델이 하고, 대화 요약은 10배 싼 소형 모델이 처리하는 식의 역할 분담입니다.

**하위 개념(더 일반·근본)**: [LLM (대규모 언어 모델)](#llm)

**관련 용어**: [컨텍스트 압축](04_prompt_context.md#context-compression) · [큐레이터](05_memory_self_improvement.md#curator)

**이 용어를 참조하는 항목**: [컨텍스트 압축](04_prompt_context.md#context-compression) · [큐레이터](05_memory_self_improvement.md#curator) · [지식 증류](13_model_learning.md#distillation) · [비전 도구](03_tool_system.md#vision-tools)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="embedding"></a>

### 임베딩

**영문**: Embedding · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2013-01

텍스트를 의미를 담은 숫자 벡터로 변환한 것. [벡터 검색](06_state_retrieval.md#vector-search)의 기반이며, 비슷한 의미의 텍스트는 가까운 벡터가 됩니다.

> **예시**: "강아지"와 "반려견"은 글자는 다르지만 임베딩 벡터는 매우 가깝습니다.

**상위 개념(이를 활용해 만든 개념)**: [벡터 검색](06_state_retrieval.md#vector-search)

**관련 용어**: [벡터 검색](06_state_retrieval.md#vector-search) · [LLM (대규모 언어 모델)](#llm)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="inference"></a>

### 추론 (서빙)

**영문**: Inference / Serving · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2012

학습이 끝난 모델로 실제 출력을 생성하는 단계, 그리고 이를 API로 제공하는 것(서빙). 학습과 달리 매 요청마다 일어나므로 [지연](#latency)·비용 최적화가 핵심 과제입니다.

> **예시**: OpenAI API 호출 한 번 = 추론 한 번입니다. vLLM 같은 서빙 엔진은 여러 요청을 묶어(batching) 처리량을 높입니다.

**하위 개념(더 일반·근본)**: [LLM (대규모 언어 모델)](#llm)

**상위 개념(이를 활용해 만든 개념)**: [지연 시간](#latency) · [양자화](13_model_learning.md#quantization) · [레이트리밋](#rate-limit) · [응답 스트리밍](#streaming)

**관련 용어**: [지연 시간](#latency) · [응답 스트리밍](#streaming) · [양자화](13_model_learning.md#quantization)

**이 용어를 참조하는 항목**: [오픈 웨이트 모델](13_model_learning.md#open-weights)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="latency"></a>

### 지연 시간

**영문**: Latency · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 컴퓨팅 일반(1960년대)

요청을 보내고 응답을 받기까지 걸리는 시간. 첫 토큰까지의 시간(TTFT)과 토큰당 생성 시간으로 나뉘며, [프롬프트 캐싱](#prompt-caching)은 TTFT를, [스트리밍](#streaming)은 체감 지연을 줄입니다.

> **예시**: 에이전트는 한 턴에 모델을 수십 번 호출하므로, 호출당 1초의 지연도 턴 전체로는 수십 초가 됩니다.

**하위 개념(더 일반·근본)**: [추론 (서빙)](#inference)

**관련 용어**: [응답 스트리밍](#streaming) · [프롬프트 캐싱](#prompt-caching)

**이 용어를 참조하는 항목**: [추론 (서빙)](#inference) · [응답 스트리밍](#streaming)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="streaming"></a>

### 응답 스트리밍

**영문**: Streaming · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2020-06

응답을 다 만들 때까지 기다리지 않고 생성되는 [토큰](#token)부터 차례로 흘려보내는 방식. 체감 [지연](#latency)을 크게 줄이며, 전송에는 [SSE](08_protocols.md#sse) 같은 스트리밍 프로토콜이 쓰입니다.

> **예시**: ChatGPT에서 글자가 타자 치듯 나타나는 것이 스트리밍입니다. Hermes CLI의 실시간 출력도 stream_callback으로 구현됩니다.

**하위 개념(더 일반·근본)**: [추론 (서빙)](#inference)

**관련 용어**: [지연 시간](#latency) · [SSE (서버 전송 이벤트)](08_protocols.md#sse)

**이 용어를 참조하는 항목**: [추론 (서빙)](#inference) · [지연 시간](#latency) · [SSE (서버 전송 이벤트)](08_protocols.md#sse)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="rate-limit"></a>

### 레이트리밋

**영문**: Rate Limit · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2000년대(웹 API)

[제공자](02_agent_core.md#provider)가 분당 요청 수·토큰 수에 두는 상한. 초과하면 429 오류가 반환됩니다. Hermes는 [백오프](#backoff) 재시도와 [크리덴셜 풀](02_agent_core.md#credential-pool) 회전으로 대응합니다.

> **예시**: 분당 100만 토큰 한도인 계정으로 대형 배치를 돌리면 429가 발생하고, 잠시 기다렸다 다시 시도해야 합니다.

**하위 개념(더 일반·근본)**: [추론 (서빙)](#inference)

**상위 개념(이를 활용해 만든 개념)**: [지수 백오프](#backoff)

**관련 용어**: [지수 백오프](#backoff) · [크리덴셜 풀](02_agent_core.md#credential-pool) · [재시도와 폴백](02_agent_core.md#retry-fallback)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="backoff"></a>

### 지수 백오프

**영문**: Exponential Backoff · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 1970년대(네트워크)

실패할 때마다 대기 시간을 2배씩 늘려가며(1초→2초→4초...) 재시도하는 표준 기법. 장애 중인 서버를 더 두드려 악화시키는 것을 막습니다.

> **예시**: 429 응답을 받으면 1초 후 재시도, 또 실패하면 2초, 4초... 식으로 물러나는 것이 지수 백오프입니다.

**하위 개념(더 일반·근본)**: [레이트리밋](#rate-limit)

**관련 용어**: [재시도와 폴백](02_agent_core.md#retry-fallback)

**이 용어를 참조하는 항목**: [레이트리밋](#rate-limit)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="structured-output"></a>

### 구조화 출력

**영문**: Structured Output · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2023-06

모델 출력이 지정된 [JSON Schema](03_tool_system.md#json-schema)를 반드시 따르게 강제하는 기능. [도구 호출](02_agent_core.md#tool-calling)의 인자 생성도 본질적으로 구조화 출력입니다.

> **예시**: "{\"name\": string, \"age\": number} 형식으로만 답하라"를 스키마 수준에서 강제하면 파싱 실패가 사라집니다.

**하위 개념(더 일반·근본)**: [LLM (대규모 언어 모델)](#llm) · [JSON Schema](03_tool_system.md#json-schema)

**상위 개념(이를 활용해 만든 개념)**: [제약 디코딩](#constrained-decoding)

**관련 용어**: [도구 호출 (함수 호출)](02_agent_core.md#tool-calling) · [제약 디코딩](#constrained-decoding)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="constrained-decoding"></a>

### 제약 디코딩

**영문**: Constrained Decoding · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2021

[샘플링](#sampling) 단계에서 문법(스키마)에 어긋나는 토큰의 확률을 0으로 만들어, 출력이 형식을 벗어날 수 없게 하는 구현 기법. [구조화 출력](#structured-output)을 '검증'이 아니라 '생성 자체'에서 보장합니다.

> **예시**: JSON을 생성하는 중 여는 따옴표 다음에는 문자열 토큰만 허용하는 식으로, 매 토큰마다 허용 집합을 계산합니다.

**하위 개념(더 일반·근본)**: [구조화 출력](#structured-output) · [샘플링 / 온도](#sampling)

**이 용어를 참조하는 항목**: [구조화 출력](#structured-output)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="context-caching-provider"></a>

### 제공자별 캐시 구현

**영문**: Provider Cache Implementations · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2024-05

[프롬프트 캐싱](#prompt-caching)의 제공자별 구현 차이. OpenAI는 자동 prefix 캐시, Anthropic은 cache_control 마커로 명시적 지정, Gemini는 별도 캐시 객체를 만듭니다. Hermes의 제공자 어댑터가 이 차이를 흡수합니다.

> **예시**: Anthropic에서는 시스템 프롬프트 끝에 cache_control 마커를 붙여야 캐시가 적용되고, 캐시 읽기는 입력 요금의 10%로 과금됩니다.

**하위 개념(더 일반·근본)**: [프롬프트 캐싱](#prompt-caching)

**관련 용어**: [LLM 제공자](02_agent_core.md#provider)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="multimodal"></a>

### 멀티모달

**영문**: Multimodal · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2021-01

텍스트 외에 이미지·음성 등 여러 형태(모달리티)의 입력·출력을 다루는 모델·시스템. Hermes에서는 [비전](#vision-model), [STT](#stt), [TTS](#tts)가 각 모달리티를 담당합니다.

> **예시**: 스크린샷을 주고 "이 화면에서 로그인 버튼이 어디 있어?"라고 묻는 것이 멀티모달 사용입니다.

**하위 개념(더 일반·근본)**: [LLM (대규모 언어 모델)](#llm)

**상위 개념(이를 활용해 만든 개념)**: [음성 인식 (STT)](#stt) · [음성 합성 (TTS)](#tts) · [비전 모델 (VLM)](#vision-model)

**관련 용어**: [비전 모델 (VLM)](#vision-model) · [음성 인식 (STT)](#stt) · [음성 합성 (TTS)](#tts)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="vision-model"></a>

### 비전 모델 (VLM)

**영문**: Vision-Language Model · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 2021-01

이미지를 이해하고 텍스트로 설명·추론하는 모델. [비전 도구](03_tool_system.md#vision-tools)와 [컴퓨터 사용](03_tool_system.md#computer-use)(스크린샷 이해)의 기반입니다.

> **예시**: GPT-4o, Claude의 이미지 입력이 VLM 기능입니다. Hermes 비전 도구는 요청을 이런 전문 모델로 라우팅합니다.

**하위 개념(더 일반·근본)**: [멀티모달](#multimodal)

**상위 개념(이를 활용해 만든 개념)**: [비전 도구](03_tool_system.md#vision-tools)

**관련 용어**: [비전 도구](03_tool_system.md#vision-tools) · [컴퓨터 사용](03_tool_system.md#computer-use)

**이 용어를 참조하는 항목**: [멀티모달](#multimodal)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="stt"></a>

### 음성 인식 (STT)

**영문**: Speech-to-Text · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 1952(오디리)

음성을 텍스트로 변환하는 기술. [음성 모드](03_tool_system.md#voice-mode)의 입력 절반을 담당합니다.

> **예시**: Whisper가 대표적인 오픈소스 STT 모델입니다.

**하위 개념(더 일반·근본)**: [멀티모달](#multimodal)

**상위 개념(이를 활용해 만든 개념)**: [음성 모드](03_tool_system.md#voice-mode)

**관련 용어**: [음성 모드](03_tool_system.md#voice-mode) · [음성 합성 (TTS)](#tts)

**이 용어를 참조하는 항목**: [멀티모달](#multimodal) · [음성 합성 (TTS)](#tts)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="tts"></a>

### 음성 합성 (TTS)

**영문**: Text-to-Speech · **분류**: [LLM 기초](README.md#분류content-class) · **최초 등장**: 1968

텍스트를 음성으로 변환하는 기술. [음성 모드](03_tool_system.md#voice-mode)의 출력 절반을 담당합니다.

> **예시**: 에이전트의 답변을 자연스러운 목소리로 읽어 주는 것이 TTS입니다.

**하위 개념(더 일반·근본)**: [멀티모달](#multimodal)

**상위 개념(이를 활용해 만든 개념)**: [음성 모드](03_tool_system.md#voice-mode)

**관련 용어**: [음성 모드](03_tool_system.md#voice-mode) · [음성 인식 (STT)](#stt)

**이 용어를 참조하는 항목**: [멀티모달](#multimodal) · [음성 인식 (STT)](#stt)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---
