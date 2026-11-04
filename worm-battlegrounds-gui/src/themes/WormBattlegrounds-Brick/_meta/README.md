# WormBattlegrounds-Brick

The **Brick toy** look, one of two looks being compared for the game: cream panels and white cards on deep brick edges,
chunky buttons with a shine strip, studs on the title banner, white text with thick dark outlines, Luckiest Guy for
titles and Fredoka One for the rest. It extends the game's theme (`Extends = "WormBattlegrounds"`), so it uses that
theme's controls and only changes tokens and style records.

The guis keep `Theme = "WormBattlegrounds"`. To see them in this look, build a copy of a gui's table with `Theme` set
to `"WormBattlegrounds-Brick"`. Once a look is picked, it goes into `WormBattlegrounds` and this folder can be removed.

## Tokens

| Group | What |
| --- | --- |
| `Palette.Night` | Cream `Background` on a tan `PanelEdge`, white `Surface` on a grey `SurfaceEdge`, near-black outlines, white `Text`, brown `TextDim` / `TextMuted`, brighter `Primary`, `Danger`, `Banner` and `Accent` with their edges |
| `Font` | Luckiest Guy for `Title`, Fredoka One for `Body` and `Hint` (both have one weight) |
| `Radius`, `Stroke` | Boxier corners, 4 px outlines (`Thick`), 2.5 px text outlines (`Text`) |

## Styles

| File | Changes |
| --- | --- |
| `Button.lua` | An 8 px flat slab with a shine strip; outlined text, white when selected |
| `Label.lua` | Outlined text; `Caption`, `Dim` and `Muted` stay brown with no outline |
| `Widget.lua` | A 12 px flat panel with no shadow; an 8 px banner with a shine strip and 5 studs |
| `Box.lua` | 7 px white slabs with a shine strip and outlined titles; `Panel` 12 px, no shadow |
| `Item.lua` | 7 px slabs (5 px `Small`), outlined names, dark icons |
| `Picture.lua` | Dark icons, `Glyph` included, so they show on cream and white |
| `Progress.lua` | Brown bar labels, which have no outline |
