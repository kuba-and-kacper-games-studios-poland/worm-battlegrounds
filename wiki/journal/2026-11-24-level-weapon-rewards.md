---
title: "Levels 10 to 90 make the Grenade, Shotgun and Bazooka Shiny and Golden, with an unlock screen"
date: 2026-11-24
status: open
kind: added
pages: ["Levels & XP", "Currencies & crates", "Loadout", "Shiny", "Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Global.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Scripts/Client/Unlock.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Scripts/AdminPanel/CommandBar/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/_meta/_types.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Panel.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/Picker.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Scripts/Client/Stage.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Global.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Variants.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Uses.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/LoadoutBar.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/LevelPlate/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/LevelPlate/Preview.lua
---

**What changed.** The starter weapons never drop from crates, so they could never reach 10 or 100 copies. Now levels
open their looks (the owner's pick): **Shiny Grenade at level 10, Shiny Shotgun at 20, Shiny Bazooka at 30, Golden
Grenade at 60, Golden Shotgun at 75, Golden Bazooka at 90** ("the pros at 90 level have the golden bazooka"). Shiny and
Golden both deal **+5% damage** (Golden is gold as well), and the unlock says so ("+5% damage and a pearly shine in
every match", "+5% damage, and solid gold in every match"; the Bazooka's: "the pros' solid gold"). Nothing is saved: a
player already past a reward level has its look at once.

Reaching one of those levels plays an **unlock** in the lobby's replay, after LEVEL UP!: the lobby goes dark, the
level's diamond pops up and charges (rattles, swells, light flies into it), flashes white and opens into the weapon's
card on turning rays with a burst of stars (the weapon's 3D model turning, gilded when Golden, in the Shiny foil or the
Golden rim, a "Level 90" tag), **SHINY!** or **GOLDEN!** slams in, then "Golden Bazooka unlocked", the +5% line and
**TAP TO CONTINUE**. The plate's "Next unlock" names them too ("Shiny Grenade at level 10"). The loadout's Bazooka card
wears its Shiny or Golden mark and card from its level, and **every snail on the lobby stage holds its Bazooka in its
look**: a pale outline and ForceField sheen at 30, solid gold with a gold outline at 90 (Lobby's `STAGE_WEAPON_LOOKS`),
so the pros' Golden Bazooka shows in their party.

**Where.** `WEAPON_REWARDS` and the `UNLOCK_*` keys in Progression's `Settings.lua`; `I.G_Progression.GetWeaponVariant`;
Progression's `Scripts/Client/Unlock.lua` (`Play(level)`), called from `Client.lua`'s `_levelUp`. Loadout's
`GetMatchLoadout` now marks the Bazooka (`BASIC_WEAPON`) in `ShinyItems` / `GoldenItems` by level, and every slot item by
copies or level. The `LevelPlate` gui's new `U_Unlock`, exported to StarterGui. The `progression add_level` admin
command now queues the levels for the lobby's replay, so they play back as after a match.

Gilding moved from Combat's `Variants` to `I.G_Arsenal.Gild` / `MakeCopy`, used by matches, the unlock card and the
stage (no change to how a Golden weapon looks in a match).

**Admin commands.** `progression weapon_look <player> <weapon or utility> <Golden|Shiny|None>` gives (or takes back)
any weapon's or utility's look by hand, and `progression golden_weapons <player>` gives the Golden Bazooka, Grenade and
Shotgun at once; the player gets a toast ("You got the Golden Bazooka!"). Given looks are saved (`Progression.Variants`
in the profile), sit beside the level's (the better one wins) and show everywhere: the loadout, the match, the lobby
stage. Checked in a play test at level 1: `golden_weapons` made the stage Bazooka and its loadout card Golden and the
server's match loadout Golden; `None` took it back; an unknown look is refused.

**Fixed the same day.** The unlock's rays didn't turn in game (`Utils_Motion` Spin works only on a UIGradient); they
use `Utils_UISpin` now. **A Golden weapon in a match was green with a gold glow** (the owner: "in lobby its pure gold -
but in game its mostly green"): its gold cover and sheen copies were welded with WeldConstraints made before the held
weapon entered the world (Combat's `Held` dresses it, then parents it), so they stayed where they were made, about 380
studs away, and only the outline showed. `I.G_Arsenal.MakeCopy` now welds them with a `Weld` at no offset, which keeps
them on the part in any order. Checked in a solo match (Echo Caverns): both copies on the Body, the Bazooka gold.

**The match's weapon bar shows it too.** A Shiny item's card on the match's loadout bar wears the loadout panel's holo
foil and a Golden one its gold rim (the MatchHud gui's `BarSlot` › `S_Foil`, `S_Gold`; Combat writes each item's look as
`Variant_<item>` in the player's Combat folder). Checked in a solo match: the Golden Bazooka's card had the gold rim, the
Shiny Grenade's the foil. Before, every match card was plain, crate Shiny and Golden ones included.

**How to check.** In Studio, `progression add_level <player> 9` from level 1: the replay plays nine level-ups and the
Shiny Grenade unlock (checked 2026-11-24), then `add_level 20`: Shiny Shotgun, then Shiny Bazooka, and the loadout's
Bazooka card is Shiny (checked); the server's match loadout carried `Bazooka` in `ShinyItems` (checked). On the stage, level 30 gave the Bazooka its sheen and pale
outline and level 90 turned it gold (checked in a play test, 2026-11-24). Golden's unlock screen is checked in the Gui
tool's preview only, and a match's Golden weapon after the gilding moved to Arsenal isn't re-checked in a match. The card's 3D model can't be seen in Studio's play-test captures (they don't
draw ViewportFrames); it shows in the edit-mode preview.

**For the wiki.** Levels & XP: a Level rewards row for each of the six weapon looks and the unlock screen. Currencies &
crates: "The Grenade and Shotgun never drop from crates, so they can't become shiny" is no longer true; they (and the
Bazooka) go Shiny and Golden by level. Shiny: Golden deals +5% like Shiny. Loadout: the Bazooka card can be Shiny or
Golden. Lobby: stage snails hold their Shiny or Golden Bazooka.
