DECLARE @userid BIGINT = 100018247083;
select * from CN_CONTACT_ROLE where contact_id = @userid

UPDATE cn_contact_role SET discontinue_date = null WHERE contact_id =  @userid
select * from CN_CONTACT_ROLE where contact_id =  @userid


select * from CN_CONTACT_ROLE where DISCONTINUE_DATE > '2023-04-20';
select COUNT(*) from CN_CONTACT_ROLE where DISCONTINUE_DATE > '2023-04-20';
UPDATE cn_contact_role SET DISCONTINUE_DATE = null WHERE DISCONTINUE_DATE > '2023-04-20 00:00:00' AND DISCONTINUE_DATE < '2023-04-20 23:59:59';


SELECT *
FROM CN_CONTACT_ROLE
WHERE DISCONTINUE_DATE IS NOT NULL;
