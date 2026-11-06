# WormTag

The tag over every worm's head: name (team colour, gold for VIP), level, health number and bar, the marker over the worm whose turn it is, and the emote it plays.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). 240 × 240 at design scale, scaled with the screen like the hud (108 px wide on a 667 × 375 phone instead of a fixed 240 × 200). The stack builds up from the bottom edge, the health bar nearest the worm, with the health number big (`Heading`, 48) and centred over it. The bar shows health by colour, green when full through yellow at half to red, so the name alone carries the team's colour; the turn's seconds are only on the turn panel, so the active worm has just its arrow.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/WormTag"` |
| Kind | Billboard |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A BillboardGui named `WormTag` (a template) |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Tag` | Frame | 240 × 240, the billboard's design size. Has `S_ScreenScale` (set with the billboard's size, below) |
| `U_Tag` › `S_Active` | Stack | Shown over the active worm: a down arrow |
| `U_Tag` › `S_Name` | Label (`Strong`) | Tinted in the team's colour |
| `U_Tag` › `S_Level` | Label | "Level 12" |
| `U_Tag` › `S_Health` | Progress (`Health`) | The health number (its status line, one line tall, centred) and bar; the Worms module tints the bar's `Fill` by health (its `HEALTH_*_COLOR` settings); worms start at 200 |
| `U_Tag` › `S_Emote` | Picture | The emote playing, over the tag |

## Driven by

The game's `Worms` module clones it onto every worm.

## Integration

### Setup

Export it with the Gui tool: a BillboardGui named `WormTag` in StarterGui. Its module moves it where it keeps templates and clones it onto parts; the clone's `StudsOffset` is set by that code, and the game's ScreenScale module sizes the clone to the screen: it sets `S_ScreenScale` to the screen's scale (height / 1080, width / 1920 on screens narrower than 16:9, ×1.3 on Mobile screens shorter than 500 px, never under 0.6 on other devices; no device scale) and the billboard's `Size` to the root's design size times it. The Gui tool previews it at 240 × 240 (`Preview`).

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
