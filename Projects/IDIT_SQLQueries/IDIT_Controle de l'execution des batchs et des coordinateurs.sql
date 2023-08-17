-- Liste des batchs avec cron expression
select id, JOB_DESC, SYSTEM_TRIGGER_CRON_EXPR, *
from T_BATCH_JOB
where SYSTEM_TRIGGER_CRON_EXPR is not null

-- Liste des schedules Quartz
select top 1000 *
from QRTZ_CRON_TRIGGERS as cr

select top 1000 *
from QRTZ_TRIGGERS

-- Detail du Daily standard coordinator
select *
from T_JOB_PLAN_STEP 
where plan_id=1000003
order by DEPEND_ON;

-- Detail du GL Export coordinator
select *
from T_JOB_PLAN_STEP
where plan_id=1000008
order by DEPEND_ON;

-- Detail du BIG Renew Daily 
--select * from iDIT_ACP.dbo.T_BATCH_JOB where id='1000072'
select b.JOB_DESC, jp. *
from T_JOB_PLAN_STEP as jp 
inner join T_BATCH_JOB as b
on b.id=jp.JOB_ID

--where plan_id=1000007
where JOB_DESC LIKE '%Daily%'
order by DEPEND_ON


-- Liste des batchs en run
select top 1000 *
from IDIT_ACP.dbo.SH_BATCH_LOG as l
where l.STATUS in ('4','8','9','17','19','20','22','23')
order by UPDATE_DATE desc

--EXEC clean_qrtz_cron_triggers; -- A faire après les refresh cache

WITH
         BatchLogs AS
         (
            SELECT  1 as level, SH.ID, SH.TRANSFER_TYPE, SH.STATUS, SH.CREATE_DATE,SH.START_TIME, SH.UPDATE_STATUS_DATE , SH.PARENT_LOG_ID,
                SH.TOTAL_SUCCESS as TOTAL_SUCCESS, SH.TOTAL_FAILED as TOTAL_FAILED, SH.JOB_TYPE AS JOB_TYPE
            FROM SH_BATCH_LOG SH
            WHERE ((SH.start_time between '07/01/2023 00:20:00.000' AND '07/31/2023 12:10:00.000'  
        and JOB_TYPE >1
        and transfer_type in (1000045)--13614,13613,13615)
    --and transfer_type in (/*13398,*/1000001/*,1000067,1000048*/)--13075 --13071 --1000045
         and transfer_type not in (13069,13300,13298,13398,13299,13769,1000010,13168,13423,1000056,1000001,1000067,13430,13472,13527,13172) --1000001
            --and  transfer_type in (1000001,1000002,1000003,1000048,1000049,1000050,1000067,1000068,1000069)
            )
            ) 
             UNION ALL
            SELECT Level + 1, SH.ID, SH.TRANSFER_TYPE, SH.STATUS, SH.CREATE_DATE, SH.START_TIME, SH.UPDATE_STATUS_DATE, SH.PARENT_LOG_ID,
                SH.TOTAL_SUCCESS as TOTAL_SUCCESS, SH.TOTAL_FAILED as TOTAL_FAILED, SH.JOB_TYPE AS JOB_TYPE
            FROM SH_BATCH_LOG SH, BatchLogs
            WHERE ( SH.PARENT_LOG_ID = BatchLogs.ID)
         )
         select rl.id, TRANSFER_TYPE, priority, t_batch_job.job_desc, STATUS, t_pmnt_batch_status.DESCRIPTION,
         CREATE_DATE, START_TIME, UPDATE_STATUS_DATE,PARENT_LOG_ID,TOTAL_SUCCESS,TOTAL_FAILED, rl.JOB_TYPE,datediff(mi, START_TIME , UPDATE_STATUS_DATE) as execution_time_in_minutes
            from (
                 SELECT BatchLogs.ID as ID, row_number() OVER(PARTITION BY BatchLogs.id order by BatchLogs.Level DESC) AS RN,
                    BatchLogs.TRANSFER_TYPE as TRANSFER_TYPE , BatchLogs.STATUS as STATUS , BatchLogs.CREATE_DATE as CREATE_DATE, BatchLogs.START_TIME as START_TIME, BatchLogs.UPDATE_STATUS_DATE as UPDATE_STATUS_DATE, BatchLogs.PARENT_LOG_ID as PARENT_LOG_ID,
                    BatchLogs.TOTAL_SUCCESS as TOTAL_SUCCESS, BatchLogs.TOTAL_FAILED as TOTAL_FAILED, BatchLogs.JOB_TYPE AS JOB_TYPE

                 FROM BatchLogs
            ) RL
            left join t_batch_job on (t_batch_job.id = rl.transfer_type)
            left join t_pmnt_batch_status on (t_pmnt_batch_status.id = status)
              where RL.RN=1
            -- and status=10
         and RL.JOB_TYPE  >2          -- use >1 for initiator only
              order by start_time asc;

