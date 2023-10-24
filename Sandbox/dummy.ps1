Remove-Variable * -ErrorAction SilentlyContinue
Import-Module libEnvRoot

Test-EnvRoot;
Set-EnvRoot;
#Remove-RootPath;
