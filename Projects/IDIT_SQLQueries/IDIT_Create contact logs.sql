-- Script : IDIT_Create_Contacts_logs.sql
-- List create / update contact requests
-- Ein order to debug potential provisioning errors.

-- Formated with : https://sqlformat.org/

DECLARE @startDate DATETIME = '2023-06-01 00:00:00';  -- Start date range
DECLARE @endDate DATETIME = '2023-06-04 23:59:59';    -- End date range
DECLARE @limit INT = 100;                             -- Maximum entries returned for query

SELECT top (@limit) S.ID,
           S.SERVICE_NAME,
           S.METHOD_NAME,
           S.STATUS,
           S.STARTUP_TIME ,
           S.KEY_ENTITY_EXT,
           S.SRC_MESSAGE_INFO,
           S.RESULT_MESSAGE_INFO,
           s.ADDITIONAL_MESSAGE ,
           CAST (SE.BLOB_MESSAGE AS VARCHAR(MAX)) AS "REQUEST" ,
           CAST (SE1.BLOB_MESSAGE AS VARCHAR(MAX)) AS "RESPONSE"
FROM ST_SERVICE_AUDIT S WITH (nolock)
LEFT OUTER JOIN SERVICE_AUDIT_MESSAGE_BLOB SE WITH (nolock) ON SE.ID=S.SRC_MESSAGE_BLOB_ID
LEFT OUTER JOIN SERVICE_AUDIT_MESSAGE_BLOB SE1 WITH (nolock) ON SE1.ID = S.RESULT_MESSAGE_BLOB_ID
WHERE startup_time < @endDate
  AND startup_time > @startDate
  AND status='FAILED'
  AND S.METHOD_NAME = 'createContact' -- A remplacer par updateContact si c'est pour mettre à jour

 
 
