# WormTag

The tag over every worm's head: name (team colour, gold for VIP), level, health number and bar, the marker and timer over the worm whose turn it is, and the emote it plays.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/WormTag"` |
| Kind | Billboard |
| Theme | `WormBattlegrounds` |
| Modes | Night only |
| Devices | Desktop (Mobile and Console look the same) |
| Export | A BillboardGui named `WormTag` (a template) |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Tag` | Frame | Fills the billboard |
| `U_Tag` › `S_Active` | Stack | Shown over the active worm: `S_Timer` and a marker |
| `U_Tag` › `S_Timer` | Label (`Heading`) | The turn timer |
| `U_Tag` › `S_Name` | Label (`Strong`) | Tinted in the team's colour |
| `U_Tag` › `S_Level` | Label | "Level 12" |
| `U_Tag` › `S_Health` | Progress (`Health`) | The health number (status line) and bar, tinted in the team's colour; worms start at 200 |
| `U_Tag` › `S_Emote` | Picture | The emote playing, over the tag |

## Driven by

The game's `Worms` module clones it onto every worm.

## Integration

### Setup

Export it with the Gui tool: a BillboardGui named `WormTag` in StarterGui. Its module moves it where it keeps templates and clones it onto parts; the clone's `Size` and `StudsOffset` are set by that code (the preview uses 220 × 170 px).

### Input

None: it only shows.

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.95 (cards ×0.96, close ×1.06 / ×0.94), with `Button_Hover` and `Button_Click` sounds |
| Rarity | Item cards | Outline in the rarity's colour token (`Item` style variants `Common` … `Legendary`) |
