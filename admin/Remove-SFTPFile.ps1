#----------------------------------------------------------------------------------------------------------------------------------
#                                            C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
    # path of the resource to process
    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $true,
        Position = 0
        )
    ]
    [alias('conf','c')] $config_path,
    
    # help switch
    [switch] $help
)

#----------------------------------------------------------------------------------------------------------------------------------
#                                             _______ _______ _____ __   _
#                                             |  |  | |_____|   |   | \  |
#                                             |  |  | |     | __|__ |  \_|
#----------------------------------------------------------------------------------------------------------------------------------
$VERSION      = "0.1"
$AUTHOR       = "DLA"
$SCRIPT_DATE  = "2024.02.22"

'-' * 140
$MyInvocation.MyCommand.Name + " v" + $VERSION
'-' * 140

# 1 - Load configuration 
try {
    [XML]$conf = Get-Content $config_path
    $confRoot = $conf.conf
}
catch [System.IO.FileNotFoundException] {
    Write-Host ("Configuration file not found " + $config_path)
    Write-Host ("Process aborted! " + $config_path)
    exit $EXIT_KO
}

# 2 - Spécifiez les informations d'authentification pour le serveur SFTP
$passwd = ConvertTo-SecureString $confRoot.sftp_servers.sftp_server_tcs.userpwd -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ($confRoot.sftp_servers.sftp_server_tcs.username, $passwd)

# 3 - Créez une session SFTP
$sessionSFTP = New-SFTPSession -ComputerName $confRoot.sftp_servers.sftp_server_tcs.computername -Credential $creds
"SFTP Session opened on " + $confRoot.sftp_servers.sftp_server_tcs.username

# 4 - Spécifiez le chemin du répertoire distant que vous souhaitez explorer
$count = 0

# 5 - Obtenez la liste des fichiers plus anciens de 90 jours
"Listing remote file electible(s) for removal..."
$elderThan = (Get-Date).AddDays(-90)
"Retention is set with a minimum date set to $elderThan"
$files = Get-SFTPChildItem -SFTPSession $sessionSFTP -Path $confRoot.sftp_servers.sftp_server_tcs.sftp_input_path |
         Where-Object { $_.LastWriteTime -lt $elderThan }

# 6 - Affichez les noms des fichiers et proceder a la suppression
$files | ForEach-Object { 
    Write-Host "Remove file : "$($_.Name)  
    Remove-SFTPItem $_.FullName
    $count++
}
'-' * 140
"Total file(s) removed : $count file(s)"
'-' * 140

# 7 - Fermez la session SFTP
Remove-SFTPSession -SFTPSession $sessionSFTP | Out-Null