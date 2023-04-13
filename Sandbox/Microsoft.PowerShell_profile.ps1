# 1. Write details
Write-Host "------------------------------------------------------------------------------------------------------------------------------------"
Write-Host " 
 ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄         ▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄         ▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄            ▄           
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░▌          ▐░▌          
▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░▌       ▐░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░▌       ▐░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░▌          ▐░▌          
▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░▌          ▐░▌       ▐░▌▐░▌          ▐░▌       ▐░▌▐░▌          ▐░▌          ▐░▌          
▐░█▄▄▄▄▄▄▄█░▌▐░▌       ▐░▌▐░▌   ▄   ▐░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░▌          ▐░▌          
▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░▌  ▐░▌  ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌          ▐░▌          
▐░█▀▀▀▀▀▀▀▀▀ ▐░▌       ▐░▌▐░▌ ▐░▌░▌ ▐░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀█░█▀▀  ▀▀▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░▌          ▐░▌          
▐░▌          ▐░▌       ▐░▌▐░▌▐░▌ ▐░▌▐░▌▐░▌          ▐░▌     ▐░▌            ▐░▌▐░▌       ▐░▌▐░▌          ▐░▌          ▐░▌          
▐░▌          ▐░█▄▄▄▄▄▄▄█░▌▐░▌░▌   ▐░▐░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░▌      ▐░▌  ▄▄▄▄▄▄▄▄▄█░▌▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄▄▄ 
▐░▌          ▐░░░░░░░░░░░▌▐░░▌     ▐░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
 ▀            ▀▀▀▀▀▀▀▀▀▀▀  ▀▀       ▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  "
Write-Host "------------------------------------------------------------------------------------------------------------------------------------"
Write-Host "Host app  : [$($Host.Name)]"
Write-Host "Hostname  : $(hostname)"
$ME = whoami
Write-Host "Logged as : $ME"
Write-Host "------------------------------------------------------------------------------------------------------------------------------------"

# 3. Set Format enumeration olimit
$FormatEnumerationLimit = 99

# 4. Set some command defaults
$PSDefaultParameterValues = @{
  "*:autosize"       = $true
  'Receive-Job:keep' = $true
  '*:Wrap'           = $true
}

# 5. Set home 
$Provider = Get-PSProvider FileSystem
$Provider.Home = 'D:\dev\40_PowerShell\'
Set-Location -Path ~
Write-Host 'Setting home to ' $Provider.Home

# 6. Add a new functions
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
                            EmtpyDirectory = $true
                            Path           = $Folder
                        }
                    } else {
                        [PSCustomObject]@{
                            EmtpyDirectory = $false
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
    
Function Get-HelpDetailed { 
    Get-Help $args[0] -Detailed
} # END Get-HelpDetailed Function

Function vagrantcmd {
        param(
        [Parameter(Mandatory=$true)][string]$action
    )

    # List holding all VM to manage
    $vm_path = @(
        'D:\dev\70_Vbox\Vagrant\ansible',
        'D:\dev\70_Vbox\Vagrant\dev',
        'D:\dev\70_Vbox\Vagrant\db',
        'D:\dev\70_Vbox\Vagrant\dummy'
    )


    # Save current location
    Push-Location

    foreach ($item in $vm_path) {
        Set-Location $item
        
        if ($action -eq 'start') {
            $action = 'up'
        } 
        elseif ($action -eq 'stop') {
            $action = 'halt'
        }
        elseif ($action -eq 'status') {
            Write-Host "Get vagrant VMs status..."
            &vagrant global-status --prune  | Select-String -Pattern 'virtualbox'
            Pop-Location
            exit
        }

        elseif ($action -eq 'restart') {
            $action = 'reload'
        }
        
        Write-Host "Run action '$action' on $item environment path. "
        # Run Vagrant command
        &vagrant $action
    }

    # Restore initial locaiton
    Pop-Location
}

# 7. Set aliases 
Set-Alias gh    Get-Help
Set-Alias ghd   Get-HelpDetailed
Set-Alias ll    Get-ChildItem 
