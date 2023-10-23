-- [‎12.‎10.‎2023 15:25]  SASSI Fares:  
-- verification - on veut supprimer cette ligne  - Une seule ligne doit être concernee
-- select * from T_GEN_CONDITIONS_TCS where T_GEN_CONDITIONS_TCS.ID=1000049 and T_GEN_CONDITIONS_TCS.description='09.2023';
-- delete from T_GEN_CONDITIONS_TCS where T_GEN_CONDITIONS_TCS.ID=1000049 and T_GEN_CONDITIONS_TCS.description='09.2023'; -> n'a pas marché car contraintes avec autres tables.

update T_GEN_CONDITIONS_TCS SET T_GEN_CONDITIONS_TCS.end_date='2023-09-01' WHERE T_GEN_CONDITIONS_TCS.ID=1000049 and T_GEN_CONDITIONS_TCS.description='09.2023';

-- Verification - on veut enlever la date de fin qui a été mise par erreur sur ce parametre de CGA - Une seule ligne doit être concernee
-- select * from T_GEN_CONDITIONS_TCS where T_GEN_CONDITIONS_TCS.ID=1000042 and T_GEN_CONDITIONS_TCS.description='05.2023';
update T_GEN_CONDITIONS_TCS set T_GEN_CONDITIONS_TCS.end_date=NULL where T_GEN_CONDITIONS_TCS.ID=1000042 and T_GEN_CONDITIONS_TCS.description='05.2023'; 
-- select * from T_GEN_CONDITIONS_TCS where T_GEN_CONDITIONS_TCS.ID=1000042 and T_GEN_CONDITIONS_TCS.description='05.2023';
