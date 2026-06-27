param(
  [string]$Target = "",
  [switch]$NoLaunch
)

$ErrorActionPreference = "Stop"

$ClientId = "kimne78kx3ncx6brgo4mv6wki5h1ko"
$PlaybackAccessTokenHash = "ed230aa1e33e07eebb8928504583da78a5173989fadfb1ac94be06a04f3cdbe9"
$ProxyServers = @(
  "https://proxy4.rte.net.ru/",
  "https://proxy7.rte.net.ru/",
  "https://proxy5.rte.net.ru/",
  "https://proxy6.rte.net.ru/"
)

function Write-LauncherLog([string]$Message) {
  try {
    $line = "{0} {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -LiteralPath (Join-Path $env:TEMP "TwitchSourceLauncher.log") -Value $line -Encoding UTF8
  } catch {
  }
}

function Find-FirstExistingPath([string[]]$Paths) {
  foreach ($path in $Paths) {
    if ($path -and (Test-Path -LiteralPath $path)) {
      return $path
    }
  }

  return ""
}

function Find-CommandPath([string]$Name) {
  $command = Get-Command $Name -ErrorAction SilentlyContinue
  if ($command) {
    return $command.Source
  }

  return ""
}

function Get-PotPlayerPath {
  $fromCommand = Find-CommandPath "PotPlayerMini64.exe"
  if ($fromCommand) { return $fromCommand }

  $fromCommand = Find-CommandPath "PotPlayer64.exe"
  if ($fromCommand) { return $fromCommand }

  return Find-FirstExistingPath @(
    "$env:ProgramFiles\DAUM\PotPlayer\PotPlayerMini64.exe",
    "$env:ProgramFiles\DAUM\PotPlayer\PotPlayer64.exe",
    "${env:ProgramFiles(x86)}\DAUM\PotPlayer\PotPlayerMini64.exe",
    "${env:ProgramFiles(x86)}\DAUM\PotPlayer\PotPlayer64.exe"
  )
}

function Get-StreamlinkPath {
  $fromCommand = Find-CommandPath "streamlink.exe"
  if ($fromCommand) { return $fromCommand }

  return Find-FirstExistingPath @(
    "$env:LocalAppData\Programs\Streamlink\bin\streamlink.exe",
    "$env:ProgramFiles\Streamlink\bin\streamlink.exe",
    "${env:ProgramFiles(x86)}\Streamlink\bin\streamlink.exe"
  )
}

function Get-ChannelName {
  param([string]$Value)

  $clean = $Value.Trim()
  if ($clean -match "^twitchpotplayer:") {
    try {
      $uri = [uri]$clean
      $query = $uri.Query.TrimStart("?")
      foreach ($pair in ($query -split "&")) {
        if (-not $pair) { continue }

        $parts = $pair -split "=", 2
        if ($parts.Count -ne 2) { continue }

        $key = [uri]::UnescapeDataString($parts[0])
        $value = [uri]::UnescapeDataString($parts[1])
        if ($key -in @("target", "url", "channel")) {
          $clean = $value.Trim()
          break
        }
      }
    } catch {
      throw "Invalid twitchpotplayer URL: $clean"
    }
  }

  if ($clean -match "twitch\.tv/([^/?#]+)") {
    $candidate = $Matches[1].ToLowerInvariant()
    if ($candidate -match "^[a-z0-9_]{2,25}$") {
      return $candidate
    }
    return ""
  }

  $candidate = $clean.TrimStart("@").ToLowerInvariant()
  if ($candidate -match "^[a-z0-9_]{2,25}$") {
    return $candidate
  }

  return ""
}

function Get-TextFromWebResponse {
  param($Response)

  if ($Response.Content -is [byte[]]) {
    return [System.Text.Encoding]::UTF8.GetString($Response.Content)
  }

  return [string]$Response.Content
}

function Get-VariantScore {
  param([string]$Info)

  $height = 0
  $bandwidth = 0

  if ($Info -match "RESOLUTION=\d+x(\d+)") {
    $height = [int]$Matches[1]
  }
  if ($Info -match "BANDWIDTH=(\d+)") {
    $bandwidth = [int]$Matches[1]
  }

  return ($height * 1000000000) + $bandwidth
}

