select
  CASE WHEN o.OPTIMIZED = 1 THEN 1 ELSE 0 END NEGATIVE_CONTROL,
  d.*,
  CASE WHEN o.OPTIMIZED = 0 AND o.NOT_PREVELANT = 0 THEN 1 ELSE 0 END OPTIMIZED_OUT,
  CASE WHEN o.NOT_PREVELANT = 1 THEN 1 ELSE 0 END NOT_PREVALENT
FROM @summaryData d
  LEFT OUTER JOIN @summaryOptimizedData o
    ON d.OUTCOME_OF_INTEREST_CONCEPT_ID = o.OUTCOME_OF_INTEREST_CONCEPT_ID
{@outcomeOfInterest == 'drug'}?{
  WHERE d.OUTCOME_OF_INTEREST_CONCEPT_ID IN (
    SELECT CONCEPT_ID FROM @vocabulary.CONCEPT WHERE DOMAIN_ID = 'Drug' AND CONCEPT_CLASS_ID = 'Ingredient'
  )
}
ORDER BY 1 DESC, SORT_ORDER, OUTCOME_OF_INTEREST_CONCEPT_NAME
