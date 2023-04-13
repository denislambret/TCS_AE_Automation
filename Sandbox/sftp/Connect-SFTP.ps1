Import-Module Posh-SSH

$source = "/etc/ssh"
$dest = "D:\dev\40_PowerShell\tcs\data\output\sftp"

#Setting credentials for the user account
$user = "vagrant"
$password = ConvertTo-SecureString "vagrant" -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ($user, $password)

#Establishing an SFTP session
$Session = New-SFTPSession -ComputerName 192.168.1.101 -Credential $creds

#Downloading the .NET installer file by using the established SFTP session
"Session created - ID #" + $Session.SessionID

# Build remote pub keys list and xfert to local
$list = Get-SFTPChildItem -SessionId $Session.SessionID -Path "/etc/ssh" 
$list | Where-Object { $_.name -match "priv$" } | ForEach-Object { 
              "Copy " + $source + "/" + $_.name + " to " + $dest
              Get-SFTPItem -SessionId $Session.SessionID -Path ($source + "/" + $_.name) -Destination $dest -Force
}

# Close session
Remove-SFTPSession -SessionId $Session.SessionID | Out-Null
"Session closed"