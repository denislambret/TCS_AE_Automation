# CCM PLIS
$root_path = 'C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\admin'
pushd
Set-Location $root_path
.\rename_CCMPlisCSV.ps1 -path P:\ONBASE\DEV\DIFFUSION\SAVE -Filter *.csv
.\rename_CCMPlisCSV.ps1 -path P:\ONBASE\QA\DIFFUSION\SAVE -Filter *.csv
.\rename_CCMPlisCSV.ps1 -path P:\ONBASE\ACP\DIFFUSION\SAVE -Filter *.csv
.\rename_CCMPlisCSV.ps1 -path P:\ONBASE\PRD\DIFFUSION\SAVE -Filter *.csv

# SCanning
.\rename_scannedCSV.ps1 -path P:\ONBASE\DEV\DIFFUSION\Scanning\SAVE -Filter *.csv
.\rename_scannedCSV.ps1 -path P:\ONBASE\QA\DIFFUSION\Scanning\SAVE -Filter *.csv
.\rename_scannedCSV.ps1 -path P:\ONBASE\ACP\DIFFUSION\Scanning\SAVE -Filter *.csv
.\rename_scannedCSV.ps1 -path P:\ONBASE\PRD\DIFFUSION\Scanning\SAVE -Filter *.csv
popd