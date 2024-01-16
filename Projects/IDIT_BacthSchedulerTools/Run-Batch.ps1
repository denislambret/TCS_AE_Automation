
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("userName", "Administrator")
$headers.Add("password", "1111")
$headers.Add("Content-Type", "application/json")
$headers.Add("Cookie", "BIGipServerPOOL_ACP_idit-acp.tcsgroup.ch=2454920876.10531.0000; jawrSkin=defaultSkin")

$body = @"
{
  `"jobId`": `"13228`",
  `"checkPreviousExecution`": `"true`",
  `"updateVersion`": `"0`",
  `"priority`": `"3`"
}
"@


# 1 - Load script config file
$conf = ".\acp.conf"
try {
    [XML]$conf_raw = Get-Content $config_path
    $conf = $conf_raw.conf
}
catch [System.IO.FileNotFoundException] {
    Write-Error ("Configuration file not found " + $config_path)
    Write-Error ("Process aborted! " + $config_path)
    exit $EXIT_KO
}

# 2 Build WSI request
$response = $null
$conf.wsi.query[1].url + " - " + $conf.wsi.query[1].method
try {
        $response = Invoke-RestMethod $conf.wsi.query[1].url -Method  $conf.wsi.query[1].method -Headers $headers -Body $body 
        
  } catch {
    # Dig into the exception to get the Response details.
    # Note that value__ is not a typo.
    Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
    Write-Host "StatusDescription:" $_.Exception.Response.ReasonPhrase
    Write-Host "Error Details :" ($_.ErrorDetails.Message | Convertfrom-json).title
    exit 1
  }

  # 3 Display response
$response  | format-table
"job created with id #" + $response.logId

