# 1. Initialize
Clear

# 2. Global variables declarations
$ME = whoami
$root = 'D:\dev\40_PowerShell\'
$profile_template = $root + '20_GITHUB\TCS_AE_Automation\Sandbox\profile\profile_template_home.ps1'
$Provider 		= Get-PSProvider FileSystem
$Provider.Home 	= $root
$catalog 		= $root + '\20_GITHUB\TCS_AE_Automation\conf\servers_catalog.xml'

# 3. Set Format enumeration olimit
$FormatEnumerationLimit = 99

# 4. Set some command defaults
$PSDefaultParameterValues = @{
  "*:autosize"       = $true
  'Receive-Job:keep' = $true
  '*:Wrap'           = $true
}

# 5. Set home and modules
$Env:PSModulePath = $Env:PSModulePath+";"
$Provider = Get-PSProvider FileSystem
$Provider.Home = 'D:\Dev'
Set-Location -Path ~

# 6. Add a usefull and general administration functions to shell

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
function prompt {
    $ps = Get-Process -id $pid
    "$($executionContext.SessionState.Path.CurrentLocation)$('>' *  ($nestedPromptLevel + 1))" -f ($ps.PM/1MB), ($ps.ws/1MB), ($ps.vm/1MB), $ps.cpu
}

function stats {
    $ps = Get-Process -id $pid
    "PS PID: $pid PM(M) {0:N2} WS(M) {1:N2} VM(M) {2:N2} CPU(s) {3:N2} `r`n" -f ($ps.PM/1MB), ($ps.ws/1MB), ($ps.vm/1MB), $ps.cpu
}

function Update-Profile {
    if (Test-Path $profile_template) {
        try {
            Copy-Item -path $profile_template -Destination $profile -ErrorAction Continue 
            'Profile updated.'
        }
        catch {
            $Error
            'Error updating profile!'
        }
    }

}

Function Get-HelpDetailed { 
    Get-Help $args[0] -Detailed
} 

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
    
    if (Test-Path $catalog) {
        $srv = $srv.ToUpper()
        [xml]$srvList = Get-Content $catalog
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

    $srv = $srv.ToUpper()
    if (Test-Path $catalog) {
        [xml]$srvList = Get-Content $catalog
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

function Enter-RemoteServerPSSession {
    [CmdletBinding(SupportsShouldProcess=$true)] param(
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$false, 
        Position=1)]         
        [Alias("server","ComputerName")]
        [ValidateNotNullOrEmpty()]
        [string]$srv
    )       

    if (Test-Path $catalog) {
        [xml]$srvList = Get-Content $catalog
        if (($srvList.servers.server.alias -contains $srv) -or ($srvList.servers.server.ComputerName -contains $srv)) {
            $node = $srvList.SelectSingleNode("/servers/server[@alias='$srv']")
            if ($node -eq $null) {
                $node = $srvList.SelectSingleNode("/servers/server[@ComputerName='$srv']")
            }
            if ($node -eq $null) {
                "Server " + $srv + " not found in catalog...."
                return $null
            }

            $cred = Get-ServerCrendentials -ComputerName $node.ComputerName
            $srvDef = Get-ServerDefinition -ComputerName $node.ComputerName 
            "Set remote session on " + $srvDef.ComputerName
            try {
                Enter-PSSession -ComputerName $srvDef.ComputerName -Credential $cred
            }
            catch {
                return $null
            }
        }
    } else {
        "Catalog not found... Please check servers_catalog.xml is in /conf."
        return $null
    }
}

function Edit-File {
    param(
	[Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $false,
            Position = 0
        )]
    [alias('p')] 
    [string]$path
 )
  &'C:\Program Files\Notepad++\notepad++.exe' $path
}

function isAdmin {
    $elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    return $elevated
}

function Set-AsAdministrator {
    Start-Process wt pwsh -Verb runAs
    if (-not (isAdmin)) {

    } else {
        Write-Host -BackgroundColor Red -ForegroundColor White "Elevated to Administrator role !!!"
    }
}

function Start-AdminSession {
    Start-Process -Verb RunAs wt.exe '-w 1 -p "powershell" pwsh' 
}

