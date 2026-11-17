# FreeCrate

**Free crate for joining the group**: a gold **FREE WEAPONS** tile in the lobby (left of STYLE, WEAPONS and SKINS) and
a yellow **FREE CRATE** badge on the crates screen, both with a red dot reading 1. Both open the free crate's dialog,
its own widget since 2026-11-17 (`FreeCrateDialog`). The owner asked for it on 2026-11-16 and for the lobby tile on
2026-11-17.

**Look.** The game's screens (the code folder's `practices.md` → Guis). The tile is the lobby menu's tile pictures
tinted gold (255, 196, 40) with a pale gold outline. The badge is the crate shop's slanted button. Laid out by
fractions of the screen with aspect-ratio constraints: the tile 1.2058, the badge 3.6.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/FreeCrate"` |
| Theme | none (Primitive nodes only) |
| Modes | Night only |
| Devices | Desktop, Mobile and Console, one layout |
| Export | A ScreenGui named `FreeCrate`: `Enabled` off, `DisplayOrder` 2 (over the crates screen's 1), `ScreenInsets` `DeviceSafeInsets`. Its root is a Folder: `U_Button` and `U_LobbyButton` go straight into the ScreenGui |

## Elements

| Element | Class | What game code does with it |
| --- | --- | --- |
| `U_Button` | ImageButton (at the right edge, 0.975 × 0.42 of the screen) | The crates screen's badge: opens the dialog; hidden while a crate opens there |
| `U_LobbyButton` | ImageButton, hidden (left of the lobby menu) | The lobby's tile: opens the dialog; shown while the lobby's screens show |
| `U_LobbyButton` › `S_TileShine` | UIGradient | The light sweeping the tile (its `Offset` moved by code) |
| `U_LobbyButton` › `S_TileBob` | UIScale | The crate picture's gentle bob |

## Driven by

The game's `Crates` module (its `GroupReward` handler) finds it as `I.UserInterface.UI["FreeCrate"]` (Crates'
`GROUP_GUI_NAME`). The handler turns it on in the lobby and on the crates screen while the player's free crate is
unclaimed, animates the tile, and opens `FreeCrateDialog` from either button with `I.WidgetManager.Open`.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**) over the copy in StarterGui. A restyled copy keeps its `Name`
and its Ids.

### Input

| Action | Mouse and keyboard | Touch | Gamepad (Xbox / PlayStation) | Bound in |
| --- | --- | --- | --- | --- |
| Open the dialog | Click **FREE WEAPONS** or **FREE CRATE** | Tap | Select it and press A / Cross | Crates (`I.Interact.OnPress`) |

### Looks

| Look | Value | Set by |
| --- | --- | --- |
| Tile shine | `GROUP_SHINE_SECONDS` 0.8, then `GROUP_SHINE_PAUSE` 1.8 | Crates' Settings |
