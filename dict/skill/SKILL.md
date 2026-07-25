---
name: knowledge-graph-dictionary
description: "코드베이스 용어·개념 사전을 지식 그래프(Content/ContentClass 노드, UPPER_OF 계층)로 구축·유지보수하는 절차. dict/ 구축 과정의 시행착오와 최종 설계 사상을 담음."
version: 1.0.0
author: gyu100, Devin
license: MIT
dependencies: []
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [Dictionary, Glossary, Knowledge-Graph, Neo4j, GraphML, Documentation, Korean, UPPER_OF, ContentClass]
    related_skills: []

---

# 지식 그래프 용어·개념 사전 구축 스킬

코드베이스(또는 임의 도메인)의 용어·개념 사전을 **사람이 읽기 좋은 Markdown**과 **그래프 DB로 옮기기 좋은 데이터**(CSV·Cypher·GraphML·JSON)로 동시에 구축·유지보수하는 절차입니다. `dict/`가 이 스킬로 만든 실제 결과물입니다.

## 발동 조건 (Trigger)

다음 요청이 있을 때 이 스킬을 사용합니다.

- "용어 사전 / 개념 사전 / 용어집을 만들어줘 (또는 확장·수정해줘)"
- "용어 간 계층/관계를 지식 그래프로 정리해줘"
- "사전 데이터를 Neo4j(또는 다른 그래프 DB)로 옮길 수 있게 해줘"
- 기존 `dict/`에 용어를 추가하거나 관계를 고치는 모든 작업

## 최종 설계 사상 (반드시 이 순서로 이해할 것)

### 1. 사전 = 지식 그래프

모든 용어·개념은 노드이고, 노드 간 관계는 방향성 엣지입니다. Markdown 문서와 그래프 데이터는 **같은 원본 데이터에서 함께 생성**되어야 하며, 손으로 따로 관리하면 반드시 어긋납니다.

### 2. 노드 명(label) — 노드의 역할

| Label | 의미 | 규칙 |
|---|---|---|
| `Content` | 용어/개념 노드 | 사전의 모든 항목 |
| `ContentClass` | 분류 노드 | 모든 `Content`는 `BELONGS_TO` 엣지로 최소 1개 `ContentClass`에 연결 |

label 종류는 최소한으로 유지합니다(역할 규정 목적). 분류 자체는 `ContentClass` 노드로 표현하지, label을 늘려서 표현하지 않습니다.

### 3. 계층 방향 — 핵심 규칙 (가장 많이 틀리는 부분)

**하위 = 더 일반적·근본적, 상위 = 더 특수.**

판별 기준은 단 하나, **개념적 의존(활용) 관계**입니다:

> 개념 B를 규정(정의·이해)하기 위해 개념 A가 필요하면 — 즉 **B가 A를 활용해서 만들어진 개념**이면 — A가 B의 **하위**, B가 A의 **상위**다.

- 예: Attention을 활용해 만든 것이 Transformer("Attention Is All You Need") → **Transformer가 Attention의 상위**. Attention → Transformer → LLM 순으로 상위로 올라감.
- 예: 파인튜닝 → PEFT → LoRA 순으로 상위.
- **예시 규칙**: 용어 A를 설명하기 위해 용어 B를 예시로 들었다면 B는 A의 상위다. "Transformer를 활용한 예시는 BERT" → BERT가 Transformer의 상위.

그래프 엣지는 `(더 특수한 개념)-[:UPPER_OF]->(더 일반적인 개념)` 방향으로 저장합니다.

### 4. origin(최초 등장 시점) — 참고 속성일 뿐

모든 `Content` 노드에 개념이 처음 생긴 연월(`origin`)을 **알려진 정밀도까지만** 기록합니다(`2014-09`, `2018`, `1970년대(인지심리)` 등). 상위/하위 판별에 참고가 되지만, **상위 용어가 항상 하위 용어보다 늦게 생기는 것은 아니므로** 절대 기준은 항상 개념적 의존 관계입니다. 확인되지 않은 날짜를 정밀하게 지어내지 마세요.

### 5. 엣지 4종

| 엣지 | 방향 | 의미 |
|---|---|---|
| `UPPER_OF` | 특수 → 일반 | 계층. source가 target을 활용해 만들어진 상위 개념 |
| `RELATED_TO` | 정의한 쪽 → 대상 | 계층이 아닌 관련 개념 |
| `MENTIONS` | 정의한 쪽 → 언급 대상 | 본문 링크 중 상위·하위/관련으로 분류하지 않은 참조 |
| `BELONGS_TO` | Content → ContentClass | 분류 소속 (계층 아님) |

같은 쌍이 `UPPER_OF`와 `RELATED_TO`에 중복되지 않게 하세요(up이 우선). 서로 연결되지 않는 독립 개념도 허용됩니다.

## 절차 (Steps)

