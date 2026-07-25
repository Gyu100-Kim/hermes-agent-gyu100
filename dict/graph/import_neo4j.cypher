// Neo4j import script for the hermes-agent term dictionary graph (v2)
// Node labels: Content (용어/개념), ContentClass (분류)
// Edges: UPPER_OF (더 특수 -> 더 일반; source는 target의 상위 개념),
//        RELATED_TO, MENTIONS, BELONGS_TO (Content -> ContentClass)
// Usage: place nodes.csv/edges.csv in the DBMS import directory, then run this script.
CREATE CONSTRAINT content_id IF NOT EXISTS FOR (t:Content) REQUIRE t.id IS UNIQUE;
CREATE CONSTRAINT class_id   IF NOT EXISTS FOR (c:ContentClass) REQUIRE c.id IS UNIQUE;
LOAD CSV WITH HEADERS FROM 'file:///nodes.csv' AS row
CALL {
  WITH row
  FOREACH (_ IN CASE WHEN row.`:LABEL` = 'Content' THEN [1] ELSE [] END |
    MERGE (t:Content {id: row.`id:ID`})
    SET t.name_ko = row.name_ko, t.name_en = row.name_en,
        t.category = row.category, t.definition = row.definition)
  FOREACH (_ IN CASE WHEN row.`:LABEL` = 'ContentClass' THEN [1] ELSE [] END |
    MERGE (c:ContentClass {id: row.`id:ID`})
    SET c.name_ko = row.name_ko, c.name_en = row.name_en, c.definition = row.definition)
} IN TRANSACTIONS;
LOAD CSV WITH HEADERS FROM 'file:///edges.csv' AS row
MATCH (s {id: row.`:START_ID`}), (d {id: row.`:END_ID`})
FOREACH (_ IN CASE WHEN row.`:TYPE` = 'UPPER_OF'   THEN [1] ELSE [] END | MERGE (s)-[:UPPER_OF]->(d))
FOREACH (_ IN CASE WHEN row.`:TYPE` = 'RELATED_TO' THEN [1] ELSE [] END | MERGE (s)-[:RELATED_TO]->(d))
FOREACH (_ IN CASE WHEN row.`:TYPE` = 'MENTIONS'   THEN [1] ELSE [] END | MERGE (s)-[:MENTIONS]->(d))
FOREACH (_ IN CASE WHEN row.`:TYPE` = 'BELONGS_TO' THEN [1] ELSE [] END | MERGE (s)-[:BELONGS_TO]->(d));
