#Copyright (c) 2015 OpenSpan.
#All rights reserved.
#
#The script downloads the aw data for the defined date 
#and copy the data to a destination folder on NTTBACK
#
#@author Andrey Bespalov
#@Date 
#powershell "& 'D:\enkata_storage\<project_name>\OPS\DownloadNextGenData-CatchUp.ps1'"
#powershell "& 'D:\enkata_storage\FedEx Production Kizhi\OPS\DownloadFedexData-CatchUp.ps1'"

# Initialize the download date parameter value 

Param(
  [string]$RawDataDate
  #[string]$FolderToCopyData
)

# Global variables 
# Folder for downloaded files
$Global:DownloadFolder = "D:\Downloaded\FutureLoads" 
# Destination folder
$Global:DestinationFolder = "\\nttback\fedex\" 
# Script folder
$Global:ScriptFolder = "D:\enkata_storage\FedEx Production Kizhi\OPS\" 
$Global:a = Get-Date 


function RunDownloadProcess ($DateToDownload){
	# Filter to copy
		$FilterToCopy = $DateToDownload + "*"
	# Filter to download
		$FilterToDownload = "mget " + $DateToDownload + "*"

	#Generate a FTP script on fly to pass a subfolder parameter
		Remove-Item DownloadFCR.ftp -force
		New-Item -path DownloadFCR.ftp -type file -force
		add-content -path DownloadFCR.ftp -value "open www.ec.fedex.com"
		add-content -path DownloadFCR.ftp -value "ENKATA"
		add-content -path DownloadFCR.ftp -value "F3d3xn3t"
		add-content -path DownloadFCR.ftp -value "cd RPT2ENK"
		add-content -path DownloadFCR.ftp -value "lcd D:\Downloaded\FutureLoads"
		add-content -path DownloadFCR.ftp -value "binary" 
		add-content -path DownloadFCR.ftp -value "prompt off" 
		add-content -path DownloadFCR.ftp -value $FilterToDownload
		add-content -path DownloadFCR.ftp -value "quit" 

	# Start the download bach file
		Start-Process -FilePath DownloadFCR.bat  -Wait -passthru;$a.ExitCode

	# Create a folder if not exist
		if((test-path $DestinationFolder$DateToDownload) -eq 0){
			new-item `
		   	 -ItemType directory `
		     -Path     $DestinationFolder$DateToDownload   
		}
        # Copy downloaded files to a destination folder 
		copy-item  $DownloadFolder\*.* `
		-destination $DestinationFolder$DateToDownload\ `
		-filter $FilterToCopy -force -recurse
}


#Main :

# Remove items from a download folder
#Remove-Item $DownloadFolder\*.* 

# Change the current folder to a script folder 
set-location -path $ScriptFolder

# Download files
# If the parameter is defined start downloading for a particular day, 
# otherwise start downloading for last 3 days
if($RawDataDate -eq ""){
     RunDownloadProcess(($a.AddDays(-1)).ToString("yyyyMMdd"))
     RunDownloadProcess(($a.AddDays(-2)).ToString("yyyyMMdd"))
     RunDownloadProcess(($a.AddDays(-3)).ToString("yyyyMMdd"))
    }
else{
	 RunDownloadProcess($RawDataDate)
    }
