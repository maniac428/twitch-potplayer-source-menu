# v1.0.12 - Streamlink stability defaults

## Changes

- Increase Streamlink retry counts for unstable Twitch routes.
- Raise HLS live edge from 8 to 10 to reduce short CDN hiccups during source quality playback.
- Increase segment and HTTP timeouts for slower Twitch CDN responses.
- Increase Streamlink ring buffer from 128M to 256M.
- Keep the v1.0.11 UTF-8 PotPlayer title fix.

## Notes

- This release favors stable 1080p/source playback over the lowest possible delay.
- These settings do not change PotPlayer global preferences or the separate yt-dlp PotPlayer extension.
