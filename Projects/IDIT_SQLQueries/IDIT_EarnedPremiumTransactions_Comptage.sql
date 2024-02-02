-- SCRIPT : IDIT_EarnedPremiumTransaction_comptages.SQL
-- LIST BATCH DETAILS ON A GIVEN TIMESTAMP RANGE
-- EASE ANALYTICS WITH EXCEL / PIVOT TABLES
-- FORMATED WITH : HTTPS://SQLFORMAT.ORG/

DECLARE @ACCOUNTING_DATE DATETIME = '2024-01-31 15:01:17'; -- START DATE RANGE

-- Donne le nombre de transactions / lignes depuis AC_TRANSACTIONS 
select count(*) from AC_TRANSACTION 
with (nolock) where TRANSACTION_TYPE = 10077
and transaction_date > @ACCOUNTING_DATE; 

-- Donne le nombre de lignes en AC_GL_INTERFACE (transaction type donne les eligibles pour GL Export)
select count(*) from AC_GL_INTERFACE with (nolock) 
where TRANSACTION_TYPE = 10077
	and INSERT_DATE > @ACCOUNTING_DATE;

-- Donne le nombre de transactions / lignes depuis GL interface  rapprochés avec AC_TRANSACTIONS
select distinct e.TRANSACTION_ID from AC_GL_INTERFACE i with (nolock) 
inner join AC_ENTRY e with (nolock) on i.ENTRY_ID = e.ID
inner join AC_TRANSACTION t with (nolock) on e.TRANSACTION_ID = t.ID
where i.TRANSACTION_TYPE = 10077
and i.INSERT_DATE > @ACCOUNTING_DATE;

-- 4'042'877 M de transactions coté IDIT / 3 M coté SAP
 
-- select count(l) from AC_TRANSACTION With (nolock) 
-- where TRANSACTION_TYPE = 10077 
-- AND TRANSACTION_DATE > cast(@ACCOUNTING_DATE as date)
-- and cast(ACCOUNTING_DATE as date) = cast(@ACCOUNTING_DATE as date);

--and TRANFER_NR is NULL
