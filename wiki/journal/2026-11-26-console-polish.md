---
title: "Console polish: cursor stays put, View toggles it, zoom buttons, zoom out to 300"
date: 2026-11-26
status: open
kind: changed
pages: ["Controls", "Match", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main/0_Console/Scripts/Client/Cursor.lua
  - worm-battlegrounds-game/src/modules/Main/0_Console/Scripts/Client/Selection.lua
  - worm-battlegrounds-game/src/modules/Main/0_Console/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Panels.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/LoadoutBar.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
---

**What changed.** From the owner's console recording and notes:

- **Lobby cursor:** the pad's free cursor no longer jumps. Nothing moves it but the left stick (and a D-pad hop it
  follows): a window opening, the home button (PLAY SOLO) and redrawn lists leave it alone, and it isn't pulled onto
  buttons any more. View (the PlayStation touchpad / Xbox View) now turns the cursor off for D-pad selection and back
  on, in place. B in a window presses its back button without moving the cursor.
- **Roblox's virtual cursor is kept off.** It fought the game's cursor, made a pad count as a PC (keyboard hints in the
  match) and left a dot in the middle of the screen in matches.
- **Weapon bar:** the D-pad and stick no longer highlight the weapon cards (they aren't selectable; LB / RB pick
  them). A selected Shiny or Golden weapon shows the white outline again.
- **Zoom:** + and − buttons under EMOTES on every device, with the D-pad up / down badges on Console; the camera zooms
  out to 300 studs (was 200), enough to see a whole rotation map.
- **Lobby:** the gear (PLAY WITH FRIENDS) tile sits over PLAY SOLO's left end, so a full loadout's EMOTES button no
  longer overlaps it.

**Where.** Console's Cursor (`Toggle`, `IsAllowed`, `_disableRobloxCursor`; `CURSOR_MAGNET*` removed) and Selection
(`_select`, `_back`, `_onNavigate`); MatchCamera's `ZOOM_MAX` 300, `ZOOM_BUTTON_STEP` 0.25, `I.MatchCamera.ZoomStep`;
MatchHud's `U_Zoom` (Panels) and the bar slot's `S_Selected` (LoadoutBar), `Selectable` off on `PREFAB | BarSlot`;
MatchBoard's `S_Friends`. MatchHud and MatchBoard re-exported to StarterGui (old copies in `ServerStorage.!dump`).

**How to check.** On a pad in the lobby: move the cursor anywhere, wait for the board to refresh; it stays. Press View:
the cursor hides and the D-pad selects; press again, it returns over the selected button. In a match: no dot, pad
badges on the HUD, the + / − buttons zoom, and zoomed fully out the whole map shows. Tested in Studio with the platform
forced to Console; not yet on a real pad.

**For the wiki.** Controls: View toggles the lobby cursor; zoom buttons and D-pad zoom. Match: the zoom buttons.
