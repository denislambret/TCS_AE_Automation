Import-Module Logging

Add-LoggingTarget -Name Console -Configuration @{
    Level        = 'DEBUG'             
    Format       = '[%{timestamp:+yyyy/MM/dd HH:mm:ss.fff}][%{caller}-%{pid}] %{message}'
    ColorMapping = @{
        'DEBUG'   = 'Blue'
        'INFO'    = 'Green'
        'WARNING' = 'Yellow'
        'ERROR'   = 'Red'
    }
}

$logFileName = 'd:\dev\40_PowerShell\'+ (Get-Date -Format "yyyyMMdd") + "_testlog.log"
Add-LoggingTarget -Name File -Configuration @{
    Path         = $logFileName
    Level        = 'DEBUG'             
    Format       = '[%{timestamp:+yyyy/MM/dd HH:mm:ss.fff}][%{filename}-%{pid}] %{message}'
    Append       = $true    
    Encoding    = 'ascii'               
}

$range = 1..100
foreach ($iter in $range) {
    Write-Log -Level 'INFO' -Message 'Iteration loop #{0}' -Arguments $iter
}+