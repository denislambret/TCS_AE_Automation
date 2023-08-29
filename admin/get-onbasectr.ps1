$ccm_path = "P:\EXSTREAM\PRD\Diffusion\Onbase\Backup"
$scan_path = "P:\ONBASE\PRD\DIFFUSION\Scanning\SAVE"


write-Host "----------------------------------------------------------------------------------------------------------"
write-Host "Onbase CCM + Scan controls"
write-Host "----------------------------------------------------------------------------------------------------------"
# Count CCM
$lastDir = Get-ChildItem -Path $ccm_path -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1
write-Host "CCM directory : " $lastDir
$countCCMFiles = (gci $lastDir/*.csv).Count
$countCCM = (gci $lastDir/*.csv  | sort $_.LastWriteDate | gc).Count
write-Host "CCM Files     : " $countCCMFiles " file(s)"
write-Host "CCM count     : " $countCCM " record(s)"
# Count Scan
$countScan = (gci $scan_path *.csv | sort $_.LastWriteDate | select -last 1 | gc).Count
write-Host "Scanned docs  : " ($countScan - 1) " record(s)"
write-Host "----------------------------------------------------------------------------------------------------------"