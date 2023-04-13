# Sectzion 05 - Output and reporting experiments

# Length formater function
Function Format-FileSize() {
    Param ([int64]$size)
    If     ($size -gt 1TB) {[string]::Format("{0:0.00} TB", $size / 1TB)}
    ElseIf ($size -gt 1GB) {[string]::Format("{0:0.00} GB", $size / 1GB)}
    ElseIf ($size -gt 1MB) {[string]::Format("{0:0.00} MB", $size / 1MB)}
    ElseIf ($size -gt 1KB) {[string]::Format("{0:0.00} kB", $size / 1KB)}
    ElseIf ($size -gt 0)   {[string]::Format("{0:0.00} B", $size)}
    Else                   {""}
}

Set-Location -Path "D:\"
Write-Verbose "Building log files list..." -Verbose
$log_list = Get-ChildItem *.log -recurse | Where-Object {$_.LastWriteTime -le (get-date).AddDays(-15)} | Sort-Object -Property Length -Descending | Select-Object -Property FullName,@{Name="Size";Expression={Format-FileSize($_.Length)}}, LastWriteTime -First 10 

Write-Verbose "Building CPU threads list..." -Verbose
$CPU_list = Get-Process | Sort-Object -Property CPU -descending | Select-Object -First 10

# Define a nice CSS for our HTML table
$head = @"
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:"Calibri Light";
	panose-1:2 15 3 2 2 2 4 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:8.0pt;
	margin-left:0cm;
	line-height:107%;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
h1
	{mso-style-link:"Titre 1 Car";
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	line-height:107%;
	page-break-after:avoid;
	font-size:16.0pt;
	font-family:"Calibri Light",sans-serif;
	color:#2E74B5;
	font-weight:normal;}
h2
	{mso-style-link:"Titre 2 Car";
	margin-top:2.0pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	line-height:107%;
	page-break-after:avoid;
	font-size:13.0pt;
	font-family:"Calibri Light",sans-serif;
	color:#2E74B5;
	font-weight:normal;}
p.MsoTitle, li.MsoTitle, div.MsoTitle
	{mso-style-link:"Titre Car";
	margin:0cm;
	margin-bottom:.0001pt;
	font-size:28.0pt;
	font-family:"Calibri Light",sans-serif;
	letter-spacing:-.5pt;}
p.MsoTitleCxSpFirst, li.MsoTitleCxSpFirst, div.MsoTitleCxSpFirst
	{mso-style-link:"Titre Car";
	margin:0cm;
	margin-bottom:.0001pt;
	font-size:28.0pt;
	font-family:"Calibri Light",sans-serif;
	letter-spacing:-.5pt;}
p.MsoTitleCxSpMiddle, li.MsoTitleCxSpMiddle, div.MsoTitleCxSpMiddle
	{mso-style-link:"Titre Car";
	margin:0cm;
	margin-bottom:.0001pt;
	font-size:28.0pt;
	font-family:"Calibri Light",sans-serif;
	letter-spacing:-.5pt;}
p.MsoTitleCxSpLast, li.MsoTitleCxSpLast, div.MsoTitleCxSpLast
	{mso-style-link:"Titre Car";
	margin:0cm;
	margin-bottom:.0001pt;
	font-size:28.0pt;
	font-family:"Calibri Light",sans-serif;
	letter-spacing:-.5pt;}
span.Titre1Car
	{mso-style-name:"Titre 1 Car";
	mso-style-link:"Titre 1";
	font-family:"Calibri Light",sans-serif;
	color:#2E74B5;}
span.Titre2Car
	{mso-style-name:"Titre 2 Car";
	mso-style-link:"Titre 2";
	font-family:"Calibri Light",sans-serif;
	color:#2E74B5;}
span.TitreCar
	{mso-style-name:"Titre Car";
	mso-style-link:Titre;
	font-family:"Calibri Light",sans-serif;
	letter-spacing:-.5pt;}
p.Titlereport, li.Titlereport, div.Titlereport
	{mso-style-name:"Title report";
	mso-style-link:"Title report Car";
	margin:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	font-size:16.0pt;
	font-family:"Calibri",sans-serif;
	color:#BF8F00;}
span.TitlereportCar
	{mso-style-name:"Title report Car";
	mso-style-link:"Title report";
	color:#BF8F00;}
.MsoPapDefault
	{margin-bottom:8.0pt;
	line-height:107%;}
@page WordSection1
	{size:595.3pt 841.9pt;
	margin:70.85pt 70.85pt 70.85pt 70.85pt;}
div.WordSection1
	{page:WordSection1;}
-->
</style>
"@
 
 $log_list | ConvertTo-HTML -Head $head -Body "<h1>10 biggest logs</h1>" | Out-File .\list.html
 $log_list | Out-GridView
 $cpu_list | ConvertTo-HTML -Head $head -Title "<h1>10 most intensive processes</h1>" | Out-File .\cpu.html
 $cpu_list | Out-GridView


 # Cool stuff to serialéize PS objects
 Get-Process -name "a*" | Export-Clixml "process_list.xml"
 $ps_list = Import-Clixml .\process_list.xml 
 $ps_list | Sort-Object PM -Descending     