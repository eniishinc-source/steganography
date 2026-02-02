Write-Host "Проверка истории архиваторов..." -ForegroundColor Cyan


$winrarPath = "HKCU:\Software\WinRAR\ArcHistory"
if (Test-Path $winrarPath) {
    Write-Host "n[WinRAR] История открытых архивов:" -ForegroundColor Green


    $keys = Get-ItemProperty $winrarPath


    foreach ($property in $keys.PSObject.Properties) {
        if ($property.Name -match "^[0-9]+$") { # WinRAR хранит историю в ключах "0", "1", "2"...
            $filePath = $property.Value


            if ($filePath -match ".(jpg|png|jpeg|bmp|mp4|avi|mp3|txt)$") {
                Write-Host "---------------------------------------------------"
                Write-Host "[!] ПОДОЗРИТЕЛЬНЫЙ ФАЙЛ В ИСТОРИИ: $filePath" -ForegroundColor Red
                Write-Host "(!) Картинки/Видео не должны открываться через WinRAR!" -ForegroundColor Yellow
            } else {
                Write-Host "   $filePath" -ForegroundColor Gray
            }
        }
    }
} else {
    Write-Host "n[WinRAR] История не найдена (возможно, не установлен или очищена)." -ForegroundColor DarkGray
}


$7zipPath = "HKCU:\Software\7-Zip\Compression"
if (Test-Path $7zipPath) {
    Write-Host "n[7-Zip] История (ArcHistory):" -ForegroundColor Green

    $prop = Get-ItemProperty $7zipPath -Name "ArcHistory" -ErrorAction SilentlyContinue
    if ($prop) {
        $historyBytes = $prop.ArcHistory

        $historyString = [System.Text.Encoding]::Unicode.GetString($historyBytes)
        # Разделяем по null-байтам
        $files = $historyString -split "0"

        foreach ($file in $files) {
            if (-not [string]::IsNullOrWhiteSpace($file)) {
                 if ($file -match ".(jpg|png|jpeg|bmp|mp4|avi|mp3|txt)$") {
                    Write-Host "---------------------------------------------------"
                    Write-Host "[!] ПОДОЗРИТЕЛЬНЫЙ ФАЙЛ В ИСТОРИИ: $file" -ForegroundColor Red
                } else {
                    Write-Host "   $file" -ForegroundColor Gray
                }
            }
        }
    }
}

Write-Host "`nГотово." -ForegroundColor Cyan
