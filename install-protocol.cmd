@echo off
setlocal

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Register_TwitchPotPlayer_Protocol.ps1"
echo.
echo Done. You can close this window.
pause
