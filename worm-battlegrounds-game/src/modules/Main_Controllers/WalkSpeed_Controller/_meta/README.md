# WalkSpeed_Controller

Applies the `WalkSpeed` buff to characters. When a character spawns, and whenever the player's `WalkSpeed` buff
changes (an upgrade or a pass that adds to it), it sets the character's `Humanoid.WalkSpeed` to the buff's sum: the
buff starts at `StarterPlayer.CharacterWalkSpeed` (24 in this place) and every source adds to it. While InputBlock holds a character
still, the speed it writes is kept by InputBlock and comes back when the lock ends.

| | |
| --- | --- |
| Folder | `src/modules/Main_Controllers/WalkSpeed_Controller` |
| Runs on | Server |
| Uses | `I.G_Player`, `I.Buff`, `I.Topic` (`Buff_Updated-WalkSpeed`) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Writing the buff's sum on the humanoid on spawn and on each change |

## Network

No remotes. The speed reaches clients as the humanoid's `WalkSpeed`, which the server writes.
