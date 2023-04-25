;Setting Parameters
Set EXEC=C:\PSFTP
Set PARAM=C:\PSFTP\ONBASE_0
Set LOG=C:\PSFTP\ONBASE_0\OnBase_SFTP_DEV.log
Set DATE=%date%

echo %date% - %time% >>%LOG%
echo %date% - %time% -------------------------------------- 1-Transfert lot1 (SFDC.CSV vers /InputSFDC ------- >>%LOG%
%EXEC%\psftp sftp_capgemini@sftppub.tcs.ch -pw cAP1sftP0 -b %PARAM%\PSFTP_01.bat
xcopy /y \\fs_AppsData_ge3\Apps_Data$\ONBASE\QA\Diffusion\SFDC.CSV \\fs_AppsData_ge3\Apps_Data$\EXSTREAM\QA166\NIP\Diffusion\archive\ >>%LOG%
move \\fs_AppsData_ge3\Apps_Data$\EXSTREAM\QA166\NIP\Diffusion\archive\SDFC.TMP \\fs_AppsData_ge3\Apps_Data$\EXSTREAM\
move /y \\fs_AppsData_ge3\Apps_Data$\ONBASE\DEV\Diffusion\SFDC.CSV  \\fs_AppsData_ge3\Apps_Data$\ONBASE\DEV\Diffusion\SAVE\SFDC_%DATE%.CSV >>%LOG%

echo %date% - %time% -------------------------------------- 2-Transfert lot2 (xxx.CSV vers /InputCapture ----- >>%LOG%
%EXEC%\psftp sftp_capgemini@sftppub.tcs.ch -pw cAP1sftP0 -b %PARAM%\PSFTP_02.bat
xcopy /y \\fs_AppsData_ge3\Apps_Data$\ONBASE\DEV\Diffusion\Scanning\*.csv  \\fs_AppsData_ge3\Apps_Data$\ONBASE\DEV\Diffusion\Scanning\SAVE\ >>%LOG%
del \\fs_AppsData_ge3\Apps_Data$\ONBASE\DEV\Diffusion\Scanning\*.csv   >>%LOG%