function Start-StandardSession {
    Start-Process wt.exe '-w 1 -p "powershell" pwsh' 
}

function get-TopProcessMem {
    [CmdletBinding(SupportsShouldProcess=$true)] param(
        [Parameter(Mandatory=$false, 
        ValueFromPipeline=$false, 
        Position=1)]         
        [Alias("l")]
        [ValidateNotNullOrEmpty()]
        [string]$limit
    )
    if (-not $limit) { $limit = 10}
    return (get-process | Sort WS -Descending | Select -First $limit)
}

function Get-TopProcessCPU {
    [CmdletBinding(SupportsShouldProcess=$true)] param(
        [Parameter(Mandatory=$false, 
        ValueFromPipeline=$false, 
        Position=1)]         
        [Alias("l")]
        [ValidateNotNullOrEmpty()]
        [string]$limit
    )
    if (-not $limit) { $limit = 10}
    return (get-process | Sort CPU -Descending | Select -First $limit)
}

function Get-TopFileSize {
    [CmdletBinding(SupportsShouldProcess=$true)] param(
        [Parameter(Mandatory=$false, 
        ValueFromPipeline=$false, 
        Position=1)]         
        [Alias("p")]
        [ValidateNotNullOrEmpty()]
        [string]$path,

        [Parameter(Mandatory=$false, 
        ValueFromPipeline=$false, 
        Position=2)]         
        [Alias("l")]
        [ValidateNotNullOrEmpty()]
        [string]$limit,

        [Parameter(Mandatory=$false, 
        ValueFromPipeline=$false, 
        Position=3)]         
        [Alias("r")]
        [ValidateNotNullOrEmpty()]
        [switch]$recurse
    )
    if (-not $limit) { $limit = 10}
    if ($recurse) {
        $list = Get-ChildItem -Path $path -File -Recurse 
    } else {
        $list = Get-ChildItem -Path $path -File
    }
    $list = $list | Select-Object DirectoryName, Name, Mode, Length, @{Label='Length_MB'; Expression={"{0:N2}" -f [math]::Round(($_.Length/1MB),2)}} , Attributes | Sort-Object Length -Descending  | Select-Object -First $limit
    #$list = $list | Select-Object Name, @{Label='SizeMB'; Expression={"{0:N2}" -f ($_.Length/1MB)}} , DirectoryName,  {Label='Length'; Expression={"{0:N2}" -f $_.Length}} Length | Sort-Object Length -Descending  | Select-Object Name, DirectoryName, SizeMB -First $limit
	return $list
}

function Get-TopFileElder {
    [CmdletBinding(SupportsShouldProcess=$true)] param(
        [Parameter(Mandatory=$false, 
        ValueFromPipeline=$false, 
        Position=1)]         
        [Alias("p")]
        [ValidateNotNullOrEmpty()]
        [string]$path,

        [Parameter(Mandatory=$false, 
        ValueFromPipeline=$false, 
        Position=2)]         
        [Alias("l")]
        [ValidateNotNullOrEmpty()]
        [string]$limit,

        [Parameter(Mandatory=$false, 
        ValueFromPipeline=$false, 
        Position=3)]         
        [Alias("r")]
        [ValidateNotNullOrEmpty()]
        [string]$recurse,

        [Parameter(Mandatory=$false, 
        ValueFromPipeline=$false, 
        Position=3)]         
        [ValidateNotNullOrEmpty()]
        [switch]$period
    )

    if (-not $limit) { $limit = 10}
    if (-not $period) { $limit = 7}
    
    if ($recurse) {
        $list= Get-ChildItem -path $path -File -recurse
    } else {
        $list = Get-ChildItem -Path $path -File 
    }
    
    $list = $list | Where-Object {$_.LastWriteTime -gt (Get-Date).AddDays($period) | Select-Object -First $limit}  
    return $list

}

