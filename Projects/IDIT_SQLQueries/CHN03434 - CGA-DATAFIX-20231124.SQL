-- =================
-- CAS 1 - ETI 2013
-- =================
-- 5847 lignes a update - Select de vérification
SELECT * FROM P_POLICY_TCS where P_POLICY_TCS.ID in (select ptcs.id from T_PRODUCT
inner join T_PROD_TCSVER_TCS on T_PROD_TCSVER_TCS.PRODUCT_ID=T_PRODUCT.PRODUCT_ID
inner join P_POLICY_TCS as ptcs on ptcs.TCS_PRODUCT_VERSION=T_PROD_TCSVER_TCS.ID
inner join P_POLICY as p on p.id=ptcs.id
inner join P_POL_HEADER as ph on p.policy_header_id=ph.id
where EXTERNAL_POLICY_NUMBER is not null
and p.POLICY_START_DATE<'01-01-2024' -- date fin validité cga 2022
and p.POLICY_START_DATE>='01-01-2022' -- date début validité cga 2022
and p.ENDORS_START_DATE<'01-01-2024' -- n'ayant pas été modifiée avant 2024
and p.STATUS_ID in ('20','13','10') -- policy, proposal et suspended
and T_PROD_TCSVER_TCS.ID in (1000025) -- ETI 2013
AND P_POLICY_TCS.GENERAL_CONDITIONS_VERSION<>'01.2022');

-- update
BEGIN TRANSACTION
	update P_POLICY_TCS set GENERAL_CONDITIONS_VERSION='01.2022', GENERAL_CONDITIONS_TCS='1000022' where P_POLICY_TCS.ID in (select ptcs.id from T_PRODUCT
	inner join T_PROD_TCSVER_TCS on T_PROD_TCSVER_TCS.PRODUCT_ID=T_PRODUCT.PRODUCT_ID
	inner join P_POLICY_TCS as ptcs on ptcs.TCS_PRODUCT_VERSION=T_PROD_TCSVER_TCS.ID
	inner join P_POLICY as p on p.id=ptcs.id
	inner join P_POL_HEADER as ph on p.policy_header_id=ph.id
	where EXTERNAL_POLICY_NUMBER is not null
	and p.POLICY_START_DATE<'01-01-2024' -- date fin validité cga 2022
	and p.POLICY_START_DATE>='01-01-2022' -- date début validité cga 2022
	and p.ENDORS_START_DATE<'01-01-2024' -- n'ayant pas été modifiée avant 2024
	and p.STATUS_ID in ('20','13','10') -- policy, proposal et suspended
	and T_PROD_TCSVER_TCS.ID in (1000025) -- ETI 2013
	AND P_POLICY_TCS.GENERAL_CONDITIONS_VERSION<>'01.2022');
 COMMIT
-- ROLLBACK

-- =================
-- CAS 2 - ETI 2019
-- =================
-- 15049 lignes a update - Select de vérification
SELECT * FROM P_POLICY_TCS where P_POLICY_TCS.ID in (select ptcs.id from T_PRODUCT
inner join T_PROD_TCSVER_TCS on T_PROD_TCSVER_TCS.PRODUCT_ID=T_PRODUCT.PRODUCT_ID
inner join P_POLICY_TCS as ptcs on ptcs.TCS_PRODUCT_VERSION=T_PROD_TCSVER_TCS.ID
inner join P_POLICY as p on p.id=ptcs.id
inner join P_POL_HEADER as ph on p.policy_header_id=ph.id
where EXTERNAL_POLICY_NUMBER is not null
and p.POLICY_START_DATE<'01-01-2024' -- date fin validité cga 2022
and p.POLICY_START_DATE>='01-01-2022' -- date début validité cga 2022
and p.ENDORS_START_DATE<'01-01-2024' -- n'ayant pas été modifiée
and p.STATUS_ID in ('20','13','10') -- policy, proposal et suspended
and T_PROD_TCSVER_TCS.ID in (1000026)  -- ETI 2019
AND P_POLICY_TCS.GENERAL_CONDITIONS_VERSION<>'01.2022');

-- update
BEGIN TRANSACTION
	update P_POLICY_TCS set GENERAL_CONDITIONS_VERSION='01.2022', GENERAL_CONDITIONS_TCS='1000023' where P_POLICY_TCS.ID in (select ptcs.id from T_PRODUCT
	inner join T_PROD_TCSVER_TCS on T_PROD_TCSVER_TCS.PRODUCT_ID=T_PRODUCT.PRODUCT_ID
	inner join P_POLICY_TCS as ptcs on ptcs.TCS_PRODUCT_VERSION=T_PROD_TCSVER_TCS.ID
	inner join P_POLICY as p on p.id=ptcs.id
	inner join P_POL_HEADER as ph on p.policy_header_id=ph.id
	where EXTERNAL_POLICY_NUMBER is not null
	and p.POLICY_START_DATE<'01-01-2024' -- date fin validité cga 2022
	and p.POLICY_START_DATE>='01-01-2022' -- date début validité cga 2022
	and p.ENDORS_START_DATE<'01-01-2024' -- n'ayant pas été modifiée
	and p.STATUS_ID in ('20','13','10') -- policy, proposal et suspended
	and T_PROD_TCSVER_TCS.ID in (1000026)  -- ETI 2019
	AND P_POLICY_TCS.GENERAL_CONDITIONS_VERSION<>'01.2022');
 COMMIT
-- ROLLBACK