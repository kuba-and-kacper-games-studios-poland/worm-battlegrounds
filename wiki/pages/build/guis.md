---
title: "Guis"
summary: "Every gui Worm Battlegrounds needs, in the gui folder: what it shows, whether it's a widget or a hud, which module drives it and how it opens."
icon: frame
status: active
order: 4
type: "Plan"
tags: [build, ui]
suggestions:
  - id: hud-size
    text: "Phones and tablets differ a lot in size, and Worm Battlegrounds' match screen has a loadout bar of up to 6 boxes plus touch buttons at the edges. Add a 'Controls size' setting (small, medium, large) that scales the loadout bar and touch buttons together?"
    options: [Yes, Later, No]
  - id: rarity-colours
    text: "Worm Battlegrounds shows rarity on crate results, the loadout picker, the skins window and the odds window. Give the 5 rarities one set of colours and frames in the game's theme (Common grey, Uncommon green, Rare blue, Epic purple, Legendary gold), so every gui shows a Legendary the same way?"
    options: [Yes, No]
    status: resolved
    answer: "Built with the GUI kit (2026-11-04): a rarity is a text colour from I.Rarity, and reward tiles take their rarity's frame (silver for Common to Rare, gold for Epic and Legendary), stage and light"
    decided: 2026-11-06
  - id: colourblind
    text: "Worm Battlegrounds tells teams apart by colour (Red, Blue, Green, Yellow) on worm names, health bars and outlines. Also put a small team symbol beside each worm's name, so colourblind players can tell teams apart?"
    options: [Yes, Later, No]
---

Every gui is a table in the gui folder (`worm-battlegrounds-gui/src/guis/WormBattlegrounds/<Gui>/init.lua`, with a
`Preview.lua` and a `_meta/README.md`), built, previewed and exported with the Ume Roblox plugin's Gui tool. The rules
are the gui folder's `.claude/rules/gui/format.md` and `code.md`, and the game's decisions in
`worm-battlegrounds-game/.claude/rules/game/practices.md` → Guis; the game code that fills each gui follows the code
folder's `ume/structure.md` (a module finds its gui as `I.UserInterface.UI["<Gui>"]`). Each gui's README says its
layout (its **Look** line) and the steps after an export.

## How every gui is made

- **The look is the owner's GUI kit** (draft 4, adopted 2026-11-04), drawn by the `WormBattlegroundsBrawl` theme,
  which extends `WormBattlegrounds` (`src/themes/WormBattlegroundsBrawl/_meta/README.md`; the gui folder's
  `brawl-gui` skill makes new guis in it):
  - windows in a sea-teal gradient with a faint diamond pattern, an orange border, a tilted yellow **Hazard plate**
    title breaking out of the top-left corner and a slanted red close;
  - buttons, cards and reward frames are 9-slice skin pictures with their outline, light and lip drawn in;
  - things sit on plain see-through black **slots**; framed **reward tiles** (the rarity's stage in a silver or gold
    frame, a light behind Epic and Legendary) only for rewards being won;
  - **Londrina Solid Black** for every text; headings, titles and buttons in **capitals**, kept so when code writes
    them (the theme tags them `TextCase_Upper`, the TextCase module upper-cases what's written);
  - buttons **coloured by job**: yellow only for the next step (one per window), blue other actions, green every
    price, red leave and close, purple modes, slate tabs, grey owned or locked.
- **Picked, owned and rarity** come from the kit, not from recolouring: a button swaps to its selected or disabled
  skin, a picked slot is blue (40, 140, 255 at 0.2), a rarity is a text colour, a reward tile takes its rarity's
  frame. An owned pass's Buy turns grey and reads OWNED.
- **Built from the theme's controls** (`Widget`, `Box`, `Item`, `Cells`, `Picture`, `Label`, `Button`, `Stack`,
  `Progress`), never raw primitives, and no value controls (dropdowns, sliders, toggles): exports are static, so
  modules select buttons instead.
- **Widgets** (windows shown one at a time: shop, crates, results…) use WidgetManager's shape and open only through
  WidgetManager. Opening one blurs the scene and widens the camera's view by 5° (lobby 40° → 45°, match 30° → 35°),
  through the `FOV` buff the cameras set the base of.
- **Huds and panels** keep their own shape; their module turns their ScreenGui on while the player is in its half
  (the `InMatch` Player attribute).
- **Billboards** (`WormTag`, `DropMarker`, `DamagePop`) are templates the code clones onto worms and markers; UmeGui's
  export gives a ScreenGui, so they're wrapped as BillboardGuis after export.
