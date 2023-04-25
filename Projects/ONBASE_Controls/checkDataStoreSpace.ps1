#--------------------------------------------------------------------------------------------------------------
# Name        : checkDataStoreSpace.ps1
#--------------------------------------------------------------------------------------------------------------
# Author      : D.Lambret
# Date        : 16.11.2021
# Status      : DEV
# Version     : 0.1
#--------------------------------------------------------------------------------------------------------------
# Description :
# Script used to analyse free space used and available on the various Disk Group used by Onbase
#--------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------
# Global Variables
#--------------------------------------------------------------------------------------------------------------
$listDrives = @(
    '\\fs_Appsdata_ge3\Apps_data$\Onbase\DEV\DATA\CCM',
    '\\fs_AppsData_ge3\Apps_data$\ONBASE\DEV\DATA\SCANNING',
    '\\fs_EcmProd_ge3\ecm_prod_01$\ecm_prod_data\SPS',
    '\\fs_Appsdata_ge3\Apps_data$\ONBASE\DEV\DATA\SYSTEM',
    '\\fs_Appsdata_ge3\Apps_data$\Onbase\DEV\DATA\CCM',
    '\\fs_AppsData_ge3\Apps_data$\ONBASE\DEV\DATA\SCANNING',
    '\\fs_EcmProd_ge3\ecm_prod_01$\ecm_prod_data\SPS',
    '\\fs_Appsdata_ge3\Apps_data$\ONBASE\DEV\DATA\SYSTEM',
    '\\fs_Appsdata_ge3\Apps_data$\ONBASE\ACP\DATA\CCM',
    '\\fs_Appsdata_ge3\Apps_data$\ONBASE\ACP\DATA\SCANNING',
    '\\fs_EcmProd_ge3\ecm_prod_01$\ecm_prod_data\SPS',
    '\\fs_Appsdata_ge3\Apps_data$\ONBASE\ACP\DATA\SYSTEM',
    '\\fs_AppsData_ge3\Apps_data$\ONBASE\ACP\DATA\ASSISTA',
    '\\fs_Appsdata_ge3\Apps_data$\Onbase\PRD\DATA\CCM',
    '\\fs_AppsData_ge3\Apps_data$\ONBASE\PRD\DATA\SCANNING',
    '\\fs_EcmProd_ge3\ecm_prod_01$\ecm_prod_data\SPS',
    '\\fs_Appsdata_ge3\Apps_data$\ONBASE\PRD\DATA\SYSTEM'
)

#--------------------------------------------------------------------------------------------------------------
# procedures & functions
#--------------------------------------------------------------------------------------------------------------
function Get-DirectoryStats {
    param( 
            $directory, 
            [switch]$recurse, 
            [switch]$format 
        )
    
        Write-Progress -Activity "checkDataStoreSpace.ps1" -Status "Reading $directory.FullName"
    $files = $directory | Get-ChildItem -Force -Recurse:$recurse | Where-Object { -not $_.PSIsContainer }
    if ( $files ) {
      Write-Progress -Activity "Get-DirStats.ps1" -Status "Calculating ‘$($directory.FullName)'"  
        $output = $files | Measure-Object -Sum -Property Length | Select-Object `
        @{Name="Path"; Expression={$directory.FullName}},
        @{Name="Files"; Expression={$_.Count; $script:totalcount += $_.Count}},
        @{Name="Size"; Expression={$_.Sum; $script:totalbytes += $_.Sum}}
    }
  
    else {
        $output = "" | Select-Object `
        @{Name="Path"; Expression={$directory.FullName}},
        @{Name="Files"; Expression={0}},
        @{Name="Size"; Expression={0}}`
    }
  
    if ( -not $format ) { $output } else { $output | Format-Table }

}

#--------------------------------------------------------------------------------------------------------------
# Main
#--------------------------------------------------------------------------------------------------------------

foreach ($item in $listDrives) {
    Write-host "Exec : Get-DirectoryStats -directory $item -recurse -format"
    Get-DirectoryStats -directory $item -recurse -format
}