#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Remove-TemporaryFiles.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20220525
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
        Run clean procedures for temporary files elder than 15 days

    .DESCRIPTION
        Run clean procedures for temporary files elder than 15 days
        Run once a week on sunday for Exstream server through Windows Task Scheduler

    .INPUTS
        none

    .OUTPUTS
        none

    .EXAMPLE
        ./Remove_ExstreamTemporaryFiles.ps1

#>
$period = 15
$default_filter = "*.*"
$list_directories = ( 
    "D:\ManagementGateway\16.6\root\tmp",
    "C:\Users\SVC_Q_Exstream-01\AppData\Local\Temp"
)

foreach ($item in $list_directories) {

    d:\Scripts\tools\Remove-FileElderThan.ps1 -source $item -filter $default_filter -days $period
}
