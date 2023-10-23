$listCSVId = @()
$listPDFId = @()

$source = "P:\EXSTREAM\PRD\Diffusion\Onbase"
$ext_csv = "*.csv"
$ext_pdf = "*.pdf"
$source_csv = $source + '\' + $ext_csv
$source_pdf = $source + '\' + $ext_pdf

# Build CSV list
$listCSVFile = Get-ChildItem -path $source_csv 
Write-Host "CSV List :" ($listCSVFile).Count "record(s) "

$listCSVFile | ForEach-Object {
    $extractCSV = $_.name | select-string  -Pattern "p0_(\d{6})" -AllMatches
    if ($extractCSV) {
        $listCSVId =+ $extractCSV.Matches.Groups[1].Value
    }
}

# Build PDF List
$listPDFFile = Get-ChildItem -path $source_pdf
Write-Host "PDF List :" ($listPDFFile).Count "record(s) "

$listPDFFile | ForEach-Object {
    $extractPDF = $listPDFFile.name | select-string  -Pattern "p0_(\d{6})" -AllMatches
    if ($extractPDF) {
        $listPDFId =+ $extractPDF.Matches.Groups[1].Value
    }
}
$listPDFId = $listPDFId | Select-Object -Unique

Write-Host "---------------------------------------------------------------------------------------------------------------------------------------------------"
Compare-Object -ReferenceObject $listPDFId -DifferenceObject $listCSVId
