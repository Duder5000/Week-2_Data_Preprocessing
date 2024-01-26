#Convert EmoDB file names to RAVDESS style
function Convert-EmoDBToRAVDESS {
    param (
        [string]$emodbFilename
    )

	#Get info from EmoDB file name
	$speakerNumber = $emodbFilename.Substring(0, 2)
	$textCode = $emodbFilename.Substring(2, 3)
	$emotionCode = $emodbFilename.Substring(5, 1)

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
		$ravdessFilename = "{0}-01-{1}-01-{2}-01-{3}" -f $ravdessEmotionCode, $speakerNumber, $textCode, $ravdessEmotionCode
		return $ravdessFilename
	} else {
		throw "Unsupported emotion code: $emotionCode"
	}
}

#Target folder
$emodbFolder = "G:\DBs to Merge\EmoDB"

#Loop through the file & convert
$emodbFiles = Get-ChildItem -Path $emodbFolder -Filter *.wav
foreach ($emodbFile in $emodbFiles) {
    $convertedFilename = Convert-EmoDBToRAVDESS -emodbFilename $emodbFile.BaseName
    if ($convertedFilename -ne $null) {
        $newFilePath = Join-Path -Path $emodbFolder -ChildPath "$convertedFilename.wav"
        Rename-Item -Path $emodbFile.FullName -NewName $newFilePath
        Write-Host "EmoDB Filename: $($emodbFile.Name) -> RAVDESS Filename: $($convertedFilename).wav"
    }
}
