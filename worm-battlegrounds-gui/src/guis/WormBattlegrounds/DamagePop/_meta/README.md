# DamagePop

A damage number that rises and fades where a snail is hit (only with the Damage numbers setting on).

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). 160 × 100 at design scale, one line of the Display number ("-200" fits at full size), scaled with the screen like the hud.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/DamagePop"` |
| Kind | Billboard |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A BillboardGui named `DamagePop` (a template), moved into its `PREFAB \| DamagePop` holder as `U_DamagePop` (Integration → Setup) |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Pop` | Frame | 160 × 100, the billboard's design size. Has `S_ScreenScale` (set with the billboard's size, below) |
| `U_Pop` › `S_Amount` | Label (`Display`, `Danger`) | "-45" |

## Driven by

The game's `Snails` module clones it on each hit and tweens it up and out.

## Integration

### Setup

Export it with the Gui tool (a BillboardGui named `DamagePop` in StarterGui), then move it into its holder in place of the old one: `Workspace.Ume.ReplicatedStorage_Assets/Snails/PREFAB | DamagePop` › `RootPart` › `Attachment`, renamed `U_DamagePop` (StarterGui would draw it at 0, 0, 0 in Studio). Its module clones it onto parts; the clone's `StudsOffset` is set by that code, and the game's ScreenScale module sizes the clone to the screen: it sets `S_ScreenScale` to the screen's scale (height / 1080, width / 1920 on screens narrower than 16:9, ×1.3 on Mobile screens shorter than 500 px, never under 0.6 on other devices; no device scale) and the billboard's `Size` to the root's design size times it. The Gui tool previews it at 160 × 100 (`Preview`).

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
