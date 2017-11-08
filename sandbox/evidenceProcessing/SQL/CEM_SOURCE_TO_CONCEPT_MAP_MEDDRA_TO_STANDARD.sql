/* replace any existing MEDDRA_TO_STANDARD code mappings in the STCM table */

DROP INDEX IF EXISTS {@targetDialect == "postgresql"} ? {@schema.}IDX_STCM_SOURCE_CODE {@targetDialect == "sql server"} ? {ON @fqTableName};

DELETE FROM @fqTableName where SOURCE_VOCABULARY_ID = 'MEDDRA_TO_STANDARD';

INSERT INTO @fqTableName (SOURCE_CODE, SOURCE_CONCEPT_ID, SOURCE_VOCABULARY_ID,
  SOURCE_CODE_DESCRIPTION, TARGET_CONCEPT_ID, TARGET_VOCABULARY_ID,
  VALID_START_DATE, VALID_END_DATE, INVALID_REASON)

  /*PLACE HOLDER UNTIL WE BUILD A MAP, WE DO NOT WANT TO LEVERAGE THE VOCAB*/
  SELECT DISTINCT
    '' AS SOURCE_CODE,
    0 AS SOURCE_CONCEPT_ID,
    'MEDDRA_TO_STANDARD' AS SOURCE_VOCABULARY_ID,
    NULL AS SOURCE_CODE_DESCRIPTION,
    0 AS TARGET_CONCEPT_ID,
    NULL AS TARGET_VOCABULARY_ID,
  	CAST('1970-01-01' AS DATE) AS VALID_START_DATE,
    CAST('2099-12-31' AS DATE) AS VALID_END_DATE,
    NULL AS INVALID_REASON;

CREATE INDEX IDX_STCM_SOURCE_CODE ON @fqTableName (SOURCE_CODE);