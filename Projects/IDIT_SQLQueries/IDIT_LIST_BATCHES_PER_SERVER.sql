-- IDIT_LIST_BATCHES_PER_SERVER.sql
-- List batches running for a given server on a given period of time
-- FORMATED WITH : HTTPS://SQLFORMAT.ORG/
<<<<<<< HEAD
DECLARE @STARTDATE DATETIME = '2023-09-18 00:00:00'; -- START DATE RANGE
DECLARE @ENDDATE DATETIME = '2023-09-18 23:59:59'; -- END DATE RANGE
DECLARE @SERVER_ID VARCHAR(120) = '%ldc2as128p%'; -- NAME OF THE BATCH PROCESS AS DEFINED IN IDIT

SELECT BS.DESCRIPTION, BS.ID, BL.SERVER_ID ,BL.*
    FROM SH_BATCH_LOG BL WITH(NOLOCK)
    LEFT JOIN T_PMNT_BATCH_STATUS BS WITH(NOLOCK) ON BL.STATUS = BS.ID   
=======
DECLARE @STARTDATE DATETIME = '2023-11-04 00:00:00'; -- START DATE RANGE
DECLARE @ENDDATE DATETIME = '2023-11-04 23:59:59'; -- END DATE RANGE
-- DECLARE @SERVER_ID VARCHAR(120) = '%ldc2as126%'; -- NAME OF THE BATCH1 PROCESS AS DEFINED IN IDIT
DECLARE @SERVER_ID VARCHAR(120) = '%ldc2as127%'; -- NAME OF THE BATCH2 PROCESS AS DEFINED IN IDIT
-- DECLARE @SERVER_ID VARCHAR(120) = '%ldc2as128%'; -- NAME OF THE BATCH3 PROCESS AS DEFINED IN IDIT
-- DECLARE @SERVER_ID VARCHAR(120) = '%ldc2as129%'; -- NAME OF THE BATCH4 PROCESS AS DEFINED IN IDIT


SELECT  
	BS.ID, 
	BL.SERVER_ID, 
	BL.PARENT_LOG_ID,
	T_BATCH_JOB.DEVELOPER_DESC,
	BL.TRANSFER_TYPE, 
	BL.STATUS, 
	BS.DESCRIPTION,
	BL.CREATE_DATE, 
	BL.UPDATE_STATUS_DATE,
	BL.TOTAL_RECORDS,
	BL.TOTAL_FAILED, BL.TOTAL_SUCCESS
    FROM SH_BATCH_LOG BL WITH(NOLOCK)
    LEFT JOIN T_PMNT_BATCH_STATUS BS WITH(NOLOCK) ON BL.STATUS = BS.ID   
	INNER JOIN T_BATCH_JOB ON (T_BATCH_JOB.JOB_TYPE = BL.TRANSFER_TYPE)
>>>>>>> 81a86f5adb744c9fb3f6b450a202614d47816bb2
    WHERE 
        BL.START_TIME BETWEEN @STARTDATE AND @ENDDATE 
        AND BL.SERVER_ID LIKE @SERVER_ID 
		AND BS.ID NOT IN (4,8,17,22,6,5) --SUCCESS AND FAILED STATUS 
