#Copyright (c) 2015 OpenSpan.
#All rights reserved.
#
#The script downloads the Aetna NextGen raw data for the denibed date 
#and copy the data to a destination folder on NTTBACK
#
#@author Andrey Bespalov
#@Date 
#powershell "& 'D:\enkata_storage\Aetna Next Gen\OPS\DownloadNextGenData-CatchUp.ps1'" 20150606

# Initialize the download date parameter value 

Param(
  [string]$RawDataDate
  #[string]$FolderToCopyData
)

# Global variables 

# Folder for downloaded files
$Global:DownloadFolder = "D:\Downloaded\FutureLoads" 
# Destination folder
$Global:DestinationFolder = "\\nttback\aetnanextgen\" 
# Script folder
$Global:ScriptFolder = "D:\enkata_storage\Aetna Next Gen\OPS" 

# Filter for extensions of files to copy
$Global:FileExtensionsFilter = "*.txt" 
$Global:FileExtensionsFilter1 = "*.zip" 
$Global:FileExtensionsFilter2 = "*.csv" 

$Global:a = Get-Date 


function RunDownloadProcess ($DestinationFolderName){

#Define folder name 
#$DestinationFolderName = $DateToDownload.ToString("yyyyMMdd")

# Start the download bach file
Start-Process -FilePath Download_orig.bat $DestinationFolderName -Wait -passthru;$a.ExitCode

# Create a folder if not exist

if((Test-Path $DestinationFolder$DestinationFolderName) -eq 0)
    {
     New-Item -ItemType directory -Path $DestinationFolder$DestinationFolderName   
    }
   
 elseif ((Test-Path $DestinationFolder$DestinationFolderName) -eq 1)
    {         }

# Copy the data to a destination folder
copy-item $DownloadFolder\*.* -Destination $DestinationFolder$DestinationFolderName\ -filter $FileExtensionsFilter -force -recurse
copy-item $DownloadFolder\*.* -Destination $DestinationFolder$DestinationFolderName\ -filter $FileExtensionsFilter1 -force -recurse
copy-item $DownloadFolder\*.* -Destination $DestinationFolder$DestinationFolderName\ -filter $FileExtensionsFilter2 -force -recurse

# Remove items from a download folder
Remove-Item $DownloadFolder\*.* 
}

Set-Location -path $ScriptFolder

RunDownloadProcess($RawDataDate)

