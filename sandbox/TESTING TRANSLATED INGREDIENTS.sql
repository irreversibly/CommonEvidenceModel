SELECT DISTINCT c.CONCEPT_ID
FROM TRANSLATED.AEOLUS s
  JOIN VOCABULARY.CONCEPT_ANCESTOR ca
    ON ca.DESCENDANT_CONCEPT_ID = s.CONCEPT_ID_1
  JOIN VOCABULARY.CONCEPT c
    ON c.CONCEPT_ID = ca.ANCESTOR_CONCEPT_ID
    AND c.CONCEPT_CLASS_ID = 'Ingredient'