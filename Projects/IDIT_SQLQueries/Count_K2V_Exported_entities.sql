select a.PolicyCount,a.AccountCount,a.ErrorCount,a.ICCount , (a.AccountCount+a.ErrorCount+a.ICCount) as TotalEntity
from 
(select (
select count(*) as PolicyCount from P_POLICY where CHANNEL_TYPE_ID='2' and 
UPDATE_DATE >= '2022-08-07 09:00:00' --and '2021-09-01' 
) as PolicyCount, 

( select count(*) from CONVERSION_ROW_LOG where STATUS='FinishedSuccessfully' and ENT_TYPE='multiEntity' 
and UPDATE_DATE >= '2022-08-07' 
) as AccountCount,

( select distinct count(*) from CONVERSION_ROW_LOG where STATUS='Error' and ENT_TYPE='multiEntity' 
and UPDATE_DATE >= '2022-08-07' --and '2021-08-30'
) as ErrorCount ,

( select 0
) as ICCount )a

-- select * from CONVERSION_ROW_LOG where file_name like '%106456011%'