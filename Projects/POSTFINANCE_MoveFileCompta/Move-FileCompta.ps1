#----------------------------------------------------------------------------------------------------------------------------------
# Script  : Move-FileCompta.ps1
#----------------------------------------------------------------------------------------------------------------------------------
# Author  : DLA
# Date    : 20231028
# Version : 1.0
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS

    Move-FileCompta.ps1 -conf <conffile> -delay <x> -unit <minute/hour/day(s)>
        -conf   XML configuration file (default is scriptname.conf on script executionpath)
        -delay  Time filter to select only file created between now and (now.delay)
        -unit   Delay unit in second, minute, hour, day
    Script de copie des incoming payment non traités vers repertoire de depose finance.

    .DESCRIPTION
    
    Contexte
    Tous les jours, la Poste dépose des fichiers de transaction CAMT (paiement de BVR) dans un répertoire FTP accessible par le TCS.
    Le nom de chaque fichier contient le numéro de l'IBAN et du Delivery Number pour lequel les paiement ont été faits (refs. 02. QR Code Official IBAN- QR IBAN status).
    
    Situation actuelle
    Il existe un processus automatisé, développé dans le cadre du projet NIS, qui traite les fichiers de paiement qui ont été générées par IDIT.
    Chaque fichier traité par ce processus est renommé avec le suffix .treated (ref. IDIT - Contrôle des fichiers Incoming Payment).
    Le choix de fichier à traiter par ce processus est définit dans un fichier de mapping NIPO-1375 - Le projet Jira n'existe pas ou vous n'êtes pas autorisé(e) à l'afficher.
    Les autres fichiers qui ne sont pas traités par ce processus (pas de suffix .treated) sont téléchargé manuellement par l'équipe de comptabilité (TRANCHET Christophe) pour un tratement manuel dans SAP.
    
    Situation souhaitée
    Les fichiers qui ne sont pas traité par le processus d'IDIT soient téléchargés automatiquement à un répertoire accessible exclusivement par l'équipe de comptabilité.
    Les fichiers téléchargés sont renommer avec le suffix .downloaded dans le répertoire SFTP de PostFinance (similaire au processus IDIT où les fichiers sont renommés .treated)

    Liste des comptes camt a traiter :

    - TCS	                    CH8609000000120024167 	1111200329  SAP
    - T&L Camping	            CH7009000000120053070	1111189590	SAP
    - T&L Training & Events	    CH7609000000177043566	1111205029  SAP
    - Academie Mobilité SA	    CH6709000000123782774	1111189602  SAP
    - TCS Voyages SA	        CH0609000000151620156	1111190795  SAP
    - Chacomo	                CH1809000000158817922	1116241979	SAP
    - BMW	                    CH6509000000159517319	1116427001	SAP
    - Swiss eMobility	        CH4509000000128207631	1111182929	SAP

    Reference :  https://confluence.tcsgroup.ch/pages/viewpage.action?pageId=632497603
    
    .PARAMETER FirstParameter
        Description of each of the parameters.
        Note:
        To make it easier to keep the comments synchronized with changes to the parameters,
        the preferred location for parameter documentation comments is not here,
        but within the param block, directly above each parameter.

    .PARAMETER SecondParameter
        Description of each of the parameters.

    .INPUTS
        Description of objects that can be piped to the script.

    .OUTPUTS
        Return code 0 - Script successsfully executed
        Return code 1 - Script in error

    .EXAMPLE
        Move-FileCompta.ps1 

    .LINK
        Links to further documentation.

    .NOTES
        Detail on what the script does, if this is needed.

    #>
#----------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------
#                                            C O M M A N D   P A R A M E T E R S
#----------------------------------------------------------------------------------------------------------------------------------
param (
    # path of the resource to process
    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $true,
        Position = 0
        )
    ]
    [alias('conf')] $config_path,
    
   
    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $true,
        Position = 0)
    ] $delay,

    [Parameter(
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $true,
        Position = 0)
    ]
    [ValidateSet('second', 'minute', 'hour', 'day')]
     $unit,
   
    
    # help switch
    [switch] $help
)



