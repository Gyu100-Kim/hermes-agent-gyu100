# 용어 사전 — 보안

[⬆ 사전 전체 목차로](README.md)

이 문서는 **보안** 범주의 용어 8개를 다룹니다. 설명 속 파란 링크를 누르면 해당 용어 항목으로 이동하며, 각 항목 끝의 "이 용어를 참조하는 항목"으로 되돌아올 수 있습니다.

## 이 문서의 용어

- [명령 승인](#command-approval)
- [YOLO 모드](#yolo-mode)
- [하드라인 차단 목록](#hardline-blocklist)
- [비신뢰 콘텐츠 원칙](#untrusted-content)
- [프롬프트 인젝션](#prompt-injection)
- [도구 중독](#tool-poisoning)
- [비밀정보 분리 (.env)](#secrets-env)
- [새니타이즈](#sanitization)

<a id="command-approval"></a>

### 명령 승인

**영문**: Command Approval · **범주**: 보안

위험한 셸 명령 실행 전 사용자 확인을 받는 계층. [YOLO 모드](#yolo-mode)로 완화할 수 있지만 [하드라인 차단 목록](#hardline-blocklist)은 우회 불가입니다.

**상위 개념**: [터미널 도구](03_tool_system.md#terminal-tool)

**하위 개념**: [하드라인 차단 목록](#hardline-blocklist) · [YOLO 모드](#yolo-mode)

**관련 용어**: [YOLO 모드](#yolo-mode) · [하드라인 차단 목록](#hardline-blocklist)

**이 용어를 참조하는 항목**: [터미널 도구](03_tool_system.md#terminal-tool)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="yolo-mode"></a>

### YOLO 모드

**영문**: YOLO Mode · **범주**: 보안

위험 명령의 수동 승인 절차를 생략하는 설정. 편의와 위험을 맞바꾸는 옵션이며, 그래도 [하드라인 차단](#hardline-blocklist)은 계속 적용됩니다.

**상위 개념**: [명령 승인](#command-approval)

**이 용어를 참조하는 항목**: [명령 승인](#command-approval)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="hardline-blocklist"></a>

### 하드라인 차단 목록

**영문**: Hardline Blocklist · **범주**: 보안

`rm -rf /` 같은 파국적 명령을 어떤 설정으로도 우회할 수 없게 막는 최후의 필터.

**상위 개념**: [명령 승인](#command-approval)

**이 용어를 참조하는 항목**: [명령 승인](#command-approval) · [YOLO 모드](#yolo-mode)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="untrusted-content"></a>

### 비신뢰 콘텐츠 원칙

**영문**: Untrusted Content · **범주**: 보안

외부 파일, [메모리 제공자](05_memory_self_improvement.md#memory-provider) 응답, [MCP 서버](08_protocols.md#mcp-server) 출력, 도구 결과를 모두 '신뢰할 수 없는 데이터'로 취급하는 Hermes 보안 원칙. 지시가 아니라 데이터로 다룹니다.

**하위 개념**: [프롬프트 인젝션](#prompt-injection) · [새니타이즈](#sanitization)

**관련 용어**: [프롬프트 인젝션](#prompt-injection) · [MCP 서버](08_protocols.md#mcp-server) · [메모리 제공자](05_memory_self_improvement.md#memory-provider)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="prompt-injection"></a>

### 프롬프트 인젝션

**영문**: Prompt Injection · **범주**: 보안

외부 콘텐츠(웹페이지, 파일, 도구 결과) 안에 심어진 지시문이 에이전트를 조종하려는 공격. 에이전트 시대의 대표적 보안 위협입니다.

**상위 개념**: [비신뢰 콘텐츠 원칙](#untrusted-content)

**하위 개념**: [도구 중독](#tool-poisoning)

**관련 용어**: [도구 중독](#tool-poisoning)

**이 용어를 참조하는 항목**: [비신뢰 콘텐츠 원칙](#untrusted-content)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="tool-poisoning"></a>

### 도구 중독

**영문**: Tool Poisoning · **범주**: 보안

악성 [MCP 서버](08_protocols.md#mcp-server)가 도구 설명(스키마)에 숨은 지시를 심어 에이전트를 조종하는 [프롬프트 인젝션](#prompt-injection)의 변종.

**상위 개념**: [프롬프트 인젝션](#prompt-injection)

**관련 용어**: [MCP 서버](08_protocols.md#mcp-server)

**이 용어를 참조하는 항목**: [프롬프트 인젝션](#prompt-injection)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="secrets-env"></a>

### 비밀정보 분리 (.env)

**영문**: Secrets in .env · **범주**: 보안

API 키·토큰 같은 비밀은 .env에만, 일반 동작 설정은 [config.yaml](11_design_principles.md#config-yaml)에 두는 Hermes 규칙. 비밀이 설정 파일·로그에 섞여 유출되는 것을 막습니다.

**관련 용어**: [config.yaml](11_design_principles.md#config-yaml)

**이 용어를 참조하는 항목**: [config.yaml](11_design_principles.md#config-yaml)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="sanitization"></a>

### 새니타이즈

**영문**: Sanitization · **범주**: 보안

외부에서 온 텍스트에서 위험 요소(제어 문자, 비밀정보, 주입 시도)를 제거·중화하는 처리. 오류 메시지와 메모리 컨텍스트에 적용됩니다.

**상위 개념**: [비신뢰 콘텐츠 원칙](#untrusted-content)

**관련 용어**: [에러 봉투](03_tool_system.md#error-envelope)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---
