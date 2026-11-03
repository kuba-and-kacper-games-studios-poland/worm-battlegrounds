# 0001: Windows open through WidgetManager, never a module's `Open`

**Status:** Accepted
**Date:** 2026-10-26
**Deciders:** Nari

## Context

In My Tree Farm the Upgrades and Titles modules exposed their own `Open` functions, and the hud's buttons called them.
Every window was connected its own way, and the windows were single panel frames that WidgetManager couldn't open
(ume-gui's ADR 0004 gives them WidgetManager's shape).

## Decision

**No module exposes an `Open`.** A window is a WidgetManager widget, opened by name:

- a hud button carries `Interact_Button` → `WidgetManager.Toggle`, with the window's name in `Interact_Arg1`;
- a prompt or code calls `I.WidgetManager.Open(name)`;
- the module fills its window on `WidgetManager_Opened`.

Rule: `ume/structure.md` → Locals, replicator, gui.

## Options considered

| | A: through WidgetManager (chosen) | B: each module's `Open` |
| --- | --- | --- |
| How a button opens a window | A tag and its argument, set in the gui | Code per button |
| Tweens, closing, one window at a time | WidgetManager's, the same for every window | Each module's own |
| What a module adds | A handler on `WidgetManager_Opened` | An API function and its callers |
