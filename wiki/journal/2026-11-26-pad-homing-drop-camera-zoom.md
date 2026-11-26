---
title: "Pad: homing missile target with the stick, cleaner lobby cursor, camera pans in the drop, zoom-out stays on the snail"
date: 2026-11-26
status: open
kind: fixed
pages: ["Controls", "Homing missile", "Match", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Settings.lua
  - worm-battlegrounds-game/src/modules/Main/0_Console/Scripts/Client/Cursor.lua
  - worm-battlegrounds-game/src/modules/Utils/Utils/Components/Button/ButtonScale.lua
  - worm-battlegrounds-game/src/modules/Utils/Utils/Components/Button/ButtonTransform.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
---

**What changed.** From the owner's two pad recordings (`art/recordings/1.mp4`, `2.mp4`):

- **Homing missile on a pad:** it couldn't be used (it waited for a click on the target). Now the right stick moves an
  open lock-on mark, starting on the nearest enemy; FIRE or RT locks it, then the launch is aimed as usual. B (or
  Esc) lets go of the target and picks again from the same spot. The readout says "Move to a target, RT to lock" (R2
  on a PlayStation pad).
- **Lobby cursor:** no more square blue selection box on top of the cursor (it sat crooked on the slanted buttons and
  once jumped onto the whole Public Matches list). The button under the cursor now does its own hover pop, the same
  as with a mouse. The D-pad's selection pops buttons the same way.
- **Drop:** the right stick moves the camera on its own while picking where to land (the rest of the match it still
  needs LT, as it aims).
- **Zoom out:** fully zoomed out, the camera stays centred on the snail instead of rising until the map's bottom
  edge meets the screen's, which had left the snail under the FIRE button.

**Where.** Aim: `_pickWithStick`, `_getStickPush`, `_getNearestEnemy`, `_fire` (locks the pick first), `_clearAim`
(lets go of a locked target first), `_clearTarget`, `_drawTargetMark`; MatchHud settings `STICK_TARGET_SPEED` 0.55,
`STICK_TARGET_MARGIN` 0.05, `TARGET_HINTS.PadPick`. MatchCamera: `FLOOR_EXTRA` 0.5 (the view may sink half a view
under the map's `Bounds`), the right stick pans in the `Drop` phase. Console's Cursor sets
`PlayerGui.SelectionImageObject` to an empty frame while it runs; Utils' ButtonScale and ButtonTransform treat
`SelectionGained` / `SelectionLost` as hover; MatchBoard's `U_Rows` is not `Selectable`. MatchBoard re-exported to
StarterGui (old copy `ServerStorage.!dump.MatchBoard_old_2026-11-26_rows`).

**How to check.** Pad, lobby: move the cursor onto PLAY SOLO; it grows a little, with no blue box. Match: select the
homing missile; the mark sits on the nearest enemy, the stick moves it, RT locks it (New target shows), B unlocks it.
Zoom fully out: the snail is near the screen's middle. In the drop, the right stick moves the camera. Tested in
Studio with the platform forced to Console and simulated stick input (the drop pan only by reading the code); not on
a real pad.

**For the wiki.** Controls: the homing missile on a pad; the right stick pans during the drop. Homing missile: how
to target on each device.
