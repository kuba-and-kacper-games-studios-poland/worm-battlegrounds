---
title: "Mute music button on the lobby's top bar"
date: 2026-11-13
status: open
kind: added
pages: ["Lobby", "Settings"]
files:
  - worm-battlegrounds-game/src/modules/Main_Controllers/TopBar_Controller/Client.lua
---

**What changed.** The lobby's top bar has a music button (left side) reading "Mute music" or "Play music". It sets the `Music` setting to 0, and back to the volume it had (or the setting's default). It hides in a match, which has its own Mute music button (MatchHud's TopBar).

**Where.** TopBar_Controller's Client: `_toggleMusic`, `_refreshMusicButton`, refreshed on the `InMatch` attribute and the Settings folder's `Music`.

**How to check.** In the lobby press it: the music stops and it reads Play music; press again and it comes back at the old volume.

**For the wiki.** Lobby: the top bar's music button. Settings: it writes the Music volume.

**From.** The testers: "mute music button in lobby - topbar".
