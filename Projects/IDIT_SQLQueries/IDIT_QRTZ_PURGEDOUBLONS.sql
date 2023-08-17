------------ DEBUT REQUETE -------------
-- Script : IDIT_QRTZ_PURGEDOUBLONS.sql
-- Script name & version:   DFIX-TCSP-332
-- Description:             Datafix for QRTZ
-- Last updated:            10-02-2023 - Ryszard
-- Permet de supprimer les doublons par purge
--------------------------------------------------------------------------------

-- Quick snapshot view
select * from QRTZ_CRON_TRIGGERS 
select COUNT(*) as NB from QRTZ_CRON_TRIGGERS 

-- Removal
DECLARE @insertDate datetime2;
set @insertDate = getDate();

DECLARE @sheet TABLE (
  sched_name varchar(200), 
  trigger_name varchar(200), 
  trigger_group varchar(200),
  batch_log_id bigint,
  job_name varchar(200),
  job_group varchar(200),
  first_batch_log_id bigint,
  insert_date datetime2 NULL
);
DECLARE @count int;

DECLARE @messages TABLE (
  [message] nvarchar(256) NOT NULL
) ;

with broken_groups as(
select trigger_group , count(*) as count
from qrtz_cron_triggers
group by trigger_group
having count(*)>1
),
broken_triggers as (
select qrtz_cron_triggers.SCHED_NAME, qrtz_cron_triggers.TRIGGER_NAME, broken_groups.TRIGGER_GROUP, qrtz.batch_log_id
from qrtz_cron_triggers, broken_groups, QRTZ_TRIGGERS qrtz
where qrtz_cron_triggers.trigger_group = broken_groups.trigger_group
and  qrtz_cron_triggers.trigger_group = QRTZ.trigger_group
and  qrtz_cron_triggers.SCHED_NAME = QRTZ.SCHED_NAME 
and  qrtz_cron_triggers.TRIGGER_NAME = QRTZ.TRIGGER_NAME
and  qrtz.batch_log_id not in (select max(batch_log_id) from QRTZ_TRIGGERS where QRTZ_TRIGGERS.trigger_group=broken_groups.trigger_group)
),
broken_qrtz_triggers as (
select QRTZ_TRIGGERS.SCHED_NAME, QRTZ_TRIGGERS.TRIGGER_NAME, QRTZ_TRIGGERS.TRIGGER_GROUP, QRTZ_TRIGGERS.batch_log_id, QRTZ_TRIGGERS.job_name, QRTZ_TRIGGERS.JOB_GROUP,null as first_batch_log_id 
from QRTZ_TRIGGERS, broken_triggers  
where QRTZ_TRIGGERS.trigger_name = broken_triggers.trigger_name
) 
insert into @sheet
select *,  @insertDate from broken_qrtz_triggers;

--select * from @sheet;

--Started > Failed  
UPDATE PH
SET PH.status = 6, update_status_date = @insertDate
FROM sh_batch_log PH
INNER JOIN @sheet as sheet ON ( PH.ID = sheet.batch_log_id )
where status =4 and transfer_type != 13844;

--Scheduled > Unscheduled
UPDATE PH
SET PH.status = 10, update_status_date = @insertDate
FROM sh_batch_log PH
INNER JOIN @sheet as sheet ON ( PH.ID = sheet.batch_log_id )
where status =8 and transfer_type != 13844;

--Processing > Failed
UPDATE PH
SET PH.status = 6, update_status_date = @insertDate
FROM sh_batch_log PH
INNER JOIN @sheet as sheet ON ( PH.ID = sheet.batch_log_id )
where status =17 and transfer_type != 13844;

-- Recurring Job Scheduled,Recurring Job Paused > Recurring Job Unscheduled 
UPDATE PH
SET PH.status = 21, update_status_date = @insertDate
FROM sh_batch_log PH
INNER JOIN @sheet as sheet ON ( PH.ID = sheet.batch_log_id )
where status in (19,23) and transfer_type != 13844;


delete T_JOB_DETAIL_XML_FILES where id in (select batch_log_id from @sheet); 

delete qrtz from qrtz_cron_triggers qrtz join @sheet as sheet on (sheet.SCHED_NAME = qrtz.SCHED_NAME and  sheet.TRIGGER_NAME = qrtz.TRIGGER_NAME and sheet.TRIGGER_GROUP = qrtz.TRIGGER_GROUP); 

delete qrtz from QRTZ_TRIGGERS qrtz join @sheet as sheet on (sheet.SCHED_NAME = QRTZ.SCHED_NAME and  sheet.TRIGGER_NAME = QRTZ.TRIGGER_NAME and sheet.TRIGGER_GROUP = QRTZ.TRIGGER_GROUP); 

delete qrtz from QRTZ_JOB_DETAILS qrtz join @sheet as sheet on (sheet.SCHED_NAME = QRTZ.SCHED_NAME and  sheet.JOB_NAME = QRTZ.JOB_NAME and sheet.JOB_GROUP = QRTZ.JOB_GROUP); 

------------------------------------------------------------------------------------
PRINT 'CREATE BACKUP TABLE BACKUP_TCS332'
IF OBJECT_ID('BACKUP_TCS332', 'U') IS NULL
  CREATE TABLE BACKUP_TCS332 (
  sched_name varchar(200), 
  trigger_name varchar(200), 
  trigger_group varchar(200),
  batch_log_id bigint,
  job_name varchar(200),
  job_group varchar(200),
  first_batch_log_id bigint,
  insert_date datetime2 NULL
);


--select * from BACKUP_TCS332 
--copy changes to backup table
INSERT INTO BACKUP_TCS332 select * from @sheet WHERE INSERT_DATE = @insertDate;
-- select * from BACKUP_TCS192

-- Quick snapshot view
select * from QRTZ_CRON_TRIGGERS 
select COUNT(*) as NB from QRTZ_CRON_TRIGGERS 
