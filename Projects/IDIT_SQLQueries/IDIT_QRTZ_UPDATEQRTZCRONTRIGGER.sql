-- IDIT_UpdateQrtzCronTriggers.sql
-- Update a schedulle cron expression for a given job.


--UPDATE QRTZ_CRON_TRIGGERS 
--SET CRON_EXPRESSION = '0 0,15,30,45 2,3,4,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20 ? * * *'
--WHERE TRIGGER_GROUP = 'SYS_GL Export'

SELECT * 
FROM QRTZ_CRON_TRIGGERS
WHERE TRIGGER_GROUP = 'SYS_GL Export';