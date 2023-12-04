# 1. Write details
$ME = whoami
Clear
"----------------------------------------------------------------------------------------------------------------------------------------------"
"                                                            @#*********************@                       
                                                             @+-*#################=-@                       
                                                             @+-#%%%%%%%%%%%%%%%%%+-@                       
                                                             @+-#%%%%%%+---%%%%%%%+-@                       
                                                            @@+-#%%%%%%+---%%%%%%%+-%@@                     
                                                         @@#+---#%%+----------=#%%+---+#@@                  
                                                       @%+---++-#%%+-----------*%%+-+=---+%@                
                                                     @%+--=#@@%-+%%%%%%+---%%%%%%%=-%@%#=--=%@              
                                                   @@+--+%@@@@@*-#%%%%%+---%%%%%%+-#@@@@@#=--+@@            
                                                  @%--=#@@@@@@@@+-#%%%%%%%%%%%%%+-*@@@@@@@@#=--#@           
                                                 @*--+@@@@@@@@@@@*-=%%%%%%%%%%#--#@@@@@@@@@@%+--*@          
                                                @+--*@@@@@@@@@@@@@%+-=*%%%%%+--*%@@@@@@@@@@@@@+--+@         
                                               @*--*@%***********%@@@#+-----+%@@@@@@@%*+++*%@@@*--*@        
                                              @%--+@@#-----------%@@@@@+---*@@@@@@@#---------#@@=--#@       
                                              @+--@@@@@@@*---%@@@@@@@@@+---+@@@@@@%---=@@@#---%@%--+@       
                                             @#=-*@@@@@@@*---%@@@@@@@@@=---+@@@@@@*---#@@@@@@@@@@+-=#@      
                                             @*--%@@@@@@@*---%@@@@@@@%+-----+%@@@@#---*@@@%+==%@@#--*@      
                                             @*--%@@@@@@@*---%@@@@@@#=-------=%@@@@+---+#*---+%@@%--+@      
                                             @*--%@@@@@@@*---%@@@@@@*---------#@@@@@#-------*%@@@%--+@      
                                             @*--%@@@@@@@@@@@@@@@%=-------------+%@@@@@@@@@@@@@@@#--*@      
                                             @#=-*@@@@@@@@@@@@#=------=----=-------=%@@@@@@@@@@@@+-=#@      
                                              @+--@@@@@@@@%*------=*%@@@@@@@@@%+------=#%@@@@@@@%--=@       
                                              @#--*@@@@%*------+#@@@@@@@%%%%%@@@@@*=-----=*%@@@@+--#@       
                                               @+--#%*-----=*@@@@@@@@#=-------*@@@@@@%+------*%*--+@        
                                                @+------+%@@@@@@@@@@%=--+%%#==+%@@@@@@@@@#=------=@         
                                                 @+--+%@@@@@@@@@@@@@@*------=*%@@@@@@@@@@@@@%=--+@          
                                                  @#--=%@@@@@@@@@@@@@@@%*+=----#@@@@@@@@@@@#=--*@           
                                                   @%=--+%@@@@@@@@@@#---*@@%---*@@@@@@@@@%+--=%@            
                                                     @#=--+%@@@@@@@@@*=-------+%@@@@@@@#+--=#@              
                                                       @#+---*%%@@@@@@@%####%@@@@@@%#+---=#@@               
                                                         @@*=---=+*#%%@@@@@@@%%#*+----=*%@                  
                                                            @@#*+=---------------==*#@@                     
                                                                @@@%#**+++++**#%@@@               "   
 "----------------------------------------------------------------------------------------------------------------------------------------------"
 "Host app  : [$($Host.Name)]"
 "Hostname  : $(hostname)"
 "profile   : Microsoft.Powershell_profile.ps1"
 "Logged as : $ME"
 "----------------------------------------------------------------------------------------------------------------------------------------------"
 "Profile v 1.0.2 - 14.11.2023"
 "----------------------------------------------------------------------------------------------------------------------------------------------"

# 2. Global variables declarations
$ME = whoami

# 3. Set Format enumeration olimit
$FormatEnumerationLimit = 99

# 4. Set some command defaults
$PSDefaultParameterValues = @{
  "*:autosize"       = $true
  'Receive-Job:keep' = $true
  '*:Wrap'           = $true
}