1. **용어 수집** — 저장소의 코드·문서에서 주요·세부 용어를 수집합니다. 설명을 쓰다가 등장하는 새 개념도 항목으로 추가하는 방식으로 확장합니다(닫힘 원칙: 본문 링크는 모두 사전 안에서 해소).
2. **원본 데이터 작성** — 용어를 코드/데이터 파일(예: Python dict 목록)로 관리합니다. 항목당: `id`(anchor용 슬러그), `ko`, `en`, `cat`(ContentClass), `d`(정의, `{{다른-용어-id}}` 링크 문법), `ex`(예시, 선택), `up`(이 용어를 규정하는 데 필요한 더 근본적인 개념 id 목록), `rel`(관련), `origin`.
   - **명명 주의**: `up` 필드는 "하위(더 일반) 개념 목록"입니다. 생성되는 엣지는 `(이 용어)-[:UPPER_OF]->(up의 각 대상)`. 필드명과 엣지명이 헷갈리기 쉬우므로 생성기 주석에 명시하세요.
3. **생성기 작성** — 하나의 생성 스크립트가 원본 데이터에서 다음을 모두 생성합니다:
   - 분류별 Markdown(항목 anchor `<a id="...">`, 본문 상호 링크, 하위/상위/관련/역링크 표시, 최초 등장 표시)
   - `README.md`(통계, 사용법, 설계 이념, 노드·엣지 모델, mermaid 구조 예시, 분류 표, 계층의 뿌리, 허브 용어, 전체 색인 — 통계는 데이터에서 자동 산출)
   - `graph/nodes.csv`·`edges.csv`(Neo4j 헤더: `id:ID`, `:LABEL`, `:START_ID`, `:END_ID`, `:TYPE`), `import_neo4j.cypher`, `graph.graphml`(TinkerPop/JanusGraph용 `labelV`/`labelE`), `graph.json`
4. **검증 (필수, 생성할 때마다)**:
   - 내부 링크·anchor 전수 검사: broken 0
   - 그래프 무결성: dangling 엣지 0, 모든 Content에 `BELONGS_TO` ≥ 1
   - **UPPER_OF 순환(cycle) 검사: 0** — 순환이 있으면 계층 방향을 잘못 잡은 것
   - GraphML/JSON 파싱 확인
   - 대표 경로 확인(예: Attention → Transformer → LLM 방향이 맞는지)
5. **PR** — 생성 결과물만 커밋합니다. 소스코드는 건드리지 않습니다.

## 시행착오 기록 (Pitfalls — 실제로 겪은 것들)

1. **계층 방향 뒤집기 (v2의 실수)** — "A를 구성 요소로 포함한다"를 A의 상위로 오해해 "어텐션이 트랜스포머의 상위"가 되었습니다. 교훈: 포함/구성이 아니라 **활용/의존** 방향으로 판단할 것. JSON-RPC→MCP, WebSocket→CDP, 네임스페이스·cgroups→컨테이너, 역색인→FTS, TF-IDF→BM25 등 같은 유형의 오류가 광범위하게 있었고 전수 재검토로 바로잡았습니다.
2. **origin을 판별 기준으로 쓰려는 유혹** — 시간 순서는 대체로 의존 방향과 일치하지만 항상은 아닙니다(나중에 나온 개념이 기존 개념의 바탕을 정리하는 경우). origin은 참고 속성으로만.
3. **up 필드와 UPPER_OF 엣지의 의미 혼동** — 데이터의 `up`은 "나의 하위(근본) 개념 목록"인데 엣지 이름은 `UPPER_OF`(내가 상위)라 방향을 반대로 읽기 쉽습니다. 문서와 생성기 주석에 방향을 반드시 명시.
4. **손 편집으로 인한 불일치** — 생성물(Markdown/CSV/GraphML/JSON)을 직접 고치면 다음 재생성 때 사라지거나 어긋납니다. 항상 원본 데이터·생성기를 고치고 재생성.
5. **통계 숫자 하드코딩** — README의 용어 수·엣지 수를 손으로 쓰면 즉시 낡습니다. 생성기에서 자동 산출.
6. **rel/up 중복** — 같은 대상이 up과 rel 양쪽에 있으면 그래프에 중복 의미가 생깁니다. up 우선으로 rel에서 제거.
7. **origin 누락** — 새 용어 추가 시 origin을 빠뜨리면 안 됩니다. 생성기에 누락 검사(assert)를 넣어 강제.
8. **mermaid 규칙** — 색상 미사용, 라벨은 큰따옴표로 감쌈(한글·특수문자 안전).

## 산출물 구조 (dict/의 실제 구조)

```
dict/
├── README.md            # 통계·사용법·설계 이념·모델·색인 (전부 생성됨)
├── 01_*.md ~ 13_*.md    # 분류(ContentClass)별 용어 문서 (생성됨)
├── graph/
│   ├── README.md        # 그래프 모델·적재 방법 문서
│   ├── nodes.csv        # Neo4j admin import 형식 (:LABEL 포함)
│   ├── edges.csv        # :START_ID,:END_ID,:TYPE
│   ├── import_neo4j.cypher
│   ├── graph.graphml    # JanusGraph(TinkerPop) 등 오픈소스 그래프 DB용
│   └── graph.json       # 범용 JSON
└── skill/
    └── SKILL.md         # 이 문서
```
