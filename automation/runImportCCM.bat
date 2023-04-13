@echo off
rem --- Batch caller for transcoding processing dedicated to CCM Plis index input file

rem 1 - Check command line parameters
if "%1"=="" ( echo "File source %1 does not exist" && EXIT /B 1 )
if "%2"=="" ( echo "File target %2 does not exist" && EXIT /B 1 )
if "%3"=="" ( echo "Lookup table %3 does not exist" && EXIT /B 1 )

echo File source %1>>d:/scripts/transco.out.txt
echo File target %2>>d:/scripts/transco.out.txt
echo Lookup %3>>d:/scripts/transco.out.txt

rem 2 - Execute associated powershell script
echo c:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -command "D:\scripts\CCM_Plis_Preprocessor\bin\preprocessorCCM.ps1 -path %1 -Dest %2 -Lookup %3">>d:/scripts/transco.out.txt
c:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -command "D:\scripts\CCM_Plis_Preprocessor\bin\preprocessorCCM.ps1 -path %1 -Dest %2 -Lookup %3" 

rem 3 - Retrieve and display error code
echo Return code : %ERRORLEVEL% >>d:/scripts/transco.out.txt

rem 4 - Return script RC to caller
EXIT /B %ERRORLEVEL%
@echo on

