---
title: "Tutorial hints wait for the player's own shot"
date: 2026-11-04
status: merged
merged: 2026-11-06
kind: fixed
pages: ["Lobby", "Lobby & meta modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/MatchHints.lua
---

**What changed.** The tutorial match picks who plays first at random, so the tutorial bot can take the first turn.
Its shot used to move the hints past walk, jump and fire before the player had their first turn. Now the hints
move on only when the player's own shot is in flight: walk, jump and fire stay until the player fires, and "Two hits
knock it out. Finish it!" stays until their next shot.

**Where.** `_tick()` in `Tutorial/Scripts/Client/MatchHints.lua`: the steps change on `myShot` (phase `Flight` while
`I.Match.IsMyTurn()`), not on any `Flight`.

**How to check.** Seen on the Studio map: the bot played first, and the hint stayed on "Walk with A and D, or the
arrow keys" and showed when the player's turn came.

**For the wiki.** Lobby → First time playing: the bot may play first; the hints follow the player's own turns. Still
open: whether the tutorial should always let the player go first.
