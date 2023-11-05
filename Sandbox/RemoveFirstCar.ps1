$source = 'D:\dev\60_Python\WeatherDB\data\MeteoBlue_LowRes_dataexport_20210718T094329.csv'
$dest   = 'D:\dev\60_Python\WeatherDB\data\MeteoBlue_LowRes_dataexport_20210718T094329_final.csv'
$buffer = gc -path $source
$count = 0
$bCount = ($buffer.count)
Write-Host 'Buffer line(s) :' $bcount

Remove-Item $dest
New-Item -path $dest
foreach ($line in $buffer) {
    if (($count % 1000) -eq 0) {
        Write-Host "Lines processed : "$count" / "$bCount
    }
    $line = $line.substring(1)
    Add-Content -path $dest -value $line
    $count += 1
}