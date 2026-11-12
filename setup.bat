@echo off
title Game Launcher Setup
cd /d "%~dp0"

REM ---------------------------------------------------------------
REM  ASCII-ONLY, NO BOM, CRLF. Do NOT add "chcp 65001" here:
REM  cmd.exe shifts its file pointer when the code page changes
REM  mid-parse and starts eating the beginnings of lines.
REM  All Russian text lives in _app\autodetect.ps1 (UTF-8 with BOM).
REM ---------------------------------------------------------------

echo Starting setup from: "%~dp0"

if not exist "_app\autodetect.ps1" goto :missing

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_app\autodetect.ps1" 2>"%~dp0_app\setup_error.txt"

if errorlevel 1 goto :failed
if not exist "_app\config.ini" goto :failed
exit /b 0

:missing
echo.
echo [ERROR] File not found: _app\autodetect.ps1
echo.
echo Rename autodetect.txt  -^>  autodetect.ps1
echo Rename launcher_app.txt -^>  launcher.ps1
echo Keep both .ps1 files in UTF-8 with BOM.
echo.
echo Files currently in _app:
dir /b "_app"
echo.
pause
exit /b 1

:failed
echo.
echo [ERROR] Setup did not create _app\config.ini
echo See _app\setup_error.txt for the PowerShell error text.
echo.
if exist "_app\setup_error.txt" type "_app\setup_error.txt"
echo.
echo Send this text to the person who gave you the launcher.
echo.
pause
exit /b 1
