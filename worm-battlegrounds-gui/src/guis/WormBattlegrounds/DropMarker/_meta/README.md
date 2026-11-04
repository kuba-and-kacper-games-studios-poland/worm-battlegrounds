# DropMarker

A player's chosen landing spot in the drop phase: their name and a pin, in their colour.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/DropMarker"` |
| Kind | Billboard |
| Theme | `WormBattlegrounds` |
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
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.95 (cards ×0.96, close ×1.06 / ×0.94), with `Button_Hover` and `Button_Click` sounds |
| Rarity | Item cards | Outline in the rarity's colour token (`Item` style variants `Common` … `Legendary`) |
