
function export-files { 
    param([string] $Source, [string] $Destination, [string] $FileType, [int32] $TotalFiles,`
    [string] $DateAfter, [string] $DateBefore)
    
    $src = $Source # "C:\SourceFolder"
	$dest_in = $Destination # "C:\DestinationFolder"
	cd $dest_in 

	$tmp_dir = "\" + (Get-Date).ToString("yyyyMMdd") + "_" + (New-Guid).ToString().Substring(0,5) 
	$dest = $dest_in + $tmp_dir 
	"`n`ntmp_dir: " + $tmp_dir
	$md = mkdir $dest

	$ftype = $FileType # "*.*" 
	$i = 0
    "`nStart Time:" 
	Get-Date

	$row_count = $TotalFiles # Max Files = 999

	cd $dest
    #ii $dest

    #Where-Object DateModified -le $d | ` 	sort LastWriteTime -Descending | ` 
	$cmd = 'gci -Filter $ftype -File -Recurse -Path $src | Where-Object { $_.LastWriteTime -gt (Get-Date $DateAfter) `
    -and $_.LastWriteTime -lt (Get-Date $DateBefore) -and $_.Length -gt 1kb} `
    | sort -property $_.LastWriteTime | select -First ' + $row_count 

	Write-Progress -Activity "Calulating" -PercentComplete 1
	$stat = Invoke-Expression $cmd | measure-object -Property length -Sum
	"Size (with Duplicate) MB: " + [math]::Round($stat.Sum / 1mb)
    
    # Copy files using Hash as a new name
	Write-Progress -Activity "Copying" -PercentComplete 2

	$copy_text = Invoke-Expression $cmd | `
	ForEach-Object { $i = $i + 1; $pct = [math]::Round(($i / $stat.Count)*100) ; `
		Write-Progress -Activity "Copying" -PercentComplete $pct; `
        $number = ([string]$i).PadLeft(4,'0'); `
		cp -Verbose -Force -Destination ($dest + "\"+ $number + $_.Extension) -Path ($_.FullName ); `
		return ("`n"+ $number.ToString() + ": " + $_.Name); } 

	#"`nCopy File:" + ($copy_text)
	"`nTotal Copy Files (with Duplicate):" + ($copy_text).Count

	Write-Progress -Activity "Closing" -PercentComplete 99
	"`nEnd Time:" 
    Get-Date

}

function export-yearly {param([string] $yr)

for($m = 1; $m -lt 13; $m++){  

$a = (get-date ($yr+"-"+ $m +"-"+"01")).ToShortDateString()
$a
$b=(get-date $a).AddMonths(1).ToShortDateString()
$b

$dst = "F:\FFOutput" + "\"  + $yr
$pct = ($m / 12) * 100
Write-Progress -Activity "Yearly" -PercentComplete $pct; 

 export-files -Source "H:\Temp\AVI_ALL"  `
 -Destination $dst  -FileType "*.*" -TotalFiles 999 `
 -DateAfter $a -DateBefore $b

 }

 }

# Execute Section
("2004" , "2005")  | % {export-yearly $_ }
