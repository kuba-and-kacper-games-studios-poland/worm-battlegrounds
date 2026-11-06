---
title: "Kill feed: long lines wrap onto two lines instead of shrinking"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: fixed
pages: ["Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/KillFeed.lua
---

**What changed.** A long knockout line ("Bax knocked out Ninja with the Black hole grenade") shrank to fit the feed's
width, smaller than the other lines. It now keeps its size and wraps onto a second line.

**Where.** `KillFeed._getLineCount` measures the line's text at its design size (`TextService:GetTextBoundsAsync`,
the label's `MaxTextSize` and font) against the feed's width (560 minus its padding); a line that doesn't fit gets
two lines' height. One line when the font can't be measured.

**How to check.** A knockout with a long weapon name: the line wraps right-aligned at full size. Checked in a preview
at 1717 × 966; a short live line ("Turbo fell into the water") stayed one line.

**For the wiki.** Nothing new to say; Match screen → Kill feed is still right.

**Merged.** Only a line and a History line on Match screen.
