---
title: "Falling bombs and rockets whistle, and the camera leads flying shots"
date: 2026-11-10
status: open
kind: added
pages: ["Arsenal", "Controls & platforms", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Shots.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/_meta/_types.lua
  - worm-battlegrounds-game/src/global_data/Sound/SoundsList.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Settings.lua
---

**What changed.**

- **Falling whistle:** a thrown bomb, a rocket or the spider bomb's throw (the `Bouncer`, `Rocket` and `Crawler`
  kinds: Grenade, Cluster bomb (not its bomblets), Variety grenade, Dynamite, Bazooka, Spartan spear and the Spider
  bomb's throw; not the Homing missile or the Black hole grenade) whistles once, from the shot, the
  first time it comes down faster than 25 studs a second. The whistle stops when the shot stops, rests on the ground,
  sinks into liquid, rises again or ends.
- **Camera lead:** while the camera follows a flying shot, it looks 0.35 s ahead along the shot's flight (its speed
  smoothed), at most 18 studs, so where it lands comes into view sooner.

**Where.** `Shots._whistle(shot)` in Combat's `Scripts/Client/Shots.lua`, called each frame from `Shots._step`;
`Shots._onEnd` stops it. New fields on `Combat_ClientShot` (`_meta/_types.lua`): `Whistled` (played once) and
`Whistle` (the playing Sound). New Combat settings `WHISTLE_KINDS` `{ Bouncer, Rocket, Crawler }` and
`WHISTLE_FALL_SPEED` 25 (studs a second of the shot's own flight). New sound `Shot_Whistle` 127333563637736 in
`SoundsList.lua`, played at volume 0.5 within Combat's `SOUND_ROLLOFF_MIN`/`MAX`. It loads in Studio, but it's a
community upload ("falling-bomb"), not one of the licensed creators the sounds rule prefers: a placeholder the owner
should listen to and swap if it doesn't fit. Camera: `MatchCamera._update` adds the lead when it follows a part
(a shot); new settings `LEAD_SECONDS` 0.35, `LEAD_MAX` 18, `LEAD_SMOOTH` 8.

**How to check.** In a Studio match, lob a Grenade high: as it falls, the whistle plays from it and cuts out when it
lands. With "Camera follows shot" on, fire the Bazooka sideways: the view runs a little ahead of the rocket. Not
checked in Studio by the docs pass.

**For the wiki.** Arsenal (or Match screen, sounds): lobbed shots whistle as they fall. Controls & platforms (the
camera): it leads a flying shot. Match modules: the new settings and the `Shot_Whistle` sound.
