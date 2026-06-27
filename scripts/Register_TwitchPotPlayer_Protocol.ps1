$ErrorActionPreference = "Stop"

$PowerShell = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
$Launcher = Join-Path $PSScriptRoot "Open_Twitch_PotPlayer_Source.ps1"

if (-not (Test-Path -LiteralPath $PowerShell)) {
  throw "PowerShell was not found: $PowerShell"
}
if (-not (Test-Path -LiteralPath $Launcher)) {
  throw "Launcher was not found: $Launcher"
}

$base = "HKCU:\Software\Classes\twitchpotplayer"
$command = '"' + $PowerShell + '" -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $Launcher + '" "%1"'

New-Item -Path $base -Force | Out-Null
Set-Item -Path $base -Value "URL:Twitch PotPlayer Source Protocol"
New-ItemProperty -Path $base -Name "URL Protocol" -Value "" -PropertyType String -Force | Out-Null

New-Item -Path "$base\shell\open\command" -Force | Out-Null
Set-Item -Path "$base\shell\open\command" -Value $command

Write-Host "Registered twitchpotplayer:// protocol for the current user."
Write-Host $command
