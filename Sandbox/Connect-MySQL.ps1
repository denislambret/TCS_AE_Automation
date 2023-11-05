[void][system.reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MySQL\MySQL Connector Net 8.0.30\Assemblies\v4.8\MySql.Data.dll")
$Mysqlhost= "192.168.1.100"
$Mysqluser= "dbadmin"
$Mysqlpass= "1234qwerASD!"
$Mysqldatabase= "dummy"

$Connection = [MySql.Data.MySqlClient.MySqlConnection]@{ConnectionString="server=$Mysqlhost;uid=$Mysqluser;pwd=$Mysqlpass;database=$Mysqldatabase"}
$Connection.Open()
$sql = New-Object MySql.Data.MySqlClient.MySqlCommand
$sql.Connection = $Connection

$sql.CommandText = "SELECT Id,DATE(date_timestamp) AS DATE
FROM RawRecords AS r
WHERE DATE(date_timestamp) > DATE_SUB(curdate(),INTERVAL 2 DAY)"
$myreader = $sql.ExecuteReader()
$recLst = @()
while($myreader.Read()) { 
    $rec = $myreader.GetString(0); 
    $recLst += $rec 
}


$myreader.Close()

($recLst).Count

$recLst