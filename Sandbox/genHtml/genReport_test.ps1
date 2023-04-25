#----------------------------------------------------------------------------------------------------------------------------------
# Script  : script_name
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : author trigram
# Date    : YYYYMMDD
# Version : X.X
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        This script is a generic template to demonstrate how to generate automatically reports using PSP

    .DESCRIPTION
        A longer description.
#>
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                             C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
# No input parameters

#----------------------------------------------------------------------------------------------------------------------------------
#                                                  F U N C T I O N S 
#----------------------------------------------------------------------------------------------------------------------------------
#..................................................................................................................................
# Function : Get-DirectoryStats
#..................................................................................................................................
function Get-DirectoryStats {

    param( 
        $directory, 
        [switch]$recurse
     )
  
     Write-Progress -Activity “Get-DirectoryStats $directory” -Status “Reading ‘$directory'”
      $files = $directory | Get-ChildItem -Force -Recurse:$recurse -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer }
      if ( $files ) {
          Write-Progress -Activity “Get-DirectoryStats $directory” -Status “Calculating ‘$directory'”
          $output = $files | Measure-Object -Sum -Property Length | Select-Object `
          @{Name = ”Path”; Expression = { $directory} },
          @{Name = ”Files”; Expression = { $_.Count; $script:totalcount += $_.Count } },
          @{Name = ”Size”; Expression = { $_.Sum; $script:totalbytes += $_.Sum } }
      }
  
    else {
  
        $output = “” | Select-Object `
          @{Name = ”Path”; Expression = { $directory} },
          @{Name = ”Files”; Expression = { 0 } },
          @{Name = ”Size”; Expression = { 0 } }
      }
      return $output
}

#----------------------------------------------------------------------------------------------------------------------------------
#                                             _______ _______ _____ __   _
#                                             |  |  | |_____|   |   | \  |
#                                             |  |  | |     | __|__ |  \_|
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .DESCRIPTION
        Particularly when the comment must be frequently edited,
        as with the help and documentation for a function or script.
#>

# Define header and footer html fragments to insert in report
$header = Get-Content "./header.frag"
$footer = Get-Content "./footer.frag"

# Load configuration file for this particular report
[xml]$config = Get-Content -path "./conf.xml"

# Process directory space analysis info section
$directory_info = @()
foreach ($item in $config.conf.directories_list.directory) {
    $directory_info_partial = Get-DirectoryStats -directory $item.path -Recurse 

    if ($item.thresholdWarning -match "(\d+)(\w{2})") {
        $value = $Matches[1]
        $unit  = $Matches[2]
        
        switch ( $unit ) {
            "TB" {$units = 1024 * 1024 * 1024 * 1024}
            "GB" {$units = 1024 * 1024 * 1024}
            "MB" {$units = 1024 * 1024}
            "KB" {$units = 1024}
        }
        $item.thresholdWarning = $units * $value
    }
    
    if ($item.thresholdAlert -match "(\d+)(\w{2})") {
        $value = $Matches[1]
        $unit  = $Matches[2]
        
        switch ( $unit ) {
            "TB" {$units = 1024 * 1024 * 1024 * 1024}
            "GB" {$units = 1024 * 1024 * 1024}
            "MB" {$units = 1024 * 1024}
            "KB" {$units = 1024}
        }
        $item.thresholdAlert = $units * $value
    }
    
    if ($directory_info_partial.Size -ge [float]($item.thresholdAlert)) {
        $directory_info_partial | Add-Member -NotePropertyName Status -NotePropertyValue "ALERT"        
    } 
    elseif (($directory_info_partial.Size -lt $item.thresholdAlert) -and ($directory_info_partial.Size -ge $item.thresholdWarning)) {
        $directory_info_partial | Add-Member -NotePropertyName Status -NotePropertyValue "WARNING"
    }
    elseif (($directory_info_partial.Size -lt $item.thresholdWarning)) {
        $directory_info_partial | Add-Member -NotePropertyName Status -NotePropertyValue "OK"
    }

    $directory_info_partial | Add-Member -NotePropertyName thresholdAlert -NotePropertyValue $item.thresholdAlert
    $directory_info_partial | Add-Member -NotePropertyName thresholdWarning -NotePropertyValue $item.thresholdWarning 
    $directory_info += $directory_info_partial
}
$directory_info = $directory_info | Select-Object -property Path, Files, @{Name = "Size GB"; Expression={"{0:n}" -f ($_.Size / (1GB))}}, @{Name = "Threshold Warning GB"; Expression={"{0:n}" -f ($_.thresholdWarning / (1GB))}}, @{Name = "Threshold Error GB"; Expression={"{0:n}" -f ($_.thresholdAlert / (1GB))}}, status | ConvertTo-Html -Fragment -PreContent "<div align='center'><h2>Sapce consumption info</h2>" -PostContent "</div>"

# $directory_info = $directory_info | Select-Object -property Path, Files, @{Name = "Size"; Expression={"{0:n}" -f ($_.Size)}}, thresholdWarning, thresholdAlert, status | ConvertTo-Html -Fragment -PreContent "<div align='center'><h2>Directories info</h2>" -PostContent "</div>"
# $file_list = Get-ChildItem -path *.ps1 | Sort-Object -Property Length | Select-Object -Property Name, Fullname, Length, LastWriteTime
# $file_list = $file_list | ConvertTo-Html -Fragment -PreContent "<div align='center'><h2>File List</h2>" -PostContent "</div>"

# Test if files(s) exist and their age
Write-Progress -Activity “Analyzing files...” -Status “Reading”
$files_list = @()
foreach ($item in $config.conf.files_exist.file) 
{
    "status shouldExist " + $item.shouldExist
    "status shouldExist " + $item.shouldNotExist

    if ($item.shouldExist) {
        if (Test-Path $item.name) { 
            $item | Add-Member -NotePropertyName status -NotePropertyValue "OK"
        } else {
            $item | Add-Member -NotePropertyName status -NotePropertyValue "ALERT"
        }
    } 
    elseif ($item.shouldNotExist) {
        if (-not (Test-Path $item.name)) { 
            $item | Add-Member -NotePropertyName status -NotePropertyValue "OK"
        } else {
            $item | Add-Member -NotePropertyName status -NotePropertyValue "ALERT"
        }
    }
    $files_list += $item
}
$files_list = $files_list | Select-Object Name, Description, shouldExist, shouldNotExist, Status | ConvertTo-Html -PreContent "<div align='center'><h2>Files Control List</h2>" -PostContent "</div>"
# Process services section
Write-Progress -Activity “Analyzing services...” -Status “Reading”
$service_list = @()
foreach ($item in $config.conf.services_list.service) 
{
    $service_list_partial = Get-Service $item.name -ErrorAction SilentlyContinue | Select-Object -Property Name, DisplayName, ServiceType, Status, can* | Sort-object -Property Name, Status -Descending  
    $service_list += $service_list_partial
}
$service_list = $Service_list | Select-Object Name, DisplayName, Status | ConvertTo-Html -PreContent "<div align='center'><h2>Services Control List</h2>" -PostContent "</div>"
$service_list = $service_list -replace '<td>Running</td>','<td class="RunningStatus">Running</td>'
$service_list = $service_list -replace '<td>Stopped</td>','<td class="StopStatus">Stopped</td>'
$service_list = $service_list -replace '<td>False</td>','<td class="boolean_false">False</td>'
$service_list = $service_list -replace '<td>True</td>','<td class="boolean_true">True</td>'

# Build final report
Convertto-html  -CssUri "./styles.css" -Body ($header + $directory_info + $file_list + $files_list + $service_list + $footer) | Out-File "./test_page.html"
