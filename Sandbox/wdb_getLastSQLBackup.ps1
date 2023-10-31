# SFTP tests
[string]$userName       = 'dev'
[string]$userPassword   = '1234qwerASD'
[string]$srv            = "192.168.1.15"

[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)
$source = "/home/share/WeatherDB/sql/BACKUPS/WeatherDB_ALL.sql.zip"
$dest   = "D:\dev\40_PowerShell\PowerShell\data\input\sftp\pi4\"
Write-Host "Connect to $srv"
$SFTPSession = New-SFTPSession -ComputerName $srv -Credential ($credObject)
Write-Host "Copy $source --> $dest"
Get-SFTPItem -SessionId $SFTPSession.SessionId -Path $source -Destination $dest  -Force
if (Remove-SFTPSession $SFTPSession) {
    Write-Host "File succesfully transfered!"
}
exit 0

