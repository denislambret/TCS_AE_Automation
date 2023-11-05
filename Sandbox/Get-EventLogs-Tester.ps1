$source = "./localhost.txt"

$logname = ""
$id = 0


$list = Get-Content $source 
foreach ($item in $list) {
    while (-not $logname) {$logname =  Read-Host "Enter log name"}
    while (-not $id) {$id =  Read-Host "Enter log message id"}
 
    "Searching host "+$item
    "----------------------------------------------------------------------------------------------"
    $rec = Get-EventLog -LogName $logname -computer $item -index $id
    "Found : " + $rec.Message
 
    $output = "./" + (get-date -f "yyyyMMdd" )+ "_" + $item + "_" + $logname + "_"
 
    $rec | Select-Object -Property MachineName, TimeGenerated, Source, message | Export-CSV $output
}