function Get-SourceVariantUrl {
  param([string]$Playlist)

  $lines = $Playlist -split "`r?`n"
  $variants = New-Object System.Collections.Generic.List[object]

  for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i].Trim()
    if (-not $line.StartsWith("#EXT-X-STREAM-INF:")) {
      continue
    }

    $url = ""
    for ($j = $i + 1; $j -lt $lines.Count; $j++) {
      $candidate = $lines[$j].Trim()
      if ($candidate -and -not $candidate.StartsWith("#")) {
        $url = $candidate
        break
      }
    }

    if (-not $url) { continue }

    $variants.Add([pscustomobject]@{
      Info = $line
      Url = $url
      IsSource = $line -match 'IVS-VARIANT-SOURCE="source"'
      Score = Get-VariantScore $line
    })
  }

  if ($variants.Count -eq 0) {
    throw "No playable HLS variants were found."
  }

  $source = $variants | Where-Object { $_.IsSource } | Sort-Object Score -Descending | Select-Object -First 1
  if ($source) { return $source }

  return $variants | Sort-Object Score -Descending | Select-Object -First 1
}

if ([string]::IsNullOrWhiteSpace($Target)) {
  $Target = Read-Host "Paste Twitch channel name or URL"
}

$potPlayer = Get-PotPlayerPath
if (-not $potPlayer) {
  throw "PotPlayer was not found. Install PotPlayer first."
}

$streamlink = Get-StreamlinkPath
if (-not $streamlink) {
  throw "Streamlink was not found. Install Streamlink first: https://streamlink.github.io/install.html"
}

$channel = Get-ChannelName $Target
if ([string]::IsNullOrWhiteSpace($channel)) {
  throw "No valid Twitch channel was provided. Target was: $Target"
}

Write-Host "Target channel: $channel"
Write-LauncherLog "Target=$Target Channel=$channel NoLaunch=$NoLaunch"

$headers = @{
  "Client-ID" = $ClientId
  "User-Agent" = "Mozilla/5.0"
}

$bodyObject = @{
  operationName = "PlaybackAccessToken"
  extensions = @{
    persistedQuery = @{
      version = 1
      sha256Hash = $PlaybackAccessTokenHash
    }
  }
  variables = @{
    isLive = $true
    login = $channel
    isVod = $false
    vodID = ""
    playerType = "embed"
    platform = "site"
  }
}

$body = $bodyObject | ConvertTo-Json -Depth 20 -Compress
$lastError = $null

foreach ($proxy in $ProxyServers) {
  try {
    Write-Host "Trying proxy: $proxy"
    Write-LauncherLog "Trying proxy=$proxy"

    $tokenResponse = Invoke-RestMethod `
      -Method Post `
      -Uri ($proxy + "https://gql.twitch.tv/gql") `
      -Headers $headers `
      -Body $body `
      -ContentType "application/json"

    $accessToken = $tokenResponse.data.streamPlaybackAccessToken
    if (-not $accessToken -or -not $accessToken.value -or -not $accessToken.signature) {
      throw "PlaybackAccessToken was not returned."
    }

    $tokenJson = $accessToken.value | ConvertFrom-Json
    Write-Host ("Token maximum resolution: " + $tokenJson.maximum_resolution)

    $token = [uri]::EscapeDataString($accessToken.value)
    $sig = [uri]::EscapeDataString($accessToken.signature)
    $p = Get-Random -Minimum 100000 -Maximum 999999

    $usherUrl = "https://usher.ttvnw.net/api/v2/channel/hls/$channel.m3u8?platform=web&p=$p&allow_source=true&allow_audio_only=true&playlist_include_framerate=true&supported_codecs=h264,h265,av1&fast_bread=true&sig=$sig&token=$token"
    $playlistResponse = Invoke-WebRequest `
      -Uri ($proxy + $usherUrl) `
      -Headers @{ "User-Agent" = "Mozilla/5.0" } `
      -UseBasicParsing

    $playlist = Get-TextFromWebResponse $playlistResponse
    $variant = Get-SourceVariantUrl $playlist

    Write-Host ("Selected: " + $variant.Info)
    Write-LauncherLog ("Selected=" + $variant.Info)
    Write-LauncherLog ("SelectedUrl=" + $variant.Url)

    if ($NoLaunch) {
      Write-Host ("NO_LAUNCH_SELECTED: " + $variant.Info)
      Write-Host ("NO_LAUNCH_URL: " + $variant.Url)
      exit 0
    }

    Write-Host "Opening via Streamlink pipe..."
    $streamlinkArgs = '--player "' + $potPlayer + '" "' + ("hls://" + $variant.Url) + '" best'
    Write-LauncherLog ("StreamlinkArgs=" + $streamlinkArgs)
    Start-Process -FilePath $streamlink -ArgumentList $streamlinkArgs -WindowStyle Hidden
    exit 0
  } catch {
    $lastError = $_
    Write-LauncherLog ("Failed proxy=" + $proxy + " Error=" + $_.Exception.Message)
    Write-Warning ("Failed via " + $proxy + ": " + $_.Exception.Message)
  }
}

Write-LauncherLog ("All proxies failed. LastError=" + $lastError)
throw "All proxies failed. Last error: $lastError"
