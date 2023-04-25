$errorCount   = 0
$successCount = 0
$count        = 0
$idx          = 0
$previous     = ""

$list  = gc D:\dev\80_data\fileList.txt

Write-Output "-----------------------------------------------------------------------------------------------"
Write-Output "file name normalizer"
Write-Output "-----------------------------------------------------------------------------------------------"
foreach ($item in $list) {
    $idx   += 1
    $count += 1
    $noclt,$dtype,$desc,$date = $item -split "_"
    

    # indexes controls
    if ((-not $noclt) -or (-not ($noclt -match "^\d{7}$"))) {
        Write-Output "No clt is not correctly formated or does not exist (value : $noclt). Bypass entry!"
        $errorCount += 1
        continue        
    }

    if ((-not $dtype) -or -not ($dtype -match "^[a-zA-Z0-9]{3,4}$")) {
        Write-Output "Dtype is not correctly formated or does not exist (value : $dtype). Bypass entry!"
        $errorCount += 1
        continue        
    }
    
    if ((-not $desc) -or -not ($desc -match "\w{1,32}$")) {
        Write-Output "Desc is not correctly formated or does not exist (value : $desc). Bypass entry!"
        $errorCount += 1
        continue        
    }
    
    # Check and validate date / remove extra info
    $date = $date -replace "\(\d{1,4}\)",""
    $date = $date -replace "\.pdf",""
    $date = $date -replace "\s",""
    if (-not ($date -match "^\d{2}\.\d{2}\.\d{4}")) {
            Write-output "Bypass file : $item - Please check date value $date "
            $errorCount += 1
            continue
    }  
    
    $current = ($noclt,$dtype,$desc,$date) -join "_"
   
    if (-not ($previous -eq $current)) { $idx = 1}
    $idxPadded = ($idx.toString()).PadLeft(3,"0")
    $previous = $current
    
    # Rebuild destination name
    $newItem = ($noclt,$dtype,$desc,$date,$idxPadded) -join "_"
    $newItem = $newItem + ".pdf"
    $successCount +=1
}

Write-Output "-----------------------------------------------------------------------------------------------"
Write-Output "Total items processed   : $count"
Write-Output "File name(s) in success : $successCount"
Write-Output "File name(s) in error   : $errorCount"
Write-Output "-----------------------------------------------------------------------------------------------"
