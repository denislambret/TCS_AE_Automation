# LibEnvRoot
#---------------------------------------------------------------------------------------------
$ROOT_PATH = "Y:\03_DEV\06_GITHUB\tcs-1\libs”
function Get-RootPath {

}

function exists_RootPath {

}

Function Test-RootPath {
    if ((Get-Item -Path 'HKLM:\Software' -Name 'TCS' -ErrorAction Ignore)) {
        write-host "There"
        if (Get-ItemProperty -Path 'HKLM:\Software\TCS' -Name 'PWSH_SCRIPT_ROOT' -ErrorAction Ignore) {
            $true
        } else {
            $false
        }
    } else {
        $false
    }  
}

function set_RootPath {
    if (-not (Get-ItemProperty -Path 'HKLM:\Software' -Name 'TCS' -ErrorAction Ignore)) {
        New-Item -Path HKLM:\Software -Name TCS -Value “TCS Apps branch”
    }
    New-ItemProperty -Path HKLM:\Software\TCS -Name “PWSH_SCRIPT_ROOT” -Value $ROOT_PATH
}

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
    $global:ScriptRoot  = Get-ItemProperty -Path 'HKLM:\Software\TCS' -Name 'PWSH_SCRIPT_ROOT'
    $global:LogRoot     = $global:ScriptRoot + "\logs"
    $global:LibRoot     = $global:ScriptRoot + "\libs"
    $global:global_conf = $global:ScriptRoot + "\libs\global.json"   

    if ($Env:PSModulePath -notlike  $LibRoot) { 
        $Env:PSModulePath = $Env:PSModulePath + ";" + $global:LibRoot 
    }
}

Set-EnvRoot
Export-ModuleMember -Function Set-EnvRoot