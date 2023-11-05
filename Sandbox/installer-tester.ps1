
# Registry pathes to get list of installed software.
$HKLM_64b_Uninstaller = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
$HKLM_32b_Uninstaller = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"

# Get installed software for 32 bits 
$reg32 = Get-ItemProperty $HKLM_32b_Uninstaller 

# Get installed software for 64 bits
$reg64 = Get-ItemProperty $HKLM_64b_Uninstaller 

# Build the full apps installed list
$reg = ($reg32 + $reg64) | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, EstimatedSize 

# Display quick stats
"--------------------------------------------------------------------------------------------------------------------"
" Installer tests"
"--------------------------------------------------------------------------------------------------------------------"
"32b apps    : " + ($reg32).Count + " application(s)"
"64b apps    : " + ($reg64).Count + " application(s)"
"Total items : " + ($reg).Count  + " application(s)"
"--------------------------------------------------------------------------------------------------------------------"

# List 10 first biggest apps installed on this machine
# Warning : EstimatedSize is far not a reliable information but it gives a raw idea of the situation
$reg_bySize = $reg | Sort-Object -Property EstimatedSize -Descending | Select-Object InstallDate, DisplayName, DisplayVersion, @{n="Size";e={'{0:N2}' -f ($_.EstimatedSize / 1KB)}} | Select-Object -First 10

# List 10 elder apps on this machine
# Warning : The same way, dates are stored as string and not date object which could bring behavior in the sort
$reg_byDate = $reg | Sort-Object -Property InstallDate -Descending | Select-Object InstallDate, DisplayName, DisplayVersion, @{n="Size";e={'{0:N2}' -f ($_.EstimatedSize / 1KB)}} | Select-Object -First 10

# Easy list filtering for an application name
# Here we avoid the string problem simply using where clause
$reg_filter = $reg | Where-Object {($_.DisplayName -match '^a*')} | Select-Object -First 10 -property DisplayName 

# Test if a particular app is installed
$softName = "7-Zip"
$installer = "./installer_7zip.exe"
$reg | Where-Object {$_.DisplayName -match $softName} | ForEach-Object {
    if ( $_.DisplayName -match $softName ) {
        Write-Host "Software $softName already installed !!!"
        #exit
    } 
}


# Download 7 zip
if (-not (Test-Path -Path $installer)) {
    $uri = "https://www.7-zip.org/a/7z2201-x64.exe"
    Invoke-WebRequest -Uri $uri -OutFile $installer -verbose
    Start-Process $installer /S -NoNewWindow -Wait -PassThru
}

