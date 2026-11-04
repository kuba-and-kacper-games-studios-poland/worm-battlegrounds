# DamagePop

A damage number that rises and fades where a worm is hit (only with the Damage numbers setting on).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/DamagePop"` |
| Kind | Billboard |
| Theme | `WormBattlegrounds` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A BillboardGui named `DamagePop` (a template) |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Pop` | Frame | Fills the billboard |
| `U_Pop` › `S_Amount` | Label (`Display`, `Danger`) | "-45" |

## Driven by

The game's `Worms` module clones it on each hit and tweens it up and out.

## Integration

### Setup

Export it with the Gui tool: a BillboardGui named `DamagePop` in StarterGui. Its module moves it where it keeps templates and clones it onto parts; the clone's `Size` and `StudsOffset` are set by that code (the preview uses 140 × 64 px).

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.95 (cards ×0.96, close ×1.06 / ×0.94), with `Button_Hover` and `Button_Click` sounds |
| Rarity | Item cards | Outline in the rarity's colour token (`Item` style variants `Common` … `Legendary`) |
