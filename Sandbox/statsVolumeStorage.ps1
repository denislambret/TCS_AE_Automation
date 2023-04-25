#--------------------------------------------------------------------------------------------------------------
# Name        : 
#--------------------------------------------------------------------------------------------------------------
# Author      : D.Lambret
# Date        : 17.11.2021
# Status      : DEV
# Version     : 0.1
#--------------------------------------------------------------------------------------------------------------
# Description : Ce script permet de scanner un repertoire de type Volume OnBase pour compter le nombre de f
# de fichiers deja stockés et différentes statistiques sur la taille moyenne et maximale des archives.
#--------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------
# Global Variables
#--------------------------------------------------------------------------------------------------------------
$records = @()
$count = 0
$total = 0

#--------------------------------------------------------------------------------------------------------------
# Main
#--------------------------------------------------------------------------------------------------------------
$list = Get-ChildItem P:\ONBASE\PRD\DATA\CCM -directory
Write-Host "Directory;biggestFileName;maxSize;avgSize;totalFiles"
foreach ($item in $list) {
    $newRecord = Get-ChildItem P:\ONBASE\PRD\DATA\CCM\$item -r
    $count = ($newRecord).Count
    $avg = [Math]::round((($newRecord | measure-object -property length -average).average) / 1MB ,2)
    $max = [Math]::round((($newRecord | measure-object -property length -maximum).maximum) / 1MB ,2)
    $total = $total + $count
    $newRecord = $newRecord | sort-object -descending -property length | select-object -first 1 name, DirectoryName, @{Name="MB";Expression={[Math]::round($_.length / 1MB, 2)}}
    $records += $newRecord
    Write-Host $newRecord.DirectoryName";"$newRecord.Name";"$max";"$avg";"$total
    $avg = 0
}
