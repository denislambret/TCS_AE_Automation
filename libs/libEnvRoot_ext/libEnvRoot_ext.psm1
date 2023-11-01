#----------------------------------------------------------------------------------------------------------------------------------
# Module  : libEnvRoot.psm1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20230913
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Implemnt all vital environm,ents pathes to run scripts.
    
    .DESCRIPTION
        This library intends to load an XML descriptor files with all mandatory path values for :
        - scripts
        - logs
        - data
        - temporary directories
#>
#----------------------------------------------------------------------------------------------------------------------------------



#----------------------------------------------------------------------------------------------------------------------------------
#                                            G L O B A L   V A R I A B L E S
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Global variables
    
    .DESCRIPTION
        Set script's global variables 
#>
$VERSION = "1.0"
$AUTHOR  = "Denis Lambret"

$EnvVar = @{}

# -- Home
$ROOT_PATH = "D:\dev\40_PowerShell\20_GITHUB\TCS_AE_Automation”

# -- Office
#$ROOT_PATH = "D:\dev\40_PowerShell\20_GITHUB\TCS_AE_Automation”


#----------------------------------------------------------------------------------------------------------------------------------
#                                                  F U N C T I O N S 
#----------------------------------------------------------------------------------------------------------------------------------
<#  Implement portability environment variables for PWS scripts

    .DESCRIPTION
        Implement alll basic env variables to run script and ease portability.
        Write a ROOT path in registry, then use it as base path for all other sub dirs
        Implements auto setup, install and uninstall functions to write win registry
        Includes path for :
        - Scripts
        - Logs
        - Temp directory

        Use registry branch : HKLM:\Software\TCS to store values
    #>
#----------------------------------------------------------------------------------------------------------------------------------

#..................................................................................................................................
# Function : Get-RootPath
#..................................................................................................................................
function Get-RootPath {
    if (Test-RootPath) {
        return (Get-ItemProperty -Path 'HKLM:\Software\TCS' -Name 'PWSH_SCRIPT_ROOT' -ErrorAction Ignore).PWSH_SCRIPT_ROOT
    } else {
        return $false
    }
}

#..................................................................................................................................
# Function : Test-RootPath
#..................................................................................................................................
Function Test-RootPath {
    if ((Get-Item -Path 'HKLM:\Software\TCS' -ErrorAction Ignore)) {
        $rc = (Get-ItemProperty -Path 'HKLM:\Software\TCS' -Name 'PWSH_SCRIPT_ROOT' -ErrorAction Ignore)
        if (-not $rc) { 
            return $false
        } 
    } else {
        return $false
    }  
    return $true
}

#..................................................................................................................................
# Function : Set-RootPath
#..................................................................................................................................
function Set-RootPath {
    if (-not (Get-Item -Path 'HKLM:\Software\TCS' -ErrorAction Ignore)) {
        try {
            New-Item -Path 'HKLM:\Software' -Name 'TCS' -Value 'TCS Apps branch'
        }
        catch {
            "Error creating TCS registry branch"
            $_.Exception.Message
            return $false
        }
    } 

    if (-not (Get-ItemProperty -Path 'HKLM:\Software\TCS' -Name 'PWSH_SCRIPT_ROOT' -ErrorAction Ignore)) { 
        try {
            New-ItemProperty -Path HKLM:\Software\TCS -Name 'PWSH_SCRIPT_ROOT' -Value $ROOT_PATH | Out-Null
        } catch {
            "Error creating TCS registry value PWSH_SCRIPT_ROOT"
            $_.Exception.Message
            return $false
        }
    } else  {
        return $false
    }

    return $true
}
 
#..................................................................................................................................
# Function : Remove-RootPath
#..................................................................................................................................
function Remove-RootPath {
    if ((Get-Item -Path 'HKLM:\Software\TCS' -ErrorAction Ignore)) {
        if (Get-ItemProperty -Path 'HKLM:\Software\TCS' -Name 'PWSH_SCRIPT_ROOT' -ErrorAction Ignore) {
            try {
                Remove-ItemProperty -Path 'HKLM:\Software\TCS' -Name “PWSH_SCRIPT_ROOT” 
            } catch {
                return $false
            }
        } else {
            return $false
        }
    } else {
        return $false
    }  
    return $true
 }

 function Remove-EnvRoot {
    if (-not (Remove-RootPath)) {
        return $false
    }
    return $true
 }


#..................................................................................................................................
# Function : Set-EnvRoot
#..................................................................................................................................
function Set-EnvRoot 
{   
    $global:ScriptRoot  = [string](Get-ItemProperty -Path 'HKLM:\Software\TCS' -Name 'PWSH_SCRIPT_ROOT').PWSH_SCRIPT_ROOT
    $global:LogRoot     = [string]$global:ScriptRoot + "\logs"
    $global:LibRoot     = [string]$global:ScriptRoot + "\libs"
    $global:TempDir     = [string]$global:ScriptRoot + "\tmp"
    $global:ConfDir     = [string]$global:ScriptRoot + "\conf"
    $global:global_conf = [string]$global:ScriptRoot + "\libs\global.json"   
    
    try {
        $rootPath = [string](Get-ItemProperty -Path 'HKLM:\Software\TCS' -Name 'PWSH_SCRIPT_ROOT').PWSH_SCRIPT_ROOT
    } catch {
        $_.Exception.Message
        return $false
    }
    
    $EnvVar = @{ 
        'scriptroot' = $rootPath
        'log' = $rootPath + "\log"
        'lib' = $rootPath + "\lib"
        'tmp' = $rootPath + "\tmp"
        'conf' = $rootPath + "\conf"
    }
    
    if ($Env:PSModulePath -notlike  $LibRoot) { 
        $Env:PSModulePath = $Env:PSModulePath + ";" + $global:LibRoot 
    }

    return $EnvVar
}

function Get-EnvRoot 
{
    return $EnvVar
}

#..................................................................................................................................
# Function : Test-EnvRoot
#..................................................................................................................................
function Test-EnvRoot {
    if (-not (Test-RootPath)) {
        Write-Host "---------------------------------------------------------------------------------------------------------------"
        Write-Host "  !!! WARNING !!!"
        Write-Host "---------------------------------------------------------------------------------------------------------------"
        Write-Host "It seems this machine did not has TCS scripts deployed yet. Therefor environement variables for scripts "
        Write-Host "are not yet correctly implemented in reistry. In order to complete installation, we can set registry key" 
        Write-Host "to point to script root path. Would you like to proceed ? (Y/N) "
        Write-Host "---------------------------------------------------------------------------------------------------------------"

        $key = $Host.UI.RawUI.ReadKey()
        if (($key.Character -eq 'y') -or ($key.Character -eq 'Y')) {
            if (Set-RootPath) {
                Write-Host "Registry successfully updated !"
                return $true
            } else {
                Write-Error "Something went wrong updating registry. Change not applied !"
                return $false
            }
        }
    }
    return $true
}

#----------------------------------------------------------------------------------------------------------------------------------
#                                                E X P O R T E R S
#----------------------------------------------------------------------------------------------------------------------------------
Export-ModuleMember -Function Set-RootPath, Get-RootPath, Test-RootPath, Remove-RootPath, Test-EnvRoot, Set-EnvRoot, Get-EnvRoot -Variable EnvVar


