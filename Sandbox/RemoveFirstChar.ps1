$source = D:\dev\60_Python\WeatherDB\data\test.csv
$dest =

$buffer = gc $source
foreach ($line in $buffer) {
    Write-Host $line
}