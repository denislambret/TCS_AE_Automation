-- Script : OB_GetWrongIdPli
-- List records with a wrong idPlis given a timestamp range

-- Formated with : https://sqlformat.org/
DECLARE @startDate DATETIME = '2022-01-01 00:00:00';					-- Start date range
DECLARE @endDate DATETIME = '2023-06-30 23:59:59';						-- End date range
DECLARE @batch INT = 38745;												-- Run number
--DECLARE @custRef VARCHAR(9) = '106740328';   							-- TCS Customer reference number
--DECLARE @firstName VARCHAR(32) = 'LAMBERT';   						-- TCS Customer first name
--DECLARE @evtType VARCHAR(32) = 'POLICY-CANCELLED';   					-- TCS Event type

-- List batches of the period
SELECT DISTINCT itemname, batchnum, itemdate, datestored  
FROM hsi.itemdata
WHERE itemdate BETWEEN @startDate AND @endDate
	  AND (
		batchnum != 0
		AND batchnum = @batch
	  )
	  AND itemname LIKE '%batch%SYS Verification%'
ORDER BY datestored ASC;

---- Detail CCM Plis docs for a period
---- K102 CCM Business
---- K103 CCM Direction
---- K105 CCM Sequence
---- K106 CCM EventType
---- K107 CCM PrintShop
---- K108 CCM EMail
---- K109 CCM Langue
---- K110 CCM Customer Ref
---- K114 CCM Origin
---- K113 CCM Creation Date
---- K115 CCM IdPlis

SELECT TOP (100000) COUNT(ITDATA.itemnum) AS Records
FROM hsi.itemdata ITDATA
    JOIN keyitem110 KI110 ON (ITDATA.itemnum = KI110.itemnum) 
	JOIN keyitem111 KI111 ON (ITDATA.itemnum = KI111.itemnum) 
	JOIN keyitem112 KI112 ON (ITDATA.itemnum = KI112.itemnum) 
	JOIN keyitem102 KI102 ON (ITDATA.itemnum = KI102.itemnum) 
	JOIN keyitem103 KI103 ON (ITDATA.itemnum = KI103.itemnum) 
	JOIN keyitem105 KI105 ON (ITDATA.itemnum = KI105.itemnum) 
	JOIN keyitem106 KI106 ON (ITDATA.itemnum = KI106.itemnum) 
	JOIN keyitem107 KI107 ON (ITDATA.itemnum = KI107.itemnum) 
	JOIN keyitem108 KI108 ON (ITDATA.itemnum = KI108.itemnum) 
	JOIN keyitem109 KI109 ON (ITDATA.itemnum = KI109.itemnum) 
    JOIN keyitem115 KI115 ON (ITDATA.itemnum = KI115.itemnum) 
WHERE itemdate BETWEEN @startDate AND @endDate
	AND itemname LIKE '%CCM Pli%'
	AND batchnum != 0
	AND batchnum = @batch
--	AND charindex(@custRef,KI110.keyvaluechar) > 0
--	AND charindex(@firstName,KI111.keyvaluechar) > 0
--	AND charindex(@evtType,KI106.keyvaluechar) > 0;

SELECT TOP (100000) ITDATA.itemnum AS DocumentHandle, 
		itemname, 
		batchnum, 
		itemdate, 
		datestored, 
		TRIM(KI110.keyvaluechar) AS CCM_CustRefNumber,
		TRIM(KI111.Keyvaluechar) AS CCM_firstName,
		TRIM(KI112.Keyvaluechar) AS CCM_lastName,
		TRIM(KI102.keyvaluechar) AS CCM_Business,
		TRIM(KI103.keyvaluechar) AS CCM_Direction,
		KI105.keyvaluesmall AS CCM_Sequence,
		TRIM(KI106.keyvaluechar) AS CCM_EventType,
		TRIM(KI107.keyvaluechar) AS CCM_forPrintshop,
		TRIM(KI108.keyvaluechar) AS CCM_forEmail,
		TRIM(KI109.keyvaluechar) AS CCM_langue,
		TRIM(KI115.keyvaluechar) AS CCM_IDPlis	
		
FROM hsi.itemdata ITDATA
    JOIN keyitem110 KI110 ON (ITDATA.itemnum = KI110.itemnum) 
	JOIN keyitem111 KI111 ON (ITDATA.itemnum = KI111.itemnum) 
	JOIN keyitem112 KI112 ON (ITDATA.itemnum = KI112.itemnum) 
	JOIN keyitem102 KI102 ON (ITDATA.itemnum = KI102.itemnum) 
	JOIN keyitem103 KI103 ON (ITDATA.itemnum = KI103.itemnum) 
	JOIN keyitem105 KI105 ON (ITDATA.itemnum = KI105.itemnum) 
	JOIN keyitem106 KI106 ON (ITDATA.itemnum = KI106.itemnum) 
	JOIN keyitem107 KI107 ON (ITDATA.itemnum = KI107.itemnum) 
	JOIN keyitem108 KI108 ON (ITDATA.itemnum = KI108.itemnum) 
	JOIN keyitem109 KI109 ON (ITDATA.itemnum = KI109.itemnum) 
    JOIN keyitem115 KI115 ON (ITDATA.itemnum = KI115.itemnum) 

WHERE itemdate BETWEEN @startDate AND @endDate
	AND itemname LIKE '%CCM Pli%'
	AND batchnum != 0
	AND batchnum = @batch
--	AND charindex(@custRef,KI110.keyvaluechar) > 0
--	AND charindex(@firstName,KI111.keyvaluechar) > 0
--	AND charindex(@evtType,KI106.keyvaluechar) > 0

ORDER BY itemdate ASC, CCM_firstName ASC, CCM_lastName ASC;

