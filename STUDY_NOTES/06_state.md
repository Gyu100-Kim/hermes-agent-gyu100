# 06. 상태와 영속성 — SQLite, WAL, FTS5, 세션 분할 (1-C-4)

## 이 문서에서 다루는 큰 맥락

Hermes는 모든 대화를 **SQLite 데이터베이스** 하나(`state.db`)에 저장합니다. 이
덕분에 `hermes -c`로 세션을 이어가고, 과거 대화를 전문 검색(full-text search)하며,
여러 메시징 플랫폼이 동시에 써도 안전하게 동작합니다. 이 문서는 그 저장소인
`hermes_state.py`(약 9,900줄)의 핵심 설계 4가지를 봅니다:

1. **SQLite 스키마** (무엇을 어떤 표에 저장하는가)
2. **WAL 모드** (동시 접근 안전성)와 파일시스템 폴백
3. **FTS5 전문 검색** (과거 대화를 빠르게 찾기)
4. **`parent_session_id` 체인** (압축으로 인한 세션 분할)

### 소목차
- [1. 왜 파일이 아니라 SQLite인가](#1-왜-파일이-아니라-sqlite인가)
- [2. 스키마 개요: sessions와 messages](#2-스키마-개요-sessions와-messages)
- [3. WAL 모드와 폴백](#3-wal-모드와-폴백)
- [4. FTS5 전문 검색](#4-fts5-전문-검색)
- [5. 트라이그램 인덱스 — CJK(한중일) 검색](#5-트라이그램-인덱스--cjk한중일-검색)
- [6. parent_session_id — 압축 세션 분할](#6-parent_session_id--압축-세션-분할)

---

## 1. 왜 파일이 아니라 SQLite인가

파일 상단 docstring이 설계 결정을 요약합니다.
[`hermes_state.py` 3-15행](../hermes_state.py#L3-L15)
```
SQLite State Store ... replacing the per-session JSONL file approach.

Key design decisions:
- WAL mode for concurrent readers + one writer (gateway multi-platform)
- FTS5 virtual table for fast text search across all session messages
- Compression-triggered session splitting via parent_session_id chains
- Session source tagging ('cli', 'telegram', 'discord', ...) for filtering
```
(`hermes_state.py` 3-15행)

예전에는 세션마다 JSONL 파일을 쓰던 방식이었는데, (a) 게이트웨이가 여러 플랫폼을
동시에 다룰 때 파일 락 문제, (b) 전체 대화를 가로질러 검색하기 어려움이 있었습니다.
SQLite 하나로 옮기면 이 두 문제를 트랜잭션과 인덱스로 깔끔히 해결할 수 있습니다.

> **개념: SQLite** — 서버가 필요 없는 파일 기반 관계형 DB. 파이썬 표준 라이브러리
> (`sqlite3`)에 포함돼 있어 추가 설치가 필요 없습니다. Hermes의 "어디서든 돈다"는
> 목표와 잘 맞습니다.

---

## 2. 스키마 개요: sessions와 messages

가장 중요한 두 표는 `sessions`(세션 하나 = 한 행)와 `messages`(메시지 하나 = 한 행)
입니다.

### 2-1. sessions 표
[`hermes_state.py` 1056-1105행](../hermes_state.py#L1056-L1105)
```sql
CREATE TABLE IF NOT EXISTS sessions (
    id TEXT PRIMARY KEY,
    source TEXT NOT NULL,          -- 'cli', 'telegram', 'discord', ...
    user_id TEXT, session_key TEXT, chat_id TEXT, ...
    model TEXT, model_config TEXT, system_prompt TEXT,
    parent_session_id TEXT,        -- 압축 세션 분할 체인
    started_at REAL NOT NULL, ended_at REAL, end_reason TEXT,
    message_count INTEGER DEFAULT 0, tool_call_count INTEGER DEFAULT 0,
    input_tokens INTEGER DEFAULT 0, output_tokens INTEGER DEFAULT 0,
    cache_read_tokens INTEGER DEFAULT 0, cache_write_tokens INTEGER DEFAULT 0,
    cwd TEXT, git_branch TEXT, git_repo_root TEXT,  -- 작업공간 바인딩
    ... estimated_cost_usd REAL, actual_cost_usd REAL, ...  -- 과금
    profile_name TEXT, archived INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (parent_session_id) REFERENCES sessions(id)
);
```
(`hermes_state.py` 1056-1105행)

주목할 열들:
- `source`(1058행): 세션이 어디서 왔는지(CLI/텔레그램/디스코드...). 필터링에 사용.
- `system_prompt`(1069행): 세션의 시스템 프롬프트를 저장 → 재개 시 **바이트 그대로
  복원**해 프롬프트 캐시를 유지([07](07_prompt_context.md)).
- `parent_session_id`(1070행): 자기 자신을 참조하는 외래키(1104행). 압축 분할의 핵심.
- 토큰/캐시/비용 열들(1076-1091행): 과금 표시(`CLIBillingMixin`)에 쓰임.
- `cwd`/`git_branch`/`git_repo_root`(1081-1083행): [03](03_entrypoints.md)에서 본
  "세션↔작업공간 바인딩"을 위한 기록.

### 2-2. messages 표
[`hermes_state.py` 1107-1131행](../hermes_state.py#L1107-L1131)
```sql
CREATE TABLE IF NOT EXISTS messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL REFERENCES sessions(id),
    role TEXT NOT NULL,            -- 'user' | 'assistant' | 'tool' | 'system'
    content TEXT,
    tool_call_id TEXT, tool_calls TEXT, tool_name TEXT,
    timestamp REAL NOT NULL, token_count INTEGER, finish_reason TEXT,
    reasoning TEXT, reasoning_content TEXT, ...
    active INTEGER NOT NULL DEFAULT 1,      -- 현재 활성 컨텍스트에 포함되는가
    compacted INTEGER NOT NULL DEFAULT 0,   -- 압축으로 요약본에 흡수됐는가
    api_content TEXT, display_kind TEXT, display_metadata TEXT
);
```
(`hermes_state.py` 1107-1131행)

- `role`(1110행): 대화 역할. Hermes는 "user→assistant→user..." **역할 교대**를
  엄격히 지킵니다(`AGENTS.md`).
- `active`(1126행) / `compacted`(1127행): 압축의 핵심 플래그. 압축되면 원본
  메시지는 지워지지 않고 `active=0`/`compacted=1`로 표시되어, **원본은 검색·감사용으로
  남되 활성 컨텍스트에서만 빠집니다**.
- 인덱스(1196-1221행)와 `session_model_usage`/`compression_locks`/`async_delegations`
  등 보조 표(1133-1190행)가 성능·과금·동시성·비동기 위임을 뒷받침합니다.

---

## 3. WAL 모드와 폴백

**WAL(Write-Ahead Logging)** 은 SQLite의 동시성 모드로, "여러 읽기 + 한 개의 쓰기"를
동시에 허용합니다. 게이트웨이가 여러 플랫폼을 다뤄 여러 프로세스가 DB를 열어도
서로 막히지 않게 하는 것이 목적입니다(docstring 10행).

문제는 **모든 파일시스템이 WAL을 지원하진 않는다**는 점(NFS/SMB/일부 FUSE)입니다.
그래서 `apply_wal_with_fallback`이 방어적으로 처리합니다.
[`hermes_state.py` 521-584행](../hermes_state.py#L521-L584)
- WAL 설정을 시도하고(569행), 실패 시 원인이 "WAL 비호환"이면 경고 후
  `journal_mode=DELETE`로 폴백(582-584행). DELETE는 NFS에서도 동작하는 옛 기본값.
- **손상 버그 회피**(553-555행): 특정 SQLite 빌드에 WAL-reset 손상 버그(#69784)가
  있으면 새 DB에는 아예 WAL을 켜지 않습니다.
- **다운그레이드 금지**(578-581행): 디스크의 DB가 이미 WAL이면, 다른 프로세스가
  동시에 열고 있을 수 있으므로 절대 DELETE로 낮추지 않습니다.
- 경고는 `db_label`별로 한 번만(dedup, 540-544행).

> 이 함수는 `SessionDB`뿐 아니라 kanban DB, cron 실행 원장([10](10_subsystems.md)의
> `cron/executions.py` 29행)도 공유합니다 — "한 곳에서 올바르게 처리한 폴백을 모든
> DB가 재사용"하는 좋은 설계입니다.

---

## 4. FTS5 전문 검색

**FTS5(Full-Text Search 5)** 는 SQLite에 내장된 전문 검색 엔진입니다. Hermes는
과거 모든 세션의 메시지를 여기 색인해 `session_search` 도구로 빠르게 찾습니다
(배경 이론은 [tech_background/06_retrieval_fts5.md](tech_background/06_retrieval_fts5.md)).

[`hermes_state.py` 1245-1261행](../hermes_state.py#L1245-L1261)
```sql
CREATE VIRTUAL TABLE IF NOT EXISTS messages_fts USING fts5(
    content,
    tool_name,
    tool_calls,
    content='messages',      -- 외부 콘텐츠(external content) 테이블
    content_rowid='id'
);
CREATE TRIGGER IF NOT EXISTS messages_fts_insert AFTER INSERT ON messages ...
```
(`hermes_state.py` 1245-1261행)

- `content='messages'`(1249행): FTS 표가 데이터를 중복 저장하지 않고 원본
  `messages` 표를 참조하는 **external content** 방식. 저장 공간을 아낍니다.
- **트리거로 자동 동기화**(1253-1286행): `messages`에 INSERT/DELETE/UPDATE가
  일어나면 트리거가 FTS 색인을 자동 갱신합니다. 즉 개발자가 색인을 직접 관리할
  필요가 없습니다.
- 트리거의 `WHEN` 조건(1254-1257행)은 대량 재색인(rebuild) 중 중복 색인을 막기
  위한 high-water/progress 마커 체크입니다 — 큰 DB를 점진적으로 재색인할 때의
  정합성 장치입니다.

---

## 5. 트라이그램 인덱스 — CJK(한중일) 검색

기본 FTS5 토크나이저(unicode61)는 한글/한자/일본어를 글자 단위로 쪼개 구(phrase)
검색이 깨집니다. 그래서 별도의 **트라이그램(trigram)** 인덱스를 둡니다.
[`hermes_state.py` 1289-1316행](../hermes_state.py#L1289-L1316)
- 트라이그램 토크나이저(1315행)는 겹치는 3바이트 조각을 만들어 어떤 문자 체계든
  부분 문자열 검색이 되게 합니다(1290-1292행).
- **비용 최적화**(1293-1302행): 트라이그램 인덱스는 원문의 약 2.6배로 가장 비싼
  인덱스인데, `role='tool'` 행이 메시지 바이트의 ~90%이면서 대부분 기계 잡음
  (base64, 파일 덤프)입니다. 그래서 `messages_fts_trigram_src`라는 뷰로
  **도구 행을 제외**하고 색인합니다(1304-1307행). 도구 행은 표준 `messages_fts`로는
  여전히 검색됩니다.
- CJK 스택 위에 CJK 전용 FTS(`messages_fts_cjk`, 1399행~)도 추가로 있습니다.

> 이 부분은 한국어 사용자에게 특히 중요합니다: 한국어로 나눈 과거 대화도
> `session_search`로 제대로 찾히도록 설계되어 있습니다.

---

## 6. parent_session_id — 압축 세션 분할

대화가 아주 길어지면 컨텍스트를 압축해야 합니다([07](07_prompt_context.md)). Hermes는
압축이 일어날 때 **세션을 분할**하고, 새 세션의 `parent_session_id`로 원본을 가리키게
해서 계보(lineage)를 남깁니다(docstring 12행).

- `sessions.parent_session_id`(1070행)와 자기참조 외래키(1104행), 인덱스
  `idx_sessions_parent`(1198행)가 이를 뒷받침합니다.
- 파일 상단(136-203행)에는 이 체인을 다루는 SQL 조각들이 있습니다:
  - `_BRANCH_CHILD_SQL`/`_LISTABLE_CHILD_SQL`(136-149행): 세션 목록에서 어떤
    자식 세션을 보여줄지 결정.
  - 부모 삭제 시(202-203행): 자식의 `parent_session_id`를 NULL로 만들어 고아
    참조가 남지 않게 정리.

> **왜 지우지 않고 분할하나 (설계 의도):** 압축은 "요약"이라 정보 손실이 있습니다.
> 원본을 삭제하는 대신 부모 세션으로 남겨두면, 나중에 감사하거나 검색할 때 원본
> 대화를 되짚을 수 있습니다. 활성 컨텍스트(비용)는 줄이면서 기록(가치)은 보존하는
> 절충입니다.

다음 문서에서는 이 상태 위에서 매 턴 만들어지는 **프롬프트와 컨텍스트**를 봅니다.
→ [07_prompt_context.md](07_prompt_context.md)
