# 용어 사전 — 프롬프트·컨텍스트

[⬆ 사전 전체 목차로](README.md)

이 문서는 **프롬프트·컨텍스트** 범주의 용어 15개를 다룹니다. 설명 속 파란 링크를 누르면 해당 용어 항목으로 이동하며, 각 항목 끝의 "이 용어를 참조하는 항목"으로 되돌아올 수 있습니다.

## 이 문서의 용어

- [컨텍스트 엔지니어링](#context-engineering)
- [시스템 프롬프트 3계층](#system-prompt-tiers)
- [SOUL.md](#soul-md)
- [페르소나](#persona)
- [컨텍스트 압축](#context-compression)
- [요약 기반 압축](#summarization)
- [구조화 요약](#structured-summary)
- [머리/꼬리 보호](#head-tail-protection)
- [토큰 예산 기반 꼬리 보호](#token-budget-tail)
- [도구 출력 가지치기](#tool-output-pruning)
- [중간 소실 현상](#lost-in-the-middle)
- [압축 계보](#compression-lineage)
- [컨텍스트 엔진](#context-engine)
- [컨텍스트 파일 (AGENTS.md)](#context-file)
- [압축 쿨다운](#compression-cooldown)

<a id="context-engineering"></a>

### 컨텍스트 엔지니어링

**영문**: Context Engineering · **범주**: 프롬프트·컨텍스트

한정된 [컨텍스트 윈도우](01_llm_basics.md#context-window) 안에 '무엇을, 어떤 순서로, 얼마나' 넣을지 설계하는 기술 전반. [프롬프트 계층화](#system-prompt-tiers), [압축](#context-compression), [점진적 공개](05_memory_self_improvement.md#progressive-disclosure)가 모두 여기에 속합니다.

**하위 개념**: [컨텍스트 압축](#context-compression) · [컨텍스트 엔진](#context-engine) · [점진적 공개](05_memory_self_improvement.md#progressive-disclosure)

**관련 용어**: [시스템 프롬프트](01_llm_basics.md#system-prompt) · [컨텍스트 압축](#context-compression) · [점진적 공개](05_memory_self_improvement.md#progressive-disclosure)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="system-prompt-tiers"></a>

### 시스템 프롬프트 3계층

**영문**: System Prompt Tiers · **범주**: 프롬프트·컨텍스트

Hermes 시스템 프롬프트의 3계층 구조: stable(정체성·규칙, 가장 안정적) → context(호출자 지정 지시·컨텍스트 파일) → volatile(메모리 스냅샷, 가장 잘 변함). 안정적인 것을 앞에 두어 [캐시](01_llm_basics.md#prompt-caching) 적중률을 극대화합니다.

**상위 개념**: [시스템 프롬프트](01_llm_basics.md#system-prompt)

**하위 개념**: [컨텍스트 파일 (AGENTS.md)](#context-file) · [SOUL.md](#soul-md)

**관련 용어**: [SOUL.md](#soul-md) · [프롬프트 캐싱](01_llm_basics.md#prompt-caching)

**이 용어를 참조하는 항목**: [컨텍스트 엔지니어링](#context-engineering) · [메모리 매니저](05_memory_self_improvement.md#memory-manager) · [시스템 프롬프트](01_llm_basics.md#system-prompt)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="soul-md"></a>

### SOUL.md

**영문**: SOUL.md · **범주**: 프롬프트·컨텍스트

에이전트의 정체성과 행동 원칙을 담은 마크다운 파일. 시스템 프롬프트의 stable 계층에 포함되어 에이전트의 '영혼' 역할을 합니다.

**상위 개념**: [시스템 프롬프트 3계층](#system-prompt-tiers)

**하위 개념**: [페르소나](#persona)

**관련 용어**: [페르소나](#persona)

**이 용어를 참조하는 항목**: [컨텍스트 파일 (AGENTS.md)](#context-file) · [시스템 프롬프트](01_llm_basics.md#system-prompt) · [시스템 프롬프트 3계층](#system-prompt-tiers)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="persona"></a>

### 페르소나

**영문**: Persona · **범주**: 프롬프트·컨텍스트

에이전트가 일관되게 유지하는 성격·말투·가치관. [SOUL.md](#soul-md)로 정의되며 프로필별로 다르게 설정할 수 있습니다.

**상위 개념**: [SOUL.md](#soul-md)

**이 용어를 참조하는 항목**: [SOUL.md](#soul-md)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="context-compression"></a>

### 컨텍스트 압축

**영문**: Context Compression · **범주**: 프롬프트·컨텍스트

대화가 [컨텍스트 한도](01_llm_basics.md#context-window)에 다가가면 중간 턴들을 [보조 모델](01_llm_basics.md#auxiliary-model)로 요약해 토큰을 회수하는 메커니즘(`agent/context_compressor.py`). [프롬프트 캐싱](01_llm_basics.md#prompt-caching)을 깨는 유일하게 허용된 예외입니다.

**상위 개념**: [컨텍스트 엔지니어링](#context-engineering)

**하위 개념**: [압축 쿨다운](#compression-cooldown) · [압축 계보](#compression-lineage) · [머리/꼬리 보호](#head-tail-protection) · [요약 기반 압축](#summarization)

**관련 용어**: [요약 기반 압축](#summarization) · [머리/꼬리 보호](#head-tail-protection) · [압축 계보](#compression-lineage) · [프롬프트 캐싱](01_llm_basics.md#prompt-caching)

**이 용어를 참조하는 항목**: [보조 모델](01_llm_basics.md#auxiliary-model) · [컨텍스트 엔진](#context-engine) · [컨텍스트 엔지니어링](#context-engineering) · [컨텍스트 윈도우](01_llm_basics.md#context-window) · [프롬프트 캐싱](01_llm_basics.md#prompt-caching) · [run_conversation 루프](02_agent_core.md#run-conversation) · [세션](06_state_retrieval.md#session) · [시스템 프롬프트](01_llm_basics.md#system-prompt)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="summarization"></a>

### 요약 기반 압축

**영문**: Summarization · **범주**: 프롬프트·컨텍스트

오래된 대화 구간을 LLM으로 요약해 짧은 텍스트로 대체하는 압축 방식. 정보 손실과 토큰 회수 사이의 균형이 핵심입니다.

**상위 개념**: [컨텍스트 압축](#context-compression)

**하위 개념**: [구조화 요약](#structured-summary) · [도구 출력 가지치기](#tool-output-pruning)

**관련 용어**: [구조화 요약](#structured-summary) · [도구 출력 가지치기](#tool-output-pruning)

**이 용어를 참조하는 항목**: [컨텍스트 압축](#context-compression)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="structured-summary"></a>

### 구조화 요약

**영문**: Structured Summary · **범주**: 프롬프트·컨텍스트

자유 서술 대신 정해진 템플릿(해결된 질문/미해결 질문/핵심 결정 등)으로 요약을 생성하는 기법. 후속 대화에 필요한 정보가 누락되는 것을 줄입니다.

**상위 개념**: [요약 기반 압축](#summarization)

**이 용어를 참조하는 항목**: [요약 기반 압축](#summarization)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="head-tail-protection"></a>

### 머리/꼬리 보호

**영문**: Head/Tail Protection · **범주**: 프롬프트·컨텍스트

압축 시 대화의 머리(초기 지시·목표)와 꼬리(최근 맥락)는 원문 그대로 두고 중간만 요약하는 전략. [중간 소실](#lost-in-the-middle) 연구와도 일치하는 설계입니다.

**상위 개념**: [컨텍스트 압축](#context-compression)

**하위 개념**: [토큰 예산 기반 꼬리 보호](#token-budget-tail)

**관련 용어**: [중간 소실 현상](#lost-in-the-middle) · [토큰 예산 기반 꼬리 보호](#token-budget-tail)

**이 용어를 참조하는 항목**: [컨텍스트 압축](#context-compression) · [중간 소실 현상](#lost-in-the-middle)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="token-budget-tail"></a>

### 토큰 예산 기반 꼬리 보호

**영문**: Token-Budget Tail Protection · **범주**: 프롬프트·컨텍스트

'최근 N개 메시지'가 아니라 '꼬리에 남길 토큰 예산'으로 보호 범위를 정하는 방식. 메시지 길이 편차에 강건합니다.

**상위 개념**: [머리/꼬리 보호](#head-tail-protection)

**이 용어를 참조하는 항목**: [머리/꼬리 보호](#head-tail-protection)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="tool-output-pruning"></a>

### 도구 출력 가지치기

**영문**: Tool Output Pruning · **범주**: 프롬프트·컨텍스트

LLM 요약 전에 큰 도구 출력(웹 검색 결과 등)을 "[web_search] 5 results (2500 chars)" 같은 한 줄로 대체하는 값싼 사전 처리 단계.

**상위 개념**: [요약 기반 압축](#summarization)

**관련 용어**: [도구 결과 크기 상한](03_tool_system.md#max-result-size)

**이 용어를 참조하는 항목**: [요약 기반 압축](#summarization)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="lost-in-the-middle"></a>

### 중간 소실 현상

**영문**: Lost in the Middle · **범주**: 프롬프트·컨텍스트

긴 컨텍스트에서 모델이 처음과 끝은 잘 기억하지만 중간 정보는 잘 놓친다는 2023년 연구 결과. '중간부터 요약하라'는 [머리/꼬리 보호](#head-tail-protection) 설계의 근거입니다.

**상위 개념**: [컨텍스트 윈도우](01_llm_basics.md#context-window)

**관련 용어**: [머리/꼬리 보호](#head-tail-protection)

**이 용어를 참조하는 항목**: [컨텍스트 윈도우](01_llm_basics.md#context-window) · [머리/꼬리 보호](#head-tail-protection)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="compression-lineage"></a>

### 압축 계보

**영문**: Compression Lineage (parent_session_id) · **범주**: 프롬프트·컨텍스트

압축이 일어나면 새 [세션](06_state_retrieval.md#session) 행을 만들고 `parent_session_id`로 원본을 가리켜, 압축 전 전체 이력을 잃지 않고 추적하는 구조.

**상위 개념**: [컨텍스트 압축](#context-compression)

**관련 용어**: [세션](06_state_retrieval.md#session) · [SessionDB](06_state_retrieval.md#sessiondb)

**이 용어를 참조하는 항목**: [컨텍스트 압축](#context-compression) · [세션](06_state_retrieval.md#session)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="context-engine"></a>

### 컨텍스트 엔진

**영문**: Context Engine · **범주**: 프롬프트·컨텍스트

컨텍스트 구성 전략을 교체 가능하게 만든 추상화(`agent/context_engine.py`). 기본 압축기 대신 대안 엔진을 [플러그인](12_subsystems.md#plugin)으로 끼울 수 있습니다.

**상위 개념**: [컨텍스트 엔지니어링](#context-engineering)

**관련 용어**: [컨텍스트 압축](#context-compression) · [플러그인](12_subsystems.md#plugin)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="context-file"></a>

### 컨텍스트 파일 (AGENTS.md)

**영문**: Context Files · **범주**: 프롬프트·컨텍스트

작업 디렉토리의 AGENTS.md 등 저장소별 지침 파일. 시스템 프롬프트의 context 계층에 삽입되어 저장소 규칙을 에이전트에게 알립니다.

**상위 개념**: [시스템 프롬프트 3계층](#system-prompt-tiers)

**관련 용어**: [SOUL.md](#soul-md)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="compression-cooldown"></a>

### 압축 쿨다운

**영문**: Compression Cooldown · **범주**: 프롬프트·컨텍스트

압축 실패가 반복될 때 일정 시간 재시도를 멈추는 장치. 실패 루프로 인한 비용 낭비를 막습니다.

**상위 개념**: [컨텍스트 압축](#context-compression)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---
