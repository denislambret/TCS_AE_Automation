# 1 - Load modules
Import-Module libSFTP


# 2 - Load config files
$config_path = ".\PRD.conf"
try {
    [XML]$confRoot = Get-Content $config_path
}
catch [System.IO.FileNotFoundException] {
    Log -Level "ERROR" -Message ("Configuration file not found " + $config_path)
    Log -Level "ERROR" -Message ("Process aborted! " + $config_path)
    Clean-TemporaryDirectory
    Stop-Log | Out-Null
    exit $EXIT_KO
}

# 3 - Open SFTP Connection
$sessionID = Connect-SFTPPrivKey -server $conf.conf.sftp_servers.sftp_server_poste.computername -user $confRoot.conf.sftp_servers.sftp_server_poste.username -privKey $confRoot.conf.sftp_servers.sftp_server_poste.privkey
$sessionID
# 4 - Get file source list
$list = Get-SFTPFileList -session $sessionID -remotePath '/PROD'

# 5 - Close connexion
Close-SFTP -session $sessionID