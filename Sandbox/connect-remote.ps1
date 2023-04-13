function get-fileList {
        Get-ChildItem c:\ | ft
}

# Prepare connection information
#$host_list = @("WGE1AS056T.tcsgroup.ch","WGE3AS164T.tcsgroup.ch","WGE1AS053T.tcsgroup.ch","WGE1AS056T.tcsgroup.ch","WGE1AS165T.tcsgroup.ch","WGE1AS057T.tcsgroup.ch")
$host_list = @("WGE1AS056T.tcsgroup.ch")
$user = "LD06974ADM"
$pwd = ConvertTo-SecureString "1234SamsungS10+" -AsPlainText -Force
[pscredential] $cred = New-Object System.Management.Automation.PSCredential($user,$pwd)

foreach ($item_host in $host_list) {


    Invoke-Command -ComputerName $item_host -Credential $cred -ScriptBlock {[System.Net.DNS]::GetHostByName($Null)}
    Invoke-Command -ComputerName $item_host -Credential $cred -ScriptBlock {get-fileList}
}
