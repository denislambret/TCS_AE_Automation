[XML]$confFile = (get-Content -path ./sample.conf.xml)

$confFile.conf.cleaner.directory | foreach-object { $_ }

