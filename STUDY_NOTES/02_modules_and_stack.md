# 02. 사용/활용 모듈 및 기술 스택 (1-B)

## 이 문서에서 다루는 큰 맥락

Hermes가 "무엇으로 만들어졌는가"를 봅니다. `pyproject.toml`(파이썬 프로젝트의
표준 설정 파일)에 선언된 의존성(라이브러리)들을 **역할별로 분류**하고, 그 목록을
관통하는 두 가지 독특한 설계 원칙 — **정확 버전 고정(exact pinning)** 과
**지연 설치(lazy deps)** — 를 라인 단위 근거와 함께 이해합니다.

### 소목차
- [1. 큰 그림: 왜 의존성 목록이 이렇게 생겼나](#1-큰-그림-왜-의존성-목록이-이렇게-생겼나)
- [2. 코어 의존성 역할별 분류](#2-코어-의존성-역할별-분류)
- [3. 선택적 의존성(extras)](#3-선택적-의존성extras)
- [4. 설계 원칙 ① 정확 버전 고정(exact pinning)](#4-설계-원칙-①-정확-버전-고정exact-pinning)
- [5. 설계 원칙 ② 지연 설치(lazy deps)](#5-설계-원칙-②-지연-설치lazy-deps)
- [6. 프론트엔드/보조 언어 스택](#6-프론트엔드보조-언어-스택)

---

## 들어가기 전에 — 필요한 배경과 비유

**필요한 배경**: "다른 사람이 만든 코드(라이브러리)를 가져다 쓴다"는 개념만 알면 됩니다.

**비유**: 요리사가 모든 재료를 직접 기르지 않듯, 프로그램도 필요한 기능(HTTP 통신,
화면 출력 등)을 남이 만든 **라이브러리(재료)**로 조달합니다. `pyproject.toml`은 이
프로젝트의 **장보기 목록**입니다. 이 문서는 그 목록을 한 줄씩 읽으며 "왜 이 재료를,
왜 이 버전으로 골랐는가"를 이해하는 문서입니다.

특히 두 가지 설계 원칙이 핵심입니다:
- **정확 고정(exact pinning)** = 재료의 산지·등급까지 고정해 매번 완전히 같은 맛을 보장.
- **지연 설치(lazy deps)** = 자주 안 쓰는 재료는 미리 사두지 않고 주문이 들어오면 그때 구매.

**학습 목표**: 의존성 목록을 역할별(LLM SDK/HTTP/CLI/검증/스케줄링 등)로 분류할 수 있고,
두 원칙의 장단점을 설명할 수 있게 됩니다.

---

## 1. 큰 그림: 왜 의존성 목록이 이렇게 생겼나

`pyproject.toml`의 `dependencies` 목록에는 유독 긴 주석이 붙어 있습니다. 이는
Hermes가 **공급망 보안(supply-chain security)** 을 매우 진지하게 다루기 때문입니다.
"공급망 공격"이란 내가 쓰는 라이브러리(또는 그 라이브러리가 쓰는 라이브러리)에
악성 코드가 섞여 배포되는 공격입니다. Hermes는 이를 막기 위해:

- **모든 직접 의존성을 정확한 버전(`==X.Y.Z`)으로 고정**하고,
- **모든 세션이 쓰는 게 아닌 무거운/선택적 패키지는 "지연 설치"** 로 분리합니다.

핵심 규칙(19-39행 주석 요약):
> "Scope rule: only packages used by EVERY hermes session belong here."
> (`pyproject.toml`)

즉 **모든 세션이 반드시 쓰는 것만** 코어 `dependencies`에 두고, provider별/기능별
패키지는 `optional-dependencies`(extras)와 `tools/lazy_deps.py`로 뺍니다.

---

## 2. 코어 의존성 역할별 분류

[`pyproject.toml` 19-140행](../pyproject.toml#L19-L140)
(`pyproject.toml` 19-140행) 기준으로 역할별로 묶으면:

| 역할 | 패키지(고정 버전) | 무엇을 위한 것인가 |
|------|------------------|------------------|
| **LLM SDK / API** | `openai==2.24.0` | OpenAI 호환 API 클라이언트. Hermes의 기본 모델 호출 경로 |
| **HTTP / 네트워크** | `httpx[socks]==0.28.1`, `requests==2.33.0`, `urllib3>=2.7.0,<3`, `certifi==2026.5.20`, `websockets==15.0.1` | API/웹 호출, 프록시, TLS 인증서, 브라우저 CDP 통신 |
| **데이터 검증/직렬화** | `pydantic==2.13.4`, `pyyaml==6.0.3`, `ruamel.yaml==0.18.17`, `jinja2==3.1.6`, `Markdown==3.10.2` | 설정/스키마 검증, YAML 파싱, 템플릿, 마크다운→HTML |
| **CLI / 대화형 UI** | `fire==0.7.1`, `rich==14.3.3`, `prompt_toolkit==3.0.52` | 명령 파싱, 터미널 출력 서식, 멀티라인 입력 |
| **재시도/신뢰성** | `tenacity==9.1.4` | API 실패 시 백오프 재시도 |
| **스케줄링(cron)** | `croniter==6.0.0` | cron/interval 스케줄 계산 (58-59행: 이제 코어 의존성) |
| **웹서버** | `fastapi>=0.104.0,<1`, `uvicorn[standard]>=0.24.0,<1`, `python-multipart>=0.0.9,<1` | 대시보드/웹훅 서버, 멀티파트 업로드 |
| **프로세스/PTY 관리** | `psutil==7.2.2`, `ptyprocess`(POSIX), `pywinpty`(Windows), `pywin32`(Windows) | PID 관리, 가상 터미널(pseudo-terminal) |
| **보안/암호** | `PyJWT[crypto]==2.13.0`, `cryptography==46.0.7` | GitHub App JWT, WeCom/Weixin 암호화 |
| **이미지 처리** | `Pillow==12.2.0` | 비전 도구용 이미지 리사이즈(과대 이미지가 세션을 못 쓰게 만드는 것 방지) |
| **플랫폼 보정** | `packaging==26.0`, `tzdata`(Windows), `concurrent-log-handler`(Windows), `pathspec==1.1.1` | 버전 비교, Windows 타임존/로그 회전, .gitignore 매칭 |

> **왜 Pillow가 코어인가 (설계 트레이드오프의 예):** 원래는 선택적이었지만
> (186-191행), 과대 이미지 축소 경로가 기본 비전 경로에 있고, 세션 중간에 지연
> 설치하면 prompt_toolkit 하에서 CLI가 교착(deadlock)되는 버그(#40490)가 있어서
> **코어로 승격**했습니다. "언제 코어로 올리고 언제 지연 설치로 남기는가"의 판단이
> 실제 버그 경험에 기반한다는 점을 보여줍니다.

---

## 3. 선택적 의존성(extras)

[`pyproject.toml` 142-302행](../pyproject.toml#L142-L302)
`[project.optional-dependencies]`(142행~)는 특정 기능을 켤 때만 필요한 패키지들을
이름표(extra) 아래 묶습니다. 예:

- `anthropic` — 네이티브 Anthropic provider (`anthropic==0.87.0`)
- `exa`/`firecrawl`/`parallel-web` — 웹 검색 백엔드
- `fal` — 이미지 생성 백엔드
- `edge-tts`/`tts-premium`/`voice` — 음성(TTS/STT)
- `messaging`/`slack`/`matrix`/`teams`/`dingtalk`/`feishu` — 메시징 플랫폼
- `modal`/`daytona` — 서버리스 실행 환경 ([용어사전](../dict/09_execution_infra.md#execution-environment))
- `mcp`/`acp` — MCP ([용어사전](../dict/08_protocols.md#mcp))/ACP ([용어사전](../dict/08_protocols.md#acp)) 프로토콜
- `bedrock`/`vertex`/`azure-identity` — 클라우드 provider 인증
- `web` — 대시보드 서버
- `dev` — 개발 도구(`pytest`, `ruff`, `ty` 등)

`all`(270행~)과 `termux-all`(236행~)은 "가능한 많이 설치" 프로파일이지만,
**정책적으로 지연 설치 가능한 것은 제외**합니다(주석 271-291행). 예를 들어
matrix의 `python-olm`은 Windows/최신 macOS에 휠이 없어 `[all]`에 넣으면
`uv sync --locked`가 소스 빌드로 실패하므로 뺐습니다.

---

## 4. 설계 원칙 ① 정확 버전 고정(exact pinning)

[`pyproject.toml` 20-39행](../pyproject.toml#L20-L39)

핵심 근거 주석(20-39행):
> "Exact pins mean the only way a new package version reaches a user is via an
> intentional update on our end..." — "이 방식은 2026-05-12 Mini Shai-Hulud 웜이
> PyPI의 mistralai 2.4.6을 감염시킨 사건 이후 강화되었다. 만약 `mistralai>=2.3.0,<3`
> 같은 범위였다면, 격리(quarantine) 전 몇 시간 동안 모든 설치가 그 악성 릴리스를
> 끌어왔을 것이다."

**쉽게 말해:** `==2.24.0`처럼 정확히 못 박으면, PyPI에 새 버전이 올라와도 우리가
직접 이 파일을 고치고 `uv lock`을 다시 돌리기 전까지는 아무도 그 새 버전을 받지
않습니다. 그래서 악성/깨진 신규 릴리스의 **피해 범위(blast radius)** 가 0에
가깝습니다. 대신 보안 패치를 받으려면 사람이 직접 버전을 올려야 하는 유지보수
비용을 감수합니다(트레이드오프).

버전을 올릴 때 규칙(30-32행): "버전을 올리면 **반드시** `uv lock`으로
`uv.lock`도 다시 생성해 전이 의존성 해석을 일관되게 유지하라."

---

## 5. 설계 원칙 ② 지연 설치(lazy deps)

무거운/선택적 백엔드는 처음 쓰는 순간 설치합니다. 담당 모듈은
`tools/lazy_deps.py`입니다.
[`tools/lazy_deps.py` 1-66행](../tools/lazy_deps.py#L1-L66)

모듈 최상단 docstring(1-66행)이 이유와 보안 모델을 아주 잘 설명합니다:

- **왜 하는가 (1-16행):** 모든 extra를 `[all]`로 한꺼번에 미리 설치하면 (1) 하나의
  전이 의존성이 PyPI에서 사라지면 `[all]` 해석 전체가 실패하고, (2) 한 provider만
  쓰는 사용자도 수백 개의 안 쓸 패키지를 받는 **비대(bloat)** 문제가 생깁니다.
- **어떻게 (18-24행):** 백엔드는 첫 import 경로 맨 위에서 `ensure("feature.name")`을
  호출합니다. 없으면 `security.allow_lazy_installs`(기본 true)를 확인하고 venv
  범위 pip 설치를 실행합니다. 꺼져 있으면 `FeatureUnavailable`을 던지며 안내합니다.
- **보안 모델 (25-58행):**
  - venv 범위 설치 — 시스템 파이썬은 절대 건드리지 않음.
  - 봉인(immutable) 이미지에서는 쓰기 가능 볼륨으로 리다이렉트하되, 그 경로를
    `sys.path` **맨 끝**에 붙여 코어 site-packages가 항상 이기게 함(지연 설치
    패키지가 코어를 덮어써 Hermes를 망가뜨릴 수 없다는 **구조적 보장**).
  - **PyPI 패키지 이름만** 허용 — `--index-url`, `git+https://`, 파일 경로 등
    설정 하이재킹 통로를 막음.
  - **허용목록(allowlist):** `LAZY_DEPS`에 있는 스펙만 설치 가능.
  - 오프라인/실패 시 조용한 재시도 없이 실제 pip stderr를 그대로 노출.

> **연결:** `pyproject.toml` extras의 정확 버전 고정과 `LAZY_DEPS`의 버전 고정은
> 서로 일치해야 하며, 이는 `tests/test_project_metadata.py`가 강제합니다
> (`pyproject.toml` 179-185행 주석). 즉 "정확 고정"과 "지연 설치"는 별개가 아니라
> **한 세트의 공급망 방어 전략**입니다.

---

## 6. 프론트엔드/보조 언어 스택

Python 외 스택은 주로 프론트엔드입니다(자세한 내용 [10](10_subsystems.md)).

- `ui-tui/` — **Ink**(터미널에서 React를 쓰게 해주는 라이브러리) 기반 TUI ([용어사전](../dict/07_gateway_interfaces.md#tui)).
  `package.json`, `tsconfig*.json`, `vitest.config.ts`로 구성.
- `web/` — **Vite + React** 기반 브라우저 대시보드.
- `apps/desktop/` — **Electron** 데스크톱 앱 ([용어사전](../dict/07_gateway_interfaces.md#desktop-app)).
- 루트 `package.json`, `eslint.config.shared.mjs` — JS/TS 워크스페이스 공통 설정.
- Nix ([용어사전](../dict/09_execution_infra.md#nix))(`flake.nix`) — 재현 가능한 빌드/개발 환경.

---

## 정리 — 스스로 점검 질문

**핵심 요약**
- 코어 의존성은 적게 유지하고(LLM SDK, HTTP, CLI/UI, 검증, 스케줄링, 웹서버, 프로세스 관리 등 역할별로 분류 가능), 나머지는 extras로 분리한다.
- **exact pinning**: 모든 버전을 `==`로 고정 → 재현성↑, 대신 업그레이드는 의도적으로만.
- **lazy deps**: 무거운 선택 기능의 라이브러리는 첫 사용 시점에 설치 → 기본 설치가 가뱕고 빠름.
- TUI(TypeScript/Ink)·데스크톱(Electron)·웹(Vite/React)·Nix는 보조 스택이다.

**점검 질문**
1. 의존성을 버전 범위(`>=`)가 아니라 `==`로 고정하면 무엇이 좋고 무엇이 불편해지는가?
2. 지연 설치가 없다면 사용자 경험은 어떻게 달라질까?
3. LLM SDK가 하나가 아닌 이유는? (힌트: provider 독립성)
4. 새 기능을 추가할 때 의존성을 코어에 넣을지 extras로 분리할지 판단 기준은 무엇일까?

다음 문서부터는 실제 코드 진입점으로 내려갑니다.
→ [03_entrypoints.md](03_entrypoints.md)
