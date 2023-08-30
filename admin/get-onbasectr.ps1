$ccm_path = "P:\EXSTREAM\PRD\Diffusion\Onbase\Backup"
$scan_path = "P:\ONBASE\PRD\DIFFUSION\Scanning\SAVE"


write-Host "----------------------------------------------------------------------------------------------------------"
write-Host "Onbase CCM + Scan controls"
write-Host "----------------------------------------------------------------------------------------------------------"
# Count CCM
$lastDir = Get-ChildItem -Path $ccm_path -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1
write-Host "CCM directory : " $lastDir
$countCCMFiles = (Get-ChildItem $lastDir/*.csv).Count
$countCCM = (Get-ChildItem $lastDir/*.csv  | Sort-Object $_.LastWriteDate | gc).Count
write-Host "CCM Files     : " $countCCMFiles " file(s)"
write-Host "CCM count     : " $countCCM " record(s)"
# Count Scan
$scanFile = Get-ChildItem $scan_path *.csv | Sort-Object $_.LastWriteDate | Select-Object -last 1
$countScan = (Get-ChildItem $scan_path *.csv | Sort-Object $_.LastWriteDate | Select-Object -last 1 | gc).Count
write-Host "Scan index    : " ($countScan - 1) 
write-Host "Scanned docs  : " ($countScan - 1) " record(s)"
write-Host "----------------------------------------------------------------------------------------------------------"