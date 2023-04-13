$source = "Y:\03_DEV\06_GITHUB\tcs-1\Projects\POSTMAN - JSON_Converter\data\input"
$output_file = "Y:\03_DEV\06_GITHUB\tcs-1\Projects\POSTMAN - JSON_Converter\data\output\stats.csv"
$sep = ";"
$records = @()
write-host "--------------------------------------------------------------------------------------------------"
$jsonList = Get-ChildItem -Path $source -Filter "*.json"  
$header ="timestamp;envID;campaignID;campaignName;testName;code;time"
Set-Content -path $output_file -Value $header

foreach ($item in $jsonList) {
   
   write-host "Processing" $item.fullname
   $json = Get-Content -path $item.FullName | ConvertFrom-Json
   $results = $json.results
   foreach($result in $results) {
      foreach($t in $result.times)
      {
        $record = [string]$json.timestamp + $sep + $json.environment_id + $sep + $json.id + $sep + $json.name + $sep 
        $record = $record + $result.name + $sep + $result.responseCode.code + $sep 
        $record = $record + $t
        $records += $record
      }      
  }
}
Add-Content -path $output_file -Value $records
write-host "--------------------------------------------------------------------------------------------------"
Add-Content -path $output_file -Value $records
write-host "CSV generated as " $output_file
