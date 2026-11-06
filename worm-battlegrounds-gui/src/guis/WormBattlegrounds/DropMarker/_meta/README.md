# DropMarker

A player's chosen landing spot in the drop phase: their name and a pin, in their colour.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). 240 × 100 at design scale, scaled with the screen like the hud.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/DropMarker"` |
| Kind | Billboard |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A BillboardGui named `DropMarker` (a template) |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Marker` | Frame | 240 × 100, the billboard's design size. Has `S_ScreenScale` (set with the billboard's size, below) |
| `U_Marker` › `S_Name` | Label (`Strong`) | The player's name, in their colour |
| `U_Marker` › `S_Pin` | Picture (`Glyph`) | Tinted in their colour |

## Driven by

The game's `Match` module clones one per player during the drop.

## Integration

### Setup

Export it with the Gui tool: a BillboardGui named `DropMarker` in StarterGui. Its module moves it where it keeps templates and clones it onto parts; the clone's `StudsOffset` is set by that code, and the game's ScreenScale module sizes the clone to the screen: it sets `S_ScreenScale` to the screen's scale (height / 1080, width / 1920 on screens narrower than 16:9, ×1.3 on Mobile screens shorter than 500 px, never under 0.6 on other devices; no device scale) and the billboard's `Size` to the root's design size times it. The Gui tool previews it at 240 × 100 (`Preview`).

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
