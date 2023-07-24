--kill or running Daily or GL’s from dashboard and by update
update sh_batch_log set status = 6 where status = 4 and TRANSFER_TYPE in (1000001,1000067,1000072);    -- Started > Failed 

--kill or running Daily or GL’s from dashboard and by update
-- Recurring Job Scheduled,Recurring Job Paused > Recurring Job Unscheduled
update sh_batch_log set status = 21 where status in (19,20,23) and transfer_type != 13844;

-- 3. execute update
update t_batch_job_group set IS_LONG_AND_LOW_FREQUENT=1 where id= 1000022;

-- 4. Correction limites daily + big renew
update T_JOB_PLAN_STEP set NOT_BEFORE='' where plan_id=1000003;
update T_JOB_PLAN_STEP set NOT_AFTER='' where plan_id=1000003;
update T_JOB_PLAN_STEP set NOT_BEFORE='' where plan_id=1000007;
update T_JOB_PLAN_STEP set NOT_AFTER='' where plan_id=1000007;

-- 5.Correction limites du GL
update T_JOB_PLAN_STEP set NOT_AFTER='18:00' where id=1000072;
update T_JOB_PLAN_STEP set NOT_AFTER='18:00' where id=1000073;
update T_JOB_PLAN_STEP set NOT_AFTER='18:00' where id=1000074;

-- 6.refresh cache
--7. Si doublon dans select * from QRTZ_CRON_TRIGGERS, alors passer EXEC clean_qrtz_cron_triggers;
select * from QRTZ_CRON_TRIGGERS