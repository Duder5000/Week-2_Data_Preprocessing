#Target folders
$ravdassFolder = "G:\DBs to Merge\RAVDESS"
$copyToFolder = "G:\DBs to Merge\NewRavdass"
$outputFilePath = "G:\DBs to Merge\NewRavdass\OutputLog.txt"

#Clean new folder before copying
Remove-Item -Path $copyToFolder\* -Recurse -Force

#Loop through the files & convert & skip boredom
$ravdassFiles = Get-ChildItem -Path $ravdassFolder -Filter *.wav -Recurse

#01 = neutral, 02 = calm, 03 = happy, 04 = sad, 05 = angry, 06 = fearful, 07 = disgust, 08 = surprised
#Remove calm (02) & surprised (08)
#.Substring(6, 2)

foreach ($ravdassFile in $ravdassFiles) {		
	#Check if the emotion code is '02' or '08' and skip it
	if (($ravdassFile.BaseName.Substring(6, 2) -eq '02') -or ($ravdassFile.BaseName.Substring(6, 2) -eq '08')) { 
		Add-Content -Path $outputFilePath -Value "Skip $($ravdassFile.BaseName)"
	} else {
		Copy-Item -Path $ravdassFile.FullName -Destination $copyToFolder
		Add-Content -Path $outputFilePath -Value "Coppied $($ravdassFile.BaseName)"
	}
}