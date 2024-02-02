#Convert EmoDB file names to RAVDESS style
function Convert-EmoDBToRAVDESS{
    param ([string]$emodbFilename)

    #Get info from EmoDB file name
    
	$substringResult = [int]$emodbFilename.Substring(0, 2)
	#$speakerNumber = $substringResult+50
	
	#Odd numbered actors are male, even numbered actors are female
	if($substringResult -eq 3){
		#03 - male, 31 years old
		$speakerNumber = 25
	}elseif($substringResult -eq 8){
		#08 - female, 34 years
		$speakerNumber = 26
	}elseif($substringResult -eq 9){
		#09 - female, 21 years
		$speakerNumber = 28
	}elseif($substringResult -eq 10){
		#10 - male, 32 years
		$speakerNumber = 27
	}elseif($substringResult -eq 11){
		#11 - male, 26 years
		$speakerNumber = 29
	}elseif($substringResult -eq 12){
		#12 - male, 30 years
		$speakerNumber = 31
	}elseif($substringResult -eq 13){
		#13 - female, 32 years
		$speakerNumber = 30
	}elseif($substringResult -eq 14){
		#14 - female, 35 years
		$speakerNumber = 32
	}elseif($substringResult -eq 15){
		#15 - male, 25 years
		$speakerNumber = 33
	}elseif($substringResult -eq 16){
		#16 - female, 31 years
		$speakerNumber = 34
	}else{
		$speakerNumber = 99
	}
	
	#https://www.kaggle.com/datasets/piyushagni5/berlin-database-of-emotional-speech-emodb
	
	$speakingTextCode = $emodbFilename.Substring(2, 3)	
	
	if($speakingTextCode.Substring(0, 1) -eq 'a'){
		$intensityCode = '01'
	}elseif($speakingTextCode.Substring(0, 1) -eq 'b'){
		$intensityCode = '02'
	}else{ 
		$intensityCode = '99'
	}
	    
	#Add-Content -Path $outputFilePath -Value $speakingTextCode.Substring(1)
	$statementCode = $speakingTextCode.Substring(1)
	
	#$intensityCode = '01' #Set all to Normal intensity
	#$statementCode = '03' #Set all do a diffrent statement than the 2 in RAVDESS
	
	$emotionCode = $emodbFilename.Substring(5, 1)
	
	$repCode = $emodbFilename.Substring(6)
	$repCode = ConvertToNumber($repCode)
	$repCode = '0' + $repCode

    #Map codes
    $emotionMapping = @{
        'W' = '05'; # anger
        'L' = '99'; # boredom (no matching RAVDESS)
        'E' = '07'; # disgust
        'A' = '06'; # anxiety/fear
        'F' = '03'; # happiness
        'T' = '04'; # sadness
        'N' = '01'; # neutral
    }

    #Check if code matches
    if ($emotionMapping.ContainsKey($emotionCode)) {
        $ravdessEmotionCode = $emotionMapping[$emotionCode]

        #Make new file name		
		$ravdessFilename = "03-01-{0}-{1}-{2}-{3}-{4}" -f $ravdessEmotionCode, $intensityCode, $statementCode, $repCode, $speakerNumber
        
		return $ravdessFilename
    } else {
        throw "Unsupported emotion code: $emotionCode"
    }
}

#Convert the EmoDB repetition letters to numbers
function ConvertToNumber{
    param ([char]$letter)
    # Convert letter to ASCII value
    $asciiValue = [int][char]::ToUpper($letter) - [int][char]'A' + 1

    return $asciiValue
}

#Target folders
$emodbFolder = "G:\DBs to Merge\EmoDB" #"G:\DBs to Merge\smallTest"
$renamedFilesFolder = "G:\DBs to Merge\NewEmoDB"
$outputFilePath = "G:\DBs to Merge\NewEmoDB\OutputLog.txt"

#Clean new folder before copying
Remove-Item -Path $renamedFilesFolder\* -Recurse -Force

#Loop through the files & convert & skip boredom
$emodbFiles = Get-ChildItem -Path $emodbFolder -Filter *.wav

foreach ($emodbFile in $emodbFiles) {
    #Adding the counter fixed the missing files, so I'm ending up with doubled up files names some how
	$convertedFilename = Convert-EmoDBToRAVDESS -emodbFilename $emodbFile.BaseName
	
	#Check if the emotion code is 'L' and skip it
	if ($emodbFile.BaseName.Substring(5, 1) -eq 'L') {
		Add-Content -Path $outputFilePath -Value "Skip $($emodbFile.Name)"
	} else {
		$destinationPath = Join-Path -Path $renamedFilesFolder -ChildPath "$convertedFilename.wav"
		Copy-Item -Path $emodbFile.FullName -Destination $destinationPath
		Add-Content -Path $outputFilePath -Value "EmoDB: $($emodbFile.Name) --> RAVDESS: $($convertedFilename).wav"
	}
}