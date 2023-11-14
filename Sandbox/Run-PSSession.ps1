$user = "ld06974adm"
$pwd = "1234SamsungS13+"
$srv = "WGE3AS161D"

# Create credentials for remote connection
[securestring]$password = ConvertTo-SecureString -String $pwd -AsPlainText -Force
[pscredential]$cred = New-Object System.Management.Automation.PSCredential ($user, $password) 

Enter-PSSession -computername $srv -Credential $cred
    Push-Location
        Set-Location -path 'd:\'
        Get-ChildItem
    Pop-Location
Exit-PsSession