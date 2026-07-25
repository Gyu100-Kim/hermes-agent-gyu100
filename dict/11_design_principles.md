# 용어 사전 — 설계 원칙·프로젝트 용어

[⬆ 사전 전체 목차로](README.md)

이 문서는 분류(Content Class) **설계 원칙·프로젝트 용어** 에 속한 용어 13개를 다룹니다.

- 설명 속 링크를 누르면 해당 용어 항목으로 이동합니다.
- **하위 개념** = 이 용어를 규정하는 데 필요한 더 **일반적·근본적인** 개념, **상위 개념** = 이 용어를 **활용해 만들어진** 더 특수한 개념입니다. (예: Attention → Transformer → LLM 순으로 상위)
- 각 항목의 **최초 등장** 연월은 상위/하위 판별의 참고 자료입니다(단, 상위 용어가 항상 늦게 생기는 것은 아닙니다).
- 각 항목 끝의 "이 용어를 참조하는 항목"으로 원래 보던 곳으로 되돌아갈 수 있습니다.

## 이 문서의 용어

- [좁은 허리 원칙](#narrow-waist)
- [풋프린트 사다리](#footprint-ladder)
- [config.yaml](#config-yaml)
- [행위 계약 테스트](#behavior-contract)
- [변경 감지 테스트 (안티패턴)](#change-detector)
- [E2E 검증](#e2e-validation)
- [탈출구 패턴](#escape-hatch)
- [컨벤셔널 커밋](#conventional-commits)
- [Nous Portal](#nous-portal)
- [관리형 도구](#managed-tools)
- [턴 격리](#turn-isolation)
- [스킨 (CLI 테마)](#skin)
- [설정 마법사](#setup-wizard)

<a id="narrow-waist"></a>

### 좁은 허리 원칙

**영문**: Narrow Waist · **분류**: [설계 원칙·프로젝트 용어](README.md#분류content-class) · **최초 등장**: 1980년대(인터넷 모래시계)·2025(Hermes)

에이전트 코어와 모델 도구 스키마를 최소한으로 유지하고, 기능 확장은 가장자리(스킬, 플러그인, MCP)에서 하라는 Hermes 핵심 설계 철학. 모든 [도구 스키마](03_tool_system.md#tool-schema)가 매 호출 전송되므로 코어 추가는 영구적 비용입니다.

> **예시**: 도구 하나의 스키마가 500토큰이면, 하루 1,000번의 API 호출에서 50만 토큰이 그 도구 하나 때문에 매일 전송됩니다. 코어 도구 추가에 신중한 이유입니다.

**상위 개념(이를 활용해 만든 개념)**: [풋프린트 사다리](#footprint-ladder)

**관련 용어**: [풋프린트 사다리](#footprint-ladder) · [도구 스키마](03_tool_system.md#tool-schema) · [코어 도구](03_tool_system.md#core-tools)

**이 용어를 참조하는 항목**: [코어 도구](03_tool_system.md#core-tools) · [탈출구 패턴](#escape-hatch) · [도구 스키마](03_tool_system.md#tool-schema)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="footprint-ladder"></a>

### 풋프린트 사다리

**영문**: Footprint Ladder · **분류**: [설계 원칙·프로젝트 용어](README.md#분류content-class) · **최초 등장**: 2025

새 기능을 추가할 때 낮은 비용부터 시도하는 우선순위: ① 기존 코드 확장 → ② CLI 명령+스킬 → ③ 서비스 게이트 도구([check_fn](03_tool_system.md#check-fn)) → ④ [플러그인](12_subsystems.md#plugin) → ⑤ [MCP](08_protocols.md#mcp) 서버 → ⑥ 새 코어 도구(최후).

> **예시**: '일정 관리 기능'이 필요하면: 새 코어 도구를 만들기 전에, `hermes cron` CLI 명령 + 사용법 스킬로 해결되는지부터 검토합니다.

**하위 개념(더 일반·근본)**: [좁은 허리 원칙](#narrow-waist)

**관련 용어**: [가용성 검사 (check_fn)](03_tool_system.md#check-fn) · [플러그인](12_subsystems.md#plugin) · [MCP (모델 컨텍스트 프로토콜)](08_protocols.md#mcp)

**이 용어를 참조하는 항목**: [가용성 검사 (check_fn)](03_tool_system.md#check-fn) · [지연 설치 의존성](09_execution_infra.md#lazy-deps) · [좁은 허리 원칙](#narrow-waist) · [플러그인](12_subsystems.md#plugin) · [설정 마법사](#setup-wizard)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="config-yaml"></a>

### config.yaml

**영문**: config.yaml · **분류**: [설계 원칙·프로젝트 용어](README.md#분류content-class) · **최초 등장**: 2025

타임아웃·임계값·기능 플래그 등 모든 동작 설정이 들어가는 파일. 비밀([.env](10_security.md#secrets-env))과 분리하는 것이 규칙입니다.

**관련 용어**: [비밀정보 분리 (.env)](10_security.md#secrets-env) · [HERMES_HOME](07_gateway_interfaces.md#hermes-home)

**이 용어를 참조하는 항목**: [HERMES_HOME](07_gateway_interfaces.md#hermes-home) · [비밀정보 분리 (.env)](10_security.md#secrets-env) · [설정 마법사](#setup-wizard)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="behavior-contract"></a>

### 행위 계약 테스트

**영문**: Behavior Contract Tests · **분류**: [설계 원칙·프로젝트 용어](README.md#분류content-class) · **최초 등장**: 소프트웨어 공학 일반

'두 데이터가 어떤 관계여야 한다'는 불변식을 검증하는 테스트 스타일. 현재 값을 얼려 두는 [변경 감지 테스트](#change-detector)의 반대말로, Hermes가 권장하는 방식입니다.

> **예시**: "기본 모델은 모델 목록 안에 존재해야 한다"는 계약 테스트는 모델이 추가되어도 깨지지 않지만, "모델 목록 == [A, B, C]" 스냅샷 테스트는 깨집니다.

**상위 개념(이를 활용해 만든 개념)**: [변경 감지 테스트 (안티패턴)](#change-detector)

**관련 용어**: [변경 감지 테스트 (안티패턴)](#change-detector)

**이 용어를 참조하는 항목**: [E2E 검증](#e2e-validation)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="change-detector"></a>

### 변경 감지 테스트 (안티패턴)

**영문**: Change-Detector Tests · **분류**: [설계 원칙·프로젝트 용어](README.md#분류content-class) · **최초 등장**: 2015(구글 테스트 블로그)

모델 목록·설정 버전 같은 현재 값을 그대로 박아 두어, 정당한 변경에도 깨지는 테스트 안티패턴. Hermes에서 명시적으로 금지됩니다.

**하위 개념(더 일반·근본)**: [행위 계약 테스트](#behavior-contract)

**이 용어를 참조하는 항목**: [행위 계약 테스트](#behavior-contract)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="e2e-validation"></a>

### E2E 검증

**영문**: E2E Validation · **분류**: [설계 원칙·프로젝트 용어](README.md#분류content-class) · **최초 등장**: 소프트웨어 공학 일반

모의(mock)가 아닌 실제 import·파일·네트워크 경로로 기능을 검증하는 것. 설정 전파, 보안 경계, 원격 백엔드 관련 변경에 필수입니다.

**관련 용어**: [행위 계약 테스트](#behavior-contract)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="escape-hatch"></a>

### 탈출구 패턴

**영문**: Escape Hatch · **분류**: [설계 원칙·프로젝트 용어](README.md#분류content-class) · **최초 등장**: 소프트웨어 공학 일반

고수준 추상화가 못 다루는 예외 상황을 위해 저수준 원시 접근을 제한적으로 열어 두는 설계 패턴. [browser_cdp](03_tool_system.md#browser-cdp-tool) 도구가 대표 사례입니다.

> **예시**: 고수준 브라우저 도구가 다루지 못하는 1%의 상황을 위해 browser_cdp라는 저수준 문을 열어 두되, 화이트리스트로 통제합니다.

**관련 용어**: [browser_cdp (CDP 탈출구)](03_tool_system.md#browser-cdp-tool) · [좁은 허리 원칙](#narrow-waist)

**이 용어를 참조하는 항목**: [browser_cdp (CDP 탈출구)](03_tool_system.md#browser-cdp-tool)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="conventional-commits"></a>

### 컨벤셔널 커밋

**영문**: Conventional Commits · **분류**: [설계 원칙·프로젝트 용어](README.md#분류content-class) · **최초 등장**: 2017

`fix(scope):`, `feat(scope):`처럼 커밋 메시지에 유형과 범위를 규격화해 적는 관례. 변경 이력 자동 분류와 릴리스 노트 생성을 돕습니다.

**관련 용어**: [CI/CD](09_execution_infra.md#ci-cd)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="nous-portal"></a>

### Nous Portal

**영문**: Nous Portal · **분류**: [설계 원칙·프로젝트 용어](README.md#분류content-class) · **최초 등장**: 2025

Nous Research가 운영하는 통합 구독 서비스. 개별 API 키를 여러 개 관리하는 대신, 포털 계정 하나로 관리형 모델·도구 접근을 제공합니다.

> **예시**: 사용자가 OpenAI/Anthropic 키를 각각 발급받는 대신 Nous Portal 하나로 여러 모델을 쓰는 방식입니다.

**하위 개념(더 일반·근본)**: [LLM 제공자](02_agent_core.md#provider)

**관련 용어**: [관리형 도구](#managed-tools) · [크리덴셜 풀](02_agent_core.md#credential-pool)

**이 용어를 참조하는 항목**: [관리형 도구](#managed-tools)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="managed-tools"></a>

### 관리형 도구

**영문**: Managed Tools · **분류**: [설계 원칙·프로젝트 용어](README.md#분류content-class) · **최초 등장**: 2025

로컬이 아니라 호스팅된 게이트웨이에서 원격 실행되는 도구(이미지 생성 등). 무거운 의존성·GPU가 필요한 기능을 로컬 설치 없이 제공합니다.

> **예시**: 이미지 생성 도구는 로컬 GPU 없이 [Nous Portal](#nous-portal)의 원격 실행으로 동작합니다.

**하위 개념(더 일반·근본)**: [도구](03_tool_system.md#tool)

**관련 용어**: [Nous Portal](#nous-portal)

**이 용어를 참조하는 항목**: [Nous Portal](#nous-portal)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="turn-isolation"></a>

### 턴 격리

**영문**: Turn Isolation · **분류**: [설계 원칙·프로젝트 용어](README.md#분류content-class) · **최초 등장**: 2025

에이전트 턴 자체를 원격 컴퓨트 호스트에서 실행하는 기능. 무거운 턴 처리를 로컬 기기에서 떼어내 확장성과 격리를 얻습니다.

> **예시**: 노트북에서는 메시지만 주고받고, 실제 턴 실행(모델 호출+도구)은 클라우드 호스트에서 수행하는 구성입니다.

**하위 개념(더 일반·근본)**: [턴](02_agent_core.md#turn) · [실행 환경](09_execution_infra.md#execution-environment)

**관련 용어**: [서버리스 컴퓨트](09_execution_infra.md#serverless)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="skin"></a>

### 스킨 (CLI 테마)

**영문**: Skin · **분류**: [설계 원칙·프로젝트 용어](README.md#분류content-class) · **최초 등장**: 2025

CLI의 표시 스타일(색·배너·서식)을 갈아입히는 테마 시스템(`hermes_cli/`의 skin engine). 동작이 아닌 외관만 바꾸는 가장 가벼운 커스터마이징 계층입니다.

> **예시**: 커뮤니티가 만든 스킨을 설치하면 같은 Hermes가 완전히 다른 look & feel로 보입니다.

**하위 개념(더 일반·근본)**: [HermesCLI](07_gateway_interfaces.md#hermes-cli)

**관련 용어**: [플러그인](12_subsystems.md#plugin)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="setup-wizard"></a>

### 설정 마법사

**영문**: Setup Wizard · **분류**: [설계 원칙·프로젝트 용어](README.md#분류content-class) · **최초 등장**: 2025

`hermes setup`으로 실행되는 대화형 초기 설정 절차. 새 기능은 원시 환경변수를 문서에 적는 대신 이 설정 UX(`hermes tools`, 자동 설치)에 통합하는 것이 규칙입니다.

> **예시**: Telegram 게이트웨이를 켜면 마법사가 토큰 입력과 검증까지 안내합니다.

**하위 개념(더 일반·근본)**: [HermesCLI](07_gateway_interfaces.md#hermes-cli)

**관련 용어**: [config.yaml](#config-yaml) · [풋프린트 사다리](#footprint-ladder)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---
