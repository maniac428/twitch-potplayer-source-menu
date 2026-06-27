# Twitch PotPlayer 720p Fix - Source Quality Menu

Languages: [English](#english) | [한국어](#한국어) | [Русский](#русский)

## Search Keywords

English: Twitch PotPlayer 720p fix, Twitch PotPlayer source quality, Twitch PotPlayer 1080p, PotPlayer Twitch original quality, Tampermonkey Twitch PotPlayer, Streamlink Twitch.

한국어: 트위치 팟플레이어 720p 해결, 트위치 팟플레이어 원본화질, 트위치 팟플레이어 1080p, 팟플레이어 트위치 원본소스, 트위치 720p 제한, Bluesky 프레임 보간.

Русский: Twitch PotPlayer 720p ограничение, Twitch PotPlayer исходное качество, Twitch PotPlayer 1080p, PotPlayer Twitch source quality, Tampermonkey Twitch PotPlayer, Streamlink Twitch.

## English

**Twitch PotPlayer 720p Fix - Source Quality Menu** opens Twitch livestreams in PotPlayer at source/original quality from a Tampermonkey right-click menu.

Some PotPlayer setups or Chrome extensions open Twitch by passing the normal Twitch page URL to PotPlayer. Depending on region, codec handling, or PotPlayer's internal HLS source, this can get stuck at 720p. This project takes a different route: it requests the Twitch HLS playlist, selects the `IVS-VARIANT-SOURCE="source"` variant, and hands it to PotPlayer through Streamlink.

Search keywords: Twitch PotPlayer source quality, Twitch 720p fix, PotPlayer Twitch 1080p, Tampermonkey Twitch PotPlayer, Streamlink Twitch, Bluesky Frame Rate Converter.

### Required Downloads

Download the full repository first. `install-protocol.cmd` needs the `scripts` folder, so downloading only the `.cmd` file is not enough.

| File or tool | Download link |
| --- | --- |
| Beginner ZIP, recommended | [twitch-potplayer-720p-fix-beginner.zip](https://github.com/maniac428/twitch-potplayer-source-menu/releases/latest/download/twitch-potplayer-720p-fix-beginner.zip) |
| Full repository ZIP | [Download main.zip](https://github.com/maniac428/twitch-potplayer-source-menu/archive/refs/heads/main.zip) |
| Tampermonkey userscript | [twitch-potplayer-source-menu.user.js](https://raw.githubusercontent.com/maniac428/twitch-potplayer-source-menu/main/twitch-potplayer-source-menu.user.js) |
| Direct CMD launcher | [open-twitch-source.cmd](https://raw.githubusercontent.com/maniac428/twitch-potplayer-source-menu/main/open-twitch-source.cmd) |
| PotPlayer official page | [potplayer.tv](https://potplayer.tv/) |
| PotPlayer 64-bit direct, recommended | [PotPlayerSetup64.exe](https://t1.kakaocdn.net/potplayer/PotPlayer/Version/Latest/PotPlayerSetup64.exe) |
| Streamlink official install | [streamlink.github.io/install.html](https://streamlink.github.io/install.html) |
| Streamlink Windows release | [GitHub latest release](https://github.com/streamlink/windows-builds/releases/latest) |
| Tampermonkey for Chrome | [Chrome Web Store](https://chromewebstore.google.com/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo) |

Optional for frame interpolation:

| Tool | Download link |
| --- | --- |
| LAV Filters | [GitHub releases](https://github.com/Nevcairiel/LAVFilters/releases/latest) |
| Bluesky Frame Rate Converter | [bluesky-soft.com](https://bluesky-soft.com/en/BlueskyFRC.html) |

Do not download PotPlayer, Streamlink, or Tampermonkey from random mirror sites. The safest sweet spot for this project is: official PotPlayer 64-bit + official Streamlink + Tampermonkey from Chrome Web Store + this repository ZIP.

### Who Is This For?

- Users who only get 720p when opening Twitch in PotPlayer
- Users who want Twitch playback through PotPlayer filters such as LAV Filters or Bluesky Frame Rate Converter
- Users who prefer a stable Tampermonkey right-click menu over generic browser extension link handling
- Users searching for a practical Twitch PotPlayer 1080p/source-quality workflow

### How It Works

1. Right-click a Twitch stream page or stream card.
2. Click `Open in PotPlayer source quality: channel`.
3. The userscript opens `twitchpotplayer://open?target=...`.
4. The Windows protocol handler launches the PowerShell script.
5. The launcher selects the Twitch source HLS variant.
6. Streamlink opens the stream in PotPlayer.

### Install

Requirements:

- Windows
- PotPlayer 64-bit recommended
- Streamlink
- Chrome or another Chromium browser
- Tampermonkey

Steps:

1. Download this repository.
2. Run `install-protocol.cmd`.
3. Install `twitch-potplayer-source-menu.user.js` in Tampermonkey.
4. Right-click a Twitch stream and choose `Open in PotPlayer source quality`.

### Direct CMD Usage

You can also open Twitch source quality without Chrome or Tampermonkey after downloading the full repository.

```cmd
open-twitch-source.cmd "https://www.twitch.tv/aceu"
```

Channel name only also works:

```cmd
open-twitch-source.cmd aceu
```

If you double-click `open-twitch-source.cmd`, it will ask you to paste a Twitch channel name or URL. This method still requires PotPlayer 64-bit and Streamlink. Do not download only `open-twitch-source.cmd`; it needs `scripts\Open_Twitch_PotPlayer_Source.ps1`.

### Notes

- If the streamer broadcasts only at 720p, the source variant will also be 720p.
- Public proxy endpoints can break or become unavailable.
- This project does not use your Twitch cookies or auth-token.
- Generic PotPlayer browser-extension link menus may still open Twitch the old way. Use this Tampermonkey menu for the source-quality route.
- Use 32-bit PotPlayer only if you depend on old 32-bit-only filters. This project is designed around PotPlayer 64-bit.
- Streamlink uses a stability-oriented HLS buffer by default in this launcher. This can add a few seconds of latency, but it reduces live-stream buffering.

## 한국어

**Twitch PotPlayer 720p Fix - Source Quality Menu**는 Twitch 방송을 PotPlayer에서 원본화질로 열기 위한 Tampermonkey 우클릭 메뉴와 Windows 실행 도구입니다.

한국/러시아 등 일부 환경에서는 기존 Chrome 확장 프로그램이나 PotPlayer의 기본 Twitch 링크 열기가 720p까지만 잡히는 경우가 있습니다. 이 도구는 Twitch 페이지 주소를 그대로 넘기지 않고, ReYohoho 방식의 프록시 요청으로 Twitch HLS playlist에서 `IVS-VARIANT-SOURCE="source"` 항목을 직접 선택한 뒤 Streamlink를 통해 PotPlayer로 넘깁니다.

검색 키워드: Twitch PotPlayer source quality, Twitch 720p fix, PotPlayer Twitch 1080p, Twitch 720p 제한, 트위치 팟플레이어 원본화질, Tampermonkey Twitch PotPlayer, Streamlink Twitch, Bluesky Frame Rate Converter.

### 필수 다운로드

먼저 저장소 전체를 받으세요. `install-protocol.cmd`는 `scripts` 폴더 안의 PowerShell 파일을 같이 사용하므로 `.cmd` 파일 하나만 받으면 동작하지 않습니다.

| 파일 또는 도구 | 다운로드 링크 |
| --- | --- |
| 초보자용 ZIP, 권장 | [twitch-potplayer-720p-fix-beginner.zip](https://github.com/maniac428/twitch-potplayer-source-menu/releases/latest/download/twitch-potplayer-720p-fix-beginner.zip) |
| 전체 저장소 ZIP | [main.zip 다운로드](https://github.com/maniac428/twitch-potplayer-source-menu/archive/refs/heads/main.zip) |
| Tampermonkey 유저스크립트 | [twitch-potplayer-source-menu.user.js](https://raw.githubusercontent.com/maniac428/twitch-potplayer-source-menu/main/twitch-potplayer-source-menu.user.js) |
| 직접 실행용 CMD | [open-twitch-source.cmd](https://raw.githubusercontent.com/maniac428/twitch-potplayer-source-menu/main/open-twitch-source.cmd) |
| PotPlayer 공식 페이지 | [potplayer.tv](https://potplayer.tv/) |
| PotPlayer 64비트 직접 다운로드, 권장 | [PotPlayerSetup64.exe](https://t1.kakaocdn.net/potplayer/PotPlayer/Version/Latest/PotPlayerSetup64.exe) |
| Streamlink 공식 설치 문서 | [streamlink.github.io/install.html](https://streamlink.github.io/install.html) |
| Streamlink Windows 릴리스 | [GitHub latest release](https://github.com/streamlink/windows-builds/releases/latest) |
| Chrome용 Tampermonkey | [Chrome Web Store](https://chromewebstore.google.com/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo) |

프레임 보간용 선택 설치:

| 도구 | 다운로드 링크 |
| --- | --- |
| LAV Filters | [GitHub releases](https://github.com/Nevcairiel/LAVFilters/releases/latest) |
| Bluesky Frame Rate Converter | [bluesky-soft.com](https://bluesky-soft.com/en/BlueskyFRC.html) |

PotPlayer, Streamlink, Tampermonkey는 랜덤 미러 사이트에서 받지 마세요. 이 프로젝트에서 가장 안전하고 효율 좋은 조합은 공식 PotPlayer 64비트 + 공식 Streamlink + Chrome Web Store의 Tampermonkey + 이 저장소 ZIP입니다.

### 이런 사람에게 추천

- PotPlayer에서 Twitch가 720p까지만 나오는 사람
- Twitch 방송을 PotPlayer로 보면서 LAV Filters, Bluesky Frame Rate Converter 같은 필터를 쓰고 싶은 사람
- Chrome 우클릭 메뉴보다 Tampermonkey 페이지 메뉴가 더 안정적인 사람
- YouTube/로컬 영상은 프레임 보간이 되는데 Twitch만 잘 안 되는 사람

### 동작 방식

1. Twitch 방송 페이지 또는 메인/탐색 화면에서 방송 카드 우클릭
2. `Open in PotPlayer source quality: channel` 메뉴 클릭
3. Tampermonkey가 `twitchpotplayer://open?target=...` 호출
4. Windows 프로토콜 핸들러가 PowerShell launcher 실행
5. launcher가 Twitch source HLS variant 선택
6. Streamlink가 PotPlayer로 스트림 전달

### 설치

필수:

- Windows
- PotPlayer 64-bit 권장
- Streamlink
- Chrome 또는 Chromium 계열 브라우저
- Tampermonkey

설치 순서:

1. 이 저장소를 다운로드합니다.
2. `install-protocol.cmd`를 실행합니다.
3. `twitch-potplayer-source-menu.user.js`를 Tampermonkey에 설치합니다.
4. Twitch에서 우클릭 후 `Open in PotPlayer source quality` 메뉴를 누릅니다.

### CMD 직접 실행 사용법

전체 저장소를 받은 뒤에는 Chrome이나 Tampermonkey 없이도 CMD 파일에 Twitch 링크를 넣어서 원본화질로 열 수 있습니다.

```cmd
open-twitch-source.cmd "https://www.twitch.tv/aceu"
```

채널 이름만 넣어도 됩니다.

```cmd
open-twitch-source.cmd aceu
```

`open-twitch-source.cmd`를 더블클릭하면 Twitch 채널명이나 URL을 붙여넣으라는 입력창이 나옵니다. 이 방식도 PotPlayer 64비트와 Streamlink가 필요합니다. `open-twitch-source.cmd` 파일 하나만 받으면 안 되고, `scripts\Open_Twitch_PotPlayer_Source.ps1`이 같이 있어야 합니다.

### 주의

- 방송 자체가 720p로 송출 중이면 source도 720p입니다.
- 공개 프록시가 막히면 실행이 실패할 수 있습니다.
- 이 스크립트는 Twitch 로그인 쿠키나 auth-token을 사용하지 않습니다.
- 기존 `PotPlayer YouTube Shortcut` 확장의 `Open link in PotPlayer` 메뉴는 Twitch에서 720p로 빠질 수 있습니다. 이 저장소의 Tampermonkey 메뉴를 사용하세요.
- 32비트 PotPlayer는 오래된 32비트 전용 필터가 꼭 필요할 때만 고려하세요. 이 프로젝트의 기본 경로는 64비트 PotPlayer입니다.
- 이 런처는 Streamlink HLS 버퍼를 안정성 위주로 설정합니다. 지연은 몇 초 늘 수 있지만 라이브 버퍼링은 줄어듭니다.

## Русский

**Twitch PotPlayer 720p Fix - Source Quality Menu** - это меню правой кнопки мыши Tampermonkey и Windows launcher, которые открывают Twitch-стримы в PotPlayer в исходном качестве.

В некоторых регионах и конфигурациях обычное открытие Twitch-ссылки в PotPlayer или через расширение Chrome может давать только 720p. Этот проект не передает обычную страницу Twitch напрямую в PotPlayer. Вместо этого он получает HLS playlist, выбирает вариант `IVS-VARIANT-SOURCE="source"` и открывает его через Streamlink в PotPlayer.

Ключевые слова: Twitch PotPlayer source quality, Twitch 720p fix, PotPlayer Twitch 1080p, Twitch PotPlayer 720p ограничение, исходное качество Twitch PotPlayer, Tampermonkey Twitch PotPlayer, Streamlink Twitch, Bluesky Frame Rate Converter.

### Обязательные загрузки

Сначала скачайте весь репозиторий. `install-protocol.cmd` использует файлы из папки `scripts`, поэтому одного `.cmd` файла недостаточно.

| Файл или инструмент | Ссылка |
| --- | --- |
| ZIP для начинающих, рекомендуется | [twitch-potplayer-720p-fix-beginner.zip](https://github.com/maniac428/twitch-potplayer-source-menu/releases/latest/download/twitch-potplayer-720p-fix-beginner.zip) |
| Полный ZIP репозитория | [Скачать main.zip](https://github.com/maniac428/twitch-potplayer-source-menu/archive/refs/heads/main.zip) |
| Userscript для Tampermonkey | [twitch-potplayer-source-menu.user.js](https://raw.githubusercontent.com/maniac428/twitch-potplayer-source-menu/main/twitch-potplayer-source-menu.user.js) |
| CMD launcher напрямую | [open-twitch-source.cmd](https://raw.githubusercontent.com/maniac428/twitch-potplayer-source-menu/main/open-twitch-source.cmd) |
| Официальная страница PotPlayer | [potplayer.tv](https://potplayer.tv/) |
| PotPlayer 64-bit напрямую, рекомендуется | [PotPlayerSetup64.exe](https://t1.kakaocdn.net/potplayer/PotPlayer/Version/Latest/PotPlayerSetup64.exe) |
| Официальная установка Streamlink | [streamlink.github.io/install.html](https://streamlink.github.io/install.html) |
| Streamlink для Windows | [GitHub latest release](https://github.com/streamlink/windows-builds/releases/latest) |
| Tampermonkey для Chrome | [Chrome Web Store](https://chromewebstore.google.com/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo) |

Дополнительно для интерполяции кадров:

| Инструмент | Ссылка |
| --- | --- |
| LAV Filters | [GitHub releases](https://github.com/Nevcairiel/LAVFilters/releases/latest) |
| Bluesky Frame Rate Converter | [bluesky-soft.com](https://bluesky-soft.com/en/BlueskyFRC.html) |

Не скачивайте PotPlayer, Streamlink или Tampermonkey со случайных зеркал. Самый безопасный и практичный набор для этого проекта: официальный PotPlayer 64-bit + официальный Streamlink + Tampermonkey из Chrome Web Store + ZIP этого репозитория.

### Для кого это полезно

- Twitch в PotPlayer открывается только в 720p
- Нужно открыть Twitch в PotPlayer в source/original quality
- Используются LAV Filters или Bluesky Frame Rate Converter
- Обычные расширения Chrome для PotPlayer открывают Twitch не в исходном качестве

### Как это работает

1. Нажмите правой кнопкой мыши на странице Twitch или на карточке стрима.
2. Выберите `Open in PotPlayer source quality: channel`.
3. Userscript открывает `twitchpotplayer://open?target=...`.
4. Windows protocol handler запускает PowerShell launcher.
5. Launcher выбирает source-вариант Twitch HLS.
6. Streamlink передает поток в PotPlayer.

### Установка

Требуется:

- Windows
- PotPlayer 64-bit рекомендуется
- Streamlink
- Chrome или Chromium-браузер
- Tampermonkey

Шаги:

1. Скачайте этот репозиторий.
2. Запустите `install-protocol.cmd`.
3. Установите `twitch-potplayer-source-menu.user.js` в Tampermonkey.
4. На Twitch нажмите правой кнопкой мыши и выберите `Open in PotPlayer source quality`.

### Использование через CMD

После скачивания полного репозитория можно открыть Twitch в исходном качестве без Chrome и Tampermonkey, передав ссылку в CMD файл.

```cmd
open-twitch-source.cmd "https://www.twitch.tv/aceu"
```

Можно указать только имя канала:

```cmd
open-twitch-source.cmd aceu
```

Если дважды нажать `open-twitch-source.cmd`, он попросит вставить имя канала Twitch или URL. Для этого способа все равно нужны PotPlayer 64-bit и Streamlink. Не скачивайте только `open-twitch-source.cmd`; ему нужен файл `scripts\Open_Twitch_PotPlayer_Source.ps1`.

### Важно

- Если стример сам вещает только в 720p, source тоже будет 720p.
- Публичные proxy-серверы могут временно не работать.
- Скрипт не использует ваши Twitch cookies или auth-token.
- Меню обычных расширений PotPlayer может по-прежнему открывать Twitch старым способом. Используйте меню Tampermonkey из этого проекта.
- 32-bit PotPlayer имеет смысл только для старых 32-bit фильтров. Основной путь этого проекта рассчитан на PotPlayer 64-bit.
- Launcher использует более стабильный HLS buffer в Streamlink. Задержка может увеличиться на несколько секунд, но буферизация должна стать реже.

## Credits

The Twitch source playlist approach is inspired by [reyohoho/twitch_quality_proxy](https://github.com/reyohoho/twitch_quality_proxy).

## License

MIT
