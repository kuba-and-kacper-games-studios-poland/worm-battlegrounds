---
title: "Getting hurt on your turn ends it, as in Worms"
date: 2026-11-12
status: open
kind: changed
pages: ["Turns", "Match modes & maps"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
---

**What changed.** While a snail's turn runs and its shot isn't away yet, any loss of health (a fall, a mine, a barrel,
fire) ends the turn at once, as if its timer ran out. Before, a snail could fall, lose health and keep playing the
turn. Damage after the shot is away belongs to the shot's flight and doesn't change anything.

**Where.** Match's `Turns` (server): the turn loop watches the active snail's `Health` attribute and stops on a drop
(`hurt`), next to the timer, the shot and `Alive`.

**How to check.** On your turn, fly the jetpack high and land: the fall damage pops and the turn passes to the next
snail. Checked in a Studio match: a 13-damage landing passed the turn to a bot.

**For the wiki.** Turns: a line that getting hurt ends your turn (the Worms rule), with falls as the usual case.
