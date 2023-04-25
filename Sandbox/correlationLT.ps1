Param (
    [Parameter(Mandatory=$True)][String]$Path
)

Import-Module libEncoding

#$Path = "D:\dev\40_PowerShell\PowerShell\data\input\list.txt"
$ltFile = "D:\dev\40_PowerShell\PowerShell\data\input\LT_num.csv"
$keyIndex = "col1"

"Read source index $Path as encoded with " + (Get-Encoding -path $Path).Encoding
if (-not (is_UTF8($Path))) {
    "Convert $Path to UTF8 encoding..."
    ConvertTo-UTF8 -path $Path 
    "Read source index $Path as encoded with " + (Get-Encoding -path $Path).Encoding
}

"Add extra column based on Lootkup table $ltFile with key set to $keyIndex"
$count = 0
$bypassed = 0

$lt = Import-csv $ltFile  -Header ("key","value") -Delimiter ";" | Group-Object -AsHashTable -Property key
$list = Import-CSV  $Path -Delimiter ";" -Header ("col1","col2","col3","col4")
$countInputRecords = ($list).Count
$new_list = [System.Collections.ArrayList]@()

foreach ($item in $list) {
    $count += 1
    if ($lt.ContainsKey($item.$keyIndex)) { 
        $item | Add-Member -Name DocType -Type NoteProperty -value $lt[$item.col1].value 
        $new_list += $item
   } else {
       "no key found for key " + $item.col1 + " on row " + $count + " -> Bypass this record "
       $bypassed += 1
   }
}
"Total input record(s))   : " + $countInputRecords + " record(s))"
"Total record(s) read     : " + $count + " record(s))"
"Total record(s) bypassed : " + $bypassed + " record(s))"
"Export transformed file to $Path" 

$new_list |ConvertTo-Csv -Delimiter ";" -NoTypeInformation  | ForEach-Object { $_ -replace '"',''} | Select-Object -Skip 1 | Set-Content -path $Path -Encoding utf8BOM -Force
"Exported records         : " + ($new_list).Count + " record(s))"

"Read source $Path encoding -> " + (Get-Encoding -path $Path).Encoding

