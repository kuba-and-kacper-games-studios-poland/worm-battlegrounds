# LobbyGui

TeleportGui's card for ume's transit lobby hop: "Getting things ready…".

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/LobbyGui"` |
| Theme | `WormBattlegrounds` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A ScreenGui named `LobbyGui`: `Enabled` on, `DisplayOrder` 100, `ResetOnSpawn` off, `ScreenInsets` `None` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Backdrop` | Frame | Covers the screen |
| `U_Card` | Box (`Panel`) | The card. Has `S_ScreenScale` |
| `U_Card` › `S_Text` | Label (`Title`) | The message |

## Driven by

ume's `Teleport` moves it from `ServerStorage.Ume.UtilityGuis` to ReplicatedFirst in the transit lobby.

## Integration

### Setup

Export it with the Gui tool, then move it from StarterGui to `ServerStorage.Ume.UtilityGuis`.

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.95 (cards ×0.96, close ×1.06 / ×0.94), with `Button_Hover` and `Button_Click` sounds |
| Rarity | Item cards | Outline in the rarity's colour token (`Item` style variants `Common` … `Legendary`) |
