$username = "SVC-D-OnBase1-01"
$password = "_tn47fF6UsQ4"
$password = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList($username, $password)
$server = "WGE1AS050T.tcsgroup.ch"

#$session = Enter-PSSession -ComputerName $server -Credential $cred
$result = invoke-command -ComputerName $server -Credential $cred -ScriptBlock {Restart-Computer}

# Push-Location
# Set-Location "D:/scripts/logs"
# gci *.log
# popd 

# Disconnect-PSSession -Session $session