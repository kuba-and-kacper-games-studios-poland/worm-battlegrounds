---
title: "The teleport card is the studio's Loading design"
date: 2026-11-12
status: open
kind: changed
pages: ["Match modes & maps"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/TeleportGui/init.lua
---

**What changed.** The card shown while teleporting to a match or back to the lobby is the studio's `Loading`
design (ported 1:1): a dark textured backdrop, the map's picture on a dim card, and HEADING TO … in capitals. It still
slides down before the teleport and off after.

**Where.** The TeleportGui gui (`ServerStorage.Ume.UtilityGuis.TeleportGui` in the place); the Transition module fills
it, unchanged.

**How to check.** Start a match from the lobby in a published test: the card shows the map.

**For the wiki.** Match modes & maps, or Lobby: the loading card, if it's pictured. Unsure: not seen in a real
teleport (Studio doesn't teleport).
