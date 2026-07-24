# 용어 사전 — 설계 원칙·프로젝트 용어

[⬆ 사전 전체 목차로](README.md)

이 문서는 **설계 원칙·프로젝트 용어** 범주의 용어 8개를 다룹니다. 설명 속 파란 링크를 누르면 해당 용어 항목으로 이동하며, 각 항목 끝의 "이 용어를 참조하는 항목"으로 되돌아올 수 있습니다.

## 이 문서의 용어

- [좁은 허리 원칙](#narrow-waist)
- [풋프린트 사다리](#footprint-ladder)
- [config.yaml](#config-yaml)
- [행위 계약 테스트](#behavior-contract)
- [변경 감지 테스트 (안티패턴)](#change-detector)
- [E2E 검증](#e2e-validation)
- [탈출구 패턴](#escape-hatch)
- [컨벤셔널 커밋](#conventional-commits)

<a id="narrow-waist"></a>

### 좁은 허리 원칙

**영문**: Narrow Waist · **범주**: 설계 원칙·프로젝트 용어

에이전트 코어와 모델 도구 스키마를 최소한으로 유지하고, 기능 확장은 가장자리(스킬, 플러그인, MCP)에서 하라는 Hermes 핵심 설계 철학. 모든 [도구 스키마](03_tool_system.md#tool-schema)가 매 호출 전송되므로 코어 추가는 영구적 비용입니다.

**하위 개념**: [풋프린트 사다리](#footprint-ladder)

**관련 용어**: [풋프린트 사다리](#footprint-ladder) · [도구 스키마](03_tool_system.md#tool-schema) · [코어 도구](03_tool_system.md#core-tools)

**이 용어를 참조하는 항목**: [코어 도구](03_tool_system.md#core-tools) · [탈출구 패턴](#escape-hatch) · [도구 스키마](03_tool_system.md#tool-schema)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="footprint-ladder"></a>

### 풋프린트 사다리

**영문**: Footprint Ladder · **범주**: 설계 원칙·프로젝트 용어

새 기능을 추가할 때 낮은 비용부터 시도하는 우선순위: ① 기존 코드 확장 → ② CLI 명령+스킬 → ③ 서비스 게이트 도구([check_fn](03_tool_system.md#check-fn)) → ④ [플러그인](12_subsystems.md#plugin) → ⑤ [MCP](08_protocols.md#mcp) 서버 → ⑥ 새 코어 도구(최후).

**상위 개념**: [좁은 허리 원칙](#narrow-waist)

**관련 용어**: [가용성 검사 (check_fn)](03_tool_system.md#check-fn) · [플러그인](12_subsystems.md#plugin) · [MCP (모델 컨텍스트 프로토콜)](08_protocols.md#mcp)

**이 용어를 참조하는 항목**: [가용성 검사 (check_fn)](03_tool_system.md#check-fn) · [지연 설치 의존성](09_execution_infra.md#lazy-deps) · [좁은 허리 원칙](#narrow-waist) · [플러그인](12_subsystems.md#plugin)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="config-yaml"></a>

### config.yaml

**영문**: config.yaml · **범주**: 설계 원칙·프로젝트 용어

타임아웃·임계값·기능 플래그 등 모든 동작 설정이 들어가는 파일. 비밀([.env](10_security.md#secrets-env))과 분리하는 것이 규칙입니다.

**관련 용어**: [비밀정보 분리 (.env)](10_security.md#secrets-env) · [HERMES_HOME](07_gateway_interfaces.md#hermes-home)

**이 용어를 참조하는 항목**: [HERMES_HOME](07_gateway_interfaces.md#hermes-home) · [비밀정보 분리 (.env)](10_security.md#secrets-env)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="behavior-contract"></a>

### 행위 계약 테스트

**영문**: Behavior Contract Tests · **범주**: 설계 원칙·프로젝트 용어

'두 데이터가 어떤 관계여야 한다'는 불변식을 검증하는 테스트 스타일. 현재 값을 얼려 두는 [변경 감지 테스트](#change-detector)의 반대말로, Hermes가 권장하는 방식입니다.

**하위 개념**: [변경 감지 테스트 (안티패턴)](#change-detector)

**관련 용어**: [변경 감지 테스트 (안티패턴)](#change-detector)

**이 용어를 참조하는 항목**: [E2E 검증](#e2e-validation)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="change-detector"></a>

### 변경 감지 테스트 (안티패턴)

**영문**: Change-Detector Tests · **범주**: 설계 원칙·프로젝트 용어

모델 목록·설정 버전 같은 현재 값을 그대로 박아 두어, 정당한 변경에도 깨지는 테스트 안티패턴. Hermes에서 명시적으로 금지됩니다.

**상위 개념**: [행위 계약 테스트](#behavior-contract)

**이 용어를 참조하는 항목**: [행위 계약 테스트](#behavior-contract)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="e2e-validation"></a>

### E2E 검증

**영문**: E2E Validation · **범주**: 설계 원칙·프로젝트 용어

모의(mock)가 아닌 실제 import·파일·네트워크 경로로 기능을 검증하는 것. 설정 전파, 보안 경계, 원격 백엔드 관련 변경에 필수입니다.

**관련 용어**: [행위 계약 테스트](#behavior-contract)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="escape-hatch"></a>

### 탈출구 패턴

**영문**: Escape Hatch · **범주**: 설계 원칙·프로젝트 용어

고수준 추상화가 못 다루는 예외 상황을 위해 저수준 원시 접근을 제한적으로 열어 두는 설계 패턴. [browser_cdp](03_tool_system.md#browser-cdp-tool) 도구가 대표 사례입니다.

**관련 용어**: [browser_cdp (CDP 탈출구)](03_tool_system.md#browser-cdp-tool) · [좁은 허리 원칙](#narrow-waist)

**이 용어를 참조하는 항목**: [browser_cdp (CDP 탈출구)](03_tool_system.md#browser-cdp-tool)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="conventional-commits"></a>

### 컨벤셔널 커밋

**영문**: Conventional Commits · **범주**: 설계 원칙·프로젝트 용어

`fix(scope):`, `feat(scope):`처럼 커밋 메시지에 유형과 범위를 규격화해 적는 관례. 변경 이력 자동 분류와 릴리스 노트 생성을 돕습니다.

**관련 용어**: [CI/CD](09_execution_infra.md#ci-cd)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---
