---
title: "The snail tag keeps its health on your turn"
date: 2026-11-15
status: open
kind: fixed
pages: ["Match HUD"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Tags.lua

---

**What changed.** The tag over the active snail (name and health) hid itself once the snail moved or aimed, Worms
style, so the health seemed to disappear on the player's turn. The owner asked for it fixed: the tag now stays, and
only its turn arrow hides once the snail acts, back at the turn's end.

**Where.** Snails' client `Tags.lua` (`turn.Arrow.Visible`); the old `Hidden` field is gone; Snails' `TAG_HIDE`
setting's comment.

**How to check.** On your turn, move: the name and health stay over the snail, the arrow goes.

**For the wiki.** Match HUD: snail tags always show health; the arrow marks the snail whose turn it is until it acts.
