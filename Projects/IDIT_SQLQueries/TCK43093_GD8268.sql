-- Check user exists in T_USER table (table used for provisionning with Azure)
select * from t_user where name_of_user like '%lena%' or name_of_user like '%nl07784%' or external_code like '%nl07784%'

-- To change UPN, Name of user must be changed in T_USER table
update t_user set name_of_user='lena.nicolai@tcs.ch' where userid = 7001991 

-- To reverse UPN, user ID  in T_USER table
update t_user set name_of_user='nl07784' where userid = 7001991