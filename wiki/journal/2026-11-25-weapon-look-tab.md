---
title: "Look tab: players pick Normal, Shiny or Golden for each weapon"
date: 2026-11-25
status: open
kind: added
pages: ["Loadout", "Shiny and Golden weapons", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Global.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Panel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Picker.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Matchmaking/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Roster.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Blast.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Uses.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Scripts/Client/Stage.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Loadout/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Loadout/Preview.lua
---

**What changed.** Players choose the look each weapon wears: Normal, Shiny or Golden, any look up to the best they
have. A Shiny weapon can show as Normal or Shiny; a Golden one as Normal, Shiny or Golden. In the lobby, pressing the
Bazooka's card or a slot's card opens the weapon picker and a **look tab** left of the LOADOUT column, beside that
card (the Bazooka opens the picker like any weapon, selected there; nothing can replace it, so the other cards don't
respond and EMPTY hides): a LOOK heading over three cards, the weapon in each look (plain, holo foil, gold rim). The
worn look has the white selected outline and an EQUIPPED tag (green) on its top edge; a look not had yet is locked and says how it opens ("Level 90",
"100 copies"). Pressing a look puts the weapon in it at once. The tab only appears for a weapon that has Shiny or
Golden, so new players never see it. It shuts with the picker. While the picker is open, the LOADOUT column and the
look tab are not dimmed with the rest of the lobby, and EMOTES hides. The Bazooka is now listed first in the picker
(it wasn't shown before: it has no inventory item), in its picked look.

Only the look changes: the damage follows the best look owned (Shiny and Golden both +5%), so a Golden Bazooka worn as
Normal still deals +5%. A pick holds until a better look opens (a level reward, or 10 / 100 copies), which then shows
instead.

The picked look shows everywhere a weapon is drawn: the loadout cards, the weapon picker, the lobby stage snails'
Bazooka (everyone's, on every screen), and in matches the held weapon, its shots and blasts, and the match's weapon
bar.

**Where.** Loadout's `LOOKS` setting; the `Loadout_SetLook @ (player, itemId, look)` remote (rate limit 5/s,
`I.Loadout.SetLook`); profile key `Loadout.Looks` (item id → `"Look:Best"`, e.g. `"Normal:Golden"`), mirrored on the
Player attribute `WeaponLooks` (JSON). `I.G_Loadout` (new `Loadout/Global.lua`): `GetBestLook`, `GetWornLook`,
`GetLookRank`, `GetLookUnlock`. `GetMatchLoadout` returns a fourth map, the worn looks, carried on Matchmaking's card
and the match participant as `ItemLooks`; Combat's `Blast.GetVariant` and `Uses._getVariant` read it first
(`ShinyItems` still sets the damage). The gui's `U_Looks` › `S_Cards` (`Look_CardSize`), filled with clones of
`PREFAB | Slot`.

**How to check.** In the lobby with a level of 30 or more (Shiny Bazooka), press the Bazooka card: the tab shows
Normal and Shiny, Golden locked "Level 90". Press Normal: the card, the stage snail's Bazooka and, in a match, the held
Bazooka and its shots lose their shine; damage is still ×1.05.

**For the wiki.** Loadout page: a section on the look tab (how to open it, what locked looks say), with a picture.
Shiny and Golden weapons page: "you can choose to show a plainer look; the damage bonus stays". Lobby: the stage snail
holds its Bazooka in the picked look.

**From.** The owner's request in the session of 2026-11-25 ("a tab that opens up on the left side… switch between shiny
golden and normal"), picked from three mock-ups (look tab, tag arrows, picker gems).
