---
title: "Loadout cards and the match weapon bar: a key cap, a count pill, the name at the bottom, a SHINY / GOLDEN tag, a cooldown badge; levels stop giving skins that aren't made; match_xp; quieter skipped replays"
date: 2026-11-25
status: open
kind: changed
pages: ["Loadout", "Levels & XP", "Admin commands"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Loadout/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Loadout/Preview.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Panel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Scripts/AdminPanel/CommandBar/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Global.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Picker.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/LoadoutBar.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/LevelPlate/init.lua
---

**What changed.** The loadout's slot cards give every text its own place and look (the owner: "the gui looks not
finished… the player knows what's up just by looking at it"): the slot's number is a key cap (the control hints' dark
rounded key with the grey line), the copies a quiet "x12" in a dark pill (hidden on an empty slot), the name stays the
card's title, and Shiny or Golden is a tag across the card's top edge in the variant's colours (pink holo, or gold),
the reward card's NEXT tag, instead of a loose word over the picture ("it looks out of place, just plastered there").

Levels give no skin now (the owner: "we don't have FBI agent… if it's not in the game don't grant it"): Progression's
`LEVEL_REWARDS` 25 Prisoner, 50 FBI Agent and 100 Wizard → none. Those levels still open their frames (Gold, Emerald,
Mythic); the XP replay's next-reward card shows the frame (the player's face in it) there, never the skins' stand-in
"?" picture. Players who already own one keep it. Once the skins are made, they go back in and players past those
levels get them (not built).

A new admin command plays a match's XP as after a round: `progression match_xp <player> <levels>` (0 or more) takes
the player up that many levels and 40% into the next, split into a match's lines (Match played, Victory, 3 knockouts),
and the lobby plays the replay. `add_level`'s replay no longer cuts off at once (its "Levels added" line had no tile
picture; it's the star badge now, `XP_ICONS.Admin`).

The cards' pictures sit in the slanted card's middle (they leaned left of it), the names stay inside the card, and the
count pill is bigger. The weapon picker lists the Bazooka first, marked Equipped (it was missing; it can't move to
another slot). The match's weapon bar slots follow the same layout (the owner: "3 2 TURNS 2 left - a bunch of text"):
the key a key cap top left, the uses left ("2 left", kept in words: the owner found "x2" unclear on the bar) a pill top
right, the picture in the middle (bigger, and kept its shape: it had been stretched wide, the owner: "the icons are squished"), the name along the bottom, and a cooling slot its turns left in a round badge
ringed in blue in the top right corner, the pill's place (no TURNS word), its picture greyed out (tinted 150, 150, 160, was 90, 90,
90, and 45% see-through) but still seen in the middle (the owner, on the badge over the picture: "not centered… we cant see the icon of the
item - maybe put it in the corner"), its blue charge rising as before.

The XP replay's tiles say what the number is: "+100 XP" over "Match played" (was "+100", which the owner read as a count of matches). The amounts are the server's, `MatchRewards` `XP_PER_MATCH` 100, `XP_WIN` 50, `XP_PER_KNOCKOUT` 10; level n to n + 1 costs 100 + 4 × n (`LEVEL_BASE_XP`, `LEVEL_STEP_XP`), so one match alone (100) doesn't take a new player from level 1 to 2 (104). Progression client `_addLine`.

The XP replay: a weapon look's reward card shows its Shiny foil or Golden rim ("now it looks like a normal shotgun");
the Mythic XP bars keep their rainbow left to right instead of turning (it looked broken on a thin bar); and a skipped
replay plays one level-up fanfare at the end instead of every level's at once (they stacked into a very loud burst).

**Where.** Loadout gui `PREFAB | Slot`: `S_Number`, `S_Amount`, `S_Shiny` (a Frame now) › `S_ShinyText`,
`S_ShinyGradient`, attributes `Look_ShinyTag`, `Look_GoldenTag` (were `Look_ShinyColor`, `Look_GoldenColor`); Loadout's
`Panel._drawVariant`, `Picker` (the Bazooka). MatchHud `PREFAB | BarSlot` (`S_Key`, `S_Uses`, `S_Name`, `S_Turns`,
`S_Icon`), LoadoutBar `_drawCooldown`. LevelPlate `S_NextFoil`, `S_NextGold`; `I.G_Progression.ApplyFrame(gradient, level,
holdStill)`; Progression client `skippedLevelUp`. Progression's `LEVEL_REWARDS`, `XP_ICONS.Admin`, client `_getReward` (frame before skin),
command `match_xp`.

**How to check.** A Golden Bazooka (`progression weapon_look <player> Bazooka Golden`) shows the GOLDEN tag on its
card; `progression match_xp <player> 2` plays two level-ups with three tiles; reaching level 50 gives no FBI Agent.

**For the wiki.** Loadout: how a card shows its key, copies and Shiny/Golden. Levels & XP: level rewards are frames
and weapon looks for now. Admin commands: `match_xp`.
