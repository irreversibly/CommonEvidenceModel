IF OBJECT_ID('@storeData', 'U') IS NOT NULL DROP TABLE @storeData;

CREATE TABLE @storeData (
  DATA_TYPE VARCHAR(100),
  MAPPING_TYPE  VARCHAR(50),
  OUTCOME_OF_INTEREST_CONCEPT_ID BIGINT,
  OUTCOME_OF_INTEREST_CONCEPT_NAME  VARCHAR(500),
  SOURCE_CODE VARCHAR(500),
  SOURCE_CODE_NAME  VARCHAR(500),
  UNIQUE_IDENTIFIER VARCHAR(500),
  UNIQUE_IDENTIFIER_TYPE  VARCHAR(150)
);
