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
  - id: colourblind
    text: "Worm Battlegrounds tells teams apart by colour (Red, Blue, Green, Yellow) on worm names, health bars and outlines. Also put a small team symbol beside each worm's name, so colourblind players can tell teams apart?"
    options: [Yes, Later, No]
---

Every gui is a table in the gui folder (`worm-battlegrounds-gui/src/guis/WormBattlegrounds/<Gui>/init.lua`, with a
`Preview.lua` and a `_meta/README.md`), on the `WormBattlegrounds` theme, built, previewed and exported with the Ume
Roblox plugin's Gui tool. The rules are the gui folder's `.claude/rules/gui/format.md` and `code.md`; the game code
that fills each gui follows the code folder's `ume/structure.md` (a module finds its gui as
`I.UserInterface.UI["<Gui>"]`).

## How every gui is made

- **Widgets** (menus shown one at a time: shop, crates, results…) use WidgetManager's shape: `Root` → `U_Widget`
  (`Bg_Bottom`, `Bg_Top`, `Content`) + `MouseLockFix`, `Screen = { Enabled = false }`, and open only through
  WidgetManager (a button's `Interact_Button` tags, or `I.WidgetManager.Open`). The module that fills one draws it on
  `WidgetManager_Opened` with its name.
- **Huds and panels** (always on while their map runs) keep their own shape; their module turns their ScreenGui on.
  Lobby panels show only on the `Lobby` map, the match screen only on the `Match` map.
- **Billboards** (`Kind = "Billboard"`) are templates the code clones onto worms and markers.
- **Ids:** `U_` for elements code reaches, `S_` inside them, `PREFAB | Name` for templates code clones (rows, slots,
  kill feed lines). Every text rich and scaled; everything anchored at its centre.
- **Every device:** `Utils_PlatformSize` / `Utils_HideOnPlatform` for phone, tablet and console layouts; every button
  a gamepad can reach has `Utils_ButtonKey` or is in the console selection; `Console_Hint` badges on pad keys.
- **Buttons** carry `Utils_ButtonScale` and `Utils_ButtonSound` (`Button_Click`, `Button_Hover`).
- **Exports:** all guis export to StarterGui and ship on both maps (unused ones stay disabled). The agent can export
  from Studio through the Studio MCP (`UmeGui.Export` from `ServerStorage.UmeGui`) or ask the owner to press Export in
  the Gui tool. `TeleportGui` and `LobbyGui` export, then move to `ServerStorage.Ume.UtilityGuis`.
- **The theme** (`src/themes/WormBattlegrounds/`): cartoony and chunky to match the studded bricks: thick outlines,
  big rounded corners, a bold display font, team colours (Red, Blue, Green, Yellow) and rarity colours as tokens.

## Lobby (Lobby map)

| Gui | Kind | Driven by | What it shows |
|---|---|---|---|
| `Lobby` | Hud, `DisplayOrder` lowest | `Lobby` | The flat illustrated background over the whole screen; `U_Pointer` (the tutorial's arrow layer) |
| `MatchBoard` | Panel, middle | `MatchBoard` | `U_Solo` (Play solo button), `U_Rows` with `PREFAB \| Row` (map thumbnail, mode, map name, `3 / 8`, timer, Join / Join teams), `U_Custom` (Custom lobby button), `U_WaitingRoom` (match line, countdown, `5 / 8 players`, `PREFAB \| PlayerName`, Vote to start `4 / 6`, Leave match) |
| `Party` | Panel, left top | `Party` | `U_Members` with `PREFAB \| Member` (avatar, name, level, leader crown, kick), `U_Invite` (invite players here), `U_InviteFriends` (Roblox's invite prompt), Leave party |
| `Loadout` | Panel, left | `Loadout`, `Cosmetics` | `U_Slots` with `PREFAB \| Slot` (icon, rarity frame, shiny mark, lock with price), the Bazooka box, `U_Emotes` (the smiley and the row of owned emotes, a + for the emote shop) |
| `Crates` | Panel, right | `Crates`, `Cosmetics`, `Shop` | `PREFAB \| CrateCard` × 4 (picture, prices in coins and diamonds, Open, Open 10, **Details**), the free VIP crate badge, the tutorial crate card, `U_Skins` (Skins button with the equipped skin) |
| `Currency` | Hud, top | `Currency` (existing), `Shop` | A copy of System's `Currency` (same `Name`, Ids and prefab names): coins and diamonds `Currency_Slot` labels, a + that opens `Shop` |
| `SoloSetup` | Widget | `MatchBoard` | Easy, Medium, Hard (with the coins a win pays), Start |
| `CustomLobby` | Widget | `MatchBoard` | Create: map (dropdown with thumbnails), Deathmatch or Teams, number of players. Room: members, `PREFAB \| Invitable` (players in this server), Invite friends, Start (owner), Leave |
| `LoadoutPicker` | Widget | `Loadout` | `PREFAB \| ItemTile` grid of owned weapons and utilities: icon, name, rarity, `7 / 10` copies to shiny, uses and cooldown; `HoverInfo` details; Empty slot |
| `CrateOpen` | Widget | `Crates` | The reveal: crate shake, burst in the result's rarity colour (`I.UIEmitter`), the item card, "Shiny!" when it turned shiny; for 10 a grid of 10 cards; Open again |
| `CrateOdds` | Widget | `Crates` | The crate's odds: one row per item with rarity and chance, adding up to 100%, and the price |
| `Skins` | Widget | `Cosmetics` | Owned skins in viewports (`PREFAB \| SkinTile`), copies to shiny, Equip |
| `EmoteShop` | Widget | `Cosmetics` | `PREFAB \| EmoteRow`: name, level needed, coins, Buy or Owned |
| `Shop` | Widget | `Shop` | 5 diamond packs (`PREFAB \| Pack`, prices read live), 4 game passes with every benefit listed |

## Match (Match map)

| Gui | Kind | Driven by | What it shows |
|---|---|---|---|
| `MatchHud` | Hud | `MatchHud` | `U_Turn` (banner, timer, wind arrow and 0–10 strength), `U_Stamina`, `U_LoadoutBar` (`PREFAB \| BarSlot`: icon, uses left, cooldown overlay, key hint), `U_Power` (power bar and angle readout), `U_Touch` (◀ ▶ Jump, Mobile only), `U_KillFeed` (`PREFAB \| FeedLine`), `U_EmoteWheel`, `U_Drop` ("Pick where to land" and its timer), `U_KnockedOut` (Spectate, Leave), `U_Waiting` ("Waiting for players") |
| `WormTag` | Billboard | `Worms` | Name in team colour (gold for VIP), level, health number and bar, `S_Active` (the marker and timer over the active worm), `S_Emote` |
| `DropMarker` | Billboard | `Match` | A player's chosen landing spot: name and colour |
| `DamagePop` | Billboard | `Worms` | A damage number that rises and fades (only with the `DamageNumbers` setting) |
| `Results` | Widget, `PreventClosing` | `MatchHud` | `PREFAB \| Placing` rows in team colours, my coins and XP (with a level-up line), match stats (damage, knockouts, best shot), Rematch with votes and timer, Back to lobby |

## Both maps

| Gui | Kind | Driven by | What it shows |
|---|---|---|---|
| `Settings` | Widget | `Settings` (existing) | A copy of System's `Settings`, restyled: "Settings — saved for next time", Music and Sound effects volumes, Damage numbers, Camera follows the shot, Done |
| `TutorialHint` | Hud | `Tutorial` | A speech bubble with an arrow, placed beside the element or spot it points at |
| `Notify`, `WidgetManager_Message`, `WidgetManager_Confirmation` | System copies | ume's modules | Restyled copies (same `Name`, Ids, prefab names) |
| `TopBar` | System | `TopBar` | Unchanged; buttons added by code |
| `TeleportGui` | Utility gui | `I.Teleport` | A full-screen "Heading to the match…" / "Back to the lobby…" card shown during teleports (in `ServerStorage.Ume.UtilityGuis`) |
| `LobbyGui` | Utility gui | ume's transit lobby | The same card for the transit hop |

## Art the guis need

From the team, in `assets/ui/` of the game home, uploaded with PrepKit and their asset ids written on the cards:
the lobby background, 6 map thumbnails, 14 weapon and 6 utility icons, 14 skin portraits, 9 emote icons, 4 crate
pictures, coin and diamond icons, the wind arrow, rarity frames. Until they exist the guis use the theme's icons and
plain frames.

::navbox{from="build"}
