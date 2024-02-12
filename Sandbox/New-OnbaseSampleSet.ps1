#----------------------------------------------------------------------------------------------------------------------------------
#                                            C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
    # path of the resource to process
    # path of the resource to process
    [Parameter(
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 0
        )
    ] 
    [Alias("out")] [string]$output,
    
    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $true,
        Position = 1
        )
    ] 
    [Alias("gen")] [switch]$genPDF,
    
    # path for the result generated during process
    [Parameter(
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 2)
    ] 
    [Alias("Count")] [int] $maxIter,
    
    # help switch
    [switch] $help
)


 #----------------------------------------------------------------------------------------------------------------------------------
#                                          G L O B A L   V A R I A B L E S
#----------------------------------------------------------------------------------------------------------------------------------
<#
.SYNOPSIS
    Global variables

.DESCRIPTION
    Set script's global variables 
#>
$VERSION      = "0.1"
$AUTHOR       = "DLA"
$SCRIPT_DATE  = ""

$source_catalog  = "./catalog.csv";
$source_dtg      = "./DTG_catalog.csv"
$source_sample   = "D:\dev\01_GITHUB\TCS_AE_Automation\data\input\DIP\TCS_Sample_PDF.pdf"
#$output          = "D:\dev\01_GITHUB\TCS_AE_Automation\data\input\DIP"

function genPDF {

    [CmdletBinding()]
        param(
            [Parameter(
                Mandatory = $true,
                Position = 0
            )]
            [string] $Path,
            [Parameter(
                Mandatory = $true,
                Position = 0
            )]
            [int] $id
        )
    
        $wdExportFormatPDF = 17
    $wdDoNotSaveChanges = 0
    
    # Crée une fenêtre Word cachée
    $word = New-Object -ComObject word.application
    $word.visible = $false
    
    # Ajoute un document Word
    $doc = $word.documents.add()
    
    # Insère le texte dans le document Word (remplace $txtPath par le chemin de ton fichier texte)
    $txt = $item | Format-List
    
    $selection = $word.selection
    foreach ($line in $txt) {
        $selection.typeText($line) | Format-wide
        $selection.typeparagraph()
    }
    
    # Exporte le fichier PDF et ferme le document Word sans enregistrer
    $doc.ExportAsFixedFormat($Path, $wdExportFormatPDF)
    if ($?) {
        Write-Host "PDF created -> $Path" -ForegroundColor Cyan
    }
    $doc.close([ref]$wdDoNotSaveChanges)
    $word.Quit()
}

# MAIN
#------------------------------------------------------------------------------------------------------------------
'-' * 140
$MyInvocation.MyCommand.Name + " v" + $VERSION
'-' * 140
'Generating sample documents and associated indexes...'
$sw = [Diagnostics.Stopwatch]::StartNew()

$myDate = get-date -f 'yyyyMMdd_HHmmss_'
$catalog = Import-CSV -Path $source_catalog  -Delimiter ';'
$dtgList = Import-CSV -path $source_dtg -Delimiter ';' -Header @('Type','Description')
$mylist = @()

1..$maxIter | ForEach-Object { 
    $dtg = Get-Random -InputObject $dtgList
    $filename =  $output + '\' + $myDate + $dtg.DEscription + '_' + (($_.ToString()).PadLeft(10,"0")) + '.pdf'    

    $item = Get-Random -InputObject $catalog
    $item | Add-Member -NotePropertyName DTGs -NotePropertyValue $dtg.Type -Force
    $item | Add-Member -NotePropertyName FilePath -NotePropertyValue $filename -Force
    $mylist += $item
    if ($genPDF) { 
        genPDF -path $filename -id $_
    } else {
        Copy-Item -path $source_sample -Destination $filename
    }
    $item = $null
}

$output_file = $output + '\' + $mydate + 'DIP_Samples.csv'
'Index file   : ' + $output_file
$myList | ConvertTo-Csv -Delimiter ';' | Out-file $output_file
'-' * 140
$sw.Stop()
'Elapsed time : ' + $sw.Elapsed.TotalSeconds + ' second(s)'
'-' * 140