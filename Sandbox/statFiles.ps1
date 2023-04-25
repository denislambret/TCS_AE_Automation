$source = "D:\dev\40_PowerShell\PowerShell\data\input\logs"
$filter = "*.log"
$startDate = [Datetime]::ParseExact('2020-01-01', 'yyyy-MM-dd', $null)
$endDate = [Datetime]::ParseExact('2022-02-10', 'yyyy-MM-dd', $null)
$archive = $false
$remove = $false

"---------------------------------------------------------------------------------------------------"
"Scan -> $source for pattern $filter"
"---------------------------------------------------------------------------------------------------"
$file_list = Get-ChildItem $source -filter $filter | Where-Object {($_.LastWriteTime -ge $startDate) -and ($_.LastWriteTime -le $endDate) }
$file_list | Format-Table -Autosize
"---------------------------------------------------------------------------------------------------"
$file_size     = ($file_list | Measure-Object -Property Length -Sum).Sum
$file_size_min = ($file_list | Measure-Object -Property Length -Minimum).Minimum
$file_size_max = ($file_list | Measure-Object -Property Length -Maximum).Maximum
$file_entries  = ($file_list | Measure-Object -Property Length).Count
$file_avgSize  = ($file_list | Measure-Object -Property Length -Average).Average
"Total file(s) found        : " + $file_entries + " item(s)"
"Total file(s) size         : " +  [math]::Round(($file_size / 1Kb),2) + " KB" 
"Min file size              : " +  [math]::Round(($file_size_min),2) + " Bytes" 
"Max file(s) size           : " +  [math]::Round(($file_size_max / 1Kb),2) + " KB" 
"Averge file size           : " +  [math]::Round(($file_avgSize / 1Kb),2) + " KB"
"Estimated file size        : " +  [math]::Round((($file_size + $file_entries) / 1Kb),2) + " KB"
"---------------------------------------------------------------------------------------------------"

if ($archive) {
    if ((-not (Test-Path -Path $source -PathType Leaf))) { $zip_file = $source + "\" + (Get-Date -Format "yyyyMMdd_") + ($my_script -replace ".ps1",".zip")}
    else {$zip_file = $source}

    "Run Compress cmdlet... -Path $file_list -DestinationPath $zip_file" 
    $error.clear()
    try {
            "Compress-Archive -Path $file_list -DestinationPath $zip_file -ErrorAction Continue -Force | Out-Null"
            Compress-Archive -Path $file_list -DestinationPath $zip_file -ErrorAction Continue -Force | Out-Null
        }
        catch {
            $error[0].exception.gettype().fullname 
            Wait-Logging
            exit 
        }
    "Archive created -> $zip_file created"

    if ($remove) {
        try {
            foreach ($source_file in $list) {
                Remove-Item -Path $source_file -ErrorAction Continue                                                                                 
                "$source_file file removed"
            }
        }
        catch {
            $error[0].exception.gettype().fullname 
            Wait-Logging
            exit 
        }
        ($list).Count + " source file(s) removed successfully"
    }
}