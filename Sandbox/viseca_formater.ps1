# VISECA extract formater to CSV

$source = "D:\dev\40_PowerShell\10_local\data\input\VISECA.txt"
$dest = "D:\dev\40_PowerShell\10_local\data\output\VISECA.csv"

$record = ""
$recCount = 0
$content = get-content $source
$first = $true
$csvList = @()

Write-Host "------------------------------------------------------------------------------------------------"
foreach ($item in $content) {
   if ($first) {
       $csvList += $record
       $first = $false
       if (($item -match '\d{2}\.\d{2}\.\d{4}') -or ($item -in 'JANVIER', 'FEVRIER', 'MARS', 'AVRIL', 'MAI', 'JUIN', 'JUILLET', 'AOUT', 'SEPTEMBRE', 'OCTOBRE', 'NOVEMBRE', 'DECEMBRE' ) -or ($item -match '(.*)EUR$') )  {
         $first=$true  
         continue
       }
       $record = $item
    }
    else {
      if ($item -match '\d{2}\.\d{2}\.\d{4}') {
         $item = $item.Substring(0,10)
       } 
       elseif (($item -match  '(.*)CHF$')) {
         $item = $item -replace ' CHF',''
         $first = $true;
         $recCount++
       }
       $record += ";" + $item 
    } 
}

$csvList | Out-File $dest
$csvList = Import-Csv $dest -Delimiter ";" -Header @('category','desc','date','value')
$csvList | Select-Object date,desc,value,category | Sort-Object value -Descending