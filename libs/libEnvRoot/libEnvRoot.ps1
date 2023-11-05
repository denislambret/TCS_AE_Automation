#----------------------------------------------------------------------------------------------------------------------------------
# Module  : libEnvRoot
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20230911
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
$SEP_L1  = '----------------------------------------------------------------------------------------------------------------------'
$SEP_L2  = '......................................................................................................................'
$EXIT_OK = 0
$EXIT_KO = 1

#----------------------------------------------------------------------------------------------------------------------------------
#                                                  F U N C T I O N S 
#----------------------------------------------------------------------------------------------------------------------------------

function Set-EnvRoot 
{   
    if (-not (Test-Path ".\libEnvRoot.xml")) {
        Write-Host 'Root configuration file .\libEnvRoot.xml not found !'
        exit 1
    }
    [xml]$conf = Get-Content -path ".\libEnvRoot.xml"
    $global:ScriptRoot  = $conf.pathes.root
    $global:LogRoot     = $conf.pathes.log.path
    $global:TmpRoot     = $conf.pathes.tmp.path
    $global:LibRoot     = $conf.pathes.lib.path
    $global:DataRoot    = $conf.pathes.data.path
    $global:global_conf = "D:\dev\40_PowerShell\20_GITHUB\TCS_AE_Automationl\tcs\libs\global.json"   
    

    # Chalet Env

    # $global:ScriptRoot  = "G:\dev\20_GitHub\tcs"
    # $global:LogRoot     = "G:\dev\20_GitHub\tcs\log"
    # $global:LibRoot     = "G:\dev\20_GitHub\tcs\libs"

    # Home env
    #$global:ScriptRoot  = "D:\dev\40_PowerShell\20_GITHUB\TCS_AE_Automationl\tcs"
    #$global:LogRoot     = "D:\dev\40_PowerShell\20_GITHUB\TCS_AE_Automationl\tcs\log"
    #$global:LibRoot     = "D:\dev\40_PowerShell\20_GITHUB\TCS_AE_Automationl\tcs\libs"    
    #$global:global_conf = "D:\dev\40_PowerShell\20_GITHUB\TCS_AE_Automationl\tcs\libs\global.json"   
    
    # TCS Laptop env
    #$global:ScriptRoot  = "Y:\03_DEV\06_GITHUB\tcs-1"
    #$global:LogRoot     = "Y:\03_DEV\06_GITHUB\tcs-1\logs"
    #$global:LibRoot     = "Y:\03_DEV\06_GITHUB\tcs-1\libs"
    #$global:global_conf = "Y:\03_DEV\06_GITHUB\tcs-1\libs\global.json"   

    if ($Env:PSModulePath -notlike  $LibRoot) { 
        $Env:PSModulePath = $Env:PSModulePath + ";" + $global:LibRoot 
    }
}


#----------------------------------------------------------------------------------------------------------------------------------
#                                                     M A I N
#----------------------------------------------------------------------------------------------------------------------------------

Set-EnvRoot

#----------------------------------------------------------------------------------------------------------------------------------
#                                                E X P O R T E R S
#----------------------------------------------------------------------------------------------------------------------------------
#Export-ModuleMember -Function Set-EnvRoot