---
title: "Turn arrow drops in; the playing snail's tag hides once it acts"
date: 2026-11-11
status: open
kind: changed
pages: ["Match HUD", "Turns"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Tags.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/SnailTag/init.lua
  - art/hud/
---

**What changed.** As in Worms Armageddon (the owner's ask, 2026-11-11):
- When a turn starts, a fat red arrow drops onto the playing snail's tag from above the screen, bounces in, then bobs
  over it. It replaces the small chevron.
- Once that snail moves, aims or shoots, its tag (name, health, arrow and the turn's seconds) hides until the turn
  ends, then comes back.
  - Moving means 0.75 studs from where its turn started.
  - Aiming means turning the aim 4° while the camera is still, or charging a shot. The aim follows the mouse
    pointer, so it drifts while the camera flies to the snail at the start of a turn. That drift doesn't count.
- Everyone sees the same, bots' turns included.
- The turn's time stays on the hud's timer.

**Where.** `Snails/Scripts/Client/Tags.lua`:
- `_startTurn`, `_stepTurn`, `_endTurn` and `_hasActed`, run from `_refreshTag` on the snail's `Active` attribute.
- Moving is read from the snail's `Root` position, aiming from its `AimTime`, `AimAngle` and `AimPower` attributes, and
  shooting from the Match phase leaving `Turn`.

Settings in `Snails/Settings.lua` → Tags:
- `ARROW_DROP_FROM` 700 design px and `ARROW_DROP_SECONDS` 0.7 (the drop).
- `ARROW_BOB_HEIGHT` 7 and `ARROW_BOB_SPEED` 6 (the bob).
- `TAG_HIDE_MOVE` 0.75, `TAG_HIDE_AIM` 4° and `TAG_HIDE_CAMERA_STILL` 0.02 studs a frame (when the tag hides).

The arrow is `S_Arrow` in the SnailTag gui's `S_Active`. Its picture is `art/hud/make_turn_arrow.py`.

**How to check.** Checked in Studio, solo vs bots on 2026-11-11: the arrow drops from 677 px above, bounces in and
bobs; the tag stays through the camera's fly-in with the mouse still, hides on walking and comes back at the turn's
end; a bot's tag hides as it aims. In a solo match vs bots:
- At the start of each turn the arrow falls in over the playing snail and bobs.
- Walking or turning the aim hides that snail's name, health and arrow.
- They come back when the next turn starts.

**For the wiki.** Match HUD: the turn arrow, and that the playing snail's tag hides while it moves and aims. Turns: how
a turn is shown.

The arrow picture is uploaded to The Snail Studio group (decal 87256015728687, image `rbxassetid://107929925047000`).
