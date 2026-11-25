---
title: "Weapon bar: cooling slots count their turns and charge up"
date: 2026-11-25
status: open
kind: changed
pages: ["Match HUD", "Cooldowns"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/Preview.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/LoadoutBar.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
---

**What changed.** A slot cooling down used to show a bare number over its darkened icon, overlapping the weapon's name.
Now it shows the turns left big over the icon with TURNS (TURN at 1) in the name's place, and its card fills in blue
from the bottom as the turns pass, with a brighter line on top of the fill. When the cooldown ends the card flashes
white. The number never goes above the weapon's own `Cooldown` (Combat's count is one higher right after a shot, until
the player's next turn starts, so the bar used to say 4 for the homing missile's 3-turn wait).

**Where.** The gui's `PREFAB | BarSlot`: `S_Turns` (moved up, black outline), `S_TurnsLabel`, `Background` › `S_Charge`
(the card's own fill picture, blue (110, 175, 255), cut by its `UIGradient`), `S_ReadyFlash`. LoadoutBar's
`_drawCooldown`; Settings' `COOLDOWN_CHARGE_BODY` (0.5), `COOLDOWN_CHARGE_EDGE` (0.05), `READY_FLASH_TRANSPARENCY`
(0.35), `READY_FLASH_TWEENINFO` (0.5 s). Exported to StarterGui the same day.

**How to check.** In a match with the homing missile (Cooldown 3) in the loadout: on the first turn its slot shows 3
TURNS and no fill; 2 TURNS a third filled; 1 TURN two thirds; then it flashes and shows its name again. Checked in a
Studio play test on 2026-11-25 (slots set by hand on the client).

**Uses left.** The count under a slot read "x2", which the owner found unclear ("no idea why we have 2x there"); it
now reads "2 left", the uses left this match (LoadoutBar's `_refreshBoxes`, `S_Uses`), empty for the Bazooka
(unlimited), the Jetpack's fuel still "75%".

**For the wiki.** Match HUD: how a cooling weapon looks on the bar, and "2 left" under a slot.

Superseded in part by 2026-11-25-loadout-card-labels-and-level-skins: the slot's texts moved (key cap, uses pill, name
at the bottom) and the cooling slot shows its turns in a round badge with no TURNS word; the charge and the flash hold.
