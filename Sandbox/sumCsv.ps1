$src_data = "D:/dev/40_PowerShell/PowerShell/data/input/test.csv"

$csv = Import-Csv -Path $src_data -Header @('Name','Count','Comment') -Delimiter ";"

$csv_sorted = $csv | Group-Object -Property Name 

$formated = $csv_sorted | ForEach-Object  {
    New-Object PSCustomObject @{
        userName = $_.Name
        userCount = ($_.Count | Measure-Object -Sum).Sum
    }
}

$formated | foreach-object {
    Write-Host $_.userName "=" $_.userCount
}
