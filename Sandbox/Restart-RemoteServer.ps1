$user = "ld06974adm"
$pwd = "1234SamsungS13+"
$srv = "WGE3AS161D"

$tryCount = 1
$maxTries = 5

# Create credentials for remote connection
[securestring]$password = ConvertTo-SecureString -String $pwd -AsPlainText -Force
[pscredential]$cred = New-Object System.Management.Automation.PSCredential($user, $password) 

# Restart remote server
try {
    Restart-Computer -ComputerName $srv -credential $cred -force    
}
catch {
    <#Do this if a terminating exception happens#>
    "Error restarting remote server "+$srv
    $Error
}

"Wait until remote system reboot... This could take some time."

# Wait until wer are able to get last reboot time
# 3 attempts. One every minute
while ($tryCount -le $maxTries ) {
    Start-Sleep -seconds 10

    try {
        $rc = Invoke-Command -ComputerName $srv -Credential $cred -ScriptBlock {(systeminfo | select-string -pattern "System Boot time")}
   }
   catch {
    "Error geting last reboot time on "+$srv
   } 

   if ($rc) { 
    $rc
    break
  }

  $tryCount++
}

