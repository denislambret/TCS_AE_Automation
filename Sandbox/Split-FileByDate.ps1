$root = "Y:\99_TMP\"

$buffer = @() 
$fileList = Get-ChildItem ($root + '*.part')
$fileList | Foreach-object {
    "Processing file : " + $_.name
    $content = get-content ($root + $_.name)
    $totalLines = ($content).Count
    
    if ($buffer) {    
        $buffer | Out-File -Append -path $logName
        $buffer = @()
    }
    
    $prevDate = "1980-01-01"
    $lineCount = 0
    foreach ($line in $content) {
        
        $lineCount += 1
        if ($line -match '(\d{4})/(\d{2})/(\d{2}) (\d{2}):(\d{2}):(\d{2})') {
            $year = $Matches[1]
            $month = $Matches[2]
            $day = $Matches[3]
            $hour = $Matches[4]
            $minute = $Matches[5]
            $second = $Matches[6]
            
            $curDate = $year + $month + $day
            if (($curDate -ne $prevDate) -and ($buffer)) {
                $buffer | Out-File -Append -path $logName
                "New file date...Dump buffer in out-file " + $logName
                $buffer = @()
            }
            if ($year -and $month -and $day) {
                $logName = $root + $curDate + "_Nginx_RevProxy.log"
            }   
        }
        $buffer += $line
        $prevDate = $year + $month + $day
        if (-not ($lineCount % 1000)) {
            "Total lines processed so far : " + $lineCount + " / " + $totalLines 
            $buffer | Out-File -Append -path $logName
            $buffer = @()
        }

    }
    
    "Rename source as treated."
    Move-Item ($root + $_.name) -Destination ($root  + $_.name + ".treated")
}