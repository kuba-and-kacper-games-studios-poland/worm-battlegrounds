---
title: "Knocked-out snails turn into a glowing ghost that floats up 9 studs and fades"
date: 2026-11-10
status: open
kind: changed
pages: ["Match modes & maps", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Ghost.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Server/Health.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Shell.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
  - worm-battlegrounds-game/src/global_data/Sound/SoundsList.lua
---

**What changed.** A knocked-out snail used to turn 0.6 see-through and slide 4 studs up over 1.5 s, and stayed there.
Now each screen plays a ghost: a flash of pale light (a Highlight) with a puff and a rush of air, then it floats 9
studs up over 1.8 s, bobbing side to side and swaying, fades out from 30% of the way up, and vanishes in a small
puff. A snail knocked out in the sea no longer breaks its shell as it goes. When a turn ends
with a knockout, the next turn waits the ghost's 1.8 s, so it's seen before the camera moves on.

**Where.** New client handler `Snails/Scripts/Client/Ghost.lua` (`Snails_Client_Ghost`, started from `Snails/Client.lua`):
on `Alive` → false it adds a Highlight named `Ghost` (`GHOST_COLOR` (205, 235, 255)), plays the `Spawn` effect and the
new sound `Snail_Ghost` (id 9113080102, ProSoundEffects "Airy Pass By", in `SoundsList.lua`), moves the ball on
`RenderStepped` and fades the skin's `LocalTransparencyModifier`; a snail already out when it streams in is hidden at
once. Snails settings: `GHOST_RISE` 4 → 9, `GHOST_TIME` 1.8 (replaces `GHOST_RISE_TIME` 1.5), new `GHOST_BOB` 0.5
(studs), `GHOST_BOB_RATE` 1.2 (a second), `GHOST_SWAY` 10 (degrees), `GHOST_FADE_FROM` 0.3, `GHOST_COLOR`; removed
`GHOST_TRANSPARENCY`. `Health.Kill` sets `Alive` false and `Ghost` true before `Health` 0, and no longer sets the
skin's Transparency or tweens the ball up. `Shell._refresh` skips snails not `Alive`. `Turns.RunTurn` waits
`GHOST_TIME` when `_resolveDeaths` (which now returns a count) knocked any out. Supersedes the knockout look in
`2026-11-03-worms`.

**How to check.** In a Studio match, `snails kill`: the snail glows, puffs, floats up wobbling and disappears; the
sound plays. Not checked in Studio by the docs pass (the sound id was checked to load on 2026-11-10). Unsure: a fall
into the sea may still pop a damage number over the ghost (`Tags`' DamagePop doesn't check `Alive`).

**For the wiki.** Match modes & maps (knockouts): the ghost floats up and vanishes. Match modules: Snails' new
`Ghost` handler and settings; the `Snail_Ghost` sound.
