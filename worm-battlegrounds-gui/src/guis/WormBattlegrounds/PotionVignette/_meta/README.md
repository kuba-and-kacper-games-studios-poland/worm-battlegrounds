# PotionVignette

A soft coloured glow around the screen's edges that shows while the player's snail is under the Speed or Low gravity
potion on their own turn: four white edges, each fading out toward the middle along its gradient, that code tints
and fades in.

**Look.** `Primitive` nodes, no theme: like MatchHud's tension band, an overlay that isn't a panel. The edges start
half see-through at the screen's border and are gone 45 % of the way in (the top and bottom 30 % of the height deep,
the sides 20 % of the width), so the arena stays clear.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/PotionVignette"` |
| Theme | None (`Primitive` nodes) |
| Modes | Night only |
| Devices | All, the same: it covers the whole screen |
| Export | A ScreenGui named `PotionVignette`: `Enabled` off, `DisplayOrder` −5 (under the HUD), `IgnoreGuiInset` on and `ScreenInsets` `None`, so it reaches the screen's real edges |

## Elements

| Element | Primitive | What game code does with it |
| --- | --- | --- |
| `U_Vignette` | Frame | The whole screen, holding the edges |
| `U_Vignette` › `S_Top`, `S_Bottom`, `S_Left`, `S_Right` | Frame with a `UIGradient` | Tinted (`BackgroundColor3`) and faded (`BackgroundTransparency`) together |

## Driven by

The game's `Snails` module (`Scripts/Client/Potions.lua`).

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `PotionVignette`, `Enabled` off. Snails
sets each edge's `BackgroundTransparency` to 1 at start, enables the gui while it shows and disables it once it has
faded out.

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Speed potion | Every edge | `POTION_VIGNETTE_SPEED`, cyan |
| Low gravity potion | Every edge | `POTION_VIGNETTE_LOW_GRAVITY`, violet |
| Both | Every edge | `POTION_VIGNETTE_BOTH`, pink |
| Fading in, changing, out | Every edge | `POTION_VIGNETTE_TWEENINFO` (0.4 s sine out) on `BackgroundTransparency` (0 in, 1 out) and `BackgroundColor3` |
