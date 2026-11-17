---
title: "Level plate in the lobby, XP for wins (+50) and knockouts (+10), and the replay after a match"
date: 2026-11-17
status: open
kind: added
pages: ["Levels", "Lobby", "Results"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Global.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchRewards/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchRewards/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/LevelPlate/init.lua
---

**What changed.** The lobby shows the player's level at the top centre: a diamond with the level in it (painted in
their prestige frame's colours), "LEVEL n", "into / for XP", a gold bar and the next thing a level opens ("Next unlock:
Silver frame at level 15"). XP now comes in lines: 100 for playing a Public, Solo or Party match (as before), +50 for a
win (first place, or the winning team) and +10 per knockout. When a player comes back from a match that gave XP, the
lobby dims, the plate grows in the middle, each line pops in with a chime and fills the bar with rising ticks and
sparks flying into it; each level-up throws stars, shows LEVEL UP! and what it opened (a new frame first, with its own
sting), then the plate flies back. Any tap, click or A skips it.

**Where.** `MatchRewards` `XP_WIN` 50, `XP_PER_KNOCKOUT` 10, `XP_LABELS`; the lines are queued with
`I.Progression.SetReplay` (profile `Progression.Replay`, a JSON replay that survives the teleport back; Replicator
`Progression.Replay`), merged with any still waiting (a rematch). The client plays it (`Progression/Client.lua`, the
`LevelPlate` gui) and sends `Progression_ReplaySeen`. The level curve is unchanged (`LEVEL_BASE_XP` 100,
`LEVEL_STEP_XP` 4, max 100); `LEVEL_REWARDS` moved to the shared `Settings.lua`. Results get `XpLines`, `XpBefore`,
`XpAfter` in `earned`. Sounds `Xp_Line`, `Xp_Tick`, `Level_Up`, `Frame_Unlock` (stand-ins until the 17 Nov sound set is
approved).

**How to check.** Win a solo match with 2 knockouts: 170 XP in three lines; back in the lobby the replay plays once.

**For the wiki.** Levels: XP per match, win and knockout; the plate and the replay; a screenshot of the plate.

**Changed after the owner's second look (same day).** "Polish the level gui too, it needs to fit the game more": the
plate now stands on the currency slots' dark slanted plate (the Gacha frame's pictures), its diamond on the plate's
left end as the coin sits on a currency slot, LEVEL n in its top half, the XP written over the bar in its bottom half,
and the next unlock under it. The sounds are uploaded now: `Xp_Line` "Snail Level Chime" 110710270773656, `Xp_Tick`
"Snail Level Tick" 93301600404825, `Level_Up` "Snail Level Up Fanfare" 86569810342605, `Frame_Unlock` "Snail Frame
Unlock" 94250786007519.
