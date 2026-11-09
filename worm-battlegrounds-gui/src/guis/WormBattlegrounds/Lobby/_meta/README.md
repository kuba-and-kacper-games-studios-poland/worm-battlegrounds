# Lobby

The lobby's own screen: the **STYLE**, **WEAPONS** and **SKINS** menu in the top-right corner, a badge on WEAPONS,
and the tutorial's arrow layer. Under every other gui, so the lobby's backdrop match shows behind it.

**Look.** The menu is ported 1:1 from the studio's `LobbyInventory` gui (its `TopRight` frame, 2026-11-09) as
`Primitive` nodes, laid out in screen fractions with aspect-ratio constraints (no `S_ScreenScale`). The badge, which
the design lacks, is the design's red close look behind a count. The design has no logo, so the game's name that
stood at the top is gone. The arrow layer is the kit's (`WormBattlegroundsBrawl`), kept from before the port.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Lobby"` |
| Theme | `WormBattlegroundsBrawl` (the arrow) |
| Modes | Night only |
| Export | A ScreenGui named `Lobby`: `Enabled` off, `DisplayOrder` -1000, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Menu` | Frame | The corner menu (the design's `TopRight`) |
| `U_Menu` › `S_Style` | ImageButton | Opens `Skins` (its tags) |
| `U_Menu` › `S_Weapons` | ImageButton | Crates binds it and opens `Crates` on the crate in its `Crates_CrateId` attribute (`"Weapon"`) |
| `U_Menu` › `S_Skins` | ImageButton | The same, `Crates_CrateId` `"Skin"` |
| `U_Menu` › `S_Badge` | Frame, hidden | The badge on WEAPONS; Crates shows it |
| `U_Menu` › `S_Count` | TextLabel | The badge's text: FREE, a count |
| `U_Pointer` | Frame, full screen | The tutorial's layer |
| `U_Pointer` › `S_Arrow` | Picture (`Glyph`) | Tutorial shows it and moves it over what the player should press |

## Driven by

The game's `Lobby` module turns the ScreenGui on outside matches and off while a full-screen widget is open;
`Crates` binds WEAPONS and SKINS and fills the badge; `Tutorial` drives `S_Arrow`.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Lobby`, `Enabled` off. It keeps its `Name`,
Ids and prefab names.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Open Skins | Click STYLE | Tap | Select and A | `S_Style` tags (`Interact_Button` → WidgetManager `Toggle`, `Skins`) |
| Open a crate | Click WEAPONS or SKINS | Tap | Select and A | Crates (`I.Interact.OnPress`) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | STYLE, WEAPONS, SKINS | `Utils_ButtonScale` (`Bouncy`, hover ×1.04, press ×0.92) with `Button_Hover` and `Button_Click` |
