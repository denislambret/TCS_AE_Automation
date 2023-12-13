# Retrieve batch dashboard view
$usrname = "Administrator"
$pwd = "1111"
$url = 'https://idit-acp.tcsgroup.ch/idit-web/api/batch/dashboard?'


$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("accept", "application/json")
$headers.Add("userName", $usrname)
$headers.Add("password", $pwd)

$response = Invoke-RestMethod $url -Method 'GET' -Headers $headers
$response | ConvertTo-Json
Remove-Variable -Name $response

# Get Policy
$policyNumber = "PO011680237-10500/01"
$url = 'https://idit-web/api/policy/tcs/' + $policyNumber
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("accept", "application/json")
$headers.Add("userName", $usrname)
$headers.Add("password", $pwd)

$response = Invoke-RestMethod $url -Method 'GET' -Headers $headers
$response | ConvertTo-Json
Remove-Variable -Name $response


(Measure-Command { 
                    $result = Invoke-RestMethod $url -Method 'GET' -Headers $headers
                }).Milliseconds
Remove-Variable -Name $result