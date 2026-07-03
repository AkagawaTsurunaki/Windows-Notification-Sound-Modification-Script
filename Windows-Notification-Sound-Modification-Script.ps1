<#
Author: AkagawaTsurunaki
#>

function NormalizeEventName {
    param (
        [string]$eventName
    )

    if ($null -eq $eventName) {
        return ''
    }

    return ($eventName.Trim().ToLowerInvariant() -replace '[\s　]', '')
}

function GetToneFileNameCandidates {
    param (
        [string]$toneFileName
    )

    $candidates = [System.Collections.Generic.List[string]]::new()
    $baseName = $toneFileName.Trim()
    $nameWithoutAnnotation = ($baseName -replace '[（(].*?[）)]', '').Trim()
    $nameBeforeAnnotation = ($baseName -split '[（(]', 2)[0].Trim()

    foreach ($candidate in @($baseName, $nameWithoutAnnotation, $nameBeforeAnnotation)) {
        if (![string]::IsNullOrWhiteSpace($candidate) -and !$candidates.Contains($candidate)) {
            $candidates.Add($candidate)
        }
    }

    return $candidates
}

function ReadEventLabelsFromJsonFile {
    param ()
    $eventLabelsJsonFilePath = Join-Path $PSScriptRoot 'EventLabels.json'
    if (Test-Path -LiteralPath $eventLabelsJsonFilePath) {
        return Get-Content -LiteralPath $eventLabelsJsonFilePath -Raw -Encoding UTF8 | ConvertFrom-Json
    } else {
        throw [System.IO.FileNotFoundException]::new("未找到事件标签配置文件：$eventLabelsJsonFilePath")
    }
}

function GetAllToneFilesInfo {
    param (
        [string]$toneFolderPath
    )
    $fileHashTable = @{}
    $toneFiles = Get-ChildItem -LiteralPath $toneFolderPath -Filter *.wav -File
    foreach ($toneFile in $toneFiles) {
        $toneFileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($toneFile.Name)
        $toneFileAbsPath = $toneFile.FullName
        $fileHashTable[$toneFileNameWithoutExtension] = $toneFileAbsPath
    }
    return $fileHashTable
}

function NewEventLabelLookup {
    param (
        $eventLabels
    )

    $lookup = @{}
    foreach ($app in $eventLabels) {
        foreach ($label in $app.EventLabels) {
            foreach ($name in @($label.ZH, $label.EN, $label.ID)) {
                $key = NormalizeEventName -eventName $name
                if (![string]::IsNullOrWhiteSpace($key) -and !$lookup.ContainsKey($key)) {
                    $lookup[$key] = @{ App = $app.App; id = $label.ID; ZH = $label.ZH; EN = $label.EN }
                }
            }
        }
    }

    return $lookup
}

