Import-Module SimplySql -Force

$user = "dev"
[securestring]$password = ConvertTo-SecureString -String "1234qwerASD" -AsPlainText -Force
[pscredential]$cred = New-Object System.Management.Automation.PSCredential ($user, $password) 
$server = "192.168.1.3"
$db = 'WeatherDB'



try {
    Open-MySqlConnection -ConnectionName test -server $server -Database $db -Credential $cred
}
catch {
    Write-Host $Error
    Write-Host $StackTrace 
    exit
}

"Setting up dates..."
$start = '2023-11-01 00:00:00'
$end = '2023-11-31 23:59:59'

"Query snow report summary"

$query = "
SELECT date_timestamp, Locations.name, AVG(temp - 273.15) AS 'Average temperature', SUM(Snow_1h) AS 'total snow'
FROM RawRecords
INNER JOIN Locations ON RawRecords.id_location = Locations.id
WHERE RawRecords.id_location = 6
AND date_timestamp BETWEEN '$start' AND '$end' 
AND Snow_1h > 0
GROUP BY DAY(date_timestamp), Locations.name
ORDER BY date_timestamp
"

try {
       $results = Invoke-SQLQuery -ConnectionName test -query $query | Format-Table -AutoSize
}
catch {
    Write-Host $Error
    Write-Host $StackTrace 
}


$results | Format-Table -AutoSize

try {
    Close-SqlConnection -ConnectionName  test
}
catch {
    Write-Host $Error
    Write-Host $StackTrace 
}
finally {
    exit $EXIT_KO
}

exit $EXIT_OK