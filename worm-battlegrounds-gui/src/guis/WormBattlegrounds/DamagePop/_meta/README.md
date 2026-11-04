# DamagePop

A damage number that rises and fades where a worm is hit (only with the Damage numbers setting on).

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). Billboard 160 × 80 (was 140 × 64) for the bigger Display text.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/DamagePop"` |
| Kind | Billboard |
| Theme | `WormBattlegroundsBrawl` |
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
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
