# VoiceChat

Voice chat that works without avatars. The game has no characters, so Roblox's default voice (which plays near an
avatar) would be silent. The server gives each player an `AudioDeviceInput`; each client wires every other player's
input to one `AudioDeviceOutput`, so voices play at the same volume wherever the camera is.

| | |
| --- | --- |
| Folder | `src/modules/Utils/VoiceChat` |
| Runs on | Server, Client · both maps |
| Uses | `I.G_Player`, `I.Create` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | One `AudioDeviceInput` named `VoiceChat` under each player |
| `Client.lua` | The `AudioDeviceOutput` and a `Wire` from each other player's input |

## Network

No remotes: the inputs replicate under the players.

## In the place

Creates `Player.VoiceChat` (`AudioDeviceInput`) on the server and `SoundService.VoiceChat` (`AudioDeviceOutput`) on
each client. `VoiceChatService.EnableDefaultVoice` must be off in the place.
