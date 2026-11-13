# MatchHud

The match screen: the team panels in the top corners, the timer, whose turn and the wind at the top, the turn order on the left, the emote button on the right, the move and jump buttons (touch screens) bottom left, the loadout bar with the stamina bar over it at the bottom, the power slider and FIRE (touch screens) bottom right; plus the kill feed, the emote wheel and the blocks for the other phases (waiting, drop, knocked out).

**Look.** Ported 1:1 from the studio's `HUD` gui (2026-11-09) as `Primitive` nodes: its slanted dark cards, pictures and fonts, laid out by screen fractions with aspect-ratio constraints, so the design's frames scale with the screen by themselves (no `S_ScreenScale`). Added to it from pieces of the design: the wait line under the banner (a copy of the banner), Jump (a copy of `>` above the move buttons), the angle and hint line over the power slider and the cooldown count on a slot (copies of the design's texts), the stamina bar (a copy of the power slider without its handle, its bar green) and the LB / RB hints (copies of a slot's key number). Kept from the old hud as the theme's controls (`WormBattlegroundsBrawl`): the kill feed (moved under the right team panel), the emote wheel and the waiting, drop and knocked-out blocks, each with its `S_ScreenScale`. The design's `World` frame (the world labels' look) went to `SnailTag` and `DamagePop`, and its crosshair picture to the MatchHud module's angle marker. Added on 2026-11-10 as `Primitive` nodes (the owner turned down the GUI kit's yellow Hazard plate for them: "this is old style, the new style is MatchBoard or MatchHud"): the tension band, and the turn callout. The callout was first two blocks on the timer's trapezoid frame pictures; later that day it became one banner (the owner: "the ui your turn looks bad, polish it up, make it look professional", "add the player avatar/bot icon"): a full-width dark band with accent lines, the snail's rounded square avatar, and the turn's text in the timer's font (`rbxassetid://12187365977`, Heavy Italic).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/MatchHud"` |
| Theme | `WormBattlegroundsBrawl` (for the kept blocks; the design's frames are `Primitive` nodes) |
| Modes | Night only |
| Devices | Desktop, Mobile (shows `U_Touch` and `U_Fire`), Console (shows the pad hints: LB / RB, X on EMOTES, Y on a utility slot, `U_PadControls`) |
| Export | A ScreenGui named `MatchHud`: `Enabled` off, `DisplayOrder` 0, `ScreenInsets` `DeviceSafeInsets` (the MatchHud module switches it to `CoreUISafeInsets` on Mobile, below Roblox's top bar) |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Turn` | Frame (top middle) | Shown while turns run |
| `U_Turn` › `S_Timer` | TextLabel | The turn's time, "0:30"; blank while a shot flies and settles |
| `U_Turn` › `S_Banner` | TextLabel (`TextCase_Upper`) | "Your turn!" in its own colour, or "Bax's turn" in that snail's team colour |
| `U_Turn` › `S_Wait` | TextLabel (`TextCase_Upper`), hidden | Under the banner on other snails' turns: "You're next!" or "You play in 3 turns" |
| `U_Turn` › `S_WindArrow` | TextLabel | `&gt;` or `&lt;`, the way the wind blows; hidden in still air |
| `U_Turn` › `S_Wind` | TextLabel | The wind with its side, "+3" or "-3" ("0" in still air) |
| `U_TeamsLeft`, `U_TeamsRight` | Frame (horizontal list), top corners | Hold one `Team` per team: the player's first on the left, then right, left… |
| `U_TurnList` | Frame (vertical list), left | Holds one `TurnEntry` per snail: the one playing, then the next ones |
| `U_EmoteButton` › `Button` | ImageButton (EMOTES), right | Opens `U_EmoteWheel` (the Cosmetics module) |
| `U_Touch` | Frame, bottom left, `Utils_HideOnPlatform` (Mobile only) | Touch controls |
| `U_Touch` › `S_Left`, `S_Right`, `S_Jump` | ImageButton | Walk left, walk right, jump (above them, wider, its card drawn in three slices so the corners keep their shape: the gui maker's, 2026-11-11); shown on the player's turn |
| `U_Aim` | Frame, the whole screen, see-through, ZIndex 0 (under the rest of the HUD) | The aim layer: MatchHud's Aim places the crosshair and the power circles in it, in pixels over the snail |
| `U_Aim` › `S_Crosshair` | Frame (hidden; sized and placed by code), ZIndex 100 | Worms Armageddon's crosshair: a ring (`RingOutline`, then `S_Ring` › `S_RingLine`, UIStrokes centred on the edge, `ScaledSize`) under an X (`ArmOutline` bars, then `S_ArmA`, `S_ArmB`), outlined in dark (20, 14, 10); it spins |
| `U_LoadoutBar` | Frame, bottom middle | Shown while the player's snail plays |
| `U_LoadoutBar` › `S_PrevHint`, `S_NextHint` | ImageLabel, `Console_Hint` (`Console_Action` `WeaponPrevious`, `WeaponNext`) | LB / RB beside the bar on Console |
| `U_PadControls` | Frame, `Console_Hint` (`Console_HintHidden` until the player's turn) | The match's pad controls at the bottom left, a row each (`Console_Action`): charge and fire, aim, jump, move, camera, zoom in and out, menus |
| `U_EmoteButton` › `Button` › `PadHint` | ImageLabel, `Console_Hint` (`Emotes`) | X on the EMOTES button |
| `U_Slots` | Frame (horizontal list) | Holds one `BarSlot` per slot key (7: the Bazooka and loadout slots 1 to 6) |
| `U_Stamina` | Frame, over the loadout bar | On the player's turn |
| `U_Stamina` › `S_Bar`, `S_BarMask` | ImageLabels (`Fit`) with a UIGradient each | How far the snail can still walk: the bar and its texture, cut by their gradients at the share times MatchHud's `BAR_FILL` (1: the studio's complete PowerSlider, 2026-11-12, fills its whole width; sized 0.9319 × 0.4312, as the track) |
| `U_Stamina` › `S_Text` | TextLabel | "Stamina 70%" |
| `U_Power` | Frame, bottom right | The power slider, while the player aims |
| `U_Power` › `S_Bar`, `S_BarMask` | ImageLabels (`Fit`) with a UIGradient each | The power: the gradients cut the bar and its texture at the share times `BAR_FILL`, like the stamina bar (the studio's PowerSlider, node for node) |
| `U_Power` › `S_Handle` › `S_Amount` | ImageButton (not interactable) › TextLabel | The handle rides the bar's edge; "75%" |
| `U_Power` › `S_Info` | TextLabel | Over the slider: the angle, "45°", or a homing missile's hint |
| `U_Fire` | ImageButton (FIRE, the gui maker's painted button, 2026-11-11), bottom right | Touch screens, on the player's turn: held, charges the aim shown; let go, fires |
| `U_Fire` › `S_Icon` | ImageLabel | The held weapon's icon |
| `U_KillFeed` | Cells (no scroll, `Fixed`), kept | Top right, under the team panel: one `FeedLine` per knockout |
| `U_EmoteWheel` | Frame, kept, hidden | One `WheelEmote` per owned emote, placed on a circle. Has its own `S_ScreenScale` |
| `U_Drop` | Box (`Hud`), kept, hidden | The drop phase: "Pick where to land" and `S_Timer` |
| `U_KnockedOut` | Frame, the studio's KnockedOut (2026-11-12), hidden | YOU WERE KNOCKED OUT! over `S_Spectate` (yellow, A) and `S_Leave` (red, B), ImageButtons with `Console_Hint` badges |
| `U_Waiting` | Box (`Hud`), kept, hidden | "Waiting for players" and `S_Count` |
| `U_TurnCallout` | Frame, hidden, see-through, across the screen (Position 0.5, 0.34; 1 × 0.14 of the screen; ZIndex 10) | The turn banner, shown as each turn starts (the player's own and anyone else's) |
| `U_TurnCallout` › `S_Band` | Frame ((14, 14, 22) at 0.2 transparency, a UIGradient fading its left and right edges) | Opened and closed by its height (`Size` 1 × 0 to 1 × 1) |
| `S_Band` › `S_LineTop`, `S_LineBottom` | Frame (0.045 of the band's height, orange (255, 140, 20), ends faded by a UIGradient) | `BackgroundColor3` = MatchHud's `CALLOUT_ACCENT_COLOR`, or the snail's `Color` |
| `U_TurnCallout` › `S_Content` | Frame, see-through, centred (0.34 × 0.86 of the banner) | Slid in from the left and on to the right (`Position` X) |
| `S_Content` › `S_Pop` | UIScale | Settles from MatchHud's `CALLOUT_START_SCALE` to 1, or to `CALLOUT_OTHER_SCALE` for anyone else's turn |
| `S_Content` › `S_Avatar` | ImageLabel (square, `UICorner` 0.22, `Crop`; the design's player picture in the gui) | The snail's headshot, or `BOT_AVATAR` for a bot |
| `S_Avatar` › `S_AvatarStroke` | UIStroke (`Border`, `ScaledSize` 0.06, orange) | `Color` = the accent, as the lines |
| `S_Content` › `S_Title` | TextLabel (`TextCase_Upper`, the timer's font Heavy Italic, white under its gradient, a dark (20, 14, 10) `ScaledSize` UIStroke) | "Your turn!" or "Bax's turn" |
| `S_Title` › `S_TitleGradient` | UIGradient (top to bottom) | `Color` = MatchHud's `CALLOUT_MINE_GRADIENT` (gold) or `CALLOUT_OTHER_GRADIENT` (white) |
| `S_Content` › `S_Sub` | TextLabel (`TextCase_Upper`, Bold Italic, (225, 225, 235), the same dark UIStroke) | "Aim and fire!", "You're next!" or "You play in 3 turns" |
| `U_Tension` | Frame, hidden, the whole screen (0.99 × 0.985) | Shown in the last `TICK_SOUND_FROM` seconds of the player's own turn |
| `U_Tension` › `S_Glow` | UIStroke (red (240, 60, 30), 14 px, `Border`, a UIGradient clearer at the middle of each side) | Its `Transparency` pulses (1 in the gui) |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| BarSlot` | `U_Slots` | An ImageButton: `S_Icon`, `S_Key` ("1"–"7", Desktop only), `S_Uses` ("x5"), `S_Name`, `S_Turns` (the cooldown's turns left, hidden), `S_Plus` (an empty slot's "+", hidden), `S_UseHint` (Y on Console, a `Console_Hint` with `Console_Action` `UseUtility`, hidden by `Console_HintHidden` until the pad's cursor rests on the slot), `Background` › `Stroke` (the outline the looks recolour) |
| `PREFAB \| TurnEntry` | `U_TurnList` | `S_Name` (with a `UITextSizeConstraint`), `S_Badges` (Frame: PlayerBadges clones its hidden `PREFAB \| Badge`, an ImageLabel with an `S_Glyph` TextLabel for Roblox's verified and Premium glyphs, once per badge and lays them out after the name, whose `UITextSizeConstraint` it lowers so the name stays on one line), `Background` › `Main`, `S_Avatar` (square, under the outlines), `Stroke`, `S_Mask` (the current look's shine) |
| `PREFAB \| Team` | `U_TeamsLeft` (clones go on either side) | `S_Players` (a horizontal list holding the nested `PREFAB \| TeamPlayer`), `S_Name` (`TextCase_Upper`) |
| `PREFAB \| TeamPlayer` | nested in `Team` › `S_Players`, hidden | `Background` › `Main`, `S_Avatar` (square, under the outlines), `Stroke2`, `Stroke` |
| `PREFAB \| FeedLine` | `U_KillFeed` | A Label: "Bax knocked out Ninja with the Black hole grenade", names in team colours (rich text) |
| `PREFAB \| WheelEmote` | `U_EmoteWheel` | An Item (`S_Icon`, `S_Name`, `S_Info`, `Button`), anchored at its centre |
| `PREFAB \| PowerDot` | `U_Aim` | A round white Frame (`UICorner` 0.5, no outline) with a `UIGradient`: one circle of the power cone, which Aim clones `POWER_DOTS` times and sizes, colours (the gradient, along the aim) and places |

## Driven by

The game's `MatchHud` module: it turns the ScreenGui on while the player is in a match and shows each block in its phase, plays the turn callout as turns start and pulses `U_Tension` in the player's last seconds (its `Turn` handler). The Cosmetics module fills the emote wheel and opens it from `U_EmoteButton`.

## Preview

`Preview.lua` shows the phases and fills the screen as the module does. It doesn't show the turn callouts or the tension band.

| Setting | What it does |
| --- | --- |
| `S_Phase` (Segmented: Waiting, Drop, Turn, Out) | Which blocks show |
| `S_MyTurn` (Toggle) | On: "Your turn!", stamina and the slider; off: "Ninja's turn" in red with the wait under it |
| `S_Aiming` (Toggle) | The power slider (and FIRE on Mobile) shows |
| `S_Power` (Slider) | The slider's power |
| `S_Slots` (Slider, 1 to 7) | Loadout items; the rest of the 7 slots show "+" (the second item cools down) |
| `S_Teams` (Slider, 2 to 4) | Teams of two in the corners |
| `S_Feed` (Slider, 0 to 3) | Kill feed lines |
| `S_Wheel` (Toggle) | Opens the emote wheel |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `MatchHud`, `Enabled` off. Its module turns it on while the player is in a match. The kept blocks' `S_ScreenScale` UIScales are set by the game's ScreenScale module (`MatchHud` is in its `GUIS` list), laid out for a 1920 × 1080 screen, times the device scale their `Utils_PlatformScale` tag keeps; the design's frames need nothing. Capitals texts carry `TextCase_Upper`, so what code writes there shows in capitals. Last exported to StarterGui on 2026-11-13 (`UmeGui.Export`, with "You play in N turns"); the exports before are kept in `ServerStorage.!dump` as `MatchHud_before_2026-11-10` and `MatchHud_before_2026-11-13`.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Pick a loadout slot | 1–7 or click | Tap | LB / RB (a utility only gets the cursor), Y uses it | MatchHud (`MatchHud_Slots`; the pad through `I.Console`: `WeaponPrevious`, `WeaponNext`, `UseUtility`) |
| Aim | The mouse, from the snail | A finger on the arena (the aim stays where it lifts) | Right stick | MatchHud (Aim) |
| Charge the power | Hold the left button | Hold `U_Fire` | Hold RT | MatchHud (Aim; Combat's `CHARGE_SECONDS`, firing by itself at full) |
| Fire | Let go | Let go of `U_Fire` | Let go of RT | MatchHud (Aim) |
| Walk, jump | Game controls | `S_Left`, `S_Right`, `S_Jump` | Game controls | MatchHud and SnailControl |
| Emote wheel | Click EMOTES | Tap EMOTES | X, then the selection (B closes it) | `Button` tags (`Utils_ButtonKey`); Cosmetics (`I.Console.Focus`) |
| Zoom | Mouse wheel | Pinch | D-pad up / down | MatchCamera (`I.Console`: `ZoomIn`, `ZoomOut`) |
| HUD and top bar buttons | Click | Tap | View starts the selection, A presses | Console (`Navigate`) |
| Spectate / Leave | Click | Tap | A / B | `S_Spectate`, `S_Leave` tags (`Utils_ButtonKey`) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Slots, EMOTES, FIRE, move and jump buttons | `Utils_ButtonScale` (`Bouncy`, hover ×1.04, press ×0.92) with `Button_Hover` and `Button_Click` |
| Selected item | `BarSlot` › `Background` › `Stroke` | `ImageColor3` = `Look_SelectedStrokeColor` (white); others `Look_StrokeColor` (grey) |
| Empty slot | `BarSlot` | `S_Plus` shown, the rest hidden, `Stroke` = `Look_EmptyStrokeColor`, not interactable |
| Cooling down | `BarSlot` › `S_Icon` (and a model's `S_Model`) | `ImageColor3` = `Look_CooldownIconColor`, `S_Turns` shown |
| Turn callout, the player's own | `S_TitleGradient`; `S_LineTop`, `S_LineBottom`, `S_AvatarStroke` | Gold `CALLOUT_MINE_GRADIENT`; orange `CALLOUT_ACCENT_COLOR` |
| Turn callout, anyone else's | `S_TitleGradient`; `S_LineTop`, `S_LineBottom`, `S_AvatarStroke`; `S_Pop` | White `CALLOUT_OTHER_GRADIENT`; the snail's `Color`; at `CALLOUT_OTHER_SCALE` |
| Current snail | `TurnEntry` › `Background` | `Main` takes `Look_CurrentMain` and `Look_CurrentMainColor` (orange), `Stroke` `Look_CurrentStrokeColor`, `S_Mask` shown; others `Look_Main`, `Look_MainColor` and their team colour on `Stroke` |
| Side | `TeamPlayer` › `Background` | `Main`, `Stroke2`, `Stroke` take `Look_Left*` or `Look_Right*` (mirrored slants); `Stroke` tinted the team colour |
| Aiming snail | `S_Crosshair` › `S_RingLine` (`Color`), `S_ArmA`, `S_ArmB` (`BackgroundColor3`) | The snail's `Color`: its team's, or its own in a free-for-all |
| Power | `PowerDot` clones | Yellow (255, 226, 92) through orange (255, 148, 38) to red (240, 62, 46), first to last, blended into one: each circle's `UIGradient` runs the cone's colours from its back edge to its front, turned along the aim; each grows from nothing to its size as the power passes it |
| Bar fill | `U_Stamina` › `S_Bar`, `U_Power` › `S_Bar` | Their `UIGradient.Transparency` is opaque up to the share times `BAR_FILL`, clear after it |
| Rarity, hover (kept blocks) | Item cards and buttons from the theme | The theme's `Item` and `Button` looks |
