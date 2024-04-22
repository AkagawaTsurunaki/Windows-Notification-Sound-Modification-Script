# Read event lables from JSON file.
function ReadEventLablesFromJsonFile {
    param ()
    $eventLablesJsonFilePath = '.\EventLables.json'
    $data = Get-Content -Path $eventLablesJsonFilePath -Raw -Encoding UTF8 | ConvertFrom-Json
    # Write-Host $eventLables.GetEnumerator()
    foreach ($app in $data) {
        foreach ($eventLable in $app.EventLables) {
            Write-Host $eventLable.zh
        }
    }
}

ReadEventLablesFromJsonFile

