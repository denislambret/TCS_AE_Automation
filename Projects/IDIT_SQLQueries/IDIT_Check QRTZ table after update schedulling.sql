--- Comparaison des tables SYSTEM_TRIGGER_CRON_EXPR et QRTZ_CRON_TRIGGERS
-- Il faut faire cette requete après un changement de schedulling et un refresh cache.
-- En ca de différences de records entre les deux tables alors, il faut faire un purge de la table QRTZ_CRON_TRIGGER 
-- pour supprimer les doublons. Dans cette situation les batches servers doivent ensuite être redémarré !!!
Select id, SYSTEM_TRIGGER_CRON_EXPR, *
from IDIT_PRD.dbo.T_BATCH_JOB with(nolock)
where SYSTEM_TRIGGER_CRON_EXPR is not null
order by JOB_DESC asc
 
select top 1000 *
from IDIT_PRD.dbo.QRTZ_CRON_TRIGGERS as cr with(nolock)
order by TRIGGER_GROUP asc 