# LibEnvRoot
#---------------------------------------------------------------------------------------------

function Set-EnvRoot 
{
    # Chalet Env
    # $global:ScriptRoot  = "G:\dev\20_GitHub\tcs"
    # $global:LogRoot     = "G:\dev\20_GitHub\tcs\log"
    # $global:LibRoot     = "G:\dev\20_GitHub\tcs\libs"

    # Home env
    # $global:ScriptRoot  = "D:\dev\40_PowerShell\tcs"
    # $global:LogRoot     = "D:\dev\40_PowerShell\tcs\log"
    # $global:LibRoot     = "D:\dev\40_PowerShell\tcs\libs"    
    # $global:global_conf = "D:\dev\40_PowerShell\tcs\libs\global.json"   
    
    # TCS Laptop env
    $global:ScriptRoot  = "Y:\03_DEV\06_GITHUB\tcs-1"
    $global:LogRoot     = "Y:\03_DEV\06_GITHUB\tcs-1\logs"
    $global:LibRoot     = "Y:\03_DEV\06_GITHUB\tcs-1\libs"
    $global:global_conf = "Y:\03_DEV\06_GITHUB\tcs-1\libs\global.json"   

    if ($Env:PSModulePath -notlike  $LibRoot) { 
        $Env:PSModulePath = $Env:PSModulePath + ";" + $global:LibRoot 
    }
}

Set-EnvRoot
Export-ModuleMember -Function Set-EnvRoot