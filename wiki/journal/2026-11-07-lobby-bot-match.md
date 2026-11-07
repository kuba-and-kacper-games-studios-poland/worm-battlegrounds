---
title: "The lobby plays a blurred bot match behind its panels instead of the 3D stage"
date: 2026-11-07
status: open
kind: changed
pages: ["Lobby", "Lobby & meta modules", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Scripts/Client/Backdrop.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Scripts/Server/Backdrop.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
---

**What changed.** The owner's pick (2026-11-07), like RoWorld's lobby. Before: the camera looked at a 3D stage with
the player's snail on a podium. Now a bot match plays behind the lobby's panels, blurred: the lobby server copies
Picnic Plains (always; `BACKDROP_MAP`) far from everything, and each player's screen plays 4 bots on it, the first in
their equipped skin. It's a small, slow match (the owner asked for it calmer, 2026-11-07): turn after turn a bot
thinks 2–3.5 s, walks up to 8 studs toward a rival or, about one turn in three, hops over with the jetpack (4 studs
up, 8–16 studs along, landing within 4 studs of its height), turns its weapon (Bazooka or Grenade) to the shot over
1.6 s and fires; it picks an arc that no ledge overhead or hill in the way catches (up to 16 tries). The shot flies
1.4–3.2 s under the backdrop's own gravity (50, gentler than a match's) as its weapon's model, the blast flashes and
smokes, deals the weapon's damage and throws snails with 0.4 of its knockback, and the turn ends 1.5 s after everything
landed; a snail at 0 health, in the water or lava,
or off the map floats off as a ghost, and when one is left a new round starts on fresh spots. The camera follows the
bot playing and its shot. Each screen plays its own match; nothing is sent to the server.

**Where.** Server: `Lobby/Scripts/Server/Backdrop.lua` makes `Workspace.Ume.Lobby.Backdrop` (the arena's Terrain and
Decor, a still `Water` or `Lava` part per liquid marker, `Bounds`) at `BACKDROP_ORIGIN` (0, 400, −1500). Client:
`Lobby/Scripts/Client/Backdrop.lua` (was `Stage.lua`). Blur 30 (the owner asked for a stronger one, 2026-11-07) through ume's Lighting layers (weight 1000, over an open
window's 14, so opening one keeps the 30). Settings: the `BACKDROP_*` keys in Lobby's Settings (`BACKDROP_MAP`, `BACKDROP_WEAPONS`,
`BACKDROP_THINK`, `BACKDROP_REST`, `BACKDROP_JETPACK_*`, `BACKDROP_GRAVITY`, `BACKDROP_FLIGHT`, `BACKDROP_AIM_TRIES`,
`BACKDROP_KNOCKBACK_SCALE`); `STAGE_NAME`, `CAMERA_MARKER`, `SNAIL_MARKER`,
`STAGE_FOV` are gone. The old `LobbyStage` Model is unused in the place.

**How to check.** Play the Studio map: behind the lobby panels four snails take turns firing, blurred; opening Crates
keeps the blur at 30; joining a match hands the camera to the match. Checked 2026-11-07 in Studio: the backdrop was Picnic Plains with 4 snails, the camera Scriptable at FOV 30 following the shot, blur 8; after the calmer version, 110 seconds held 9 turns (Bazooka, Grenade and jetpack hops all seen), 8 of 9 shots flew
their full arc, and the jetpack rose 4 studs, with no errors in the output.

**For the wiki.** Lobby: the background is a blurred bot match (the lobby-background question's answer becomes the
owner's new pick); the worm-preview suggestion's answer is now the first bot wearing the player's skin. Still unsure:
blasts make no craters and the liquid is still (the Arena module doesn't run in the lobby).

Supersedes the stage part of 2026-11-05-lobby-stage; its layout (corner buttons, Crates window, Loadout bar) still holds.
