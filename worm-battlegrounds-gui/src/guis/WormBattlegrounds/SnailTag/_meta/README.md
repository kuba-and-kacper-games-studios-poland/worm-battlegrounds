# SnailTag

The tag over every snail's head: name (team colour, gold for VIP), level, health number and bar, the marker and turn timer over the snail whose turn it is, and the emote it plays.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). 240 × 240 at design scale, scaled with the screen like the hud (108 px wide on a 667 × 375 phone instead of a fixed 240 × 200). The stack builds up from the bottom edge, the health bar nearest the snail, with the health number big (`Heading`, 48) and centred over it. The name, the health number and the bar carry the team's colour (the studio's wiki: "a number and a bar above each worm's head, in its team's colour"). The active snail shows the turn's seconds beside its arrow to everyone but its own player, who reads them on the turn panel.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/SnailTag"` |
| Kind | Billboard |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A BillboardGui named `SnailTag` (a template), moved into its `PREFAB \| SnailTag` holder as `U_SnailTag` (Integration → Setup) |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Tag` | Frame | 240 × 240, the billboard's design size. Has `S_ScreenScale` (set with the billboard's size, below) |
| `U_Tag` › `S_Active` | Stack | Shown over the active snail: a down arrow |
| `U_Tag` › `S_Active` › `S_Timer` | Label (`Strong`) | The turn's seconds, blank while a shot flies; hidden on the active player's own screen |
| `U_Tag` › `S_Name` | Label (`Strong`) | Tinted in the team's colour |
| `U_Tag` › `S_Level` | Label | "Level 12" |
| `U_Tag` › `S_Health` | Progress (`Health`) | The health number (its status line, one line tall, centred) and bar; the Snails module tints the number and the bar's `Fill` in the team's colour; snails start at 200 |
| `U_Tag` › `S_Emote` | Picture | The emote playing, over the tag |

## Driven by

The game's `Snails` module clones it onto every snail.

## Integration

### Setup

Export it with the Gui tool (a BillboardGui named `SnailTag` in StarterGui), then move it into its holder in place of the old one: `Workspace.Ume.ReplicatedStorage_Assets/Snails/PREFAB | SnailTag` › `RootPart` › `Attachment`, renamed `U_SnailTag` (StarterGui would draw it at 0, 0, 0 in Studio). Its module clones it onto parts; the clone's `StudsOffset` is set by that code, and the game's ScreenScale module sizes the clone to the screen: it sets `S_ScreenScale` to the screen's scale (height / 1080, width / 1920 on screens narrower than 16:9, ×1.3 on Mobile screens shorter than 500 px, never under 0.6 on other devices; no device scale) and the billboard's `Size` to the root's design size times it. The Gui tool previews it at 240 × 240 (`Preview`).

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
