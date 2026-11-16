---
title: "Other snails wear a small tag (name and health only, 0.7 size)"
date: 2026-11-16
status: open
kind: changed
pages: ["Match HUD", "Snails", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Tags.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
---

**What changed.** The owner: "small minimalistic hp and nickname". On each player's screen, only their own snail
wears the full tag (name, level, badges, health bar). Every other snail, teammates and bots included, wears a small
tag: its name and health bar at 0.7 size, with no level and no badges. The red turn arrow and the turn timer keep their
size on every snail.

**Where.** Snails' `Tags._addTag`: `OTHER_TAG_SCALE` 0.7, an `S_SmallScale` UIScale under the tag's `Overhead`;
`S_Level` and `S_Badges` hidden on others' snails. Own snail = the model's `UserId` is the local player's.

**How to check.** In a match against bots: your snail's tag shows "Lv" and your badges; the bots' tags are smaller
with only their name and bar.

**For the wiki.** Match HUD / Snails: what the tag over a snail shows, yours and everyone else's.
