#----------------------------------------------------------------------------------------------------------------------------------
#                                            C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
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
    [Alias("Gen")] [switch]$genPDF,
    
    # path for the result generated during process
    [Parameter(
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 2)
    ] 
    [Alias("Count")] [int] $maxIter,

    # path for the result generated during process
    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $true,
        Position = 3)
    ] 
    [Alias("DocumentType")] [int] $docType,
    
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

$root_script = "C:\Users\LD06974\OneDrive - Touring Club Suisse\03_DEV\06_GITHUB\TCS_AE\Projects"
#$root_script = "D:\Dev\01_GITHUB\TCS_AE_Automation\"
#$root_script = "D:\scripts"
$source_catalog  = $root_script + "\ONBASE_BacthDIPGenerator\catalog.csv";
$source_dtg      = $root_script + "\ONBASE_BacthDIPGenerator\DTG_catalog.csv"
$source_sample   = $root_script + "\ONBASE_BacthDIPGenerator\TCS_Sample_PDF.pdf"

#----------------------------------------------------------------------------------------------------------------------------------
#                                                 F U N C T I O N S 
#----------------------------------------------------------------------------------------------------------------------------------

#..................................................................................................................................
# Function : genPDF
#..................................................................................................................................
# Generate PDF file
#..................................................................................................................................
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

#----------------------------------------------------------------------------------------------------------------------------------
#                                             _______ _______ _____ __   _
#                                             |  |  | |_____|   |   | \  |
#                                             |  |  | |     | __|__ |  \_|
#----------------------------------------------------------------------------------------------------------------------------------
'-' * 140
$MyInvocation.MyCommand.Name + " v" + $VERSION
'-' * 140
'Generating sample documents and associated indexes...'
$sw = [Diagnostics.Stopwatch]::StartNew()

$myDate = get-date -f 'yyyyMMdd_HHmmss_'
$catalog = Import-CSV -Path $source_catalog  -Delimiter ';'
$dtgList = Import-CSV -path $source_dtg -Delimiter ';' -Header @('Type','Description')
$mylist = @()
if ($docType) {
		$fDocType = $true
	} else {
		$fDocType = $false
	}

1..$maxIter | ForEach-Object { 
    
       
    if (-not $fDocType) { 
		$dtg = Get-Random -InputObject $dtgList
        $docType = $dtg.Type
		$docTypeDesc = $dtg.Description
    } else {
		$docTypeDesc = ($dtgList | Where-Object {$_.Type -eq $docType} | Select-Object Description).Description
    }
	$filename =  $output + '\' + $myDate + $docTypeDesc + '_' + (($_.ToString()).PadLeft(10,"0")) + '.pdf' 
    $item = Get-Random -InputObject $catalog
    $item | Add-Member -NotePropertyName DTGs -NotePropertyValue $docType -Force
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
$myList | ConvertTo-Csv -Delimiter ';' -NoTypeInformation | Select-Object -Skip 1| Out-file $output_file
'-' * 140
$sw.Stop()
'Elapsed time : ' + $sw.Elapsed.TotalSeconds + ' second(s)'
'-' * 140