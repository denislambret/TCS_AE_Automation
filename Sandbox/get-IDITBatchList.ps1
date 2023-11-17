Import-Module SimplySql -Force

$user = "iditPRD"
$pwd = "X8xo3G5eA"

[securestring]$password = ConvertTo-SecureString -String $pwd -AsPlainText -Force
[pscredential]$cred = New-Object System.Management.Automation.PSCredential ($user, $password) 
$server = 'PRD-IDIT'
$db = 'IDIT-PRD'


try {
    Open-SqlConnection -DataSource "IDITPRD"
}
catch {
    Write-Host $Error
}

exit

$start = '2023-11-05 22:00:00'
$end = '2023-11-07 12:00:00'

$query = "`
-- SCRIPT : LISTBATCHIDIT.SQL`
-- LIST BATCH DETAILS ON A GIVEN TIMESTAMP RANGE`
-- EASE ANALYTICS WITH EXCEL / PIVOT TABLES`
-- FORMATED WITH : HTTPS://SQLFORMAT.ORG/`
DECLARE @STARTDATE DATETIME = `'' + $start + '`'; -- START DATE RANGE`
DECLARE @ENDDATE DATETIME = `'' + $end + '`'; -- END DATE RANGE`
DECLARE @JOB_NAME VARCHAR(120) = 'GL Export'; -- NAME OF THE BATCH PROCESS AS DEFINED IN IDIT`
-- DECLARE @JOB_NAME VARCHAR(120) = 'Client statement'; `
-- DECLARE @JOB_NAME VARCHAR(120) = 'Earned Premium Transactions'; `
-- DECLARE @JOB_NAME VARCHAR(120) = 'GL EXPORT - INITIATOR'; `
`
WITH BATCHLOGS AS`
(`
	SELECT 1 AS LEVEL,`
          SH.ID,`
          SH.TRANSFER_TYPE,`
          SH.STATUS,`
          SH.CREATE_DATE,`
          SH.START_TIME,`
          SH.UPDATE_STATUS_DATE,`
          SH.PARENT_LOG_ID,`
          SH.TOTAL_SUCCESS AS TOTAL_SUCCESS,`
          SH.TOTAL_FAILED AS TOTAL_FAILED,`
          SH.JOB_TYPE AS JOB_TYPE`
   FROM SH_BATCH_LOG SH`
   WHERE (`
           (`   
			   --UPDATE_STATUS_DATE BETWEEN @STARTDATE AND @ENDDATE`
			   START_TIME BETWEEN @STARTDATE AND @ENDDATE `
			   AND JOB_TYPE > 1 -- TRANSFER_TYPE IN (13614,13613,13615)`
			   --  AND TRANSFER_TYPE IN (1000001,1000067,1000048)--13075 --13071 --1000045`
			   AND TRANSFER_TYPE NOT IN (13069,`
										 13300,`
										 13298,`
										 13398,`
										 13299,`
										 13769,`
										 1000010,`
										 13168,`
										 13423,`
										 1000056,`
										 1000067,`
										 13430,`
										 13472,`
										 13527,`
										 13172`
										 ) `
		)`
	)`
	UNION ALL SELECT LEVEL + 1,`
                            SH.ID,`
                            SH.TRANSFER_TYPE,`
                            SH.STATUS,`
                            SH.CREATE_DATE,`
                            SH.START_TIME,`
                            SH.UPDATE_STATUS_DATE,`
                            SH.PARENT_LOG_ID,`
                            SH.TOTAL_SUCCESS AS TOTAL_SUCCESS,`
                            SH.TOTAL_FAILED AS TOTAL_FAILED,`
                            SH.JOB_TYPE AS JOB_TYPE`
   FROM SH_BATCH_LOG SH,`
        BATCHLOGS`
   WHERE (SH.PARENT_LOG_ID = BATCHLOGS.ID) `
) `
SELECT RL.ID,`
    TRANSFER_TYPE,`
    PRIORITY,`
    T_BATCH_JOB.JOB_DESC,`
    STATUS,`
    T_PMNT_BATCH_STATUS.DESCRIPTION,`
    CREATE_DATE,`
    START_TIME,`
    UPDATE_STATUS_DATE,`
    PARENT_LOG_ID,`
    TOTAL_SUCCESS,`
    TOTAL_FAILED,`
    RL.JOB_TYPE,`
    DATEDIFF(MI, START_TIME, UPDATE_STATUS_DATE) AS EXECUTION_TIME_IN_MINUTES`
FROM (`
    SELECT BATCHLOGS.ID AS ID,`
        ROW_NUMBER() OVER(PARTITION BY BATCHLOGS.ID ORDER BY BATCHLOGS.LEVEL DESC) AS RN,`
        BATCHLOGS.TRANSFER_TYPE AS TRANSFER_TYPE,`
        BATCHLOGS.STATUS AS STATUS,`
        BATCHLOGS.CREATE_DATE AS CREATE_DATE,`
        BATCHLOGS.START_TIME AS START_TIME,`
        BATCHLOGS.UPDATE_STATUS_DATE AS UPDATE_STATUS_DATE,`
        BATCHLOGS.PARENT_LOG_ID AS PARENT_LOG_ID,`
        BATCHLOGS.TOTAL_SUCCESS AS TOTAL_SUCCESS,`
        BATCHLOGS.TOTAL_FAILED AS TOTAL_FAILED,`
        BATCHLOGS.JOB_TYPE AS JOB_TYPE`
    FROM BATCHLOGS`
) RL`
LEFT JOIN T_BATCH_JOB ON (T_BATCH_JOB.ID = RL.TRANSFER_TYPE)`
LEFT JOIN T_PMNT_BATCH_STATUS ON (T_PMNT_BATCH_STATUS.ID = STATUS)`
WHERE RL.RN = 1`
AND STATUS != 10 --AND RL.JOB_TYPE > 1 -- USE >1 FOR INITIATOR ONLY`
AND T_BATCH_JOB.JOB_DESC LIKE '%' + @JOB_NAME + '%'`
AND STATUS IN(4,8)`
ORDER BY UPDATE_STATUS_DATE DESC;`
-- ORDER BY EXECUTION_TIME_IN_MINUTES DESC;`
-- ORDER BY START_TIME DESC;`
`
"

try {
       $results = Invoke-SQLQuery -ConnectionName test -query $query | Format-Table -AutoSize
}
catch {
    Write-Host $Error
    Write-Host $StackTrace 
}

$results | Format-Table -AutoSize


try {
    Close-SqlConnection -ConnectionName test -server $server -Database $db -Credential $cred
}
catch {
    Write-Host $Error
    Write-Host $StackTrace 
}