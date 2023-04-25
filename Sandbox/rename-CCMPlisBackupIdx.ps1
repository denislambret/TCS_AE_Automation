$source_env_list = ("DEV", "QA", "ACP", "PRD")

"Build directories list..."
"-------------------------------------------------------------------------------------------------------------------------------------------"
foreach ($source_env in $source_env_list) {
    $source_dir = "P:\EXSTREAM\" + $source_env + "\Diffusion\Onbase\Backup"
    if (-not (Test-Path $source_dir)) { "Source directory not found... Abort!"; exit -1}

    $subdir_list = Get-ChildItem -Path $source_dir -Recurse | Where-Object { $_.PSIsContainer -and ($LastWriteDate -le (Get-Date).AddMonths(-1))} 

    foreach ($dir in $subdir_list) {
        $flag_remove = $true
        $rc = $dir | Select-String -pattern "(\d{2})_(\d{2})_(\d{4})_(\d{2})_(\d{2})_(\d{2})" -AllMatches
        if ($rc) {
            "-------------------------------------------------------------------------------------------------------------------------------------------"
            # Extract date information
            $day = $rc.Matches.Groups[2].value
            $month = $rc.Matches.Groups[1].value
            $year = $rc.Matches.Groups[3].value
            $hour = $rc.Matches.Groups[4].value
            $min = $rc.Matches.Groups[5].value
            $sec = $rc.Matches.Groups[6].value
            $timestamp = $year + $month + $day 
            
            # Set destination path
            $dest_dir = "P:\EXSTREAM\" + $source_env + "\Diffusion\Onbase\Backup\Archives\" + $year + "\"
            $dest_zip = $dest_dir + $year + "_" + $month + "_CCMPlis_Backup_Idx.zip"
            
            "Source : " + $dir + " - Computed Timestamp : " + $timestamp 

            if (-not (Test-Path $dest_dir)) {
                try {
                    New-Item -Path $dest_dir -ItemType directory -Force | Out-Null
                }
                catch {
                $flag_remove = $false
                "Error in process - Creating path  " + $dest_dir
                    $error
                }
            }
            
            "Create archive : " + $dest_zip
            try {
                Compress-Archive -Path ($dir.FullName + "\*.*") -DestinationPath $dest_zip -CompressionLevel Optimal -Update
            }
            catch {
                $flag_remove = $false
                "Error in process - Building zip file $dest_zip"
                $error
            }

            if ($flag_remove) {
                "Remove items from " + $dir.Fullname
                Remove-Item -path $dir.FullName -Force -Recurse -ErrorAction Continue
            } else {
                "Error in process - Abort sources cancel operations..."
            }
        }
    }
}