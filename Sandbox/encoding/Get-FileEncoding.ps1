Param (
    [Parameter(Mandatory=$True)][String]$Path
)

Import-Module libEncoding

"Get Encoding Info -------------------------------------------------------------------------------"
if (Test-Path -Path $path) {
  Get-FileEncoding -Path $path
"-------------------------------------------------------------------------------------------------"
}
