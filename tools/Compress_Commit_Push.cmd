@echo off
setlocal enabledelayedexpansion

REM Go to repo root (tools -> root)
cd /d "%~dp0\.."

REM Run compressor (stages images/)
powershell -ExecutionPolicy Bypass -File "tools\compress_images.ps1"
if errorlevel 1 (
  echo Compression failed.
  pause
  exit /b 1
)

REM Stage any other changes you want included (optional)
git add index.html recipes.json sw.js >nul 2>&1

echo.
git status
echo.

set /p MSG="Commit message (blank = 'Add/update recipe photos'): "
if "%MSG%"=="" set MSG=Add/update recipe photos

git commit -m "%MSG%"
if errorlevel 1 (
  echo Commit failed (maybe nothing to commit).
  pause
  exit /b 1
)

git push
if errorlevel 1 (
  echo Push failed.
  pause
  exit /b 1
)

echo.
echo Done!
pause