# 5. Set home and modules
$Env:PSModulePath = $Env:PSModulePath+";C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\libs"
$Provider = Get-PSProvider FileSystem
$Provider.Home = 'C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE'
Set-Location -Path ~
'Setting home to ' + $Provider.Home
"----------------------------------------------------------------------------------------------------------------------------------------------"

# 6. Add a new functions

# Useful shortcuts for traversing directories
function cd...  { cd ..\.. }
function cd.... { cd ..\..\.. }

# Compute file hashes - useful for checking successful downloads 
function md5    { Get-FileHash -Algorithm MD5 $args }
function sha1   { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }

# Quick shortcut to start notepad
function n      { &"C:\Program Files\Notepad++\notepad++.exe" $args }

# Drive shortcuts
function HKLM:  { Set-Location HKLM: }
function HKCU:  { Set-Location HKCU: }
function Env:   { Set-Location Env: }

# Customize prompt with resource wather on prompt
function prompt
{
 $ps = Get-Process -id $pid
 "$($executionContext.SessionState.Path.CurrentLocation)$('>' *  ($nestedPromptLevel + 1))" -f ($ps.PM/1MB), ($ps.ws/1MB), ($ps.vm/1MB), $ps.cpu
}

function stats
{
 $ps = Get-Process -id $pid
 "PS PID: $pid PM(M) {0:N2} WS(M) {1:N2} VM(M) {2:N2} CPU(s) {3:N2} `r`n" -f ($ps.PM/1MB), ($ps.ws/1MB), ($ps.vm/1MB), $ps.cpu
}

# Get detailed help on a command
Function Get-HelpDetailed { 
    Get-Help $args[0] -Detailed
} # END Get-HelpDetailed Function

Function Clear-CCMCache {
<#
    .SYNOPSIS
        Clear CCM Cache folders for Configuration manager security updates
     
    .NOTES
        Name: Clear-CCMCache
        Author: DLA
        Version: 1.0
        DateCreated: 2022-06-20
      
    .EXAMPLE
        Clear-CCMCache
    #>
     
    "Clearing CCM Cache folders ..."
    [__comobject]$CCMComObject = New-Object -ComObject 'UIResource.UIResourceMgr'
    $CacheInfo = $CCMComObject.GetCacheInfo().GetCacheElements()
    ForEach ($CacheItem in $CacheInfo) {
        $null = $CCMComObject.GetCacheInfo().DeleteCacheElement([string]$($CacheItem.CacheElementID))
    }
}

Function Get-EmptyDirectory {
    <#
    .SYNOPSIS
        Get empty directories using underlying Get-ChildItem cmdlet
     
    .NOTES
        Name: Get-EmptyDirectory
        Author: theSysadminChannel
        Version: 1.0
        DateCreated: 2021-Oct-2
      
    .LINK
         https://thesysadminchannel.com/find-empty-folders-powershell/ -
      
    .EXAMPLE
        Get-EmptyDirectory -Path \\Server\Share\Folder -Depth 2 
    #>
     
        [CmdletBinding()]
     
        param(
            [Parameter(
                Mandatory = $true,
                Position = 0
            )]
            [string]    $Path,
     
            [Parameter(
                Mandatory = $false,
                Position = 1
            )]
            [switch]    $Recurse,
     
            [Parameter(
                Mandatory = $false,
                Position = 2
            )]
            [ValidateRange(1,15)]
            [int]    $Depth
        )
     
        BEGIN {}
     
        PROCESS {
            try {
                $ItemParams = @{
                    Path      = $Path
                    Directory = $true
                }
                if ($PSBoundParameters.ContainsKey('Recurse')) {
                    $ItemParams.Add('Recurse',$true)
                }
     
                if ($PSBoundParameters.ContainsKey('Depth')) {
                    $ItemParams.Add('Depth',$Depth)
                }
                $FolderList = Get-ChildItem @ItemParams | select -ExpandProperty FullName
     
                foreach ($Folder in $FolderList) {
                    if (-not (Get-ChildItem -Path $Folder)) {
                        [PSCustomObject]@{
                            EmptyDirectory = $true
                            Path           = $Folder
                        }
                    } else {
                        [PSCustomObject]@{
                            EmptyDirectory = $false
                            Path           = $Folder
                        }
                    }
                }
            } catch {
                Write-Error $_.Exception.Message
            }
        }
     
        END {}
    }

