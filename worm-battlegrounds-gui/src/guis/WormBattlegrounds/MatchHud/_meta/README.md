# MatchHud

The match screen: whose turn, the timer and the wind at the top; the kill feed at the top right; the loadout bar, stamina, the emote smiley and the power bar at the bottom; walk and jump buttons on touch screens; and the blocks for the other phases (waiting, drop, knocked out) and the emote wheel.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). The turn, loadout bar, stamina, power, drop and waiting blocks are `Hud` boxes (a darker see-through slot, no frame), so the arena stays in view; the knocked-out dialog stays a window with Spectate in yellow. The loadout bar is 720 wide for 112 slots; Jump is blue; cooldowns read on a darker cover. Every block is placed by screen fractions, so positions scale with the screen as sizes do. The kill feed and the emote button scale too (the emote button through the `Item` control's `Screen`), tagged `Utils_PlatformScale` like the theme's panels; the kill feed sits under the top bar, stamina at 79 % down to clear the bar on a phone. On phones and tablets the turn and drop panels are at 0.6 and the kill feed at 0.8, so the hint fits under the turn panel; the walk and jump buttons scale with the screen through the `Button` control's `Screen`.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/MatchHud"` |
| Theme | `WormBattlegroundsBrawl` |
| Modes | Night only |
| Devices | Desktop, Mobile (shows `U_Touch`, hides key hints), Console (shows the LB / RB hints); Desktop at 0.75 of the kit's size (`Utils_PlatformScale`) |
| Export | A ScreenGui named `MatchHud`: `Enabled` off, `DisplayOrder` 0, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Control | What game code does with it |
| --- | --- | --- |
| `U_Turn` | Box (`Panel`) | Top middle. Has `S_ScreenScale` |
| `U_Turn` › `S_Banner` | Label (`Title`) | "Your turn!", only on the player's own turn |
| `U_Turn` › `S_Timer` | Label (`Display`) | The 15-second turn timer |
| `U_Turn` › `S_WindArrow` | Picture (`Glyph`) | Rotated to the wind's direction |
| `U_Turn` › `S_Wind` | Label (`Heading`) | "Wind 4" (0 to 10) |
| `U_KillFeed` | Cells (no scroll, `Fixed`) | Top right: holds one `FeedLine` per knockout |
| `U_LoadoutBar` | Box (`Panel`) | Bottom middle. Has `S_ScreenScale` |
| `U_LoadoutBar` › `S_PrevHint`, `S_NextHint` | Label, tagged `Console_Hint` | LB / RB beside the bar on Console |
| `U_Slots` | Cells (horizontal, no scroll) | Holds one `BarSlot` per loadout slot |
| `U_Stamina` | Box (`Panel`) | Above the bar, on the player's turn. Has `S_ScreenScale` |
| `U_Stamina` › `S_Bar` | Progress (`Stamina`) | How far the worm can still walk |
| `U_EmoteButton` | Item (`Small`) | The smiley: opens `U_EmoteWheel` |
| `U_Power` | Box (`Panel`) | Bottom right, while aiming. Has `S_ScreenScale` |
| `U_Power` › `S_Bar` | Progress (`Power`) | The shot's power |
| `U_Power` › `S_Angle` | Label (`Heading`) | "Angle 45°" |
| `U_Touch` | Frame, `Utils_HideOnPlatform` (Mobile only) | Touch controls |
| `U_Touch` › `S_Left`, `S_Right`, `S_Jump` | Button | Walk left, walk right, jump |
| `U_EmoteWheel` | Frame | Hidden; holds one `WheelEmote` per owned emote, placed on a circle. Has its own `S_ScreenScale` |
| `U_Drop` | Box (`Panel`) | Hidden; the drop phase: "Pick where to land" and `S_Timer` |
| `U_KnockedOut` | Box (`Panel`) | Hidden; `S_Spectate`, `S_Leave` |
| `U_Waiting` | Box (`Panel`) | Hidden; "Waiting for players" and `S_Count` |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | BarSlot` | `U_Slots` | An Item (`S_Icon`; selected = highlighted), `S_Key` ("1"–"5", Desktop only), `S_Uses` ("×3"), `S_Cooldown` (cover) › `S_Turns` |
| `PREFAB | FeedLine` | `U_KillFeed` | A Label: "Bax knocked out Ninja with the Black hole grenade", names in team colours (rich text) |
| `PREFAB | WheelEmote` | `U_EmoteWheel` | An Item (`S_Icon`), anchored at its centre |

## Driven by

The game's `MatchHud` module: it turns the ScreenGui on on the Match map and shows each block in its phase.

## Preview

`Preview.lua` shows the phases.

| Setting | What it does |
| --- | --- |
| `S_Phase` (Segmented: Waiting, Drop, Turn, Out) | Which blocks show |
| `S_MyTurn` (Toggle) | The banner, stamina and power show on the player's own turn |
| `S_Slots` (Slider, 3 to 5) | Loadout slots (the second one cools down) |
| `S_Feed` (Slider, 0 to 3) | Kill feed lines |
| `S_Wheel` (Toggle) | Opens the emote wheel |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `MatchHud`, `Enabled` off. Its module turns it on while its map runs. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size. `U_KillFeed` and `U_Touch` have no UIScale yet (styling pass).

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Pick a loadout slot | 1–5 or click | Tap | LB / RB | MatchHud |
| Walk, jump | Game controls | `S_Left`, `S_Right`, `S_Jump` | Game controls | MatchHud and the movement code |
| Emote wheel | Click the smiley | Tap the smiley | Game binding | MatchHud |
| Spectate / Leave | Click | Tap | A / B | `S_Spectate`, `S_Leave` tags (`Utils_ButtonKey`) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Buttons and item cards | `Utils_ButtonScale` from the theme's styles: hover ×1.04, press ×0.92 (`Bouncy`), with `Button_Hover` and `Button_Click` sounds; a held button's skin takes the theme's `Pressed` tint |
| Rarity | Item cards with a rarity style | A reward tile: the rarity's frame, stage and light (`Item` style variants `Common` … `Legendary`) |
| Selected item | `BarSlot` › `Body` | Fill rgb(40, 140, 255) at 0.2 transparency when selected, else black at 0.7 (MatchHud's `SELECTED_*` and `TILE_*` settings) |
