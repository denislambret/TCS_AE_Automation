$txt = "./data.txt"


class dbStats {
    [string]$db                = ''
    [string]$cmdType           = ''
    [string]$start             = ''
    [string]$end               = ''
    [string]$statname          = ''
}


$raw = Get-Content $txt
$list = @()


foreach ($item in $raw) {
    if ($item -match 'DatabaseName') {
        if ($obj) {
                $list += $obj
                $obj = $null
            }
        
        $obj = New-Object dbStats
        $obj.db = ($item -split ':')[1]
   } elseif ($item -match 'CommandType') {
        $obj.cmdType = ($item -split ':')[1]
   } elseif ($item -match 'StartTime') {
        
        $rc = $item | select-string -Pattern '(.*):(.*).(.*).(.*) (.*):(.*):(.*)' -AllMatches
        if ($rc) {
            $obj.start = $rc.Matches[0].Groups[5].Value + ":" + $rc.Matches[0].Groups[6].Value + ":" + $rc.Matches[0].Groups[7].Value
        }
        
   } elseif ($item -match 'EndTime') {
        $rc = $item | select-string -Pattern '(.*):(.*).(.*).(.*) (.*):(.*):(.*)' -AllMatches
        if ($rc) {
            $obj.end = $rc.Matches[0].Groups[5].Value + ":" + $rc.Matches[0].Groups[6].Value + ":" + $rc.Matches[0].Groups[7].Value
        }
   } elseif ($item -match 'StatisticsName') {
        $obj.statName = ($item -split ':')[1]
   }
}

Write-Host ($list).count " object(s) created"
$list | Export-CSV -path "./output.csv" -Delimiter ";"