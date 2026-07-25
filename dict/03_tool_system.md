# 용어 사전 — 도구 시스템

[⬆ 사전 전체 목차로](README.md)

이 문서는 **도구 시스템** 범주의 용어 24개를 다룹니다. 설명 속 파란 링크를 누르면 해당 용어 항목으로 이동하며, 각 항목 끝의 "이 용어를 참조하는 항목"으로 되돌아올 수 있습니다.

## 이 문서의 용어

- [도구](#tool)
- [도구 스키마](#tool-schema)
- [JSON Schema](#json-schema)
- [도구 레지스트리](#tool-registry)
- [자기 등록](#self-registration)
- [AST 기반 도구 발견](#ast-discovery)
- [디스패치](#dispatch)
- [핸들러](#handler)
- [결과 정규화](#result-normalization)
- [에러 봉투](#error-envelope)
- [가용성 검사 (check_fn)](#check-fn)
- [툴셋](#toolset)
- [코어 도구](#core-tools)
- [터미널 도구](#terminal-tool)
- [파일 도구](#file-tools)
- [브라우저 도구](#browser-tool)
- [browser_cdp (CDP 탈출구)](#browser-cdp-tool)
- [비전 도구](#vision-tools)
- [웹 검색 도구](#web-search-tool)
- [delegate 도구](#delegate-tool)
- [스킬 도구 (skill_view)](#skill-tool)
- [컴퓨터 사용](#computer-use)
- [음성 모드](#voice-mode)
- [도구 결과 크기 상한](#max-result-size)

<a id="tool"></a>

### 도구

**영문**: Tool · **범주**: 도구 시스템

에이전트가 호출할 수 있는 기능 하나(터미널, 파일 읽기, 웹 검색 등). [스키마](#tool-schema)(모델에게 보이는 명세)와 [핸들러](#handler)(실제 실행 코드)의 쌍으로 구성됩니다.

**상위 개념**: [도구 호출 (함수 호출)](02_agent_core.md#tool-calling)

**하위 개념**: [브라우저 도구](#browser-tool) · [컴퓨터 사용](#computer-use) · [delegate 도구](#delegate-tool) · [핸들러](#handler) · [스킬 도구 (skill_view)](#skill-tool) · [도구 레지스트리](#tool-registry) · [도구 스키마](#tool-schema) · [툴셋](#toolset) · [비전 도구](#vision-tools) · [음성 모드](#voice-mode)

**관련 용어**: [도구 스키마](#tool-schema) · [핸들러](#handler) · [툴셋](#toolset)

**이 용어를 참조하는 항목**: [MCP 프리미티브](08_protocols.md#mcp-primitives)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="tool-schema"></a>

### 도구 스키마

**영문**: Tool Schema · **범주**: 도구 시스템

도구의 이름·설명·매개변수([JSON Schema](#json-schema))를 담은 명세. 모든 도구의 스키마가 매 API 호출에 전송되므로, 스키마 크기가 곧 상시 비용입니다 — [좁은 허리](11_design_principles.md#narrow-waist) 원칙의 근거.

**상위 개념**: [도구](#tool)

**하위 개념**: [JSON Schema](#json-schema)

**관련 용어**: [JSON Schema](#json-schema) · [좁은 허리 원칙](11_design_principles.md#narrow-waist)

**이 용어를 참조하는 항목**: [좁은 허리 원칙](11_design_principles.md#narrow-waist) · [도구](#tool) · [도구 호출 (함수 호출)](02_agent_core.md#tool-calling)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="json-schema"></a>

### JSON Schema

**영문**: JSON Schema · **범주**: 도구 시스템

JSON 데이터의 구조(타입, 필수 필드, 열거값)를 선언하는 표준. 도구 매개변수 명세에 사용되며, 모델은 이 스키마에 맞는 인자를 생성합니다.

**상위 개념**: [도구 스키마](#tool-schema)

**이 용어를 참조하는 항목**: [도구 스키마](#tool-schema)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="tool-registry"></a>

### 도구 레지스트리

**영문**: Tool Registry · **범주**: 도구 시스템

모든 도구의 등록부(`tools/registry.py`). 도구 이름 → [핸들러](#handler)/스키마/[가용성 검사](#check-fn) 매핑을 보관하며, [디스패치](#dispatch)의 진입점입니다.

**상위 개념**: [도구](#tool)

**하위 개념**: [가용성 검사 (check_fn)](#check-fn) · [디스패치](#dispatch) · [자기 등록](#self-registration)

**관련 용어**: [자기 등록](#self-registration) · [디스패치](#dispatch) · [가용성 검사 (check_fn)](#check-fn)

**이 용어를 참조하는 항목**: [MCP 서버](08_protocols.md#mcp-server)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="self-registration"></a>

### 자기 등록

**영문**: Self-Registration · **범주**: 도구 시스템

각 도구 파일이 import될 때 스스로 `registry.register(...)`를 호출해 등록되는 패턴. 코어를 수정하지 않고 도구를 추가할 수 있게 합니다.

**상위 개념**: [도구 레지스트리](#tool-registry)

**하위 개념**: [AST 기반 도구 발견](#ast-discovery)

**관련 용어**: [AST 기반 도구 발견](#ast-discovery)

**이 용어를 참조하는 항목**: [도구 레지스트리](#tool-registry)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="ast-discovery"></a>

### AST 기반 도구 발견

**영문**: AST-based Discovery · **범주**: 도구 시스템

`discover_builtin_tools`가 `tools/*.py`를 실제 import하기 전에 AST(추상 구문 트리)로 검사해, 모듈 수준에서 `registry.register`를 호출하는 파일만 import하는 최적화. 불필요한 import 비용과 부작용을 피합니다.

**상위 개념**: [자기 등록](#self-registration)

**이 용어를 참조하는 항목**: [자기 등록](#self-registration)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="dispatch"></a>

### 디스패치

**영문**: Dispatch · **범주**: 도구 시스템

모델이 낸 도구 호출(이름+인자)을 받아 [레지스트리](#tool-registry)에서 [핸들러](#handler)를 찾아 실행하고, 결과를 [정규화](#result-normalization)해 돌려주는 과정. 예외가 나도 [에러 봉투](#error-envelope)로 감싸 루프가 죽지 않게 합니다.

**상위 개념**: [도구 레지스트리](#tool-registry)

**하위 개념**: [에러 봉투](#error-envelope) · [결과 정규화](#result-normalization)

**관련 용어**: [핸들러](#handler) · [에러 봉투](#error-envelope) · [결과 정규화](#result-normalization)

**이 용어를 참조하는 항목**: [핸들러](#handler) · [run_conversation 루프](02_agent_core.md#run-conversation) · [도구 호출 (함수 호출)](02_agent_core.md#tool-calling) · [도구 레지스트리](#tool-registry)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="handler"></a>

### 핸들러

**영문**: Handler · **범주**: 도구 시스템

도구의 실제 실행 코드(파이썬 함수). 동기/비동기 모두 지원되며, [디스패치](#dispatch)가 호출합니다.

**상위 개념**: [도구](#tool)

**관련 용어**: [디스패치](#dispatch)

**이 용어를 참조하는 항목**: [디스패치](#dispatch) · [도구](#tool) · [도구 레지스트리](#tool-registry)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="result-normalization"></a>

### 결과 정규화

**영문**: Result Normalization · **범주**: 도구 시스템

핸들러가 돌려준 다양한 형태(문자열, dict, 예외)의 결과를 모델에 반환 가능한 일관된 형식으로 변환하는 단계. 결과 크기 상한도 여기서 적용됩니다.

**상위 개념**: [디스패치](#dispatch)

**하위 개념**: [도구 결과 크기 상한](#max-result-size)

**관련 용어**: [에러 봉투](#error-envelope)

**이 용어를 참조하는 항목**: [디스패치](#dispatch) · [에러 봉투](#error-envelope)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="error-envelope"></a>

### 에러 봉투

**영문**: Error Envelope · **범주**: 도구 시스템

도구 실행 실패를 `{"error": "..."}` JSON으로 감싸 모델에 돌려주는 패턴. 루프를 죽이는 대신 모델이 오류를 읽고 스스로 대처(재시도, 다른 방법)하게 만듭니다.

**상위 개념**: [디스패치](#dispatch)

**관련 용어**: [결과 정규화](#result-normalization)

**이 용어를 참조하는 항목**: [디스패치](#dispatch) · [결과 정규화](#result-normalization) · [새니타이즈](10_security.md#sanitization)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="check-fn"></a>

### 가용성 검사 (check_fn)

**영문**: check_fn (Service Gating) · **범주**: 도구 시스템

도구가 전제 조건(API 토큰, 서비스 설정)이 갖춰졌을 때만 모델에 노출되게 하는 검사 함수. 조건이 없으면 스키마가 아예 전송되지 않아 비용이 0이 됩니다 — [풋프린트 사다리](11_design_principles.md#footprint-ladder)의 3번 단계.

**상위 개념**: [도구 레지스트리](#tool-registry)

**관련 용어**: [풋프린트 사다리](11_design_principles.md#footprint-ladder) · [툴셋](#toolset)

**이 용어를 참조하는 항목**: [풋프린트 사다리](11_design_principles.md#footprint-ladder) · [도구 레지스트리](#tool-registry)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="toolset"></a>

### 툴셋

**영문**: Toolset · **범주**: 도구 시스템

도구들의 논리적 묶음(파일, 브라우저, 스킬 등). 세션·작업별로 활성화할 툴셋을 선택할 수 있습니다.

**상위 개념**: [도구](#tool)

**하위 개념**: [코어 도구](#core-tools)

**관련 용어**: [코어 도구](#core-tools)

**이 용어를 참조하는 항목**: [가용성 검사 (check_fn)](#check-fn) · [도구](#tool)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="core-tools"></a>

### 코어 도구

**영문**: Core Tools (_HERMES_CORE_TOOLS) · **범주**: 도구 시스템

terminal, 파일 읽기, 웹 검색처럼 거의 모든 사용자에게 근본적으로 필요한 최소한의 도구 집합. 새 코어 도구 추가는 [좁은 허리](11_design_principles.md#narrow-waist) 원칙상 최후의 수단입니다.

**상위 개념**: [툴셋](#toolset)

**하위 개념**: [파일 도구](#file-tools) · [터미널 도구](#terminal-tool) · [웹 검색 도구](#web-search-tool)

**관련 용어**: [좁은 허리 원칙](11_design_principles.md#narrow-waist)

**이 용어를 참조하는 항목**: [좁은 허리 원칙](11_design_principles.md#narrow-waist) · [툴셋](#toolset)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="terminal-tool"></a>

### 터미널 도구

**영문**: Terminal Tool · **범주**: 도구 시스템

에이전트가 셸 명령을 실행하는 도구. 실제 실행은 [실행 환경](09_execution_infra.md#execution-environment) 백엔드에 위임되며, 위험 명령은 [명령 승인](10_security.md#command-approval) 계층을 거칩니다.

**상위 개념**: [코어 도구](#core-tools)

**하위 개념**: [명령 승인](10_security.md#command-approval)

**관련 용어**: [실행 환경](09_execution_infra.md#execution-environment) · [명령 승인](10_security.md#command-approval)

**이 용어를 참조하는 항목**: [실행 환경](09_execution_infra.md#execution-environment) · [파일 도구](#file-tools)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="file-tools"></a>

### 파일 도구

**영문**: File Tools · **범주**: 도구 시스템

파일 읽기/쓰기/편집 도구군. 에이전트가 코드베이스를 읽고 수정하는 기본 수단입니다.

**상위 개념**: [코어 도구](#core-tools)

**관련 용어**: [터미널 도구](#terminal-tool)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="browser-tool"></a>

### 브라우저 도구

**영문**: Browser Tool · **범주**: 도구 시스템

에이전트가 웹 브라우저를 조작하는 고수준 도구. 로컬 크로미움과 [클라우드 브라우저](08_protocols.md#cloud-browser)를 동일 인터페이스로 노출하고, [접근성 트리](08_protocols.md#accessibility-tree) 스냅샷과 ref 선택자로 조작합니다.

**상위 개념**: [도구](#tool)

**하위 개념**: [접근성 트리](08_protocols.md#accessibility-tree) · [browser_cdp (CDP 탈출구)](#browser-cdp-tool) · [클라우드 브라우저](08_protocols.md#cloud-browser)

**관련 용어**: [CDP (크롬 개발자도구 프로토콜)](08_protocols.md#cdp) · [접근성 트리](08_protocols.md#accessibility-tree) · [클라우드 브라우저](08_protocols.md#cloud-browser)

**이 용어를 참조하는 항목**: [CDP (크롬 개발자도구 프로토콜)](08_protocols.md#cdp) · [컴퓨터 사용](#computer-use)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="browser-cdp-tool"></a>

### browser_cdp (CDP 탈출구)

**영문**: browser_cdp Tool · **범주**: 도구 시스템

임의의 [CDP](08_protocols.md#cdp) 명령을 브라우저에 직접 보내는 저수준 도구. 고수준 도구가 못 다루는 경우(네이티브 다이얼로그, iframe 평가)를 위한 [탈출구](11_design_principles.md#escape-hatch)이며, 허용 메서드 화이트리스트로 통제됩니다.

**상위 개념**: [브라우저 도구](#browser-tool)

**관련 용어**: [CDP (크롬 개발자도구 프로토콜)](08_protocols.md#cdp) · [탈출구 패턴](11_design_principles.md#escape-hatch)

**이 용어를 참조하는 항목**: [탈출구 패턴](11_design_principles.md#escape-hatch)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="vision-tools"></a>

### 비전 도구

**영문**: Vision Tools · **범주**: 도구 시스템

이미지를 분석하는 도구군. 비전 요청을 메인 대화 모델과 독립적으로 전문 모델에 라우팅합니다.

**상위 개념**: [도구](#tool)

**관련 용어**: [보조 모델](01_llm_basics.md#auxiliary-model)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="web-search-tool"></a>

### 웹 검색 도구

**영문**: Web Search Tool · **범주**: 도구 시스템

에이전트가 웹을 검색해 최신 정보를 얻는 도구. 학습 데이터에 없는 사실의 [그라운딩](01_llm_basics.md#grounding) 수단입니다.

**상위 개념**: [코어 도구](#core-tools)

**관련 용어**: [그라운딩](01_llm_basics.md#grounding)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="delegate-tool"></a>

### delegate 도구

**영문**: Delegate Tool · **범주**: 도구 시스템

[서브에이전트](02_agent_core.md#subagent)를 띄워 작업을 맡기는 도구. [위임](02_agent_core.md#delegation) 패턴의 구현입니다.

**상위 개념**: [도구](#tool)

**관련 용어**: [서브에이전트 / 위임](02_agent_core.md#subagent) · [델리게이션 (작업 위임)](02_agent_core.md#delegation)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="skill-tool"></a>

### 스킬 도구 (skill_view)

**영문**: Skill Tools · **범주**: 도구 시스템

스킬 본문을 필요할 때 로드하는 도구. [점진적 공개](05_memory_self_improvement.md#progressive-disclosure)의 2단계(본문 로드)를 담당합니다.

**상위 개념**: [도구](#tool)

**관련 용어**: [스킬](05_memory_self_improvement.md#skill) · [점진적 공개](05_memory_self_improvement.md#progressive-disclosure)

**이 용어를 참조하는 항목**: [점진적 공개](05_memory_self_improvement.md#progressive-disclosure)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="computer-use"></a>

### 컴퓨터 사용

**영문**: Computer Use · **범주**: 도구 시스템

화면 스크린샷을 보고 마우스/키보드를 조작하는 GUI 자동화 도구군. 브라우저를 넘어 데스크톱 전체를 다룹니다.

**상위 개념**: [도구](#tool)

**관련 용어**: [브라우저 도구](#browser-tool)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="voice-mode"></a>

### 음성 모드

**영문**: Voice Mode · **범주**: 도구 시스템

음성 입출력(STT/TTS)으로 에이전트와 대화하는 모드.

**상위 개념**: [도구](#tool)

**관련 용어**: [게이트웨이](07_gateway_interfaces.md#gateway)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="max-result-size"></a>

### 도구 결과 크기 상한

**영문**: Max Result Size · **범주**: 도구 시스템

도구 결과가 [컨텍스트](01_llm_basics.md#context-window)를 폭식하지 않도록 문자 수 상한을 두고 초과분을 자르는 장치. 도구별로 상한을 다르게 설정할 수 있습니다.

**상위 개념**: [결과 정규화](#result-normalization)

**관련 용어**: [컨텍스트 윈도우](01_llm_basics.md#context-window)

**이 용어를 참조하는 항목**: [도구 출력 가지치기](04_prompt_context.md#tool-output-pruning)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---
