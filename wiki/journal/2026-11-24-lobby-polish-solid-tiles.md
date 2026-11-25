---
title: "Lobby polish: solid tiles, wide FREE WEAPONS, bottom bar gaps, crate pedestal, Style showroom"
date: 2026-11-24
status: open
kind: changed
pages: ["Interface", "Lobby", "Crates"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/*/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/FreeCrate/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/FreeCrateDialog/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Crates/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Skins/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/GroupReward.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/Showcase.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/SkinsStage.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Scripts/Client/Stage.lua
---

**What changed.** The owner's look pass on the lobby (2026-11-24, "make sure all is polished up and consistent"):

- **Solid tiles and panels.** The design's navy fill pictures are partly see-through (solid only over the design's dark
  backdrop): the "+" slots, loadout cards, menu tiles, the public-matches board and every lobby window (setup, custom
  lobby, invite, emote shop, weapon picker, shop, crates, Style, waiting room, results) now draw each fill three times
  (`MainFill` copies) and the grey outline twice where no code recolours it (`StrokeFill`). The match HUD's loadout
  slots, timer, wind and EMOTES plates too (not the team portraits or turn list, whose pictures code swaps).
- **FREE WEAPONS** is one wide tile with the label on one line at STYLE's size (2.2 × its height, the menu tile's own
  picture with its ends kept and the middle stretched), sitting a menu gap left of STYLE on every screen shape (a copy
  of the menu's row in the FreeCrate gui). Its icon is now a crate with a star cut in its front (`art/ui_glyphs`'
  `freeweapons`, uploaded to the group that day: decal 90403607718877, image 95485980368344), not the gift.
- **FREE WEAPONS dialog:** the title clear of the X, LIKE and JOIN flush with the crate panel, their texts off the right
  edge, the ✓ on each step's picture, the crate clear of its label, and its twinkles spread round it (they all spawned
  on one point: `EmissionShape` was missing).
- **Bottom bar:** the public-matches cards have gaps (0.015, was a −0.0038 overlap), and the board keeps a fixed gap to
  LOCAL / CUSTOM / PLAY SOLO on wide screens (the `BottomBar` list; at 16:9 it's unchanged).
- **Crate pedestal:** drawn from shapes (a dark cylinder, a lit top with a rim, the ring in the crate's colour, 11 lamps
  evenly round its side, a soft shadow) instead of the picture with uneven studs; Showcase tints the ring's `Line` and
  `Glow`.
- **Style showroom:** the yellow ring is gone, the room behind is darkened (`Shade`), a warm `Backlight` sits behind the
  snail, and the camera centres the posed snail (SkinsStage's `_place` slides it by the bones' screen spread).
- **Stage labels** (nameplates, "+" bubbles) hide behind full-screen windows (Stage's `SetLabelsShown`).

**How to check.** In the lobby at 1080p: slots and panels are solid; FREE WEAPONS reads on one line, as tall as STYLE's
label, 14.8 px from STYLE like the other tiles; cards 19.5 px apart; the board 27 px from the buttons; the crates screen
shows the new pedestal; the Style screen's snail sits over its name.

**For the wiki.** Interface: the lobby, crates and Style screen descriptions and screenshots.
