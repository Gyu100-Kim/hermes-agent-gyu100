# 03. 진입점 — hermes 명령이 실행되기까지 (1-C-1)

## 이 문서에서 다루는 큰 맥락

사용자가 터미널에 `hermes`라고 치면 어떤 코드가 순서대로 실행될까요? 이 문서는
**진입점(entry point)** 부터 대화형 CLI 오케스트레이터 `HermesCLI`가 뜨기까지의
경로를 따라갑니다.

큰 흐름:
```
hermes (명령)
  → pyproject [project.scripts]  →  hermes_cli/main.py:main()
     → (부트스트랩/자가치유/argparse 파서 구성)
     → args.func(args) 로 하위 명령 디스패치
        → cmd_chat(args)  →  HermesCLI (cli.py) 인스턴스 생성 + REPL 시작
```

### 소목차
- [1. 세 개의 진입점](#1-세-개의-진입점)
- [2. main()의 앞부분 — "print 한 줄 전에 해야 할 일들"](#2-main의-앞부분--print-한-줄-전에-해야-할-일들)
- [3. argparse 파서 구성과 하위 명령 디스패치](#3-argparse-파서-구성과-하위-명령-디스패치)
- [4. 기본 명령은 chat — cmd_chat()](#4-기본-명령은-chat--cmd_chat)
- [5. HermesCLI (cli.py) — 대화형 오케스트레이터](#5-hermescli-clipy--대화형-오케스트레이터)

---

## 들어가기 전에 — 필요한 배경과 비유

**필요한 배경**: [01](01_source_overview.md)의 디렉토리 지도, 그리고 "터미널에서 명령을
친다"는 개념. 함수 호출이 무엇인지 알면 더 좋습니다.

**비유**: 진입점(entry point)은 건물의 **정문**입니다. 터미널에 `hermes`라고 치면
운영체제가 정문을 열어 주고(`[project.scripts]` 등록), 그 안의 안내데스크(`main()`)가
"어떤 용건이세요?"를 묻고(명령줄 파싱), 용건별 담당 부서(하위 명령 함수)로 연결해
줍니다. 이 문서는 "`hermes` 한 단어를 치는 순간부터 대화 화면이 뜨기까지"의 여정을
한 단계씩 따라갑니다.

**학습 목표**: `hermes` 실행 → `hermes_cli/main.py`의 `main()` → 명령 분기 →
`HermesCLI` 대화 루프로 이어지는 호출 사슬을 그림으로 그릴 수 있게 됩니다.

---

## 1. 세 개의 진입점

`pyproject.toml`의 `[project.scripts]`가 정의합니다.
[`pyproject.toml` 308-311행](../pyproject.toml#L308-L311)

```toml
[project.scripts]
hermes = "hermes_cli.main:main"
hermes-agent = "run_agent:main"
hermes-acp = "acp_adapter.entry:main"
```

- **`hermes`** → `hermes_cli/main.py`의 `main()`. 사람 대부분이 쓰는 진입점.
- **`hermes-agent`** → `run_agent.py`의 `main()`. 에이전트 러너를 직접 실행(스크립트/
  배치용). 코어인 `AIAgent`가 여기 있습니다 → [04](04_agent_loop.md).
- **`hermes-acp`** → `acp_adapter/entry.py`의 `main()`. 에디터 통합용 ACP ([용어사전](../dict/08_protocols.md#acp)) 서버
  → [10](10_subsystems.md).

이 문서는 가장 흔한 `hermes` 경로를 따라갑니다.

---

## 2. main()의 앞부분 — "print 한 줄 전에 해야 할 일들"

`hermes_cli/main.py`는 파일 맨 위부터 매우 방어적으로 작성되어 있습니다. 이유는
**"업데이트 중간에 죽거나, Windows에서 인코딩이 깨지거나, 손상된 venv에서도
`hermes update`로 복구할 수 있어야"** 하기 때문입니다.

### 2-1. 부트스트랩(가장 먼저 import)
[`hermes_cli/main.py` 59-62행](../hermes_cli/main.py#L59-L62)
```python
try:
    import hermes_bootstrap  # noqa: F401
except ModuleNotFoundError:
    pass
```
(`hermes_cli/main.py` 59-62행) — `hermes_bootstrap`을 **맨 먼저** import합니다.
주석(46-58행)에 따르면 이는 Windows에서 `print()`/자식 프로세스가 비ASCII 문자에서
`UnicodeEncodeError`를 내지 않도록 UTF-8 stdio를 설정하기 위함입니다. POSIX(리눅스/
맥)에서는 아무 일도 하지 않습니다(no-op). `try/except`로 감싼 것은, 부분적으로
실패한 `hermes update` 상황에서도 이 모듈이 없다고 크래시하지 않기 위함입니다.

### 2-2. 조기 자가치유(early recovery)
[`hermes_cli/main.py` 88-93행](../hermes_cli/main.py#L88-L93)
```python
from hermes_cli import _early_recovery as _early_recovery_mod
try:
    _early_recovery_mod.recover_if_needed()
except Exception:
    pass
```
(88-93행) — 이전 `hermes update`가 중간에 죽어 핵심 패키지의 import 파일이 지워진
경우(#57828), 아래의 무거운 import들이 실행되기 전에 **표준 라이브러리만으로**
최소한을 복구합니다.

### 2-3. main() 본문의 초기 정리 작업
[`hermes_cli/main.py` 14351-14391행](../hermes_cli/main.py#L14351-L14391)
`main()`(14351행)은 순서대로:
1. `_set_process_title()` — `ps`/`top`에서 `python3.11` 대신 `hermes`로 보이게(장식).
2. `configure_windows_stdio()` — Windows UTF-8 stdio 강제.
3. `_cleanup_quarantined_exes()` — 이전 업데이트가 남긴 `hermes.exe.old.*` 정리(Windows).
4. `_recover_from_interrupted_install()` — 중단된 설치 자가치유(단, `update` 실행
   중에는 건너뜀 — 복구 설치가 진짜 설치와 경쟁하지 않도록).
5. `_try_termux_fast_*` — Termux(안드로이드)용 빠른 실행 경로.

> **왜 이렇게까지 하나 (설계 의도):** Hermes는 "$5 VPS부터 GPU 클러스터까지 어디서든"
> 돌아가는 것을 목표로 하며, 사용자가 직접 `hermes update`로 자기를 업그레이드합니다.
> 그 업데이트가 중간에 끊겨도 다음 실행에서 스스로 복구할 수 있어야 하므로, 진입점이
> 이토록 방어적입니다.

---

## 3. argparse 파서 구성과 하위 명령 디스패치

Hermes CLI는 `git`처럼 **하위 명령(subcommand)** 구조입니다(`hermes chat`,
`hermes gateway`, `hermes model`, `hermes cron`, ...). 이를 위해
`argparse`(파이썬 표준 명령행 파서)로 파서 트리를 구성합니다.

### 3-1. 하위 명령 파서 등록
[`hermes_cli/main.py` 431-470행](../hermes_cli/main.py#L431-L470)
파일 상단(431-470행)에서 각 하위 명령의 파서 빌더를 import합니다:
`build_cron_parser`, `build_gateway_parser`, `build_model_parser`,
`build_setup_parser`, `build_slack_parser`, `build_mcp_parser`, ... 각 하위 명령은
`hermes_cli/subcommands/` 아래 별도 파일로 모듈화되어 있습니다.

### 3-2. 파서 조립 + 기본 함수 연결
[`hermes_cli/main.py` 14393-14416행](../hermes_cli/main.py#L14393-L14416)
```python
from hermes_cli._parser import build_top_level_parser
parser, subparsers, chat_parser = build_top_level_parser()
chat_parser.set_defaults(func=cmd_chat)          # chat → cmd_chat
build_model_parser(subparsers, cmd_model=cmd_model)   # model → cmd_model
...
```
(14393-14416행) — 각 하위 파서에 `set_defaults(func=...)`로 **실행할 함수**를
심어둡니다. 이게 argparse의 흔한 디스패치 ([용어사전](../dict/03_tool_system.md#dispatch)) 패턴입니다.

### 3-3. 실제 디스패치
[`hermes_cli/main.py` 16420-16441행](../hermes_cli/main.py#L16420-L16441)
```python
# Default to chat if no command specified
if args.command is None:
    ...
    cmd_chat(args)      # 인자 없이 `hermes` → 바로 채팅
    return

if hasattr(args, "func"):
    args.func(args)     # 하위 명령의 func 실행
else:
    parser.print_help()
```
(16420-16441행) — **핵심:** 아무 하위 명령 없이 `hermes`만 치면 `cmd_chat`으로
가고(16434행), 하위 명령이 있으면 그 명령에 연결된 `args.func`를 호출합니다(16439행).

---

## 4. 기본 명령은 chat — cmd_chat()

[`hermes_cli/main.py` 2444-2483행](../hermes_cli/main.py#L2444-L2483)
`cmd_chat(args)`(2444행)가 대화형 세션을 시작합니다. 주요 초기 처리:

- `use_tui = _resolve_use_tui(args)` (2446행) — TUI ([용어사전](../dict/07_gateway_interfaces.md#tui))로 띄울지 클래식 REPL ([용어사전](../dict/07_gateway_interfaces.md#repl))로 띄울지
  결정. (`--cli` > `--tui`/`HERMES_TUI` > 실제 TTY 여부 > 설정 순서. 이 결정의
  가장 이른 버전은 파일 상단 `_wants_tui_early()` 294행에 있습니다.)
- `--continue`/`-c` 처리(2451-2473행) — 이름/ID로 이전 세션을 찾아 `--resume`으로
  변환. 인자 없이 `-c`면 가장 최근 세션을 이어감.
- `--resume` 처리(2476-2482행) — 제목이면 세션 ID로 해석.
- **세션↔작업공간 바인딩**(2484행~) — 재개(resume)한 세션이 기록해둔 작업
  디렉토리(cwd)로 다시 `cd` 해서 "떠났던 그 저장소에서" 이어가게 함.

> **개념: 세션(session)** — 하나의 연속된 대화. Hermes는 세션을 SQLite ([용어사전](../dict/06_state_retrieval.md#sqlite))에 저장하며
> (→ [06](06_state.md)), 그래서 `hermes -c`로 언제든 이어갈 수 있습니다.

---

## 5. HermesCLI (cli.py) — 대화형 오케스트레이터

`cmd_chat`은 결국 `cli.py`의 `HermesCLI`를 만들어 REPL(읽기-평가-출력 반복)을
돌립니다. 이 클래스가 CLI 인터페이스의 심장입니다.

[`cli.py` 3880-3902행](../cli.py#L3880-L3902)
```python
class HermesCLI(CLIAgentSetupMixin, CLICommandsMixin, CLIBillingMixin):
    """Interactive CLI for the Hermes Agent.

    Provides a REPL interface with rich formatting, command history,
    and tool execution capabilities.
    """
    def __init__(self, model=None, toolsets=None, provider=None, api_key=None,
                 base_url=None, max_turns=None, verbose=None, compact=False,
                 resume=None, checkpoints=False, pass_session_id=False,
                 ignore_rules=False):
```
(`cli.py` 3880-3902행)

주목할 점:
- **믹스인(mixin) 구성**: `HermesCLI`는 3개의 믹스인 클래스를 상속합니다 —
  `CLIAgentSetupMixin`(에이전트 준비), `CLICommandsMixin`(슬래시 명령 ([용어사전](../dict/07_gateway_interfaces.md#slash-command))),
  `CLIBillingMixin`(과금 표시). `cli.py`가 16,000줄이 넘는 "god-file"이라, 기능을
  믹스인으로 쪼개 관리합니다. `AGENTS.md`도 이런 god-file을 믹스인/모듈로 쪼개는
  리팩터링을 "원하는 작업"으로 명시합니다.
- **생성자 인자**가 곧 CLI 옵션과 대응합니다: `model`, `provider`, `toolsets`,
  `max_turns`(도구 호출 ([용어사전](../dict/02_agent_core.md#tool-calling)) 반복 상한, 기본 90 — 서브에이전트와 공유), `resume`(재개할
  세션 ID) 등.
- **설정 로드**: `self.config = CLI_CONFIG`(3920행) 이후 `display` 섹션에서
  표시 옵션(compact, tool_progress, show_reasoning 등)을 읽습니다(3921-3948행).
  이 설정들은 모두 `config.yaml`에서 오며, `AGENTS.md` 원칙상 **비밀이 아닌 모든
  동작 설정은 `.env`가 아니라 `config.yaml`** 에 둡니다.

`HermesCLI`가 실제로 사용자 메시지를 처리할 때는 내부적으로 `AIAgent`
(`run_agent.py`)의 `run_conversation`을 호출합니다. 그 "두뇌"가 다음 문서의
주제입니다.

---

## 정리 — 스스로 점검 질문

**핵심 요약**
- 진입점은 `pyproject.toml`의 `[project.scripts]`가 정의하며, 모두 `hermes_cli/main.py`의 `main()`으로 모인다.
- `main()` 앞부분은 "print 한 줄 전에 해야 할 일"(부트스트랩, 프로파일, 로깅 등)을 순서대로 처리한다 — 순서가 곱 설계다.
- 하위 명령이 없으면 기본값은 `chat`이고, 대화형 세션은 `cli.py`의 `HermesCLI`가 오케스트레이션한다.

**점검 질문**
1. 터미널의 `hermes`라는 단어가 어떻게 `main()` 함수 실행으로 이어지는가?
2. `main()`이 출력보다 먼저 처리하는 일에는 어떤 것들이 있고, 왜 순서가 중요한가?
3. `hermes`만 치면 왜 채팅 모드가 시작되는가?
4. `HermesCLI`와 `AIAgent`의 역할 분담은? (힌트: 오케스트레이션 vs 두뇌)

다음 문서 → [04_agent_loop.md](04_agent_loop.md)
