@echo off
setlocal EnableExtensions

set "ROOT=%~dp0"
set "REGISTER=%ROOT%scripts\Register_TwitchPotPlayer_Protocol.ps1"
set "USERJS=%ROOT%twitch-potplayer-source-menu.user.js"

echo Twitch PotPlayer 720p Fix installer
echo.

if not exist "%REGISTER%" (
  echo [ERROR] Missing: %REGISTER%
  echo Download the full repository again and retry.
  echo.
  pause
  exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%REGISTER%"
if errorlevel 1 (
  echo.
  echo [ERROR] Failed to register twitchpotplayer:// protocol.
  echo Try running this file again, or check Windows security settings.
  echo.
  pause
  exit /b 1
)

echo.
echo Checking prerequisites...
echo.

set "POTPLAYER_FOUND="
where PotPlayerMini64.exe >nul 2>nul && set "POTPLAYER_FOUND=1"
where PotPlayer64.exe >nul 2>nul && set "POTPLAYER_FOUND=1"
if exist "%ProgramFiles%\DAUM\PotPlayer\PotPlayerMini64.exe" set "POTPLAYER_FOUND=1"
if exist "%ProgramFiles%\DAUM\PotPlayer\PotPlayer64.exe" set "POTPLAYER_FOUND=1"
if exist "%ProgramFiles(x86)%\DAUM\PotPlayer\PotPlayerMini64.exe" set "POTPLAYER_FOUND=1"
if exist "%ProgramFiles(x86)%\DAUM\PotPlayer\PotPlayer64.exe" set "POTPLAYER_FOUND=1"

if defined POTPLAYER_FOUND (
  echo [OK] PotPlayer 64-bit found.
) else (
  echo [MISSING] PotPlayer 64-bit was not found.
  echo           Install PotPlayer 64-bit first.
)

set "STREAMLINK_FOUND="
where streamlink.exe >nul 2>nul && set "STREAMLINK_FOUND=1"
if exist "%LocalAppData%\Programs\Streamlink\bin\streamlink.exe" set "STREAMLINK_FOUND=1"
if exist "%ProgramFiles%\Streamlink\bin\streamlink.exe" set "STREAMLINK_FOUND=1"
if exist "%ProgramFiles(x86)%\Streamlink\bin\streamlink.exe" set "STREAMLINK_FOUND=1"

if defined STREAMLINK_FOUND (
  echo [OK] Streamlink found.
) else (
  echo [MISSING] Streamlink was not found.
  echo           Install Streamlink: https://streamlink.github.io/install.html
)

if exist "%USERJS%" (
  echo [OK] Tampermonkey userscript file found.
) else (
  echo [MISSING] Tampermonkey userscript file was not found.
)

echo.
echo Next step:
echo 1. Install Tampermonkey in Chrome.
echo 2. Add this userscript to Tampermonkey:
echo    %USERJS%
echo 3. On Twitch, right-click and choose "Open in PotPlayer source quality".
echo.
pause
