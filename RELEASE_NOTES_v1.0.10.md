# v1.0.10 - Playback stability and player titles

## Changes

- Use the current Twitch stream title as the PotPlayer window title.
- Sanitize player titles so quotes and special characters do not break launch arguments.
- Switch Streamlink player handoff to continuous HTTP mode for better recovery behavior.
- Increase live edge and ringbuffer defaults for more stable playback on unstable connections.
- Add Streamlink retry and timeout options for HLS segment interruptions.

## Notes

- If the Streamlink process exits completely, reopen the channel from the browser menu.
- The PotPlayer play button can only resume while Streamlink is still serving the stream.
- The stability defaults trade a little more live delay for fewer stalls.
