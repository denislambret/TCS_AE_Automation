Import-Module SimplySql -Force

$user = "dbadmin"
[securestring]$password = ConvertTo-SecureString -String "1234qwerASD!" -AsPlainText -Force
[pscredential]$cred = New-Object System.Management.Automation.PSCredential ($user, $password) 
$server = "192.168.1.100"
$db = 'wdb'



try {
    Open-MySqlConnection -ConnectionName test -server $server -Database $db -Credential $cred
}
catch {
    Write-Host $Error
    Write-Host $StackTrace 
}

$start = '2023-10-10 00:00:00'
$end = '2023-10-10 23:59:59'

$query = "`
SELECT date_timestamp, Locations.name, temp, pressure, humidity, clouds_cover, Rain_1h
 FROM RawRecords
 INNER JOIN Locations ON id_location = Locations.id
 WHERE id_location = 6
 AND date_timestamp BETWEEN '$start' AND '$end' 
 ORDER BY date_timestamp DESC
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