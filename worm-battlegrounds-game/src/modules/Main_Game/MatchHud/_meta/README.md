# MatchHud

The match screen and its input, on the `MatchHud` gui (the studio's HUD design). It shows the teams in the top
corners, the timer, whose turn it is and the wind at the top, the turn order on the left, the stamina bar, the kill
feed, the loadout bar (the Bazooka and the player's items, with icons, uses and cooldowns, empty slots as "+"), the
power slider, touch move, jump and FIRE buttons, the waiting, drop and knocked-out blocks, and the Results screen.
Shooting is Worms Armageddon's: the weapon always points from the player's snail toward the mouse (a finger on touch,
the right stick on a pad), and holding the mouse button, RT or **FIRE** (touch) charges the power at one even rate,
none to full in Combat's `CHARGE_SECONDS`. Letting go fires, and a full charge fires by itself. Guns, melee weapons and
weapons placed at the feet fire on the press. On touch a finger on the arena points the aim (and stays pointed after
it lifts; a second finger stops it, for the camera's pan), and only FIRE shoots. Right click, Esc and the pad's
`CancelAim` (B) drop a charge. A homing missile's crosshair is its target: it follows the mouse or finger anywhere on the arena (no power cone) until the first click or tap places it, then stays there while the shot charges.
With an admin's aimbot on (Combat's `aimbot` command), the player's arced shots show the tutorial's prediction line,
and Combat marks the snails a shot can hit; the aim itself stays the player's (no lock-on).
The aim is drawn W:A's way on the gui's aim layer, `U_Aim`, under the rest of the HUD, in pixels over the snail every
frame: the power's cone, `POWER_DOTS` circles (clones of `PREFAB | PowerDot`, each later one drawn over the one before)
from `POWER_START` out along the aim, yellow through orange to red, blended into one (each circle's `UIGradient` runs the cone's colours from its back edge to its front, turned along the aim every frame), each growing in from nothing as the power passes it; then
`POWER_GAP` of room and the crosshair, `S_Crosshair` (a ring with an X, outlined), spinning, in the aiming snail's
`Color` (its team's, or its own in a free-for-all). Lengths are units, a stud at MatchCamera's `DISTANCE`, so the aim
looks the same at any zoom; zoomed in, the cone starts past the snail's grown ball instead. The held weapon turns with
the aim on this screen at once (Combat's `SetAim`). A turn that runs out drops a
charge without firing. Every player sees the active snail's crosshair and power. Number keys 1 to 6 pick a slot; on a pad LB and RB step through the
slots (a weapon is picked at once; a utility only gets the pad's cursor, its slot outlined with a Y hint, and Y puts
it in the snail's hands, for RT to use), and X held opens the emote wheel (the Cosmetics module's, T on a keyboard). It adds **Leave game** to the top bar,
an icon (`LEAVE_ICON`) after TopBar_Controller's music button. The HUD and that button show while the player is in the
match (the `InMatch` Player attribute); on the Studio map, going back to the lobby hides them and closes Results.

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

Devices: the move, jump and FIRE buttons show only on touch screens (`U_Touch`'s and `U_TouchJump`'s `Utils_HideOnPlatform`, FIRE by
`I.Platform.Current`), on the player's turn; the power slider shows on every device while the player aims; the slot
key numbers only on Desktop; the gamepad hints only on Console (`Console_Hint`, drawn by the Console module: LB and RB
at the bar's ends, Y on the utility the pad's cursor rests on, X on the emote button and the `U_PadControls` strip of
the match's buttons). Every pad button is the Console module's scheme (`I.Console`).

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/MatchHud` |
| Runs on | Client · Match map, Studio map |
| Uses | `I.Match`, `I.Snails`, `I.SnailControl`, `I.G_Arsenal`, `I.G_Combat`, `I.Replicator`, `I.TopBar`, `I.PlayerSettings`, `I.WidgetManager`, `I.Haptic`, `I.Sound`, `I.Interact`, `I.Platform`, `I.Console`, `I.PlayerBadges`, `I.G_Progression` (Results: a level's prestige frame), `I.DoEvery`, `ContextActionService` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Turns the gui on while the player is in a match (and the `HIDDEN_IN_MATCH` guis off), lays it out below Roblox's top bar on Mobile (its `ScreenInsets` `CoreUISafeInsets`, `DeviceSafeInsets` elsewhere, following `Platform_Changed`), and starts the handlers |
| `Scripts/Client/Turn.lua` | Banner ("Your turn!" in the gui's colour, or on other snails' turns "Bax's turn" in that snail's `Color`, from its `DisplayName`), the wait under it on other snails' turns ("You're next!" / "You play in N turns", from Match's `TurnOrder`; hidden once the player's snail is out), timer ("0:30"; once the shot is away it stays on the time that was left, in `TIMER_SPENT_COLOR`, until the turn ends), wind (`&gt;` / `&lt;` and "+3" / "-3"), the turn list (the active snail in the current look, then the next ones from `TurnOrder`, up to `TURN_LIST_ENTRIES`, avatar and name, the player's badges after it (`I.PlayerBadges.Show`), outlined in their team colour), stamina (`U_Stamina`: its bar cut at the share by its `UIGradient`, `STAMINA_FORMAT`; shown on the player's turn and, after a throw, while they still move), and over it the jetpack's fuel while the snail wears one (`U_Fuel`, cut at `I.SnailControl.GetFuelShare()`, `FUEL_FORMAT`, or `FUEL_REST_TEXT` while the jetpack rests); the turn callout (`_onTurnStarted` fills `U_TurnCallout`'s avatar, title, line (`_getCalloutLine`), gradient and accent colours; `_popCallout(scale, hold?)` opens the band (`_openCallout`) and closes it after the hold (`_closeCallout`), a newer one taking over from an older one; in local play a turn waiting for its player holds the callout open until Match's `HandOff` clears, `_onHandOff`, and the turn panel stays hidden meanwhile) and the "You're next!" flash; the sudden-death callout (`_onSuddenDeath`, after the turn's own, the liquid from `_getSuddenDeathLiquid`, its title gradient turned and tweened, then put back by the next turn's callout); the last seconds' timer colours, ticks and `U_Tension` pulse (`_tick`); sounds: `Turn_Yours` and `Turn_Whoosh` when the player's turn starts, `Turn_Start` on others', `Turn_Next` (volume 0.5) when the player is next, `Turn_Tick` in the player's last `TICK_SOUND_FROM` seconds, `Turn_TimeUp` when the player's turn runs out without a shot, `Match_SuddenDeath` when sudden death starts, `Match_WaterRise` as each sudden-death turn starts (the sea rises) |
| `Scripts/Client/Teams.lua` | The team panels (`U_TeamsLeft`, `U_TeamsRight`), from the drop on: the participants grouped by `Team`, the player's own first on the left, the others in turn right and left; each team's avatars (headshots for players, `BOT_AVATAR` for bots; `OUT_AVATAR_COLOR` once out) outlined in its colour, the side's own pictures (`Look_Left*` / `Look_Right*`), and its name ("Your team", "Red team" from Match's `TEAMS`; in a free-for-all "You" or the snail's name). A side with more players than fit shrinks them (`TEAM_PLAYER_WIDTH`). `SetAvatar` is shared with the turn list, the turn callout and the results |
| `Scripts/Client/Panels.lua` | The waiting (hidden while a public match's own waiting room shows, Match's `RoomEndsAt`), drop and knocked-out blocks; which bars show. The drop's timer (2026-11-17) is the turn timer's plate counting the drop's seconds down ("0:15", from Match's `DropEndsAt`), and from `DROP_WARN_FROM` seconds left its seconds turn `TIMER_DANGER_COLOR` and `Turn_Tick` plays each second |
| `Scripts/Client/LoadoutBar.lua` | The loadout bar and slot keys: one `BarSlot` per item (icon, name, uses, key), "+" slots up to `SLOT_KEYS`, the selected one in the slot's `Look_SelectedStrokeColor`, a cooling one darkened (`Look_CooldownIconColor`) under its turns left, one used up for the match darkened the same way under `S_Lock` (the Jetpack only once its fuel is gone: until then its uses show the fuel left, "75%", and a turn's cooldown while it rests after flying), and one with no uses left or cooling down can't be charged or fired (`IsReady`, which Aim checks). A utility picked goes in the snail's hands like a weapon (`Combat_Select`), and one in `USE_ON_SELECT` (the Jetpack) is used at once (`Select` calls `UseHeld`); `UseHeld` uses it (`Combat_UseUtility`) and hands back the last weapon held, or the Bazooka when that one isn't ready. The pad's LB and RB (Console's `WeaponPrevious`, `WeaponNext`) step through the slots, resting on a utility (outlined, its `S_UseHint` shown) until Y (`UseUtility`) puts it in the snail's hands. A weapon with no icon picture shows its 3D model in its icon instead (`I.G_Arsenal.GetModel`, in a ViewportFrame `S_Model`) |
| `Scripts/Client/Aim.lua` | With a utility in the snail's hands, no aim: any press on the screen (a finger's too, RT on a pad) uses it (`LoadoutBar.UseHeld`). The crosshair and charging (mouse, touch, pad), the pad's aim (`_aimWithStick`, every frame: the right stick points it, a gentle lean only nudging it at `STICK_NUDGE_SPEED`, a firm one easing it there at `STICK_TURN_SPEED`, never in one jump; it holds still while the lean drops faster than `STICK_DROP_RATE`, while LT pans the camera and after LT until the stick is back under `STICK_DEADZONE`), the power circles, firing (the mouse, RT or `U_Fire` let go, or a full charge; with the `Combat_Fire` haptic tick; firing ends the player's snail's emote on this screen at once, `I.SnailRig.StopEmote`), homing targets (a click places one; on touch a finger places it and drags it until FIRE, and where a finger last lifted is forgotten when a turn starts or ends), detonating; another snail's crosshair and power (a player's or a bot's) while it aims; on the player's turn the power slider (`U_Power`: the bar cut at the power, the handle at its edge with "75%", the angle "45°" over it, or with a homing missile `TARGET_HINTS`), and FIRE on touch screens with the held weapon's icon. FIRE needs a homing missile's target. In the tutorial match, and for a player with the `Aimbot` attribute (Combat's `aimbot` command), an arced weapon's prediction line (`PREDICTION_*`: gold neon dots along the path at the power held, or faded at the power last fired, wind and all, to the first terrain or snail, in `Workspace.Ume.Combat`) |
| `Scripts/Client/KillFeed.lua` | Knockout lines; a line too long for the feed at its design size (`TextService:GetTextBoundsAsync`) gets two lines' height instead of shrinking |
| `Scripts/Client/TouchControls.lua` | Walk buttons (`U_Touch`, bottom left) and the jump button (`U_TouchJump`, on the right above FIRE) on touch screens, on the player's turn; the pad's controls strip (`U_PadControls`, Console only) then too |
| `Scripts/Client/Results.lua` | The Results screen (the studio's MatchOver: each card's place in its medal colour from the prefab's `Look_<Place>*` attributes, name with the player's badges after it, `I.PlayerBadges.Show`, and username), rematch votes; `Match_Win` for first place, `Match_Lose` otherwise. The level bar under the coins line (2026-11-17): from MatchRewards' `XpBefore` to `XpAfter`, after `RESULTS_XP_DELAY` each of its `XpLines` (one line of `Xp` when there are none) counts the XP total up with `Xp_Line` and fills the bar with `Xp_Tick` ticks climbing in pitch, each level reached plays `Level_Up`, pops the diamond in the new level's prestige frame (`I.G_Progression.ApplyFrame`) and shows the level-up line; a level between the two costs the share of the way from `XpBefore.For` to `XpAfter.For` (the curve rises by the same step each level; the client never gets it). Results without `XpBefore` and `XpAfter` (a server from before) hide the bar and show the XP and level-up line at once |
| `Scripts/Client/Hints.lua` | The control hints (the `ControlHints` gui, 2026-11-17): on while the player is in the match's `Waiting` or `Drop` phase, in their first `HINTS_MATCHES` matches (the `MatchesPlayed` statistic in their Replicator `Statistic` folder; off until it's known, and for good once it's reached) and never in the tutorial match; each device sees its own list by itself (`Utils_HideOnPlatform`), and the tip over the list fades to the next of `HINT_TIPS` every `HINT_TIP_SECONDS` |
| `Scripts/Client/TopBar.lua` | The Leave and Music top bar buttons |
| `Settings.lua` | `MatchHud_Settings` |
| `_meta/_types.lua` | `MatchHud_SuddenDeathLiquid`, a `SUDDEN_DEATH_LIQUIDS` row (`Name`, `Color`) |

## Network

No remotes of its own. It sends Combat's `Combat_Select`, `Combat_UseUtility`, `Combat_Aim` (unreliable, 10 per
second), `Combat_Fire` and `Combat_Detonate`, and Match's `Match_Leave` and `Match_Rematch`; it listens to
`Match_KnockedOut` and `Match_Results`.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `GUI_NAME`, `RESULTS_GUI_NAME` | `"MatchHud"`, `"Results"` | The guis |
| `RESULTS_FIT_PLACINGS` | `4` | The Results placing cards that fit across at the design's width; with more players each card narrows to share it |
| `LOCKED_REMATCH_COLORS` | Main 120, 120, 130; Stroke 170, 170, 178; Text 200, 200, 205 | The tutorial's Rematch button, grey and dead (the button's own colours come back for other matches) |
| `HIDDEN_IN_MATCH` | `{ "Currency" }` | Guis the framework keeps on (`UserInterface_PreventHiding`) that are hidden while the player is in a match; the currency bar sits where the team panel goes |
| `TIMER_WARN_FROM`, `TIMER_WARN_COLOR` | `8`, `(255, 170, 40)` | On the player's own turn the timer turns this orange from this many seconds left |
| `TIMER_SPENT_COLOR` | `(140, 140, 150)` | The timer once the shot is away, held on the time that was left |
| `TICK_SOUND_FROM`, `TIMER_DANGER_COLOR` | `5`, `(255, 70, 50)` | From this many seconds left of the player's own turn the timer turns this red, ticks aloud each second (`Turn_Tick`, pitch rising to 1.3) and `U_Tension` shows |
| `TICK_FAST_FROM` | `3` | From this many seconds left it ticks every half second |
| `TENSION_PULSE_RATE` | `1.5` | `U_Tension`'s pulses a second at first, rising to twice as many at the end |
| `CALLOUT_START_SCALE`, `CALLOUT_SLIDE`, `CALLOUT_HOLD` | `1.3`, `0.06`, `1` | The turn callout's content settles from this many times its size (its `S_Pop` UIScale), slides this share of the screen in and on, and stays this many seconds |
| `CALLOUT_OTHER_SCALE` | `0.8` | Anyone else's callout's size, a share of the player's own |
| `CALLOUT_BAND_TWEENINFO` | 0.18 s quad out | How the band (`S_Band`) opens |
| `CALLOUT_IN_TWEENINFO`, `CALLOUT_OUT_TWEENINFO` | 0.35 s back out, 0.22 s quart in | How the content slides in and settles, and how it slides on as the band closes |
| `CALLOUT_ACCENT_COLOR` | `(255, 140, 20)` | The lines and the avatar frame on the player's own turn (anyone else's take their snail's `Color`, and so does every local snail in local play) |
| `CALLOUT_MINE_GRADIENT`, `CALLOUT_OTHER_GRADIENT` | `(255, 232, 110)` to `(255, 140, 20)`; `(255, 255, 255)` to `(200, 215, 235)` | The title's gradient, top to bottom: gold on the player's own turn, white on anyone else's |
| `HANDOFF_TEXTS` | `Desktop`, `Mobile`, `Console` lines | Local play: the line under a local snail's name while its turn waits for the controller, for the device in use ("Pass the controller, then click when ready") |
| `SUDDEN_DEATH_TITLE`, `SUDDEN_DEATH_SUB`, `SUDDEN_DEATH_REMINDER` | `"%s is rising..."`, `"Sudden death!"`, `"The %s rises"` | The sudden-death callout's title (with the liquid's name) and line, and what every sudden-death turn's line adds (the name in lower case) |
| `SUDDEN_DEATH_HOLD` | `2.4` | How long the sudden-death callout stays, in seconds |
| `SUDDEN_DEATH_FILL_FROM`, `SUDDEN_DEATH_FILL_TO`, `SUDDEN_DEATH_FILL_TWEENINFO` | `(0, 0.55)`, `(0, -0.1)`, 1.6 s sine out | The title fills with the liquid's colour from the bottom: its gradient (turned 90°, white over the colour) slides its `Offset` from the first to the second |
| `SUDDEN_DEATH_LIQUIDS` | Water `(63, 166, 255)`, Lava `(255, 140, 20)` | Each liquid's name in the callout and its colour (the lines, the title's fill), by Match's `SeaKind`; water when unknown |
| `NEXT_FLASH_COLOR`, `NEXT_FLASH_TWEENINFO` | `(255, 220, 60)`, 1.2 s quad out | When the player is next, their "You're next!" line flashes this colour and fades back to its own |
| `STAMINA_FORMAT` | `"Stamina %d%%"` | The stamina bar's text |
| `FUEL_FORMAT`, `FUEL_REST_TEXT` | `"Jetpack %d%%"`, `"Jetpack next turn"` | The jetpack fuel bar's text: its share, or the turn it rests after flying |
| `TURN_LIST_ENTRIES` | `6` | How many snails the turn list shows |
| `TEAM_PLAYER_WIDTH` | `0.235` | A player's share of a team panel's width |
| `OUT_AVATAR_COLOR` | `(70, 70, 70)` | A knocked-out snail's avatar tint in the team panels |
| `BOT_AVATAR` | `rbxassetid://75705415395334` | A bot's avatar in the team panels, the turn list, the turn callout and the results: the default snail's voxel headshot (`art/bots`), uploaded to The Snail Studio group |
| `LEAVE_ICON`, `LEAVE_QUESTION` | | The Leave game button's icon (the repo's `art/topbar` `TopBar_Leave`, uploaded to The Snail Studio group) and its confirmation |
| `SLOT_KEYS` | One … Seven | Keys that pick boxes 1 to 7 (the Bazooka first, then loadout slots 1 to 6); also how many boxes the bar shows |
| `MODEL_FOV`, `MODEL_VIEW_DIRECTION`, `MODEL_PADDING` | `30`, `0.3, 0.25, 1`, `1.15` | A slot's weapon model: the camera's field of view, the direction it looks from (the muzzle points right), and the room around the model's longest side |
| `USE_ON_SELECT` | `{ Jetpack = true }` | Utilities used the moment their box is picked, with no press on the screen (the owner, 2026-11-16) |
| `FEED_LINES`, `FEED_SECONDS` | `4`, `6` | Kill feed length and how long a line stays |
| `AIM_SEND_INTERVAL` | `0.1` | How often the aim is sent to others during the player's turn |
| `HOMING_AIM_REACH` | `60` | A homing missile fired with no target picked (the pad's RT, FIRE on touch) homes on the mouse's point on the arena, or this many studs along its aim |
| `FIRE_ANSWER_SECONDS` | `2` | After a shot is sent the aim hides and the held weapon stays on the shot's angle (its sound plays at once on the shooter's screen) until the match moves on; after this long without that (the server refused it), the player may aim again |
| `AIM_SHOW_GRACE`, `AIM_SMOOTHING` | `0.4`, `15` | Another snail's crosshair and power show while its aim keeps arriving (none for this long hides them), eased toward each update |
| `POWER_DOTS`, `POWER_COLORS`, `POWER_DOT_SIZE` | `14`, (255, 226, 92), (255, 148, 38), (240, 62, 46), `{ 0.9, 2.3 }` | The power cone's circles: how many, their colours (spread evenly, first to last) and sizes in units (a stud at MatchCamera's `DISTANCE`), first to last |
| `POWER_START`, `POWER_LENGTH`, `POWER_GAP` | `2.3`, `7`, `0.3` | In units: from the snail's middle to the first circle's (further zoomed in, past the snail's ball), from the first circle's middle to the last's, and the room after the last circle before the crosshair |
| `CROSSHAIR_SIZE`, `CROSSHAIR_SPIN` | `3.4`, `60` | The crosshair's size in units (the X's reach) and its spin in degrees a second |
| `BAR_FILL` | `1` | The share of the power and stamina bars' picture its fill covers (the rest is its empty end), so a full bar cuts its gradients (the bar's and its texture's, `S_BarMask`) there and the power handle stops there |
| `TARGET_COLOR` | red | The homing target marker |
| `TARGET_HINTS` | `Pick`, `TouchPick`, `Shoot` | The slider's text with a homing missile: before its target is picked (a click, or a tap on touch), then until the aim starts |
| `STICK_DEADZONE`, `STICK_FIRM_LEAN`, `STICK_NUDGE_SPEED` | `0.3`, `0.55`, `{ 5, 30 }` | The right stick points the aim from this lean; up to the firm lean it only nudges the aim toward the stick, from 5 to 30 degrees a second as it leans further |
| `STICK_TURN_SPEED` | `{ 8, 18 }` | A firm lean turns the aim to the stick in a quick ease, this quickly from the firm lean to full lean (higher is snappier; at 18 it's 95% there in a sixth of a second) |
| `STICK_DROP_RATE` | `1.5` | While the lean drops faster than this many a second (the stick springing back as it's let go), the aim holds still |
| `PREDICTION_STEP`, `PREDICTION_SECONDS`, `PREDICTION_DOT_GAP`, `PREDICTION_DOTS` | `1 / 30`, `4`, `1.5`, `80` | The prediction line (the tutorial's, the testers, 2026-11-15, and the admin aimbot's): the path followed in these steps up to this long, a dot every this many studs, at most this many. It ignores a shot's slowdown in water and its bounces |
| `PREDICTION_DOT_SIZE`, `PREDICTION_END_SIZE`, `PREDICTION_COLOR`, `PREDICTION_END_COLOR` | `0.6`, `1.4`, gold, red | Its dots and the bigger dot where the shot lands |
| `PREDICTION_IDLE_POWER`, `PREDICTION_IDLE_TRANSPARENCY` | `0.6`, `0.4` | Before a press it shows the power last fired (this at first), this faded |
| `DROP_WARN_FROM` | `3` | From how many seconds left the drop's timer (the turn timer's plate) turns `TIMER_DANGER_COLOR` and ticks (`Turn_Tick`) each second |
| `HINTS_GUI_NAME` | `"ControlHints"` | The control hints, listed at the bottom left |
| `HINTS_MATCHES` | `9` | The hints show while the player's `MatchesPlayed` is under this: their first nine matches, hidden for good from the tenth |
| `HINT_TIP_SECONDS`, `HINT_TIP_TWEENINFO` | `4`, 0.35 s quad out | How long each tip stays, and its fade out and in |
| `HINT_TIPS` | seven tips | The tips over the list, in turn: holding to charge, holding jump to fly, the wind, a full charge, moving after a throw, the open sea, grenades (the list's labels are one or two words, so the holds are told here) |
| `RESULTS_XP_DELAY`, `RESULTS_XP_LINE_GAP` | `0.6`, `0.25` | Seconds after Results opens before its level bar plays, and between two XP lines |
| `RESULTS_XP_FILL_SECONDS`, `RESULTS_XP_TICKS`, `RESULTS_XP_TICK_PITCH` | `0.8`, `10`, `0.9` to `1.5` | A line's fill (a stretch that reaches a level first takes its share), its `Xp_Tick` ticks, and their pitch from an empty bar to a full one |
| `RESULTS_LEVEL_TWEENINFO` | 0.3 s back out | The diamond's pop when a level is reached |

## In the place

Clones the power circles into the gui's `U_Aim`, and puts the homing target marker (`AimTarget`) in
`Workspace.Ume.Combat`. Binds the CAS action `MatchHud_Slots` while the loadout bar shows. The Results screen greys out
**Rematch** after the tutorial match (`LOCKED_REMATCH_COLORS`, its gold `Mask` hidden; pressing it does nothing).
