# DropMarker

A player's chosen landing spot in the drop phase: their name and a pin, in their colour.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). Billboard 240 × 100 (was 200 × 90) for the bigger text.

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
| `U_Marker` | Frame | Fills the billboard |
| `U_Marker` › `S_Name` | Label (`Strong`) | The player's name, in their colour |
| `U_Marker` › `S_Pin` | Picture (`Glyph`) | Tinted in their colour |

## Driven by

The game's `Match` module clones one per player during the drop.

## Integration

### Setup

Export it with the Gui tool: a BillboardGui named `DropMarker` in StarterGui. Its module moves it where it keeps templates and clones it onto parts; the clone's `Size` and `StudsOffset` are set by that code (the preview uses 200 × 90 px).

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
