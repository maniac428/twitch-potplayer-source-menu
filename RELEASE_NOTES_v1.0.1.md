## English

Stability update for live Twitch playback through Streamlink.

Changed:
- Added Streamlink buffering options for fewer live-stream stalls:
  - `--hls-live-edge 5`
  - `--stream-segment-threads 3`
  - `--stream-segment-attempts 5`
  - `--stream-segment-timeout 20`
  - `--ringbuffer-size 64M`

Tradeoff:
- Playback can be delayed by a few extra seconds.
- Source/original quality selection is unchanged.

## 한국어

Streamlink로 Twitch 라이브를 볼 때 버퍼링을 줄이기 위한 안정성 업데이트입니다.

변경점:
- 라이브 끊김을 줄이기 위해 Streamlink 버퍼 옵션을 추가했습니다.
  - `--hls-live-edge 5`
  - `--stream-segment-threads 3`
  - `--stream-segment-attempts 5`
  - `--stream-segment-timeout 20`
  - `--ringbuffer-size 64M`

단점:
- 재생 지연이 몇 초 늘 수 있습니다.
- 원본화질/source 선택 방식은 그대로입니다.

## Русский

Обновление стабильности для просмотра Twitch live через Streamlink.

Изменено:
- Добавлены настройки буфера Streamlink, чтобы уменьшить зависания live-стрима:
  - `--hls-live-edge 5`
  - `--stream-segment-threads 3`
  - `--stream-segment-attempts 5`
  - `--stream-segment-timeout 20`
  - `--ringbuffer-size 64M`

Компромисс:
- Задержка воспроизведения может увеличиться на несколько секунд.
- Выбор source/original quality не изменился.
