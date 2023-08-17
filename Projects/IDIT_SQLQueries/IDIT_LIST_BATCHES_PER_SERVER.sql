-- IDIT_LIST_BATCHES_PER_SERVER.sql
-- List batches running for a given server on a given period of time
-- FORMATED WITH : HTTPS://SQLFORMAT.ORG/
DECLARE @STARTDATE DATETIME = '2023-08-03 00:00:00'; -- START DATE RANGE
DECLARE @ENDDATE DATETIME = '2023-08-03 23:59:59'; -- END DATE RANGE
DECLARE @SERVER_ID VARCHAR(120) = '%ldc2as128p%'; -- NAME OF THE BATCH PROCESS AS DEFINED IN IDIT

SELECT BS.DESCRIPTION, BS.ID, BL.SERVER_ID ,BL.*
    FROM SH_BATCH_LOG BL
    LEFT JOIN T_PMNT_BATCH_STATUS BS ON BL.STATUS = BS.ID   
    WHERE 
        BL.START_TIME BETWEEN @STARTDATE AND @ENDDATE
        --AND BL.SERVER_ID LIKE 'JBossEAP-7.3.0.GA:ldc2as128p/172.30.68.79:9001' 
        AND BL.SERVER_ID LIKE @SERVER_ID 
		AND BS.ID IN (4,8,17,22,6,5)--SUCCESS AND FAILED STATUS 
