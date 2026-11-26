# MatchHud

The match screen and its input, on the `MatchHud` gui (the studio's HUD design). It shows the teams in the top
corners, the timer, whose turn it is and the wind at the top, the turn order on the left, the player's health and stamina
at the bottom left (`U_Bars`), the kill feed, the loadout bar (the Bazooka and the player's items, with icons, uses
and cooldowns), FIRE over it, touch move and jump buttons, the waiting, drop and knocked-out blocks, and the Results screen.
**Knocked out** (2026-11-24, the studio's `KnockedOut` design, `U_KnockedOut`): when the player's own snail goes out the
screen pops in with who did it (their picture framed in their team colour, their name and the weapon's icon, "with the
Bazooka") or how it happened ("You fell into the water", taking the killer card's place), the player's place, diamonds and
XP once their team is out (MatchRewards' `MatchRewards_Earned`; "Waiting for the match to end..." until then) with their
damage, knockouts and best shot, and three buttons: PLAY AGAIN (public and solo matches: Match's `Match_PlayAgain`),
SPECTATE (closes it to watch; the pad's X, Console's `Spectate`) and LOBBY (Leave). A turn callout waits while it shows.
Aiming is drag, lock, FIRE (2026-11-24, replacing hold to charge), Ring: point since 2026-11-25 (the owner's pick,
replacing the trackpad drag): on the player's turn a press on the arena (the mouse button, a finger) puts the
crosshair under it, and a drag moves it with the pointer: its way from the snail is
the angle, its distance past the power's start the power, up to the power ring (`S_PowerRing`, full power). Letting
go locks the aim; **FIRE** (`U_Fire`, over the weapon bar on every device, shown while the aim is locked and the
weapon ready), `FIRE_KEYS` (F, Enter) or the pad's RT shoot it. Within `AIM_DEADZONE` of no power, or
Esc and the pad's `CancelAim` (B), clear it. The right stick moves the crosshair the same way (`STICK_*`). Each snail
keeps its aim into its next turn (by participant id); its first starts at `AIM_START_POWER`, `AIM_START_ANGLE` toward
its nearest enemy. Guns and swings use the angle only (the readout shows "41°"); a weapon placed at the feet fires on
FIRE with no aim; a homing missile's first press locks its target (a finger drags it until it lifts; on a pad the right
stick moves its open mark from the nearest enemy, `STICK_TARGET_*`, and FIRE or RT locks it), then its launch
aims like an arced weapon's, and **New target** (`U_Retarget`, the lobby's blue LOCAL button copied, left of FIRE
and inside it, or Esc / the pad's B) lets go of the target for another. An arced aim (and a homing missile's launch) shows the start of its path from the snail: 9 dots in the power's
colour over a fifth of a full-power flight, no wind (`PREVIEW_*`), as the testers had them on 2026-11-24, brought back
on 2026-11-25 after the day's halving, thinning, removal and a try with dots past the crosshair. The tutorial shows the same dots (2026-11-25: so a new player isn't taught a line the game doesn't have). With an
admin's aimbot on (Combat's `aimbot` command), the whole prediction line shows instead, and Combat marks the snails a shot can hit; the aim itself stays the player's (no lock-on).
The aim is drawn on the gui's aim layer, `U_Aim`, under the rest of the HUD, in pixels over the snail every frame: the
crosshair, `S_Crosshair` (a ring with an X, outlined), `CROSSHAIR_SIZE` across, spinning, in the power's colour
(`POWER_COLORS`, as the wedge, since 2026-11-25), `POWER_START` plus `POWER_GAP` and half its size out along the aim
at no power and `POWER_LENGTH` further at full, on the faint power ring, with the power and angle over it
(`S_Readout`, "62% · 41°"). The power shows as a wedge, ShellShock Live's way (the owner, 2026-11-25), on the player's
own aim and every other snail's: `S_PowerWedge`, a soft triangle in the power's colour (`POWER_COLORS`, yellow at
little, red at full) from `POWER_START`, its point at the snail's end, to the crosshair's ring, its far end
`POWER_WEDGE_SPREAD` of its length across (two halves, each cut along its diagonal by its gradient's hard step, turned
to the half's size every frame). A homing missile's placed target wears a mark of its own (`S_TargetMark`: a red
ring and dot with lock-on brackets, which turn and close in as it's placed). Lengths are units, a stud at MatchCamera's `DISTANCE`, growing and shrinking with the zoom
like the map, within `AIM_ZOOM_SCALE` (0.75 to 1.4 times their size at the starting zoom); zoomed in, it also starts
past the snail's grown ball. The drag for full power stays the same share of the screen at any zoom. The held weapon
turns with the aim on this screen at once (Combat's `SetAim`). A turn that runs out never fires. Every player sees the active snail's crosshair and power. Number keys 1 to 6 pick a slot; on a pad LB and RB step through the
slots (a weapon is picked at once; a utility only gets the pad's cursor, its slot outlined with a Y hint, and Y puts
it in the snail's hands, for RT to use), and X held opens the emote wheel (the Cosmetics module's, T on a keyboard). It adds **Leave game** to the top bar,
an icon (`LEAVE_ICON`) after TopBar_Controller's music button. The HUD and that button show while the player is in the
match (the `InMatch` Player attribute); on the Studio map, going back to the lobby hides them and closes Results.
The wind plate shows only in a match with wind (Match's `WindOn`: a custom lobby or local play that turned it on, the
owner, 2026-11-24).

**The tutorial match** (Match's `Kind = "Tutorial"`, 2026-11-24) is quieter, since the Tutorial module's guide says
what to do: no turn timer plate and no "You're next" line (`Turn`), no timer plate or title on the drop (`Panels`), no
Leave game (END TUTORIAL takes its place), no control hints, and no Results screen (the Tutorial module's win card
shows instead). Its arced shots show the whole prediction line. The guide reads whether the player has aimed this turn
(`I.MatchHud.HasAimedThisTurn`).

Each turn is announced on one banner, `U_TurnCallout`: a dark band across the screen with the snail's avatar (its
headshot, or `BOT_AVATAR` (the default snail's headshot) for a bot, through `Teams.SetAvatar`), whose turn it is and a line under it. On the
player's own turn it reads "Your turn!" in `CALLOUT_MINE_GRADIENT` (gold) over `CALLOUT_ACCENT_COLOR` (orange) lines
and avatar frame, "Aim and fire!" under it, with `Turn_Yours`, `Turn_Whoosh` and the `Match_YourTurn` haptic preset
(two taps, `src/global_data/Haptic/Preset.lua`). On anyone else's it reads "Bax's turn" in `CALLOUT_OTHER_GRADIENT`
(white) over lines and an avatar frame in that snail's `Color`, "You're next!" or "You play in 3 turns" under it, at
`CALLOUT_OTHER_SCALE`, with `Turn_Start`. The band opens (`CALLOUT_BAND_TWEENINFO`) as the content slides
`CALLOUT_SLIDE` of the screen in and settles from `CALLOUT_START_SCALE` times its size (`CALLOUT_IN_TWEENINFO`), holds
`CALLOUT_HOLD` seconds, then the content slides on as the band closes (`CALLOUT_OUT_TWEENINFO`); a newer turn's banner
takes over. When the player is next, `Turn_Next` plays and the "You're next!" line flashes `NEXT_FLASH_COLOR`. In local
play the banner names each local snail ("Player 2's turn") in its own colour, and while that turn waits for its player
to take the controller (Match's `HandOff`, 2026-11-17) it holds with `HANDOFF_TEXTS` under the name and `Turn_Next`,
the turn's timer hidden; once they press, the line becomes "Aim and fire!", their turn's call plays and the banner goes
as any turn's does. When sudden death starts (Match's `SuddenDeath`), once the turn's own callout is gone, the
banner announces the rising liquid (Match's `SeaKind`, from `SUDDEN_DEATH_LIQUIDS`): "Water is rising..." or "Lava is
rising..." (`SUDDEN_DEATH_TITLE`) over "Sudden death!", no avatar, its lines in the liquid's colour and its title
filling with it from the bottom, held `SUDDEN_DEATH_HOLD` seconds (2026-11-16); every sudden-death turn's line then
adds "The water rises" (`SUDDEN_DEATH_REMINDER`).
The last seconds of the player's own turn tighten: the timer turns `TIMER_WARN_COLOR` from `TIMER_WARN_FROM` seconds
left and `TIMER_DANGER_COLOR` from `TICK_SOUND_FROM`, when `Turn_Tick` plays each second, each half second from
`TICK_FAST_FROM`, its pitch rising from 1 to 1.3, and `U_Tension`, a red band along the screen's sides, pulses
`TENSION_PULSE_RATE` times a second, up to twice as fast at the end.

Devices: the move and jump buttons show only on touch screens (`U_Touch`'s and `U_TouchJump`'s `Utils_HideOnPlatform`), on the
player's turn, with room left for them under the bars (`U_Bars`' `TouchRoom`; `PadRoom` for the pad's strip); FIRE
shows on every device, bigger on Mobile (`Utils_PlatformSize`); the slot
key numbers only on Desktop; the gamepad hints only on Console (`Console_Hint`, drawn by the Console module: LB and RB
at the bar's ends, Y on the utility the pad's cursor rests on, X on the emote button and the `U_PadControls` strip of
the match's buttons). Every pad button is the Console module's scheme (`I.Console`).

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/MatchHud` |
| Runs on | Client · Match map, Studio map |
| Exposes | `I.MatchHud` (client) |
| Uses | `I.Match`, `I.Snails`, `I.SnailControl`, `I.G_Arsenal`, `I.G_Combat`, `I.Replicator`, `I.TopBar`, `I.PlayerSettings`, `I.WidgetManager`, `I.Haptic`, `I.Sound`, `I.Interact`, `I.Platform`, `I.Console`, `I.MatchCamera` (Panels: the zoom buttons), `I.PlayerBadges`, `I.G_Progression` (Results: a level's prestige frame), `I.DoEvery`, `ContextActionService` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Turns the gui on while the player is in a match (and the `HIDDEN_IN_MATCH` guis off), lays it over the whole screen out to a phone's edges (`ScreenInsets` `None`; `DeviceSafeInsets` on Console) with its top padded below Roblox's top bar on Mobile (the gui's `U_Inset`, `TopbarInset`'s height), following `Platform_Changed` and the top bar, and starts the handlers; assigns `I.MatchHud` |
| `Scripts/Client/Turn.lua` | Banner ("Your turn!" in the gui's colour, or on other snails' turns "Bax's turn" in that snail's `Color`, from its `DisplayName`), the wait under it on other snails' turns ("You're next!" / "You play in N turns", from Match's `TurnOrder`; hidden once the player's snail is out, and in the tutorial), timer ("0:30"; its plate hidden in the tutorial; once the shot is away it stays on the time that was left, in `TIMER_SPENT_COLOR`, until the turn ends), wind (`&gt;` / `&lt;` and "+3" / "-3"; its plate only while Match's `WindOn`), the turn list (the active snail in the current look, then the next ones from `TurnOrder`, up to `TURN_LIST_ENTRIES`, avatar and name, the player's badges after it (`I.PlayerBadges.Show`), outlined in their team colour), stamina (`U_Stamina`: its bar cut at the share by its `UIGradient`, `STAMINA_FORMAT`; shown on the player's turn and, after a throw, while they still move), and over it the jetpack's fuel while the snail wears one (`U_Fuel`, cut at `I.SnailControl.GetFuelShare()`, `FUEL_FORMAT`, or `FUEL_REST_TEXT` while the jetpack rests); the turn callout (`_onTurnStarted` fills `U_TurnCallout`'s avatar, title, line (`_getCalloutLine`), gradient and accent colours; `_popCallout(scale, hold?)` opens the band (`_openCallout`) and closes it after the hold (`_closeCallout`), a newer one taking over from an older one; in local play a turn waiting for its player holds the callout open until Match's `HandOff` clears, `_onHandOff`, and the turn panel stays hidden meanwhile) and the "You're next!" flash; the sudden-death callout (`_onSuddenDeath`, after the turn's own, the liquid from `_getSuddenDeathLiquid`, its title gradient turned and tweened, then put back by the next turn's callout); the last seconds' timer colours, ticks and `U_Tension` pulse (`_tick`); sounds: `Turn_Yours` and `Turn_Whoosh` when the player's turn starts, `Turn_Start` on others', `Turn_Next` (volume 0.5) when the player is next, `Turn_Tick` in the player's last `TICK_SOUND_FROM` seconds, `Turn_TimeUp` when the player's turn runs out without a shot, `Match_SuddenDeath` when sudden death starts, `Match_WaterRise` as each sudden-death turn starts (the sea rises) |
| `Scripts/Client/Teams.lua` | The team panels (`U_TeamsLeft`, `U_TeamsRight`), from the drop on: the participants grouped by `Team`, the player's own first on the left, the others in turn right and left; each team's avatars (headshots for players, `BOT_AVATAR` for bots; `OUT_AVATAR_COLOR` once out) outlined in its colour, the side's own pictures (`Look_Left*` / `Look_Right*`), and its name ("Your team", "Red team" from Match's `TEAMS`; in a free-for-all "You" or the snail's name). A side with more players than fit shrinks them (`TEAM_PLAYER_WIDTH`). `SetAvatar` is shared with the turn list, the turn callout and the results |
| `Scripts/Client/Panels.lua` | The zoom buttons (`U_Zoom`: shown through the round, watching on too, but under the knocked-out panel; `S_ZoomIn` and `S_ZoomOut` press `I.MatchCamera.ZoomStep`, 2026-11-26). The waiting (hidden while a public match's own waiting room shows, Match's `RoomEndsAt`), drop and knocked-out blocks; which bars show. The drop's timer (2026-11-17) is the turn timer's plate counting the drop's seconds down ("0:15", from Match's `DropEndsAt`), and from `DROP_WARN_FROM` seconds left its seconds turn `TIMER_DANGER_COLOR` and `Turn_Tick` plays each second. The tutorial's drop hides the plate and the drop's title |
| `Scripts/Client/LoadoutBar.lua` | The loadout bar and slot keys: one `BarSlot` per item (icon, name, uses left ("2 left"), key, and a Shiny item's holo foil or a Golden one's gold rim from Combat's `Variant_<item>`: `S_Foil`, `S_Gold`, 2026-11-24), only the items the player has (no empty "+" slots since 2026-11-24), the pad's LB / RB hints (`S_PrevHint`, `S_NextHint`) placed right outside the first and last slot as it builds them (2026-11-25), the selected one's white outline drawn over a Shiny foil or Golden rim too (`S_Selected`, 2026-11-26), the selected one in the slot's `Look_SelectedStrokeColor`, a cooling one greyed out (`Look_CooldownIconColor`, `Look_CooldownIconTransparency`) with its turns left in a round badge in the top right corner, the uses pill's place (the pill hidden, its name kept), never more than the item's `Cooldown` (Combat's count is one higher right after a shot), its card filling in blue from the bottom with the share of the cooldown already waited (`S_Charge`) and flashing white as it ends (`S_ReadyFlash`, 2026-11-25: the owner, "design a good cooldown gui"), one used up for the match darkened the same way under `S_Lock` (the Jetpack only once its fuel is gone: until then its uses show the fuel left, "75%", and a turn's cooldown while it rests after flying), and one with no uses left or cooling down can't be fired (`IsReady`, which Aim checks). A utility picked goes in the snail's hands like a weapon (`Combat_Select`), and one in `USE_ON_SELECT` (the Jetpack) is used at once (`Select` calls `UseHeld`); `UseHeld` uses it (`Combat_UseUtility`) and hands back the last weapon held, or the Bazooka when that one isn't ready. The pad's LB and RB (Console's `WeaponPrevious`, `WeaponNext`) step through the slots, resting on a utility (outlined, its `S_UseHint` shown) until Y (`UseUtility`) puts it in the snail's hands. A weapon with no icon picture shows its 3D model in its icon instead (`I.G_Arsenal.GetModel`, in a ViewportFrame `S_Model`) |
| `Scripts/Client/Aim.lua` | With a utility in the snail's hands, no aim: any press on the screen (a finger's too) uses it (`LoadoutBar.UseHeld`). The drag (`_startDrag`, `_drag`, `_endDrag`: the crosshair moved like a trackpad, `_setFromOffset` turning its offset into the angle and power), the pad's stick (`_aimWithStick`), the aims kept per snail (`_remember`, restored by `_onMyTurn`, the first one from `_getEnemySide`), the ring, crosshair and readout (`_draw`, `_drawReadout`), the preview's dots from the snail (`_drawPreview`), firing (`U_Fire`, `FIRE_KEYS`, RT: `_fire`, with the `Combat_Fire` haptic tick; it ends the player's snail's emote on this screen at once, `I.SnailRig.StopEmote`), homing targets (`_drawTarget` until one is placed, then `_drawTargetMark` on it; the first press places it, a finger drags it, a pad's stick picks it, `_pickWithStick`, and FIRE or RT locks it; `U_Retarget`, Esc or B clears it: `_clearTarget`), the stick's push shared by aiming and picking (`_getStickPush`), detonating; another snail's crosshair and power (a player's or a bot's) while it aims. For a player with the `Aimbot` attribute (Combat's `aimbot` command), an arced weapon's prediction line (`PREDICTION_*`: gold neon dots along the path at the power aimed, or faded at the power last fired, wind and all, to the first terrain or snail, in `Workspace.Ume.Combat`) |
| `Scripts/Client/KnockedOut.lua` | The knocked-out screen's content (Panels shows and hides it): the killer card or the cause (`_onKnockedOut`, from `Match_KnockedOut`), the place, diamonds ("+N diamonds", `S_Diamonds`), XP and stats (`_onEarned`, from `MatchRewards_Earned`), the pop in (`KO_POP_*`, taking down a turn callout still up), PLAY AGAIN ("Joining..." once sent), cleared on each match's `Waiting` and `Drop` |
| `Scripts/Client/BattleIntro.lua` | The round's intro (stretched over the whole device by `_coverScreen`, its dark edges and flash `INTRO_COVER_BLEED` past every edge; GET READY as the snails drop in, the slam with `Match_BattleBegins` and a camera shake once they've landed), only for a player in the match (`InMatch`); `Turn` and `Panels` likewise play their turn and drop sounds only then, since on the Studio map a match goes on beside the lobby (2026-11-24) |
| `Scripts/Client/KillFeed.lua` | Knockout lines; a line too long for the feed at its design size (`TextService:GetTextBoundsAsync`) gets two lines' height instead of shrinking |
| `Scripts/Client/TouchControls.lua` | Walk buttons (`U_Touch`, bottom left) and the jump button (`U_TouchJump`, bottom right) on touch screens, on the player's turn; the pad's controls strip (`U_PadControls`, Console only) then too |
| `Scripts/Client/Results.lua` | The Results screen (the studio's MatchOver: each card's place in its medal colour from the prefab's `Look_<Place>*` attributes, name with the player's badges after it, `I.PlayerBadges.Show`, and username), rematch votes; `Match_Win` for first place, `Match_Lose` otherwise. The level bar under the diamonds line ("+N diamonds", `S_Diamonds`; 2026-11-17): from MatchRewards' `XpBefore` to `XpAfter`, after `RESULTS_XP_DELAY` each of its `XpLines` (one line of `Xp` when there are none) counts the XP total up with `Xp_Line` and fills the bar with `Xp_Tick` ticks climbing in pitch, each level reached plays `Level_Up`, pops the diamond in the new level's prestige frame (`I.G_Progression.ApplyFrame`) and shows the level-up line; a level between the two costs the share of the way from `XpBefore.For` to `XpAfter.For` (the curve rises by the same step each level; the client never gets it). Results without `XpBefore` and `XpAfter` (a server from before) hide the bar and show the XP and level-up line at once. It never opens in the tutorial match |
| `Scripts/Client/Hints.lua` | The control hints (the `ControlHints` gui, 2026-11-17): on while the player is in the match's `Waiting` or `Drop` phase, in their first `HINTS_MATCHES` matches (the `MatchesPlayed` statistic in their Replicator `Statistic` folder; off until it's known, and for good once it's reached) and never in the tutorial match; each device sees its own list by itself (`Utils_HideOnPlatform`), and the tip over the list fades to the next of `HINT_TIPS` every `HINT_TIP_SECONDS` |
| `Scripts/Client/TopBar.lua` | The Leave and Music top bar buttons; Leave game hides in the tutorial match, where the Tutorial module's END TUTORIAL takes its place |
| `Settings.lua` | `MatchHud_Settings` |
| `_meta/_types.lua` | `MatchHud_SuddenDeathLiquid`, a `SUDDEN_DEATH_LIQUIDS` row (`Name`, `Color`) |

## API

### Client: `I.MatchHud`

| Function | Returns | What it does |
| --- | --- | --- |
| `HasAimedThisTurn()` | `boolean` | Whether the player has aimed on their turn now (let go of a drag, or moved the right stick); false again as each of their turns starts or ends. The tutorial's guide shows "Drag to aim" until it's true, then points at FIRE |

## Network

No remotes of its own. It sends Combat's `Combat_Select`, `Combat_UseUtility`, `Combat_Aim` (unreliable, 10 per
second), `Combat_Fire` and `Combat_Detonate`, and Match's `Match_Leave`, `Match_Rematch` and `Match_PlayAgain`; it listens to
`Match_KnockedOut`, `Match_Results` and MatchRewards' `MatchRewards_Earned`.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `GUI_NAME`, `RESULTS_GUI_NAME` | `"MatchHud"`, `"Results"` | The guis |
| `RESULTS_FIT_PLACINGS` | `4` | The Results placing cards that fit across at the design's width; with more players each card narrows to share it |
| `HIDDEN_IN_MATCH` | `{ "Currency" }` | Guis the framework keeps on (`UserInterface_PreventHiding`) that are hidden while the player is in a match; the currency bar sits where the team panel goes |
| `TIMER_WARN_FROM`, `TIMER_WARN_COLOR` | `8`, `(255, 170, 40)` | On the player's own turn the timer turns this orange from this many seconds left |
| `TIMER_SPENT_COLOR` | `(140, 140, 150)` | The timer once the shot is away, held on the time that was left |
| `TICK_SOUND_FROM`, `TIMER_DANGER_COLOR` | `5`, `(255, 70, 50)` | From this many seconds left of the player's own turn the timer turns this red, ticks aloud each second (`Turn_Tick`, pitch rising to 1.3) and `U_Tension` shows |
| `TICK_FAST_FROM` | `3` | From this many seconds left it ticks every half second |
| `TENSION_PULSE_RATE` | `1.5` | `U_Tension`'s pulses a second at first, rising to twice as many at the end |
| `TENSION_SIZE` | `(0.99, 0.985)` | `U_Tension`'s frame as shares of the whole screen (its glow drawn outside it, along the edges); Turn sets it each frame it shows, reaching past the phone's top padding (`U_Inset`) |
| `CALLOUT_START_SCALE`, `CALLOUT_SLIDE`, `CALLOUT_HOLD` | `1.12`, `0.03`, `1` | The turn callout's content settles from this many times its size (its `S_Pop` UIScale), slides this share of the screen in and on, and stays this many seconds |
| `CALLOUT_OTHER_SCALE` | `0.85` | Anyone else's callout's size, a share of the player's own |
| `CALLOUT_BAND_TWEENINFO` | 0.18 s quad out | How the band (`S_Band`) opens |
| `CALLOUT_IN_TWEENINFO`, `CALLOUT_OUT_TWEENINFO` | 0.32 s quint out, 0.22 s quart in | How the content slides in and settles, and how it slides on as the band closes |
| `CALLOUT_ACCENT_COLOR` | `(255, 140, 20)` | The lines and the avatar frame on the player's own turn (anyone else's take their snail's `Color`, and so does every local snail in local play) |
| `CALLOUT_MINE_GRADIENT`, `CALLOUT_OTHER_GRADIENT` | `(255, 232, 110)` to `(255, 140, 20)`; `(255, 255, 255)` to `(200, 215, 235)` | The title's gradient, top to bottom: gold on the player's own turn, white on anyone else's |
| `HANDOFF_TEXTS` | `Desktop`, `Mobile`, `Console` lines | Local play: the line under a local snail's name while its turn waits for the controller, for the device in use ("Pass the controller, then click when ready") |
| `SUDDEN_DEATH_TITLE`, `SUDDEN_DEATH_SUB`, `SUDDEN_DEATH_REMINDER` | `"%s is rising..."`, `"Sudden death!"`, `"The %s rises"` | The sudden-death callout's title (with the liquid's name) and line, and what every sudden-death turn's line adds (the name in lower case) |
| `SUDDEN_DEATH_HOLD` | `2.4` | How long the sudden-death callout stays, in seconds |
| `INTRO_VIGNETTE_DEPTH`, `INTRO_COVER_BLEED` | `(0.26, 0.34)`, `0.08` | How far the round intro's dark edges reach in (shares of the screen's width and height), and how far past every screen edge they and its flash run, solid out there (a share of the width), so no phone shows a light strip at its sides |
| `SUDDEN_DEATH_FILL_FROM`, `SUDDEN_DEATH_FILL_TO`, `SUDDEN_DEATH_FILL_TWEENINFO` | `(0, 0.55)`, `(0, -0.1)`, 1.6 s sine out | The title fills with the liquid's colour from the bottom: its gradient (turned 90°, white over the colour) slides its `Offset` from the first to the second |
| `SUDDEN_DEATH_LIQUIDS` | Water `(63, 166, 255)`, Lava `(255, 140, 20)` | Each liquid's name in the callout and its colour (the lines, the title's fill), by Match's `SeaKind`; water when unknown |
| `NEXT_FLASH_COLOR`, `NEXT_FLASH_TWEENINFO` | `(255, 220, 60)`, 1.2 s quad out | When the player is next, their "You're next!" line flashes this colour and fades back to its own |
| `STAMINA_FORMAT` | `"Stamina · %d%%"` | The stamina bar's text |
| `HEALTH_FORMAT` | `"Health · %d"` | The health bar's text (bottom left, over the stamina bar) |
| `FUEL_FORMAT`, `FUEL_REST_TEXT` | `"Jetpack · %d%%"`, `"Jetpack next turn"` | The jetpack fuel bar's text: its share, or the turn it rests after flying |
| `TURN_LIST_ENTRIES` | `6` | How many snails the turn list shows |
| `TEAM_PLAYER_WIDTH` | `0.235` | A player's share of a team panel's width |
| `OUT_AVATAR_COLOR` | `(70, 70, 70)` | A knocked-out snail's avatar tint in the team panels |
| `BOT_AVATAR` | `rbxassetid://75705415395334` | A bot's avatar in the team panels, the turn list, the turn callout and the results: the default snail's voxel headshot (`art/bots`), uploaded to The Snail Studio group |
| `LEAVE_ICON`, `LEAVE_QUESTION` | | The Leave game button's icon (the repo's `art/topbar` `TopBar_Leave`, uploaded to The Snail Studio group) and its confirmation |
| `SLOT_KEYS` | One … Seven | Keys that pick boxes 1 to 7 (the Bazooka first, then loadout slots 1 to 6); also how many boxes the bar shows |
| `MODEL_FOV`, `MODEL_VIEW_DIRECTION`, `MODEL_PADDING` | `30`, `0.3, 0.25, 1`, `1.15` | A slot's weapon model: the camera's field of view, the direction it looks from (the muzzle points right), and the room around the model's longest side |
| `USE_ON_SELECT` | `{ Jetpack = true }` | Utilities used the moment their box is picked, with no press on the screen (the owner, 2026-11-16) |
| `COOLDOWN_CHARGE_BODY`, `COOLDOWN_CHARGE_EDGE` | `0.5`, `0.05` | A cooling slot's charge: its gradient's see-through in the fill, and the height of the brighter band along its top (a share of the card) |
| `READY_FLASH_TRANSPARENCY`, `READY_FLASH_TWEENINFO` | `0.35`, 0.5 s Quad Out | The white flash over a slot as its cooldown ends: how see-through it starts, and its fade |
| `FEED_LINES`, `FEED_SECONDS` | `4`, `6` | Kill feed length and how long a line stays |
| `AIM_SEND_INTERVAL` | `0.1` | How often the aim is sent to others during the player's turn |
| `FIRE_ANSWER_SECONDS` | `2` | After a shot is sent the aim hides and the held weapon stays on the shot's angle (its sound plays at once on the shooter's screen) until the match moves on; after this long without that (the server refused it), the player may aim again |
| `AIM_SHOW_GRACE`, `AIM_SMOOTHING` | `0.4`, `15` | Another snail's crosshair and power show while its aim keeps arriving (none for this long hides them), eased toward each update |
| `POWER_COLORS` | (255, 226, 92), (255, 148, 38), (240, 62, 46) | The power's colours from none to full (spread evenly): the power wedge wears the one for the power |
| `POWER_START`, `POWER_LENGTH`, `POWER_GAP` | `2.3`, `9.5`, `0.3` | In units (a stud at MatchCamera's `DISTANCE`): from the snail's middle to where the power starts (further zoomed in, past the snail's ball), the power's length at full, the room before the crosshair, which rides the power's end |
| `AIM_ZOOM_SCALE` | `{ 0.75, 1.4 }` | The aim's smallest and biggest size on screen against its size at MatchCamera's `DISTANCE`: between them it grows and shrinks with the zoom (2026-11-24) |
| `CROSSHAIR_SIZE`, `CROSSHAIR_SPIN` | `2.2`, `60` | The crosshair's size in units (the X's reach) and its spin in degrees a second |
| `POWER_WEDGE_SPREAD` | `0.26` | The power wedge's far end across, as a share of its length |
| `TARGET_MARK_SIZE` | `3.6` | A homing missile's target mark, in units |
| `TARGET_LOCK_SCALE`, `TARGET_LOCK_SECONDS` | `1.7`, `0.3` | Its brackets close in from this many times their size over this long as the target is placed |
| `TARGET_MARK_PULSE`, `TARGET_MARK_PULSE_SPEED`, `TARGET_BRACKET_SPIN` | `0.06`, `1.2`, `30` | Then they grow and shrink by this share this many times a second, turning this many degrees a second |
| `BAR_FILL` | `1` | The share of the health, stamina and jetpack bars' picture its fill covers (the rest is its empty end), so a full bar cuts its gradients (the bar's and its texture's, `S_BarMask`) there and the power handle stops there |
| `TARGET_HINTS` | `Pick`, `TouchPick`, `PadPick` | The readout over the snail with a homing missile in hand, before its target is picked (a click, a tap on touch, or on a pad "Move to a target, RT to lock", the Fire button's name filled in) |
| `STICK_TARGET_SPEED`, `STICK_TARGET_MARGIN` | `0.55`, `0.05` | On a pad, a homing missile's open target mark moves up to this many screen heights a second at full lean (with the stick's curve and speed-up), kept this share of the screen's height inside its edges |
| `STICK_DEADZONE`, `STICK_AIM_SPEED`, `STICK_CURVE` | `0.2`, `1.1`, `2` | The right stick moves the crosshair past this lean, up to this share of the power's length a second at full lean, the lean to this power (small leans aim finely); never while LT pans the camera, nor after until the stick is back in the middle ; pushing through the snail turns the aim to the other side |
| `STICK_RAMP_DELAY`, `STICK_RAMP_TIME`, `STICK_RAMP_MAX` | `0.35`, `0.6`, `2.5` | A stick push held past this many seconds speeds up, to this many times `STICK_AIM_SPEED` over this many more (a short nudge stays fine, a sweep across is quick) |
| `AIM_DEADZONE` | `0.05` | A crosshair within this share of no power clears the aim |
| `AIM_START_POWER`, `AIM_START_ANGLE` | `0.5`, `45` | A snail's first aim: this power, this many degrees up toward its nearest enemy |
| `FIRE_KEYS` | F, Enter | Keys that fire the locked aim, beside FIRE and RT |
| `PREDICTION_STEP`, `PREDICTION_SECONDS`, `PREDICTION_DOT_GAP`, `PREDICTION_DOTS` | `1 / 30`, `4`, `1.5`, `80` | The prediction line (the tutorial's, the testers, 2026-11-15, and the admin aimbot's): the path followed in these steps up to this long, a dot every this many studs, at most this many. It ignores a shot's slowdown in water and its bounces |
| `PREDICTION_DOT_SIZE`, `PREDICTION_END_SIZE`, `PREDICTION_COLOR`, `PREDICTION_END_COLOR` | `0.6`, `1.4`, gold, red | Its dots and the bigger dot where the shot lands |
| `PREDICTION_IDLE_POWER`, `PREDICTION_IDLE_TRANSPARENCY` | `0.6`, `0.4` | With no aim it shows the power last fired (this at first), this faded |
| `PREVIEW_DOTS`, `PREVIEW_SHARE` | `9`, `0.2` | The preview from the snail (every match, the tutorial too, but not with the aimbot; arced aims and a homing missile's launch): this many `PREFAB \| AimDot`s over this share of a full-power shot's flight time (at 45°), so they reach further with more power; no wind, stopped by the first terrain or snail. As the testers had it on 2026-11-24 |
| `PREVIEW_DOT_SIZE`, `PREVIEW_FADE` | `{ 0.75, 0.45 }`, `0.75` | The first and last dot's size in units, and how see-through the last one is (the first solid), all in the power's colour |
| `DROP_WARN_FROM` | `3` | From how many seconds left the drop's timer (the turn timer's plate) turns `TIMER_DANGER_COLOR` and ticks (`Turn_Tick`) each second |
| `HINTS_GUI_NAME` | `"ControlHints"` | The control hints, listed at the bottom left |
| `HINTS_MATCHES` | `9` | The hints show while the player's `MatchesPlayed` is under this: their first nine matches, hidden for good from the tenth |
| `HINT_TIP_SECONDS`, `HINT_TIP_TWEENINFO` | `4`, 0.35 s quad out | How long each tip stays, and its fade out and in |
| `HINT_TIPS` | seven tips | The tips over the list, in turn: dragging to aim (farther is more power), letting go then FIRE (or F), holding jump to fly, the aim kept for the next turn, moving after a throw, the open sea, grenades bursting when they stop |
| `RESULTS_XP_DELAY`, `RESULTS_XP_LINE_GAP` | `0.6`, `0.25` | Seconds after Results opens before its level bar plays, and between two XP lines |
| `RESULTS_XP_FILL_SECONDS`, `RESULTS_XP_TICKS`, `RESULTS_XP_TICK_PITCH` | `0.8`, `10`, `0.9` to `1.5` | A line's fill (a stretch that reaches a level first takes its share), its `Xp_Tick` ticks, and their pitch from an empty bar to a full one |
| `RESULTS_LEVEL_TWEENINFO` | 0.3 s back out | The diamond's pop when a level is reached |
| `KO_POP_START_SCALE`, `KO_POP_TWEENINFO` | `0.85`, 0.3 s back out | The knocked-out screen pops in from this size |
| `KO_CAUSE_ALONE_SCALE` | `1.5` | With no snail to name, the cause line takes the killer card's place, this many times as tall |

## In the place

Draws on the gui's `U_Aim` (a homing missile's target shows as its `S_TargetMark`, the crosshair's red copy), and puts the prediction's dots in `Workspace.Ume.Combat`. Binds the CAS action `MatchHud_Slots` while the loadout bar shows.
