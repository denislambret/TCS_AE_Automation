$list = gc *.json | convertFrom-Json
$list | Select -ExpandProperty results  | select id, name, time, responseCode