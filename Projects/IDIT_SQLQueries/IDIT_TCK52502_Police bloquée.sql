-- Unlock policies in "Processing Change" status
-- Author : Sassi Fares + Denis Lambret
-- Date : 20240123
-- Initialize the variable
DECLARE @policy_external_number VARCHAR(30);
SET @policy_external_number = 'PO700018985-10600/03';

BEGIN TRANSACTION
                -- Update p_pol_header
                UPDATE p_pol_header 
                SET IS_IN_ENDORSEMENT_BATCH = 0 
                WHERE IS_IN_ENDORSEMENT_BATCH = 1 
                AND id IN (SELECT policy_header_id FROM p_policy WHERE external_policy_number = @policy_external_number);

                -- Update p_policy
                UPDATE p_policy 
                SET IS_UNDER_CONSTRUCTION = 0 
                WHERE IS_UNDER_CONSTRUCTION = 1 
                AND id IN (SELECT id FROM p_policy WHERE external_policy_number = @policy_external_number);

                -- Update AC_ACCOUNT
                UPDATE AC_ACCOUNT 
                SET IS_UNDER_CONSTRUCTION = 0 
                WHERE IS_UNDER_CONSTRUCTION = 1 
                AND policy_header_id IN (SELECT policy_header_id FROM p_policy WHERE external_policy_number = @policy_external_number);
COMMIT
