@echo off
setlocal enabledelayedexpansion

set "rootFolder=C:\Users\bderr\Desktop\folder\projects\flutter\Freelance\spa_app\Assets"

PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "$pngFiles = Get-ChildItem -Path '%rootFolder%' -Recurse -Filter *.png; " ^
    "$pngCount = $pngFiles.Count; " ^
    "Write-Host 'Number of PNG files in %rootFolder% and its subfolders: $pngCount';"
pause
