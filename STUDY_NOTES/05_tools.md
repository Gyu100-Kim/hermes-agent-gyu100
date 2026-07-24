# 05. 도구 계층 — 등록, 발견, 디스패치 (1-C-3)

## 이 문서에서 다루는 큰 맥락

LLM 에이전트가 실제로 "일"을 하려면 도구(tool)가 필요합니다. 터미널 명령을 실행하고,
파일을 읽고, 웹을 검색하고, 브라우저를 조작하는 것 모두 도구입니다. 이 문서는
Hermes가 도구를 **어떻게 등록하고(register), 어떻게 발견하며(discover), 어떻게
실행하는지(dispatch)** 를 라인 단위로 봅니다.

큰 흐름:
```
tools/*.py 각 파일이 모듈 로드 시 registry.register(...) 호출
        ↓ (자기 등록, self-registration)
tools/registry.py 의 ToolRegistry 가 모든 도구를 보관
        ↓
model_tools.py 가 레지스트리를 조회해 (1) 스키마 조립, (2) 호출 디스패치
        ↓
run_conversation 루프가 handle_function_call() 을 호출  → registry.dispatch()
```

### 소목차
- [1. 도구란 무엇인가 (이 코드베이스에서)](#1-도구란-무엇인가-이-코드베이스에서)
- [2. 좁은 허리(narrow waist)와 코어 도구 목록](#2-좁은-허리narrow-waist와-코어-도구-목록)
- [3. 자기 등록(self-registration) 메커니즘](#3-자기-등록self-registration-메커니즘)
- [4. 자동 발견: discover_builtin_tools](#4-자동-발견-discover_builtin_tools)
- [5. ToolEntry와 register()의 매개변수](#5-toolentry와-register의-매개변수)
- [6. check_fn — 서비스 게이팅과 플래키 억제](#6-check_fn--서비스-게이팅과-플래키-억제)
- [7. 디스패치: registry.dispatch와 handle_function_call](#7-디스패치-registrydispatch와-handle_function_call)
- [8. 대표 개별 도구들](#8-대표-개별-도구들)

---

## 1. 도구란 무엇인가 (이 코드베이스에서)

- **도구(tool)**: LLM이 "이 함수를 이런 인자로 실행해줘"라고 요청할 수 있는 기능
  단위. 각 도구는 (a) **스키마**(이름·설명·인자 형식을 담은 JSON — 모델에게 보내짐),
  (b) **핸들러**(실제 파이썬 함수)로 이루어집니다.
- **도구 묶음(toolset)**: 관련 도구들의 집합. `toolsets.py`가 정의.
- 모델이 도구를 요청 → Hermes가 핸들러를 실행 → 결과 문자열을 모델에게 돌려줌 →
  모델이 다음 행동 결정. 이 반복이 [04](04_agent_loop.md)의 루프입니다.

---

## 2. 좁은 허리(narrow waist)와 코어 도구 목록

`AGENTS.md`의 핵심 원칙: **모든 코어 도구는 매 API 호출마다 모델에게 전송**됩니다.
도구가 많을수록 프롬프트가 커지고 비용/지연이 늘어납니다. 그래서 코어 도구 목록은
의도적으로 좁게 유지되고, 새 기능은 "가장자리"(스킬/플러그인/MCP/서비스 게이트
도구)로 들어갑니다.

코어 도구 목록은 `toolsets.py`의 `_HERMES_CORE_TOOLS`입니다.
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/toolsets.py" lines="31-81" />
대표 항목(31-81행):
- 웹: `web_search`, `web_extract`
- 터미널/프로세스: `terminal`, `process`
- 파일: `read_file`, `write_file`, `patch`, `search_files`
- 스킬: `skills_list`, `skill_view`, `skill_manage`
- 브라우저: `browser_navigate`, `browser_snapshot`, `browser_click`, ... `browser_cdp`
- 계획/메모리: `todo`, `memory`
- 세션 검색: `session_search`
- 코드 실행/위임: `execute_code`, `delegate_task`
- cron: `cronjob`

주석(55-59행, 70-78행)이 흥미롭습니다: 데스크톱 전용 도구(`project_*`)나 kanban
도구는 **일부러 코어에 넣지 않고** GUI/kanban 게이트웨이가 켤 때만 활성화합니다.
이것이 "좁은 허리"의 실천입니다.

`_HERMES_WEBHOOK_SAFE_TOOLS`(86-91행)는 또 다른 좋은 예입니다: 웹훅은 신뢰할 수 없는
제3자 콘텐츠(공개 PR 제목 등)에서 올 수 있으므로, 프롬프트 인젝션으로 로컬 실행이
일어나지 않도록 `web_search`/`web_extract`/`vision_analyze`/`clarify`만 남긴
**의도적으로 축소된 도구 집합**입니다.

---

## 3. 자기 등록(self-registration) 메커니즘

레지스트리의 핵심 아이디어(파일 상단 docstring):
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/tools/registry.py" lines="1-15" />
```
각 도구 파일은 모듈 레벨에서 registry.register()를 호출해 자신의
스키마·핸들러·소속 toolset·가용성 체크를 선언한다. model_tools.py는 자체
자료구조를 유지하는 대신 레지스트리에 질의한다.
```
(`tools/registry.py` 1-6행)

즉 새 도구를 추가하려면 `tools/`에 파일을 만들고 그 안에서 `registry.register(...)`를
호출하면 됩니다. `model_tools.py`를 수정할 필요가 없습니다. import 체인(7-14행)이
순환 import에 안전하도록 설계되어 있습니다: `registry.py`는 아무것도 import하지
않고, 도구 파일들이 `registry`를 import하며, `model_tools.py`가 그 위에 얹힙니다.

---

## 4. 자동 발견: discover_builtin_tools

레지스트리는 "자기 등록"만으로는 부족합니다. 등록하려면 먼저 그 모듈이 **import**
되어야 합니다. 그 일을 하는 함수가 `discover_builtin_tools`입니다.
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/tools/registry.py" lines="67-84" />
```python
def discover_builtin_tools(tools_dir: Optional[Path] = None) -> List[str]:
    """Import built-in self-registering tool modules and return their module names."""
    tools_path = ...
    module_names = [
        f"tools.{path.stem}"
        for path in sorted(tools_path.glob("*.py"))
        if path.name not in {"__init__.py", "registry.py", "mcp_tool.py"}
        and _module_registers_tools(path)
    ]
    imported: List[str] = []
    for mod_name in module_names:
        try:
            importlib.import_module(mod_name)   # ← import하면 register()가 실행됨
            ...
```
(`tools/registry.py` 67-84행)

- `tools/` 아래 모든 `.py`를 훑어(`glob`), `registry.py`/`mcp_tool.py`/`__init__.py`는
  제외하고, `_module_registers_tools(path)`가 True인 파일만 골라 import합니다.
- `_module_registers_tools`(43행~)는 **AST(추상 구문 트리) 분석**으로 "이 파일이
  모듈 최상위에서 `registry.register(...)`를 호출하는가"를 확인합니다
  (`_is_registry_register_call`, 30-40행). 함수 안에서만 호출하는 헬퍼 모듈은
  제외됩니다. 값싼 텍스트 사전 필터(49-50행)로 `ast.parse` 비용도 아낍니다.

> **왜 AST까지 쓰나 (설계 의도):** 단순히 이름 규칙으로 도구 파일을 찾으면 오탐이
> 생깁니다. "실제로 모듈 레벨에서 register를 호출하는 파일"만 정확히 골라야
> 불필요한 import(부작용/비용)를 피할 수 있어서, 파일을 실행하지 않고 구조만 읽는
> AST 분석을 씁니다.

---

## 5. ToolEntry와 register()의 매개변수

등록된 도구 하나는 `ToolEntry`로 표현됩니다.
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/tools/registry.py" lines="87-116" />
`__slots__`(90-94행)로 메모리를 아끼며, 필드는:
`name`, `toolset`, `schema`, `handler`, `check_fn`, `requires_env`, `is_async`,
`description`, `emoji`, `max_result_size_chars`, `dynamic_schema_overrides`.

특히 `dynamic_schema_overrides`(109-116행)는 런타임 설정에 따라 스키마를 바꿔야 할
때 씁니다. 예: `delegate_task`의 설명에 사용자의 현재
`delegation.max_concurrent_children` 한도를 반영해야 모델이 틀린 한도를 안내받지
않습니다.

`register()` 메서드(365행~)가 이 필드들을 인자로 받아 `ToolEntry`를 만들어 저장합니다.
`override=True`면 기존 등록을 덮어씁니다(플러그인/테스트용).

---

## 6. check_fn — 서비스 게이팅과 플래키 억제

`check_fn`은 "이 도구를 지금 쓸 수 있는가?"를 반환하는 함수입니다. 예: Home
Assistant 도구는 토큰이 설정돼 있을 때만, Docker 백엔드 도구는 Docker 데몬이 떠
있을 때만 노출됩니다. 이것이 `AGENTS.md`의 "서비스 게이트 도구(service-gated tool)"
개념이며, 조건이 안 맞으면 스키마에서 아예 빠져 **좁은 허리**를 지킵니다.

그런데 이 체크는 비쌉니다(외부 프로세스 프로브). 그래서 TTL 캐시가 붙어 있습니다.
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/tools/registry.py" lines="119-151" />
- `_CHECK_FN_TTL_SECONDS = 30.0` (143행): 결과를 ~30초 캐시. `hermes tools`로 켠
  설정이 한두 턴 안에 반영되도록.
- **플래키(flaky) 억제** (130-140행, `_CHECK_FN_FAILURE_GRACE_SECONDS = 60.0`):
  Docker 데몬 프로브가 부하로 순간 타임아웃하면 False가 나오는데, 그걸 그대로 믿으면
  터미널+파일 도구 전체가 갑자기 사라져 서브에이전트가 "read_file 도구가 없다"고
  실패합니다(#21658/#5304). 그래서 "최근에 성공했던 체크가 짧은 유예 시간 안에
  실패하면 마지막 성공값(True)을 대신 돌려주되 실패는 캐시하지 않는" 방식으로,
  진짜 다운은 반영하면서 순간적 흔들림은 흡수합니다(`_check_fn_cached`, 154행~).

> 이 부분은 "정확성 vs. 안정성"의 정교한 트레이드오프를 보여주는 좋은 예입니다.

---

## 7. 디스패치: registry.dispatch와 handle_function_call

### 7-1. registry.dispatch — 실제 실행
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/tools/registry.py" lines="614-644" />
```python
def dispatch(self, name: str, args: dict, **kwargs) -> str | dict:
    entry = self.get_entry(name)
    if not entry:
        return json.dumps({"error": f"Unknown tool: {name}"})
    try:
        if entry.is_async:
            from model_tools import _run_async
            result = _run_async(entry.handler(args, **kwargs))  # 비동기 핸들러 브리지
        else:
            result = entry.handler(args, **kwargs)
        return self._normalize_handler_result(name, result)
    except Exception as e:
        ...
        return json.dumps({"error": sanitized})
```
(`tools/registry.py` 614-644행)

- 이름으로 `ToolEntry`를 찾고, 비동기면 `_run_async`로 이벤트 루프에 브리지(627-629행).
- 결과는 `_normalize_handler_result`로 문자열/멀티모달 봉투로 정규화(632행).
- **모든 예외를 잡아** `{"error": ...}` JSON으로 변환(633-644행). 도구가 터져도
  루프가 죽지 않고 모델이 오류를 읽고 대응할 수 있게 합니다. 예외 메시지는
  `_sanitize_tool_error`로 살균해, 예외 문자열 속 프레이밍 토큰/CDATA/코드펜스가
  모델에게 구조적 잡음으로 전달되지 않게 합니다.

### 7-2. handle_function_call — 루프와 레지스트리 사이
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/model_tools.py" lines="1069-1084" />
`model_tools.handle_function_call`(1069행)이 대화 루프와 레지스트리 사이의
공식 관문입니다. 인자에 `task_id`, `session_id`, `turn_id`, `enabled_tools`,
`enabled_toolsets` 등이 있어, 세션/서브에이전트 격리와 도구 범위 지정을 담당합니다.

내부에서 실제로 `registry.dispatch`를 호출합니다.
<ref_snippet file="/home/ubuntu/repos/hermes-agent-gyu100/model_tools.py" lines="1303-1322" />
- `execute_code`는 서브에이전트가 부모의 도구 집합을 덮어쓰지 못하도록
  호출자가 준 `enabled_tools`를 우선 사용(1304-1314행).
- 그 외 도구는 `task_id`/`session_id`/`user_task`를 dispatch로 전달(1316-1322행).
- 실행 전후로 승인(approval)/미들웨어/관측(observability) 컨텍스트를 설정합니다
  (1292-1323행). 위험한 명령의 승인 게이팅이 여기서 걸립니다.

---

## 8. 대표 개별 도구들

각 도구는 `tools/` 아래 자기 파일에서 `registry.register`로 등록됩니다.

- **`tools/terminal_tool.py`** — 실제 터미널. 여러 실행 백엔드(local/docker/ssh/
  modal/daytona/singularity)를 `tools/environments/`로 추상화. `check_fn`으로
  백엔드 가용성을 게이팅. → [tech_background/09_execution_environments.md](tech_background/09_execution_environments.md)
- **`tools/file_tools.py`** — `read_file`/`write_file`/`patch`/`search_files`.
  상단(1-26행)에서 `agent/file_safety.py`, `tools/file_operations.py`,
  `agent/redact.py` 등을 조합해 안전한 파일 조작(민감정보 마스킹 포함)을 제공.
- **`tools/browser_tool.py`** — 접근성 트리(ariaSnapshot) 기반 텍스트 브라우징.
  local Chromium / Browserbase / Browser Use 백엔드 자동 감지(1-38행). 저수준
  제어는 CDP 기반(`browser_cdp`). → [tech_background/08_cdp_browser.md](tech_background/08_cdp_browser.md)
- **`tools/mcp_tool.py`** — 외부 MCP 서버의 도구를 동적으로 등록/호출. 그래서
  `discover_builtin_tools`에서 **일부러 제외**되어 있습니다(67-74행) — 정적
  자기등록이 아니라 런타임 동적 등록이기 때문. → [tech_background/05_mcp_and_acp.md](tech_background/05_mcp_and_acp.md)
- **`tools/delegate_tool.py`** — `delegate_task`. 격리된 자식 에이전트에게 하위
  목표를 맡기는 위임(delegation). 자식의 중간 과정은 부모 컨텍스트를 오염시키지
  않고 요약만 돌아오며, 반복 예산을 부모와 공유([04](04_agent_loop.md)의 예산 설명).

다음 문서에서는 이 모든 활동이 저장되는 **상태/영속성 계층**을 봅니다.
→ [06_state.md](06_state.md)
