# 용어 사전 — 프로토콜·상호운용

[⬆ 사전 전체 목차로](README.md)

이 문서는 **프로토콜·상호운용** 범주의 용어 19개를 다룹니다. 설명 속 파란 링크를 누르면 해당 용어 항목으로 이동하며, 각 항목 끝의 "이 용어를 참조하는 항목"으로 되돌아올 수 있습니다.

## 이 문서의 용어

- [MCP (모델 컨텍스트 프로토콜)](#mcp)
- [MCP 서버](#mcp-server)
- [MCP 클라이언트](#mcp-client)
- [MCP 프리미티브](#mcp-primitives)
- [MCP 전송 계층](#mcp-transport)
- [stdio 전송](#stdio)
- [SSE (서버 전송 이벤트)](#sse)
- [Streamable HTTP](#streamable-http)
- [JSON-RPC 2.0](#json-rpc)
- [ACP (에이전트 클라이언트 프로토콜)](#acp)
- [LSP (언어 서버 프로토콜)](#lsp)
- [N×M 통합 문제](#nxm-problem)
- [기능 협상](#capability-negotiation)
- [CDP (크롬 개발자도구 프로토콜)](#cdp)
- [WebSocket](#websocket)
- [CDP 도메인](#cdp-domain)
- [헤드리스 브라우저](#headless)
- [접근성 트리](#accessibility-tree)
- [클라우드 브라우저](#cloud-browser)

<a id="mcp"></a>

### MCP (모델 컨텍스트 프로토콜)

**영문**: Model Context Protocol · **범주**: 프로토콜·상호운용

에이전트가 외부 도구·데이터 소스에 표준 방식으로 연결하게 하는 개방형 프로토콜(Anthropic, 2024). '에이전트 ↔ 도구' 방향의 표준이며, [N×M 통합 문제](#nxm-problem)를 해결합니다.

**하위 개념**: [기능 협상](#capability-negotiation) · [MCP 클라이언트](#mcp-client) · [MCP 프리미티브](#mcp-primitives) · [MCP 서버](#mcp-server) · [MCP 전송 계층](#mcp-transport)

**관련 용어**: [MCP 서버](#mcp-server) · [JSON-RPC 2.0](#json-rpc) · [ACP (에이전트 클라이언트 프로토콜)](#acp) · [N×M 통합 문제](#nxm-problem)

**이 용어를 참조하는 항목**: [ACP (에이전트 클라이언트 프로토콜)](#acp) · [풋프린트 사다리](11_design_principles.md#footprint-ladder) · [JSON-RPC 2.0](#json-rpc) · [LSP (언어 서버 프로토콜)](#lsp) · [N×M 통합 문제](#nxm-problem)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="mcp-server"></a>

### MCP 서버

**영문**: MCP Server · **범주**: 프로토콜·상호운용

도구·리소스를 [MCP](#mcp) 형식으로 제공하는 프로그램. Hermes는 이를 발견해 자기 [도구 레지스트리](03_tool_system.md#tool-registry)에 등록, 내장 도구처럼 호출합니다.

**상위 개념**: [MCP (모델 컨텍스트 프로토콜)](#mcp)

**관련 용어**: [MCP 클라이언트](#mcp-client) · [MCP 프리미티브](#mcp-primitives)

**이 용어를 참조하는 항목**: [MCP (모델 컨텍스트 프로토콜)](#mcp) · [MCP 클라이언트](#mcp-client) · [도구 중독](10_security.md#tool-poisoning) · [비신뢰 콘텐츠 원칙](10_security.md#untrusted-content)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="mcp-client"></a>

### MCP 클라이언트

**영문**: MCP Client · **범주**: 프로토콜·상호운용

[MCP 서버](#mcp-server)에 접속하는 쪽(`tools/mcp_tool.py`). 연결·초기화·도구 발견·호출 중계를 담당합니다.

**상위 개념**: [MCP (모델 컨텍스트 프로토콜)](#mcp)

**관련 용어**: [MCP 전송 계층](#mcp-transport)

**이 용어를 참조하는 항목**: [MCP 서버](#mcp-server)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="mcp-primitives"></a>

### MCP 프리미티브

**영문**: MCP Primitives · **범주**: 프로토콜·상호운용

MCP가 정의하는 기능 단위들: tools(호출 가능한 기능), resources(읽을 수 있는 데이터), prompts(템플릿), sampling(서버가 클라이언트의 LLM에 생성 요청).

**상위 개념**: [MCP (모델 컨텍스트 프로토콜)](#mcp)

**관련 용어**: [도구](03_tool_system.md#tool)

**이 용어를 참조하는 항목**: [MCP 서버](#mcp-server)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="mcp-transport"></a>

### MCP 전송 계층

**영문**: MCP Transports · **범주**: 프로토콜·상호운용

MCP 메시지가 오가는 통신 방식: [stdio](#stdio)(로컬 프로세스), HTTP/[Streamable HTTP](#streamable-http), [SSE](#sse)(레거시). Hermes는 셋 다 지원합니다.

**상위 개념**: [MCP (모델 컨텍스트 프로토콜)](#mcp)

**하위 개념**: [SSE (서버 전송 이벤트)](#sse) · [stdio 전송](#stdio) · [Streamable HTTP](#streamable-http)

**관련 용어**: [stdio 전송](#stdio) · [SSE (서버 전송 이벤트)](#sse) · [Streamable HTTP](#streamable-http)

**이 용어를 참조하는 항목**: [MCP 클라이언트](#mcp-client)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="stdio"></a>

### stdio 전송

**영문**: stdio Transport · **범주**: 프로토콜·상호운용

서버를 자식 프로세스로 띄우고 표준 입출력 파이프로 통신하는 방식. 네트워크 설정 없이 로컬 도구를 연결하는 가장 간단한 경로입니다.

**상위 개념**: [MCP 전송 계층](#mcp-transport)

**이 용어를 참조하는 항목**: [ACP 어댑터](12_subsystems.md#acp-adapter) · [MCP 전송 계층](#mcp-transport)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="sse"></a>

### SSE (서버 전송 이벤트)

**영문**: Server-Sent Events · **범주**: 프로토콜·상호운용

서버가 HTTP 연결을 유지하며 클라이언트로 이벤트를 스트리밍하는 웹 표준. MCP 초기 원격 전송으로 쓰였으나 [Streamable HTTP](#streamable-http)로 대체되는 중입니다.

**상위 개념**: [MCP 전송 계층](#mcp-transport)

**관련 용어**: [Streamable HTTP](#streamable-http)

**이 용어를 참조하는 항목**: [MCP 전송 계층](#mcp-transport) · [Streamable HTTP](#streamable-http)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="streamable-http"></a>

### Streamable HTTP

**영문**: Streamable HTTP · **범주**: 프로토콜·상호운용

단일 HTTP 엔드포인트에서 요청-응답과 스트리밍을 모두 처리하는 현행 MCP 원격 전송 방식.

**상위 개념**: [MCP 전송 계층](#mcp-transport)

**관련 용어**: [SSE (서버 전송 이벤트)](#sse)

**이 용어를 참조하는 항목**: [MCP 전송 계층](#mcp-transport) · [SSE (서버 전송 이벤트)](#sse)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="json-rpc"></a>

### JSON-RPC 2.0

**영문**: JSON-RPC 2.0 · **범주**: 프로토콜·상호운용

JSON으로 원격 함수 호출(요청 id, method, params / 응답 result, error)을 표현하는 경량 프로토콜. [MCP](#mcp), [ACP](#acp), [LSP](#lsp)가 모두 이 위에 만들어졌습니다.

**관련 용어**: [MCP (모델 컨텍스트 프로토콜)](#mcp) · [ACP (에이전트 클라이언트 프로토콜)](#acp) · [LSP (언어 서버 프로토콜)](#lsp)

**이 용어를 참조하는 항목**: [ACP (에이전트 클라이언트 프로토콜)](#acp) · [LSP (언어 서버 프로토콜)](#lsp) · [MCP (모델 컨텍스트 프로토콜)](#mcp) · [TUI 게이트웨이](07_gateway_interfaces.md#tui-gateway)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="acp"></a>

### ACP (에이전트 클라이언트 프로토콜)

**영문**: Agent Client Protocol · **범주**: 프로토콜·상호운용

에디터(UI)와 에이전트 사이의 표준 프로토콜(Zed, 2025). [MCP](#mcp)가 '에이전트 ↔ 도구'라면 ACP는 'UI ↔ 에이전트' 방향입니다. Hermes의 `acp_adapter/`가 이를 구현해 Zed 등에서 Hermes를 쓸 수 있게 합니다.

**하위 개념**: [ACP 어댑터](12_subsystems.md#acp-adapter)

**관련 용어**: [MCP (모델 컨텍스트 프로토콜)](#mcp) · [JSON-RPC 2.0](#json-rpc)

**이 용어를 참조하는 항목**: [JSON-RPC 2.0](#json-rpc) · [LSP (언어 서버 프로토콜)](#lsp) · [MCP (모델 컨텍스트 프로토콜)](#mcp)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="lsp"></a>

### LSP (언어 서버 프로토콜)

**영문**: Language Server Protocol · **범주**: 프로토콜·상호운용

에디터와 언어 분석기를 분리한 프로토콜(Microsoft, 2016). '[N×M 문제](#nxm-problem)를 표준 프로토콜로 푼다'는 아이디어의 원조로, [MCP](#mcp)·[ACP](#acp)의 정신적 조상입니다.

**관련 용어**: [N×M 통합 문제](#nxm-problem) · [JSON-RPC 2.0](#json-rpc)

**이 용어를 참조하는 항목**: [JSON-RPC 2.0](#json-rpc) · [N×M 통합 문제](#nxm-problem)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="nxm-problem"></a>

### N×M 통합 문제

**영문**: N×M Integration Problem · **범주**: 프로토콜·상호운용

N개의 애플리케이션과 M개의 도구를 연결하려면 N×M개의 개별 통합이 필요해지는 조합 폭발. 표준 프로토콜을 사이에 끼우면 N+M개로 줄어듭니다.

**관련 용어**: [MCP (모델 컨텍스트 프로토콜)](#mcp) · [LSP (언어 서버 프로토콜)](#lsp)

**이 용어를 참조하는 항목**: [LSP (언어 서버 프로토콜)](#lsp) · [MCP (모델 컨텍스트 프로토콜)](#mcp)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="capability-negotiation"></a>

### 기능 협상

**영문**: Capability Negotiation · **범주**: 프로토콜·상호운용

연결 초기화 때 클라이언트와 서버가 서로 지원하는 기능 목록을 교환하는 절차. 버전이 달라도 공통 기능만으로 동작할 수 있게 합니다.

**상위 개념**: [MCP (모델 컨텍스트 프로토콜)](#mcp)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="cdp"></a>

### CDP (크롬 개발자도구 프로토콜)

**영문**: Chrome DevTools Protocol · **범주**: 프로토콜·상호운용

크롬 계열 브라우저를 프로그램으로 조작하는 프로토콜. [WebSocket](#websocket)으로 명령(command)/응답(response)/이벤트(event)를 주고받으며, Puppeteer·Playwright의 기반입니다.

**하위 개념**: [CDP 도메인](#cdp-domain) · [헤드리스 브라우저](#headless)

**관련 용어**: [브라우저 도구](03_tool_system.md#browser-tool) · [WebSocket](#websocket) · [CDP 도메인](#cdp-domain) · [헤드리스 브라우저](#headless)

**이 용어를 참조하는 항목**: [browser_cdp (CDP 탈출구)](03_tool_system.md#browser-cdp-tool) · [브라우저 도구](03_tool_system.md#browser-tool) · [클라우드 브라우저](#cloud-browser) · [WebSocket](#websocket)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="websocket"></a>

### WebSocket

**영문**: WebSocket · **범주**: 프로토콜·상호운용

한 번 연결하면 양방향으로 메시지를 실시간으로 주고받는 통신 프로토콜. 요청-응답만 가능한 HTTP와 달리 서버 쪽 이벤트 통지가 가능해 [CDP](#cdp)가 사용합니다.

**관련 용어**: [CDP (크롬 개발자도구 프로토콜)](#cdp)

**이 용어를 참조하는 항목**: [CDP (크롬 개발자도구 프로토콜)](#cdp)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="cdp-domain"></a>

### CDP 도메인

**영문**: CDP Domains · **범주**: 프로토콜·상호운용

CDP 명령의 대분류(Page, DOM, Network, Runtime, Input 등). 명령 이름은 `도메인.메서드` 형식입니다(예: `Page.navigate`).

**상위 개념**: [CDP (크롬 개발자도구 프로토콜)](#cdp)

**이 용어를 참조하는 항목**: [CDP (크롬 개발자도구 프로토콜)](#cdp)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="headless"></a>

### 헤드리스 브라우저

**영문**: Headless Browser · **범주**: 프로토콜·상호운용

화면 표시 없이 백그라운드로 실행되는 브라우저. 서버 환경 자동화의 기본 형태입니다.

**상위 개념**: [CDP (크롬 개발자도구 프로토콜)](#cdp)

**관련 용어**: [클라우드 브라우저](#cloud-browser)

**이 용어를 참조하는 항목**: [CDP (크롬 개발자도구 프로토콜)](#cdp)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="accessibility-tree"></a>

### 접근성 트리

**영문**: Accessibility Tree · **범주**: 프로토콜·상호운용

스크린리더용으로 브라우저가 만드는 페이지의 의미적 구조(역할·이름·상태). 원시 DOM보다 훨씬 작고 의미가 명확해, 에이전트가 페이지를 '읽는' 형식(ariaSnapshot)으로 적합합니다.

**상위 개념**: [브라우저 도구](03_tool_system.md#browser-tool)

**이 용어를 참조하는 항목**: [브라우저 도구](03_tool_system.md#browser-tool)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="cloud-browser"></a>

### 클라우드 브라우저

**영문**: Cloud Browser · **범주**: 프로토콜·상호운용

원격 서비스(Browserbase 등)에서 실행되는 브라우저를 [CDP](#cdp) URL로 연결해 쓰는 방식. 로컬에 크로미움을 설치할 수 없는 환경을 지원합니다.

**상위 개념**: [브라우저 도구](03_tool_system.md#browser-tool)

**관련 용어**: [CDP (크롬 개발자도구 프로토콜)](#cdp)

**이 용어를 참조하는 항목**: [브라우저 도구](03_tool_system.md#browser-tool) · [헤드리스 브라우저](#headless)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---
