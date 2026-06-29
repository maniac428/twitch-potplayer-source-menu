# v1.0.9 - Faster proxy fallback

## Changes

- Prefer the currently fastest built-in proxy endpoint first.
- Cache the last successful proxy and try it first on the next launch.
- Add a configurable proxy timeout with an 8-second default.
- Support custom proxy overrides through `TWITCH_POTPLAYER_PROXIES` or `proxies.txt`.
- Keep the existing PotPlayer and Streamlink launch flow unchanged.

## Notes

- Public proxy endpoints can still go down or become slow.
- For the most stable setup, use your own trusted proxy endpoint and add it through `proxies.txt` or the `TWITCH_POTPLAYER_PROXIES` environment variable.
- If playback buffers after the player opens, Streamlink, Twitch CDN routing, or the local network may be the bottleneck rather than the playlist proxy.
