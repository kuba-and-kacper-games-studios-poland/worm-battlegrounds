---
title: "Fixed: a snail that blew itself up vanished, and the match went back to the lobby"
date: 2026-11-13
status: open
kind: fixed
pages: ["Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Scripts/Server/Effects.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Scripts/Server/Control.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Server/Health.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/AdminPanel/CommandBar/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Blast.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Rocket.lua
---

**What changed.** A snail thrown by its own shot (a full-power Bazooka straight down) no longer disappears, and the
match no longer sends everyone back to the lobby on the next turn. Found by the owner in a custom deathmatch, alone
with three Easy bots: Output said `Bodies:333: attempt to index nil with 'AssemblyLinearVelocity'` (or `Control:92`
on `Position`), then Match's "couldn't play!".

**Why it happened.** A thrown snail's ball is anchored while it flies the game's own flight. The shot ends the turn
mid-flight, and SnailControl's `ClearTurnEffects` reset the ball's `Lift` force from `AssemblyMass`, which is
infinite for an anchored part. When the snail landed and its ball was unanchored, the infinite force turned its
position NaN and Roblox deleted the snail; the next turn's look at it errored, and Match's `Play` failure sends
everyone to the lobby.

**Where.** Every force on a snail's ball now uses `root:GetMass()`: `ClearTurnEffects` and the LowGravity potion in
SnailControl's `Effects.lua`, the jetpack's lift check in `Control.lua`, the knock throw in Snails' `Health.lua`, the
admin fling command, and the knockback in Combat's `Blast.lua`. Combat's `Rocket.lua` pushes snails a piercing shot
passed with `Vector3.yAxis` when the shot has stopped (its zero speed's `.Unit` was NaN).

**How to check.** In a custom lobby with bots, fire the Bazooka at full power straight down at your own feet: the
snail flies, lands, keeps its health bar, and the next turn starts. Checked in Studio: one flight, one landing, the
snail alive at 171 health, `Lift` back to 812.5 up, the match on.

**For the wiki.** Match modules (Snails, SnailControl): a History line that a self-hit snail no longer vanishes and
kicks the match back to the lobby. Nothing changes for players beyond the bug.
