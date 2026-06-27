@echo off
setlocal EnableExtensions

set "ROOT=%~dp0"
set "LAUNCHER=%ROOT%scripts\Open_Twitch_PotPlayer_Source.ps1"
set "TARGET=%~1"

if not exist "%LAUNCHER%" (
  echo [ERROR] Missing: %LAUNCHER%
  echo Download the full repository ZIP and retry.
  echo.
  pause
  exit /b 1
)

if "%TARGET%"=="" (
  echo Paste a Twitch channel name or URL.
  echo Example: https://www.twitch.tv/aceu
  echo.
  set /p "TARGET=Twitch: "
)

if "%TARGET%"=="" (
  echo [ERROR] No Twitch channel or URL was provided.
  echo.
  pause
  exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%LAUNCHER%" -Target "%TARGET%"
if errorlevel 1 (
  echo.
  echo [ERROR] Failed to open Twitch source quality in PotPlayer.
  echo Check whether the channel is live, and make sure PotPlayer 64-bit and Streamlink are installed.
  echo.
  pause
  exit /b 1
)

exit /b 0
