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
    JOIN keyitem184 KI184 ON (ITDATA.itemnum = KI184.itemnum) 
	JOIN keyitem196 KI196 ON (ITDATA.itemnum = KI196.itemnum) 
	JOIN keyitem197 KI197 ON (ITDATA.itemnum = KI197.itemnum) 
	JOIN keyitem136 KI136 ON (ITDATA.itemnum = KI136.itemnum) 
	JOIN keyitem198 KI198 ON (ITDATA.itemnum = KI198.itemnum) 
	JOIN keyitem178 KI178 ON (ITDATA.itemnum = KI178.itemnum) 
	JOIN keyitem199 KI199 ON (ITDATA.itemnum = KI199.itemnum) 
	JOIN keyitem141 KI141 ON (ITDATA.itemnum = KI141.itemnum) 
	JOIN keyitem177 KI177 ON (ITDATA.itemnum = KI177.itemnum) 
	JOIN keyitem139 KI139 ON (ITDATA.itemnum = KI139.itemnum) 
    JOIN keyitem183 KI183 ON (ITDATA.itemnum = KI183.itemnum) 
WHERE itemdate BETWEEN @startDate AND @endDate
	AND itemname LIKE '%CCM Pli%'
	AND batchnum != 0
	AND batchnum = @batch
--	AND charindex(@custRef,KI184.keyvaluechar) > 0
--	AND charindex(@firstName,KI196.keyvaluechar) > 0
--	AND charindex(@evtType,KI199.keyvaluechar) > 0;

SELECT TOP (100000) ITDATA.itemnum AS DocumentHandle, 
		itemname, 
		batchnum, 
		itemdate, 
		datestored, 
		TRIM(KI184.keyvaluechar) AS ID_SOCIETAIRE,
		TRIM(KI196.Keyvaluechar) AS DATE_CREATION,
		TRIM(KI197.Keyvaluechar) AS DATE_ARCHIVAGE,
		TRIM(KI136.keyvaluechar) AS DATE_RECEPTION,
		TRIM(KI198.keyvaluechar) AS DATE_FIN_TRAITEMENT,
		TRIM(KI178.keyvaluesmall AS DPT_OWNER,
		TRIM(KI199.keyvaluechar) AS OWNER_USER,
		TRIM(KI141.keyvaluechar) AS DIRECTION,
		TRIM(KI177.keyvaluechar) AS LANGUE,
		TRIM(KI139.keyvaluechar) AS ORIGINE,
		TRIM(KI183.keyvaluechar) AS SENSIBLE	
		
FROM hsi.itemdata ITDATA
    JOIN keyitem110 KI184 ON (ITDATA.itemnum = KI184.itemnum) 
	JOIN keyitem111 KI196 ON (ITDATA.itemnum = KI196.itemnum) 
	JOIN keyitem112 KI197 ON (ITDATA.itemnum = KI197.itemnum) 
	JOIN keyitem102 KI136 ON (ITDATA.itemnum = KI136.itemnum) 
	JOIN keyitem103 KI198 ON (ITDATA.itemnum = KI198.itemnum) 
	JOIN keyitem105 KI178 ON (ITDATA.itemnum = KI178.itemnum) 
	JOIN keyitem106 KI199 ON (ITDATA.itemnum = KI199.itemnum) 
	JOIN keyitem107 KI141 ON (ITDATA.itemnum = KI141.itemnum) 
	JOIN keyitem108 KI177 ON (ITDATA.itemnum = KI177.itemnum) 
	JOIN keyitem109 KI139 ON (ITDATA.itemnum = KI139.itemnum) 
    JOIN keyitem115 KI183 ON (ITDATA.itemnum = KI183.itemnum) 

WHERE itemdate BETWEEN @startDate AND @endDate
	AND itemname LIKE '%CCM Pli%'
	AND batchnum != 0
	AND batchnum = @batch
--	AND charindex(@custRef,KI184.keyvaluechar) > 0
--	AND charindex(@firstName,KI196.keyvaluechar) > 0
--	AND charindex(@evtType,KI199.keyvaluechar) > 0

ORDER BY itemdate ASC, CCM_firstName ASC, CCM_lastName ASC;

