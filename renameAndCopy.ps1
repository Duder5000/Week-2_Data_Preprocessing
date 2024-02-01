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
	
    
	#$textCode = $emodbFilename.Substring(2, 3)
    $emotionCode = $emodbFilename.Substring(5, 1)
	$emotionCode = [char]::ToUpper($emotionCode) #Checking if forcing to upper char could fix not getting all te=he files
	
	$intensityCode = '01' #Set all to Normal intensity
	$statementCode = '03' #Set all do a diffrent statement than the 2 in RAVDESS
	
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
$emodbFolder = "G:\DBs to Merge\EmoDB"
$renamedFilesFolder = "G:\DBs to Merge\NewEmoDB"

#Clean new folder before copying
Remove-Item -Path $renamedFilesFolder\* -Recurse -Force

#Loop through the files & convert & skip boredom
$emodbFiles = Get-ChildItem -Path $emodbFolder -Filter *.wav

foreach ($emodbFile in $emodbFiles) {
    $convertedFilename = Convert-EmoDBToRAVDESS -emodbFilename $emodbFile.BaseName
	#Check if the emotion code is 'L' and skip it
	if ($emodbFile.BaseName.Substring(5, 1) -eq 'L') {
		#Skip copying
	}else{
		$destinationPath = Join-Path -Path $renamedFilesFolder -ChildPath "$convertedFilename.wav"
		Copy-Item -Path $emodbFile.FullName -Destination $destinationPath
		Write-Host "EmoDB Filename: $($emodbFile.Name) -> RAVDESS Filename: $($convertedFilename).wav"
    }
}