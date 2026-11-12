---
title: "Lobby emote and chat bubbles sit just over the snail (0.86 studs lower)"
date: 2026-11-12
status: open
kind: fixed
pages: ["Emotes", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/ChatBubbles/Client.lua
---

**What changed.** On the lobby's stage, an emote's thought cloud (and chat bubbles) floated well above the snail's
eyestalks. They now start `STAGE_GAP` (0.6 studs) over the top of the snail's Body, eyestalks included: 2.89 + 0.6 =
3.49 studs over its RootPart, down from 4.35. The old height came from the skin's bounding box, which reaches the
shell's rest place, high above its back.

**Where.** ChatBubbles' client `_getAnchor` (the lobby branch); in a match the bubbles still sit over the snail's tag.

**How to check.** Emote in the lobby: the cloud's trail starts just over the eyestalks.

**For the wiki.** Nothing new to say beyond where the cloud shows; a fresh screenshot for Emotes if it has one.
