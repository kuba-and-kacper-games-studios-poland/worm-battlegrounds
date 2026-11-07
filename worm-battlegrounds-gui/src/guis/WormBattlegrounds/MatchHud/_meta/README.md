# MatchHud

The match screen: whose turn, the timer and the wind at the top; the kill feed at the top right; one row at the bottom: walk buttons (touch screens), the loadout bar with stamina and the shot's power on top of it, the emote smiley and Jump (touch screens); and the blocks for the other phases (waiting, drop, knocked out) and the emote wheel.

**Look.** The GUI kit (`WormBattlegroundsBrawl`, the theme's README). The turn, loadout bar, drop and waiting blocks are `Hud` boxes (a darker see-through slot, no frame), so the arena stays in view; the knocked-out dialog stays a window with Spectate in yellow. The loadout bar is 720 wide for 112 slots, with a row on top for stamina (the player's turn) and power with the angle (while aiming): inside one block they stay on the bar on every screen, and the block is only as tall as what shows. Jump is blue; cooldowns read on a darker cover. Every block is placed by screen fractions, so positions scale with the screen as sizes do. The bottom row shares one line: walk buttons in the bottom-left corner, the bar in the middle, the emote smiley at 81 % across, Jump in the bottom-right corner (on a 667 × 375 phone the row is about 28 % of the height while aiming). The kill feed and the emote button scale too (the emote button through the `Item` control's `Screen`), tagged `Utils_PlatformScale` like the theme's panels; the kill feed sits under the top bar. On phones and tablets the turn and drop panels are at 0.7 (their smallest text 15 px on a phone) and the kill feed is 440 wide, beside the turn panel; no text is under 14 px on a 667 × 375 phone. The walk and jump buttons scale with the screen through the `Button` control's `Screen`. The turn panel says whose turn it is (the player's, or another snail's name in its team colour with the player's wait under it), then the kit's clock beside the timer and its wind picture (`wb-wind`) beside the wind's arrow and strength; on a PC at 1024 × 768 (ScreenScale's 0.6 floor) its text is 14 px and up.

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
| `U_Turn` › `S_Banner` | Label (`Title`, capitals) | "Your turn!" on the player's own turn, in the gui's colour; on other snails' turns "Bax's turn" in that snail's team colour |
| `U_Turn` › `S_Wait` | Label (`Heading`, capitals) | Hidden on the player's own turn and once their snail is out; otherwise "You're next!" or "Your turn in 3 turns" |
| `U_Turn` › `S_Timer` | Label (`Display`) | The turn timer, beside the kit's clock (`wb-clock`); blank while a shot flies and settles |
| `U_Turn` › `S_WindArrow` | Picture (`Glyph`) | Beside the wind picture (`wb-wind`); rotated to the wind's direction, hidden in still air |
| `U_Turn` › `S_Wind` | Label (`Heading`) | The wind's strength, "4" (0 to 10) |
| `U_KillFeed` | Cells (no scroll, `Fixed`) | Top right: holds one `FeedLine` per knockout |
| `U_LoadoutBar` | Box (`Hud`) | Bottom middle. Has `S_ScreenScale`. Its top row holds `U_Stamina` and `U_Power`, sharing the width |
| `U_LoadoutBar` › `S_PrevHint`, `S_NextHint` | Label, tagged `Console_Hint` | LB / RB beside the bar on Console |
| `U_Slots` | Cells (horizontal, no scroll) | Holds one `BarSlot` per loadout slot |
| `U_Stamina` | Stack, in `U_LoadoutBar` (find it recursively) | On the player's turn |
| `U_Stamina` › `S_Bar` | Progress (`Stamina`) | How far the snail can still walk: its status reads "Stamina 70%" |
| `U_EmoteButton` | Item (`Small`) | The smiley, right of the bar: opens `U_EmoteWheel` |
| `U_Power` | Stack (horizontal), in `U_LoadoutBar` (find it recursively) | While aiming |
| `U_Power` › `S_Bar` | Progress (`Power`) | The shot's power: its status reads "Power 60%" |
| `U_Power` › `S_Angle` | Label (`Heading`) | "45°", beside the bar; sized for "-90°" |
| `U_Touch` | Frame, `Utils_HideOnPlatform` (Mobile only) | Touch controls |
| `U_Touch` › `S_Left`, `S_Right`, `S_Jump` | Button | Walk left, walk right (bottom-left corner), jump (bottom-right corner) |
| `U_EmoteWheel` | Frame | Hidden; holds one `WheelEmote` per owned emote, placed on a circle. Has its own `S_ScreenScale` |
| `U_Drop` | Box (`Panel`) | Hidden; the drop phase: "Pick where to land" and `S_Timer` |
| `U_KnockedOut` | Box (`Panel`) | Hidden; `S_Spectate`, `S_Leave` |
| `U_Waiting` | Box (`Panel`) | Hidden; "Waiting for players" and `S_Count` |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB | BarSlot` | `U_Slots` | An Item (`S_Icon`; selected = highlighted), `S_Key` ("1"–"5", Desktop only) and `S_Uses` ("x3", a plain x: the kit's font has no ×), corner badges sized by the slot (half and 0.6 of its width, 0.4 of its height), `S_Cooldown` (cover) › `S_Turns` |
| `PREFAB | FeedLine` | `U_KillFeed` | A Label: "Bax knocked out Ninja with the Black hole grenade", names in team colours (rich text); one line tall, two for a line too long for the feed |
| `PREFAB | WheelEmote` | `U_EmoteWheel` | An Item (`S_Icon`), anchored at its centre |

## Driven by

The game's `MatchHud` module: it turns the ScreenGui on on the Match map and shows each block in its phase.

## Preview

`Preview.lua` shows the phases.

| Setting | What it does |
| --- | --- |
| `S_Phase` (Segmented: Waiting, Drop, Turn, Out) | Which blocks show |
| `S_MyTurn` (Toggle) | On: "Your turn!", stamina and power; off: "Bax's turn" in red with the wait under it |
| `S_Aiming` (Toggle) | Power shows (while aiming) |
| `S_Slots` (Slider, 3 to 5) | Loadout slots (the second one cools down) |
| `S_Feed` (Slider, 0 to 3) | Kill feed lines |
| `S_Wheel` (Toggle) | Opens the emote wheel |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `MatchHud`, `Enabled` off. Its module turns it on while its map runs. A restyled copy keeps its `Name`, Ids and prefab names. Every panel with an `S_ScreenScale` is laid out for a 1920 × 1080 screen and placed by screen fractions: the game's ScreenScale module sets the UIScale to the screen's height / 1080 (width / 1920 on screens narrower than 16:9), ×1.3 on Mobile screens shorter than 500 px and never under 0.6 on other devices, times the device scale its `Utils_PlatformScale` tag keeps (`Utils_BaseScale`), when it shows and when the screen changes size. Capitals-styled texts carry the `TextCase_Upper` tag, so what code writes there shows in capitals too (the theme's README). `U_KillFeed` has its own `S_ScreenScale` (a `Primitive` UIScale) and a Mobile size (`Utils_PlatformSize`, 440 × 320); each touch button has its own.

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
| No icon picture | `BarSlot` › `S_Icon` | The game adds a ViewportFrame `S_Model` filling the icon, with the weapon's 3D model side-on (MatchHud's `MODEL_*` settings) |
| Selected item | `BarSlot` › `Body` | Fill rgb(40, 140, 255) at 0.2 transparency when selected, else black at 0.7 (MatchHud's `SELECTED_*` and `TILE_*` settings) |
