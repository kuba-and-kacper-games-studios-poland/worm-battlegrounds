# 0005: Every element is anchored at its centre

**Status:** Accepted
**Date:** 2026-10-28
**Deciders:** Nari

## Context

My Tree Farm's guis placed most elements from their parent's top left (`AnchorPoint` 0, 0 and offsets from the corner,
Roblox's default), and in most guis only a few elements per window set an `AnchorPoint` at all. A UIScale pop, a press
scale or a size tween grows from an element's anchor, so those elements grew from their corner and shifted, and
positions read differently from gui to gui.

## Decision

**Every frame, text and image is anchored at its centre**: `AnchorPoint` 0.5, 0.5 at a position from its parent's
middle. An element pinned to an edge changes only that axis (at the top, `AnchorPoint` 0.5, 0 at X 0.5). Elements a
`UIListLayout` or `UIGridLayout` places keep the same anchors.

Rule: `gui/format.md` → Layout.

## Options considered

| | A: centred anchors (chosen) | B: Roblox's default, top left |
| --- | --- | --- |
| Scale, size and press animations | Grow from the middle, nothing shifts | Grow from the corner and shift |
| Reading a position | From the parent's middle, the same everywhere | From a corner, or wherever an anchor was set |
| Elements pinned to an edge | Change one axis | As before |
