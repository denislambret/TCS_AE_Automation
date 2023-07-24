select * from T_SETUP_PROJECT_DATA
where entity_number = (select id from t_system_entity where table_name = 'T_MAIN_CAMPAIGNS') 
and entity_id = '%' --missing record id
and change_type = 1 --record creation

select * from T_SETUP_PROJECT_DATA

select id from t_system_entity where table_name = 'T_MAIN_CAMPAIGNS' --select main campaign list

select * from T_SETUP_PROJECT_DATA
where entity_number = (select id from t_system_entity where table_name = 'T_MAIN_CAMPAIGNS') -- missing tables
and change_type = 1 --record creation
