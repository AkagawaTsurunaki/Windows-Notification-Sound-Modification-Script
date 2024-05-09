<#
Author: AkagawaTsurunaki
#>

function ReadEventLabelsFromJsonFile {
    param ()
    $eventLabelsJsonFilePath = '.\EventLabels.json'
    if (Test-Path $eventLabelsJsonFilePath) {
        return Get-Content -Path $eventLabelsJsonFilePath -Raw -Encoding UTF8 | ConvertFrom-Json
    } else {
        throw [System.IO.FileNotFoundException] "$eventLabelsJsonFilePath not found."
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

function GetEventLabel {
    param (
        [string]$lang,
        [string]$eventLabel,
        $eventLabels
    )
    foreach ($app in $eventLabels) {
        foreach ($label in $app.EventLabels) {
            if ($lang -eq 'EN' -and $label.EN -eq $eventLabel) {
                return @{App=$app.App; id=$label.ID}
            } elseif ($lang -eq 'ZH' -and $label.ZH -eq $eventLabel) {
                return @{App=$app.App; id=$label.ID}
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

$eventLabels = ReadEventLabelsFromJsonFile

$toneFolderPath = Read-Host -Prompt "Please enter the path of the folder that stores notification sounds"

$tonePackageName = Split-Path $toneFolderPath -Leaf
Write-Host "Tone package" $tonePackageName "found"

$TonePackageId = CreateAppEventsSchemesNamesByPackageName -tonePackageName $tonePackageName
$TonePackageId = $TonePackageId[0]

$allToneFilesInfo = GetAllToneFilesInfo -toneFolderPath $toneFolderPath
Write-Host $allToneFilesInfo.Keys.Count "tone file(s) found"

foreach ($toneFileName in $allToneFilesInfo.Keys) {
    $eventLabel = GetEventLabel -lang 'ZH' -eventLabel $toneFileName -eventLabels $eventLabels
    if ($eventLabel) {
        $registryItem = "HKCU:\AppEvents\Schemes\Apps\" + $eventLabel.App +"\" + $eventLabel.ID + "\" + $TonePackageId
        $toneFilePath = $allToneFilesInfo[$toneFileName]
        if (SetTone -registryItem $registryItem -toneFilePath $toneFilePath) {
            Write-Host "Set $registryItem to $toneFilePath"
        }
    }
}

Write-Host "Notification sound package $tonePackageName has been registered in your system successfully"
Write-Host "Note: You need to REBOOT your computer to make effect."
Read-Host "Press any key to exit..."