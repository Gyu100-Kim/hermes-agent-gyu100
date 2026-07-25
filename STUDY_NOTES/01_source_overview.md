# 01. 전체 소스코드 구조 개요 (1-A)

## 이 문서에서 다루는 큰 맥락

이 문서는 "숲"에 해당합니다. 개별 코드 한 줄을 보기 전에, **리포지토리 전체가
어떤 조각들로 이루어져 있는지** 지도를 그립니다. 구체적으로:

1. 최상위 디렉토리 지도 (무엇이 어디에 있는가)
2. "최상위 단일 파일 모듈" vs "패키지(디렉토리)"의 구분과 그 이유
3. 진입점(entry point)들이 무엇이고 어디서 시작하는가
4. 사용 언어(Python 3.11~3.13 중심, 보조로 JavaScript/TypeScript/Nix ([용어사전](../dict/09_execution_infra.md#nix)))

### 소목차
- [1. 한눈에 보는 저장소](#1-한눈에-보는-저장소)
- [2. 최상위 디렉토리 지도](#2-최상위-디렉토리-지도)
- [3. 단일 파일 모듈 vs 패키지](#3-단일-파일-모듈-vs-패키지)
- [4. 진입점(entry points)](#4-진입점entry-points)
- [5. 사용 언어](#5-사용-언어)
- [6. 코어와 가장자리 — 설계 철학](#6-코어와-가장자리--설계-철학)

---

## 1. 한눈에 보는 저장소

Hermes Agent는 **하나의 에이전트 코어**를 여러 인터페이스(CLI, 메시징 게이트웨이 ([용어사전](../dict/07_gateway_interfaces.md#gateway)),
TUI ([용어사전](../dict/07_gateway_interfaces.md#tui)), 데스크톱 앱 ([용어사전](../dict/07_gateway_interfaces.md#desktop-app)), ACP ([용어사전](../dict/08_protocols.md#acp)))에서 공유하는 구조입니다. `AGENTS.md`(개발 가이드) 첫머리는
이를 이렇게 요약합니다:

> "Hermes is a personal AI agent that runs the same agent core across a CLI, a
> messaging gateway ..., a TUI, and an Electron desktop app."
> (`AGENTS.md`)

즉 **"코어는 한 개, 얼굴은 여러 개"** 입니다. 이 관점을 기억하면 디렉토리 지도가
훨씬 잘 읽힙니다: 대부분의 디렉토리는 (a) 코어 로직, (b) 코어를 감싸는 인터페이스,
(c) 코어를 확장하는 도구/플러그인/스킬 중 하나에 속합니다.

---

## 2. 최상위 디렉토리 지도

리포지토리 루트(`hermes-agent-gyu100/`)의 주요 항목입니다.

### 2-1. 코어 로직 (에이전트의 두뇌와 심장)

| 경로 | 역할 | 관련 학습문서 |
|------|------|--------------|
| `run_agent.py` | `AIAgent` 클래스 — 에이전트 코어. 약 6,900줄 | [04](04_agent_loop.md) |
| `agent/` | 에이전트 내부(대화 루프, 프롬프트, 압축, 메모리, provider 어댑터, 학습 등) | [04](04_agent_loop.md),[07](07_prompt_context.md),[09](09_self_improvement.md) |
| `model_tools.py` | 도구 정의 조립·도구 호출 디스패치. 약 1,400줄 | [05](05_tools.md) |
| `toolsets.py` | 도구 묶음(toolset) 정의, `_HERMES_CORE_TOOLS` 목록 | [05](05_tools.md) |
| `hermes_state.py` | `SessionDB` — SQLite 세션 저장소(FTS5 검색). 약 9,900줄 | [06](06_state.md) |
| `hermes_constants.py` | 프로파일 인지 경로(`get_hermes_home()` 등) | [03](03_entrypoints.md) |
| `hermes_logging.py` | 로깅 설정(agent.log/errors.log/gateway.log) | - |
| `hermes_bootstrap.py` | 가장 먼저 import되는 부트스트랩(Windows UTF-8 stdio 등) | [03](03_entrypoints.md) |

### 2-2. 인터페이스 / 진입점 (여러 개의 "얼굴")

| 경로 | 역할 | 관련 학습문서 |
|------|------|--------------|
| `cli.py` | `HermesCLI` — 대화형 CLI 오케스트레이터. 약 16,600줄 | [03](03_entrypoints.md) |
| `hermes_cli/` | CLI 하위 명령, 설정 마법사, 인증, 플러그인 로더, 스킨 엔진 | [03](03_entrypoints.md) |
| `gateway/` | 메시징 게이트웨이(`run.py` + `session.py` + `platforms/`) | [08](08_gateway.md) |
| `tui_gateway/` | TUI용 Python JSON-RPC 백엔드 | [10](10_subsystems.md) |
| `ui-tui/` | Ink(React) 터미널 UI (`hermes --tui`) | [10](10_subsystems.md) |
| `apps/` | 데스크톱(Electron) 앱, 부트스트랩 인스톨러, 공유 코드 | [10](10_subsystems.md) |
| `web/` | 브라우저용 대시보드 프론트엔드(Vite/React) | [10](10_subsystems.md) |
| `acp_adapter/` | ACP(Agent Client Protocol) 서버 어댑터 | [10](10_subsystems.md) |

### 2-3. 확장 지점 (도구/스킬/플러그인 — 가장자리)

| 경로 | 역할 | 관련 학습문서 |
|------|------|--------------|
| `tools/` | 도구 구현. `registry.py`가 자동 발견. `environments/`에 터미널 백엔드 | [05](05_tools.md) |
| `skills/` | 기본 번들 스킬(각 `SKILL.md`) | [09](09_self_improvement.md) |
| `optional-skills/` | 기본 비활성인 무거운/틈새 스킬 | [09](09_self_improvement.md) |
| `optional-mcps/` | 선택적 MCP 서버 설정 | [05](05_tools.md) |
| `plugins/` | 플러그인 시스템(메모리/모델 provider/observability/kanban 등) | [10](10_subsystems.md) |
| `providers/` | 모델 provider 관련 코드 | [04](04_agent_loop.md) |
| `cron/` | 자연어 작업 스케줄러 | [10](10_subsystems.md) |

### 2-4. 그 외 (연구/문서/빌드/배포)

| 경로 | 역할 |
|------|------|
| `batch_runner.py`, `mini_swe_runner.py`, `trajectory_compressor.py` | 배치 궤적(trajectory) 생성/압축 — 연구용 |
| `docs/`, `website/` | 문서 (Docusaurus 사이트 등) |
| `docker/`, `Dockerfile`, `docker-compose.yml` | 컨테이너 배포 |
| `nix/`, `flake.nix`, `flake.lock` | Nix 재현 가능 빌드 |
| `native/` | 네이티브 보조 코드 |
| `tests/`, `tests-js/` | Python/JS 테스트 |
| `locales/`, `assets/`, `infographic/`, `infograficos/` | 번역/자산/인포그래픽 |
| `scripts/`, `setup-hermes.sh`, `setup.py` | 설치/실행 스크립트 |

> **왜 이렇게 나눴는가 (설계 의도):** `AGENTS.md`의 "Footprint Ladder ([용어사전](../dict/11_design_principles.md#footprint-ladder))"는 새 기능을
> 넣을 때 "코어 도구 ([용어사전](../dict/03_tool_system.md#core-tools))"는 최후의 수단이고, 가능하면 CLI 명령+스킬 → 서비스 게이트
> 도구 → 플러그인 → MCP 서버 ([용어사전](../dict/08_protocols.md#mcp-server)) 순으로 **가장자리에** 넣으라고 규정합니다. 그래서
> 코어(`run_agent.py`, `agent/`)는 좁게 유지하고, 기능 대부분은
> `tools/`·`skills/`·`plugins/`에 쌓입니다. 이 원칙이 디렉토리 구조에 그대로
> 드러납니다.

---

## 3. 단일 파일 모듈 vs 패키지

Python에서 **모듈(module)** 은 `.py` 파일 하나, **패키지(package)** 는 `__init__.py`를
포함한 디렉토리입니다. Hermes는 둘을 섞어 씁니다.

- **최상위 단일 파일 모듈**: 루트에 바로 있는 큰 `.py` 파일들
  (`run_agent.py`, `model_tools.py`, `cli.py`, `hermes_state.py`,
  `toolsets.py`, `hermes_constants.py` 등).
- **패키지**: `agent/`, `tools/`, `hermes_cli/`, `gateway/`, `cron/`,
  `plugins/`, `providers/`, `acp_adapter/`, `tui_gateway/` 등.

이 구분은 그냥 관례가 아니라 **빌드 설정에 명시**되어 있습니다.
[`pyproject.toml` 313-319행](../pyproject.toml#L313-L319)

```toml
[tool.setuptools]
# Top-level single-file modules (not packages)...
py-modules = ["run_agent", "model_tools", "toolsets", "batch_runner",
              "trajectory_compressor", "toolset_distributions", "cli",
              "hermes_bootstrap", "hermes_constants", "hermes_state",
              "hermes_time", "hermes_logging", "utils", "mcp_serve"]

[tool.setuptools.packages.find]
include = ["agent", "agent.*", "tools", "tools.*", "hermes_cli", ...]
```
(`pyproject.toml` 313-319행)

- `py-modules`: 위 목록에 든 파일들은 "패키지가 아닌 단일 파일 모듈"임을 명시합니다.
  주석(314-316행)은 이 선언이 없으면 uv2nix의 봉인된 가상환경에서
  `hermes_constants`, `run_agent` 등이 사라진다고 설명합니다 — 즉 **패키징이
  실제로 깨지지 않게 하려는 실용적 이유**입니다.
- `packages.find.include`: `agent`, `tools`, `hermes_cli`, `gateway`,
  `tui_gateway`, `cron`, `acp_adapter`, `plugins`, `providers` 를 패키지로
  포함합니다.

---

## 4. 진입점(entry points)

"진입점"이란 사용자가 프로그램을 실행했을 때 **가장 먼저 실행되는 함수**입니다.
`pyproject.toml`의 `[project.scripts]`가 이를 정의합니다.
[`pyproject.toml` 308-311행](../pyproject.toml#L308-L311)

```toml
[project.scripts]
hermes = "hermes_cli.main:main"        # `hermes ...` 명령
hermes-agent = "run_agent:main"        # 에이전트 러너 직접 실행
hermes-acp = "acp_adapter.entry:main"  # 에디터용 ACP 서버
```
(`pyproject.toml` 308-311행)

- `hermes` → `hermes_cli/main.py`의 `main()` (가장 흔한 진입점)
- `hermes-agent` → `run_agent.py`의 `main()`
- `hermes-acp` → `acp_adapter/entry.py`의 `main()`

자세한 부트스트랩/디스패치 ([용어사전](../dict/03_tool_system.md#dispatch)) 흐름은 [03_entrypoints.md](03_entrypoints.md)에서
라인 단위로 봅니다.

---

## 5. 사용 언어

- **Python 3.11 ~ 3.13** (주 언어). 상한선이 중요합니다:
  [`pyproject.toml` 15행](../pyproject.toml#L15)
  ```toml
  requires-python = ">=3.11,<3.14"
  ```
  주석(8-14행)에 따르면 상한(`<3.14`)은 단순 장식이 아니라 **load-bearing(꼭
  필요한)** 제약입니다. 3.14에서는 pydantic-core 같은 Rust 기반 의존성의 cp314
  휠(wheel)이 아직 없어 소스 빌드로 떨어지며 실패하기 때문입니다.
- **JavaScript / TypeScript** (보조): `ui-tui/`(Ink+React TUI), `web/`(Vite+React
  대시보드), `apps/desktop/`(Electron), `tests-js/`. 루트에 `package.json`,
  `package-lock.json`, `eslint.config.shared.mjs`가 있습니다.
- **Nix** (보조): `flake.nix`, `flake.lock`, `nix/` — 재현 가능한(reproducible)
  개발/빌드 환경을 위한 설정.
- 그 외 설정/데이터: YAML(`config.yaml`, `cli-config.yaml.example` 등), Markdown
  (문서·스킬), Dockerfile.

---

## 6. 코어와 가장자리 — 설계 철학

이 구조를 지배하는 두 가지 원칙(`AGENTS.md`)을 이해하면 앞으로의 모든 문서가
잘 읽힙니다.

1. **"대화별 프롬프트 캐싱은 신성하다(Per-conversation prompt caching is sacred)."**
   장시간 대화는 매 턴 캐시된 프리픽스를 재사용합니다. 과거 컨텍스트를 바꾸거나
   시스템 프롬프트를 중간에 재구성하면 이 캐시가 무효화되어 비용이 폭증합니다.
   그래서 시스템 프롬프트는 세션 동안 바이트 단위로 고정되며, 유일한 예외가
   **컨텍스트 압축 ([용어사전](../dict/04_prompt_context.md#context-compression))**입니다. → [07](07_prompt_context.md)
2. **"코어는 좁은 허리, 기능은 가장자리(narrow waist)."** 모든 코어 도구는 매
   API 호출마다 전송되므로, 새 코어 도구를 추가하는 기준이 매우 높습니다. 대부분의
   새 기능은 CLI 명령+스킬, 서비스 게이트 도구, 플러그인으로 들어옵니다.
   → [05](05_tools.md), [10](10_subsystems.md)

다음 문서에서는 이 코어를 실제로 구동하는 **의존성/기술 스택**을 살펴봅니다.
→ [02_modules_and_stack.md](02_modules_and_stack.md)
