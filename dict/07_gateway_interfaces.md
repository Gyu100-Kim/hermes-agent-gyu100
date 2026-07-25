# 용어 사전 — 게이트웨이·인터페이스

[⬆ 사전 전체 목차로](README.md)

이 문서는 분류(Content Class) **게이트웨이·인터페이스** 에 속한 용어 16개를 다룹니다.

- 설명 속 링크를 누르면 해당 용어 항목으로 이동합니다.
- **하위 개념** = 이 용어를 규정하는 데 필요한 더 **일반적·근본적인** 개념, **상위 개념** = 이 용어를 **활용해 만들어진** 더 특수한 개념입니다. (예: Attention → Transformer → LLM 순으로 상위)
- 각 항목의 **최초 등장** 연월은 상위/하위 판별의 참고 자료입니다(단, 상위 용어가 항상 늦게 생기는 것은 아닙니다).
- 각 항목 끝의 "이 용어를 참조하는 항목"으로 원래 보던 곳으로 되돌아갈 수 있습니다.

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
- [웹훅](#webhook)
- [API 서버 어댑터](#api-server)

<a id="gateway"></a>

### 게이트웨이

**영문**: Gateway · **분류**: [게이트웨이·인터페이스](README.md#분류content-class) · **최초 등장**: 2025

Telegram, Discord, Slack 등 여러 메신저에서 같은 에이전트 코어를 쓰게 해 주는 상시 실행 서비스(`gateway/run.py`의 GatewayRunner). 플랫폼별 차이는 [플랫폼 어댑터](#platform-adapter)가 흡수합니다.

> **예시**: Telegram에서 말을 걸든 Slack에서 걸든, 같은 Hermes 에이전트가 같은 기억을 갖고 답합니다.

**상위 개념(이를 활용해 만든 개념)**: [딜리버리 (출력 라우팅)](#delivery) · [게이트웨이 세션](#gateway-session) · [플랫폼 어댑터](#platform-adapter) · [슬래시 명령](#slash-command)

**관련 용어**: [플랫폼 어댑터](#platform-adapter) · [게이트웨이 세션](#gateway-session) · [딜리버리 (출력 라우팅)](#delivery)

**이 용어를 참조하는 항목**: [음성 모드](03_tool_system.md#voice-mode)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="platform-adapter"></a>

### 플랫폼 어댑터

**영문**: Platform Adapter · **분류**: [게이트웨이·인터페이스](README.md#분류content-class) · **최초 등장**: 2025

각 메신저의 API·메시지 형식을 게이트웨이의 공통 인터페이스로 변환하는 계층(`gateway/platforms/*`). 새 메신저 지원 = 어댑터 하나 추가이며, 절차는 ADDING_A_PLATFORM.md에 문서화되어 있습니다.

> **예시**: Telegram의 4096자 메시지 제한, Discord의 2000자 제한 같은 차이를 어댑터가 알아서 분할 처리합니다.

**하위 개념(더 일반·근본)**: [게이트웨이](#gateway)

**상위 개념(이를 활용해 만든 개념)**: [API 서버 어댑터](#api-server) · [웹훅](#webhook)

**관련 용어**: [딜리버리 (출력 라우팅)](#delivery)

**이 용어를 참조하는 항목**: [딜리버리 (출력 라우팅)](#delivery) · [게이트웨이](#gateway)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="gateway-session"></a>

### 게이트웨이 세션

**영문**: Gateway Session Context · **분류**: [게이트웨이·인터페이스](README.md#분류content-class) · **최초 등장**: 2025

채팅방/사용자별로 유지되는 대화 컨텍스트(`gateway/session.py`). 어느 플랫폼에서 온 메시지인지에 관계없이 [세션](06_state_retrieval.md#session)과 연결합니다.

**하위 개념(더 일반·근본)**: [게이트웨이](#gateway)

**상위 개념(이를 활용해 만든 개념)**: [통합 세션](#unified-inbox)

**관련 용어**: [세션](06_state_retrieval.md#session) · [통합 세션](#unified-inbox)

**이 용어를 참조하는 항목**: [게이트웨이](#gateway)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="delivery"></a>

### 딜리버리 (출력 라우팅)

**영문**: Delivery · **분류**: [게이트웨이·인터페이스](README.md#분류content-class) · **최초 등장**: 2025

에이전트의 응답을 올바른 플랫폼·채팅방으로 되돌려 보내는 출력 라우팅 계층(`gateway/delivery.py`). 플랫폼별 메시지 길이 제한·서식 차이를 처리합니다.

**하위 개념(더 일반·근본)**: [게이트웨이](#gateway)

**관련 용어**: [플랫폼 어댑터](#platform-adapter)

**이 용어를 참조하는 항목**: [게이트웨이](#gateway) · [플랫폼 어댑터](#platform-adapter)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="unified-inbox"></a>

### 통합 세션

**영문**: Unified Session · **분류**: [게이트웨이·인터페이스](README.md#분류content-class) · **최초 등장**: 2025

여러 플랫폼(예: Telegram과 CLI)에서 온 대화를 하나의 세션으로 이어주는 기능. 어디서 말을 걸어도 같은 맥락이 유지됩니다.

**하위 개념(더 일반·근본)**: [게이트웨이 세션](#gateway-session)

**이 용어를 참조하는 항목**: [게이트웨이 세션](#gateway-session)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="slash-command"></a>

### 슬래시 명령

**영문**: Slash Command · **분류**: [게이트웨이·인터페이스](README.md#분류content-class) · **최초 등장**: 1988(IRC)

`/model`, `/moa`, `/new`처럼 사용자가 직접 입력하는 제어 명령. 모든 인터페이스(CLI, TUI, 메신저)에서 공통으로 동작합니다.

> **예시**: `/model gpt-4o`로 모델을 바꾸고, `/new`로 새 세션을 시작합니다.

**하위 개념(더 일반·근본)**: [게이트웨이](#gateway)

**관련 용어**: [Mixture-of-Agents (MoA)](02_agent_core.md#moa)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="hermes-cli"></a>

### HermesCLI

**영문**: HermesCLI · **분류**: [게이트웨이·인터페이스](README.md#분류content-class) · **최초 등장**: 2025

터미널 대화형 인터페이스의 오케스트레이터(`cli.py`). `hermes` 명령의 진입점이며 [REPL](#repl) 루프를 제공합니다.

**하위 개념(더 일반·근본)**: [REPL](#repl)

**상위 개념(이를 활용해 만든 개념)**: [설정 마법사](11_design_principles.md#setup-wizard) · [스킨 (CLI 테마)](11_design_principles.md#skin)

**관련 용어**: [AIAgent 클래스](02_agent_core.md#aiagent)

**이 용어를 참조하는 항목**: [REPL](#repl) · [TUI (Ink)](#tui)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="repl"></a>

### REPL

**영문**: REPL · **분류**: [게이트웨이·인터페이스](README.md#분류content-class) · **최초 등장**: 1964(LISP)

읽기(Read)-평가(Eval)-출력(Print) 반복(Loop)의 약자. 터미널에서 한 줄씩 입력하고 즉시 응답을 받는 대화형 실행 방식입니다.

**상위 개념(이를 활용해 만든 개념)**: [HermesCLI](#hermes-cli)

**관련 용어**: [HermesCLI](#hermes-cli)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="tui"></a>

### TUI (Ink)

**영문**: TUI · **분류**: [게이트웨이·인터페이스](README.md#분류content-class) · **최초 등장**: 1980년대·2025(Hermes TUI)

React 기반 Ink 프레임워크로 만든 터미널 그래픽 인터페이스(`ui-tui/`). 일반 CLI보다 풍부한 표시(패널, 진행 표시)를 제공합니다.

**상위 개념(이를 활용해 만든 개념)**: [TUI 게이트웨이](#tui-gateway)

**관련 용어**: [TUI 게이트웨이](#tui-gateway) · [HermesCLI](#hermes-cli)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="tui-gateway"></a>

### TUI 게이트웨이

**영문**: TUI Gateway · **분류**: [게이트웨이·인터페이스](README.md#분류content-class) · **최초 등장**: 2025

Python 코어와 TypeScript TUI 사이를 잇는 [JSON-RPC](08_protocols.md#json-rpc) 브리지(`tui_gateway/`). 프론트엔드와 코어를 분리해 각자 독립적으로 발전할 수 있게 합니다.

**하위 개념(더 일반·근본)**: [TUI (Ink)](#tui) · [JSON-RPC 2.0](08_protocols.md#json-rpc)

**상위 개념(이를 활용해 만든 개념)**: [데스크톱 앱 (Electron)](#desktop-app)

**이 용어를 참조하는 항목**: [TUI (Ink)](#tui)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="desktop-app"></a>

### 데스크톱 앱 (Electron)

**영문**: Desktop App · **분류**: [게이트웨이·인터페이스](README.md#분류content-class) · **최초 등장**: 2025

Electron 기반 데스크톱 애플리케이션(`apps/desktop/`). 웹 기술로 만든 UI를 네이티브 앱처럼 배포합니다.

**하위 개념(더 일반·근본)**: [TUI 게이트웨이](#tui-gateway)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="web-dashboard"></a>

### 웹 대시보드

**영문**: Web Dashboard · **분류**: [게이트웨이·인터페이스](README.md#분류content-class) · **최초 등장**: 2025

브라우저에서 세션·상태를 보는 웹 UI. [플러그인](12_subsystems.md#plugin)으로 제공되는 관측 화면입니다.

**하위 개념(더 일반·근본)**: [플러그인](12_subsystems.md#plugin)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="profile"></a>

### 프로필

**영문**: Profile · **분류**: [게이트웨이·인터페이스](README.md#분류content-class) · **최초 등장**: 2025

설정·상태·스킬이 완전히 분리된 독립 실행 환경. 프로필끼리는 의도적으로 서로 영향을 주지 않는 '섬'으로 설계되어 있습니다(생성 시 `--clone` 복사만 허용).

> **예시**: '업무용'과 '개인용' 프로필을 만들면 설정·기억·스킬이 완전히 분리된 두 Hermes가 됩니다.

**하위 개념(더 일반·근본)**: [HERMES_HOME](#hermes-home)

**이 용어를 참조하는 항목**: [HERMES_HOME](#hermes-home)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="hermes-home"></a>

### HERMES_HOME

**영문**: HERMES_HOME · **분류**: [게이트웨이·인터페이스](README.md#분류content-class) · **최초 등장**: 2025

Hermes의 상태(설정, DB, 스킬, 로그)가 저장되는 홈 디렉토리. [프로필](#profile)마다 다른 경로를 가집니다.

**상위 개념(이를 활용해 만든 개념)**: [프로필](#profile)

**관련 용어**: [프로필](#profile) · [config.yaml](11_design_principles.md#config-yaml)

**이 용어를 참조하는 항목**: [config.yaml](11_design_principles.md#config-yaml)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="webhook"></a>

### 웹훅

**영문**: Webhook · **분류**: [게이트웨이·인터페이스](README.md#분류content-class) · **최초 등장**: 2007

외부 서비스가 이벤트 발생 시 지정된 URL로 HTTP 요청을 보내 에이전트를 깨우는 통합 방식. 폴링 없이 이벤트 기반으로 반응할 수 있습니다.

> **예시**: GitHub 저장소에 이슈가 생기면 웹훅이 Hermes를 호출해 자동으로 분류하게 만들 수 있습니다.

**하위 개념(더 일반·근본)**: [플랫폼 어댑터](#platform-adapter)

**관련 용어**: [크론 (예약 작업)](12_subsystems.md#cron)

**이 용어를 참조하는 항목**: [API 서버 어댑터](#api-server)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="api-server"></a>

### API 서버 어댑터

**영문**: API Server Adapter · **분류**: [게이트웨이·인터페이스](README.md#분류content-class) · **최초 등장**: 2025

Hermes를 HTTP API로 노출하는 [플랫폼 어댑터](#platform-adapter). 다른 프로그램이 메신저 없이 직접 에이전트를 호출할 수 있게 합니다.

> **예시**: 사내 시스템이 REST 호출로 Hermes에게 질문을 보내고 JSON 응답을 받는 구성입니다.

**하위 개념(더 일반·근본)**: [플랫폼 어댑터](#platform-adapter)

**관련 용어**: [웹훅](#webhook)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---
