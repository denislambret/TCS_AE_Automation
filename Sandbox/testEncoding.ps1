
Import-Module libEncoding

$source = "Y:\03_DEV\01_Powershell\data\Input\"
$dest   = "Y:\03_DEV\01_Powershell\data\Input\"


$list = Get-ChildItem $Source -Filter *.csv

ForEach ($item in $list) {
    "----------------------------------------------------------------------------------------------------------------------------------------"
    $enc = Get-Encoding -Path $source/$item
    "Get encoding file information for " + $item + " -> Encoding code : " + $enc.Encoding
    
    if (-not ($enc.Encoding -match "UTF8"))
    {
        "Convert file " + $item.FullPath + " to UTF8"
        ConvertTo-UTF8 -Path $item.FullPath;
        "Encoding : " + (Get-Encoding -Path $item.FullPath).Encoding
    }
}