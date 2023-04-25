$SEP = ";"
$source_path = "Y:\03_DEV\06_GITHUB\tcs-1\Sandbox\demo_ASSYS\data"
$target_path = "Y:\03_DEV\06_GITHUB\tcs-1\Sandbox\demo_ASSYS\data"
$source_ref = $source_path + "\List_custref.csv"

$tpl_path = "Y:\03_DEV\06_GITHUB\tcs-1\Sandbox\demo_ASSYS\data\tpl"
$tpl_pdf_sinister = "TPL_COURRIER_ENTRANT.pdf"
$tpl_pdf_incoming_letter = "TPL_COURRIER_SORTANT.pdf"
$tpl_pdf_outgoing_letter = "TPL_DECLARATION_SINISTRE.pdf"

$counter = 1;
$csv = Import-CSV -Path $source_ref -Delimiter ";" 

foreach ($item in $csv) {
    
    $csv_output_file = $source_path + "\" + "index.csv"
    "Customer Reference : " + $item.id
    "------------------------------------------------------------------------------------------------------------"
    "Create directory structure for " + $item.id
    $target_path = $source_path + "\" + $item.id 
    if (($item.id) -and (-not (Test-Path $target_path))) {
        New-Item -path $item.id -ItemType directory -WhatIf
    }
        
    "Generate sinister declaration PDF... " + $target_path + "\" + ($tpl_pdf_sinister -replace ".pdf",$Counter.toString().PadLeft(5,"0") + ".pdf")
    try {
        $in_file =  $tpl_path + "\" + $tpl_pdf_sinister
        $out_file = $target_path + "\" + ($tpl_pdf_sinister -replace ".pdf", ("_" + ($Counter.toString().PadLeft(5,"0") + ".pdf")))
        Copy-Item -path $in_file -Dest $out_file -ErrorAction Continue
    }
    catch {
        "Potential error during copy : " + $error
    }
    
    "Generate incoming letter... " + ($target_path + "\" + ($tpl_pdf_incoming_letter -replace ".pdf",$Counter.toString().PadLeft(5,"0") + ".pdf"))
    try {
        $in_file =  $tpl_path + "\" + $tpl_pdf_sinister
        $out_file = $target_path + "\" + ($tpl_pdf_sinister -replace ".pdf", ("_" + ($Counter.toString().PadLeft(5,"0") + ".pdf")))
        Copy-Item -path $in_file -Dest $out_file -ErrorAction Continue
    }
    catch {
        "Potential error during copy : " + $error
    }
    
    "Generate response letter... " + ($tpl_pdf_outgoing_letter -replace ".pdf",(($Counter.toString()).PadLeft(5,"0") + ".pdf"))
    try {
        $in_file =  $tpl_path + "\" + $tpl_pdf_outgoing_letter
        $out_file = $target_path + "\" + ($tpl_pdf_outgoing_letter -replace ".pdf", ("_" + ($Counter.toString().PadLeft(5,"0") + ".pdf")))
        Copy-Item -path $in_file -Dest $out_file -ErrorAction Continue
    }
    catch {
        "Potential error during copy : " + $error
    }

    "Create index CSV for import as " + $csv_output_file
    $csv_idx_master = $item.id + $SEP + $item.id_sinistre + $SEP + $item.position + $SEP + $item.first_name + $SEP + $item.last_name + $SEP + $item.email
    $csv_idx_sinister_declaration = $csv_idx_master + $SEP + $csv_idx_sinister_declaration + "`r`n"
    $csv_idx_incoming_mail = $csv_idx_master + $SEP + $csv_idx_incoming_mail + "`r`n"
    $csv_idx_response_mail = $csv_idx_master + $SEP + $csv_idx_response_mail + "`r`n"

    if (-not (Test-Path -path ($csv_idx_master + "\" + "index.csv"))) { Set-Content -Path ($source_path + "\" + "index.csv") -Value $null}
    Add-Content -path ($csv_output_file) -Value  $csv_idx_sinister_declaration
    Add-Content -path ($csv_output_file) -Value  $csv_idx_incomming_mail
    Add-Content -path ($csv_output_file) -Value  $csv_idx_outgoing_mail

    $Counter += 1
}