#----------------------------------------------------------------------------------------------------------------------------------
#                                                I N I T I A L I Z A T I O N
#----------------------------------------------------------------------------------------------------------------------------------
<#
    .DESCRIPTION
        Setup logging facilities by defining log path and default levels.
        Create log instance
#>


BEGIN {
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                           G L O B A L   I N C L U D E S 
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .SYNOPSIS
            Global variables
        
        .DESCRIPTION
            Set script's global variables as AUTHOR, VERSION, and Last modif date
			Also define output separator line size for nice formating
			Define standart script exit codes
    #>
    # Import-Module libEnvRoot
    Import-Module libConstants
    Import-Module libLog
    Import-Module Posh-SSH

    #Set-EnvRoot
    $script_path      = "Y:\03_DEV\06_GITHUB\tcs-1\Projects\POSTFINANCE_MoveFileCompta"
    if (-not $config_path) { $config_path      = $script_path + "\" + ($MyInvocation.MyCommand.Name -replace 'ps1','')+ 'conf'}
    
    # Log initialization
    if (-not (Start-Log -path $global:LogRoot -Script $MyInvocation.MyCommand.Name)) { 
        "FATAL : Log initializzation failed!"
        exit $EXIT_KO
    }
    
    # Set log default and minum level for logging (ideally DEBUG when having trouble)
    Set-DefaultLogLevel -Level "INFO"
    Set-MinLogLevel -Level "DEBUG"
}

PROCESS {
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 I N C L U D E S 
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .SYNOPSIS
            Includes
        
        .DESCRIPTION
            Include necessary libraries
    #>
   
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

    
    #----------------------------------------------------------------------------------------------------------------------------------
    #                                                 F U N C T I O N S 
    #----------------------------------------------------------------------------------------------------------------------------------

    #..................................................................................................................................
    # Function : helper
    #..................................................................................................................................
    # Display help message and exit gently script with EXIT_OK
    #..................................................................................................................................
    function helper {
        "Do something usefull for you..."
        " "
        "Options : "
        "-conf     Configuration file"
        "-unit     Filter period unit"
        "-delay    Filter period value"
        "-Help     Display command help"
    }
   

    #----------------------------------------------------------------------------------------------------------------------------------
    #                                             _______ _______ _____ __   _
    #                                             |  |  | |_____|   |   | \  |
    #                                             |  |  | |     | __|__ |  \_|
    #----------------------------------------------------------------------------------------------------------------------------------
    <#
        .DESCRIPTION
            Particularly when the comment must be frequently edited,
            as with the help and documentation for a function or script.
    #>
    
    # Quick comment
    
    # Script infp
    Log -Level 'INFO' -Message $SEP_L1
    log -Level 'INFO' -Message ($MyInvocation.MyCommand.Name + " v" + $VERSION)
    Log -Level 'INFO' -Message $SEP_L1
    
   

    #$delay = '01.01.2023'
    
    # 1 - Load script config file
    try {
        [XML]$conf = Get-Content $config_path
        $confRoot = $conf.conf
    }
    catch [System.IO.FileNotFoundException] {
        Log -Level "ERROR" -Message ("Configuration file not found " + $config_path)
        Log -Level "ERROR" -Message ("Process aborted! " + $config_path)
        Clean-TemporaryDirectory
        Stop-Log | Out-Null
        exit $EXIT_KO
    }
    
     # Process command line + Display inline help if required
     if ($help) { helper }
     
     if ((-not ($unit)) -or (-not ($delay))) {
        $delay = $confRoot.options.delay.value
        $unit = $confRoot.options.delay.unit
     }

     if ($unit -eq 'second') {
         $delay = (Get-date).AddSeconds(-1 * $delay)
     } elseif ($unit -eq 'minute') {
         $delay = (Get-date).AddMinutes(-1 * $delay)
     } elseif ($unit -eq 'hour') {
         $delay = (Get-date).AddGours(-1 * $delay)
     }
     elseif ($unit -eq 'day') {
         $delay = (Get-date).AddDays(-1 * $delay)
     }
     
     Log -Level 'DEBUG' -Message ('Filter delay period set to : ' + $delay + ' ' + $unit)
     
     # Do something here
    # 1 - Get connected to SFTP
    
    $sec_pwd        = $confRoot.sftp_servers.sftp_server_tcs.userpwd | ConvertTo-SecureString -AsPlainText -Force
    $credential     = New-Object System.Management.Automation.PSCredential($confRoot.sftp_servers.sftp_server_tcs.username, $sec_pwd ) 
    try {
        $sftpSession    = New-SFTPSession -ComputerName $confRoot.sftp_servers.sftp_server_tcs.computername -Credential $credential
    }
    catch {
        Log -Level 'ERROR' -Message "An error occurred while connecting to SFTP server."
        Log -Level 'ERROR' -Message($_)
        Log -Level 'ERROR' -Message($_.ScriptStackTrace)
        exit $EXIT_KO
    }
    
    # 2 - Get file source list
    $srcFileList = Get-SFTPChildItem -SFTPSession $sftpSession -path $confRoot.sftp_servers.sftp_server_tcs.sftp_input_path
    Log -Level 'INFO' -message('Count ' + ($srcFileList).Count + ' item(s) on SFTP source')
    

    # 3 - Filter source list
    # Date and name filtering
    Log -Level 'INFO' -message 'Sorting and filtering SFTP file list'
    $srcFileList = $srcFileList | ?{
        $_.LastWriteTime -gt $delay `
        -and ($_.name -match ".xml$")
    } 
    
    # Accounts list filtering
    $tmpList = @()
    $srcFileList | foreach-object {
        if ($_.name -match 'camt.054_P_CH(\d{19})_(\d{10})_(\d)_(\d{16}).xml$') {
            $iban = "CH" + $Matches[1]
            $number = $Matches[2]
            $seq = $Matches[3]
            $timestamp = $Matches[4]

            if ($iban -in $confRoot.accounts.account.iban) {
                $tmpList += $_
            }
        }
    }
    $srcFileList = $tmpList
    
    Log -Level 'INFO' -message('Count ' + ($srcFileList).Count + ' item(s) electable for copy to ' + $confRoot.pathes.local_path )
    
    if (($srcFileList).Count -eq 0) {
        Log -Level 'INFO' -message 'There nothing left to do...'
        Log -Level 'INFO' -message $SEP_L1
        Stop-Log | Out-Null
        exit $EXIT_OK
    }

    # 4 - Download source file to dest + rename original
    Log -Level 'INFO' -message $SEP_L2
    $srcFileList | %{
        try {
            Log -Level 'INFO' -message ("Copy "+ $_.FullName + " to " + $confRoot.pathes.local_path)
            Get-SFTPItem -SFTPSession $sftpSession -path $_.FullName -destination $confRoot.pathes.local_path -ErrorAction SilentlyContinue
            Log -Level 'INFO' -message ("Rename source to " + ($_.name + '.downloaded'))
            Rename-SFTPFile -SFTPSEssion $sftpSession -path $_.FullName -NewName ($_.name + '.downloaded')
        } catch {
            Log -Level 'ERROR' -Message "An error occurred while copy/rename files :"
            Log -Level 'ERROR' -Message($_)
            Log -Level 'ERROR' -Message($_.ScriptStackTrace)
            Log -Level 'INFO' -message $SEP_L1
            (get-sftpsession | Select-object SessionId) | remove-sftpsession
            Stop-Log | Out-Null
            exit $EXIT_KO
        }
    }
     

    # 5 - Close connexion
    Remove-SFTPSession -SFTPSEssion $sftpSession | Out-Null
    
    # Standard exit
    Log -Level 'INFO' -message $SEP_L1
    Stop-Log | Out-Null
    exit $EXIT_OK
    #----------------------------------------------------------------------------------------------------------------------------------
}






