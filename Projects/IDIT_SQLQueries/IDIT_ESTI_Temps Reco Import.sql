-- Estimation temps reste a faire traitement sapiens avant creation import phase 2
DECLARE @Total INT = 196894
SELECT CONVERT(DATE, crl.UPDATE_DATE) AS UPDATE_DATE
     , count(*) qty
     , min(crl.UPDATE_DATE) time_start
     , max(crl.UPDATE_DATE) time_end
     , DATEDIFF(minute, min(crl.UPDATE_DATE), max(crl.UPDATE_DATE) ) time_elapse
     , 100.0 * count(*) / @Total Pct
     , @Total - count(*) qty_remain
     , DATEDIFF(minute, min(crl.UPDATE_DATE), max(crl.UPDATE_DATE) ) * (@Total - count(*)) / count(*)  time_remain
     , DATEADD( minute
              , DATEDIFF(minute, min(crl.UPDATE_DATE), max(crl.UPDATE_DATE) ) * (@Total - count(*)) / count(*)  
              , max(crl.UPDATE_DATE) ) EAT
FROM CONVERSION_ROW_LOG crl
WHERE ENT_TYPE = 'multiEntity'
AND FILE_NAME LIKE 'Policies\__________.zip' ESCAPE '\'
AND crl.UPDATE_DATE > '2022-06-23'
--AND crl.UPDATE_DATE < '2022-06-23 15:00:00'
GROUP BY CONVERT(DATE, crl.UPDATE_DATE) 
ORDER BY 1, 2;