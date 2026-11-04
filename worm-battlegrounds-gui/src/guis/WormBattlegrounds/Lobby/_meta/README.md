# Lobby

The lobby's backdrop: a flat illustrated background over the whole screen, under every other gui, and the tutorial's arrow layer over it.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). Only the theme changes (the tutorial arrow).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/Lobby"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A ScreenGui named `Lobby`: `Enabled` off, `DisplayOrder` -1000, `ScreenInsets` `None` (edge to edge) |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Background` | ImageLabel | The lobby art (`Image`), cropped to the screen; until it exists, a sky-blue fill |
| `U_Pointer` | Frame | Full-screen layer for the tutorial |
| `U_Pointer` › `S_Arrow` | Picture (`Glyph`) | Tutorial shows it and moves it over the button the player should press |

## Driven by

The game's `Lobby` module turns the ScreenGui on on the Lobby map; `Tutorial` drives `S_Arrow`.

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `Lobby`, `Enabled` off. Its module turns it on while its map runs. A restyled copy keeps its `Name`, Ids and prefab names. The background art goes in `U_Background.Image` once it's uploaded.

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
