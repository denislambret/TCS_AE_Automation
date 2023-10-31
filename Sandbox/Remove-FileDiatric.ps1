Param (
    [Parameter(Mandatory=$True)][String]$Path
)

Remove-Module *
Import-Module libEncoding
$content = Get-Content $path
"Remove accents---------------------------------------------------------------------------------------------"
"Lines    : " + $(($content | Measure-Object -Line).Lines) + " items"
"Words    : " + $(($content | Measure-Object -Word).Words) + " items"
"Chars    : " + $(($content | Measure-Object -Character).characters) + " items"

if(Remove-FileDiatric($path)) {
    "All accentuated chars have been replaced in $path"
} else {
    "Error while substituing accentuated chars on $path"
}
"----------------------------------------------------------------------------------------------------------"