"---------------------------------------------------------------------------------------------------------------------------" 
"Translating path in CSV index ..." 
"---------------------------------------------------------------------------------------------------------------------------" 
$list_csv = Get-ChildItem "\\fs_Appsdata_ge3\Apps_data$\EXSTREAM\DEV\Diffusion\Onbase\*.csv"
$total = ($list_csv).Count
$count = 0
foreach ($item in $list_csv) {
    $count += 1
    "($count/$total) Translate source path on $item" 
    (Get-Content $item) -replace "\\PRD\\","\\DEV\\" |Set-Content $item
	(Get-Content $item) -replace "\ACP\","\\DEV\\" |Set-Content $item
	(Get-Content $item) -replace "\\QA\\","\\DEV\\" |Set-Content $item
} 
"---------------------------------------------------------------------------------------------------------------------------"
"Done!" 
"---------------------------------------------------------------------------------------------------------------------------"