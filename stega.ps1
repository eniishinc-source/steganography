$path = "$env:USERPROFILE"
Write-Host "Сканирование папки: $path" -ForegroundColor Cyan

if (-not (Test-Path $path)) {
    Write-Host "Папка не найдена!" -ForegroundColor Red
    exit
}


$files = Get-ChildItem -Path $path -Include .jpg,.png,.mp4,.txt -Recurse -ErrorAction SilentlyContinue

foreach ($file in $files) {
    try {
        # Читаем только первые и последние байты для скорости, или весь файл если он небольшой
        # Для надежности прочитаем весь файл (если он < 100 МБ)
        if ($file.Length -gt 100MB) { continue } 

        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
        $hexString = [System.BitConverter]::ToString($bytes)





        if ($hexString -match "52-61-72-21") {
             # Проверяем, не является ли файл просто архивом с неправильным расширением
             if ($bytes[0] -eq 0x52 -and $bytes[1] -eq 0x61) {
                  Write-Host "[?] Файл $($file.Name) является обычным RAR архивом (или начинается как он)" -ForegroundColor Gray
             } else {
                  Write-Host "---------------------------------------------------"
                  Write-Host "[!] ОБНАРУЖЕНА СТЕГАНОГРАФИЯ (RAR внутри): $($file.Name)" -ForegroundColor Red
                  Write-Host "Путь: $($file.FullName)" -ForegroundColor Yellow
                  Write-Host "Размер: $([math]::Round($file.Length / 1KB, 2)) KB"
             }
        }


        elseif ($hexString -match "50-4B-03-04") {
             if ($bytes[0] -eq 0x50 -and $bytes[1] -eq 0x4B) {
                  # Это обычный zip/docx/jar
             } else {
                  Write-Host "---------------------------------------------------"
                  Write-Host "[!] ОБНАРУЖЕНА СТЕГАНОГРАФИЯ (ZIP/EXE внутри): $($file.Name)" -ForegroundColor Red
                  Write-Host "Путь: $($file.FullName)" -ForegroundColor Yellow
                  Write-Host "Размер: $([math]::Round($file.Length / 1KB, 2)) KB"
             }
        }
    }
    catch {
        Write-Host "Ошибка доступа к файлу: $($file.Name)" -ForegroundColor DarkGray
    }
}

Write-Host "Готово." -ForegroundColor Cyan
