$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("userName", "Administrator")
$headers.Add("password", "1111")
$headers.Add("Content-Type", "application/json")
$headers.Add("Cookie", "BIGipServerPOOL_ACP_idit-acp.tcsgroup.ch=2454920876.10531.0000; jawrSkin=defaultSkin")

$body = @"
{
  `"jobId`": 1000072,
  `"checkPreviousExecution`": true,
  `"updateVersion`": 0,
  `"priority`": 3
}
"@
$response = $null
$response = Invoke-RestMethod 'https://idit-acp.tcsgroup.ch/idit-web/api/batch' -Method 'POST' -Headers $headers -Body $body
$response = $response | ConvertTo-Json
