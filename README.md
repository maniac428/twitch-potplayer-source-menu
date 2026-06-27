# Twitch PotPlayer Source Menu

> Twitch streams in PotPlayer, source/original quality, from a Tampermonkey right-click menu.  
> PotPlayer에서 Twitch가 720p까지만 나올 때, Tampermonkey 우클릭 메뉴로 원본화질(source/original quality)을 직접 여는 도구입니다.  
> Открывайте Twitch в PotPlayer в исходном качестве через меню Tampermonkey, если поток ограничивается 720p.

Keywords: Twitch PotPlayer source quality, Twitch 720p fix, PotPlayer Twitch 1080p, Twitch 720p 제한, 트위치 팟플레이어 원본화질, Tampermonkey Twitch PotPlayer, Streamlink Twitch, Bluesky Frame Rate Converter, Twitch PotPlayer 720p ограничение, исходное качество Twitch PotPlayer.

## 한국어

**Twitch PotPlayer Source Menu**는 Twitch 방송을 PotPlayer에서 원본화질로 열기 위한 작은 Tampermonkey 스크립트와 Windows 실행 도구입니다.

한국/러시아 등 일부 환경에서는 기존 Chrome 확장 프로그램이나 PotPlayer의 기본 Twitch 링크 열기가 720p까지만 잡히는 경우가 있습니다. 이 도구는 Twitch 페이지 주소를 그대로 넘기지 않고, ReYohoho 방식의 프록시 요청으로 Twitch HLS playlist에서 `IVS-VARIANT-SOURCE="source"` 항목을 직접 선택한 뒤 Streamlink를 통해 PotPlayer로 넘깁니다.

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
- PotPlayer
- Streamlink
- Chrome 또는 Chromium 계열 브라우저
- Tampermonkey

설치 순서:

1. 이 저장소를 다운로드합니다.
2. `install-protocol.cmd`를 실행합니다.
3. `twitch-potplayer-source-menu.user.js`를 Tampermonkey에 설치합니다.
4. Twitch에서 우클릭 후 `Open in PotPlayer source quality` 메뉴를 누릅니다.

### 주의

- 방송 자체가 720p로 송출 중이면 source도 720p입니다.
- 공개 프록시가 막히면 실행이 실패할 수 있습니다.
- 이 스크립트는 Twitch 로그인 쿠키나 auth-token을 사용하지 않습니다.
- 기존 `PotPlayer YouTube Shortcut` 확장의 `Open link in PotPlayer` 메뉴는 Twitch에서 720p로 빠질 수 있습니다. 이 저장소의 Tampermonkey 메뉴를 사용하세요.

## Русский

**Twitch PotPlayer Source Menu** - это небольшой userscript для Tampermonkey и Windows launcher, который открывает Twitch-стримы в PotPlayer в исходном качестве.

В некоторых регионах и конфигурациях обычное открытие Twitch-ссылки в PotPlayer или через расширение Chrome может давать только 720p. Этот проект не передает обычную страницу Twitch напрямую в PotPlayer. Вместо этого он получает HLS playlist, выбирает вариант `IVS-VARIANT-SOURCE="source"` и открывает его через Streamlink в PotPlayer.

### Для кого это полезно

- Twitch в PotPlayer открывается только в 720p
- Нужно открыть Twitch в PotPlayer в source/original quality
- Используются LAV Filters или Bluesky Frame Rate Converter
- Обычные расширения Chrome для PotPlayer открывают Twitch не в исходном качестве

### Как это работает

1. Нажмите правой кнопкой мыши на странице Twitch или на карточке стрима
2. Выберите `Open in PotPlayer source quality: channel`
3. Userscript открывает `twitchpotplayer://open?target=...`
4. Windows protocol handler запускает PowerShell launcher
5. Launcher выбирает source-вариант Twitch HLS
6. Streamlink передает поток в PotPlayer

### Установка

Требуется:

- Windows
- PotPlayer
- Streamlink
- Chrome или Chromium-браузер
- Tampermonkey

Шаги:

1. Скачайте этот репозиторий.
2. Запустите `install-protocol.cmd`.
3. Установите `twitch-potplayer-source-menu.user.js` в Tampermonkey.
4. На Twitch нажмите правой кнопкой мыши и выберите `Open in PotPlayer source quality`.

### Важно

- Если стример сам вещает только в 720p, source тоже будет 720p.
- Публичные proxy-серверы могут временно не работать.
- Скрипт не использует ваши Twitch cookies или auth-token.
- Меню обычных расширений PotPlayer может по-прежнему открывать Twitch старым способом. Используйте меню Tampermonkey из этого проекта.

## English

**Twitch PotPlayer Source Menu** opens Twitch livestreams in PotPlayer at source/original quality using a Tampermonkey right-click menu.

Some PotPlayer setups or Chrome extensions open Twitch by passing the normal Twitch page URL to PotPlayer. Depending on region, codec handling, or PotPlayer's internal HLS source, this can get stuck at 720p. This project takes a different route: it requests the Twitch HLS playlist, selects the `IVS-VARIANT-SOURCE="source"` variant, and hands it to PotPlayer through Streamlink.

### Who is this for?

- Users who only get 720p when opening Twitch in PotPlayer
- Users who want Twitch playback through PotPlayer filters such as LAV Filters or Bluesky Frame Rate Converter
- Users who prefer a stable Tampermonkey right-click menu over generic browser extension link handling
- Users searching for a practical Twitch PotPlayer 1080p/source-quality workflow

### How it works

1. Right-click a Twitch stream page or stream card
2. Click `Open in PotPlayer source quality: channel`
3. The userscript opens `twitchpotplayer://open?target=...`
4. The Windows protocol handler launches the PowerShell script
5. The launcher selects the Twitch source HLS variant
6. Streamlink opens the stream in PotPlayer

### Install

Requirements:

- Windows
- PotPlayer
- Streamlink
- Chrome or another Chromium browser
- Tampermonkey

Steps:

1. Download this repository.
2. Run `install-protocol.cmd`.
3. Install `twitch-potplayer-source-menu.user.js` in Tampermonkey.
4. Right-click a Twitch stream and choose `Open in PotPlayer source quality`.

### Notes

- If the streamer broadcasts only at 720p, the source variant will also be 720p.
- Public proxy endpoints can break or become unavailable.
- This project does not use your Twitch cookies or auth-token.
- Generic PotPlayer browser-extension link menus may still open Twitch the old way. Use this Tampermonkey menu for the source-quality route.

## Credits

The Twitch source playlist approach is inspired by [reyohoho/twitch_quality_proxy](https://github.com/reyohoho/twitch_quality_proxy).

## License

MIT
