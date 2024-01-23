#----------------------------------------------------------------------------------------------------------------------------------
#                                            C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
    # path of the resource to process
    [Parameter(
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 0
        )
    ] 
    [Alias("Path")] $sourceDirectory,
    
    # path for the result generated during process
    [Parameter(
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 1)
    ] 
    [Alias("Destination")] $targetDirectory,
    
    # help switch
    [switch] $help
)

#----------------------------------------------------------------------------------------------------------------------------------
#                                             _______ _______ _____ __   _
#                                             |  |  | |_____|   |   | \  |
#                                             |  |  | |     | __|__ |  \_|
#----------------------------------------------------------------------------------------------------------------------------------
   
# Define the source directory
#$sourceDirectory = "D:\dev\02_LOCAL\Work\data"

# Define the target directory
#$targetDirectory = "D:\dev\02_LOCAL\Work\data"

# Get all files in the source directory
$files = Get-ChildItem -Path $sourceDirectory -File

# Loop through each file
foreach ($file in $files) {
    # Extract the year, month, and day of the file's creation time
    $year = $file.CreationTime.Year
    $month = $file.CreationTime.Month
    
    # Define the new directory path
    $newDirectory = Join-Path -Path $targetDirectory -ChildPath ("{0}\\{1}" -f $year, $month)

    # Check if the new directory exists, if not, create it
    if (!(Test-Path -Path $newDirectory)) {
        New-Item -ItemType Directory -Path $newDirectory
    }

    # Define the new file path
    $newFilePath = Join-Path -Path $newDirectory -ChildPath $file.Name

    # Move the file to the new directory
    Move-Item -Path $file.FullName -Destination $newFilePath
}
