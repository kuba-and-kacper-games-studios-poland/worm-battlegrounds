---
title: "Lobby: the loadout is a column two cards wide on the right, EMOTES is one button with Wave's icon, the Party X clears the title"
date: 2026-11-15
status: open
kind: changed
pages: ["Lobby", "Loadout & inventory", "Emotes"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Loadout/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/EmoteShop/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Party/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Panel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/Emotes.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Cosmetics/Scripts/Client/EmoteShop.lua
---

**What changed.** The owner's lobby changes:

- **LOADOUT** is a column hanging from the right edge of the screen, under the STYLE / WEAPONS / SKINS menu, with
  the cards **two a row** (the Bazooka, then slots 1 to 6: four rows at most), instead of a row of four over a row
  of three. The LOADOUT heading is right-aligned, and so are the rows: a lone last card (the locked one, usually)
  sits in the right column.
- **EMOTES** (right-aligned too) sits right under the last row of cards shown (it moves down as slots open) and is
  **one button showing Wave's icon** (the waving hand), instead of a row of every owned emote and a +. It opens the EMOTES panel as before, now placed so its right edge lines up with the loadout column's.
- In the EMOTES panel, **pressing an owned emote closes the panel and plays it** (before, owned cards did nothing
  there and emotes were played from the lobby row). Locked ones are still bought by a press.
- **PARTY**: the red Leave X now sits just after the PARTY title instead of covering its end.

**Where.** Loadout gui: `U_Loadout` (top-right anchored, 0.1354 × 0.5176 of the screen, at 0.9756, 0.2111),
`U_Slots` › `U_Row1` to `U_Row4` (right-aligned rows, 0.2261 of `U_Slots` tall, cards 0.5 wide), `U_Emotes` › `S_Shop`;
`PREFAB | Emote` is gone. Loadout's Panel puts the cards `SLOTS_PER_ROW` (now 2) a row and moves `U_EmoteSection` up
one row step (row height plus padding) for each of the four rows not shown. Cosmetics' Emotes no longer draws the lobby row
(`LOADOUT_GUI_NAME` removed); its EmoteShop plays an owned emote through `Cosmetics_PlayEmote`. EmoteShop gui:
`Right` at x 0.9756 (was 0.8906). Party gui: `S_Leave` anchored at its left, x 0.92 of the column (was right-anchored
at 1.05).

**How to check.** In the lobby: LOADOUT at the top right with two cards a row, EMOTES with one button under it
showing Wave's waving hand (`S_Shop` › `Icon`, `rbxassetid://122190966104251`); it opens the panel against the right edge; pressing Wave there closes it and the snail waves. In a party, the X sits
after PARTY.

**For the wiki.** Lobby and Loadout & inventory: the loadout's layout (two a row, on the right). Emotes: owned
emotes are played from the EMOTES panel opened by the + under the loadout. Its open question about where emotes are
bought can note the panel.
