$delay      = -24
$today      = $(Get-Date)
$todayf     = Get-Date -format "yyyyMMdd"
$logSection = @('system','application','hyland','onbase')
$output     = "Y:\03_DEV\01_Powershell\data\Output"

Write-Host "Scanning the event log of: " -NoNewLine; Write-Host $server;
foreach ($section in $logSection) {
    Write-Host "Get $section logs..."
    if (-not (Test-Path $output/$todayf"_WinSysLogs_$section.txt")) { 
        New-Item $output/$todayf"_WinSysLogs_$section.txt" | out-null
    } 
    else {
        Remove-item -Force $output/$todayf"_WinSysLogs_$section.txt"
    }
    
    try {
        Get-EventLog -LogName $section -After ($today).AddHours($delay) -EntryType Error, Warning | ConvertTo-Csv -Delimiter ";" | Set-Content $output/$todayf"_WinSysLogs_$section.csv"
    }
    catch {
        Write-Host "No log section found!"
    }
}