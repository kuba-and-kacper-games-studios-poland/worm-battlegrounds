# 0006: Every text is rich and scaled

**Status:** Accepted
**Date:** 2026-10-28
**Deciders:** Nari

## Context

UmeGui's controls always turn on `RichText` and `TextScaled` and keep the design size in a `UITextSizeConstraint`, but
`Primitive` nodes could keep plain Roblox text. In My Tree Farm's 32 guis, 72 of 313 texts were scaled; the rest had a
fixed `TextSize`, and some grew with `AutomaticSize` or cut long text with `TextTruncate`. Nari asked for rich, scaled
text everywhere: "EVERY TEXT NO EXCEPTION".

Two days later (2026-10-30) a pixel button's label stayed 32 px while the button grew on hover and shrank on click:
`MaxTextSize` is in screen pixels, and no UIScale passes it.

## Decision

**Every `TextLabel`, `TextBox` and `TextButton`, `Primitive` nodes included, has `RichText` and `TextScaled` on**, with
its design size as the `MaxTextSize` of a `UITextSizeConstraint` and a box that fits that size. It looks the same, but
shrinks instead of spilling when its box is too small, and any text can take rich-text formatting later.

Text that grows with a press or hover scale has a box exactly its design size tall and a `MaxTextSize` of 100, so it
follows every scale on the button and its window.

Rule: `gui/format.md` → Text. ume-gui's own System guis, built before this rule, still have plain text.

## Options considered

| | A: every text rich and scaled (chosen) | B: controls only | C: plain text, fixed sizes |
| --- | --- | --- | --- |
| Text in a box too small | Shrinks | Shrinks in controls, spills elsewhere | Spills or is cut |
| Rich-text formatting | Anywhere | In controls | Turned on per label |
| Text under a press or hover scale | Follows it, with the press-scale box | Stays its size | Follows it |
| Sizing a box | Its design size, one line or every line | Mixed | `TextSize` decides |
