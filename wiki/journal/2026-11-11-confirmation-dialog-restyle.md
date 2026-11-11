---
title: "Dialogs in the game's look: confirmation, message and Settings"
date: 2026-11-11
status: open
kind: changed
pages: ["Lobby", "Loadout", "Settings"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/WidgetManager_Confirmation/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/WidgetManager_Message/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Settings/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Settings/Preview.lua
---

**What changed.** The three windows that still had System's blue title banner now match the game's screens: one
rounded dark panel (fill 25, 25, 35) with the grey outline (130, 130, 130), the title and text in white Londrina
(Heavy Italic, black outline), and the crate shop's slanted buttons tinted.

- **The "are you sure?" dialog** (buying a loadout slot, and every other `ShowConfirmation`): **ARE YOU SURE?**, the
  question, green **ACCEPT** and red **DECLINE**. The close X is gone: DECLINE closes it, and on a gamepad B now
  presses DECLINE (it was X; A still accepts).
- **The message dialog** (`ShowMessage`, e.g. "You can't open that crate right now. Check your coins and
  diamonds."): **HEY!**, the message and one green **OK** in the middle (A on a pad). The close X is gone: OK
  closes it.
- **The Settings window** (the top bar's gear): **SETTINGS** at the top and the red close button in the top right
  corner (the EMOTES panel's), over the same dark panel. Its rows, switches and volume steppers are unchanged.

**Where.** The guis `WormBattlegrounds/WidgetManager_Confirmation`, `WormBattlegrounds/WidgetManager_Message` and
`WormBattlegrounds/Settings`: copies of System's, with the same `Name`, `U_`/`S_` ids and prefabs, exported to
StarterGui over System's. No code changed: ume's WidgetManager and Settings modules drive them as before. The old
exports are in `ServerStorage.!dump` as `<Name>_before_2026-11-11`.

**How to check.** In the lobby, press a locked loadout slot: the dialog says "Open slot 4 for 2500 coins?" over the
blurred lobby, and DECLINE closes it. Try to open a crate you can't afford: the HEY! message shows, and OK closes it.
Press the gear: the Settings window shows its groups under SETTINGS, and the red X closes it.

**For the wiki.** Lobby or Loadout: a picture of the dialog when buying a slot. Settings: a picture of the window.
Gamepad controls: B declines a confirmation, A answers OK.
