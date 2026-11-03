# 0004: Windows are WidgetManager widgets

**Status:** Accepted
**Date:** 2026-10-26
**Deciders:** Nari

## Context

My Tree Farm's 18 windows (a shop, a bag, an index, an NPC's dialogue…) were each built as one panel frame (`U_Shop`,
`U_AxeShop`…). WidgetManager tweens and finds a widget by its `U_Widget`, so it couldn't open them, and each module
opened its own window its own way (ume's ADR 0001).

## Decision

**Every gui WidgetManager opens is built in WidgetManager's shape**, as `System/WidgetManager_Message` is: a Folder
holding a transparent `U_Widget` (with `Bg_Bottom` for the look, `Bg_Top` for the header, `Content` for the rest) and a
`MouseLockFix`. The exported ScreenGui starts hidden, its close button closes through WidgetManager, and buttons open
it by name through WidgetManager's tags. Guis WidgetManager doesn't open (huds, toasts, prompts, world guis) keep their
own shape.

Rule: `gui/format.md` → Widgets.

## Options considered

| | A: WidgetManager's shape (chosen) | B: a panel frame per window |
| --- | --- | --- |
| WidgetManager opens, tweens and closes it | Yes | No |
| Where its look lives | `Bg_Bottom`, apart from the elements | Mixed with the elements |
| Finding elements | Under `U_Widget`, the same in every window | Under each window's own root |
