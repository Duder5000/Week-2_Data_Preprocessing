#Convert EmoDB file names to RAVDESS style
#535
function Convert-EmoDBToRAVDESS{
    param ([string]$emodbFilename)

    #Get info from EmoDB file name
    $speakerNumber = $emodbFilename.Substring(0, 2)
    $textCode = $emodbFilename.Substring(2, 3)
    $emotionCode = $emodbFilename.Substring(5, 1)
	$intensityCode = 'IC'
	$statementCode = 'SC'
	
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

#Loop through the file & convert
$emodbFiles = Get-ChildItem -Path $emodbFolder -Filter *.wav
foreach ($emodbFile in $emodbFiles) {
    $convertedFilename = Convert-EmoDBToRAVDESS -emodbFilename $emodbFile.BaseName
    if ($convertedFilename -ne $null) {
        $destinationPath = Join-Path -Path $renamedFilesFolder -ChildPath "$convertedFilename.wav"
        Copy-Item -Path $emodbFile.FullName -Destination $destinationPath
        Write-Host "EmoDB Filename: $($emodbFile.Name) -> RAVDESS Filename: $($convertedFilename).wav"
    }
}