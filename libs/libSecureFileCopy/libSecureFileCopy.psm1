class objFileCopyInfo {
    [string]$source           = ""
    [string]$dest             = ""
    [string]$sourceHash       = ""
    [string]$destHash         = ""
    [int]$size                = 0
    [float]$timeCopy          = 0
    [DateTime]$startCopyDate  = 0
    [DateTime]$endCopyDate    = 0   
}

class objListFiles {
    [int]$count     = 0
    [int]$size      = 0
    [System.Collections.ArrayList]$fileList
}

#..................................................................................................................................
# Function : Copy-Files
#..................................................................................................................................
# Input    : $path, $dest, $recurse
# Output   : false / true
#..................................................................................................................................
# Synopsis
#..................................................................................................................................
# Safe copy in two time of a source file
#..................................................................................................................................
function SafeCopy-Files
{
    # Input parameter function
    Param (
        [Parameter(Mandatory=$True)][String]$Path,
        [Parameter(Mandatory=$True)][String]$Dest,
        [Parameter(Mandatory=$False)][String]$waitExt,
        [Parameter(Mandatory=$False)][Switch]$Recurse
    )
    
    $fileList = @()

    # Define which temporary file extension to use
    if (-not $waitExt) {
        $waitExt = ".cpy"
    }

    if ($Recurse) {
        $fileList = Get-ChildItem -Path $Path -Recurse
    } else {
        $fileList = Get-ChildItem -Path $Path 
    }

    $dest_path = Split-Path $dest
    
    if (-not (Test-Path $dest_path)) {
        Log -Level "DEBUG" -Message ("Create directory $dest_path")
        New-Item $dest_path -ItemType Directory
    }
    
    foreach ($item in $fileList) {
        $dest = $dest_path + "/" + $item.name + $waitExt
        
        # Get file hash
        #$sourceHash = Get-FileHash -path $item.fullname -Algorithm SHA256
        Log -Level "DEBUG" -Message ("GET - Source hash -  "+ $sourceHash.hash )
        
        Try {
            log -Level "DEBUG" -Message ("COPY - $item to $dest" ) | Out-Host    
            Copy-Item -Path $item -Destination $dest -ErrorAction Continue
            }
            Catch  {    
                Log -Level "ERROR" -Message ($_.Exception.Message)
                return ($_.Exception.Message)
            }
           
        Try {
               $dest_noext =  ($dest -replace $waitExt,"")
               if (Test-Path $dest_noext) {Remove-Item -Path $dest_noext -Force }
               Rename-Item -Path $dest -NewName $dest_noext -ErrorAction Continue 
            }
            Catch  {
                Log -Level "ERROR" -Message ($_.Exception.Message)   
                return ($_.Exception.Message)
            }  
        
            $destHash = Get-FileHash -path $dest_noext -Algorithm SHA256
            Log -Level "DEBUG" -Message ("GET - Destination hash - " + $destHash.hash )
            # if (-not ($sourceHash.hash -match $destHash.hash)) {
            if (-not (Compare-Files -source $item.fullname -dest $dest_noext)) {
                Log -Level "ERROR" -Message ("Integrity check failed : " + $sourceHash.hash + " <> " + $destHash.hash )
                return ($_.Exception.Message)
            }
    }
    return  $null
}

#..................................................................................................................................
# Function : Copy-Files2
#..................................................................................................................................
# Input    : $path, $dest, $recurse
# Output   : false / true
#..................................................................................................................................
# Synopsis
#..................................................................................................................................
# Convert file content into UTF8
#..................................................................................................................................
function Copy-Files2
{
    Param (
        [Parameter(Mandatory=$True)][String]$Path,
        [Parameter(Mandatory=$True)][String]$Dest,
        [Parameter(Mandatory=$False)][String]$waitExt,
        [Parameter(Mandatory=$False)][Switch]$Recurse
    )
    
    $fileList = New-Object -TypeName objListFile

    if (-not $waitExt) {
        $waitExt = ".cpy"
    }

    if ($Recurse) {
        $fileList = Get-ChildItem -Path $Path -Recurse
    } else {
        $fileList = Get-ChildItem -Path $Path 
    }

    $dest_path = Split-Path $dest
    
    if (-not (Test-Path $dest_path)) {
        Log -Level "DEBUG" -Message ("Create directory $dest_path")
        New-Item $dest_path -ItemType Directory

    }
    
    foreach ($item in $fileList) {
        $dest = $dest_path + "/" + $item.name + $waitExt
        $fileCopyInfo = New-Object -TypeName objFileCopyInfo
        $fileCopyInfo.source        = $item.FullName
        $fileCopyInfo.Dest          =  $dest
        $fileCopyInfo.sourceHash    = Get-FileHash -path $source -Algorithm SHA256
        
        Log -Level "DEBUG" -Message ("GET - Source hash -  "+ $sourceHash.hash )
        
        Try {
                log -Level "DEBUG" -Message ("COPY - $item to $dest" ) | Out-Host    
                $fileCopyInfo.$startCopyDate = (Get-Date -format "yyyyMMdd_hhmmss_fff")
                Copy-Item -Path $item -Destination $dest -ErrorAction Continue
            }
            Catch  {    
                Log -Level "ERROR" -Message ($_.Exception.Message)
                return ($_.Exception.Message)
            }
        
            
        Try {
               $dest_noext =  ($dest -replace $waitExt,"")
               if (Test-Path $dest_noext) {Remove-Item -Path $dest_noext -Force }
               Rename-Item -Path $dest -NewName $dest_noext -ErrorAction Continue 
            }
            Catch  {
                Log -Level "ERROR" -Message ($_.Exception.Message)   
                return ($_.Exception.Message)
            }  
        
            $fileCopyInfo.$endCopyDate = (Get-Date -format "yyyyMMdd_hhmmss_fff")
            $destHash = Get-FileHash -path $dest_noext -Algorithm SHA256
            $fileCopyInfo.destHash =  $destHash
            Log -Level "DEBUG" -Message ("GET - Destination hash - " + $destHash.hash )
            
            $fileCopyInfo.destHash =  $destHash
            $rc = Compare-Files -source $item.fullname -dest $dest_noext
            if (-not ($rc)) {
                Log -Level "ERROR" -Message ("Integrity check failed : " + $sourceHash.hash + " <> " + $destHash.hash )
                return ("Integrity check failed")
            }
            $fileList.fileList.add($fileCopyInfo)
    }
    return  $fileList
}

#..................................................................................................................................
# Function : Compare-Files
#..................................................................................................................................
# Input    : $source, $dest, $recurse
# Output   : false / true
#..................................................................................................................................
# Synopsis
#..................................................................................................................................
# Compare SHA-256 fingerprints - return true if equal
#..................................................................................................................................
function Compare-Files
{
    Param (
        [Parameter(Mandatory=$True)][String]$source,
        [Parameter(Mandatory=$True)][String]$dest
    )

    $sourceHash = Get-FileHash -path $source -Algorithm SHA256
    $destHash   = Get-FileHash -path $dest   -Algorithm SHA256
    
    if (-not ($sourceHash.hash -match $destHash.hash)) {
        return $False
    }
    return $True
}


Export-ModuleMember -Function SafeCopy-Files, Compare-Files