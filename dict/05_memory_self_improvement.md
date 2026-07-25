# 용어 사전 — 메모리·자기개선

[⬆ 사전 전체 목차로](README.md)

이 문서는 **메모리·자기개선** 범주의 용어 22개를 다룹니다. 설명 속 파란 링크를 누르면 해당 용어 항목으로 이동하며, 각 항목 끝의 "이 용어를 참조하는 항목"으로 되돌아올 수 있습니다.

## 이 문서의 용어

- [자기개선 에이전트](#self-improving-agent)
- [메모리 (에이전트 기억)](#memory)
- [절차 기억](#procedural-memory)
- [의미 기억](#semantic-memory)
- [일화 기억](#episodic-memory)
- [스킬](#skill)
- [SKILL.md](#skill-md)
- [프런트매터](#frontmatter)
- [점진적 공개](#progressive-disclosure)
- [큐레이터](#curator)
- [보관 (비파괴 정리)](#archive)
- [스킬 고정](#pinning)
- [스킬 허브](#skills-hub)
- [자기 성찰](#self-reflection)
- [학습 프롬프트](#learn-prompt)
- [메모리 제공자](#memory-provider)
- [메모리 매니저](#memory-manager)
- [메모리 도구](#memory-tool)
- [Honcho](#honcho)
- [변증법적 API](#dialectic-api)
- [마음 이론](#theory-of-mind)
- [사용자 모델링](#user-modeling)

<a id="self-improving-agent"></a>

### 자기개선 에이전트

**영문**: Self-Improving Agent · **범주**: 메모리·자기개선

실행 경험으로부터 배워 다음 실행이 더 나아지는 에이전트. 가중치 재학습 대신 외부 메모리([스킬](#skill), [메모리](#memory))에 지식을 축적하는 방식이 실용적 주류입니다(Voyager, Reflexion 계열).

**상위 개념**: [에이전트](02_agent_core.md#agent)

**하위 개념**: [큐레이터](#curator) · [메모리 (에이전트 기억)](#memory) · [자기 성찰](#self-reflection)

**관련 용어**: [스킬](#skill) · [큐레이터](#curator) · [메모리 (에이전트 기억)](#memory)

**이 용어를 참조하는 항목**: [스킬](#skill)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="memory"></a>

### 메모리 (에이전트 기억)

**영문**: Agent Memory · **범주**: 메모리·자기개선

에이전트가 대화·세션을 넘어 유지하는 지식. 인지과학 분류를 빌려 [절차 기억](#procedural-memory)·[의미 기억](#semantic-memory)·[일화 기억](#episodic-memory)으로 나눠 설계합니다.

**상위 개념**: [자기개선 에이전트](#self-improving-agent)

**하위 개념**: [일화 기억](#episodic-memory) · [메모리 제공자](#memory-provider) · [절차 기억](#procedural-memory) · [의미 기억](#semantic-memory) · [사용자 모델링](#user-modeling)

**관련 용어**: [절차 기억](#procedural-memory) · [의미 기억](#semantic-memory) · [일화 기억](#episodic-memory) · [메모리 제공자](#memory-provider)

**이 용어를 참조하는 항목**: [자기개선 에이전트](#self-improving-agent)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="procedural-memory"></a>

### 절차 기억

**영문**: Procedural Memory · **범주**: 메모리·자기개선

'어떻게 하는가'에 대한 기억. Hermes에서는 [스킬](#skill)(작업 절차 문서)로 구현됩니다.

**상위 개념**: [메모리 (에이전트 기억)](#memory)

**하위 개념**: [스킬](#skill)

**관련 용어**: [스킬](#skill)

**이 용어를 참조하는 항목**: [메모리 (에이전트 기억)](#memory)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="semantic-memory"></a>

### 의미 기억

**영문**: Semantic Memory · **범주**: 메모리·자기개선

'무엇이 사실인가'에 대한 기억(사용자 선호, 프로젝트 지식). [메모리 도구](#memory-tool)와 [메모리 제공자](#memory-provider)가 담당합니다.

**상위 개념**: [메모리 (에이전트 기억)](#memory)

**하위 개념**: [메모리 도구](#memory-tool)

**관련 용어**: [메모리 도구](#memory-tool)

**이 용어를 참조하는 항목**: [메모리 (에이전트 기억)](#memory)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="episodic-memory"></a>

### 일화 기억

**영문**: Episodic Memory · **범주**: 메모리·자기개선

'무슨 일이 있었는가'에 대한 기억(과거 대화 이력). [SessionDB](06_state_retrieval.md#sessiondb)에 저장되고 [세션 검색](06_state_retrieval.md#session-search)으로 회수됩니다.

**상위 개념**: [메모리 (에이전트 기억)](#memory)

**관련 용어**: [세션 검색](06_state_retrieval.md#session-search) · [SessionDB](06_state_retrieval.md#sessiondb)

**이 용어를 참조하는 항목**: [메모리 (에이전트 기억)](#memory) · [세션 검색](06_state_retrieval.md#session-search)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="skill"></a>

### 스킬

**영문**: Skill · **범주**: 메모리·자기개선

특정 작업의 절차를 담은 재사용 가능한 지식 단위(디렉토리 + [SKILL.md](#skill-md) + 스크립트). 에이전트가 스스로 만들고 개선할 수 있어 [자기개선](#self-improving-agent)의 핵심 매체입니다.

**상위 개념**: [절차 기억](#procedural-memory)

**하위 개념**: [SKILL.md](#skill-md) · [스킬 허브](#skills-hub)

**관련 용어**: [SKILL.md](#skill-md) · [점진적 공개](#progressive-disclosure) · [큐레이터](#curator) · [스킬 허브](#skills-hub)

**이 용어를 참조하는 항목**: [큐레이터](#curator) · [학습 프롬프트](#learn-prompt) · [절차 기억](#procedural-memory) · [점진적 공개](#progressive-disclosure) · [자기개선 에이전트](#self-improving-agent) · [스킬 도구 (skill_view)](03_tool_system.md#skill-tool)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="skill-md"></a>

### SKILL.md

**영문**: SKILL.md · **범주**: 메모리·자기개선

스킬의 본문 문서. [프런트매터](#frontmatter)(이름·설명·트리거 조건)와 단계별 절차·주의사항으로 구성됩니다.

**상위 개념**: [스킬](#skill)

**하위 개념**: [프런트매터](#frontmatter)

**관련 용어**: [프런트매터](#frontmatter)

**이 용어를 참조하는 항목**: [스킬](#skill)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="frontmatter"></a>

### 프런트매터

**영문**: Frontmatter · **범주**: 메모리·자기개선

마크다운 파일 머리에 붙는 YAML 메타데이터 블록. 스킬의 이름과 설명만 이 부분에서 읽어 시스템 프롬프트에 실을 수 있게 합니다([점진적 공개](#progressive-disclosure)의 1단계).

**상위 개념**: [SKILL.md](#skill-md)

**관련 용어**: [점진적 공개](#progressive-disclosure)

**이 용어를 참조하는 항목**: [점진적 공개](#progressive-disclosure) · [SKILL.md](#skill-md)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="progressive-disclosure"></a>

### 점진적 공개

**영문**: Progressive Disclosure · **범주**: 메모리·자기개선

스킬 목록(이름+한 줄 설명)만 상시 노출하고, 본문은 필요할 때 [도구](03_tool_system.md#skill-tool)로 로드하는 계층적 로딩 전략. 스킬이 늘어나도 상시 토큰 비용이 완만하게 증가합니다.

**상위 개념**: [컨텍스트 엔지니어링](04_prompt_context.md#context-engineering)

**관련 용어**: [스킬](#skill) · [프런트매터](#frontmatter) · [스킬 도구 (skill_view)](03_tool_system.md#skill-tool)

**이 용어를 참조하는 항목**: [컨텍스트 엔지니어링](04_prompt_context.md#context-engineering) · [프런트매터](#frontmatter) · [스킬](#skill) · [스킬 도구 (skill_view)](03_tool_system.md#skill-tool)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="curator"></a>

### 큐레이터

**영문**: Curator · **범주**: 메모리·자기개선

유휴 시간에 백그라운드로 스킬 라이브러리를 정비하는 구성요소(`agent/curator.py`). 에이전트가 만든 스킬만 대상으로 하고, 삭제 대신 [보관](#archive)하며, [고정된](#pinning) 스킬은 건드리지 않습니다.

**상위 개념**: [자기개선 에이전트](#self-improving-agent)

**하위 개념**: [보관 (비파괴 정리)](#archive) · [스킬 고정](#pinning)

**관련 용어**: [스킬](#skill) · [보관 (비파괴 정리)](#archive) · [스킬 고정](#pinning) · [보조 모델](01_llm_basics.md#auxiliary-model)

**이 용어를 참조하는 항목**: [보조 모델](01_llm_basics.md#auxiliary-model) · [자기개선 에이전트](#self-improving-agent) · [스킬](#skill)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="archive"></a>

### 보관 (비파괴 정리)

**영문**: Archive (Non-Destructive) · **범주**: 메모리·자기개선

스킬을 지우는 대신 보관 폴더로 옮기는 정책. 자동화된 정리가 잘못돼도 복구할 수 있게 하는 안전장치입니다.

**상위 개념**: [큐레이터](#curator)

**이 용어를 참조하는 항목**: [큐레이터](#curator)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="pinning"></a>

### 스킬 고정

**영문**: Skill Pinning · **범주**: 메모리·자기개선

사용자가 중요 표시한 스킬을 [큐레이터](#curator)의 상태 전환(보관 등)에서 제외하는 기능.

**상위 개념**: [큐레이터](#curator)

**이 용어를 참조하는 항목**: [큐레이터](#curator)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="skills-hub"></a>

### 스킬 허브

**영문**: Skills Hub · **범주**: 메모리·자기개선

스킬을 패키징해 공유·배포하는 저장소 생태계. 번들 스킬(모두에게 유용)과 허브 스킬(특정 용도)로 나뉩니다.

**상위 개념**: [스킬](#skill)

**관련 용어**: [플러그인](12_subsystems.md#plugin)

**이 용어를 참조하는 항목**: [스킬](#skill)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="self-reflection"></a>

### 자기 성찰

**영문**: Self-Reflection · **범주**: 메모리·자기개선

에이전트가 자신의 시도·실패를 언어로 되돌아보고 교훈을 추출하는 기법(Reflexion, 2023). Hermes에서는 학습 프롬프트([learn_prompt](#learn-prompt))가 경험에서 스킬을 뽑아내는 데 사용됩니다.

**상위 개념**: [자기개선 에이전트](#self-improving-agent)

**하위 개념**: [학습 프롬프트](#learn-prompt)

**관련 용어**: [학습 프롬프트](#learn-prompt)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="learn-prompt"></a>

### 학습 프롬프트

**영문**: Learn Prompt · **범주**: 메모리·자기개선

대화 경험에서 재사용 가능한 절차를 추출해 [스킬](#skill)로 저장하도록 유도하는 프롬프트(`agent/learn_prompt.py`).

**상위 개념**: [자기 성찰](#self-reflection)

**관련 용어**: [스킬](#skill)

**이 용어를 참조하는 항목**: [자기 성찰](#self-reflection)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="memory-provider"></a>

### 메모리 제공자

**영문**: Memory Provider · **범주**: 메모리·자기개선

장기 기억 백엔드의 추상화. [Honcho](#honcho) 같은 외부 서비스를 [플러그인](12_subsystems.md#plugin)으로 끼울 수 있으며, [메모리 매니저](#memory-manager)가 수명주기를 관리합니다.

**상위 개념**: [메모리 (에이전트 기억)](#memory)

**하위 개념**: [Honcho](#honcho) · [메모리 매니저](#memory-manager)

**관련 용어**: [Honcho](#honcho) · [메모리 매니저](#memory-manager) · [플러그인](12_subsystems.md#plugin)

**이 용어를 참조하는 항목**: [메모리 (에이전트 기억)](#memory) · [플러그인](12_subsystems.md#plugin) · [의미 기억](#semantic-memory) · [비신뢰 콘텐츠 원칙](10_security.md#untrusted-content)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="memory-manager"></a>

### 메모리 매니저

**영문**: Memory Manager · **범주**: 메모리·자기개선

[메모리 제공자](#memory-provider)들을 오케스트레이션하고 메모리 스냅샷을 시스템 프롬프트 volatile 계층에 주입하는 구성요소(`agent/memory_manager.py`).

**상위 개념**: [메모리 제공자](#memory-provider)

**관련 용어**: [시스템 프롬프트 3계층](04_prompt_context.md#system-prompt-tiers)

**이 용어를 참조하는 항목**: [메모리 제공자](#memory-provider)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="memory-tool"></a>

### 메모리 도구

**영문**: Memory Tool · **범주**: 메모리·자기개선

에이전트가 명시적으로 사실을 저장/조회하는 도구. 문자 수 기반 한도로 모델 독립성을 유지합니다.

**상위 개념**: [의미 기억](#semantic-memory)

**이 용어를 참조하는 항목**: [의미 기억](#semantic-memory)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="honcho"></a>

### Honcho

**영문**: Honcho · **범주**: 메모리·자기개선

사용자 모델링에 특화된 외부 메모리 서비스. 사실 목록을 저장하는 전통적 메모리와 달리, [변증법적 API](#dialectic-api)로 질의 시점에 사용자에 대한 통찰을 합성합니다.

**상위 개념**: [메모리 제공자](#memory-provider)

**하위 개념**: [변증법적 API](#dialectic-api) · [마음 이론](#theory-of-mind)

**관련 용어**: [변증법적 API](#dialectic-api) · [마음 이론](#theory-of-mind)

**이 용어를 참조하는 항목**: [메모리 제공자](#memory-provider)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="dialectic-api"></a>

### 변증법적 API

**영문**: Dialectic API · **범주**: 메모리·자기개선

"이 사용자는 어떤 설명 방식을 선호하나?" 같은 자연어 질문을 던지면 축적된 대화 근거로부터 그 시점에 답을 합성해 주는 [Honcho](#honcho)의 질의 인터페이스.

**상위 개념**: [Honcho](#honcho)

**관련 용어**: [마음 이론](#theory-of-mind)

**이 용어를 참조하는 항목**: [Honcho](#honcho) · [사용자 모델링](#user-modeling)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="theory-of-mind"></a>

### 마음 이론

**영문**: Theory of Mind · **범주**: 메모리·자기개선

타인의 신념·욕구·의도를 추론하는 능력(심리학 용어). [Honcho](#honcho)는 이를 계산적으로 구현해 사용자의 내적 상태를 모델링하려 합니다.

**상위 개념**: [Honcho](#honcho)

**관련 용어**: [사용자 모델링](#user-modeling)

**이 용어를 참조하는 항목**: [변증법적 API](#dialectic-api) · [Honcho](#honcho) · [사용자 모델링](#user-modeling)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="user-modeling"></a>

### 사용자 모델링

**영문**: User Modeling · **범주**: 메모리·자기개선

사용자의 선호·지식 수준·목표를 표현으로 축적하는 것. 명시적(사용자가 직접 말한 것) 모델링과 암묵적(행동에서 추론) 모델링로 나뉩니다.

**상위 개념**: [메모리 (에이전트 기억)](#memory)

**관련 용어**: [마음 이론](#theory-of-mind) · [변증법적 API](#dialectic-api)

**이 용어를 참조하는 항목**: [마음 이론](#theory-of-mind)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---
