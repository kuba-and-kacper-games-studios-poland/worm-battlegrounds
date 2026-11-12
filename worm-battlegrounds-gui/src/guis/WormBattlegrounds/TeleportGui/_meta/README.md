# TeleportGui

The full-screen card shown while ume teleports players between the lobby and a match: "Heading to Desert…" or "Back to the lobby…". It slides down over the screen before the teleport, stays up through it, and slides off once the next server is ready.

**Look.** The studio's `Loading` design (2026-11-12), ported 1:1 as `Primitive` nodes (its pictures, fonts and screen-fraction layout, the code folder's `practices.md` → "The studio's screens are 1:1 `Primitive` ports"). A dark navy backdrop with its texture over it, and in the middle the map's picture on a dim rounded card over HEADING TO … in capitals.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/TeleportGui"` |
| Theme | none: every node is a `Primitive` |
| Modes | Night only |
| Devices | One layout for every device: screen fractions and an aspect-ratio constraint on the card |
| Export | A ScreenGui named `TeleportGui`: `Enabled` on, `DisplayOrder` 100, `ResetOnSpawn` off, `ScreenInsets` `None` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Backdrop` | Frame (its `Main` and `Texture` pictures) | Covers the screen; the card sits in it, so the two slide together |
| `U_Card` | Frame | The card: the map picture over the text |
| `U_Card` › `S_Image` | ImageLabel | The map's picture, hidden when there is none |
| `U_Card` › `S_Text` | TextLabel (`TextCase_Upper`) | Where the player is going |
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
