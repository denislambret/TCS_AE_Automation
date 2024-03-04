-- Check user exists in T_USER table (table used for provisionning with Azure)
select * from t_user where name_of_user like '%yolan-vito%' or name_of_user like '%hy32952%' or external_code like '%hy07782%'

-- To change UPN, Name of user must be changed in T_USER table
update t_user set name_of_user='HY07782' where userid = 7001886 

-- To reverse UPN, user ID  in T_USER table
update t_user set name_of_user='nl07784' where userid = 7001991

-- To change UPN, Name of user must be changed in T_USER table
update t_user set discontinue_date=NULL where userid = 7001886 
