#-----------------------------------------------------------------------------------------------------------------------
# Set-EnvironmentVariables
#-----------------------------------------------------------------------------------------------------------------------
# Setup necessary environment variables to run powershell scripts in a simple reusable way
# Prevent hardcoding of variable in script.
#-----------------------------------------------------------------------------------------------------------------------
$ROOT_PATH = Read-Host "Please enter root path for PowerShell scripts" 

"Setup common Powershell scripts environment variables...."
[System.Environment]::SetEnvironmentVariable("PWSH_SCRIPTS_ROOT",$ROOT_PATH,[System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("PWSH_SCRIPTS_LIBS",$ROOT_PATH+"\libs",[System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("PWSH_SCRIPTS_CONF",$ROOT_PATH+"\conf",[System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("PWSH_SCRIPTS_BIN",$ROOT_PATH+"\tools",[System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("PWSH_SCRIPTS_LOGS",$ROOT_PATH+"\logs",[System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("PWSH_SCRIPTS_TMP",$ROOT_PATH+"\tmp",[System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("PSModulePath",$Env:PSModulePath + ";" + $PWSH_SCRIPTS_LIBS,[System.EnvironmentVariableTarget]::Machine)

"Check values for freshly created variables :"
"PWSH_SCRIPTS_ROOT " + $env:PWSH_SCRIPTS_ROOT
"PWSH_SCRIPTS_LIBS " + $env:PWSH_SCRIPTS_LIBS
"PWSH_SCRIPTS_BIN  " + $env:PWSH_SCRIPTS_BIN
"PWSH_SCRIPTS_LOGS " + $env:PWSH_SCRIPTS_LOGS
"PWSH_SCRIPTS_TMP  " + $env:PWSH_SCRIPTS_TMP
