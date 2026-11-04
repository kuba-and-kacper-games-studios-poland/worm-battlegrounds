# LobbyGui

TeleportGui's card for ume's transit lobby hop: "Getting things ready…".

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). The backdrop is the sea gradient (a `UIGradient` on a white frame); the card is 720 wide.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/LobbyGui"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`); Mobile sizes where Look says |
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
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
