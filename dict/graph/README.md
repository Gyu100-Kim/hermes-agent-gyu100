# 용어 그래프 데이터 (dict/graph/)

[사전 본문](../README.md)에 있는 모든 용어와 용어 간 관계를, 그래프 데이터베이스로 바로 들여올 수 있는 형식으로 저장한 디렉토리입니다.

## 그래프 모델

- **노드**: `Term` 레이블 하나. 속성은 `id`(영문 슬러그), `name_ko`, `name_en`, `category`(12개 범주), `definition`(링크 제거한 순수 텍스트 정의).
- **엣지(방향 있음)**:
  - `SUBCONCEPT_OF` — 하위 개념 → 상위 개념 (계층 관계. 예: `bm25 -SUBCONCEPT_OF-> fts5`)
  - `RELATED_TO` — 계층은 아니지만 함께 이해해야 하는 관련 개념
  - `MENTIONS` — 정의 본문에서 언급(링크)하지만 상위/관련으로 분류하지 않은 참조

## 파일

| 파일 | 형식 | 용도 |
|---|---|---|
| `nodes.csv` / `edges.csv` | Neo4j 헤더 규약 CSV (`id:ID`, `:START_ID`, `:END_ID`, `:TYPE`, `:LABEL`) | Neo4j `LOAD CSV`/`neo4j-admin import`, 기타 대부분의 도구 |
| `import_neo4j.cypher` | Cypher 스크립트 | Neo4j(및 Cypher 호환 DB인 Memgraph)에서 위 CSV를 읽어 그래프 생성 |
| `graph.graphml` | GraphML (TinkerPop 호환) | **JanusGraph** 등 Apache TinkerPop/Gremlin 계열 DB |
| `graph.json` | 일반 JSON (`nodes`/`edges` 배열) | 커스텀 스크립트·시각화 도구용 범용 형식 |

## 대표 오픈소스 그래프 DB 선정: JanusGraph

Neo4j 외의 대표 오픈소스 그래프 DB로는 **[JanusGraph](https://janusgraph.org/)** 를 선정했습니다.

- **완전한 오픈소스**: Apache 2.0 라이선스, Linux Foundation 산하 프로젝트 (Neo4j Community는 GPLv3이고 핵심 기능 일부가 상용판 전용).
- **표준 기반**: Apache TinkerPop / Gremlin 표준 위에 구축되어, 같은 GraphML 파일을 TinkerPop 호환 DB 어디서든 재사용 가능.
- **확장성**: Cassandra/HBase 백엔드로 대규모 그래프까지 확장.

### JanusGraph(Gremlin Console)로 가져오기

```groovy
graph = JanusGraphFactory.open('inmemory')      // 또는 실제 스토리지 설정
graph.io(IoCore.graphml()).readGraph('dict/graph/graph.graphml')
g = graph.traversal()
// 예: "컨텍스트 압축"의 상위 개념 사슬
g.V().has('name_en', 'Context Compression').repeat(out('SUBCONCEPT_OF')).emit().values('name_ko')
```

### Neo4j로 가져오기

1. `nodes.csv`, `edges.csv`를 Neo4j의 `import/` 디렉토리에 복사
2. `import_neo4j.cypher` 실행 (Browser 또는 `cypher-shell -f import_neo4j.cypher`)

또는 초기 적재라면 한 번에:

```bash
neo4j-admin database import full neo4j --nodes=nodes.csv --relationships=edges.csv
```

### 활용 예시 쿼리 (Cypher)

```cypher
// 특정 용어를 이해하기 위해 알아야 하는 모든 하위 개념 (역방향 계층 탐색)
MATCH (t:Term {name_en: 'Context Compression'})<-[:SUBCONCEPT_OF*]-(sub)
RETURN sub.name_ko;

// 두 용어 사이의 최단 연결 경로
MATCH p = shortestPath(
  (a:Term {id: 'skill'})-[*..6]-(b:Term {id: 'prompt-caching'}))
RETURN [n IN nodes(p) | n.name_ko];

// 연결이 가장 많은 허브 개념 Top 10
MATCH (t:Term)-[r]-()
RETURN t.name_ko, count(r) AS degree ORDER BY degree DESC LIMIT 10;
```
