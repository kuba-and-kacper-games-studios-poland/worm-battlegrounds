---
title: "The lobby's EMOTES row always shows your emotes (no fold button)"
date: 2026-11-12
status: open
kind: removed
pages: ["Emotes", "Lobby"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Loadout/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/Emotes.lua
---

**What changed.** The smiley button that folded and opened the lobby's EMOTES row is gone. The row always shows the
emotes the player owns (each plays when pressed), then + for the emote shop. Emotes have no equipped state: every
owned emote is in the row and on the match's emote wheel.

**Where.** `S_Smiley` removed from the Loadout gui's `U_Emotes`; Cosmetics' client `Emotes` lost its `rowOpen` flag.

**How to check.** In the lobby the EMOTES row reads Wave (and any other owned emote), then +.

**For the wiki.** Emotes and Lobby: the row and how to play an emote from it.
