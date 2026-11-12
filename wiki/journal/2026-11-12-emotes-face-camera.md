---
title: "Emoting snails turn to face the camera and put their weapon away; a hit or a shot stops an emote"
date: 2026-11-12
status: open
kind: changed
pages: ["Emotes"]
files:
  - worm-battlegrounds-game/src/libs/Internal/SnailRig/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/Emotes.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Held.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
---

**What changed.** While a snail emotes it turns smoothly to face the viewer's camera and its held weapon is hidden;
when the emote ends it turns back and the weapon shows again. A hit wins: hiding in the shell ends the emote at once,
and a snail that's hiding can't start one (no bubble either). Shooting ends it at once too.

**Where.** SnailRig's `Emote` (now returns whether it plays), `StopEmote`, `CanEmote`, `FACE_TURN_EASE` (0.12);
Cosmetics' client `Emotes` checks `CanEmote` before sending and skips the bubble when a screen refuses it. A shot ends
the emote on the shooter's screen at the press (MatchHud's `Aim._fire`) and on every screen when the match enters
its Flight phase (Combat's client `Held`, on `Match_PhaseChanged`). No new remote.

**How to check.** Emote in a match: the snail turns to the camera without its weapon; fire mid-emote and it turns
back, weapon out; shoot it mid-emote and it ducks into its shell.

**For the wiki.** Emotes: the turn to the camera, the weapon put away, and that hits and shots interrupt. Checked in a
playtest with Emote_Wave and the Bazooka: the turn, the weapon hidden, and firing ending it on the shooter's screen.
Not yet seen from another player's screen.
