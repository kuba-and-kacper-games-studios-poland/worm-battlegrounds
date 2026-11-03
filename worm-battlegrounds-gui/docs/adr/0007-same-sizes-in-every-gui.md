# 0007: Same sizes and looks in every gui

**Status:** Accepted
**Date:** 2026-10-30
**Deciders:** Nari

## Context

My Tree Farm's guis were styled one at a time, and each picked some of its own numbers. One board had 2 px outlines on
its glass panels beside 3 px cards, and its rewards panel got one-off headers (a gold band, then a ribbon) that no
other gui used. After catching the mismatched outlines, Nari asked, in capitals, for the same sizes and element
styling across all guis.

## Decision

**Before giving an element a size or a look, reuse how the other guis and their theme's controls already draw that
kind of element.** No gui gets a one-off value, and a new look changes every gui that has that element. After changing
a gui, check it for values that differ from the rest, outline thicknesses first. A game keeps its shared values (its
outline widths, title sizes, fonts) in its own rules.

Rule: `gui/code.md` → Changing a gui.

## Options considered

| | A: shared values (chosen) | B: each gui its own |
| --- | --- | --- |
| Guis look like one game | Yes | Only by care |
| Changing a look | Every gui that has the element | One gui, the rest drift |
| Before styling | Find the existing values first | Pick by eye |
