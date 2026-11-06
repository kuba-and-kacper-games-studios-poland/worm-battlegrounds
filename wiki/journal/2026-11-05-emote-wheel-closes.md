---
title: "Emote wheel closes on a click or tap outside it, and when the emote button hides"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: fixed
pages: ["Emotes", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/Emotes.lua
---

**What changed.** The match's emote wheel only closed by pressing the smiley again or picking an emote, so it stayed
open over the middle of the screen across turns. It now also closes on a click or tap anywhere but a button, and when
the hud hides the smiley (knocked out, between phases).

**Where.** `Emotes._onInput` (UserInputService `InputBegan`, mouse button 1 or touch, not taken by a gui button) and
the `U_EmoteButton` `Visible` change in `Emotes.Start`.

**How to check.** In a match, open the wheel with the smiley, click the arena: it closes. Checked in Studio.

**For the wiki.** Emotes → In a match: the wheel closes when you pick, press the smiley again, or click/tap away.
