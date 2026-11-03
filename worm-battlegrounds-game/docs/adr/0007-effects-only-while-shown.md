# 0007: Gui effects run only while they show

**Status:** Accepted
**Date:** 2026-11-01
**Deciders:** Nari

## Context

The Utils visual components (`Utils_UIGradientMove`, `Utils_UISpin`, `Utils_UIHover`, `Utils_UIShake`…) already left
their loop while hidden, through `GuiVisibility`. Nothing else in My Tree Farm did: preview components moved every
element they had built, shown or not; each `Currency_Slot` kept a Heartbeat for the whole session; the billboard
stroke scaler resized hidden strokes ten times a second; and a menu's badges kept pulsing after it closed. A window
with 22 animated tiles made the cost plain. Nari asked for every gui to turn its effects off while it isn't visible,
"so it'll not lag if a lot of guis has the effects turned on".

When titles with split, moving letters came into the game (2026-11-02), the same request covered low-end devices.

## Decision

**Anything that moves a gui every frame or on a loop runs only while every GuiObject from it up is `Visible` and its
ScreenGui, BillboardGui or SurfaceGui is `Enabled`.**

- A component follows that with `GuiVisibility.Watch`; `GuiVisibility.IsShown`, made public for it, answers once for
  work on a timer.
- A module's loop runs only while something moves or its gui shows. An endless tween stops when its window closes.
- A heavy effect also skips what nobody can see while it shows (scrolled out of its list, beyond a billboard's
  `MaxDistance`, off the screen), and reads layout and writes properties only when they change.

Rule: `ume/components.md` → Effects only while shown.

## Options considered

| | A: only while shown (chosen) | B: always running |
| --- | --- | --- |
| Cost of a closed window | Nothing | Every effect it has |
| Code per effect | A visibility watch | None |
| Effects that must run hidden | Not allowed | Possible |
