---
title: "A walking snail is never stuck in its shell"
date: 2026-11-12
status: open
kind: fixed
pages: ["The game", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Motion.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Settings.lua
  - worm-battlegrounds-game/src/libs/Internal/SnailRig/init.lua
---

**What changed.** The owner saw bots walking while still hidden in their shell: "when snail starts walking it
shouldn't be in the shell, the animation should get cancelled".

- **The cause.** A snail hid in its shell while it moved faster than 25 studs a second (`HIDE_SPEED`) without
  `CanMove`, and came out only once nearly still (under `SHOW_SPEED`, 2). Bots never get `CanMove` (only a player's
  snail does), so a bot's own jump hid it, and a bot that kept walking never slowed enough to come out. A snail hit
  just before its turn could be stuck the same way.
- **Now.** The active snail's own jumps and falls never hide it (its `Active` attribute, not `CanMove`); a snail
  already hidden stays hidden while it still flies fast. One second after it hid (`HIDE_SECONDS`), a snail comes out
  once it's nearly still, or, when it's the active snail, as soon as it walks along the ground.
- **No overlap.** When a snail starts walking, SnailRig stops the shell's `Hide` and `Show` animations, so the walk
  never plays over the shell; a snail coming out to stand still still plays `Show`.

**Where.** `_step` in `Snails/Scripts/Client/Motion.lua`; `SetMotion` in `src/libs/Internal/SnailRig/init.lua`. The
numbers are unchanged: `HIDE_SPEED` 25, `SHOW_SPEED` 2, `HIDE_SECONDS` 1.

**How to check.** Studio bot match, 2026-11-12: over 16 turns no active snail moving along the ground had `Hide` or
`Show` weighing in on its Animator. A bot jumping at the start of its turn stays out of its shell.

**For the wiki.** The game (the snail): a snail hides in its shell when hit or thrown and comes out when it walks. Only
a sentence, if the page describes the shell.
