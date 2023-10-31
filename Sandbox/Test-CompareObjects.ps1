$count = 1
$lstSource= @()
$lstSize = 100
$lstSourcePath = "D:\dev\40_PowerShell\10_local\data\input"
$lstSourcePath_a = $lstSourcePath + '\alpha'
$lstSourcePath_b = $lstSourcePath + '\beta'

# Create random files
while ($count -le $lstSize) {
    # Directory switch to alpha or beta dest
    $lstSourcePath = "D:\dev\40_PowerShell\10_local\data\input"
    Push-Location
    Set-Location $lstSourcePath
    $dstSeed = Get-Random -Minimum 0 -Maximum 2
    if ($dstSeed -eq 1) {
        $lstSourcePath = $lstSourcePath + '\alpha'
    } else {
        $lstSourcePath = $lstSourcePath + '\beta'
    }
    #"---------------------------------------------------------------------------------------------------"
    #"Source path : " + $lstSourcePath
    #"Dst Seed    : " + $dstSeed
    # Create test file
    $fileName = $lstSourcePath + '\Dummy_' + $count.toString().padLeft(4,'0') + '.txt'
    #"File        : " + $fileName
    "File        : " + $fileName | Out-File -FilePath $fileName 
    
    # Then update random LastWriteTime
    $delay = -1 * (Get-Random -Minimum 1 -Maximum 10)
    #"Delay       : " + $delay + " day(s)"
    (Get-Item  $fileName).LastWriteTime = ((Get-Item  $fileName).LastWriteTime).addDays($delay)

    #"LastWriteTime delay set back to " + $delay + " day(s) in the past."
    $count++
    Pop-Location
}

# Establish file list for alpha and beta directories
$lstSource_a  = Get-ChildItem -path $lstSourcePath_a -Filter '*.txt'
$lstSource_b  = Get-ChildItem -path $lstSourcePath_b -Filter '*.txt'

# Compute common values betwenn lists
$common = Compare-Object -ReferenceObject $lstSource_a -DifferenceObject $lstSource_b -Property name -ExcludeDifferent

# Whats is proper to A?
$diff_a = Compare-Object -ReferenceObject $lstSource_a -DifferenceObject $lstSource_b -Property name | ?{ $_.SideIndicator -eq '<='}

# Whats is proper to B?
$diff_b = Compare-Object -ReferenceObject $lstSource_a -DifferenceObject $lstSource_b -Property name | ?{ $_.SideIndicator -eq '=>'}

"- A -------------------------------------------------------------"
"Size " + ($diff_a).Count
"Present in A but not in B :"
$diff_a 
"- B -------------------------------------------------------------"
"Size " + ($diff_b).Count
"Present in B but not in A :"
$diff_b

"- Common items --------------------------------------------------"
"Size " + ($common).Count 
"Present in both :"
$common

# Removal of existing dummies
#$lstSource_a | Remove-Item 
#$lstSource_b | Remove-Item 
