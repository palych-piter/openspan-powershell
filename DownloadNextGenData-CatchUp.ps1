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
  #[string]$RawDataDate
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

# Send and Email according to parameters
function SendEmail($To, $From, $Subject, $Body, $smtpServer){
        write-host $smptServer
		Send-MailMessage -To $To -Subject $Subject -From $From -Body $Body -priority "High" -SmtpServer $smtpServer
}

# Checking file size and sending an Email in case of an alert
function CheckFileSizes ($FilePath){
        # Define a threshold
        $FileSizeThreshold = DefineThreshold ($DateToDownload)
        # Send a Emaili in case of the file size is small 		
        if((get-item $FilePath).length -lt $FileSizeThresHold){ 
			 
			 $EmailTo = 
			 "abespalov@openspan.com,schurbanov@openspan.com,mtsurenko@openspan.com"
			 
			 $EmailFrom = 
			 'AetnaNextGen-RawDataValidation@openspan.com'
			 
			 $EmailBody = 
			 "The ASD file either doesn't exist or less than a pre-defined threshold" + 
			 "in the $($DestinationFolder+$DestinationFolderName) folder." + 
			 "The threshold for week days is 100MB, the threshold for Saturdays is 10MB," +
			 "the threshold for Sundays is 4MB."
			 
			 $EmailSubject = 
			 "WARNING: Aetna FCR Raw Data"
			 
			 $EmailSmtp = 
			 'smtp.enkata.com'
			 
			 SendEmail abespalov@openspan.com,schurbanov@openspan.com,mtsurenko@openspan.com $EmailFrom $EmailSubject $EmailBody $EmailSmtp 
			
			}					 	 
}

# Define the threshold to check file size 
# according to a day of week
function DefineThreshold ($DateToDownload){
		
		 if(
		    $DateToDownload.DayofWeek -eq "Monday" -or
		    $DateToDownload.DayofWeek -eq "Tuesday" -or
		    $DateToDownload.DayofWeek -eq "Wednesday" -or
		    $DateToDownload.DayofWeek -eq "Thursday" -or
		    $DateToDownload.DayofWeek -eq "Friday") 
	            #Weekdays threshold
				{return 100mb}
		 elseif(
		    $DateToDownload.DayofWeek -eq "Saturday")
                #Threshold for Saturday
				{return 10mb}			
		 else   
				#Rhreshold for Sunday 
				{return 4mb}
}


function RunDownloadProcess ($DateToDownload){

#Define folder name 
$DestinationFolderName = $DateToDownload.ToString("yyyyMMdd")

# Start the download bach file
Start-Process -FilePath download_background.bat $DestinationFolderName -Wait -passthru;$a.ExitCode

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

# Check the files on NTTBACK to verify if sizes are 
CheckFileSizes $DestinationFolder$DestinationFolderName\ASD*.zip

}


# Main
# Go to the working directory
Set-Location -path $ScriptFolder

RunDownloadProcess($a.AddDays(-3))
RunDownloadProcess($a.AddDays(-4))
RunDownloadProcess($a.AddDays(-5))
RunDownloadProcess($a.AddDays(-6))

