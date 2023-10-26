-- TCK48752 - IDIT - Compte administrateur ne fonctionne plus
-- List user additional data for Administrator
-- Typically this table show number of failed attempts and if the account is locked.
SELECT ID, ENABLED, FAILED_LOGIN 
FROM S_USER_ADDITIONAL_DATA 
WHERE USER_ID = (SELECT USERID FROM T_USER WHERE NAME_OF_USER = 'ADMINISTRATOR'); 

-- List T_USER_ROLE fields for administrator
SELECT * 
FROM T_USER_ROLE 
WHERE USERID = (SELECT USERID FROM T_USER WHERE NAME_OF_USER = 'ADMINISTRATOR'); 

-- List roles and description for user ADMINISTRATOR
SELECT * 
FROM T_ROLE
WHERE ROLE_ID IN (
	SELECT ROLE_ID 
	FROM T_USER_ROLE 
	WHERE USERID = (SELECT USERID FROM T_USER WHERE NAME_OF_USER = 'ADMINISTRATOR')
)

-- List contact's roles
SELECT * FROM CN_CONTACT_ROLE WHERE CONTACT_ID = (SELECT CONTACT_ID FROM T_USER WHERE NAME_OF_USER = 'ADMINISTRATOR'); 


-- Unlock admin account by SQL
-- Locked admin account you can unlock without UI usage.
-- Just to see what happend
SELECT ID, ENABLED, FAILED_LOGIN 
FROM S_USER_ADDITIONAL_DATA    
WHERE USER_ID = (SELECT USERID FROM T_USER WHERE  NAME_OF_USER = 'ADMINISTRATOR');

--UPDATE S_USER_ADDITIONAL_DATA SET 
--		ENABLED =1, 
--		PASSWORD_CREATION_DATE = CURRENT_TIMESTAMP, 
--		FAILED_LOGIN = 0 
--WHERE USER_ID = (
--	SELECT USERID 
--	FROM T_USER 
--	WHERE  NAME_OF_USER = 'ADMINISTRATOR'
--);


-- BTW
-- Do you still have problem with Administrator account? 
-- admin rolse on prod seems to be fine
SELECT * 
FROM T_USER_ROLE
WHERE USERID  = (
	SELECT USERID 
	FROM T_USER 
	WHERE NAME_OF_USER = 'ADMINISTRATOR'
);

-- Contact roles also seems to be fine
SELECT *
FROM CN_CONTACT_ROLE
WHERE CONTACT_ID =  (
	SELECT CONTACT_ID 
	FROM T_USER 
	WHERE NAME_OF_USER = 'ADMINISTRATOR'
);

-- 13.10.2023
-- contact_role_id is 10013 now is Director.
-- Please change it to Staff (by query update) or add Director role to contact using contact form.

SELECT USERID,CONTACT_ROLE_ID 
FROM T_USER 
WHERE NAME_OF_USER = 'ADMINISTRATOR'

--UPDATE T_USER SET
--	CONTACT_ROLE_ID = '10020'
--WHERE NAME_OF_USER = 'ADMINISTRATOR'

SELECT * 
FROM T_USER
WHERE NAME_OF_USER = 'ADMINISTRATOR'

-- Root cause are probably changes in setup of organization
-- Query gives contact role description for ID 10013 and 10020
SELECT * 
FROM T_CONTACT_ROLE 
WHERE ID IN (10013,10020)

-- List all contact roles
SELECT ID, DESCRIPTION, DEVELOPER_DESC, UPDATE_DATE, DISCONTINUE_DATE, ACCOUNT_TYPE
FROM T_CONTACT_ROLE;

-- List passwords history (table S_USER_PASSWORD_HISTORY)
SELECT TOP (1000) [ID]
      ,[USER_PASSWORD]
      ,[PASSWORD_CREATION_DATE]
      ,[USER_ID]
      ,[DISCONTINUE_DATE]
      ,[UPDATE_VERSION]
      ,[UPDATE_DATE]
      ,[UPDATE_USER]
      ,[EXT_DATA]
  FROM [S_USER_PASSWORD_HISTORY]
  where user_id = (select userid from T_USER where  NAME_OF_USER = 'Administrator')
  order  by PASSWORD_CREATION_DATE desc

-- Password are stored in s_user_additional_data
 SELECT *
 FROM s_user_additional_data
 WHERE USER_ID = 1;

 -- if you change password in s_user additional_data to selected below then all should fine with password (unhashed) valid before yesterday
 -- So the trick is to get password from S_USER_PASSWORD_HISTORY on the elder record. The hash print match the initial password. So we update s_user_additional_data with the value obtained.
UPDATE s_user_additional_data SET
	USER_PASSWORD='irPvMJpwgL0='
WHERE USER_ID = 1
 

