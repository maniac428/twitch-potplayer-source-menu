# Twitch PotPlayer 720p Fix - Source Quality Launcher

Languages: [한국어](#한국어) | [English](#english) | [Русский](#русский)

Related project:

- Chzzk PotPlayer yt-dlp installer: [chzzk-potplayer-ytdlp-installer](https://github.com/maniac428/chzzk-potplayer-ytdlp-installer)

## 한국어

**Twitch PotPlayer 720p Fix**는 Twitch 방송을 PotPlayer에서 원본화질/source quality로 열기 위한 Windows용 실행 도구입니다.

복잡한 브라우저 스크립트 방식은 제외했습니다. 초보자는 ZIP을 받은 뒤 `open-twitch-source.cmd`를 실행하고 Twitch 채널명이나 링크를 붙여넣으면 됩니다.

### 필요한 것

| 항목 | 링크 |
| --- | --- |
| 최신 릴리스 ZIP | [GitHub Releases](https://github.com/maniac428/twitch-potplayer-720p-fix/releases/latest) |
| PotPlayer 64비트 | [PotPlayerSetup64.exe](https://t1.kakaocdn.net/potplayer/PotPlayer/Version/Latest/PotPlayerSetup64.exe) |
| Streamlink | [Streamlink Windows release](https://github.com/streamlink/windows-builds/releases/latest) |

선택 사항:

| 항목 | 링크 |
| --- | --- |
| LAV Filters | [GitHub releases](https://github.com/Nevcairiel/LAVFilters/releases/latest) |
| Bluesky Frame Rate Converter | [bluesky-soft.com](https://bluesky-soft.com/en/BlueskyFRC.html) |

랜덤 블로그나 미러 사이트에서 설치 파일을 받지 마세요. 가장 효율 좋은 조합은 공식 PotPlayer 64비트 + 공식 Streamlink + 이 저장소 ZIP입니다.

### 사용법

1. 최신 릴리스 ZIP을 받습니다.
2. 압축을 풉니다.
3. `open-twitch-source.cmd`를 실행합니다.
4. Twitch 채널명이나 링크를 입력합니다.

예시:

```cmd
open-twitch-source.cmd "https://www.twitch.tv/aceu"
```

채널명만 넣어도 됩니다.

```cmd
open-twitch-source.cmd aceu
```

### 어떻게 동작하나

1. 입력한 Twitch 채널명을 읽습니다.
2. Twitch HLS playlist를 요청합니다.
3. `IVS-VARIANT-SOURCE="source"` 항목을 우선 선택합니다.
4. Streamlink가 PotPlayer로 스트림을 전달합니다.

### 주의

- 방송 자체가 720p까지만 송출 중이면 원본화질도 720p입니다.
- 이 도구는 공개 프록시 엔드포인트에 의존하므로, 프록시 상태에 따라 실패할 수 있습니다.
- Twitch 계정 쿠키나 auth-token을 사용하지 않습니다.
- "광고 없음"은 브라우저 플레이어를 거치지 않고 PotPlayer로 열 때 웹 플레이어 광고 화면이나 UI를 피할 수 있다는 뜻입니다. Twitch의 모든 광고를 영구 차단한다고 보장하는 도구는 아닙니다.
- 일반 PotPlayer 브라우저 확장은 Twitch 페이지 주소를 그대로 넘겨 720p로 열릴 수 있습니다. 이 도구는 Twitch HLS source variant를 직접 골라 넘기는 방식입니다.

## English

**Twitch PotPlayer 720p Fix** is a small Windows launcher for opening Twitch livestreams in PotPlayer at source/original quality.

The setup is intentionally simple. Download the ZIP, run `open-twitch-source.cmd`, then paste a Twitch channel name or URL.

### Requirements

| Item | Link |
| --- | --- |
| Latest release ZIP | [GitHub Releases](https://github.com/maniac428/twitch-potplayer-720p-fix/releases/latest) |
| PotPlayer 64-bit | [PotPlayerSetup64.exe](https://t1.kakaocdn.net/potplayer/PotPlayer/Version/Latest/PotPlayerSetup64.exe) |
| Streamlink | [Streamlink Windows release](https://github.com/streamlink/windows-builds/releases/latest) |

Optional:

| Item | Link |
| --- | --- |
| LAV Filters | [GitHub releases](https://github.com/Nevcairiel/LAVFilters/releases/latest) |
| Bluesky Frame Rate Converter | [bluesky-soft.com](https://bluesky-soft.com/en/BlueskyFRC.html) |

Avoid random mirror sites. The practical sweet spot is official PotPlayer 64-bit + official Streamlink + this repository ZIP.

### Usage

1. Download the latest release ZIP.
2. Extract it.
3. Run `open-twitch-source.cmd`.
4. Enter a Twitch channel name or URL.

Example:

```cmd
open-twitch-source.cmd "https://www.twitch.tv/aceu"
```

Channel name only also works:

```cmd
open-twitch-source.cmd aceu
```

### How It Works

1. Reads the Twitch channel name.
2. Requests the Twitch HLS playlist.
3. Prefers the `IVS-VARIANT-SOURCE="source"` variant.
4. Streamlink passes the stream to PotPlayer.

### Notes

- If the streamer only broadcasts up to 720p, the source variant will also be 720p.
- This tool depends on public proxy endpoints, so proxy outages can break playback.
- It does not use your Twitch cookies or auth-token.
- "No ads" means opening Twitch outside the browser player may avoid browser ad screens or web-player UI in some setups. It is not a guaranteed permanent Twitch ad blocker.
- Generic PotPlayer browser extensions may pass the normal Twitch page URL and still open 720p. This tool selects the Twitch HLS source variant directly.

## Русский

**Twitch PotPlayer 720p Fix** - это простой Windows launcher для открытия Twitch-стримов в PotPlayer в исходном качестве/source quality.

Настройка максимально простая: скачайте ZIP, запустите `open-twitch-source.cmd` и вставьте имя канала Twitch или ссылку.

### Что нужно

| Компонент | Ссылка |
| --- | --- |
| Последний ZIP release | [GitHub Releases](https://github.com/maniac428/twitch-potplayer-720p-fix/releases/latest) |
| PotPlayer 64-bit | [PotPlayerSetup64.exe](https://t1.kakaocdn.net/potplayer/PotPlayer/Version/Latest/PotPlayerSetup64.exe) |
| Streamlink | [Streamlink Windows release](https://github.com/streamlink/windows-builds/releases/latest) |

Дополнительно:

| Компонент | Ссылка |
| --- | --- |
| LAV Filters | [GitHub releases](https://github.com/Nevcairiel/LAVFilters/releases/latest) |
| Bluesky Frame Rate Converter | [bluesky-soft.com](https://bluesky-soft.com/en/BlueskyFRC.html) |

Не скачивайте установщики со случайных зеркал. Практичный вариант: официальный PotPlayer 64-bit + официальный Streamlink + ZIP этого репозитория.

### Использование

1. Скачайте последний ZIP release.
2. Распакуйте архив.
3. Запустите `open-twitch-source.cmd`.
4. Введите имя канала Twitch или ссылку.

Пример:

```cmd
open-twitch-source.cmd "https://www.twitch.tv/aceu"
```

Можно указать только имя канала:

```cmd
open-twitch-source.cmd aceu
```

### Как это работает

1. Launcher читает имя Twitch-канала.
2. Запрашивает Twitch HLS playlist.
3. Выбирает вариант `IVS-VARIANT-SOURCE="source"`, если он доступен.
4. Streamlink передает поток в PotPlayer.

### Важно

- Если сам стример вещает только в 720p, source тоже будет 720p.
- Инструмент зависит от публичных proxy endpoints, поэтому при сбоях proxy воспроизведение может не работать.
- Twitch cookies и auth-token не используются.
- "Без рекламы" означает, что открытие вне браузерного player иногда помогает избежать рекламного экрана или web-player UI. Это не гарантированный постоянный ad blocker для Twitch.
- Обычные расширения PotPlayer могут передавать обычную ссылку Twitch-страницы и открывать 720p. Этот launcher выбирает Twitch HLS source variant напрямую.

## Search Keywords / 검색 키워드 / Ключевые слова

한국어: 트위치 팟플레이어 720p 해결, 트위치 팟플레이어 1080p, 트위치 팟플레이어 원본화질, 트위치 팟플레이어 광고 없음, 팟플레이어 트위치 연결, 트위치 720p 제한, 한국 트위치 1080p 안됨, 러시아 트위치 1080p 안됨, Streamlink Twitch PotPlayer.

English: Twitch PotPlayer 720p fix, Twitch PotPlayer 1080p, Twitch PotPlayer source quality, Twitch PotPlayer no ads, PotPlayer Twitch original quality, Streamlink Twitch PotPlayer, Korea Twitch 720p, Russia Twitch 720p.

Русский: Twitch PotPlayer 720p ограничение, Twitch PotPlayer 1080p, Twitch PotPlayer исходное качество, Twitch PotPlayer без рекламы, PotPlayer Twitch source quality, Streamlink Twitch PotPlayer, Twitch 1080p не работает.

## Credits

The Twitch source playlist approach is inspired by [reyohoho/twitch_quality_proxy](https://github.com/reyohoho/twitch_quality_proxy).

## License

MIT
