---
title: "Less waiting between turns: settle 0.5 → 0.3 s (at most 8 → 6 s), bots think 0.8–1.5 s, blast holds 1 s / 1.6 s"
date: 2026-11-10
status: open
kind: changed
pages: ["Match modes & maps", "Controls & platforms", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Settings.lua
---

**What changed.** The match moves on sooner after a shot, and bots play faster.

| What | Setting | Before | Now |
| --- | --- | --- | --- |
| How long snails, debris and shots must be at rest before the next turn | Match `SETTLE_HOLD` | 0.5 s | 0.3 s |
| The longest the match waits for them to settle | Match `MAX_SETTLE` | 8 s | 6 s |
| How long a bot thinks before it moves and aims (random between) | Bots `THINK_TIME` | 1.2–2.2 s | 0.8–1.5 s |
| How long a bot's crosshair swings to its shot | Bots `AIM_TIME` | 1.5 s | 1.2 s |
| The least time the camera stays on a blast it followed | MatchCamera `BLAST_HOLD` | 1.5 s | 1 s |
| The same for a big blast (radius 6 or more) | MatchCamera `BIG_BLAST_HOLD` | 2.5 s | 1.6 s |

**Where.** `Match/Settings.lua`, `Bots/ServerSettings.lua` (server only), `MatchCamera/Settings.lua`. The camera still
stays on a blast until the next turn starts (`2026-11-10-camera-keeps-your-snail-in-view`); only the least hold is
shorter. Supersedes the hold numbers (1.5, 2.5) in that entry and in `2026-11-09-camera-holds-on-blasts`.

**How to check.** Read the values in the three files. In a Studio match against bots, a turn follows a blast sooner
and bots fire sooner. Not checked in Studio by the docs pass.

**For the wiki.** Match modes & maps (turns): the settle numbers. Controls & platforms (the camera): the blast holds.
Match modules: the Bots and Match settings rows.