- **Ids:** `U_` for elements code reaches, `S_` inside them, `PREFAB | Name` for templates code clones.
- **Exports:** to StarterGui (`TeleportGui` and `LobbyGui` then move to `ServerStorage.Ume.UtilityGuis`), keeping
  each copy's extra attributes (`Results` keeps `PreventClosing`). Some need a step after each export, in their README
  (the `Currency` slots' `Currency_UIScale` links).

## How guis fit the screen

- **Laid out for 1920 × 1080**, placed by screen fractions (`UDim2.fromScale`), hanging from a screen edge or corner.
- **Sized by `S_ScreenScale`** (the ScreenScale module, Utils): the screen's height / 1080, or its width / 1920 on a
  screen narrower than 16:9 (4:3, 5:4, tablets); ×1.3 on phones under 500 px tall; and **never under 0.6** on PC and
  console (`MIN_SCALE`), so text on a 1024 × 768 window stays 14 px and up.
- **Per device** through ume's platform tags (`Utils_PlatformScale`, `Utils_PlatformSize`, `Utils_HideOnPlatform`):
  the kit is drawn for phones, so its panels show at **0.75 on Desktop**, and on phones panels get their own sizes,
  a scrolling list, or fold behind a tab (Party).
- **World labels** scale with the screen too (`I.ScreenScale.AddBillboard`): the worm tag is 240 × 240 at 1080p,
  108 px wide on a 667 × 375 phone.
- **Checked for overlaps** at PC sizes from 1024 × 768 to 3840 × 2160, tablets, and phones down to 667 × 375.

## Lobby (Lobby map)

| Gui | Kind | Driven by | What it shows |
|---|---|---|---|
| `Lobby` | Hud | `Lobby`, `Crates`, `Cosmetics`, `Tutorial` | The gold "WORM BATTLEGROUNDS" logo (a text placeholder), `U_OpenCrates` (Crates, with `S_Badge`: FREE, a count or 9+) and `U_Skins` under the currency bar, `U_Pointer` (the tutorial's arrow). The 3D stage is behind it, not a picture |
| `MatchBoard` | Panel, bottom just right of the centre (55 %) | `MatchBoard` | `U_Play` (`S_Welcome`, `S_Solo` Play solo / Play with party, `S_Custom`, `U_Rows` with the public cards: mode, `1 / 6`, timer, Join), `U_Setup` (difficulties, the line about them, what it pays, Start, Back), `U_WaitingRoom` (match line, countdown, players, Vote to start, Leave match), in one spot |
| `Party` | Panel, top left | `Party` | `S_Tab` ("PARTY 2/4", blue and arrow up open, slate and arrow down folded), `S_Panel` with `U_Members` › `PREFAB \| Member` (avatar, name, level, crown, Kick), `U_Invite`, `U_InviteFriends`, `U_Leave` |
| `PartyInvite` | Widget | `Party` | Players here not in a party (`PREFAB \| Invitable`: avatar, name, Invite → Sent), a line when there's nobody, Invite friends |
| `PartyInvited` | Widget | `Party` | The inviter's avatar, "Name invited you to their party!", Join party (yellow), No thanks |
| `Loadout` | Panel, bottom left | `Loadout`, `Cosmetics` | A slim dark bar: `U_Emotes` (the row of owned emotes), the Bazooka box and `U_Slots` › `PREFAB \| Slot` (picture, name in rarity colour, a + when empty, `S_Lock` with only the price) |
| `Crates` | Widget | `Crates`, `Shop`, `Tutorial` | `U_CrateList` › `PREFAB \| CrateCard`, two to a row (picture, currency tabs, Open, Open 10, Details, the FREE badge), `U_TutorialCrate` |
| `Currency` | Hud, top right | `Currency` (existing), `Shop` | Coins and diamonds `Currency_Slot` counts, each on its own UIScale, short from 10,000 (`Currency_ShortFrom`); a green + that opens `Shop`. Hidden during matches |
| `CustomLobby` | Widget | `MatchBoard` | Create: map cards (`U_Maps`, `PREFAB \| MapChoice`), Deathmatch or Teams, 2–8 players. Room: members, `PREFAB \| Invitable`, Invite friends, Start (owner), Leave |
| `LoadoutPicker` | Widget | `Loadout` | `PREFAB \| ItemTile` grid of owned weapons and utilities: picture, name, rarity, `7 / 10` copies to shiny, uses and cooldown; Empty slot |
| `CrateOpen` | Widget | `Crates` | The reveal: the crate shakes, then a big reward tile (or 10) in its rarity's frame, "Shiny!" when it turned shiny; Open again |
| `CrateOdds` | Widget | `Crates` | One row per item with its rarity (in its colour) and chance, adding up to 100%, and the price |
| `Skins` | Widget | `Cosmetics` | Owned skins in 3D previews (`PREFAB \| SkinTile`), copies to shiny, Equip |
| `EmoteShop` | Widget | `Cosmetics` | `PREFAB \| EmoteRow`: picture, name, level needed, coins, Buy or Owned |
| `Shop` | Widget | `Shop` | 5 diamond packs (`PREFAB \| Pack`, prices read live, green Buy), 4 game passes with every benefit listed (OWNED when owned) |
| `SoloSetup`, `PlayModes` | Widgets | — | No longer opened: the play panel's setup replaced them. Still in the folder |

## Match (Match map)

| Gui | Kind | Driven by | What it shows |
|---|---|---|---|
| `MatchHud` | Hud | `MatchHud`, `Cosmetics` | `U_Turn` (`S_Banner` whose turn, `S_Wait` your wait, the clock and `S_Timer`, the wind picture, `S_WindArrow`, `S_Wind`), `U_LoadoutBar` (a row with `U_Stamina` and `U_Power`, then `PREFAB \| BarSlot`: picture or model, `S_Uses` "x3", `S_Key`, cooldown), `U_EmoteButton` (81 % across) and `U_EmoteWheel`, `U_Touch` (◀ ▶ bottom left, Jump bottom right, phones and tablets), `U_KillFeed` (`PREFAB \| FeedLine`, under the top bar), `U_Drop`, `U_KnockedOut` (Spectate, Leave), `U_Waiting` |
| `WormTag` | Billboard | `Worms` | Name in team colour (gold for VIP), level, a big health number over a bar coloured by health, `S_Active` (the down arrow over the active worm), `S_Emote` |
| `DropMarker` | Billboard | `Match` | A player's landing spot: name and colour, faded until placed |
| `DamagePop` | Billboard (160 × 100) | `Worms` | A damage number that rises and fades (with the `DamageNumbers` setting) |
| `Results` | Widget, `PreventClosing` | `MatchHud` | `U_Placings`: a lineup of `PREFAB \| Placing` player cards (place, avatar, name in team colour, coins); `U_Earned` (my coins and XP, the level-up line, then the stats: damage, knockouts, best shot); Rematch with votes and timer, Back to lobby |

The turn panel and drop panel show at 0.7 on phones and tablets, the kill feed at full size but 440 wide there.

## Both maps

| Gui | Kind | Driven by | What it shows |
|---|---|---|---|
| `Settings` | Widget | `Settings` (existing) | System's copy for now: Music and Sound effects volumes, Damage numbers, Camera follows the shot |
| `TutorialHint` | Hud | `Tutorial` | A speech bubble hanging from 27 % down the screen, under the turn panel (0.75 on phones); windows draw over it |
| `Notify`, `WidgetManager_Message`, `WidgetManager_Confirmation` | System copies | ume's modules | Not restyled yet |
| `TopBar` | System | `TopBar` | Unchanged; Leave and Music added by `MatchHud` |
| `TeleportGui` | Utility gui | `Transition` | The card that slides over the screen during teleports: "Heading to Picnic Plains…", "Back to the lobby…", "Back to your match…", and the map's picture when it has one (in `ServerStorage.Ume.UtilityGuis`) |
| `LobbyGui` | Utility gui | ume's transit lobby | The same card for the transit hop |

## Art the guis use

The GUI kit's 86 pictures (buttons, frames, banners, tiles, icons) are uploaded (2026-11-04) and named in the theme's
`Icons.lua` and `Skins.lua` as `rbxassetid://` ids. Still **local to the PC that built them** (`rbxasset://textures/…`,
not uploaded): the first kit's item, emote and skin pictures, and the turn panel's wind picture; other PCs show
blanks there, and a Studio update blanks them until they're copied in again. New pictures stay local until the owner
approves them, then get PrepKit's pixel-fix, are uploaded, and their ids go on their asset cards.

Still to come from the team: a logo, 6 map thumbnails, the missing item pictures (the loadout bar shows the model
meanwhile), 14 skin portraits, 9 emote icons, 4 crate pictures, a crosshair picture (it's drawn in code).

## History

:::changelog
- 2026-11-03: All 22 guis built on the `WormBattlegrounds` theme (first a placeholder look, then a flat Worms-style look with a first icon kit).
- 2026-11-04: Every gui in the owner's GUI kit look (the `WormBattlegroundsBrawl` theme), placed by screen fractions, scaled by width on narrow screens and per device; the kit's pictures uploaded.
- 2026-11-05:
  - Capitals kept on text code writes; never under 0.6 scale on PC; world labels scale with the screen.
  - The lobby redesign: the Lobby gui's logo and corner buttons, Crates as a window, the slim Loadout bar, the Party tab.
  - The match screen's single bottom row; the turn panel's name, wait, clock and wind lines; the results lineup.
  - Opening a window widens the view by 5° again.
- 2026-11-06: The play panel like RoWorld's (welcome, Play solo, four public cards, the setup in place); the PartyInvite and PartyInvited windows; the teleport card driven by Transition.
:::

::navbox{from="build"}
