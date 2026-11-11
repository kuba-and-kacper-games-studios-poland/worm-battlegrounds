# Skins

The **STYLE** screen: a full-screen window over the lobby with the snail's categories on the left (Skins, then
Hats, Shirts and Shells, which are "Coming soon"), the snail colour row (a placeholder: "SOON", not pressable), and a
grid of every skin. The worn skin comes first in the grid's selected look (a green outline), owned skins after it by
rarity, and the ones the player doesn't own under a lock.

**Look.** Ported 1:1 from the studio's `Customise` gui (2026-11-09) as `Primitive` nodes: its slanted dark cards,
pictures and fonts, its screen-fraction layout (sizes and positions as screen shares with aspect-ratio constraints,
so it scales with the screen by itself, with no `S_ScreenScale`). Added to it: the SKINS category (a copy of HATS),
the lock cover on each tile (from the design's locked card), a 3D preview in place of the tile's icon, and button
tags (`Utils_ButtonScale`, `Utils_ButtonSound`).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Skins"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Export | A ScreenGui named `Skins`: `Enabled` off, `DisplayOrder` 1, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Widget` | Frame, full screen | The widget WidgetManager opens; holds `Content` with the design's `Left`, `TopLeft` and `TopRight` |
| `U_Widget` › `S_Close` | ImageButton (BACK) | Closes the widget (its tags), or B on a pad |
| `U_Categories` › `S_Skins` | ImageButton | The selected category; Cosmetics writes the worn skin's name into its `Equipped` label |
| `U_Skins` | Frame (grid) | Holds one `SkinTile` per skin |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| SkinTile` | `U_Skins` | An ImageButton: `S_Name`, `S_Rarity` (the corner mark, tinted with the rarity's colour), `S_Preview` (ViewportFrame for the snail), `S_Locked` (the lock cover). Its `Background` › `Stroke2` / `Stroke` swap to the selected look from the root's attributes |

## Driven by

The game's `Cosmetics` module (`Scripts/Client/Skins.lua`).

## Preview

`Preview.lua` fills the grid with `S_Skins` tiles (1 to 6): the first worn, the last three locked.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Skins`, `Enabled` off. WidgetManager opens
it (the lobby's STYLE button). It keeps its `Name`, Ids and prefab name.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Equip a skin | Click an owned tile | Tap | Select | Cosmetics (`I.Interact.OnPress`) |
| Close | BACK | BACK | B | `S_Close` tags (`Interact_Button`, `Utils_ButtonKey`); its `PadHint` badge on Console |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Tiles, SKINS, BACK | `Utils_ButtonScale` (`Bouncy`, hover ×1.04, press ×0.92) with `Button_Hover` and `Button_Click` |
| Worn | `SkinTile` › `Background` | `Stroke2` and `Stroke` take `Look_SelectedStroke2`, `Look_SelectedStroke` and `Look_SelectedStrokeColor` (green); the rest `Look_Stroke2`, `Look_Stroke`, `Look_StrokeColor` |
| Rarity | `SkinTile` › `S_Rarity` | `ImageColor3` = `I.Rarity.GetLook(rarity).Base` |
| Not owned | `SkinTile` › `S_Locked` | Shown |
