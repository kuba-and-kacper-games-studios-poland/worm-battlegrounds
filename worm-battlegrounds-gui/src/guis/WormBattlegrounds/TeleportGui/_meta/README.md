# TeleportGui

The full-screen card shown while ume teleports players between the lobby and a match: "Heading to Desert…" or "Back to the lobby…". It slides down over the screen before the teleport, stays up through it, and slides off once the next server is ready.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). The backdrop is the sea gradient (a `UIGradient` on a white frame); the card is 720 wide.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/TeleportGui"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop at 0.75 of the kit's size, Mobile, Console and VR at full size (`Utils_PlatformScale`); Mobile sizes where Look says |
| Export | A ScreenGui named `TeleportGui`: `Enabled` on, `DisplayOrder` 100, `ResetOnSpawn` off, `ScreenInsets` `None` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Backdrop` | Frame | Covers the screen; the card sits in it, so the two slide together |
| `U_Card` | Box (`Panel`) | The card. Has `S_ScreenScale` |
| `U_Card` › `S_Image` | Picture (`Thumbnail`) | The map's picture, hidden when there is none |
| `U_Card` › `S_Text` | Label (`Title`) | Where the player is going |
| `GuiAnimDuration` | NumberValue (0.45) | How long ume's teleport waits after cloning the card, so its slide plays first |

## Driven by

ume's `Teleport` (`core/game_instance/Start/tasks/place_loader/Teleport.lua`) clones it from `ServerStorage.Ume.UtilityGuis` into each teleported player's PlayerGui, by the gui name the teleport call passes. The Transition module (its README) fills and slides it, and its arrival script shows it on the next server.

## Integration

### Setup

Export it with the Gui tool, then move it from StarterGui to `ServerStorage.Ume.UtilityGuis`. Its `GuiAnimDuration` NumberValue makes Teleport wait that long before teleporting.

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Before a teleport | `U_Backdrop` | Slides down from `0.5, -0.5` to the middle (Transition's `WIPE_TWEENINFO`, 0.4 s) |
| Arrived, ready | `U_Backdrop` | Slides off to `0.5, 1.5` (0.5 s, Quad In), then the card goes |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
