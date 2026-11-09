# DamagePop

A damage number that rises and fades where a snail is hit (only with the Damage numbers setting on).

**Look.** The studio's HUD design (`World.Damage`), ported 1:1 on 2026-11-09 as `Primitive` nodes: "-35" in Luckiest Guy with a yellow-to-red gradient and a black outline, over a see-through black shadow a little lower. 180 × 82 at design scale, scaled with the screen like the hud.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/DamagePop"` |
| Kind | Billboard |
| Theme | `WormBattlegroundsBrawl` (unused: `Primitive` nodes only) |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A BillboardGui named `DamagePop` (a template), moved into its `PREFAB \| DamagePop` holder as `U_DamagePop` (Integration → Setup) |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Pop` | Frame | 180 × 82, the billboard's design size. Has `S_ScreenScale` (set with the billboard's size, below) |
| `U_Pop` › `S_Amount` | TextLabel (UIGradient, UIStroke) | "-45"; fades out with its outline |
| `U_Pop` › `S_Shadow` | TextLabel (UIStroke) | The same text, under it; fades out with it |

## Driven by

The game's `Snails` module clones it on each hit and tweens it up and out.

## Integration

### Setup

Export it with the Gui tool (a BillboardGui named `DamagePop` in StarterGui), then move it into its holder in place of the old one (or move the export's children into the holder's BillboardGui and set its `Size` to 180 × 82): `Workspace.Ume.ReplicatedStorage_Assets/Snails/PREFAB | DamagePop` › `RootPart` › `Attachment`, renamed `U_DamagePop` (StarterGui would draw it at 0, 0, 0 in Studio). Its module clones it onto parts; the clone's `StudsOffset` is set by that code, and the game's ScreenScale module sizes the clone to the screen: it sets `S_ScreenScale` to the screen's scale (height / 1080, width / 1920 on screens narrower than 16:9, ×1.3 on Mobile screens shorter than 500 px, never under 0.6 on other devices; no device scale) and the billboard's `Size` to the root's design size times it. The Gui tool previews it at 180 × 82 (`Preview`).

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Rise and fade | The billboard, `S_Amount`, `S_Shadow` | `StudsOffset` rises by Snails' `POP_RISE` while both texts and their `UIStroke`s fade to 1 (`POP_TWEENINFO`) |
