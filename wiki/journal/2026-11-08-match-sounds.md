---
title: "Sounds for weapons, blasts, snails and turns"
date: 2026-11-08
status: open
kind: added
pages: ["Arsenal", "Match screen", "Match modules"]
files:
  - worm-battlegrounds-game/src/global_data/Sound/SoundsList.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Fire.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Effects.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Shots.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Sounds.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Shell.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Results.lua
---

**What changed.** The match has sound effects (before, only music and gui clicks):

| When | Sound name | Heard |
| --- | --- | --- |
| A weapon fires | `Fire_<itemId>`: a rocket launch (Bazooka), missile launch (Homing missile), a whoosh (Grenade, Cluster bomb, Variety grenade, Black hole grenade, Spider bomb, Spartan spear), a fuse (Dynamite), Shotgun, Uzi and Minigun shots, a bat swing, a punch | By everyone, where the shot leaves |
| A utility is used | `Use_<itemId>`: a heal (Bandage, Medkit), a drink (Speed and Low gravity potions), a parachute opening, the jetpack starting | At the snail |
| A blast | `Explosion_Big` (radius 6 and up), `Explosion_Small` | At the blast |
| A thrown shot bounces | `Shot_Bounce` | At the bounce |
| A snail walks, jumps, lands, flies its jetpack | `Snail_Step` (two squishes), `Snail_Jump`, `Snail_Land`, `Snail_Jetpack` (looped while it climbs) | At the snail |
| A snail is hurt, its shell breaks, it's knocked out | `Snail_Hurt`, `Snail_ShellBreak`, `Snail_KnockedOut` (`Snail_Splash` in water, `Snail_Burn` in lava) | At the snail |
| A turn starts | `Turn_Yours` on the player's own, `Turn_Start` on others' | 2D |
| The last 5 s of the player's own turn | `Turn_Tick` each second | 2D |
| Sudden death starts | `Match_SuddenDeath` (a siren) | 2D |
| The results | `Match_Win` for 1st place, `Match_Lose` otherwise | 2D |

All are free Creator Store sounds (nothing uploaded), placeholders until the studio's own. Each name and its asset id
is in `SoundsList.lua`; swapping a sound is changing its id there.

**Where.** `Fire.lua` plays `Fire_`/`Use_` for everyone (`I.Sound.PlayForAll`); Combat's `Effects` and `Shots`
(blasts, bounces), Snails' new `Scripts/Client/Sounds.lua` (moves, hurts, knockouts) and `Shell.lua`, MatchHud's
`Turn.lua` and `Results.lua` play the rest on each client. Settings: Combat's `SOUND_ROLLOFF_MIN`/`MAX` (150/600 studs,
full volume within the first), `BIG_BLAST_SOUND_RADIUS` (6), `BOUNCE_SOUND_SPEED` (15); Snails' `STEP_SOUND_*`,
`JUMP_SOUND_*`, `LAND_SOUND_*`, `JETPACK_SOUND_*`; MatchHud's `TICK_SOUND_FROM` (5).

**How to check.** Studio match (2026-11-08): turn chimes and ticks, the jetpack, steps, Grenade throw and bounces,
blasts, the Dynamite fuse, the Minigun, hurts, the shell crack, knockouts, the sudden-death siren and the win sting all
played, with no errors. Not heard by ear: the ids were picked by name and checked to load, so some may not fit.

**For the wiki.** Match screen: the turn sounds (your-turn chime, last-seconds tick, sudden-death siren). Arsenal: a
line that each weapon and utility has its own sound. Match modules: where sounds are played and the `SoundsList` names.
