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
    [Alias("iter")] $numberOfFiles,
    
    # path for the result generated during process
    [Parameter(
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 1)
    ] 
    [Alias("Destination")] $directoryPath,
    
    # Time shift for generation
    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $true,
        Position = 1)
    ] 
    [Alias("shift","delay")] $timeShift = 3,
    
    # help switch
    [switch] $help
)

#..................................................................................................................................
# Function : helper
#..................................................................................................................................
# Display help message and exit gently script with EXIT_OK
#..................................................................................................................................
function Set-RandomFiles {
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string] $directoryPath,

        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [int] $numberOfFiles,

        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [int] $timeShift 
    )
   

    # Check if the directory exists, if not, create it
    if (!(Test-Path -Path $directoryPath)) {
        New-Item -ItemType directory -Path $directoryPath
    }

    # Loop to create files
    for ($i=1; $i -le $numberOfFiles; $i++) {
        # Generate a random date
        $randomDate = Get-Random -Minimum (Get-Date).AddYears($timeShift).Ticks -Maximum (Get-Date).Ticks | %{[datetime]$_}

        # Define the file path
        $filePath = Join-Path -Path $directoryPath -ChildPath ("File{0}.txt" -f $i)

        # Create the file
        try {
            New-Item -ItemType File -Path $filePath -Force
        }
        catch {
            <#Do this if a terminating exception happens#>
            $Error
            $StackTrace
            return $false
        }
        

        # Change the creation time to the random date
        try {
            (Get-Item -Path $filePath).CreationTime = $randomDate
        }
        catch {
            $Error
            $StackTrace
            return $false
        }     
    }
    return $true
}


#----------------------------------------------------------------------------------------------------------------------------------
#                                             _______ _______ _____ __   _
#                                             |  |  | |_____|   |   | \  |
#                                             |  |  | |     | __|__ |  \_|
#----------------------------------------------------------------------------------------------------------------------------------
 # Define the number of files
 #$numberOfFiles = 1000
 #$timeShift = 3;

 # Define the directory to store the files
 #$directoryPath = "D:\dev\01_GITHUB\TCS_AE_Automation\data\input"
 Set-RandomFiles -directoryPath $directoryPath -numberOfFiles $numberOfFiles -timeShift -3

