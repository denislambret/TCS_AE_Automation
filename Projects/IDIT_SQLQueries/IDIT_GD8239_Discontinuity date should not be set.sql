-- GD8239 
-- Discontinuity date is set when it should not
DECLARE @username VARCHAR(200) = 'cathy.joyeux@tcs.ch';
select * from t_user where name_of_user like '%' + @username + '%';
update t_user set DISCONTINUE_DATE=null where name_of_user like '%' + @username + '%';