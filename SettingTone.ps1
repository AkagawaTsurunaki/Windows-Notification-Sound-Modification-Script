# Read event lables from JSON file.
function ReadEventLablesFromJsonFile {
    param ()
    $eventLablesJsonFilePath = '.\EventLables.json'
    if (Test-Path $eventLablesJsonFilePath) {
        return Get-Content -Path $eventLablesJsonFilePath -Raw -Encoding UTF8 | ConvertFrom-Json
    } else {
        throw [System.IO.FileNotFoundException] "$eventLablesJsonFilePath not found."
    }
}

function GetAllToneFilesInfo {
    param (
        [string]$toneFolderPath
    )
    $fileHashTable = @{}
    $toneFiles = Get-ChildItem -Path $toneFolderPath -Filter *.wav
    foreach ($toneFile in $toneFiles) {
        $toneFileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($toneFile.Name)
        $toneFileAbsPath = $toneFile.FullName
        $fileHashTable[$toneFileNameWithoutExtension] = $toneFileAbsPath
    }
    return $fileHashTable
}

function GetEventLable {
    param (
        [string]$lang,
        [string]$eventLable,
        $eventLables
    )
    foreach ($app in $eventLables) {
        foreach ($lable in $app.EventLables) {
            if ($lang -eq 'EN' -and $lable.EN -eq $eventLable) {
                return @{App=$app.App; id=$lable.ID}
            } elseif ($lang -eq 'ZH' -and $lable.ZH -eq $eventLable) {
                return @{App=$app.App; id=$lable.ID}
            }
        }
    } 
}

function CreateAppEventsSchemesNamesByPackageName {
    param (
        [string]$tonePackageName
    )
    $i = 0
    $path = ""
    [string]$pkgId = ""
    do {
        $pkgId = $tonePackageName.Substring(0, 5) + $i
        $path = "HKCU:\AppEvents\Schemes\Names\$pkgId"
        $i = $i + 1
    } while (
        Test-Path $path
    )

    $pkgId
    New-Item -Path $path
    New-ItemProperty -Path $path -Name "(Default)" -Value $tonePackageName -PropertyType "String"
    return
}

function SetTone {
    param (
        [string]$registryItem,
        [string]$toneFilePath
    )
    if (!(Test-Path $registryItem)) {
        New-Item -Path $registryItem
    }
    Set-ItemProperty -Path $registryItem -Name "(Default)" -Value $toneFilePath
    return Test-Path $registryItem
}

$eventLables = ReadEventLablesFromJsonFile

$toneFolderPath = Read-Host -Prompt "Please enter the path of the folder that stores tones"

$tonePackageName = Split-Path $toneFolderPath -Leaf
Write-Host "Package" $tonePackageName "found"

$TonePackageId = CreateAppEventsSchemesNamesByPackageName -tonePackageName $tonePackageName
$TonePackageId = $TonePackageId[0]

$allToneFilesInfo = GetAllToneFilesInfo -toneFolderPath $toneFolderPath
Write-Host $allToneFilesInfo.Keys.Count "tone file(s) found"

foreach ($toneFileName in $allToneFilesInfo.Keys) {
    $eventLable = GetEventLable -lang 'ZH' -eventLable $toneFileName -eventLables $eventLables
    if ($eventLable) {
        $registryItem = "HKCU:\AppEvents\Schemes\Apps\" + $eventLable.App +"\" + $eventLable.ID + "\" + $TonePackageId
        $toneFilePath = $allToneFilesInfo[$toneFileName]
        if (SetTone -registryItem $registryItem -toneFilePath $toneFilePath) {
            Write-Host "$registryItem was set as $toneFilePath"
        }
    }
}