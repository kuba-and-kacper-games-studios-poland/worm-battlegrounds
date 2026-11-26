# MatchHud

The match screen: the team panels in the top corners, the timer, whose turn and the wind at the top, the turn order on the left, the emote button on the right, the move and jump buttons (touch screens) bottom left, the loadout bar with the stamina bar over it at the bottom, the power slider and FIRE (touch screens) bottom right; plus the kill feed, the emote wheel and the blocks for the other phases (waiting, drop, knocked out).

**Look.** Ported 1:1 from the studio's `HUD` gui (2026-11-09) as `Primitive` nodes: its slanted dark cards, pictures and fonts, laid out by screen fractions with aspect-ratio constraints, so the design's frames scale with the screen by themselves (no `S_ScreenScale`). Added to it from pieces of the design: the wait line under the banner (a copy of the banner), Jump (a copy of `>` above the move buttons), the angle and hint line over the power slider and the cooldown count on a slot (copies of the design's texts), the stamina bar (a copy of the power slider without its handle, its bar green) and the LB / RB hints (copies of a slot's key number). Kept from the old hud as the theme's controls (`WormBattlegroundsBrawl`): the kill feed (moved under the right team panel) and the waiting block, each with its `S_ScreenScale`. The design's `World` frame (the world labels' look) went to `SnailTag` and `DamagePop`, and its crosshair picture to the MatchHud module's angle marker. Added on 2026-11-10 as `Primitive` nodes (the owner turned down the GUI kit's yellow Hazard plate for them: "this is old style, the new style is MatchBoard or MatchHud"): the tension band, and the turn callout. The callout was first two blocks on the timer's trapezoid frame pictures; later that day it became one banner (the owner: "the ui your turn looks bad, polish it up, make it look professional", "add the player avatar/bot icon"): a full-width dark band with accent lines, the snail's rounded square avatar, and the turn's text in the timer's font (`rbxassetid://12187365977`, Heavy Italic). Rebuilt on 2026-11-17 as `Primitive` nodes in the hud's look (the polish pass the owner approved): the emote wheel (a real ring of dark glass slices on a dark backing, the pointed one lit in the player's colour, the name in a dialog-look disc in the middle) and the emote button's picture and key cap. No new pictures: frames, `UICorner`, `UIStroke`s and `UIGradient` cuts (a slice is a disc cut by one gradient on it and one on its `CanvasGroup`). The drop's timer, a ring timer for a few hours that day, became a copy of `U_Turn`'s timer plate with "Pick where to land" under it (the owner: "make it more subtle, this one looks like it's from a different game"); in local play the turn callout also holds for the hand-off (the `LocalHandOff` card it replaced overlapped it).

|  |  |
| --- | --- |
| Path | `"WormBattlegrounds/MatchHud"` |
| Theme | `WormBattlegroundsBrawl` (for the kept blocks; the design's frames are `Primitive` nodes) |
| Modes | Night only |
| Devices | Desktop, Mobile (shows `U_Touch` and `U_TouchJump`, `U_Fire` bigger), Console (shows the pad hints: LB / RB, RT on FIRE, X on EMOTES, Y on a utility slot, `U_PadControls`) |
| Export | A ScreenGui named `MatchHud`: `Enabled` off, `DisplayOrder` 0, `ScreenInsets` `None` (the whole screen out to a phone's edges, 2026-11-25; the MatchHud module gives consoles `DeviceSafeInsets` and, on Mobile, pads the top below Roblox's top bar with `U_Inset`, a UIPadding at the root), `ClipToDeviceSafeArea` off (so `U_BattleIntro`, which its module stretches over the whole device, reaches a phone's notch sides and top bar row: 2026-11-25) |

## Elements

| Element | Kind | What game code does with it |
| --- | --- | --- |
| `U_Turn` | Frame (top middle; 0.8 of its size on Mobile, `Utils_PlatformSize`, where the MatchHud module also lifts it to the top: 2026-11-25) | Shown while turns run |
| `U_Turn` › `S_Timer` | TextLabel | The turn's time, "0:30"; blank while a shot flies and settles |
| `U_Turn` › `S_Banner` | TextLabel (`TextCase_Upper`) | "Your turn!" in its own colour (not on Mobile), or "Bax's turn" in that snail's team colour |
| `U_Turn` › `S_Wait` | TextLabel (`TextCase_Upper`), hidden | Under the banner on other snails' turns: "You're next!" or "You play in 3 turns" |
| `U_Turn` › `S_WindArrow` | TextLabel | `&gt;` or `&lt;`, the way the wind blows; hidden in still air |
| `U_Turn` › `S_Wind` | TextLabel | The wind with its side, "+3" or "-3" ("0" in still air) |
| `U_TeamsLeft`, `U_TeamsRight` | Frame (horizontal list), top corners | Hold one `Team` per team: the player's first on the left, then right, left… |
| `U_TurnList` | Frame (vertical list), left | Holds one `TurnEntry` per snail: the one playing, then the next ones |
| `U_EmoteButton` › `Button` | ImageButton (EMOTES), right | Opens `U_EmoteWheel` to pick from (the Cosmetics module); no `Utils_ButtonKey` since 2026-11-17, as Cosmetics reads T and X held itself |
| `U_EmoteButton` › `S_Icon` | ImageLabel | The button's emote's picture (Cosmetics' `WHEEL_BUTTON_EMOTE`, the Wave's Inventory `IconId`) |
| `U_EmoteButton` › `Button` › `KeyHint` | Frame (a key cap, "T"), `Utils_HideOnPlatform` (Desktop only) | T on the button's bottom right corner |
| `U_Touch` | Frame, bottom left, 0.1794 × 0.154 (1.3 times the design's since 2026-11-25, as `U_TouchJump`), `Utils_HideOnPlatform` (Mobile only) | Touch controls |
| `U_Touch` › `S_Left`, `S_Right` | ImageButton | Walk left, walk right; shown on the player's turn |
| `U_TouchJump` › `S_Jump` | Frame at the bottom of `BottomRight`, `Utils_HideOnPlatform` (Mobile only) › ImageButton | Jump (its card drawn in three slices so the corners keep their shape: the gui maker's, 2026-11-11; moved over FIRE in the place, then into the gui, 2026-11-15); shown on the player's turn |
| `U_Aim` | Frame, the whole screen, see-through, ZIndex 0 (under the rest of the HUD) | The aim layer: MatchHud's Aim places the crosshair, the power circles, the power ring, the readout and the preview's dots in it, in pixels over the snail |
| `U_Aim` › `S_PowerRing` | Frame (hidden; sized and placed by code), `UICorner` 0.5, `S_PowerRingStroke` (white, 2 px, 0.75 see-through), ZIndex 0 | On the player's turn, round their snail: the crosshair's place at full power |
| `U_Aim` › `S_PowerWedge` › `S_WedgeTop`, `S_WedgeBottom` | Frame (hidden, ZIndex 10) holding two white halves, each with a `UIGradient` whose transparency steps from 1 to 0.55 at 0.5 | The power wedge (2026-11-25, ShellShock Live's way): Aim sizes, turns and places it from the snail to the crosshair's ring, colours the halves by the power and turns each gradient so its step cuts the half along its diagonal |
| `U_Aim` › `S_Readout` | TextLabel (hidden), 220 × 30 px at 15 px text, capitals; 160 × 11 px on phones and tablets (`Utils_PlatformSize`), where the text shrinks to fit (2026-11-25: "too big on the mobile") | Over the crosshair: "62% · 41°", the angle alone for a gun, or a homing missile's `TARGET_HINTS` |
| `U_Aim` › `S_Crosshair` | Frame (hidden; sized and placed by code), ZIndex 100 | Worms Armageddon's crosshair: a ring (`RingOutline`, then `S_Ring` › `S_RingLine`, UIStrokes centred on the edge, `ScaledSize`) under an X (`ArmOutline` bars, then `S_ArmA`, `S_ArmB`), outlined in dark (20, 14, 10); it spins |
| `U_Aim` › `S_TargetMark` | Frame (hidden; sized and placed by code), ZIndex 99 | A homing missile's locked target, a lock-on mark of its own (the owner, 2026-11-25: "a bit different so player knows its a homing missile target - also a bit bigger", then "polish the icon"): a soft red `Glow` disc, a ring outlined in ink (red under a light-to-dark `UIGradient`), a lit dot in the middle (`Dot` under its gradient, a small `Shine`), and `S_TargetBrackets`, four red L brackets outlined in ink at its corners, which Aim turns and closes in on the spot as it's placed; Aim sizes it `TARGET_MARK_SIZE` and never spins the whole mark |
| `U_LoadoutBar` | Frame, bottom middle | Shown while the player's snail plays |
| `U_LoadoutBar` › `S_PrevHint`, `S_NextHint` | ImageLabel, `Console_Hint` (`Console_Action` `WeaponPrevious`, `WeaponNext`) | LB / RB on Console, right outside the first and last slot (LoadoutBar places them as the loadout is built, 2026-11-25) |
| `U_PadControls` | Frame, `Console_Hint` (`Console_HintHidden` until the player's turn) | The match's pad controls at the bottom left, a row each (`Console_Action`): charge and fire, aim, jump, move, camera, zoom in and out, menus |
| `U_EmoteButton` › `Button` › `PadHint` | ImageLabel, `Console_Hint` (`Emotes`) | X on the button's bottom right corner, on Console |
| `U_Zoom` | Frame under EMOTES (centre 0.9376, top 0.565), 0.0474 wide, `UIAspectRatioConstraint` 0.6, a column of two buttons (2026-11-26: the owner, "make zoom in and out indicators somewhere") | Through the round, watching on too (Panels) |
| `U_Zoom` › `S_ZoomIn`, `S_ZoomOut` | ImageButtons, copies of the EMOTES tile (its slanted card pictures, aspect 1.2498) with a white + or − (Londrina 48 px, outline 0.06), and a `PadHint` (`Console_Hint`, `ZoomIn` / `ZoomOut`: D-pad up / down) in the top right corner | Zoom one step in or out (`I.MatchCamera.ZoomStep`) |
| `PREFAB \| BarSlot` › `Background` › `S_Selected` | ImageLabel, a copy of `Stroke` in white at ZIndex 5, over `S_Foil` and `S_Gold` (hidden) | The selected slot's outline over a Shiny foil or Golden rim, which cover `Stroke` (LoadoutBar, 2026-11-26) |
| `U_Slots` | Frame (horizontal list) | Holds one `BarSlot` per slot key (7: the Bazooka and loadout slots 1 to 6) |
| `U_Bars` | Frame, bottom left (0.014, 0.968), 0.152 × 0.5, a `UIListLayout` from the bottom | The player's bars, health over stamina (2026-11-24); under them `TouchRoom` (Mobile only, 0.33 of the bars' height for the bigger walk buttons) and `PadRoom` (Console only), room for `U_Touch` and `U_PadControls` |
| `U_Bars` › `U_Health` | Frame, a copy of the stamina bar (its pictures and `UIAspectRatioConstraint` 3.358), `S_Bar` red (235, 75, 65) | Through the turns while the player's snail is in play: `S_Bar`, `S_BarMask` cut at its health share, `S_Text` "Health 165" |
| `U_Bars` › `U_Stamina` | Frame, under the health bar | On the player's turn |
| `U_Stamina` › `S_Bar`, `S_BarMask` | ImageLabels (`Fit`) with a UIGradient each | How far the snail can still walk: the bar and its texture, cut by their gradients at the share times MatchHud's `BAR_FILL` (1: the studio's complete PowerSlider, 2026-11-12, fills its whole width; sized 0.9319 × 0.4312, as the track) |
| `U_Stamina` › `S_Text` | TextLabel, tilted −5° up along the bar and sitting on its top edge (0.29 down, close over the bar; the health and fuel bars' too: the owner, 2026-11-24 and 2026-11-25) | "Stamina · 70%" |
| `U_Stamina` › `U_Fuel` | Frame, hanging over the health bar (Y −1) (hidden until code shows it) | The jetpack's fuel while the snail wears one: the stamina bar's twin (the same frame and pictures), its bar orange, with `S_Bar`, `S_BarMask` and `S_Text` ("Jetpack · 70%", or "Jetpack next turn" while it rests) |
| `U_Fire` | ImageButton (FIRE, the gui maker's painted button, 2026-11-11), bottom middle over the loadout bar (0.5, 0.862), 0.12 wide (0.17 on Mobile, `Utils_PlatformSize`), `UIAspectRatioConstraint` 2.543 | Every device, while the player's aim is locked and the weapon ready: fires it (2026-11-24) |
| `U_Fire` › `U_Retarget` | ImageButton, NEW TARGET: a copy of the lobby's blue LOCAL button (MatchBoard's `S_Local`, its pictures and ink outline, no icon), left of FIRE and sized with it (0.86 of it), hidden | While a homing missile's target is placed: lets go of it, so the next press places another (2026-11-25) |
| `U_Fire` › `PadHint` | ImageLabel, `Console_Hint` (`Fire`), a copy of the emote button's X badge | RT on FIRE's top right corner, on Console (2026-11-25: pad players saw no way to shoot) |
| `U_KillFeed` | Cells (no scroll, `Fixed`), kept | Top right, under the team panel: one `FeedLine` per knockout |
| `U_EmoteWheel` | Frame, hidden, the middle of the screen (0.44 of it, square), ZIndex 20 | The emote wheel; its `Rotation` spins it in |
| `U_EmoteWheel` › `S_Pop` | UIScale | Grows it in as it opens |
| `U_EmoteWheel` › `S_Slices` | Frame | Holds one `WheelSlice` per emote, round the ring from the top |
| `U_EmoteWheel` › `S_Name`, `S_Sub` | TextLabel (in the `Middle` disc: fill 25, 25, 35, a dark outer and a grey 130 inner line) | The pointed emote's name (with nothing pointed at, the one a quick tap plays); under it, for one not owned yet, "Unlocks at level 10" or "Get it in the emote shop" |
| `U_EmoteWheel` › `S_Hit` | ImageButton, see-through, over the wheel | Takes every press on the wheel, and the pad's selection while the button opened it |
| `U_Drop` | Frame, top middle (where `U_Turn`'s timer stands), hidden | The drop phase's timer: `U_Turn`'s timer plate (`Timer`, its pictures) with "Pick where to land" (`Title`, `TextCase_Upper`) under it |
| `U_Drop` › `S_Timer` | TextLabel | The time left ("0:15"), red in the last seconds |
| `U_KnockedOut` | Frame, hidden (rebuilt 2026-11-24 from the studio's KnockedOut: the dialog look, 0.4 × 0.5, aspect 1.3; Mobile 0.86 × 0.9) | `S_Pop` (UIScale), the dark panel (`Bg_Bottom`), KNOCKED OUT! (`S_Title`, white to red), `S_Cause`; `S_Killer` (`S_KillerAvatar` with `S_KillerStroke`, `S_KillerName`, `S_Weapon`); the result slot (`S_Place` over PLACE, `S_Diamonds` ("+25 diamonds"), `S_Xp`, `S_Pending`), `S_Stats`; the buttons `S_PlayAgain` (gold, A), `S_Spectate` (slate, X) and `S_Leave` (red, LOBBY) with `Console_Hint` badges |
| `U_Waiting` | Box (`Hud`), kept, hidden | "Waiting for players" and `S_Count` |
| `U_TurnCallout` | Frame, hidden, see-through, across the screen (Position 0.5, 0.34; 1 × 0.14 of the screen; ZIndex 10) | The turn banner, shown as each turn starts (the player's own and anyone else's) |
| `U_TurnCallout` › `S_Band` | Frame ((14, 14, 22) at 0.2 transparency, a UIGradient fading its left and right edges) | Opened and closed by its height (`Size` 1 × 0 to 1 × 1) |
| `S_Band` › `S_LineTop`, `S_LineBottom` | Frame (0.045 of the band's height, orange (255, 140, 20), ends faded by a UIGradient) | `BackgroundColor3` = MatchHud's `CALLOUT_ACCENT_COLOR`, or the snail's `Color` |
| `U_TurnCallout` › `S_Content` | Frame, see-through, centred (0.34 × 0.86 of the banner) | Slid in from the left and on to the right (`Position` X) |
| `S_Content` › `S_Pop` | UIScale | Settles from MatchHud's `CALLOUT_START_SCALE` to 1, or to `CALLOUT_OTHER_SCALE` for anyone else's turn |
| `S_Content` › `S_Avatar` | ImageLabel (square, `UICorner` 0.22, `Crop`; the design's player picture in the gui) | The snail's headshot, or `BOT_AVATAR` for a bot |
| `S_Avatar` › `S_AvatarStroke` | UIStroke (`Border`, `ScaledSize` 0.06, orange) | `Color` = the accent, as the lines |
| `S_Content` › `S_Title` | TextLabel (`TextCase_Upper`, the timer's font Heavy Italic, white under its gradient, a dark (20, 14, 10) `ScaledSize` UIStroke) | "Your turn!" or "Bax's turn" |
| `S_Title` › `S_TitleGradient` | UIGradient (top to bottom) | `Color` = MatchHud's `CALLOUT_MINE_GRADIENT` (gold) or `CALLOUT_OTHER_GRADIENT` (white); in the sudden-death callout white over the liquid's colour, turned and slid (Looks) |
| `S_Content` › `S_Sub` | TextLabel (`TextCase_Upper`, Bold Italic, (225, 225, 235), the same dark UIStroke) | "Aim and fire!", "You're next!" or "You play in 3 turns" |
| `U_Tension` | Frame, hidden, the whole screen (0.99 × 0.985) | Shown in the last `TICK_SOUND_FROM` seconds of the player's own turn |
| `U_Tension` › `S_Glow` | UIStroke (red (240, 60, 30), 14 px, `Border`, a UIGradient clearer at the middle of each side) | Its `Transparency` pulses (1 in the gui) |

## Prefabs

| Prefab | Parent | Elements |
| --- | --- | --- |
| `PREFAB \| BarSlot` | `U_Slots` | An ImageButton, not `Selectable` (LB / RB step the slots; the D-pad and sticks never select them, 2026-11-26), laid out in three bands as the loadout's cards (2026-11-25, the owner: "a bunch of text"): `S_Icon` (the middle band: centred, 0.54 of the card tall, `ScaleType` Fit so a picture keeps its shape), `S_Key` ("1"–"7", Desktop only, the control hints' key cap top left), `S_Uses` (the uses left this match, "5 left", in a dark pill top right, hidden while it cools down or when unlimited: the owner, 2026-11-25, as "x5" read unclear), `S_Name` (along the bottom, kept while it cools down), `S_Turns` (the cooldown's turns left in a round dark badge ringed in the charge's blue, in the top right corner where the uses pill shows, so the greyed icon stays seen in the middle, hidden), `S_TurnsLabel` (no longer shown: kept for old code), `S_ReadyFlash` (the card's fill picture in white, see-through until a cooldown ends), `S_Lock` (the Loadout card's lock picture over an item used up for the match, hidden), `S_Plus` (an empty slot's "+", hidden), `S_UseHint` (Y on Console, a `Console_Hint` with `Console_Action` `UseUtility`, hidden by `Console_HintHidden` until the pad's cursor rests on the slot), `Background` › `S_Charge` (the card's fill picture in blue (110, 175, 255), cut from the bottom by a `UIGradient` at the share of the cooldown waited, its top edge brighter, hidden: 2026-11-25), `Background` › `Stroke` (the outline the looks recolour), and `Background` › `S_Foil` and `S_Gold` (the Loadout panel's slot's holo foil and gold rim, the same pictures, hidden: a Shiny or Golden item's, since 2026-11-24) |
| `PREFAB \| TurnEntry` | `U_TurnList` | `S_Name` (with a `UITextSizeConstraint`), `S_Badges` (Frame: PlayerBadges clones its hidden `PREFAB \| Badge`, an ImageLabel with an `S_Glyph` TextLabel for Roblox's verified and Premium glyphs, once per badge and lays them out after the name, whose `UITextSizeConstraint` it lowers so the name stays on one line), `Background` › `Main`, `S_Avatar` (square, under the outlines), `Stroke`, `S_Mask` (the current look's shine) |
| `PREFAB \| Team` | `U_TeamsLeft` (clones go on either side) | `S_Players` (a horizontal list holding the nested `PREFAB \| TeamPlayer`), `S_Name` (`TextCase_Upper`) |
| `PREFAB \| TeamPlayer` | nested in `Team` › `S_Players`, hidden | `Background` › `Main`, `S_Avatar` (square, under the outlines), `Stroke2`, `Stroke` |
| `PREFAB \| FeedLine` | `U_KillFeed` | A Label: "Bax knocked out Ninja with the Black hole grenade", names in team colours (rich text) |
| `PREFAB \| WheelSlice` | `U_EmoteWheel` (code puts clones in `S_Slices`) | A see-through Frame the wheel's size: `S_Grow` (UIScale), `S_Sector` (CanvasGroup) › `S_CutEnd` (its UIGradient) and `S_Wedge` (the disc, 0.92 of the wheel) › `S_CutStart` (UIGradient), `S_Icon` (the emote's picture) › `S_Lock` (the Loadout card's lock) and `S_Level` ("Lv 10"), both hidden. Its `Look_Color`, `Look_Transparency`, `Look_LockedIconColor` and `Look_LockedIconTransparency` attributes are its rest look |
| `PREFAB \| AimDot` | `U_Aim` | A round white Frame (`UICorner` 0.5) with a dark `UIStroke`: one of the aim preview's dots along the start of the path. MatchHud's Aim clones `PREVIEW_DOTS` of them into `U_Aim` and sizes, places, colours (the power's colour) and fades them (the 24 Nov preview, back 2026-11-25) |

## Driven by

The game's `MatchHud` module: it turns the ScreenGui on while the player is in a match and shows each block in its phase, fills the knocked-out screen (its `KnockedOut` handler: the killer or cause, the place, diamonds, XP and stats, PLAY AGAIN), plays the turn callout as turns start (in local play holding it while a turn waits for its player to take the controller) and pulses `U_Tension` in the player's last seconds (its `Turn` handler). The Cosmetics module builds the emote wheel's slices and opens it (held T or X, or `U_EmoteButton`); Panels runs the drop's timer.

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
| `S_Wheel` (Toggle) | Opens the emote wheel: 9 slices, the first lit in blue, the last two not owned yet |

## Integration

### Setup

Export it with the Gui tool (**Export to StarterGui**): a ScreenGui named `MatchHud`, `Enabled` off. Its module turns it on while the player is in a match. The kept blocks' `S_ScreenScale` UIScales are set by the game's ScreenScale module (`MatchHud` is in its `GUIS` list), laid out for a 1920 × 1080 screen, times the device scale their `Utils_PlatformScale` tag keeps; the design's frames need nothing. Capitals texts carry `TextCase_Upper`, so what code writes there shows in capitals. Last exported to StarterGui on 2026-11-26 (`UmeGui.Export`: the zoom buttons, the slots' `S_Selected` and `Selectable` off, the export before it in `ServerStorage.!dump.MatchHud_old_2026-11-26_zoom`; on 2026-11-25 FIRE's RT badge, the export before it in `ServerStorage.!dump.MatchHud_old_2026-11-25_console`; before that the smaller readout, after the screen-edge exports; before that the slot's picture fitted, centred and bigger, the export before it in `ServerStorage.!dump.MatchHud_before_icon_fit_2026-11-25`; before that the cooldown badge in the corner and the faded cooling picture, the export before it in `ServerStorage.!dump.MatchHud_before_cooldown_corner_2026-11-25`; before that the power wedge `S_PowerWedge` in place of `PREFAB | PowerDot`, and white `PREFAB | AimDot`s, the export before it in `ServerStorage.!dump.MatchHud_before_wedge_2026-11-25`; first the bar slot's cooldown look, `S_Charge`, `S_TurnsLabel` and `S_ReadyFlash`, the homing missile's own target mark with `S_TargetBrackets`, and `PREFAB | PowerDot` back for other snails' turns; the export before is `ServerStorage.!dump.MatchHud_before_2026-11-25`); before that 2026-11-24 ( the bar slot's `S_Foil` and `S_Gold` last; with the rebuilt `U_KnockedOut`, then the drag, lock and FIRE aim: `U_Fire` over the loadout bar, `U_Power` gone, `U_Bars`, `S_PowerRing`, `S_Readout`, `PREFAB | AimDot`, and the same day the subtler aim: no `PREFAB | PowerDot` cone, no icon under FIRE's text, a fainter ring, the bars' texts tilted −5°; before that 2026-11-15, with `U_TouchJump` and the bar slot's `S_Lock`); the exports before are kept in `ServerStorage.!dump` as `MatchHud_before_2026-11-10`, `MatchHud_before_2026-11-13` and `MatchHud_before_2026-11-15`.

### Input

| Action | Mouse and keyboard | Touch | Gamepad | Bound in |
| --- | --- | --- | --- | --- |
| Pick a loadout slot | 1–7 or click | Tap | LB / RB (a utility only gets the cursor), Y uses it | MatchHud (`MatchHud_Slots`; the pad through `I.Console`: `WeaponPrevious`, `WeaponNext`, `UseUtility`) |
| Aim | Press and drag with the left button: the crosshair goes under the pointer; farther from the snail is more power | Press and drag a finger the same way (two fingers pan the camera) | Right stick | MatchHud (Aim; `STICK_*`) |
| Lock the aim | Let go | Lift the finger | Let go of the stick | MatchHud (Aim; kept for the snail's next turn) |
| Fire | `U_Fire`, F or Enter | `U_Fire` | RT | MatchHud (Aim; `FIRE_KEYS`, Console's `Fire`) |
| Clear the aim | Esc, or drag back to the snail | Drag back to the snail | B | MatchHud (Aim; Console's `CancelAim`) |
| Walk, jump | Game controls | `S_Left`, `S_Right`, `S_Jump` | Game controls | MatchHud and SnailControl |
| Emote wheel | Hold T, point with the mouse, let go (a quick tap plays the last emote again); or click EMOTES, then a slice | Tap EMOTES, then tap a slice | Hold X, point with the left stick, let go (a quick tap plays the last again); or select EMOTES with View and A, then point and A (B closes it) | Cosmetics (T bound with ContextActionService while the button shows; X read through `I.Console.IsAction("Emotes")`; the button's `I.Interact.OnPress`; `I.Console.Focus` when the button opened it) |
| Zoom | Mouse wheel | Pinch | D-pad up / down | MatchCamera (`I.Console`: `ZoomIn`, `ZoomOut`) |
| HUD and top bar buttons | Click | Tap | View starts the selection, A presses | Console (`Navigate`) |
| Play again / Spectate / Lobby | Click | Tap | A / X / B | `S_PlayAgain` (MatchHud's `KnockedOut`, `I.Interact.OnPress`), `S_Spectate`, `S_Leave` tags (`Utils_ButtonKey`) |

### Looks

| State | Element | Value |
| --- | --- | --- |
| Hover, press | Slots, EMOTES, FIRE, move and jump buttons | `Utils_ButtonScale` (`Bouncy`, hover ×1.04, press ×0.92) with `Button_Hover` and `Button_Click` |
| Emote wheel opening | `U_EmoteWheel`, `S_Pop` | `Rotation` from Cosmetics' `WHEEL_OPEN_SPIN` (-40) to 0 and `Scale` from `WHEEL_OPEN_SCALE` (0.6) to 1 (`WHEEL_OPEN_TWEENINFO`, 0.28 s back out), with `Emote_WheelOpen` |
| Slice pointed at | `WheelSlice` › `S_Wedge`, `S_Grow` | `BackgroundColor3` = the player's match `Color` (their team's), transparency 0, `Scale` `WHEEL_HOVER_SCALE` (1.06, `WHEEL_HOVER_TWEENINFO` 0.12 s), the slice's `ZIndex` 22 over its neighbours, with `Emote_WheelHover`; at rest `Look_Color` (34, 34, 46) at `Look_Transparency` (0.08), scale 1, `ZIndex` 21 |
| Emote not owned | `WheelSlice` › `S_Icon`, `S_Lock`, `S_Level` | `ImageColor3` `Look_LockedIconColor` (120, 120, 130) at `Look_LockedIconTransparency` (0.35), the lock shown, "Lv 10" shown above level 1 |
| Drop timer, last seconds | `U_Drop` › `S_Timer` | From MatchHud's `DROP_WARN_FROM` (3) seconds left the seconds turn `TIMER_DANGER_COLOR` (255, 70, 50), with `Turn_Tick` each second; white before |
| Selected item | `BarSlot` › `Background` › `Stroke` | `ImageColor3` = `Look_SelectedStrokeColor` (white); others `Look_StrokeColor` (grey) |
| Empty slot | `BarSlot` | `S_Plus` shown, the rest hidden, `Stroke` = `Look_EmptyStrokeColor`, not interactable |
| Cooling down | `BarSlot` › `S_Icon` (and a model's `S_Model`) | `ImageColor3` = `Look_CooldownIconColor` (150, 150, 160) and `ImageTransparency` = `Look_CooldownIconTransparency` (0.45): greyed out, still readable; `S_Turns` shown in the top right corner |
| Used up for the match | `BarSlot` › `S_Icon` (and a model's `S_Model`) | `ImageColor3` = `Look_CooldownIconColor`, `S_Lock` shown (the Jetpack only once its fuel is gone; until then `S_Uses` shows the fuel left, "75%") |
| Turn callout, the player's own | `S_TitleGradient`; `S_LineTop`, `S_LineBottom`, `S_AvatarStroke` | Gold `CALLOUT_MINE_GRADIENT`; orange `CALLOUT_ACCENT_COLOR` |
| Turn callout, anyone else's | `S_TitleGradient`; `S_LineTop`, `S_LineBottom`, `S_AvatarStroke`; `S_Pop` | White `CALLOUT_OTHER_GRADIENT`; the snail's `Color`; at `CALLOUT_OTHER_SCALE` |
| Turn callout, sudden death | `S_Avatar`; `S_Title`, `S_Sub`; `S_TitleGradient`; `S_LineTop`, `S_LineBottom` | Avatar hidden; "Water is rising..." or "Lava is rising..." over "Sudden death!"; the gradient white to 0.5, the liquid's colour from 0.52 (MatchHud's `SUDDEN_DEATH_LIQUIDS`), `Rotation` 90, its `Offset` tweened from `SUDDEN_DEATH_FILL_FROM` to `SUDDEN_DEATH_FILL_TO` (1.6 s sine out); the lines in the liquid's colour; held `SUDDEN_DEATH_HOLD` (2.4 s). The next turn's callout shows the avatar and puts the gradient's `Rotation` and `Offset` back |
| Current snail | `TurnEntry` › `Background` | `Main` takes `Look_CurrentMain` and `Look_CurrentMainColor` (orange), `Stroke` `Look_CurrentStrokeColor`, `S_Mask` shown; others `Look_Main`, `Look_MainColor` and their team colour on `Stroke` |
| Side | `TeamPlayer` › `Background` | `Main`, `Stroke2`, `Stroke` take `Look_Left*` or `Look_Right*` (mirrored slants); `Stroke` tinted the team colour |
| Aiming snail | `S_Crosshair` › `S_RingLine` (`Color`), `S_ArmA`, `S_ArmB` (`BackgroundColor3`) | The snail's `Color`: its team's, or its own in a free-for-all |
| Power | `S_PowerWedge` › `S_WedgeTop`, `S_WedgeBottom` (`BackgroundColor3`) | The power's colour: yellow (255, 226, 92) at none through orange (255, 148, 38) to red (240, 62, 46) at full |
| Bar fill | `U_Health`, `U_Stamina` and `U_Fuel` › `S_Bar` | Their `UIGradient.Transparency` is opaque up to the share times `BAR_FILL`, clear after it |
| Rarity, hover (kept blocks) | Item cards and buttons from the theme | The theme's `Item` and `Button` looks |
