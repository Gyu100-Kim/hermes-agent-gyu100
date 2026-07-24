// Neo4j import script for the hermes-agent term dictionary graph
// Usage: place nodes.csv/edges.csv in the DBMS import directory, then run this script.
CREATE CONSTRAINT term_id IF NOT EXISTS FOR (t:Term) REQUIRE t.id IS UNIQUE;
LOAD CSV WITH HEADERS FROM 'file:///nodes.csv' AS row
MERGE (t:Term {id: row.`id:ID`})
SET t.name_ko = row.name_ko, t.name_en = row.name_en, t.category = row.category, t.definition = row.definition;
LOAD CSV WITH HEADERS FROM 'file:///edges.csv' AS row
MATCH (s:Term {id: row.`:START_ID`}), (d:Term {id: row.`:END_ID`})
FOREACH (_ IN CASE WHEN row.`:TYPE` = 'SUBCONCEPT_OF' THEN [1] ELSE [] END | MERGE (s)-[:SUBCONCEPT_OF]->(d))
FOREACH (_ IN CASE WHEN row.`:TYPE` = 'RELATED_TO'    THEN [1] ELSE [] END | MERGE (s)-[:RELATED_TO]->(d))
FOREACH (_ IN CASE WHEN row.`:TYPE` = 'MENTIONS'      THEN [1] ELSE [] END | MERGE (s)-[:MENTIONS]->(d));
