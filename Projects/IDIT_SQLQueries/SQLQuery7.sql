/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @userid BIGINT = 100017609674; -- DLA
--DECLARE @userid BIGINT =100017333464; -- LEA

SELECT TOP (1000) *
  FROM [IDIT_PRD].[dbo].[CN_CONTACT]
  where id = @userid;
