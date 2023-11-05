-- TSK32668 - Implement Change CHN03251 - IDIT Datafix - «short description"»
-- CHN03251 - IDIT Datafix -Débloquer une police dont l'affichage est "NULL (POLICYHOLDER)"


-- Script name & version:   DFIX-TCSP-486.sql
-- Description:             GENERATE EXTERNAL POLICY NUMBER
-- Last updated:            13-10-2023 - adamk
--------------------------------------------------------------------------------
-- *************************** START *******************************************
UPDATE P_POLICY 
    SET EXTERNAL_POLICY_NUMBER = CASE WHEN MASTER_POLICY_ENDORS_ID IS NULL THEN 'PO700008602-10600/00'
                                    ELSE  CONCAT('SubPolicyPO700008602-10600', RIGHT(EXTERNAL_PROPOSAL_NUMBER, 9))
                                 END
        --EXTERNAL_PROPOSAL_NUMBER = NULL 
        WHERE EXTERNAL_PROPOSAL_NUMBER LIKE '%OF700008602-10600%' AND STATUS_ID=20 ;


INSERT INTO T_RELEASE_TRACK (VERSION, RELEASE_TIME, SCRIPT_NAME, STATUS) VALUES (concat('DFIX-TCSP-486',cast(getdate() as varchar)), GETDATE(), 'GENERATE EXTERNAL POLICY NUMBER', 3);

-- Check output
SELECT * FROM P_POLICY WHERE EXTERNAL_PROPOSAL_NUMBER LIKE '%OF700008602-10600%' AND STATUS_ID=20 ;