select top 1000 *
from IDIT_ACP.dbo.SH_BATCH_LOG as l
where l.STATUS in ('4','8','9','17','19','20','22','23')
order by UPDATE_DATE desc

-- Run le 17.07.2023 à 14:51
update sh_batch_log set status = 6 where status = 4 and TRANSFER_TYPE in (1000001,1000067,1000072);    -- Started > Failed  

-- 1 rows
update sh_batch_log set status = 21 where status in (19,23,20) and transfer_type != 13844; -- Recurring Job Scheduled,Recurring Job Paused > Recurring Job Unscheduled (13844=rapports)

-- 12 rows
update t_batch_job_group set IS_LONG_AND_LOW_FREQUENT=1 where id= 1000022;

-- 1 rows
select * 
from IDIT_ACP.dbo.T_BATCH_JOB where ID='13060'


WITH
         BatchLogs AS
         (
            SELECT  1 as level, SH.ID, SH.TRANSFER_TYPE, SH.STATUS, SH.CREATE_DATE,SH.START_TIME, SH.UPDATE_STATUS_DATE , SH.PARENT_LOG_ID,
                SH.TOTAL_SUCCESS as TOTAL_SUCCESS, SH.TOTAL_FAILED as TOTAL_FAILED, SH.JOB_TYPE AS JOB_TYPE
            FROM SH_BATCH_LOG SH
WHERE (((SH.start_time between '07/17/2023 00:20:00.000' AND '07/31/2023 18:10:00.000'  or SH.UPDATE_DATE between '07/17/2023 00:20:00.000' AND '07/31/2023 18:10:00.000'  )

and JOB_TYPE >1
and transfer_type in (1000072)--1000045,1000011)--13614,13613,13615)
--and transfer_type in (/*13398,*/1000001/*,1000067,1000048*/)--13075 --13071 --1000045
-- and transfer_type not in (13069,13300,13298,13398,13299,13769,1000010,13168,13423,1000056,1000001,1000067,13430,13472,13527,13172) --1000001
--and  transfer_type in (1000001,1000002,1000003,1000048,1000049,1000050,1000067,1000068,1000069)
) 

) 
             UNION ALL
            SELECT Level + 1, SH.ID, SH.TRANSFER_TYPE, SH.STATUS, SH.CREATE_DATE, SH.START_TIME, SH.UPDATE_STATUS_DATE, SH.PARENT_LOG_ID,
                SH.TOTAL_SUCCESS as TOTAL_SUCCESS, SH.TOTAL_FAILED as TOTAL_FAILED, SH.JOB_TYPE AS JOB_TYPE
            FROM SH_BATCH_LOG SH, BatchLogs
            WHERE ( SH.PARENT_LOG_ID = BatchLogs.ID)
         )

 

        -- select * from batchlogs
         select rl.id, TRANSFER_TYPE, priority, t_batch_job.job_desc, STATUS, t_pmnt_batch_status.DESCRIPTION,
CREATE_DATE, START_TIME, UPDATE_STATUS_DATE,PARENT_LOG_ID,TOTAL_SUCCESS,TOTAL_FAILED, rl.JOB_TYPE,datediff(mi, START_TIME , UPDATE_STATUS_DATE) as execution_time_in_minutes
from (
                 SELECT BatchLogs.ID as ID, row_number() OVER(PARTITION BY BatchLogs.id order by BatchLogs.Level DESC) AS RN,
                    BatchLogs.TRANSFER_TYPE as TRANSFER_TYPE , BatchLogs.STATUS as STATUS , BatchLogs.CREATE_DATE as CREATE_DATE, BatchLogs.START_TIME as START_TIME, BatchLogs.UPDATE_STATUS_DATE as UPDATE_STATUS_DATE, BatchLogs.PARENT_LOG_ID as PARENT_LOG_ID,
                    BatchLogs.TOTAL_SUCCESS as TOTAL_SUCCESS, BatchLogs.TOTAL_FAILED as TOTAL_FAILED, BatchLogs.JOB_TYPE AS JOB_TYPE

                 FROM BatchLogs
            ) RL
left join t_batch_job on (t_batch_job.id = rl.transfer_type)
left join t_pmnt_batch_status on (t_pmnt_batch_status.id = status)
              where RL.RN=1
--and status!=10
and RL.JOB_TYPE  >1         -- use >1 for initiator only
-- and transfer_type=1000011
  order by UPDATE_STATUS_DATE asc,start_time asc;
 
 select * from sh_batch_log where id=16577449 -- dans server_ID, on peut voir le serveur qui execute cette tache