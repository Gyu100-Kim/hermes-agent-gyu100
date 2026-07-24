# 10. 부가 서브시스템 — cron, plugins, ACP, 프론트엔드 (1-C-8)

## 이 문서에서 다루는 큰 맥락

지금까지 본 코어·도구·상태·게이트웨이·자기개선 외에도, Hermes를 "완성된 제품"으로
만드는 주변 서브시스템들이 있습니다. 이 문서는 다섯 가지를 개요 수준으로 정리합니다:

1. **cron** (`cron/`) — 자연어로 예약하는 작업 스케줄러
2. **plugins** (`plugins/`) — 코어를 건드리지 않는 확장 시스템
3. **ACP** (`acp_adapter/`) — 코드 에디터 통합
4. **프론트엔드** (`ui-tui/`, `apps/desktop/`, `web/`) — TUI·데스크톱·웹 대시보드

### 소목차
- [1. cron — 예약 작업 스케줄러](#1-cron--예약-작업-스케줄러)
- [2. plugins — 가장자리 확장](#2-plugins--가장자리-확장)
- [3. ACP — 에디터에 에이전트 붙이기](#3-acp--에디터에-에이전트-붙이기)
- [4. 프론트엔드: TUI / 데스크톱 / 웹](#4-프론트엔드-tui--데스크톱--웹)

---

## 1. cron — 예약 작업 스케줄러

"매일 아침 9시에 뉴스 요약해줘" 같은 반복/예약 작업을 담당합니다.

### 1-1. 스케줄러
[`cron/scheduler.py` 1-9행](../cron/scheduler.py#L1-L9)
```
Cron job scheduler - executes due jobs.
Provides tick() which checks for due jobs and runs them. The gateway
calls this every 60 seconds from a background thread.
Uses a file-based lock (~/.hermes/cron/.tick.lock) so only one tick
runs at a time if multiple processes overlap.
```
(`cron/scheduler.py` 1-9행)

- **tick() 방식**(4-5행): 별도 데몬이 아니라, 게이트웨이가 백그라운드 스레드에서
  60초마다 `tick()`을 호출해 "지금 실행할 때가 된 작업"을 찾아 돌립니다.
- **크로스 프로세스 락**(7-8행): 여러 프로세스가 겹쳐도 한 번에 하나의 tick만 돌도록
  파일 락(`~/.hermes/cron/.tick.lock`)을 사용. Unix는 `fcntl`, Windows는 `msvcrt`로
  분기(25-33행) — 크로스 플랫폼 배려.
- `croniter`(코어 의존성, [02](02_modules_and_stack.md))로 다음 실행 시각을 계산.

### 1-2. 작업 저장과 출력
[`cron/jobs.py` 1-6행](../cron/jobs.py#L1-L6)
(`cron/jobs.py` 1-6행) — 작업은 `~/.hermes/cron/jobs.json`, 출력은
`~/.hermes/cron/output/{job_id}/{timestamp}.md`에 저장. 여기도 크로스 프로세스
파일 락(22-33행)으로 `jobs.json`의 임계 구역을 보호합니다.

### 1-3. 실행 원장(executions)
[`cron/executions.py` 1-6행](../cron/executions.py#L1-L6)
(`cron/executions.py` 1-6행) — 각 실행 시도의 **내구성 있는 감사 원장**입니다.
"재시도 큐가 아니라 알려진 사실의 기록"이며, 종료 상태(completed/failed/unknown)는
불변입니다. 여기서도 [06](06_state.md)의 `apply_wal_with_fallback`를 재사용(29행)해
동일한 WAL/DELETE 폴백을 얻습니다.

> **왜 CLI + 스킬로 노출하나 (설계):** cron 관리는 `hermes cron` 명령 + 스킬로
> 에이전트가 다룹니다([05](05_tools.md)의 Footprint Ladder 2번 rung). 결과 전달은
> [08](08_gateway.md)의 `delivery.py`가 담당합니다.

---

## 2. plugins — 가장자리 확장

`plugins/`는 "코어를 건드리지 않고 능력을 더하는" 공식 확장 지점입니다.
`AGENTS.md`가 정의한 카테고리별 디렉토리가 있습니다:

- `plugins/memory/` — 메모리 provider(honcho, mem0, supermemory, ...) → [09](09_self_improvement.md)
- `plugins/model-providers/` — 추론 백엔드(openrouter, anthropic, gmi, ...)
- `plugins/context_engine/` — 컨텍스트 엔진 대체 구현 → [07](07_prompt_context.md)
- `plugins/kanban/` — 멀티 에이전트 보드 디스패처 + 워커
- `plugins/observability/` — 지표/트레이스/로그
- `plugins/image_gen/`, `plugins/platforms/` 등

핵심 원칙(`AGENTS.md`):
- 플러그인은 자기 디렉토리에서 살고, 코어가 제공하는 **ABC/훅** 안에서만 동작합니다.
  더 필요하면 "일반 플러그인 표면을 넓히되, 코어에 특례를 만들지 말라."
- **제3자 제품/남의 프로젝트**(관측 백엔드, 벤더 SaaS, 분석 대시보드)는 이 저장소의
  `plugins/`에 들어오지 않습니다. 별도 플러그인 저장소로 배포해 사용자가
  `~/.hermes/plugins/`에 설치하게 합니다 — 빠르게 바뀌는 코어에 대해 우리가 유지보수
  부담을 지지 않기 위한 **결합·유지보수 결정**입니다.

플랫폼 플러그인의 자기등록 메커니즘은 [08](08_gateway.md)의 `platform_registry.py`
에서, 도구의 자기등록은 [05](05_tools.md)의 `tools/registry.py`에서 봤습니다 — 같은
"자기등록" 철학이 전반에 흐릅니다.

---

## 3. ACP — 에디터에 에이전트 붙이기

**ACP(Agent Client Protocol)** 는 코드 에디터 같은 클라이언트가 에이전트와 표준
방식으로 통신하는 프로토콜입니다(배경: [tech_background/05_mcp_and_acp.md](tech_background/05_mcp_and_acp.md)).
진입점은 `acp_adapter/entry.py`.
[`acp_adapter/entry.py` 1-14행](../acp_adapter/entry.py#L1-L14)
(`acp_adapter/entry.py` 1-14행)

- `~/.hermes/.env`에서 환경변수를 로드하고, **로깅을 stderr로** 보냅니다 — stdout은
  ACP의 JSON-RPC 전송 통로로 예약되기 때문(3-5행). 이 분리를 어기면 프로토콜이
  깨집니다.
- 실행: `python -m acp_adapter.entry` 또는 `hermes acp` 또는 `hermes-acp`(7-13행).
- 첫 import가 `hermes_bootstrap`(18-30행)인 것도 CLI/게이트웨이와 동일한 이유.

**살아있음 프로브(liveness probe) 잡음 억제**(40-69행)는 실무의 섬세함을 보여줍니다:
클라이언트가 `ping`/`health` 같은 비표준 메서드를 주기적으로 보내면 ACP 라우터는
올바르게 JSON-RPC `-32601`(method not found)로 답하지만, 그 과정에서 슈퍼바이저가
매번 traceback을 stderr에 찍습니다. `_BenignProbeMethodFilter`(51행~)는 **프로토콜
응답은 그대로 두고**, 이 양성(benign) 케이스의 stderr 잡음만 걸러냅니다.

---

## 4. 프론트엔드: TUI / 데스크톱 / 웹

Hermes의 "얼굴들" 중 GUI 계열입니다(Python이 아닌 JS/TS 스택, [02](02_modules_and_stack.md)).

- **TUI (`ui-tui/`)** — **Ink**(React를 터미널에서 렌더링)로 만든 터미널 UI.
  `hermes --tui`로 실행. 백엔드는 `tui_gateway/`(파이썬 JSON-RPC)가 담당해, 화면
  (TS)과 에이전트(Python)를 분리합니다.
- **데스크톱 (`apps/desktop/`)** — **Electron** 앱. 내부적으로 게이트웨이/TUI 백엔드에
  연결합니다([00](00_index.md)의 아키텍처 다이어그램 참고: `DESK --> GW`).
- **웹 대시보드 (`web/`)** — **Vite + React**. 세션·과금·학습 그래프 등을 브라우저에서
  보여줍니다. 서버는 코어 의존성의 FastAPI/uvicorn([02](02_modules_and_stack.md)).

> **공통 패턴:** 프론트엔드는 표시(display)만 담당하고, 실제 판단은 항상 동일한
> 에이전트 코어가 합니다. 이는 [04](04_agent_loop.md)에서 본 `*_callback` 인자들로
> 실현됩니다 — 코어가 진행 상황을 콜백으로 흘려보내면 각 프론트엔드가 자기 방식대로
> 그립니다. "코어 하나, 얼굴 여럿"의 최종 형태입니다.

---

## 5. 실행 환경 추상화와 연구용 러너

마지막으로, [06](06_state.md)의 세션 저장에는 포함되지 않는(파일 상단 docstring이
명시) 별도 시스템 두 가지를 짚습니다.

### 5-1. 실행 환경 추상화 (`tools/environments/`)

에이전트의 `terminal` 도구가 실제 명령을 실행하는 **백엔드**들입니다. 공통 ABC
[`tools/environments/base.py`](../tools/environments/base.py)를 상속해
local / docker / ssh / modal / daytona / singularity 백엔드가 구현되어 있으며,
어떤 백엔드든 에이전트 코어에는 동일하게 보입니다. 격리 개념과 각 백엔드의
트레이드오프는 [tech_background/09_execution_environments.md](tech_background/09_execution_environments.md)
에서 다룹니다.

### 5-2. 연구용 배치 러너

루트의 세 파일은 대화형 사용이 아니라 **학습 데이터(궤적, trajectory) 생성**을 위한
연구용 러너입니다.

- [`batch_runner.py`](../batch_runner.py) — 데이터셋(JSONL)의 여러 프롬프트에 대해
  에이전트를 **병렬 배치 실행**하고, 체크포인트로 중단 지점부터 재개하며, 궤적을
  from/value 쌍 형식으로 저장합니다(1-21행 docstring).
- [`mini_swe_runner.py`](../mini_swe_runner.py) — SWE(소프트웨어 엔지니어링) 과제용
  러너. Hermes의 실행 환경(local/docker/modal)을 재사용해 명령을 돌리고, 궤적을
  `batch_runner.py`와 호환되는 Hermes 형식으로 출력합니다(1-14행 docstring).
- [`trajectory_compressor.py`](../trajectory_compressor.py) — 완성된 궤적을 목표
  토큰 예산 안으로 **후처리 압축**합니다. 앞/뒤 턴은 보호하고 중간만 압축하는 전략
  (1-12행 docstring)은 [07](07_prompt_context.md)의 대화 압축과 같은 철학입니다.

> **왜 코어와 분리돼 있나:** 이들은 배포된 에이전트의 기능이 아니라 모델 학습
> 파이프라인의 일부입니다. 그래서 세션 DB에 저장되지 않고(`hermes_state.py`
> docstring 13행), 별도 단일 파일 모듈로 루트에 있습니다.

---

여기까지가 **주제 1(소스코드 이해)** 입니다. 이제 이 코드들이 딛고 선 **배경 기술**로
넘어갑니다. → [tech_background/01_tool_calling.md](tech_background/01_tool_calling.md)
