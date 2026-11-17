---
title: "Lobby windows: the setup and the free crate dialog blur like the custom lobby, windows hide what they overlap"
date: 2026-11-17
status: open
kind: fixed
pages: ["Lobby", "Solo vs bots", "Local play", "Loadout"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Setup.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchSetup/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/FreeCrateDialog/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/FreeCrate/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/GroupReward.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Settings.lua
---

**What changed.** Two fixes the owner asked for after playing the polish pass:

- "Custom lobby makes the screen fade and blur, but the local one does not - same with Play Solo": the solo, party
  and local setup is now its own WidgetManager window, the `MatchSetup` gui (it was a frame, `U_Setup`, inside the
  `MatchBoard` gui), so it opens like the custom lobby: WidgetManager's open tween and sound, the world blurred
  (`BLUR_AMOUNT` 14) and dimmed (0.5), the board sliding away and the Loadout column hidden. Opening another window
  (the shop, crates) closes it.
- "The guis are overlapping when we click weapon selection - make sure they hide": while the weapon picker
  (`LoadoutPicker`, the INVENTORY window) is open, the top row (STYLE / WEAPONS / SKINS with FREE WEAPONS, the coins and
  diamonds, the level plate) and the ACTIVE LOBBIES board hide; Party and the Loadout column stay. Before, the level
  plate and FREE WEAPONS drew over the window and the menu, coins and board showed around it.

**Where.** Lobby's `PANEL_WIDGETS` (now any lobby guis per widget): `EmoteShop`, `CustomLobby`, `MatchSetup` → Loadout;
`LoadoutPicker` → Lobby, MatchBoard, Currency, LevelPlate. MatchBoard's `SETUP_GUI_NAME` = `"MatchSetup"`; `Setup.Open`
calls `I.WidgetManager.Open`, and the board slides on `WidgetManager_Opened` / `_Closed`. The setup's look, ids and
buttons are unchanged (the custom lobby's window).

**How to check.** In the lobby: press a Loadout slot; the INVENTORY window shows alone in the middle with Party and
Loadout beside it, and everything returns on ✕. Press LOCAL or SOLO VS BOTS: the stage blurs and darkens behind the
window as it does for CUSTOM. Checked in Studio (2026-11-17): picker open → Lobby, MatchBoard, Currency, LevelPlate and
FreeCrate off, blur on; Local play → blur 14, dim 0.5, Loadout off.

**For the wiki.** Lobby: windows blur the stage behind them; the weapon picker's screenshot without the top row.

**Added the same day (the owner: "yes, do it").** The FREE WEAPONS dialog is a WidgetManager window too, the
`FreeCrateDialog` gui (it was `FreeCrate`'s `U_Dialog`; `FreeCrate` keeps the lobby tile and the crates screen's
badge). It opens with the blur and dim and the open sound, and the top row and the board hide while it shows, so it no
longer half-covers the FREE WEAPONS tile. Opened from the crates screen's badge, closing it goes back to the crates
screen; CLAIM opens the crates screen in its place and the free crate opens there as before. Crates' setting
`GROUP_DIALOG_GUI_NAME` = `"FreeCrateDialog"`; Lobby's `PANEL_WIDGETS` gains `FreeCrateDialog`. Checked in Studio: from
the tile (blur on, top row and board hidden, rays turning, X back to the lobby), from the badge (X back to the crates
screen with the badge), and CLAIM from the badge (the crate waiting on TAP TO OPEN, the tile and badge gone).
