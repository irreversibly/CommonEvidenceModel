IF OBJECT_ID('@storeData', 'U') IS NOT NULL DROP TABLE @storeData;
IF OBJECT_ID('tempdb..#TEMP_1', 'U') IS NOT NULL DROP TABLE #TEMP_1;
IF OBJECT_ID('tempdb..#TEMP_2', 'U') IS NOT NULL DROP TABLE #TEMP_2;
IF OBJECT_ID('tempdb..#TEMP_3', 'U') IS NOT NULL DROP TABLE #TEMP_3;
IF OBJECT_ID('tempdb..#TEMP_4', 'U') IS NOT NULL DROP TABLE #TEMP_4;
IF OBJECT_ID('tempdb..#TEMP_5', 'U') IS NOT NULL DROP TABLE #TEMP_5;

/*PMID DESCENDANT COUNT*/
SELECT u.CONCEPT_ID AS OUTCOME_OF_INTEREST_CONCEPT_ID,
	u.CONCEPT_NAME AS OUTCOME_OF_INTEREST_CONCEPT_NAME,
	CASE WHEN u.PERSON_COUNT_RC IS NULL THEN 0 ELSE u.PERSON_COUNT_RC END PERSON_COUNT_RC,
	u.PERSON_COUNT_DC,
	COUNT(DISTINCT descendant.UNIQUE_IDENTIFIER) AS DESCENDANT_PMID_COUNT
INTO #TEMP_1
FROM @conceptUniverseData u
	LEFT OUTER JOIN @adeSummaryData descendant
		ON descendant.OUTCOME_OF_INTEREST_CONCEPT_ID = u.CONCEPT_ID
		AND descendant.MAPPING_TYPE = 'DESCENDANT'
GROUP BY u.CONCEPT_ID, u.CONCEPT_NAME, u.PERSON_COUNT_RC, u.PERSON_COUNT_DC;

/*PMID EXACT COUNT*/
SELECT u.CONCEPT_ID AS OUTCOME_OF_INTEREST_CONCEPT_ID,
	COUNT(DISTINCT exact.UNIQUE_IDENTIFIER) AS EXACT_PMID_COUNT
INTO #TEMP_2
FROM @conceptUniverseData u
  LEFT OUTER JOIN @adeSummaryData exact
		ON exact.OUTCOME_OF_INTEREST_CONCEPT_ID = u.CONCEPT_ID
		AND exact.MAPPING_TYPE = 'EXACT'
GROUP BY u.CONCEPT_ID;

/*PMID PARENT COUNT*/
SELECT u.CONCEPT_ID AS OUTCOME_OF_INTEREST_CONCEPT_ID,
	COUNT(DISTINCT parent.UNIQUE_IDENTIFIER) AS PARENT_PMID_COUNT
INTO #TEMP_3
FROM @conceptUniverseData u
	LEFT OUTER JOIN @adeSummaryData parent
		ON parent.OUTCOME_OF_INTEREST_CONCEPT_ID = u.CONCEPT_ID
		AND parent.MAPPING_TYPE = 'PARENT'
GROUP BY u.CONCEPT_ID;

/*PMID ANCESTOR COUNT*/
SELECT u.CONCEPT_ID AS OUTCOME_OF_INTEREST_CONCEPT_ID,
	COUNT(DISTINCT ancestor.UNIQUE_IDENTIFIER) AS ANCESTOR_PMID_COUNT
INTO #TEMP_4
FROM @conceptUniverseData u
	LEFT OUTER JOIN @adeSummaryData ancestor
		ON ancestor.OUTCOME_OF_INTEREST_CONCEPT_ID = u.CONCEPT_ID
		AND ancestor.MAPPING_TYPE = 'ANCESTOR'
GROUP BY u.CONCEPT_ID;

