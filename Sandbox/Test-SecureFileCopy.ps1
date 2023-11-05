BEGIN {
        #.............................................................................................................................
        # Update vars depending of environment used
        #  $Env:PSModulePath = $Env:PSModulePath + ";Y:/03_DEV/06_GITHUB/tcs-1/libs"
        #  $log_path = "Y:/03_DEV/06_GITHUB/tcs-1/logs"
           
        # $Env:PSModulePath = $Env:PSModulePath+";G:/dev/20_GitHub/tcs//libs"
        # $log_path = "G:/dev/20_GitHub/tcs/logs"
              
        $Env:PSModulePath = $Env:PSModulePath + ";D:/dev/40_PowerShell/tcs/libs"
        $log_path = "D:/dev/40_PowerShell/tcs/logs"
    
        Import-Module libLog
        if (-not (Start-Log -path $log_path -Script $MyInvocation.MyCommand.Name)) { exit 1 }
        $rc = Set-DefaultLogLevel -Level "INFO"
        $rc = Set-MinLogLevel -Level "INFO"
}

PROCESS {
        Import-Module libSecureFileCopy
        $Source = "D:/dev/40_PowerShell/tcs/data/input/Logs/*.log"
        $Dest = "D:/dev/40_PowerShell/tcs/data/output/logs"
        
        $srcList = Get-ChildItem -Path $Source

        $count = 0
        ForEach ($item in $srcList) {
                $srcName = $item.Fullname
                $destName = $dest + "/" + $item.name

                if (Copy-Files -path $srcName -dest $destName){
                        Log -Level "ERROR" -Message ($_.toString())
                } else {
                        Log -Level "INFO" -Message ("Copied " + $srcName + " -> " + $destName)
                        $Count += 1
                }
        }
        Log -Level "INFO" -Message ("Total file copied : " + $count + " File(s)")
}