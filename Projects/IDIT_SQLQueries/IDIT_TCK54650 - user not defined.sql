-- User not found
-- Update NAME_OF_USER with email adress
DECLARE @username VARCHAR(200) = 'HY32952';
select * from t_user where name_of_user like '%' + @username + '%';
-- Yolan UserID 7001886
select * from t_user where name_of_user like '%Kofler%';
--- Daniel Kofler userid : 7001982
update t_user set NAME_OF_USER='yolan-vito.HINRICHS@tcs.ch' where name_of_user like '%' + @username + '%';


-- Errod GD8233
SELECT * FROM T_USER_ROLE WHERE USERID = 7001982
SELECT * FROM T_USER_ROLE WHERE USERID = 7001886
