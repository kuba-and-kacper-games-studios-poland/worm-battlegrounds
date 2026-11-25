---
title: "Round intro in two beats: GET READY on the drop, THE BATTLE BEGINS on the landing"
date: 2026-11-24
status: open
kind: changed
pages: ["Match", "Interface"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/BattleIntro.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Phases.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
  - worm-battlegrounds-game/src/global_data/Sound/SoundsList.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - art/sfx/make_classic.py
---

**What changed.** The round's intro is its own look (no longer the turn banner's) and plays in two beats (the owner:
"in 2 sequences - at the start and when we land"). As the snails drop in (the `Landing` phase), the screen's edges darken
and a letter-spaced gold GET READY fades in over a line, with `Match_DropIn`. When they land, the match enters a new
`Battle` phase for `BATTLE_INTRO_SECONDS` (1.8 s, was 10 s of THE BATTLE BEGINS on the old banner): a white flash, THE
BATTLE right over a big gold BEGINS! slamming in tilted, a gold shockwave ring and a streak of light, 70 sparks, a camera
jolt (CameraShake), a haptic tap and the camera punching in on the player's snail, with `Match_BattleBegins`; then it
zooms out and fades, and the first turn starts. The loadout bar already shows during `Battle`.

**Where.** MatchHud's new `BattleIntro` handler and the `U_BattleIntro` block of the MatchHud gui; the old intro left
`Turn.lua`. Settings `INTRO_*` in MatchHud's `Settings.lua` (vignette 0.35, GET READY from 1.25×, slam from 2.8× and
−14° to −4°, holds 1 s, BEGINS! 15 % of the screen's height, ring 1.5× and streak 1.6× the slam's width, shake 7 settling
in 0.45 s). Match's `Phases` sets `Battle` after the landing and waits `BATTLE_INTRO_SECONDS`.

**Sounds.** Both play on the music's own classic samples (`make_classic.py`, the owner: the first builds felt "too much
AI… pixelated"): a snare roll over low strings and choir for the drop, a bright-horn "da-da-DAAA" fanfare with crash for
the landing. Approved and uploaded to the group the same day: `Match_DropIn` 73647977085419 ("Snail Drop In Drum
Roll"), `Match_BattleBegins` 123694173132397 ("Snail Battle Fanfare"); they replace that day's numpy builds.

**How to check.** Play a match: GET READY shows while the snails fall; on landing THE BATTLE BEGINS slams in with no gap
between its two lines, then the first turn starts about 2 s later.

**For the wiki.** Match: the round start (drop, landing, the new 1.8 s intro); Interface: the intro's two screens.
