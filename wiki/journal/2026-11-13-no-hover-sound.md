---
title: "Buttons no longer make a sound on hover"
date: 2026-11-13
status: open
kind: removed
pages: ["Sounds", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Utils/Utils/Components/Button/ButtonSound.lua
---

**What changed.** Buttons play only their click sound; the hover sound is gone (`HoverSound_*` attributes are ignored).

**Where.** Utils' `ButtonSound` component.

**How to check.** Move the mouse over the lobby's buttons: silence until a click.

**For the wiki.** Sounds: no hover sound.

**From.** The testers: "sfx when hovering in lobby around stuff is annoying".
