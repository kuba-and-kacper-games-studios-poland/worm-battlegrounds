---
title: "Console HUD: RT on FIRE, LB / RB by the cards, no stray keycaps"
date: 2026-11-25
status: open
kind: fixed
pages: ["Controls", "Match"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/LoadoutBar.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
---

**What changed.** The owner, playing on a pad: no shoot button, and buttons behind the weapon bar and on its sides.
Three fixes on Console:

- Two big LB / RB keycaps showed behind the middle of the weapon bar. They were the framework hotbar's
  (`BackpackPlus`), whose module is off on every map (`ALWAYS_OFF`) but whose ScreenGui was still in StarterGui, so
  the Console module showed its hints. The gui now sits in `ServerStorage.!dump`.
- The weapon bar's LB / RB hints sat at the bar frame's fixed ends, far from the cards when the loadout is short.
  They now stand right outside the first and last card, whatever the number of weapons.
- FIRE carries an RT badge in its top right corner (a copy of the EMOTES button's X badge), so a pad player sees how
  to shoot. FIRE still shows only on the player's turn with an aim locked; RT fires as before.

**Where.** `_rebuild` in MatchHud's `Scripts/Client/LoadoutBar.lua` places `S_PrevHint` / `S_NextHint`; the MatchHud
gui's `U_Fire` › `PadHint` (`Console_Action` `Fire`), exported to StarterGui. The place holds the gui moves: save it.

**How to check.** On Console (or Studio with `I.Platform.Current` forced to Console), in a match on your turn: RT on
FIRE, LB and RB next to the end cards, nothing behind the bar. Not yet tried on a real pad.

**For the wiki.** Controls: the pad's RT shoots (badge on FIRE), LB / RB switch weapons.
