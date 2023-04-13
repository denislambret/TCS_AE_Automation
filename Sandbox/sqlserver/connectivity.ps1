
Import-Module MySQLCmdlets

$query = "
select count(id) as nb 
from WeatherDB.RawRecords 
where date_timestamp between date(now()) and now();"

"-------------------------------------------------------------------------------------------------------------------------"
try {
    $mysql = Connect-MySQL -User "dev" -Password "1234qwerASD" -Database "WeatherDB" -Server "192.168.1.15" -Port 3306
} catch {
    "db connection error..."
    exit 1
}

(get-date -format "yyyyMMdd hh:mm:ss") + " - Connection to WeatherDB is successfull !"
$response = Invoke-Mysql -Connection $mysql -query $query


"Record inserted today in RawRecords table -> " + $response.nb + " record(s)"
"-------------------------------------------------------------------------------------------------------------------------"
$query = "
    select id_location as id, l.name, l.altitude, l.longitude, l.latitude, count(*) as records
    from WeatherDB.RawRecords 
    inner join Locations as l on l.id = id_location
    where date_timestamp between date(now()) and now() 
    group by id_location;
"

$response = Invoke-MySQL -Connection $mysql -Query $query 
$response | Add-Member -NotePropertyName Status -NotePropertyValue Done
$response | ft
"-------------------------------------------------------------------------------------------------------------------------"

