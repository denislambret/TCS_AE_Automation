#..................................................................................................................................
# Function : Copy-SecureFile
#..................................................................................................................................
# Input    : $path, $dest, $recurse
# Output   : false / true
#..................................................................................................................................
# Synopsis
#..................................................................................................................................
# Convert file content into UTF8
#..................................................................................................................................

$global:log_Levels = @{
    "DEBUG"     = 1
    "INFO"      = 2
    "WARNING"   = 3
    "ERROR"     = 4
    "FATAL"     = 5
}

$global:noTranscript = $false

#..................................................................................................................................
# Function : Init-Log
#..................................................................................................................................
# Input    : $path
# Output   : none
#..................................................................................................................................
# Synopsis
#..................................................................................................................................
# Init log system
#..................................................................................................................................
function Start-Log 
{
    param(
        [Parameter(Mandatory=$True)][String] $Path,
        [Parameter(Mandatory=$True)][String] $Script,
        [switch] $noTranscript
    )

    if ($noTranscript) {
        $global:noTranscript = $true
    }

    $global:script_name      = $Script
    $global:log_path         = $Path
    $global:log_name         = ($Script -replace '.ps1','.log')
    $global:log_name         = (Get-Date -format "yyyyMMdd_hhmmss") + "_" + $global:log_name
    $global:log_minLevel     = $global:log_Levels["DEBUG"]
    $global:log_defaultLevel = $global:log_Levels["INFO"]
    
    if (-not $noTranscript)
    {
        Try {
            Start-Transcript -Path $global:log_path\$global:log_name  
        }
        catch {
            "Message: [" + $($_.Exception.Message) + "]" 
            return $false
        }
    }
    return $true
}

#..................................................................................................................................
# Function : End-Log
#..................................................................................................................................
# Input    : $message
# Output   : none
#..................................................................................................................................
# Synopsis
#..................................................................................................................................
# Display formated log message
#..................................................................................................................................
function Stop-Log
{
    $global:noTranscript
    if (-not $global:noTranscript)
    {
        Try {
                Stop-Transcript
            }
            catch {
                "Message: [" + $($_.Exception.Message) + "]" 
                return $false
            }
    }
    return $true
}

#..................................................................................................................................
# Function : log
#..................................................................................................................................
# Input    : $message
# Output   : none
#..................................................................................................................................
# Synopsis
#..................................................................................................................................
# Display formated log message
#..................................................................................................................................
function Log {
[alias("Add-Log")]    
    param(
        [Parameter(Mandatory=$True)][String] $message,
        [Parameter(Mandatory=$False)][String] $level
    )
    
    $usr = [Environment]::UserDomainName + "\" + [Environment]::UserName 
    
    if ((-not $level) -or (-not $global:log_levels.Contains($level))) { 
            $Level = $global:log_defaultLevel
    }
    
    if ($global:log_Levels[$level] -ge $global:log_minLevel) {
        if ($global:noTranscript) {
           Write-host ("[" + (Get-Date -Format "yyyyMMdd HH:mm:ss") + "][" + $global:script_name + "][" + $usr + "][" + $level + "] " + $message)    
        } else {
           ("[" + (Get-Date -Format "yyyyMMdd HH:mm:ss") + "][" + $global:script_name + "][" + $usr + "][" + $level + "] " + $message) | Out-Host
        }
    }
}

#..................................................................................................................................
# Function : Reset-log
#..................................................................................................................................
# Input    : $message
# Output   : none
#..................................................................................................................................
# Synopsis
#..................................................................................................................................
# Reset log file. Erase existing file.
#..................................................................................................................................
function Reset-Log {
    [alias("Add-Log")]    
        param(
            [Parameter(Mandatory=$True)][String] $Path
        )

        try {
            New-Content $Path -Force 
        } 
        catch {
            "Message: [" + $($_.Exception.Message) + "]" | Out-Host
        }
}

#..................................................................................................................................
# Function : Set-MinLogLevel
#..................................................................................................................................
# Input    : $level
# Output   : true/false
#..................................................................................................................................
# Synopsis
#..................................................................................................................................
# Set minnimum log level. Log function use filter on input message to display only msg equal or greater to log level
#..................................................................................................................................
function Set-MinLogLevel {
    param(
        [Parameter(Mandatory=$True)][String] $Level
    )
    if ($global:log_Levels.ContainsKey($Level)) {
        $global:log_minLevel = $log_Levels[$Level]
    }
}

#..................................................................................................................................
# Function : Set-DefaultLogLevel
#..................................................................................................................................
# Input    : $level
# Output   : true/false
#..................................................................................................................................
# Synopsis
#..................................................................................................................................
# Set default log level. If no level given to Log function, then use default
#..................................................................................................................................
function Set-DefaultLogLevel {
    param(
        [Parameter(Mandatory=$True)][String] $Level
    )
    if ($global:log_Levels.ContainsKey($Level)) {
        $global:log_defaultLevel = $log_Levels[$Level]
    }
}

Export-ModuleMember -Function Start-Log, Stop-Log, Reset-Log
Export-ModuleMember -Function Log, Add-Log
Export-ModuleMember -Function Set-MinLogLevel, Set-DefaultLogLevel