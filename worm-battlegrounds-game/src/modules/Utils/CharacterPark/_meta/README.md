# CharacterPark

Parks every player's Roblox avatar out of sight. Players play as worms (the `Worms` module), but ume still spawns each
player's avatar once, so this anchors it at `PARK_POSITION`, below the arena, as soon as it spawns. That spot stays
above `Fall_Controller`'s `MIN_POSITION`, which would bring the avatar back. It creates no remotes, Topics or saved
data, and exposes nothing.

The framework change it works around: a per-map switch for ume's `INITIAL_CHARACTER_AUTO_LOAD`, so match servers
wouldn't spawn avatars at all.

| | |
| --- | --- |
| Folder | `src/modules/Utils/CharacterPark` |
| Runs on | Server |
| Uses | `I.G_Player` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Anchoring and moving each new avatar |
| `Settings.lua` | Where avatars wait |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `PARK_POSITION` | `0, -60, 0` | Where avatars wait, anchored |
