---
title: "Skins window becomes the studio's full-screen STYLE screen"
date: 2026-11-09
status: open
kind: changed
pages: ["Skins", "Lobby"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Skins/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Skins/Preview.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/Skins.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Settings.lua
---

**What changed.** The `Skins` widget is the studio's `Customise` design, ported almost 1:1: a full-screen screen with
categories on the left (SKINS, showing the worn skin's name; HATS, SHIRTS and SHELLS say "Coming soon" and can't be
pressed), a SNAIL COLOR row marked SOON (not pressable), a BACK button (B on a pad), and a grid of every skin: the worn
one first with a green outline, then owned skins by rarity, then unowned skins under a lock. Each tile shows a 3D
preview of the skin, its name and a corner mark in its rarity's colour. Pressing an owned skin equips it.

**Where.** Ids `U_Widget`, `S_Close`, `U_Categories` › `S_Skins`, `U_Skins`; prefab `PREFAB | SkinTile` (`S_Rarity`,
`S_Name`, `S_Locked`, `S_Preview`, `Look_*` stroke attributes). Cosmetics' `Skins.lua` draws it (equips through the
`Cosmetics_Equip` remote, unchanged). Cosmetics' `LOBBY_GUI_NAME` setting removed; the gui left ScreenScale's `GUIS`
(it scales by its own screen fractions).

**How to check.** Studio play test 2026-11-09: opened from the lobby, Classic worn first, the rest locked, no errors.

**For the wiki.** Skins page: the new screen, the placeholders "Coming soon" for hats, shirts, shells and colours.
