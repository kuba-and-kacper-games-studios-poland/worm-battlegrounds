# MatchHud

The match screen: the team panels in the top corners, the timer, whose turn and the wind at the top, the turn order on the left, the emote button on the right, the move and jump buttons (touch screens) bottom left, the loadout bar with the stamina bar over it at the bottom, the power slider and FIRE (touch screens) bottom right; plus the kill feed, the emote wheel and the blocks for the other phases (waiting, drop, knocked out).

**Look.** Ported 1:1 from the studio's `HUD` gui (2026-11-09) as `Primitive` nodes: its slanted dark cards, pictures and fonts, laid out by screen fractions with aspect-ratio constraints, so the design's frames scale with the screen by themselves (no `S_ScreenScale`). Added to it from pieces of the design: the wait line under the banner (a copy of the banner), Jump (a copy of `>` above the move buttons), the angle and hint line over the power slider and the cooldown count on a slot (copies of the design's texts), the stamina bar (a copy of the power slider without its handle, its bar green) and the LB / RB hints (copies of a slot's key number). Kept from the old hud as the theme's controls (`WormBattlegroundsBrawl`): the kill feed (moved under the right team panel), the emote wheel and the waiting, drop and knocked-out blocks, each with its `S_ScreenScale`. The design's `World` frame (the world labels' look) went to `SnailTag` and `DamagePop`, and its crosshair picture to the MatchHud module's angle marker.

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/MatchHud"` |
| Theme | `WormBattlegroundsBrawl` (for the kept blocks; the design's frames are `Primitive` nodes) |
| Modes | Night only |
| Devices | Desktop, Mobile (shows `U_Touch` and `U_Fire`), Console (shows the LB / RB hints) |
| Export | A ScreenGui named `MatchHud`: `Enabled` off, `DisplayOrder` 0, `ScreenInsets` `DeviceSafeInsets` |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Turn` | Frame (top middle) | Shown while turns run |
| `U_Turn` › `S_Timer` | TextLabel | The turn's time, "0:30"; blank while a shot flies and settles |
| `U_Turn` › `S_Banner` | TextLabel (`TextCase_Upper`) | "Your turn!" in its own colour, or "Bax's turn" in that snail's team colour |
| `U_Turn` › `S_Wait` | TextLabel (`TextCase_Upper`), hidden | Under the banner on other snails' turns: "You're next!" or "Your turn in 3 turns" |
| `U_Turn` › `S_WindArrow` | TextLabel | `&gt;` or `&lt;`, the way the wind blows; hidden in still air |
| `U_Turn` › `S_Wind` | TextLabel | The wind with its side, "+3" or "-3" ("0" in still air) |
| `U_TeamsLeft`, `U_TeamsRight` | Frame (horizontal list), top corners | Hold one `Team` per team: the player's first on the left, then right, left… |
| `U_TurnList` | Frame (vertical list), left | Holds one `TurnEntry` per snail: the one playing, then the next ones |
| `U_EmoteButton` › `Button` | ImageButton (EMOTES), right | Opens `U_EmoteWheel` (the Cosmetics module) |
| `U_Touch` | Frame, bottom left, `Utils_HideOnPlatform` (Mobile only) | Touch controls |
| `U_Touch` › `S_Left`, `S_Right`, `S_Jump` | ImageButton | Walk left, walk right, jump (above them); shown on the player's turn |
| `U_LoadoutBar` | Frame, bottom middle | Shown while the player's snail plays |
| `U_LoadoutBar` › `S_PrevHint`, `S_NextHint` | TextLabel, `Console_Hint` | LB / RB beside the bar on Console |
| `U_Slots` | Frame (horizontal list) | Holds one `BarSlot` per slot key (6) |
| `U_Stamina` | Frame, over the loadout bar | On the player's turn |
| `U_Stamina` › `S_Bar` | ImageLabel with a UIGradient | How far the snail can still walk: the gradient cuts the bar at the share times MatchHud's `BAR_FILL` (0.744, where the picture's fill ends; Stretch, sized 1.2526 × 0.4312) |
| `U_Stamina` › `S_Text` | TextLabel | "Stamina 70%" |
| `U_Power` | Frame, bottom right | The power slider, while the player aims |
| `U_Power` › `S_Bar` | ImageLabel with a UIGradient | The power: the gradient cuts the bar at the share times `BAR_FILL`, like the stamina bar |
| `U_Power` › `S_Handle` › `S_Amount` | ImageButton (not interactable) › TextLabel | The handle rides the bar's edge; "75%" |
| `U_Power` › `S_Info` | TextLabel | Over the slider: the angle, "45°", or a homing missile's hint |
| `U_Fire` | ImageButton (FIRE), bottom right | Touch screens, on the player's turn: fires the aim shown |
| `U_Fire` › `S_Icon` | ImageLabel | The held weapon's icon |
| `U_KillFeed` | Cells (no scroll, `Fixed`), kept | Top right, under the team panel: one `FeedLine` per knockout |
| `U_EmoteWheel` | Frame, kept, hidden | One `WheelEmote` per owned emote, placed on a circle. Has its own `S_ScreenScale` |
| `U_Drop` | Box (`Hud`), kept, hidden | The drop phase: "Pick where to land" and `S_Timer` |
| `U_KnockedOut` | Box (`Panel`), kept, hidden | `S_Spectate`, `S_Leave` |
| `U_Waiting` | Box (`Hud`), kept, hidden | "Waiting for players" and `S_Count` |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| BarSlot` | `U_Slots` | An ImageButton: `S_Icon`, `S_Key` ("1"–"6", Desktop only), `S_Uses` ("x5"), `S_Name`, `S_Turns` (the cooldown's turns left, hidden), `S_Plus` (an empty slot's "+", hidden), `Background` › `Stroke` (the outline the looks recolour) |
| `PREFAB \| TurnEntry` | `U_TurnList` | `S_Avatar`, `S_Name`, `Background` › `Main`, `Stroke`, `S_Mask` (the current look's shine) |
| `PREFAB \| Team` | `U_TeamsLeft` (clones go on either side) | `S_Players` (a horizontal list holding the nested `PREFAB \| TeamPlayer`), `S_Name` (`TextCase_Upper`) |
| `PREFAB \| TeamPlayer` | nested in `Team` › `S_Players`, hidden | `S_Avatar`, `Background` › `Main`, `Stroke2`, `Stroke` |
| `PREFAB \| FeedLine` | `U_KillFeed` | A Label: "Bax knocked out Ninja with the Black hole grenade", names in team colours (rich text) |
| `PREFAB \| WheelEmote` | `U_EmoteWheel` | An Item (`S_Icon`, `S_Name`, `S_Info`, `Button`), anchored at its centre |

## Driven by

The game's `MatchHud` module: it turns the ScreenGui on while the player is in a match and shows each block in its phase. The Cosmetics module fills the emote wheel and opens it from `U_EmoteButton`.

## Preview

`Preview.lua` shows the phases and fills the screen as the module does.

| Setting | What it does |
| --- | --- |
| `S_Phase` (Segmented: Waiting, Drop, Turn, Out) | Which blocks show |
| `S_MyTurn` (Toggle) | On: "Your turn!", stamina and the slider; off: "Ninja's turn" in red with the wait under it |
| `S_Aiming` (Toggle) | The power slider (and FIRE on Mobile) shows |
| `S_Power` (Slider) | The slider's power |
| `S_Slots` (Slider, 1 to 6) | Loadout items; the rest of the 6 slots show "+" (the second item cools down) |
| `S_Teams` (Slider, 2 to 4) | Teams of two in the corners |
| `S_Feed` (Slider, 0 to 3) | Kill feed lines |
| `S_Wheel` (Toggle) | Opens the emote wheel |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `MatchHud`, `Enabled` off. Its module turns it on while the player is in a match. The kept blocks' `S_ScreenScale` UIScales are set by the game's ScreenScale module (`MatchHud` is in its `GUIS` list), laid out for a 1920 × 1080 screen, times the device scale their `Utils_PlatformScale` tag keeps; the design's frames need nothing. Capitals texts carry `TextCase_Upper`, so what code writes there shows in capitals.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Pick a loadout slot | 1–6 or click | Tap | LB / RB | MatchHud (`MatchHud_Slots`, `I.Interact.OnPress`) |
| Aim and set the power | Mouse from the snail, hold | Drag | Right stick, hold RT | MatchHud (Aim) |
| Fire | Let go of the mouse | `U_Fire` (the aim stays after the drag) | Let go of RT | MatchHud (Aim) |
| Walk, jump | Game controls | `S_Left`, `S_Right`, `S_Jump` | Game controls | MatchHud and SnailControl |
| Emote wheel | Click EMOTES | Tap EMOTES | — | Cosmetics |
| Spectate / Leave | Click | Tap | A / B | `S_Spectate`, `S_Leave` tags (`Utils_ButtonKey`) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Slots, EMOTES, FIRE, move and jump buttons | `Utils_ButtonScale` (`Bouncy`, hover ×1.04, press ×0.92) with `Button_Hover` and `Button_Click` |
| Selected item | `BarSlot` › `Background` › `Stroke` | `ImageColor3` = `Look_SelectedStrokeColor` (white); others `Look_StrokeColor` (grey) |
| Empty slot | `BarSlot` | `S_Plus` shown, the rest hidden, `Stroke` = `Look_EmptyStrokeColor`, not interactable |
| Cooling down | `BarSlot` › `S_Icon` (and a model's `S_Model`) | `ImageColor3` = `Look_CooldownIconColor`, `S_Turns` shown |
| Current snail | `TurnEntry` › `Background` | `Main` takes `Look_CurrentMain` and `Look_CurrentMainColor` (orange), `Stroke` `Look_CurrentStrokeColor`, `S_Mask` shown; others `Look_Main`, `Look_MainColor` and their team colour on `Stroke` |
| Side | `TeamPlayer` › `Background` | `Main`, `Stroke2`, `Stroke` take `Look_Left*` or `Look_Right*` (mirrored slants); `Stroke` tinted the team colour |
| Bar fill | `U_Stamina` › `S_Bar`, `U_Power` › `S_Bar` | Their `UIGradient.Transparency` is opaque up to the share times `BAR_FILL`, clear after it |
| Rarity, hover (kept blocks) | Item cards and buttons from the theme | The theme's `Item` and `Button` looks |
