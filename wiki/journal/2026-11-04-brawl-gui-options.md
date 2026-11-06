---
title: "Every gui now has the GUI kit look (draft 4, Hazard plate windows)"
date: 2026-11-04
status: merged
merged: 2026-11-06
kind: changed
pages: ["Guis"]
files:
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/ (all 22 guis)
  - worm-battlegrounds-gui/.claude/skills/brawl-gui/SKILL.md
  - worm-battlegrounds-game/src/modules/Main_Game/Crates/Scripts/Client/ (Panel, Odds, Reveal)
  - worm-battlegrounds-game/src/modules/Main_Game/Loadout/Scripts/Client/ (Panel, Picker)
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/ (Solo, Custom)
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/LoadoutBar.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Shop/Client.lua
---

**What changed.** The game's guis have a new look, the owner's GUI kit, draft 4. It was tried first as a design
option for every gui (`01_Brawl`), then moved into the game's guis, exported into the place and wired to the game
code the same day. (The first Brawl Stars-style options, royal-blue panels in Fredoka One, were rejected before
that.) The `WormBattlegroundsBrawl` theme draws windows in a sea-teal gradient
with a faint diamond pattern, an orange border, a tilted yellow "Hazard plate" title breaking out of the top-left
corner and a slanted red close; buttons, cards and reward frames are 9-slice skin pictures with the outline, light
and lip drawn in; things sit on plain see-through black slots; framed reward tiles (the rarity's stage inside a
silver or gold frame, light behind epic and legendary) are only for rewards being won; Londrina Solid Black for all
text. Buttons are coloured by job: yellow only for the next step (one per window), blue for other actions, green for
every price, red to leave or close, purple for modes, slate for tabs, grey for owned or locked.

All 22 guis kept their Ids and prefab names. Layout changes beyond the theme, per gui, are in each gui's
`_meta/README.md` (its **Look** line); the main ones a player sees:

- **Lobby:** Party (top left) above Loadout (bottom left, owned items on slots, rarity as the name's colour), the
  currencies on a dark pill with a green +, Play in the middle (Play solo the big yellow, open matches as purple cards
  with a blue Join), Crates on the right (currency tabs, green Open / Open 10, blue Details).
- **Match:** the hud blocks (turn, loadout bar, stamina, power) are dark see-through slots with no frame; Jump is blue.
- **Shop:** packs and passes on slots with green prices and a green Buy; no yellow.
- **Crate opening:** the reward tiles; one result is a big tile.
- **Solo setup, picker, emotes, skins, custom lobby, results:** slots or cards, one yellow at most.

**Sizes on a PC.** The kit is drawn for phones, so on a PC its windows and panels show at 0.75 of their size: each
carries ume's `Utils_PlatformScale` tag (Desktop 0.75, 1 elsewhere), which the ScreenScale module multiplies with
the screen's scale (journal entry "Panels scale by width on narrow screens"). Panels are placed by screen fractions,
so their positions scale with the screen as their sizes do. The lobby and the
match were checked for overlaps at PC sizes from 1024 × 768 to 3840 × 2160, and laid out again until nothing
touched:

- **Lobby:** the tutorial hint hangs from 18 % down the screen and Play hangs from the bottom, so the hint no longer
  covers Play; Crates is 560 wide (was 600).
- **Match:** the kill feed sits under the top bar (6.7 % down) and scales with the screen; the emote button scales
  too and sits at 21 % across; stamina is at 79 % down, high enough to clear the loadout bar on a phone. The phone
  walk and jump buttons are sized by the screen's height (they were fixed 120 × 112 px).
- **Phones and tablets:** panels hang from screen edges and corners, and on Mobile get their own sizes and scales
  through ume's platform tags: Party 460 × 360, Loadout 500 × 420 at 0.9, Play 560 × 600 at 0.9 (its "Public
  matches" heading hidden), Crates 520 × 820 at 0.9, the hint 0.55, the turn panel 0.6, the kill feed 0.8, Large and
  Screen windows 0.8 and 0.78. The walk and jump buttons scale with the screen. Nothing overlaps at phone sizes down
  to 667 × 375, tablets or PCs.

The pictures (icons, skins, banners, tiles) are the kit's SVGs (game home `assets/_inbox/ui_kit_brawl/`), rendered
into Studio's local content folder (`rbxasset://textures/wb_brawlpreview/…`); nothing is uploaded.

**How the game shows picked, owned and rarity now.** Code no longer recolours a piece's face:

- **Crates:** the paying currency's tab wears the blue selected skin, the other the slate one. The crate reveal's
  tiles take their rarity's frame (silver for Common to Rare, gold for Epic and Legendary), stage and light; the
  rarity line is in the rarity's colour, as on the odds list.
- **Solo setup, Custom lobby:** the picked difficulty and map sit on a blue slot (rgb 40, 140, 255 at 0.2
  transparency; others black at 0.7); the picked mode and player count wear the blue skin.
- **Match:** the selected loadout slot is the same blue slot.
- **Shop:** an owned pass's Buy turns grey and reads OWNED.
- **Loadout and picker:** an item's name (slots) or rarity (picker) is in its rarity's colour; an empty slot's name
  is white.
- **Tutorial hint:** windows now draw over it (it covered the top of the loadout picker).

**Where.** The theme's `_meta/README.md` (tokens, styles, the `Slab`, `Button`, `Widget` and `Item` controls, the
`Kit_*` attributes code reads, the generated `Icons.lua` and `Skins.lua`); each `src/guis/WormBattlegrounds/<Gui>/_meta/README.md`.
Code: `SELECTED_COLOR`, `SELECTED_TRANSPARENCY`, `TILE_COLOR`, `TILE_TRANSPARENCY` in MatchBoard's and MatchHud's
`Settings.lua`; `EMPTY_NAME_COLOR` in Loadout's; `_setPicked` in MatchBoard's `Custom.lua`; `_fillCard` in Crates'
`Reveal.lua`.

**How to check.** Play the place: the lobby, the crate reveal, the loadout picker, Solo, the Custom lobby and the
Shop open with the kit look and no errors (checked in a play test on 2026-11-04, PC 1881 × 1050). The kit's 86
pictures were uploaded the same day (theme `Icons.lua`, all `rbxassetid://`) and draw the same in a play test.

**For the wiki.** Guis → "How every gui is made" → The theme (the kit's look, Londrina Solid, colour by job, slots
versus reward tiles, how picked and owned show), the guis' pages' pictures, and a History line. Still unsure:
the item, emote and skin pictures from the first kit are still local previews, and the option folders
(`src/guis/WormBattlegrounds-<Gui>/`) are still on disk, uncommitted, until the owner removes them.

**Merged.** The per-gui layout details and phone sizes stay in each gui's README; the Guis page gives the rules and the main sizes.
