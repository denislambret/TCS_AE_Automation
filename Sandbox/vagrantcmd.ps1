
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