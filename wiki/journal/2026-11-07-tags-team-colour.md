---
title: "Tags: health in the team's colour, a team outline, and the turn timer over the active snail"
date: 2026-11-07
status: open
kind: changed
pages: ["Match screen", "Guis"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Tags.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/SnailTag/init.lua
---

**What changed.** Back to the studio's wiki ("a number and a bar above each worm's head, in its team's colour";
"name, health and outline in its team's colour"; "everyone else sees the marker and timer above that worm's head").
Before: the health bar went green to yellow to red with health, only the name had the team's colour, and the active
snail's tag showed just an arrow. Now the health number and bar are in the team's colour, every snail has an outline in
its team's colour (off once it's a ghost), and the active snail's tag shows the turn's seconds beside the arrow to every
player but its own (blank while a shot flies). The turn panel at the top still shows the timer to everyone.

**Where.** `Snails/Scripts/Client/Tags.lua`: `_refreshTag`, `_tickTimer`, the `TeamOutline` Highlight on each snail
model. SnailTag gui: `S_Active` › `S_Timer` (the gui must be exported again in Studio for it to exist). Snails'
`HEALTH_FULL_COLOR`, `HEALTH_HALF_COLOR`, `HEALTH_EMPTY_COLOR` are gone.

**How to check.** In a match with bots: each snail's health reads in its team colour with an outline; on a bot's turn
its tag counts 15 down. Checked 2026-11-07 in a Studio match, after exporting SnailTag: the health number, bar and `TeamOutline` matched each snail's `Color`; on the player's own turn their timer was hidden, and on a bot's turn its tag read 11 a second in.

**For the wiki.** Match screen → Whose turn, wind and health: the worm tags line; the tag-timer question's answer is
"On the tag too, for everyone but the active player" (the studio's original). Teams: the outline is back.

Supersedes 2026-11-05-worm-tag-health-colours (none of it still holds).
