-- Script : OB_GetStatsRun
-- List batch details on a given timestamp range
-- Ease analytics with Excel / pivot tables

-- Formated with : https://sqlformat.org/
DECLARE @startDate DATETIME = '2023-06-12 00:00:00';					-- Start date range
DECLARE @endDate DATETIME = '2023-06-12 23:59:59';						-- End date range

-- Count CCM Plis docs for a period
SELECT COUNT(itemnum) AS DocsCounter  
FROM hsi.itemdata
WHERE itemdate BETWEEN @startDate AND @endDate
AND itemname LIKE '%CCM Pli%'
AND batchnum <> 0


-- List batches of the period
SELECT DISTINCT itemname, batchnum, itemdate, datestored  
FROM hsi.itemdata
WHERE itemdate BETWEEN @startDate AND @endDate
AND itemname LIKE '%batch%SYS Verification%'
AND batchnum <> 0
ORDER BY datestored ASC;

-- Detail CCM Plis docs for a period
SELECT ITDATA.itemnum, 
		itemname, 
		batchnum, 
		itemdate, 
		datestored, 
		KI110.keyvaluechar AS refClient,
		KI115.keyvaluechar AS IdPlis,
		KI105.keyvaluesmall AS IdSDFC
FROM hsi.itemdata ITDATA
	LEFT JOIN keyitem115 KI115 ON (ITDATA.itemnum = KI115.itemnum) 
	LEFT JOIN keyitem110 KI110 ON (ITDATA.itemnum = KI110.itemnum) 
	LEFT JOIN keyitem105 KI105 ON (ITDATA.itemnum = KI105.itemnum) 
WHERE itemdate BETWEEN @startDate AND @endDate
	AND itemname LIKE '%CCM Pli%'
	AND batchnum != 0
ORDER BY datestored ASC;

