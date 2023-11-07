-- List Transaction type code and description.
SELECT id,
       description
FROM T_TRANSACTION_TYPE
WHERE description like '%'