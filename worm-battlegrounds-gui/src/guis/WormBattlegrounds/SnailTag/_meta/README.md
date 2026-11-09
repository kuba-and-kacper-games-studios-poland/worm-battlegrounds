# SnailTag

The tag over every snail's head: the name over a health bar (team colour, gold name for VIP), the level, the marker and turn timer over the snail whose turn it is, and the emote it plays.

**Look.** The name and health bar are the studio's HUD design (`World.Overhead`), ported 1:1 on 2026-11-09 as `Primitive` nodes: the name in the design's font with its outline, the bar's slanted frame with its fill picture and the health number on it. The turn marker, level and emote picture stay the theme's (`WormBattlegroundsBrawl`). 240 × 240 at design scale, scaled with the screen like the hud; the stack builds up from the bottom edge, the bar nearest the snail. The active snail shows the turn's seconds beside its arrow to everyone but its own player, who reads them on the turn panel.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/SnailTag"` |
| Kind | Billboard |
| Theme | `WormBattlegroundsBrawl` (the design's parts are `Primitive` nodes) |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A BillboardGui named `SnailTag` (a template), moved into its `PREFAB \| SnailTag` holder as `U_SnailTag` (Integration → Setup) |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Tag` | Frame | 240 × 240, the billboard's design size. Has `S_ScreenScale` (set with the billboard's size, below) |
| `U_Tag` › `S_Active` | Stack | Shown over the active snail: a down arrow |
| `U_Tag` › `S_Active` › `S_Timer` | Label (`Strong`) | The turn's seconds, blank while a shot flies; hidden on the active player's own screen |
| `U_Tag` › `S_Level` | Label | "Lv 12" |
| `U_Tag` › `Overhead` › `S_Name` | TextLabel | Tinted in the team's colour (gold for VIP) |
| `U_Tag` › `Overhead` › `S_Health` | Frame | The bar: `Background` › `Stroke` tinted the team's colour |
| `S_Health` › `S_Fill` | ImageLabel with a UIGradient | Tinted the team's colour; the gradient cuts it at the health left |
| `S_Health` › `S_HealthText` | TextLabel | The health number |
| `U_Tag` › `S_Emote` | Picture | The emote playing, over the tag |

## Driven by

The game's `Snails` module clones it onto every snail.

## Integration

### Setup

Export it with the Gui tool (a BillboardGui named `SnailTag` in StarterGui), then move it into its holder in place of the old one (or move the export's children into the holder's BillboardGui and set its `Size` to 240 × 240): `Workspace.Ume.ReplicatedStorage_Assets/Snails/PREFAB | SnailTag` › `RootPart` › `Attachment`, renamed `U_SnailTag` (StarterGui would draw it at 0, 0, 0 in Studio). Its module clones it onto parts; the clone's `StudsOffset` is set by that code, and the game's ScreenScale module sizes the clone to the screen: it sets `S_ScreenScale` to the screen's scale (height / 1080, width / 1920 on screens narrower than 16:9, ×1.3 on Mobile screens shorter than 500 px, never under 0.6 on other devices; no device scale) and the billboard's `Size` to the root's design size times it. The Gui tool previews it at 240 × 240 (`Preview`).

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Team colour | `S_Name`, `S_Health` › `Background` › `Stroke`, `S_Fill` | `TextColor3` / `ImageColor3` = the snail's `Color` (the name gold for VIP, Snails' `VIP_NAME_COLOR`) |
| Health left | `S_Fill` › `UIGradient` | `Transparency` opaque up to the health's share of `MaxHealth`, clear after it |
