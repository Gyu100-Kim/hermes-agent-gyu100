# dict/graph/ — 용어 그래프 데이터 (그래프 DB 전환용)

[⬆ 사전 목차로](../README.md)

`dict/` 용어 사전의 모든 노드와 관계를 그래프 DB로 옮기기 좋은 형식으로 저장한 디렉토리입니다.

## 그래프 모델 (v2)

### 노드 명(label)

노드 명은 **노드의 역할**을 규정합니다.

| Label | 의미 | 개수 |
|---|---|---|
| `Content` | 용어 사전을 구성하는 용어/개념 노드 | 237 |
| `ContentClass` | Content의 분류 정보를 갖는 노드. 모든 `Content`는 최소 1개의 `ContentClass`에 `BELONGS_TO` 엣지로 연결됩니다 | 13 |

노드 속성: `id`(고유 식별자), `name_ko`, `name_en`, `category`, `definition`(예시 포함 평문).

### 엣지(관계)

| 타입 | 방향 | 의미 |
|---|---|---|
| `UPPER_OF` | (더 특수한 개념) → (더 일반적인 개념) | **계층 엣지.** source는 target의 **상위 개념**입니다. 이 사전의 계층 방향은 "하위로 갈수록 더 일반적, 상위로 갈수록 더 특수"입니다. 예: `(LoRA)-[:UPPER_OF]->(PEFT)`, `(PEFT)-[:UPPER_OF]->(파인튜닝)`, `(시스템 프롬프트)-[:UPPER_OF]->(프롬프트)` |
| `RELATED_TO` | 방향성 있음(정의한 쪽 → 대상) | 계층은 아니지만 함께 이해하면 좋은 관련 개념 |
| `MENTIONS` | 정의한 쪽 → 언급된 용어 | 정의/예시 본문에서 링크로 언급되지만 상위·하위/관련로 분류하지 않은 참조 |
| `BELONGS_TO` | `Content` → `ContentClass` | 해당 분류(class)에 속한다는 의미. 계층(상위/하위) 엣지가 아닙니다 |

하나의 용어는 여러 용어와 동시에 연결될 수 있으며(다중 연결), 연결이 없는 독립 개념도 존재할 수 있습니다.

## 파일 구성

| 파일 | 용도 |
|---|---|
| `nodes.csv` / `edges.csv` | **Neo4j** `LOAD CSV` 및 `neo4j-admin import` 호환 CSV (`id:ID`, `:LABEL`, `:START_ID`, `:END_ID`, `:TYPE` 헤더) |
| `import_neo4j.cypher` | Neo4j 적재 스크립트 (제약 조건 + 노드/엣지 MERGE) |
| `graph.graphml` | **JanusGraph** 등 Apache TinkerPop 계열 그래프 DB용 GraphML |
| `graph.json` | 범용 JSON (시각화 도구·커스텀 스크립트용) |

## Neo4j 적재

1. `nodes.csv`, `edges.csv`를 Neo4j DBMS의 `import/` 디렉토리에 복사
2. `import_neo4j.cypher` 실행

예시 쿼리:

```cypher
// LoRA에서 하위(더 일반) 방향으로 계층을 따라 내려가기: LoRA → PEFT → 파인튜닝 → 사전학습 ...
MATCH p = (t:Content {id: 'lora'})-[:UPPER_OF*]->(base)
RETURN p;

// 어떤 개념의 상위(더 특수) 개념들 = 그 개념을 구체화한 것들
MATCH (spec)-[:UPPER_OF]->(t:Content {id: 'peft'})
RETURN spec.name_ko;

// 분류별 용어 목록
MATCH (t:Content)-[:BELONGS_TO]->(c:ContentClass {id: 'class-learning'})
RETURN t.name_ko;
```

## JanusGraph (오픈소스 그래프 DB) 적재

Neo4j 외 대표 오픈소스 그래프 DB로는 **JanusGraph**(Apache 2.0, TinkerPop/Gremlin 표준, Cassandra·HBase 등으로 수평 확장)를 선정했습니다. GraphML은 TinkerPop 표준 입출력 형식이므로 그대로 사용할 수 있습니다.

```groovy
graph = JanusGraphFactory.open('inmemory')
graph.io(IoCore.graphml()).readGraph('graph.graphml')
g = graph.traversal()
// LoRA에서 더 일반적인 개념 방향으로 탐색
g.V().has('name_en', 'Low-Rank Adaptation').out('UPPER_OF').values('name_ko')
```

GraphML의 `labelV` 속성이 노드 명(`Content`/`ContentClass`), `labelE`가 엣지 타입입니다. 같은 파일을 TinkerGraph, Amazon Neptune(변환 후) 등 다른 TinkerPop 호환 시스템에도 쓸 수 있습니다.
