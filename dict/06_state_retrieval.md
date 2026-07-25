# 용어 사전 — 상태·영속성·검색

[⬆ 사전 전체 목차로](README.md)

이 문서는 분류(Content Class) **상태·영속성·검색** 에 속한 용어 19개를 다룹니다.

- 설명 속 링크를 누르면 해당 용어 항목으로 이동합니다.
- **하위 개념** = 이 용어보다 더 **일반적인** 개념(먼저 알아두면 좋은 바탕 개념), **상위 개념** = 이 용어를 더 **특수화**한 개념(구체화·사례)입니다.
- 각 항목 끝의 "이 용어를 참조하는 항목"으로 원래 보던 곳으로 되돌아갈 수 있습니다.

## 이 문서의 용어

- [SessionDB](#sessiondb)
- [SQLite](#sqlite)
- [WAL 모드](#wal)
- [세션](#session)
- [전문 검색 (FTS)](#fts)
- [FTS5](#fts5)
- [역색인](#inverted-index)
- [토크나이저 (검색)](#tokenizer)
- [unicode61 토크나이저](#unicode61)
- [트라이그램 토크나이저](#trigram)
- [BM25](#bm25)
- [TF-IDF](#tf-idf)
- [외부 콘텐츠 테이블](#external-content)
- [FTS 동기화 트리거](#fts-trigger)
- [세션 검색](#session-search)
- [검색 증강 (RAG)](#retrieval)
- [벡터 검색](#vector-search)
- [하이브리드 검색](#hybrid-search)
- [에이전트형 RAG](#agentic-rag)

<a id="sessiondb"></a>

### SessionDB

**영문**: SessionDB · **분류**: [상태·영속성·검색](README.md#분류content-class)

Hermes의 상태 저장소 클래스(`hermes_state.py`). [SQLite](#sqlite) 파일 하나에 세션·메시지·크론 작업 등을 저장하며, [WAL](#wal) 모드와 [FTS5](#fts5) 검색을 사용합니다.

**상위 개념(더 특수)**: [세션](#session)

**관련 용어**: [SQLite](#sqlite) · [세션](#session) · [WAL 모드](#wal) · [FTS5](#fts5)

**이 용어를 참조하는 항목**: [압축 계보](04_prompt_context.md#compression-lineage) · [크론 (예약 작업)](12_subsystems.md#cron) · [일화 기억](05_memory_self_improvement.md#episodic-memory) · [SQLite](#sqlite) · [WAL 모드](#wal)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="sqlite"></a>

### SQLite

**영문**: SQLite · **분류**: [상태·영속성·검색](README.md#분류content-class)

서버 없이 파일 하나로 동작하는 임베디드 관계형 데이터베이스. 설치·운영 부담이 없어 로컬 우선 도구의 표준 선택입니다.

> **예시**: Hermes의 모든 대화 기록은 `~/.hermes/` 아래 SQLite 파일 하나에 담겨, 서버 없이 파일 복사만으로 백업됩니다.

**상위 개념(더 특수)**: [FTS5](#fts5) · [WAL 모드](#wal)

**관련 용어**: [SessionDB](#sessiondb) · [WAL 모드](#wal) · [FTS5](#fts5)

**이 용어를 참조하는 항목**: [FTS 동기화 트리거](#fts-trigger) · [SessionDB](#sessiondb)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="wal"></a>

### WAL 모드

**영문**: Write-Ahead Logging · **분류**: [상태·영속성·검색](README.md#분류content-class)

변경을 원본 파일에 바로 쓰지 않고 로그 파일에 먼저 기록하는 [SQLite](#sqlite) 저널링 모드. 읽기와 쓰기가 서로를 막지 않아 게이트웨이(쓰기)와 검색(읽기)의 동시성이 좋아집니다.

> **예시**: 게이트웨이가 새 메시지를 쓰는 도중에도 세션 검색(읽기)이 블로킹 없이 동시에 실행됩니다.

**하위 개념(더 일반)**: [SQLite](#sqlite)

**관련 용어**: [SessionDB](#sessiondb)

**이 용어를 참조하는 항목**: [SessionDB](#sessiondb) · [SQLite](#sqlite)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="session"></a>

### 세션

**영문**: Session · **분류**: [상태·영속성·검색](README.md#분류content-class)

하나의 연속된 대화 단위. 메시지들이 세션에 속하며, [압축](04_prompt_context.md#context-compression) 시 `parent_session_id`로 연결된 새 세션이 만들어집니다.

**하위 개념(더 일반)**: [SessionDB](#sessiondb)

**관련 용어**: [턴](02_agent_core.md#turn) · [압축 계보](04_prompt_context.md#compression-lineage)

**이 용어를 참조하는 항목**: [압축 계보](04_prompt_context.md#compression-lineage) · [게이트웨이 세션](07_gateway_interfaces.md#gateway-session) · [SessionDB](#sessiondb) · [턴](02_agent_core.md#turn)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="fts"></a>

### 전문 검색 (FTS)

**영문**: Full-Text Search · **분류**: [상태·영속성·검색](README.md#분류content-class)

문서 안의 단어를 미리 색인해 두고 질의어가 포함된 문서를 빠르게 찾는 기술. LIKE '%...%' 스캔과 달리 문서가 많아도 빠릅니다.

**상위 개념(더 특수)**: [FTS5](#fts5) · [역색인](#inverted-index)

**관련 용어**: [FTS5](#fts5) · [역색인](#inverted-index) · [검색 증강 (RAG)](#retrieval)

**이 용어를 참조하는 항목**: [검색 증강 (RAG)](#retrieval)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="fts5"></a>

### FTS5

**영문**: FTS5 · **분류**: [상태·영속성·검색](README.md#분류content-class)

[SQLite](#sqlite) 내장 전문 검색 확장(5세대). Hermes의 [세션 검색](#session-search)이 이것으로 구현되어, 별도 검색 서버 없이 과거 대화를 검색합니다.

> **예시**: SELECT ... WHERE messages_fts MATCH 'deploy error' 한 줄로 수만 개 메시지에서 즉시 검색됩니다.

**하위 개념(더 일반)**: [전문 검색 (FTS)](#fts) · [SQLite](#sqlite)

**상위 개념(더 특수)**: [BM25](#bm25) · [외부 콘텐츠 테이블](#external-content) · [세션 검색](#session-search) · [토크나이저 (검색)](#tokenizer)

**관련 용어**: [BM25](#bm25) · [토크나이저 (검색)](#tokenizer) · [외부 콘텐츠 테이블](#external-content) · [트라이그램 토크나이저](#trigram)

**이 용어를 참조하는 항목**: [전문 검색 (FTS)](#fts) · [SessionDB](#sessiondb) · [SQLite](#sqlite) · [unicode61 토크나이저](#unicode61)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="inverted-index"></a>

### 역색인

**영문**: Inverted Index · **분류**: [상태·영속성·검색](README.md#분류content-class)

'단어 → 그 단어가 등장하는 문서 목록' 방향으로 뒤집힌 색인. 책 뒤의 찾아보기와 같은 원리로, 전문 검색을 빠르게 만드는 핵심 자료구조입니다.

> **예시**: 책 뒤의 '찾아보기'에서 "압축 → 87, 132쪽"을 보는 것과 같은 원리입니다. 단어에서 문서를 역방향으로 찾습니다.

**하위 개념(더 일반)**: [전문 검색 (FTS)](#fts)

**관련 용어**: [토크나이저 (검색)](#tokenizer)

**이 용어를 참조하는 항목**: [전문 검색 (FTS)](#fts)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="tokenizer"></a>

### 토크나이저 (검색)

**영문**: Tokenizer (FTS) · **분류**: [상태·영속성·검색](README.md#분류content-class)

텍스트를 색인 단위(단어)로 쪼개는 규칙. 언어에 따라 적절한 방식이 다르며, [FTS5](#fts5)는 [unicode61](#unicode61)과 [트라이그램](#trigram) 등을 제공합니다. [LLM](01_llm_basics.md#llm)의 토큰화와는 다른 개념입니다.

**하위 개념(더 일반)**: [FTS5](#fts5)

**상위 개념(더 특수)**: [트라이그램 토크나이저](#trigram) · [unicode61 토크나이저](#unicode61)

**관련 용어**: [unicode61 토크나이저](#unicode61) · [트라이그램 토크나이저](#trigram)

**이 용어를 참조하는 항목**: [FTS5](#fts5) · [역색인](#inverted-index)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="unicode61"></a>

### unicode61 토크나이저

**영문**: unicode61 · **분류**: [상태·영속성·검색](README.md#분류content-class)

유니코드 공백·구두점 기준으로 단어를 나누는 [FTS5](#fts5) 기본 토크나이저. 띄어쓰기가 있는 언어(영어·한국어 어절)에 적합하지만 중국어·일본어처럼 띄어쓰기가 없는 언어에는 부적합합니다.

**하위 개념(더 일반)**: [토크나이저 (검색)](#tokenizer)

**이 용어를 참조하는 항목**: [토크나이저 (검색)](#tokenizer) · [트라이그램 토크나이저](#trigram)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="trigram"></a>

### 트라이그램 토크나이저

**영문**: Trigram · **분류**: [상태·영속성·검색](README.md#분류content-class)

텍스트를 3글자 단위로 겹쳐 쪼개 색인하는 방식. 띄어쓰기가 없는 CJK 텍스트와 부분 문자열 검색을 지원하기 위해 Hermes가 별도 색인으로 추가 사용합니다.

> **예시**: "컨텍스트압축"은 "컨텍스, 텍스트, 스트압, 트압축"으로 쪼개져 색인되어, 띄어쓰기 없이도 부분 일치 검색이 됩니다.

**하위 개념(더 일반)**: [토크나이저 (검색)](#tokenizer)

**관련 용어**: [unicode61 토크나이저](#unicode61)

**이 용어를 참조하는 항목**: [FTS5](#fts5) · [토크나이저 (검색)](#tokenizer)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="bm25"></a>

### BM25

**영문**: BM25 (Okapi) · **분류**: [상태·영속성·검색](README.md#분류content-class)

검색 결과 순위를 매기는 고전 알고리즘(1994). 질의어가 문서에 얼마나 자주(TF), 얼마나 희귀한 단어인지(IDF), 문서 길이 대비 얼마나 밀집해 있는지를 종합 점수화합니다. [FTS5](#fts5)에 내장되어 있습니다.

> **예시**: 'the' 같은 흔한 단어의 일치보다 'FTS5' 같은 희귀 단어의 일치에 훨씬 높은 점수를 주는 것이 IDF 가중치입니다.

**하위 개념(더 일반)**: [FTS5](#fts5)

**관련 용어**: [TF-IDF](#tf-idf)

**이 용어를 참조하는 항목**: [FTS5](#fts5) · [하이브리드 검색](#hybrid-search) · [TF-IDF](#tf-idf)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="tf-idf"></a>

### TF-IDF

**영문**: TF-IDF · **분류**: [상태·영속성·검색](README.md#분류content-class)

단어 빈도(TF)와 역문서빈도(IDF)를 곱해 단어의 중요도를 재는 고전 정보검색 공식. [BM25](#bm25)의 전신입니다.

**관련 용어**: [BM25](#bm25)

**이 용어를 참조하는 항목**: [BM25](#bm25)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="external-content"></a>

### 외부 콘텐츠 테이블

**영문**: External-Content FTS Table · **분류**: [상태·영속성·검색](README.md#분류content-class)

원문을 FTS 테이블에 중복 저장하지 않고 원본 테이블을 참조만 하는 [FTS5](#fts5) 구성. 저장 공간을 절약하는 대신 [트리거](#fts-trigger)로 색인을 동기화해야 합니다.

**하위 개념(더 일반)**: [FTS5](#fts5)

**상위 개념(더 특수)**: [FTS 동기화 트리거](#fts-trigger)

**관련 용어**: [FTS 동기화 트리거](#fts-trigger)

**이 용어를 참조하는 항목**: [FTS5](#fts5)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="fts-trigger"></a>

### FTS 동기화 트리거

**영문**: FTS Sync Triggers · **분류**: [상태·영속성·검색](README.md#분류content-class)

messages 테이블의 INSERT/UPDATE/DELETE 시 자동으로 FTS 색인을 갱신하는 [SQLite](#sqlite) 트리거들. 애플리케이션 코드가 색인을 잊어버리는 실수를 원천 차단합니다.

**하위 개념(더 일반)**: [외부 콘텐츠 테이블](#external-content)

**이 용어를 참조하는 항목**: [외부 콘텐츠 테이블](#external-content)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="session-search"></a>

### 세션 검색

**영문**: Session Search · **분류**: [상태·영속성·검색](README.md#분류content-class)

에이전트가 과거 대화를 전문 검색하는 도구. [일화 기억](05_memory_self_improvement.md#episodic-memory)의 회수 수단이며, 도구 잡음을 걸러낸 뷰를 검색 대상으로 씁니다.

**하위 개념(더 일반)**: [FTS5](#fts5)

**관련 용어**: [일화 기억](05_memory_self_improvement.md#episodic-memory)

**이 용어를 참조하는 항목**: [에이전트형 RAG](#agentic-rag) · [일화 기억](05_memory_self_improvement.md#episodic-memory) · [FTS5](#fts5)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="retrieval"></a>

### 검색 증강 (RAG)

**영문**: Retrieval / RAG · **분류**: [상태·영속성·검색](README.md#분류content-class)

질의와 관련된 문서를 검색해 [LLM](01_llm_basics.md#llm) 컨텍스트에 넣어주는 기법(Retrieval-Augmented Generation, 2020). 모델이 학습하지 못한 지식을 활용하게 합니다.

> **예시**: "우리 회사 휴가 규정 알려줘"에 사내 규정 문서를 검색해 컨텍스트에 넣고 답하게 하는 것이 RAG입니다.

**상위 개념(더 특수)**: [에이전트형 RAG](#agentic-rag) · [하이브리드 검색](#hybrid-search) · [벡터 검색](#vector-search)

**관련 용어**: [전문 검색 (FTS)](#fts) · [벡터 검색](#vector-search) · [에이전트형 RAG](#agentic-rag)

**이 용어를 참조하는 항목**: [전문 검색 (FTS)](#fts) · [그라운딩](01_llm_basics.md#grounding)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="vector-search"></a>

### 벡터 검색

**영문**: Vector Search · **분류**: [상태·영속성·검색](README.md#분류content-class)

[임베딩](01_llm_basics.md#embedding) 벡터 간 거리로 의미적으로 비슷한 문서를 찾는 검색. 키워드가 달라도 의미가 같으면 찾을 수 있지만, 임베딩 모델·벡터 저장소가 추가로 필요합니다.

> **예시**: "자동차 수리"로 검색해도 "차량 정비" 문서가 나오는 것이 벡터 검색의 힘입니다. 키워드 검색으로는 놓칩니다.

**하위 개념(더 일반)**: [검색 증강 (RAG)](#retrieval)

**관련 용어**: [임베딩](01_llm_basics.md#embedding) · [하이브리드 검색](#hybrid-search)

**이 용어를 참조하는 항목**: [임베딩](01_llm_basics.md#embedding) · [하이브리드 검색](#hybrid-search) · [검색 증강 (RAG)](#retrieval)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="hybrid-search"></a>

### 하이브리드 검색

**영문**: Hybrid Search · **분류**: [상태·영속성·검색](README.md#분류content-class)

키워드 검색([BM25](#bm25))과 [벡터 검색](#vector-search)의 결과를 결합하는 방식. Hermes는 의존성 최소화를 위해 키워드 검색만 내장하고, 벡터 검색은 외부 확장에 맡깁니다.

**하위 개념(더 일반)**: [검색 증강 (RAG)](#retrieval)

**관련 용어**: [벡터 검색](#vector-search) · [BM25](#bm25)

**이 용어를 참조하는 항목**: [벡터 검색](#vector-search)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---

<a id="agentic-rag"></a>

### 에이전트형 RAG

**영문**: Agentic RAG · **분류**: [상태·영속성·검색](README.md#분류content-class)

파이프라인이 항상 검색을 수행하는 고전 RAG와 달리, 에이전트가 필요하다고 판단할 때 검색 도구를 호출하는 방식. Hermes의 [세션 검색](#session-search)이 이 패턴입니다.

**하위 개념(더 일반)**: [검색 증강 (RAG)](#retrieval)

**관련 용어**: [세션 검색](#session-search) · [도구 호출 (함수 호출)](02_agent_core.md#tool-calling)

**이 용어를 참조하는 항목**: [검색 증강 (RAG)](#retrieval)

[⬆ 문서 위로](#이-문서의-용어) · [사전 목차](README.md)

---