SELECT u.CONCEPT_ID AS OUTCOME_OF_INTEREST_CONCEPT_ID,
	MAX(CASE WHEN i.CONCEPT_ID IS NULL THEN 0 ELSE 1 END) AS INDICATION,
	{@outcomeOfInterest == 'condition'}?{MAX(CASE WHEN tb.CONCEPT_ID IS NULL THEN 0 ELSE 1 END) AS TOO_BROAD,}
	MAX(CASE WHEN di.CONCEPT_ID IS NULL THEN 0 ELSE 1 END) AS DRUG_INDUCED,
	{@outcomeOfInterest == 'condition'}?{MAX(CASE WHEN p.CONCEPT_ID IS NULL THEN 0 ELSE 1 END) AS PREGNANCY,}
	MAX(CASE WHEN s.CONCEPT_ID IS NULL THEN 0 ELSE 1 END) AS SPLICER,
	MAX(CASE WHEN f.CONCEPT_ID IS NULL THEN 0 ELSE 1 END) AS FAERS,
	MAX(CASE WHEN ue.CONCEPT_ID IS NULL THEN 0 ELSE 1 END) AS USER_EXCLUDED,
	MAX(CASE WHEN ui.CONCEPT_ID IS NULL THEN 0 ELSE 1 END) AS USER_INCLUDED
INTO #TEMP_5
FROM @conceptUniverseData u
	LEFT OUTER JOIN @indicationData i
		ON i.CONCEPT_ID = u.CONCEPT_ID

	{@outcomeOfInterest == 'condition'}?{
  	LEFT OUTER JOIN @broadConceptsData  tb
  		ON tb.CONCEPT_ID = u.CONCEPT_ID
	}

	LEFT OUTER JOIN @drugInducedConditionsData di
		ON di.CONCEPT_ID = u.CONCEPT_ID

	{@outcomeOfInterest == 'condition'}?{
  	LEFT OUTER JOIN @pregnancyConditionData p
  		ON p.CONCEPT_ID = u.CONCEPT_ID
  }

	LEFT OUTER JOIN @splicerConceptData s
		ON s.CONCEPT_ID = u.CONCEPT_ID
	LEFT OUTER JOIN @faersConceptsData f
		ON f.CONCEPT_ID = u.CONCEPT_ID
	LEFT OUTER JOIN @conceptsToExclude ue
		ON ue.CONCEPT_ID = u.CONCEPT_ID
	LEFT OUTER JOIN @conceptsToInclude ui
		ON ui.CONCEPT_ID = u.CONCEPT_ID
GROUP BY u.CONCEPT_ID;

/*PULL TOGETHER*/
SELECT t1.OUTCOME_OF_INTEREST_CONCEPT_ID, t1.OUTCOME_OF_INTEREST_CONCEPT_NAME,
  t1.PERSON_COUNT_RC, t1.PERSON_COUNT_DC,
  t1.DESCENDANT_PMID_COUNT,
  t2.EXACT_PMID_COUNT,
  t3.PARENT_PMID_COUNT,
  t4.ANCESTOR_PMID_COUNT,
  t5.INDICATIOn,
  {@outcomeOfInterest == 'condition'}?{t5.TOO_BROAD,}
  t5.DRUG_INDUCED,
  {@outcomeOfInterest == 'condition'}?{t5.PREGNANCY,}
  t5.SPLICER,
  t5.FAERS,
  t5.USER_EXCLUDED,
  t5.USER_INCLUDED
INTO @storeData
FROM #TEMP_1 t1
  JOIN #TEMP_2 t2
    ON t1.OUTCOME_OF_INTEREST_CONCEPT_ID = t2.OUTCOME_OF_INTEREST_CONCEPT_ID
  JOIN #TEMP_3 t3
    ON t1.OUTCOME_OF_INTEREST_CONCEPT_ID = t3.OUTCOME_OF_INTEREST_CONCEPT_ID
  JOIN #TEMP_4 t4
    ON t1.OUTCOME_OF_INTEREST_CONCEPT_ID = t4.OUTCOME_OF_INTEREST_CONCEPT_ID
  JOIN #TEMP_5 t5
    ON t1.OUTCOME_OF_INTEREST_CONCEPT_ID = t5.OUTCOME_OF_INTEREST_CONCEPT_ID;

CREATE INDEX IDX_SUMMARIZE_EVIDENCE ON @storeData (OUTCOME_OF_INTEREST_CONCEPT_ID);

ALTER TABLE @storeData OWNER TO RW_GRP;

