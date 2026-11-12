---
title: "The knocked-out dialog is the studio's KnockedOut design"
date: 2026-11-12
status: open
kind: changed
pages: ["Match screen"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Panels.lua
---

**What changed.** A knocked-out player sees the studio's `KnockedOut` design (ported 1:1), with SPECTATE (A) and
LEAVE (B), in place of the GUI kit dialog. What the buttons do is unchanged.

**Where.** `U_KnockedOut` in the MatchHud gui; `Panels.lua` connects `S_Spectate` and `S_Leave`.

**How to check.** In a Studio match (`Ume_StudioMapId` set to "Match"), get knocked out.

**For the wiki.** Match screen: the knocked-out dialog's look. Unsure: not seen in this playtest.
