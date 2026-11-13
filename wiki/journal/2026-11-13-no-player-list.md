---
title: "Tab no longer opens Roblox's player list"
date: 2026-11-13
status: open
kind: removed
pages: ["Controls & platforms", "Lobby", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Controllers/Core_Controller/Settings.lua
---

**What changed.** Roblox's player list (the Tab scoreboard) is off in the lobby and in matches.

**Where.** `Enum.CoreGuiType.PlayerList` left out of `ENABLED_CORE_GUIS` in Core_Controller's Settings.

**How to check.** Press Tab in the lobby and in a match: nothing opens.

**For the wiki.** Controls & platforms: Tab does nothing. A History line.

**From.** The testers' list, 2026-11-13: "disable tab in lobby", "disable tab in game".
