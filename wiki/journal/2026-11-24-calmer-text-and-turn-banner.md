---
title: "Calmer turn banner; every text outline 0.06 or 0.07; FREE WEAPONS tile the menu tiles' size"
date: 2026-11-24
status: open
kind: changed
pages: ["Interface"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/*/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/FreeCrate/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/.claude/rules/game/practices.md
---

**What changed.**

- **Turn banner** (`U_TurnCallout`, the owner: "too heavy and too sloppy… text almost overlaps icon… more beautiful and
  subtle"): a strip 0.62 of the screen wide and 0.09 high at 0.3 (was the full width, 0.14 high at 0.34), its band 40 %
  see-through (was 20 %) fading over its outer thirds, lines 3 % of its height (was 4.5 %) and a little see-through, the
  avatar smaller with a thinner frame and a clear gap before the text, the title and line outlines 0.045 and 0.05 (were
  0.08). It settles calmer: from 1.12× (was 1.3×), sliding 3 % (was 6 %), on a quint ease (was a back bounce); anyone
  else's at 0.85 (was 0.8). On phones and tablets it's 0.72 × 0.15 of the screen, so the name stays readable.
- **Text outlines, every gui** (the owner: "make sure all strokes are working with each other… find a golden balance"):
  each dark text outline is 0.06 on titles of 40 px or more and 0.07 on every other label (250 outlines in 30 guis, from
  0.06 to 0.1667 before; the small names were the heaviest). The match HUD's names, turn label, stamina, power, EMOTES
  and pad hints, and the lobby's board, party, loadout, menu, nameplates, shop, crates and dialogs.
- **FREE WEAPONS tile**: the same box as STYLE (0.0672 × 0.0991 of the screen, its top at 0.1), so it's the menu tiles'
  size everywhere; it was 16 % bigger on 16:9 screens and 40 % on 4:3 tablets.

**Where.** The guis' `UIStroke` `Thickness` values; MatchHud's `CALLOUT_*` settings; the decision in the code folder's
`practices.md` (Guis → "Every text outline has one of two weights").

**How to check.** In Studio's device simulator (iPhone 7, iPhone 17 Pro, iPad 6th generation, Xbox One) the lobby fits
with no overlaps, and FREE WEAPONS measures what STYLE does (129 × 107 px on a 1080p screen).

**For the wiki.** Interface: the turn banner's description and any screenshots of the lobby or HUD.