function Get-LastErrors {
    $bt = systeminfo | select-string "System Boot Time"
    if ($bt -match "\d{1,2}.\d{1,2}.\d{4}") {$bt = [Datetime]::Parse($Matches[0]);}

    $sources = @("Application","System")
     
    Write-Host "Scan WinEvt logs for error and warnings messages since last reboot...."
    Foreach ($source in $sources) {
        $errList = Get-WinEvent -FilterHashTable @{'LogName' = $source; 'StartTime' = $bt} `
        | Select-Object TimeCreated, ID, ProviderName, LevelDisplayName, Message `
        | Where-Object {$_.LevelDisplayName -match "Error"} 
        $errList | Format-Table -AutoSize -Wrap
        
        $warnList = Get-WinEvent -FilterHashTable @{'LogName' = $source; 'StartTime' = $bt} `
        | Select-Object TimeCreated, ID, ProviderName, LevelDisplayName, Message `
        | Where-Object {$_.LevelDisplayName -match "Warning"} 
        $warnList | Format-Table -AutoSize -Wrap
    }
}

Function Get-LargestFilesOnDrive {
Param([String]$ComputerName = $env:COMPUTERNAME,[Char]$Drive = 'C', [Int]$Top = 10)
Get-ChildItem -Path \\$ComputerName\$Drive$ -Recurse | Select-Object Name, @{Label='Length_MB'; Expression={"{0:N0}" -f [math]::Round(($_.Length/1MB))}} , DirectoryName,  Length | Sort-Object Length -Descending  | Select-Object Name, DirectoryName, SizeMB -First $Top | Format-Table -AutoSize -Wrap    
}

Function Get-LargestFilesOnPath {
    Param([String]$Path = '.\', [Int]$Top = 10)
    Get-ChildItem -Path $Path -Recurse | Select-Object Name, @{Label='SizeMB'; Expression={"{0:N0}" -f ($_.Length/1MB)}} , DirectoryName,  Length | Sort-Object Length -Descending  | Select-Object Name, DirectoryName, SizeMB -First $Top | Format-Table -AutoSize -Wrap
}

# 6. Set aliases 
Set-Alias gh        Get-Help
Set-Alias ghd       Get-HelpDetailed
Set-Alias ll        Get-ChildItem 
Set-Alias gcred     Get-ServerCrendentials
Set-Alias gsrv      Get-ServerDefinition
Set-Alias admin     Set-AsAdministrator
Set-Alias topc      Get-TopProcessCPU
Set-Alias topm      Get-TopProcessMem
Set-Alias topfs     Get-TopFileSize
Set-Alias topfe     Get-TopFileElder
Set-Alias n         Edit-File
Set-Alias glfod     Get-LargestFilesOnDrive
Set-Alias glfop     Get-LargestFilesOnPath
Set-Alias gs        Get-Service
Set-Alias upprof    Update-Profile

# 7. Display splash screen
'----------------------------------------------------------------------------------------------------------------------------------------------'
Write-Host "
                            █ ▄▄  ████▄   ▄ ▄   ▄███▄   █▄▄▄▄   ▄▄▄▄▄    ▄  █ ▄███▄   █    █     
                            █   █ █   █  █   █  █▀   ▀  █  ▄▀  █     ▀▄ █   █ █▀   ▀  █    █     
                            █▀▀▀  █   █ █ ▄   █ ██▄▄    █▀▀▌ ▄  ▀▀▀▀▄   ██▀▀█ ██▄▄    █    █     
                            █     ▀████ █  █  █ █▄   ▄▀ █  █  ▀▄▄▄▄▀    █   █ █▄   ▄▀ ███▄ ███▄  
                             █           █ █ █  ▀███▀     █                █  ▀███▀       ▀    ▀ 
                              ▀            ▀ ▀            ▀               ▀                      "
'----------------------------------------------------------------------------------------------------------------------------------------------'
'Profile v 1.0.4'
'----------------------------------------------------------------------------------------------------------------------------------------------'
"Host app  : [$($Host.Name)]"
"Hostname  : $(hostname)"
"profile   : Microsoft.Powershell_profile.ps1"
Write-Host -NoNewline "Logged as : $ME as "
   if (isAdmin) {
       Write-Host -BackgroundColor Red -ForegroundColor White ' ! Administrator ! '
   } else {
       Write-Host -BackgroundColor DarkGreen -ForegroundColor White ' Standard user '
   }
'----------------------------------------------------------------------------------------------------------------------------------------------'
'Setting home to ' + $Provider.Home
'----------------------------------------------------------------------------------------------------------------------------------------------'
