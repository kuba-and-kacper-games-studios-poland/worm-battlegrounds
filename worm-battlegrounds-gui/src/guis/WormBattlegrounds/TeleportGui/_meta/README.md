# TeleportGui

The full-screen card shown while ume teleports players between the lobby and a match: "Heading to the match…" or "Back to the lobby…".

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/TeleportGui"` |
| Theme | `WormBattlegrounds` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A ScreenGui named `TeleportGui`: `Enabled` on, `DisplayOrder` 100, `ResetOnSpawn` off, `ScreenInsets` `None` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Backdrop` | Frame | Covers the screen |
| `U_Card` | Box (`Panel`) | The card. Has `S_ScreenScale` |
| `U_Card` › `S_Image` | Picture (`Thumbnail`) | The map's picture |
| `U_Card` › `S_Text` | Label (`Title`) | Where the player is going |

## Driven by

ume's `Teleport` (`core/game_instance/Start/tasks/place_loader/Teleport.lua`) clones it from `ServerStorage.Ume.UtilityGuis` into each teleported player's PlayerGui, by the gui name the teleport call passes.

## Integration

### Setup

Export it with the Gui tool, then move it from StarterGui to `ServerStorage.Ume.UtilityGuis`. An optional `GuiAnimDuration` NumberValue inside it makes Teleport wait that long before teleporting.

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.95 (cards ×0.96, close ×1.06 / ×0.94), with `Button_Hover` and `Button_Click` sounds |
| Rarity | Item cards | Outline in the rarity's colour token (`Item` style variants `Common` … `Legendary`) |
