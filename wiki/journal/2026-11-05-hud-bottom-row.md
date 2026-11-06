---
title: "Match screen: stamina and power on the loadout bar, one bottom row, readable on phones"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: changed
pages: ["Match screen"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/TutorialHint/init.lua
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/Controls/Progress.lua
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/Styles/Progress.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
---

**What changed.** The bottom of the match screen is one row now. Stamina ("Stamina 70%", on the player's turn) and
the shot's power ("Power 60%", while aiming) sit side by side in a row on top of the loadout slots, inside the same
panel, instead of stamina floating above the bar and power in the bottom-right corner. The angle reads "45°" beside
the power bar (was "Angle 45°" under it). On touch screens the walk buttons sit in the bottom-left corner and Jump in
the bottom-right, on the bar's line (Jump used to sit above the power panel); the emote button moved from left of the
bar to the right of it (81 % across). On a 667 × 375 phone the bottom row takes about 28 % of the screen's height
while aiming (was about 40 %), and no text is under 14 px: the turn and drop panels are at 0.7 of their size on
phones and tablets (were 0.6), the kill feed at full size but 440 wide there (was 0.8), and the tutorial hint at 0.75
(was 0.55), hanging from 21 % down (was 18 %) so it clears the turn panel. The bar labels keep their size on small
screens (they used to grow out of scale).

**Where.** MatchHud gui: `U_Stamina` and `U_Power` are now Stacks in a row inside `U_LoadoutBar` (code finds them
recursively in `Turn.lua` and `Aim.lua`); `U_EmoteButton` at x 0.81; `U_Touch` › `S_Left`, `S_Right`, `S_Jump` at
y 0.978; `U_Turn` and `U_Drop` `Utils_MobileScale` 0.7; `U_KillFeed` `Utils_MobileScale` 1 and `Utils_MobileSize`
440 × 320. TutorialHint `U_Hint` at y 0.21, `Utils_MobileScale` 0.75. The kit theme's own `Progress` control keeps
the status line one line tall. `Aim.lua` writes the angle as `{deg}°`.

**How to check.** In a match on your turn, stamina is a bar over the slots; drag to aim and power appears beside it
with the angle. On a phone-sized screen the bottom row doesn't touch anything and the tutorial hint sits under the
turn panel.

**For the wiki.** Match screen: where stamina, power and the angle are now, and the touch buttons' places (walk
bottom-left, Jump bottom-right); a screenshot from a phone if the page has one.
