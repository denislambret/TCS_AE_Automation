$header = @"
<style>

    h1 {

        font-family: Arial, Helvetica, sans-serif;
        color: #e68a00;
        font-size: 28px;

    }

    
    h2 {

        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 16px;

    }

    
    
   table {
		font-size: 12px;
		border: 0px; 
		font-family: Arial, Helvetica, sans-serif;
        width: 65%
	} 
	
    td {
		padding: 4px;
		margin: 0px;
		border: 0;
	}
	
    th {
        background: #fdf938;
        color: #000;
        font-size: 11px;
        text-transform: uppercase;
        padding: 10px 15px;
        vertical-align: middle;
	}

    tbody tr:nth-child(even) {
        background: #fffcbc;
    }
    


    #CreationDate {

        font-family: Arial, Helvetica, sans-serif;
        color: #ff3300;
        font-size: 12px;

    }



    .StopStatus {

        color: #ff0000;
    }
    
  
    .RunningStatus {

        color: #008000;
    }




</style>
"@

$html_header = @"
<header role="banner" class="clearfix">
<div class="branding">
<div class="logo"><img src="./logo_tcs-_bookmark.png" alt="TCS"></div>
<h1>TCS</h1>
<h2 class="strapline">Global Monitoring System</h2>
</div>
<nav role="navigation" id="navigation">
<ul>
TCS GLOBAL MONITORING&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<li><a href="https://mg.tcsgroup.ch/SanityCheck.php" target="_top">Sanity Check</a></li>
<li><a href="https://mg.tcsgroup.ch/changerMessage.php" target="_top">Info</a></li>
<li><a href="https://mg.tcsgroup.ch/ChangementDePiquet.php" target="_top">Piquets: Le Gal Yannick / Mauro Petrizzo</a></li>
<li id="miniclock">23:02:03</li>
</ul></nav>
</header>
"@





$file_list = Get-ChildItem -path *.ps1 | Sort -Property Length | select -Property Name, Fullname, Length, LastWriteTime
$file_list = $file_list | ConvertTo-Html -Fragment -PreContent "<div align='center'><h2>File List</h2>" -PostContent "</div>"

$service_list = Get-Service | Select -Property DisplayName, status,can*
$service_list = $service_list | ConvertTo-Html -Fragment -PreContent "<div align='center'><h2>Processes List</h2>" -PostContent "</div>"


Convertto-html -head $header -Body ($file_list + $service_list) | Out-File "./test_page.html"
