---
title: "Phones: Roblox's thumbstick and jump button no longer cover the lobby"
date: 2026-11-13
status: open
kind: fixed
pages: ["Controls & platforms", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Utils/CharacterPark/Client.lua
---

**What changed.** The owner, on a phone: "when I'm in lobby on phone, I have jump button and joystick for moving over
UI". Roblox still spawns each player's avatar (CharacterPark parks it anchored below the arena), so Roblox's default
touch controls showed for it. Those controls moved nothing anyone could see and sat over the lobby's guis. They are now
turned off on every client, so they show neither in the lobby nor in a match. The snails' own touch controls (the match
HUD's walk, jump and FIRE buttons) are the game's gui and stay as they were.

**Where.** CharacterPark's new `Client.lua` sets `GuiService.TouchControlsEnabled = false` in `Init`.

**How to check.** Play on a phone, or in Studio with a phone emulated (Test → Device): the lobby shows no thumbstick
and no jump button, and in a match only the HUD's own buttons show. Not checked yet: Studio was in a playtest
when this was written. Lint passed.

**For the wiki.** Controls & platforms: on touch screens the only controls are the game's own buttons (no Roblox
thumbstick or jump button).
