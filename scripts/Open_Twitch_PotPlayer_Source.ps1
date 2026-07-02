param(
  [string]$Target = "",
  [switch]$NoLaunch,
  [ValidateRange(2, 60)]
  [int]$ProxyTimeoutSec = 8,
  [switch]$SkipProxyCache,
  [switch]$DisableCdnAutoSelect,
  [ValidateRange(1, 3)]
  [int]$CdnTestSegments = 1,
  [ValidateRange(2, 20)]
  [int]$CdnTestTimeoutSec = 3,
  [ValidateRange(8, 100)]
  [double]$CdnEarlyAcceptMbps = 14,
  [ValidateRange(3, 15)]
  [int]$CdnStreamTestSec = 6,
  [string]$CdnAvoidPattern = "^euw"
)

$ErrorActionPreference = "Stop"

$ClientId = "kimne78kx3ncx6brgo4mv6wki5h1ko"
$PlaybackAccessTokenHash = "ed230aa1e33e07eebb8928504583da78a5173989fadfb1ac94be06a04f3cdbe9"
$BuiltInProxyServers = @(
  "https://proxy6.rte.net.ru/",
  "https://proxy7.rte.net.ru/",
  "https://proxy5.rte.net.ru/",
  "https://proxy4.rte.net.ru/"
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

function Get-Utf8TextFromWebResponse {
  param($Response)

  if ($Response.RawContentStream) {
    $Response.RawContentStream.Position = 0
    $reader = New-Object System.IO.StreamReader($Response.RawContentStream, [System.Text.Encoding]::UTF8, $true)
    try {
      return $reader.ReadToEnd()
    } finally {
      $reader.Dispose()
    }
  }

  return Get-TextFromWebResponse $Response
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

function Get-CdnHostFromUrl {
  param([string]$Url)

  try {
    return ([uri]$Url).Host
  } catch {
    return ""
  }
}

function Resolve-HlsUrl {
  param(
    [string]$BaseUrl,
    [string]$Line
  )

  try {
    $base = [uri]$BaseUrl
    return ([uri]::new($base, $Line)).AbsoluteUri
  } catch {
    return $Line
  }
}

function Get-ContentByteLength {
  param($Content)

  if ($Content -is [byte[]]) {
    return [int64]$Content.Length
  }

  return [int64][System.Text.Encoding]::UTF8.GetByteCount([string]$Content)
}

function Measure-UrlPrefix {
  param(
    [string]$Url,
    [int]$TimeoutSec,
    [int]$MaxBytes = 1048576
  )

  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  $response = $null
  $stream = $null
  try {
    $request = [System.Net.HttpWebRequest]::Create($Url)
    $request.Method = "GET"
    $request.UserAgent = "Mozilla/5.0"
    $request.Timeout = $TimeoutSec * 1000
    $request.ReadWriteTimeout = $TimeoutSec * 1000
    try {
      $request.AddRange(0, $MaxBytes - 1)
    } catch {
    }

    $response = $request.GetResponse()
    $stream = $response.GetResponseStream()
    $buffer = New-Object byte[] 65536
    $totalBytes = [int64]0

    while ($totalBytes -lt $MaxBytes) {
      $remaining = [Math]::Min($buffer.Length, $MaxBytes - $totalBytes)
      $read = $stream.Read($buffer, 0, $remaining)
      if ($read -le 0) { break }
      $totalBytes += $read
    }

    $elapsed = [Math]::Max($sw.Elapsed.TotalSeconds, 0.001)
    return [pscustomobject]@{
      Ok = $true
      Mbps = [Math]::Round(($totalBytes * 8 / 1000000 / $elapsed), 2)
      Seconds = [Math]::Round($elapsed, 2)
      Bytes = $totalBytes
      Error = ""
    }
  } catch {
    return [pscustomobject]@{
      Ok = $false
      Mbps = 0
      Seconds = [Math]::Round($sw.Elapsed.TotalSeconds, 2)
      Bytes = 0
      Error = $_.Exception.Message
    }
  } finally {
    if ($stream) { $stream.Dispose() }
    if ($response) { $response.Dispose() }
  }
}

function Test-HlsCdnCandidate {
  param(
    [string]$Url,
    [int]$TimeoutSec,
    [int]$SegmentCount
  )

  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  try {
    $playlistResponse = Invoke-WebRequest `
      -Uri $Url `
      -Headers @{ "User-Agent" = "Mozilla/5.0" } `
      -UseBasicParsing `
      -TimeoutSec $TimeoutSec

    $playlist = Get-TextFromWebResponse $playlistResponse
    $segmentLines = @()
    foreach ($line in ($playlist -split "`r?`n")) {
      $clean = $line.Trim()
      if (-not $clean -or $clean.StartsWith("#")) { continue }
      $segmentLines += $clean
    }

    if ($segmentLines.Count -eq 0) {
      throw "No media segments were found."
    }

    $testedSegments = 0
    $totalBytes = [int64]0
    $elapsedSeconds = [double]0
    foreach ($segmentLine in ($segmentLines | Select-Object -First $SegmentCount)) {
      $segmentUrl = Resolve-HlsUrl -BaseUrl $Url -Line $segmentLine
      $probe = Measure-UrlPrefix -Url $segmentUrl -TimeoutSec $TimeoutSec
      if (-not $probe.Ok) {
        throw $probe.Error
      }
      $totalBytes += $probe.Bytes
      $elapsedSeconds += $probe.Seconds
      $testedSegments += 1
    }

    $elapsed = [Math]::Max($elapsedSeconds, 0.001)
    return [pscustomobject]@{
      Ok = $true
      Mbps = [Math]::Round(($totalBytes * 8 / 1000000 / $elapsed), 2)
      Seconds = [Math]::Round($elapsed, 2)
      Bytes = $totalBytes
      Segments = $testedSegments
      Error = ""
    }
  } catch {
    return [pscustomobject]@{
      Ok = $false
      Mbps = 0
      Seconds = [Math]::Round($sw.Elapsed.TotalSeconds, 2)
      Bytes = 0
      Segments = 0
      Error = $_.Exception.Message
    }
  }
}

function Quote-ProcessArgument {
  param([string]$Value)

  if ($null -eq $Value) { return '""' }
  if ($Value -match '[\s"]') {
    return '"' + ($Value -replace '"', '\"') + '"'
  }
  return $Value
}

function Test-StreamlinkCdnCandidate {
  param(
    [string]$StreamlinkPath,
    [string]$Url,
    [int]$DurationSec,
    [int]$TimeoutSec
  )

  $streamlinkArgs = @(
    "--stdout",
    "--retry-open", "2",
    "--retry-streams", "1",
    "--retry-max", "1",
    "--hls-live-edge", "10",
    "--stream-segment-threads", "4",
    "--stream-segment-attempts", "3",
    "--stream-segment-timeout", "$TimeoutSec",
    "--stream-timeout", "$([Math]::Max($TimeoutSec + 5, 10))",
    "--http-timeout", "$TimeoutSec",
    "--ringbuffer-size", "64M",
    ("hls://" + $Url),
    "best"
  )
  $argumentString = ($streamlinkArgs | ForEach-Object { Quote-ProcessArgument $_ }) -join " "
  $probeId = [guid]::NewGuid().ToString("N")
  $stdoutPath = Join-Path $env:TEMP ("TwitchCdnProbe-$probeId.ts")
  $stderrPath = Join-Path $env:TEMP ("TwitchCdnProbe-$probeId.stderr.txt")
  $sw = [System.Diagnostics.Stopwatch]::StartNew()

  try {
    $process = Start-Process `
      -FilePath $StreamlinkPath `
      -ArgumentList $argumentString `
      -RedirectStandardOutput $stdoutPath `
      -RedirectStandardError $stderrPath `
      -PassThru `
      -WindowStyle Hidden

    $samples = New-Object System.Collections.Generic.List[object]
    while ($sw.Elapsed.TotalSeconds -lt $DurationSec) {
      Start-Sleep -Milliseconds 1000
      $length = [int64]0
      if (Test-Path -LiteralPath $stdoutPath) {
        $length = (Get-Item -LiteralPath $stdoutPath).Length
      }
      $samples.Add([pscustomobject]@{
        Second = [Math]::Round($sw.Elapsed.TotalSeconds, 2)
        Bytes = $length
      })
      if ($process.HasExited) { break }
    }

    $elapsed = [Math]::Max($sw.Elapsed.TotalSeconds, 0.001)
    if (-not $process.HasExited) {
      $process.Kill()
      $process.WaitForExit(5000) | Out-Null
    }

    $totalBytes = [int64]0
    if (Test-Path -LiteralPath $stdoutPath) {
      $totalBytes = (Get-Item -LiteralPath $stdoutPath).Length
    }

    $firstDataSeen = $false
    $previousBytes = [int64]0
    $maxNoGrowth = 0
    $currentNoGrowth = 0
    foreach ($sample in $samples) {
      if ($sample.Bytes -gt 0) { $firstDataSeen = $true }
      if ($firstDataSeen) {
        if ([int64]$sample.Bytes -le $previousBytes) {
          $currentNoGrowth += 1
          if ($currentNoGrowth -gt $maxNoGrowth) { $maxNoGrowth = $currentNoGrowth }
        } else {
          $currentNoGrowth = 0
        }
      }
      $previousBytes = [int64]$sample.Bytes
    }

    $stderrLines = @()
    if (Test-Path -LiteralPath $stderrPath) {
      $stderrLines = Get-Content -LiteralPath $stderrPath -ErrorAction SilentlyContinue
    }
    $mbps = [Math]::Round(($totalBytes * 8 / 1000000 / $elapsed), 2)
    $warnings = @($stderrLines | Where-Object { $_ -match "\[warning\]|\[error\]|error|warning" })
    $score = [double]$mbps
    if ($maxNoGrowth -ge 2) { $score = $score * 0.5 }
    if ($warnings.Count -gt 0) { $score = $score * 0.7 }

    return [pscustomobject]@{
      Ok = ($totalBytes -gt 0)
      Mbps = $mbps
      Score = [Math]::Round($score, 2)
      Seconds = [Math]::Round($elapsed, 2)
      Bytes = $totalBytes
      Segments = 0
      MaxGapSeconds = $maxNoGrowth
      TimeoutTicks = 0
      WarningCount = $warnings.Count
      Error = ""
    }
  } catch {
    if ($process -and -not $process.HasExited) {
      $process.Kill()
      $process.WaitForExit(5000) | Out-Null
    }
    return [pscustomobject]@{
      Ok = $false
      Mbps = 0
      Score = 0
      Seconds = [Math]::Round($sw.Elapsed.TotalSeconds, 2)
      Bytes = 0
      Segments = 0
      MaxGapSeconds = 0
      TimeoutTicks = $timeoutTicks
      WarningCount = 0
      Error = $_.Exception.Message
    }
  } finally {
    Remove-Item -LiteralPath $stdoutPath -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $stderrPath -Force -ErrorAction SilentlyContinue
  }
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

    $webResponse = Invoke-WebRequest `
      -Method Post `
      -Uri ($Proxy + "https://gql.twitch.tv/gql") `
      -Headers $Headers `
      -Body $body `
      -ContentType "application/json" `
      -UseBasicParsing `
      -TimeoutSec $TimeoutSec

    $response = Get-Utf8TextFromWebResponse $webResponse | ConvertFrom-Json

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
$candidates = New-Object System.Collections.Generic.List[object]

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
    $cdnHost = Get-CdnHostFromUrl $variant.Url
    $cdnProbe = [pscustomobject]@{
      Ok = $true
      Mbps = 0
      Seconds = 0
      Bytes = 0
      Segments = 0
      Error = ""
    }

    if (-not $DisableCdnAutoSelect) {
      $cdnProbe = Test-StreamlinkCdnCandidate -StreamlinkPath $streamlink -Url $variant.Url -DurationSec $CdnStreamTestSec -TimeoutSec $CdnTestTimeoutSec
      if ($cdnProbe.Ok) {
        if ($CdnAvoidPattern -and $cdnHost -match $CdnAvoidPattern) {
          $cdnProbe.Score = [Math]::Round(([double]$cdnProbe.Score * 0.35), 2)
        }
        Write-Host ("CDN probe: {0} -> {1} Mbps, score {2}, gap {3}s ({4})" -f $cdnHost, $cdnProbe.Mbps, $cdnProbe.Score, $cdnProbe.MaxGapSeconds, $proxy)
      } else {
        Write-Warning ("CDN probe failed: {0} via {1}: {2}" -f $cdnHost, $proxy, $cdnProbe.Error)
      }
      Write-LauncherLog ("CdnProbe proxy=$proxy cdn=$cdnHost ok=$($cdnProbe.Ok) mbps=$($cdnProbe.Mbps) score=$($cdnProbe.Score) gap=$($cdnProbe.MaxGapSeconds) warnings=$($cdnProbe.WarningCount) seconds=$($cdnProbe.Seconds) error=$($cdnProbe.Error)")
    }

    $candidates.Add([pscustomobject]@{
      Proxy = $proxy
      Info = $variant.Info
      Url = $variant.Url
      Cdn = $cdnHost
      ProbeOk = $cdnProbe.Ok
      ProbeMbps = [double]$cdnProbe.Mbps
      ProbeScore = [double]$cdnProbe.Score
      ProbeSeconds = [double]$cdnProbe.Seconds
      ProbeError = $cdnProbe.Error
      TokenMaximumResolution = $tokenJson.maximum_resolution
    })

    if ($DisableCdnAutoSelect) {
      break
    }
    if ($cdnProbe.Ok -and $cdnProbe.Score -ge $CdnEarlyAcceptMbps) {
      Write-Host ("CDN probe early accept: score {0} >= {1}" -f $cdnProbe.Score, $CdnEarlyAcceptMbps)
      Write-LauncherLog ("CdnProbeEarlyAccept proxy=$proxy cdn=$cdnHost score=$($cdnProbe.Score) mbps=$($cdnProbe.Mbps) threshold=$CdnEarlyAcceptMbps")
      break
    }
  } catch {
    $lastError = $_
    Write-LauncherLog ("Failed proxy=" + $proxy + " Error=" + $_.Exception.Message)
    Write-Warning ("Failed via " + $proxy + ": " + $_.Exception.Message)
  }
}

if ($candidates.Count -eq 0) {
  Write-LauncherLog ("All proxies failed. LastError=" + $lastError)
  throw "All proxies failed. Last error: $lastError"
}

$selectedCandidate = $null
if ($DisableCdnAutoSelect) {
  $selectedCandidate = $candidates[0]
} else {
  $selectedCandidate = $candidates |
    Where-Object { $_.ProbeOk } |
    Sort-Object @{ Expression = "ProbeScore"; Descending = $true }, @{ Expression = "ProbeMbps"; Descending = $true }, @{ Expression = "ProbeSeconds"; Descending = $false } |
    Select-Object -First 1

  if (-not $selectedCandidate) {
    $selectedCandidate = $candidates[0]
  }
}

$proxy = $selectedCandidate.Proxy
$variant = [pscustomobject]@{
  Info = $selectedCandidate.Info
  Url = $selectedCandidate.Url
}

try {
    Write-Host ("Token maximum resolution: " + $selectedCandidate.TokenMaximumResolution)
    if (-not $DisableCdnAutoSelect) {
      Write-Host ("Auto-selected CDN: {0} via {1} ({2} Mbps, score {3})" -f $selectedCandidate.Cdn, $selectedCandidate.Proxy, $selectedCandidate.ProbeMbps, $selectedCandidate.ProbeScore)
      Write-LauncherLog ("AutoSelected proxy=$($selectedCandidate.Proxy) cdn=$($selectedCandidate.Cdn) mbps=$($selectedCandidate.ProbeMbps) score=$($selectedCandidate.ProbeScore)")
    }

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
    $streamlinkArgs = '--title "' + $playerTitle + '" --player-continuous-http --retry-open 8 --retry-streams 5 --retry-max 5 --hls-live-edge 10 --stream-segment-threads 4 --stream-segment-attempts 10 --stream-segment-timeout 20 --stream-timeout 90 --http-timeout 30 --ringbuffer-size 256M --player "' + $potPlayer + '" "' + ("hls://" + $variant.Url) + '" best'
    Write-LauncherLog ("StreamlinkArgs=" + $streamlinkArgs)
    Start-Process -FilePath $streamlink -ArgumentList $streamlinkArgs -WindowStyle Hidden
    exit 0
  } catch {
    $lastError = $_
    Write-LauncherLog ("Failed proxy=" + $proxy + " Error=" + $_.Exception.Message)
    Write-Warning ("Failed via " + $proxy + ": " + $_.Exception.Message)
  }

Write-LauncherLog ("All proxies failed. LastError=" + $lastError)
throw "All proxies failed. Last error: $lastError"

