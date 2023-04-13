# Get unique sequence ID in CCM plis PDF name

$source_path = "P:\EXSTREAM\PRD\Diffusion\Onbase\*.pdf"
$list_pdf = get-childitem -path $source_path 
$list_pdf | foreach-object {
$rc = $_.FullName | Select-String -pattern "p0_(\d{6})_" -AllMatches
    if ($rc) {
     $id = $rc.Matches[0].Groups[1].Value
      $id
   }
} | Select-Object -Unique

    