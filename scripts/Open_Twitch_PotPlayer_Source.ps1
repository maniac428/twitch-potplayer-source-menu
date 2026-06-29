param(
  [string]$Target = "",
  [switch]$NoLaunch,
  [ValidateRange(2, 60)]
  [int]$ProxyTimeoutSec = 8,
  [switch]$SkipProxyCache
)

$ErrorActionPreference = "Stop"

$ClientId = "kimne78kx3ncx6brgo4mv6wki5h1ko"
$PlaybackAccessTokenHash = "ed230aa1e33e07eebb8928504583da78a5173989fadfb1ac94be06a04f3cdbe9"
$BuiltInProxyServers = @(
  "https://proxy5.rte.net.ru/",
  "https://proxy4.rte.net.ru/",
  "https://proxy7.rte.net.ru/",
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

function Normalize-ProxyUrl {
  param([string]$Proxy)

  if ([string]::IsNullOrWhiteSpace($Proxy)) {
    return ""
  }

  $clean = $Proxy.Trim()
  if ($clean -notmatch "^https?://") {
    $clean = "https://$clean"
  }
  if (-not $clean.EndsWith("/")) {
    $clean += "/"
  }

  return $clean
}

function Split-ProxyList {
  param([string]$Value)

  if ([string]::IsNullOrWhiteSpace($Value)) {
    return @()
  }

  return $Value -split "[,;`r`n]+" | ForEach-Object { $_.Trim() } | Where-Object { $_ }
}

function Get-ProxyCachePath {
  return (Join-Path $env:TEMP "TwitchSourceLauncher.proxy.json")
}

function Read-ProxyCache {
  if ($SkipProxyCache) {
    return @()
  }

  $path = Get-ProxyCachePath
  if (-not (Test-Path -LiteralPath $path)) {
    return @()
  }

  try {
    $cache = Get-Content -Raw -LiteralPath $path -Encoding UTF8 | ConvertFrom-Json
    $proxies = @()
    if ($cache.lastSuccessfulProxy) {
      $proxies += $cache.lastSuccessfulProxy
    }
    if ($cache.successfulProxies) {
      $proxies += @($cache.successfulProxies)
    }

    return $proxies
  } catch {
    return @()
  }
}

function Write-ProxyCache {
  param([string]$Proxy)

  if ($SkipProxyCache -or [string]::IsNullOrWhiteSpace($Proxy)) {
    return
  }

  try {
    $path = Get-ProxyCachePath
    $previous = @()
    if (Test-Path -LiteralPath $path) {
      $cache = Get-Content -Raw -LiteralPath $path -Encoding UTF8 | ConvertFrom-Json
      if ($cache.successfulProxies) {
        $previous += @($cache.successfulProxies)
      }
      if ($cache.lastSuccessfulProxy) {
        $previous += $cache.lastSuccessfulProxy
      }
    }

    $successfulProxies = @($Proxy) + $previous |
      ForEach-Object { Normalize-ProxyUrl $_ } |
      Where-Object { $_ } |
      Select-Object -Unique -First 8

    $payload = [pscustomobject]@{
      lastSuccessfulProxy = (Normalize-ProxyUrl $Proxy)
      successfulProxies = @($successfulProxies)
      updatedAt = (Get-Date).ToUniversalTime().ToString("o")
    }

    $payload | ConvertTo-Json -Depth 5 -Compress | Set-Content -LiteralPath $path -Encoding UTF8
  } catch {
  }
}

function Get-ProxyOverrides {
  $proxies = @()
  $proxies += @(Split-ProxyList $env:TWITCH_POTPLAYER_PROXIES)

  $candidateFiles = @()
  if ($PSScriptRoot) {
    $candidateFiles += (Join-Path $PSScriptRoot "proxies.txt")
    $parentPath = Split-Path -Parent $PSScriptRoot
    if ($parentPath) {
      $candidateFiles += (Join-Path $parentPath "proxies.txt")
    }
  }

  foreach ($path in $candidateFiles) {
    if (-not (Test-Path -LiteralPath $path)) {
      continue
    }

    try {
      $proxies += @(Split-ProxyList (Get-Content -Raw -LiteralPath $path -Encoding UTF8))
    } catch {
    }
  }

  return $proxies
}

function Get-OrderedProxyServers {
  $candidates = @()
  $candidates += @(Get-ProxyOverrides)
  $candidates += @(Read-ProxyCache)
  $candidates += @($BuiltInProxyServers)

  $seen = @{}
  $ordered = New-Object System.Collections.Generic.List[string]
  foreach ($proxy in $candidates) {
    $normalized = Normalize-ProxyUrl $proxy
    if (-not $normalized -or $seen.ContainsKey($normalized)) {
      continue
    }

    $seen[$normalized] = $true
    [void]$ordered.Add($normalized)
  }

  return $ordered.ToArray()
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

function Get-SafePlayerTitle {
  param([string]$Value)

  if ([string]::IsNullOrWhiteSpace($Value)) {
    return ""
  }

  $clean = $Value -replace "[\x00-\x1F\x7F]", " "
  $clean = $clean -replace '"', "'"
  $clean = $clean -replace "\\", "/"
  $clean = $clean -replace "[{}]", ""
  $clean = $clean -replace "\s+", " "
  $clean = $clean.Trim()

  if ($clean.Length -gt 180) {
    $clean = $clean.Substring(0, 180).Trim()
  }

  return $clean
}

function Get-TwitchPlayerTitle {
  param(
    [string]$Proxy,
    [string]$Channel,
    [hashtable]$Headers,
    [int]$TimeoutSec
  )

  try {
    $bodyObject = @{
      operationName = "GetStreamTitle"
      query = 'query GetStreamTitle($login: String!) { user(login: $login) { displayName stream { title game { name } } } }'
      variables = @{
        login = $Channel
      }
    }
    $body = $bodyObject | ConvertTo-Json -Depth 20 -Compress

    $response = Invoke-RestMethod `
      -Method Post `
      -Uri ($Proxy + "https://gql.twitch.tv/gql") `
      -Headers $Headers `
      -Body $body `
      -ContentType "application/json" `
      -TimeoutSec $TimeoutSec

    $user = $response.data.user
    if (-not $user) {
      return $Channel
    }

    $displayName = Get-SafePlayerTitle $user.displayName
    if (-not $displayName) {
      $displayName = $Channel
    }

    $streamTitle = Get-SafePlayerTitle $user.stream.title
    if ($streamTitle) {
      return (Get-SafePlayerTitle ($displayName + " - " + $streamTitle))
    }

    return $displayName
  } catch {
    Write-LauncherLog ("Failed to fetch stream title. Error=" + $_.Exception.Message)
    return $Channel
  }
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
$proxyServers = Get-OrderedProxyServers
if ($proxyServers.Count -eq 0) {
  throw "No proxy servers were configured."
}

Write-LauncherLog "Target=$Target Channel=$channel NoLaunch=$NoLaunch ProxyTimeoutSec=$ProxyTimeoutSec ProxyCount=$($proxyServers.Count)"

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

foreach ($proxy in $proxyServers) {
  try {
    Write-Host ("Trying proxy ({0}s timeout): {1}" -f $ProxyTimeoutSec, $proxy)
    Write-LauncherLog "Trying proxy=$proxy TimeoutSec=$ProxyTimeoutSec"

    $tokenResponse = Invoke-RestMethod `
      -Method Post `
      -Uri ($proxy + "https://gql.twitch.tv/gql") `
      -Headers $headers `
      -Body $body `
      -ContentType "application/json" `
      -TimeoutSec $ProxyTimeoutSec

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
      -UseBasicParsing `
      -TimeoutSec $ProxyTimeoutSec

    $playlist = Get-TextFromWebResponse $playlistResponse
    $variant = Get-SourceVariantUrl $playlist

    Write-Host ("Selected: " + $variant.Info)
    Write-LauncherLog ("Selected=" + $variant.Info)
    Write-LauncherLog ("SelectedUrl=" + $variant.Url)
    Write-ProxyCache $proxy
    $playerTitle = Get-TwitchPlayerTitle -Proxy $proxy -Channel $channel -Headers $headers -TimeoutSec $ProxyTimeoutSec
    Write-Host ("Player title: " + $playerTitle)
    Write-LauncherLog ("PlayerTitle=" + $playerTitle)

    if ($NoLaunch) {
      Write-Host ("NO_LAUNCH_SELECTED: " + $variant.Info)
      Write-Host ("NO_LAUNCH_URL: " + $variant.Url)
      Write-Host ("NO_LAUNCH_TITLE: " + $playerTitle)
      exit 0
    }

    Write-Host "Opening via Streamlink..."
    $streamlinkArgs = '--title "' + $playerTitle + '" --player-continuous-http --retry-open 5 --retry-streams 2 --retry-max 3 --hls-live-edge 8 --stream-segment-threads 3 --stream-segment-attempts 10 --stream-segment-timeout 15 --stream-timeout 60 --http-timeout 20 --ringbuffer-size 128M --player "' + $potPlayer + '" "' + ("hls://" + $variant.Url) + '" best'
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
