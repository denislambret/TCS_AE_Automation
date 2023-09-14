#----------------------------------------------------------------------------------------------------------------------------------
# Module  : libEnvRoot.psm1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20230913
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Implement portability environment variables for PWS scripts

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


#----------------------------------------------------------------------------------------------------------------------------------
#                                                   I N C L U D E S 
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                            G L O B A L   V A R I A B L E S
#----------------------------------------------------------------------------------------------------------------------------------
$VERSION = "1.0"
$AUTHOR  = "Denis Lambret"

#----------------------------------------------------------------------------------------------------------------------------------
#                                                  F U N C T I O N S 
#----------------------------------------------------------------------------------------------------------------------------------
$ROOT_PATH = "Y:\03_DEV\06_GITHUB\tcs-1\libs”

#..................................................................................................................................
# Function : Get-RootPath
#..................................................................................................................................
function Get-RootPath {
    if (Test-RootPath) {
        return (Get-ItemProperty -Path 'HKLM:\Software\TCS' -Name 'PWSH_SCRIPT_ROOT' -ErrorAction Ignore).PWSH_SCRIPT_ROOT
    } else {
        $false
    }
}

#..................................................................................................................................
# Function : Test-RootPath
#..................................................................................................................................
Function Test-RootPath {
    if ((Get-Item -Path 'HKLM:\Software\TCS' -ErrorAction Ignore)) {
        if (Get-ItemProperty -Path 'HKLM:\Software\TCS' -Name 'PWSH_SCRIPT_ROOT' -ErrorAction Ignore) {
            $true
        } else {
            $false
        }
    } else {
        $false
    }  
}

#..................................................................................................................................
# Function : Set-RootPath
#..................................................................................................................................
function Set-RootPath {
    if (-not (Get-Item -Path 'HKLM:\Software\TCS' -ErrorAction Ignore)) {
        New-Item -Path 'HKLM:\Software' -Name 'TCS' -Value 'TCS Apps branch'
    } 

    if (-not (Get-ItemProperty -Path 'HKLM:\Software\TCS' -Name 'PWSH_SCRIPT_ROOT' -ErrorAction Ignore)) { 
        New-ItemProperty -Path HKLM:\Software\TCS -Name 'PWSH_SCRIPT_ROOT' -Value $ROOT_PATH | Out-Null
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
            Remove-ItemProperty -Path 'HKLM:\Software\TCS' -Name “PWSH_SCRIPT_ROOT” 
            $true
        } else {
            $false
        }
    } else {
        $false
    }  
 }

#..................................................................................................................................
# Function : Set-EnvRoot
#..................................................................................................................................
function Set-EnvRoot 
{
    
    # Home env
    # $global:ScriptRoot  = "D:\dev\40_PowerShell\tcs"
    # $global:LogRoot     = "D:\dev\40_PowerShell\tcs\log"
    # $global:LibRoot     = "D:\dev\40_PowerShell\tcs\libs"    
    # $global:global_conf = "D:\dev\40_PowerShell\tcs\libs\global.json"   
    
    # TCS Laptop env
    $global:ScriptRoot  = Get-ItemProperty -Path 'HKLM:\Software\TCS' -Name 'PWSH_SCRIPT_ROOT'
    $global:LogRoot     = $global:ScriptRoot + "\logs"
    $global:LibRoot     = $global:ScriptRoot + "\libs"
    $global:TempDir     = $global:ScriptRoot + "\tmp"
    $global:ConfDir     = $global:ScriptRoot + "\conf"
    $global:global_conf = $global:ScriptRoot + "\libs\global.json"   

    if ($Env:PSModulePath -notlike  $LibRoot) { 
        $Env:PSModulePath = $Env:PSModulePath + ";" + $global:LibRoot 
    }
}

#..................................................................................................................................
# Function : Test-EnvRoot
#..................................................................................................................................
function Test-EnvRoot {
    if (Test-RootPath) {
        return $true
    }
    else {
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
                Write-Host " "
                Write-Host "Registry successfully updated !"
                return $true
            } else {
                Write-Host " "
                Write-Error "Something went wrong updating registry. Change not applied !"
                return $false
            }
        }

    }
    
}

#----------------------------------------------------------------------------------------------------------------------------------
#                                                     M A I N
#----------------------------------------------------------------------------------------------------------------------------------
# Test if the system is already setup for running scripts otherwise suggest auto installation
Test-EnvRoot

# Set Environment variables for scripts.
Set-EnvRoot



#----------------------------------------------------------------------------------------------------------------------------------
#                                                E X P O R T E R S
#----------------------------------------------------------------------------------------------------------------------------------
Export-ModuleMember -Function Get-RootPath, Test-RootPath, Remove-RootPath, Test-EnvRoot, Set-EnvRoot

