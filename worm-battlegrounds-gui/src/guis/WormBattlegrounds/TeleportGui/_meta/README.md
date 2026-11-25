# TeleportGui

The full-screen card shown while ume teleports players between the lobby and a match. The destination map's scene
fills it (built at runtime by the Transition module): "HEADING TO" over "DESERT" stands on the scene itself, and a slim
bar along the bottom holds the mode and how many snails and a tip, with the progress line along its top edge and the
shell glyph rolling at its head.

**Look.** The game's own (2026-11-25, from a draft the owner approved), in the HUD's text: the timer's font
(`rbxassetid://12187365977`, Heavy Italic) in white with the label outline weights (0.06 on the title, 0.07 elsewhere).
The map fills the screen; only a slim navy bar (17, 18, 29, 0.115 of the screen) runs along the bottom, its top edge
the progress line (the owner turned down a big plate under the title, "too much grey on the screen", after a stepped
brick edge, a plain fade and slanted cuts); soft dark shades at the top, along the left and up from the bottom keep
the white text readable on any sky. The progress fill, the kicker, its bar, the dots, the tip chip and the bar's fill take the map's accent colour from code.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/TeleportGui"` |
| Theme | none: every node is a `Primitive` |
| Modes | Night only |
| Devices | One layout for every device: screen fractions, aspect-ratio constraints on the glyphs |
| Export | A ScreenGui named `TeleportGui`: `Enabled` on, `DisplayOrder` 100, `ResetOnSpawn` off, `ScreenInsets` `None`, `ClipToDeviceSafeArea` off (so it reaches a phone's notch sides: 2026-11-25) |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Backdrop` | Frame (navy) | Covers the screen; fades with the scene on the intro and the reveal |
| `U_Scene` | Frame | Empty: the Transition module adds one frame per scene (named by MapId or `Lobby`) |
| `U_Shade` | CanvasGroup (`Top`, `Left`, `Bottom` gradients) | Fades with the scene |
| `U_Plate` | Frame | Everything read; rises in on the intro and drops away on the reveal |
| `U_Plate` › `S_Band` | Frame | The slim navy bar along the bottom |
| `U_Plate` › `S_KickerBar`, `S_Kicker` | Frame, TextLabel | The accent bar and line: "HEADING TO" |
| `U_Plate` › `S_Title` (`S_TitleScale`) | TextLabel (UIScale) | The map's name; its scale punches when a search finds its match |
| `U_Plate` › `S_Dots` | Frame (three `Dot`s) | Pulse after the title while a match is found, placed by the title's width |
| `U_Plate` › `S_ModeIcon`, `S_Info` | ImageLabel, TextLabel | The mode's glyph and "DEATHMATCH · 6 SNAILS" |
| `U_Plate` › `S_TipChip`, `S_Tip` | Frame (its `ChipText`), TextLabel | TIP and the tip |
| `U_Plate` › `S_Track` | Frame (its `Fill`, `Shell`) | The progress line along the bar's top edge, full width; the shell rolls along its fill's end |
| `GuiAnimDuration` | NumberValue (0.45) | How long ume's teleport waits after cloning the card, so its intro plays first |

## Driven by

ume's `Teleport` (`core/game_instance/Start/tasks/place_loader/Teleport.lua`) clones it from
`ServerStorage.Ume.UtilityGuis` into each teleported player's PlayerGui, by the gui name the teleport call passes. The
Transition module (its README) builds its scene and fills it, and `src/replicated_first/` moves it and shows it on the
next server.

## Integration

### Setup

Export it with the Gui tool, then move it from StarterGui to `ServerStorage.Ume.UtilityGuis`, replacing the old one.
Its `GuiAnimDuration` NumberValue makes Teleport wait that long before teleporting.

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Intro | the shown scene | Whips in from 650 studs to the side, 0.46 s, fading in over its first third |
| Intro | `U_Plate` | Rises from 0.36 of the screen lower (0.38 s, Back Out) |
| Search found | `S_TitleScale` | 1.22 to 1 (0.34 s, Back Out) |
| Reveal | `U_Plate` | Drops 0.36 of the screen (0.32 s, Quad In) while the camera flies through the layers (0.8 s) |
