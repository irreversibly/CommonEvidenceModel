IF OBJECT_ID('@targetTable', 'U') IS NOT NULL DROP TABLE @targetTable;

WITH CTE_VOCAB_PULL AS (
	SELECT *
	FROM @stcmTable
	WHERE SOURCE_VOCABULARY_ID = 'MESH_TO_STANDARD'
)
SELECT /*ID,*/
      SOURCE_ID,
      SOURCE_CODE_1,
      SOURCE_CODE_TYPE_1,
      SOURCE_CODE_NAME_1,
      CASE WHEN v1.TARGET_CONCEPT_ID IS NULL THEN 0 ELSE v1.TARGET_CONCEPT_ID END AS CONCEPT_ID_1,
      RELATIONSHIP_ID,
      SOURCE_CODE_2,
      SOURCE_CODE_TYPE_2,
      SOURCE_CODE_NAME_2,
      CASE WHEN v2.TARGET_CONCEPT_ID IS NULL THEN 0 ELSE v2.TARGET_CONCEPT_ID END AS CONCEPT_ID_2,
      UNIQUE_IDENTIFIER,
      UNIQUE_IDENTIFIER_TYPE,
      ARTICLE_TITLE,
      --ABSTRACT, /*Not including for now as this table has become large*/
      --ABSTRACT_ORDER,
      JOURNAL,
      ISSN,
      PUBLICATION_YEAR,
      PUBLICATION_TYPE
INTO @targetTable
FROM @sourceTable c
	LEFT OUTER JOIN CTE_VOCAB_PULL v1
		ON v1.SOURCE_CODE = c.SOURCE_CODE_1
	LEFT OUTER JOIN CTE_VOCAB_PULL v2
		ON v2.SOURCE_CODE = c.SOURCE_CODE_2;

CREATE INDEX IDX_MEDLINE_AVILLACH_CONCEPT_ID_1_CONCEPT_ID_2 ON @targetTable (CONCEPT_ID_1, CONCEPT_ID_2);

CREATE INDEX IDX_CEM_TRANSLATED_SOURCE_CODE_1
ON @targetTable (SOURCE_CODE_1)
/*INCLUDE (SOURCE_CODE_2)*/;
