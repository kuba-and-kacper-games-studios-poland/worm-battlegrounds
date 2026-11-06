---
title: "Damage numbers: billboard 160 × 80 → 160 × 100, so the number isn't cut"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: fixed
pages: ["Match screen"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/DamagePop/init.lua
---

**What changed.** The damage number's label (one line of the 80 px Display text, 100 px tall) was taller than its
80 px billboard. The billboard is now 160 × 100; "-200" fits at full size.

**Where.** `Preview` in the DamagePop gui (the billboard's size on export). Exported into the place the same day,
wrapped as a BillboardGui.

**How to check.** A hit with damage numbers on: the whole number shows, nothing cut at the bottom.

**For the wiki.** Nothing to change.

**Merged.** Only its size on the Guis page and a History line.
