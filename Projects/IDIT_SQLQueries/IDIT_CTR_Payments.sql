DECLARE @DATE VARCHAR(32) = '20231107';

--SELECT SUBSTRING(I.PAYMENT_REMARKS, 1, 66) AS CAMT, COUNT(*) AS PAYMENTS
--FROM AC_PMNT_INTERFACE_IN I WITH (NOLOCK)
--WHERE I.PAYMENT_REMARKS LIKE 'CAMT.054_P_CH%_1111183850_0_' + @DATE + '%'
--GROUP BY SUBSTRING(I.PAYMENT_REMARKS, 1, 66)

SELECT SUBSTRING(I.PAYMENT_REMARKS, 1, 66) AS CAMT, COUNT(*) AS PAYMENTS
FROM AC_PMNT_INTERFACE_IN I WITH (NOLOCK)
WHERE I.PAYMENT_REMARKS LIKE 'CAMT.054_P_CH%_1111203185_0_' + @DATE + '%'
GROUP BY SUBSTRING(I.PAYMENT_REMARKS, 1, 66)

-- SELECT SUBSTRING(I.PAYMENT_REMARKS, 1, 66) AS CAMT, COUNT(*) AS PAYMENTS
-- FROM AC_PMNT_INTERFACE_IN I WITH (NOLOCK)
-- WHERE I.PAYMENT_REMARKS LIKE 'CAMT.054_P_CH%_1111205916_0_' + @DATE + '%'
-- GROUP BY SUBSTRING(I.PAYMENT_REMARKS, 1, 66)

--SELECT SUBSTRING(I.PAYMENT_REMARKS, 1, 66) AS CAMT, COUNT(*) AS PAYMENTS
--FROM AC_PMNT_INTERFACE_IN I WITH (NOLOCK)
--WHERE I.PAYMENT_REMARKS LIKE 'CAMT.054_P_CH%_1111188138_0_' + @DATE + '%'
--GROUP BY SUBSTRING(I.PAYMENT_REMARKS, 1, 66)

SELECT SUBSTRING(I.PAYMENT_REMARKS, 1, 66) AS CAMT, COUNT(*) AS PAYMENTS
FROM AC_PMNT_INTERFACE_IN I WITH (NOLOCK)
WHERE I.PAYMENT_REMARKS LIKE 'CAMT.054_P_CH%_1115788820_0_' + @DATE + '%'
GROUP BY SUBSTRING(I.PAYMENT_REMARKS, 1, 66)

--select count(*) as Counter from AC_PMNT_INTERFACE_IN where PAYMENT_REMARKS like 'camt.054_P_%_1115788820_0_20221014%';
--select count(*) as Counter from AC_PMNT_INTERFACE_IN where PAYMENT_REMARKS like 'camt.054_P_%_1111183850_0_20221014%';
--select count(*) as Counter from AC_PMNT_INTERFACE_IN where PAYMENT_REMARKS like 'camt.054_P_%_1111203185_0_20221014%';
-- select OUT_PAYMENT_ID from AC_PMNT_INTERFACE_IN where PAYMENT_REMARKS like 'camt.054_P_CH8609000000120024167_1111203185_0_2022101123402677.xml%';

--select OUT_PAYMENT_ID from AC_PMNT_INTERFACE_IN WHERE OUT_PAYMENT_ID='711033793141000500018577937';
--select OUT_PAYMENT_ID from AC_PMNT_INTERFACE_IN WHERE OUT_PAYMENT_ID='721048017211000000013233845';
--select OUT_PAYMENT_ID from AC_PMNT_INTERFACE_IN WHERE OUT_PAYMENT_ID='730101041341000000005436706';
--select OUT_PAYMENT_ID from AC_PMNT_INTERFACE_IN WHERE OUT_PAYMENT_ID='730101041341000000005436706';

-- SELECT top 10000 S.ID, S.SERVICE_NAME,S.METHOD_NAME,S.STATUS,S.STARTUP_TIME,datediff( MILLISECOND,S.STARTUP_TIME,S.END_JOB_TIME)  
--AS execution_time ,S.KEY_ENTITY_EXT --, S.SRC_MESSAGE_INFO, S.RESULT_MESSAGE_INFO , s.ADDITIONAL_MESSAGE,
--CAST (SE.BLOB_MESSAGE AS VARCHAR(MAX))  AS "REQUEST",cast (SE1.BLOB_MESSAGE AS VARCHAR(MAX)) AS "RESPONSE" 
--FROM ST_SERVICE_AUDIT S LEFT outer JOIN SERVICE_AUDIT_MESSAGE_BLOB SE  
--ON SE.ID=S.SRC_MESSAGE_BLOB_ID LEFT outer JOIN SERVICE_AUDIT_MESSAGE_BLOB SE1 
--ON SE1.ID = S.RESULT_MESSAGE_BLOB_ID where startup_time < getDate() 
--and S.METHOD_NAME like '%online%' --and S.METHOD_NAME = 'createProposal' 
--and S.METHOD_NAME = 'createClaimPayment' --and S.METHOD_NAME = 'saveAndMatchIncomingPayment'  
--and S.METHOD_NAME = 'businessEventToTriggerDocument' --and S.METHOD_NAME = 'generatePaymentSlip' 
--and S.METHOD_NAME = 'validateCartProposals' and startup_time > '2022-10-04T08:00:12.569' and S.METHOD_NAME == 'sendPortfolioChangesEvent' 
--and (S.METHOD_NAME = 'issueListOfProposalsToPolicies') --and  S.METHOD_NAME = 'callAccountingTransactionAPI' --and  S.METHOD_NAME not like '%contact%' 
--and  S.METHOD_NAME != 'searchPoliciesByContactExtNum' --and  S.METHOD_NAME != 'searchProposalsByContactExtNum' --and  S.METHOD_NAME != 'getContactDigitalByExtNumber'
--and  S.METHOD_NAME != 'updateContact' --and S.METHOD_NAME = 'sendBlackListEvent' --and STATUS!='ENDED' ORDER BY S.STARTUP_TIME DESC ;