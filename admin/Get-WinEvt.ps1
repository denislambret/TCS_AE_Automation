clear
$root_dir = "."
$errEvtFileName = $root_dir + "\" + (Get-Date -f 'yyyyMMdd') + "_error_evt.csv"
$warnEvtFileName = $root_dir + "\" + (Get-Date -f 'yyyyMMdd') + "_warning_evt.csv"

$bt = systeminfo | select-string "System Boot Time"
if ($bt -match "\d{1,2}.\d{1,2}.\d{4}") {$bt = [Datetime]::Parse($Matches[0]);}

$sources = @("Application","System")

Foreach ($source in $sources) {
    Get-WinEvent -FilterHashTable @{'LogName' = $source; 'StartTime' = $bt} `
    | Select-Object TimeCreated, ID, ProviderName, LevelDisplayName, Message `
    | Where-Object {$_.LevelDisplayName -match "Error"} `
    | Export-Csv -Path $errEvtFileName -Delimiter ";" -Append
    
    Get-WinEvent -FilterHashTable @{'LogName' = $source; 'StartTime' = $bt} `
    | Select-Object TimeCreated, ID, ProviderName, LevelDisplayName, Message `
    | Where-Object {$_.LevelDisplayName -match "Warning"} `
    | Export-Csv -Path $warnEvtFileName -Delimiter ";" -Append
}
