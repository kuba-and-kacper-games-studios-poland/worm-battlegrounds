---
title: "Panels scale by width on narrow screens, and per device through ume's PlatformScale"
date: 2026-11-04
status: open
kind: changed
pages: ["Guis"]
files:
  - worm-battlegrounds-game/src/modules/Utils/ScreenScale/Client.lua
  - worm-battlegrounds-game/src/modules/Utils/ScreenScale/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/<Gui>/Preview.lua (13 previews)
---

**What changed.** The ScreenScale module sizes every gui panel (each `S_ScreenScale` UIScale in its `GUIS` list) by
the smaller of screen height / 1080 and screen width / 1920. Before, it used height / 1080 alone, so on screens
narrower than 16:9 (4:3, 5:4, tablets) the lobby's side-by-side panels ran into each other. On 16:9 and wider
screens nothing changes. Short phones (under 500 px tall) still get ×1.3.

A panel can also be sized per device with ume's `Utils_PlatformScale` tag (attributes `Utils_DesktopScale`,
`Utils_MobileScale`, `Utils_ConsoleScale`, `Utils_VRScale`). That component writes the device's scale on the same
UIScale and keeps it in `Utils_BaseScale`; ScreenScale multiplies the screen's scale by it, and puts the product back
whenever the component writes over it. The game's guis, now in the GUI kit look, are tagged 0.75 on Desktop (the
kit is drawn for phones) and have their own sizes on phones (journal entry "Every gui now has the GUI kit look").

**Where.** `_applyScale` and `_fitScale` in `ScreenScale/Client.lua`; settings `DESIGN_WIDTH = 1920` and
`BASE_SCALE_ATTRIBUTE = "Utils_BaseScale"` beside `DESIGN_HEIGHT = 1080`, `SMALL_SCREEN = 500` and
`MOBILE_BOOST = 1.3`. The game's gui previews copy the width rule and the device scale (`DESIGN_WIDTH` and
`_applyScreenScale` in each `Preview.lua`), so the Gui tool matches the game.

**How to check.** In a 1024 × 768 window the lobby's Play panel and Crates don't touch; at 1920 × 1080 every panel
is the size it was. In a play test, tagging a panel `Utils_PlatformScale` with `Utils_DesktopScale = 0.75` leaves its
`S_ScreenScale` at the screen's scale × 0.75 (checked: 0.972 → 0.729 in a 1881 × 1050 window).

**For the wiki.** Guis → how guis fit the screen: laid out for 1920 × 1080, placed by screen fractions, scaled by
height or by width on narrower screens, ×1.3 on short phones, and per device through ume's platform tags.
