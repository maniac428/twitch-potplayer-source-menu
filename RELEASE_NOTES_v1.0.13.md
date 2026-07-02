# v1.0.13 - Korea-first CDN auto selection

## Changes

- Add Korea-first CDN auto selection before opening PotPlayer.
- Probe candidate Twitch CDN URLs with Streamlink before playback.
- Prefer CDN paths that sustain source-quality playback during the short probe.
- Penalize `euw*` CDN hosts by default because they were unstable in Korean 1080p/source tests.
- Reorder built-in proxies for Korean users: `proxy6`, `proxy7`, `proxy5`, `proxy4`.
- Keep the v1.0.12 Streamlink stability defaults.

## Notes

- This release prioritizes Korean viewers, which is the expected audience for this launcher.
- Startup can take longer because the launcher tests CDN candidates before playback.
- The CDN auto-selection behavior can be disabled with `-DisableCdnAutoSelect`.
- The CDN avoid pattern can be changed with `-CdnAvoidPattern`.
