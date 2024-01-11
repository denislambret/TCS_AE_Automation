
#-- List batches from IDIT
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("userName", "Administrator")
$headers.Add("password", "1111")
$headers.Add("Cookie", "BIGipServerPOOL_ACP_idit-acp.tcsgroup.ch=2454920876.10531.0000; jawrSkin=defaultSkin")

$body = @"

"@

$response = Invoke-RestMethod 'https://idit-acp.tcsgroup.ch/idit-web/api/batch' -Method 'GET' -Headers $headers -Body $body
$response | ConvertTo-Json