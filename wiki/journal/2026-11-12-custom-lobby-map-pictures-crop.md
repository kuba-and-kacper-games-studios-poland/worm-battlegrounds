---
title: "Custom lobby: map pictures cropped, not stretched"
date: 2026-11-12
status: open
kind: changed
pages: ["Lobby"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/CustomLobby/init.lua
---

**What changed.** The owner: the custom lobby's map pictures should be "not stretched but like fit, so they can be
slightly cut off". The map pictures are the lobby cards' wide landscapes (1024 × 272), squeezed into the custom
lobby's narrower map buttons. They now fill each button at their own shape, centred, with their sides cut off. The
active lobby cards and the teleport card still show them as before.

**Where.** The CustomLobby gui's `PREFAB | MapChoice` › `S_Icon`: `ScaleType` `Crop` (was Roblox's default,
`Stretch`), exported over `StarterGui.CustomLobby` (the old copy is in `ServerStorage.!dump.CustomLobby_old`).
MatchBoard's `Custom` still sets its `Image` from the map's `Thumbnail`.

**How to check.** Studio playtest, 2026-11-12, the lobby's Custom button: Picnic Plains, Desert, Rockslide Ridge and
Volcano Isle show undistorted, filling their buttons.

**For the wiki.** Lobby, the custom lobby: only a screenshot would change, if the page has one.
