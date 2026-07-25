# 용어 사전 — 게이트웨이·인터페이스

[⬆ 사전 전체 목차로](README.md)

이 문서는 **게이트웨이·인터페이스** 범주의 용어 14개를 다룹니다. 설명 속 파란 링크를 누르면 해당 용어 항목으로 이동하며, 각 항목 끝의 "이 용어를 참조하는 항목"으로 되돌아올 수 있습니다.

## 이 문서의 용어

- [게이트웨이](#gateway)
- [플랫폼 어댑터](#platform-adapter)
- [게이트웨이 세션](#gateway-session)
- [딜리버리 (출력 라우팅)](#delivery)
- [통합 세션](#unified-inbox)
- [슬래시 명령](#slash-command)
- [HermesCLI](#hermes-cli)
- [REPL](#repl)
- [TUI (Ink)](#tui)
- [TUI 게이트웨이](#tui-gateway)
- [데스크톱 앱 (Electron)](#desktop-app)
- [웹 대시보드](#web-dashboard)
- [프로필](#profile)
- [HERMES_HOME](#hermes-home)

<a id="gateway"></a>

### 게이트웨이

**영문**: Gateway · **범주**: 게이트웨이·인터페이스

Telegram, Discord, Slack 등 여러 메신저에서 같은 에이전트 코어를 쓰게 해 주는 상시 실행 서비스(`gateway/run.py`의 GatewayRunner). 플랫폼별 차이는 [플랫폼 어댑터](#platform-adapter)가 흡수합니다.

**하위 개념**: [딜리버리 (출력 라우팅)](#delivery) · [게이트웨이 세션](#gateway-session) · [플랫폼 어댑터](#platform-adapter) · [슬래시 명령](#slash-command)

**관련 용어**: [플랫폼 어댑터](#platform-adapter) · [게이트웨이 세션](#gateway-session) · [딜리버리 (출력 라우팅)](#delivery)

**이 용어를 참조하는 항목**: [음성 모드](03_tool_system.md#voice-mode)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="platform-adapter"></a>

### 플랫폼 어댑터

**영문**: Platform Adapter · **범주**: 게이트웨이·인터페이스

각 메신저의 API·메시지 형식을 게이트웨이의 공통 인터페이스로 변환하는 계층(`gateway/platforms/*`). 새 메신저 지원 = 어댑터 하나 추가이며, 절차는 ADDING_A_PLATFORM.md에 문서화되어 있습니다.

**상위 개념**: [게이트웨이](#gateway)

**관련 용어**: [딜리버리 (출력 라우팅)](#delivery)

**이 용어를 참조하는 항목**: [딜리버리 (출력 라우팅)](#delivery) · [게이트웨이](#gateway)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="gateway-session"></a>

### 게이트웨이 세션

**영문**: Gateway Session Context · **범주**: 게이트웨이·인터페이스

채팅방/사용자별로 유지되는 대화 컨텍스트(`gateway/session.py`). 어느 플랫폼에서 온 메시지인지에 관계없이 [세션](06_state_retrieval.md#session)과 연결합니다.

**상위 개념**: [게이트웨이](#gateway)

**하위 개념**: [통합 세션](#unified-inbox)

**관련 용어**: [세션](06_state_retrieval.md#session) · [통합 세션](#unified-inbox)

**이 용어를 참조하는 항목**: [게이트웨이](#gateway)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="delivery"></a>

### 딜리버리 (출력 라우팅)

**영문**: Delivery · **범주**: 게이트웨이·인터페이스

에이전트의 응답을 올바른 플랫폼·채팅방으로 되돌려 보내는 출력 라우팅 계층(`gateway/delivery.py`). 플랫폼별 메시지 길이 제한·서식 차이를 처리합니다.

**상위 개념**: [게이트웨이](#gateway)

**관련 용어**: [플랫폼 어댑터](#platform-adapter)

**이 용어를 참조하는 항목**: [게이트웨이](#gateway) · [플랫폼 어댑터](#platform-adapter)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="unified-inbox"></a>

### 통합 세션

**영문**: Unified Session · **범주**: 게이트웨이·인터페이스

여러 플랫폼(예: Telegram과 CLI)에서 온 대화를 하나의 세션으로 이어주는 기능. 어디서 말을 걸어도 같은 맥락이 유지됩니다.

**상위 개념**: [게이트웨이 세션](#gateway-session)

**이 용어를 참조하는 항목**: [게이트웨이 세션](#gateway-session)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="slash-command"></a>

### 슬래시 명령

**영문**: Slash Command · **범주**: 게이트웨이·인터페이스

`/model`, `/moa`, `/new`처럼 사용자가 직접 입력하는 제어 명령. 모든 인터페이스(CLI, TUI, 메신저)에서 공통으로 동작합니다.

**상위 개념**: [게이트웨이](#gateway)

**관련 용어**: [Mixture-of-Agents (MoA)](02_agent_core.md#moa)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="hermes-cli"></a>

### HermesCLI

**영문**: HermesCLI · **범주**: 게이트웨이·인터페이스

터미널 대화형 인터페이스의 오케스트레이터(`cli.py`). `hermes` 명령의 진입점이며 [REPL](#repl) 루프를 제공합니다.

**하위 개념**: [REPL](#repl)

**관련 용어**: [REPL](#repl) · [AIAgent 클래스](02_agent_core.md#aiagent)

**이 용어를 참조하는 항목**: [TUI (Ink)](#tui)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="repl"></a>

### REPL

**영문**: REPL · **범주**: 게이트웨이·인터페이스

읽기(Read)-평가(Eval)-출력(Print) 반복(Loop)의 약자. 터미널에서 한 줄씩 입력하고 즉시 응답을 받는 대화형 실행 방식입니다.

**상위 개념**: [HermesCLI](#hermes-cli)

**이 용어를 참조하는 항목**: [HermesCLI](#hermes-cli)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="tui"></a>

### TUI (Ink)

**영문**: TUI · **범주**: 게이트웨이·인터페이스

React 기반 Ink 프레임워크로 만든 터미널 그래픽 인터페이스(`ui-tui/`). 일반 CLI보다 풍부한 표시(패널, 진행 표시)를 제공합니다.

**하위 개념**: [TUI 게이트웨이](#tui-gateway)

**관련 용어**: [TUI 게이트웨이](#tui-gateway) · [HermesCLI](#hermes-cli)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="tui-gateway"></a>

### TUI 게이트웨이

**영문**: TUI Gateway · **범주**: 게이트웨이·인터페이스

Python 코어와 TypeScript TUI 사이를 잇는 [JSON-RPC](08_protocols.md#json-rpc) 브리지(`tui_gateway/`). 프론트엔드와 코어를 분리해 각자 독립적으로 발전할 수 있게 합니다.

**상위 개념**: [TUI (Ink)](#tui)

**관련 용어**: [JSON-RPC 2.0](08_protocols.md#json-rpc)

**이 용어를 참조하는 항목**: [데스크톱 앱 (Electron)](#desktop-app) · [TUI (Ink)](#tui)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="desktop-app"></a>

### 데스크톱 앱 (Electron)

**영문**: Desktop App · **범주**: 게이트웨이·인터페이스

Electron 기반 데스크톱 애플리케이션(`apps/desktop/`). 웹 기술로 만든 UI를 네이티브 앱처럼 배포합니다.

**관련 용어**: [TUI 게이트웨이](#tui-gateway)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="web-dashboard"></a>

### 웹 대시보드

**영문**: Web Dashboard · **범주**: 게이트웨이·인터페이스

브라우저에서 세션·상태를 보는 웹 UI. [플러그인](12_subsystems.md#plugin)으로 제공되는 관측 화면입니다.

**관련 용어**: [플러그인](12_subsystems.md#plugin)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="profile"></a>

### 프로필

**영문**: Profile · **범주**: 게이트웨이·인터페이스

설정·상태·스킬이 완전히 분리된 독립 실행 환경. 프로필끼리는 의도적으로 서로 영향을 주지 않는 '섬'으로 설계되어 있습니다(생성 시 `--clone` 복사만 허용).

**하위 개념**: [HERMES_HOME](#hermes-home)

**관련 용어**: [HERMES_HOME](#hermes-home)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="hermes-home"></a>

### HERMES_HOME

**영문**: HERMES_HOME · **범주**: 게이트웨이·인터페이스

Hermes의 상태(설정, DB, 스킬, 로그)가 저장되는 홈 디렉토리. [프로필](#profile)마다 다른 경로를 가집니다.

**상위 개념**: [프로필](#profile)

**관련 용어**: [config.yaml](11_design_principles.md#config-yaml)

**이 용어를 참조하는 항목**: [config.yaml](11_design_principles.md#config-yaml) · [프로필](#profile)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---