Function List-ProfileFunctions {
	Get-ChildItem function: | ?{ $_.Name -notmatch ".`:"}
}

Function Clear-ElderThan2Weeks {
    <#
    .SYNOPSIS
        Clear files stored on a particular path with a given filter
     
    .NOTES
        Name: Get-ElderThan2Weeks
        Author: DLA
        Version: 1.0
        DateCreated: 2023-06-20
      
    .LINK

      
    .EXAMPLE
        Clear-ElderThan2Weeks -path xxxxxxxxxxx -Filter *.log
    #>
	[CmdletBinding()]
        param(
            [Parameter(Mandatory = $true,Position = 0)][string]    $Path,
			[Parameter(Mandatory = $true,Position = 1)][string]    $Filter
        )
		
	if (-not (Test-Path $path)) {
		"Error : Directory " + $path +" not found"
		return -1
	}
	
	if (-not $Filter) {
		"Error : No filter pattern defined!"
		return -1
	}
	
	$listCandidates = Get-ChildItem -Path $path -recurse | Where-Object { $_.LastWrtieTime -le (Get-Date).AddDays(-15) } 
	"File(s) electible for removal : " + ($listCandidates).Count
	$listCandidates | Remove-Item
}

function Get-ServerCrendentials {
    [CmdletBinding(SupportsShouldProcess=$true)] param(
        [Parameter(Mandatory=$false, 
        ValueFromPipeline=$false, 
        Position=2)]         
        [Alias("usr")]
        [ValidateNotNullOrEmpty()]
        [string]$user,

        [Parameter(Mandatory=$false, 
        ValueFromPipeline=$false, 
        Position=3)]         
        [Alias("password")]
        [ValidateNotNullOrEmpty()]
        [string]$plainTextPwd,

        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$false, 
        Position=1)]         
        [Alias("server","ComputerName")]
        [ValidateNotNullOrEmpty()]
        [string]$srv
    )
    
    $catalog = "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\conf\servers_catalog.xml"
    if (Test-Path $catalog) {
        [xml]$srvList = Get-Content "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\conf\servers_catalog.xml"
        if (($srvList.servers.server.alias -contains $srv) -or ($srvList.servers.server.ComputerName -contains $srv)) {
            $node = $srvList.SelectSingleNode("/servers/server[@alias='$srv']")
            if ($node -eq $null) {
                $node = $srvList.SelectSingleNode("/servers/server[@ComputerName='$srv']")
            }

            # Create credentials for remote connection
            [securestring]$securePassword = ConvertTo-SecureString -String $node.pwd -AsPlainText -Force
            [pscredential]$cred = New-Object System.Management.Automation.PSCredential($node.user, $securePassword) 
            return $cred
        }
    } else {
        "Catalog not found... Please check servers_catalog.xml is in /conf."
    }
    
    return $null
}


function Get-ServerDefinition {
    [CmdletBinding(SupportsShouldProcess=$true)] param(
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$false, 
        Position=1)]         
        [Alias("server","ComputerName")]
        [ValidateNotNullOrEmpty()]
        [string]$srv
    )

    
    $catalog = "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\conf\servers_catalog.xml"
    if (Test-Path $catalog) {
        [xml]$srvList = Get-Content "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\conf\servers_catalog.xml"
        if (($srvList.servers.server.alias -contains $srv) -or ($srvList.servers.server.ComputerName -contains $srv)) {
            $node = $srvList.SelectSingleNode("/servers/server[@alias='$srv']")
            if ($node -eq $null) {
                $node = $srvList.SelectSingleNode("/servers/server[@ComputerName='$srv']")
            }
            return $node
        }
        "Server not found"
        return $null
    } else {
        "Catalog not found... Please check servers_catalog.xml is in /conf."
        return $null
    }
}


# 7. Set aliases 
Set-Alias gh    Get-Help
Set-Alias ghd   Get-HelpDetailed
Set-Alias ll    Get-ChildItem 
Set-Alias gcred Get-ServerCrendentials
Set-Alias gsrv  Get-ServerDefinition