function GetEventLabel {
    param (
        [string]$toneFileName,
        $eventLabelLookup
    )

    foreach ($candidate in (GetToneFileNameCandidates -toneFileName $toneFileName)) {
        $key = NormalizeEventName -eventName $candidate
        if ($eventLabelLookup.ContainsKey($key)) {
            return $eventLabelLookup[$key]
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
        if ($tonePackageName.Length -ge 5) {
            $pkgId = $tonePackageName.Substring(0, 5) + $i
        } else {
            $pkgId = $tonePackageName + $i
        }
        $path = "HKCU:\AppEvents\Schemes\Names\$pkgId"
        $i = $i + 1
    } while (
        Test-Path -LiteralPath $path
    )

    New-Item -Path $path -Force | Out-Null
    New-ItemProperty -Path $path -Name "(Default)" -Value $tonePackageName -PropertyType "String" -Force | Out-Null
    return $pkgId
}

function SetTone {
    param (
        [string]$registryItem,
        [string]$currentRegistryItem,
        [string]$toneFilePath
    )
    if (!(Test-Path -LiteralPath $registryItem)) {
        New-Item -Path $registryItem -Force | Out-Null
    }
    if (!(Test-Path -LiteralPath $currentRegistryItem)) {
        New-Item -Path $currentRegistryItem -Force | Out-Null
    }

    Set-ItemProperty -Path $registryItem -Name "(Default)" -Value $toneFilePath
    Set-ItemProperty -Path $currentRegistryItem -Name "(Default)" -Value $toneFilePath
    return (Test-Path -LiteralPath $registryItem) -and (Test-Path -LiteralPath $currentRegistryItem)
}

try {
    $eventLabels = ReadEventLabelsFromJsonFile
    $eventLabelLookup = NewEventLabelLookup -eventLabels $eventLabels

    do {
        $toneFolderPath = Read-Host -Prompt "请输入存放提示音 .wav 文件的文件夹路径"
        $toneFolderPath = $toneFolderPath.Trim('"')
        if ([string]::IsNullOrWhiteSpace($toneFolderPath)) {
            Write-Host "路径不能为空，请重新输入。" -ForegroundColor Yellow
            continue
        }
        if (!(Test-Path -LiteralPath $toneFolderPath -PathType Container)) {
            Write-Host "未找到该文件夹：$toneFolderPath" -ForegroundColor Yellow
            continue
        }
        break
    } while ($true)

    $tonePackageName = Split-Path $toneFolderPath -Leaf
    Write-Host "已找到提示音包：$tonePackageName"

    $TonePackageId = CreateAppEventsSchemesNamesByPackageName -tonePackageName $tonePackageName

    $allToneFilesInfo = GetAllToneFilesInfo -toneFolderPath $toneFolderPath
    Write-Host "已找到 $($allToneFilesInfo.Keys.Count) 个 .wav 提示音文件。"

    if ($allToneFilesInfo.Keys.Count -eq 0) {
        throw "指定文件夹中没有 .wav 文件，请检查后重新运行。"
    }

    $setCount = 0
    $skippedCount = 0
    $unmatchedCount = 0
    $matchedRegistryItems = @{}

    foreach ($toneFileName in ($allToneFilesInfo.Keys | Sort-Object)) {
        $eventLabel = GetEventLabel -toneFileName $toneFileName -eventLabelLookup $eventLabelLookup
        if ($eventLabel) {
            $registryItem = 'HKCU:\AppEvents\Schemes\Apps\{0}\{1}\{2}' -f $eventLabel.App, $eventLabel.id, $TonePackageId
            $currentRegistryItem = 'HKCU:\AppEvents\Schemes\Apps\{0}\{1}\.Current' -f $eventLabel.App, $eventLabel.id

            if ($matchedRegistryItems.ContainsKey($currentRegistryItem)) {
                Write-Host "已跳过：$toneFileName 与已设置的 $($matchedRegistryItems[$currentRegistryItem]) 对应同一个系统事件。" -ForegroundColor DarkYellow
                $skippedCount++
                continue
            }

            $toneFilePath = $allToneFilesInfo[$toneFileName]
            if (SetTone -registryItem $registryItem -currentRegistryItem $currentRegistryItem -toneFilePath $toneFilePath) {
                Write-Host "已设置：$($eventLabel.ZH) -> $toneFilePath"
                $matchedRegistryItems[$currentRegistryItem] = $toneFileName
                $setCount++
            }
        } else {
            Write-Host "未匹配：$toneFileName" -ForegroundColor DarkYellow
            $unmatchedCount++
        }
    }

    if ($setCount -eq 0) {
        Write-Host "没有匹配到可设置的系统事件。请确认 .wav 文件名与 EventLabels.json 中的事件名称一致。" -ForegroundColor Yellow
    } else {
        Write-Host "提示音包 $tonePackageName 已成功注册到系统，并已写入当前声音设置。"
        Write-Host "已设置 $setCount 个事件，跳过 $skippedCount 个重复事件，未匹配 $unmatchedCount 个文件。"
        Write-Host "提示：如果控制面板没有立刻刷新，请关闭并重新打开“声音”设置；必要时注销或重启后生效。"
    }
} catch {
    Write-Host "运行失败：$($_.Exception.Message)" -ForegroundColor Red
    Write-Host "窗口不会自动关闭，请根据上面的提示检查文件或路径。" -ForegroundColor Yellow
} finally {
    Read-Host "按 Enter 键退出"
}
