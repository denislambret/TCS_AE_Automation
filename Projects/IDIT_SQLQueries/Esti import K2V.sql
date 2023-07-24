-- Idit MIGDR
DECLARE @TotalAccounts INT = 384448 
      , @TotalPolicies INT = 596960 
      , @ImportDate DATETIME = '2022-08-02 00:00' -- 12h49

SELECT CONVERT(DATE, crl.UPDATE_DATE) AS UPDATE_DATE
     , count(*) qty
     , min(crl.UPDATE_DATE) time_start
     , max(crl.UPDATE_DATE) time_end
     , DATEDIFF(minute, min(crl.UPDATE_DATE), max(crl.UPDATE_DATE) ) time_elapse
     , 100.0 * count(*) / @TotalAccounts Pct
     , @TotalAccounts - count(*) qty_remain
     , DATEDIFF(minute, min(crl.UPDATE_DATE), max(crl.UPDATE_DATE) ) * (@TotalAccounts - count(*)) / count(*)  time_remain
     , DATEADD( minute
              , DATEDIFF(minute, min(crl.UPDATE_DATE), max(crl.UPDATE_DATE) ) * (@TotalAccounts - count(*)) / count(*)  
              , max(crl.UPDATE_DATE) ) EAT
FROM CONVERSION_ROW_LOG crl
WHERE ENT_TYPE = 'multiEntity'
AND FILE_NAME LIKE 'Policies\__________.zip' ESCAPE '\'
AND crl.UPDATE_DATE > @ImportDate
GROUP BY CONVERT(DATE, crl.UPDATE_DATE) 
ORDER BY 1, 2
;

WITH calc AS
(
SELECT CONVERT(DATE, crl.UPDATE_DATE) AS UPDATE_DATE
     , count(*) qty
     , min(crl.UPDATE_DATE) time_start
     , max(crl.UPDATE_DATE) time_end
FROM CONVERSION_ROW_LOG crl
WHERE ENT_TYPE = 'multiEntity'
AND FILE_NAME LIKE 'Policies\__________.zip' ESCAPE '\'
AND crl.UPDATE_DATE > @ImportDate
GROUP BY CONVERT(DATE, crl.UPDATE_DATE) 
)
SELECT DISTINCT 
       calc.UPDATE_DATE
     , FORMAT(crl.UPDATE_DATE, 'yyyyMMdd-HHmm') AS tranche
     , calc.qty
     , calc.time_start
     , calc.time_end
     , DATEDIFF(minute, calc.time_start, calc.time_end) time_elapse
     , 100.0 * calc.qty / @TotalAccounts Pct
     , @TotalAccounts - calc.qty qty_remain
     , DATEDIFF(minute, calc.time_start, calc.time_end ) * (@TotalAccounts - calc.qty) / calc.qty  time_remain
     , DATEADD( minute
              , DATEDIFF(minute, calc.time_start, calc.time_end) * (@TotalAccounts - calc.qty) / calc.qty 
              , calc.time_end ) EAT
     , FORMAT(crl.UPDATE_DATE, 'yyyyMMdd-HHm') AS tranche
     , COUNT(*) OVER (PARTITION BY FORMAT(crl.UPDATE_DATE, 'yyyyMMdd-HHmm')) as calc
     , COUNT(*) OVER (PARTITION BY CONVERT(VARCHAR(15), FORMAT(crl.UPDATE_DATE, 'yyyyMMdd')) ORDER BY CONVERT(VARCHAR(15), FORMAT(crl.UPDATE_DATE, 'yyyyMMdd-HHmm'))) as calc2
FROM CONVERSION_ROW_LOG crl
JOIN calc ON CONVERT(DATE, crl.UPDATE_DATE) = calc.UPDATE_DATE
WHERE ENT_TYPE = 'multiEntity'
AND FILE_NAME LIKE 'Policies\__________.zip' ESCAPE '\'
AND crl.UPDATE_DATE > @ImportDate
ORDER BY 1, 2 
