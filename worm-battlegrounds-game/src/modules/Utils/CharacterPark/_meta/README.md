# CharacterPark

Parks every player's Roblox avatar out of sight. Players play as snails (the `Snails` module), but ume still spawns each
player's avatar once, so this anchors it at `PARK_POSITION`, below the arena, as soon as it spawns, and hides it
(through `I.HideOnPlay`, with the clothes, hats and face that load later) and its name, since Roblox's camera still
looks at it until a game camera takes over (the match's waiting screen). That spot stays above `Fall_Controller`'s
`MIN_POSITION`, which would bring the avatar back. On every client it turns off Roblox's touch controls (the
thumbstick and the jump button, `GuiService.TouchControlsEnabled`), which only moved that avatar and covered the guis
on phones; the snails' own touch buttons are MatchHud's. It creates no remotes, Topics or saved data, and exposes
nothing.

The framework change it works around: a per-map switch for ume's `INITIAL_CHARACTER_AUTO_LOAD`, so match servers
wouldn't spawn avatars at all.

| | |
| --- | --- |
| Folder | `src/modules/Utils/CharacterPark` |
| Runs on | Server, Client |
| Uses | `I.G_Player`, `I.HideOnPlay` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Anchoring, moving and hiding each new avatar |
| `Client.lua` | Turns off Roblox's touch thumbstick and jump button |
| `Settings.lua` | Where avatars wait |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `PARK_POSITION` | `0, -60, 0` | Where avatars wait, anchored |
