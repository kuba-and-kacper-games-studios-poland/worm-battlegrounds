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
`CancelAim` (B) drop a charge. A homing missile's first click or tap picks its target.
With an admin's aim guide on (Combat's `aimbot` command), a right click locks on: the aim eases over `AIMBOT_EASE`
seconds onto the guide whose target is nearest the mouse (Combat's `GetAimGuides`; a homing missile's target becomes
that snail), stays there whatever the mouse does, and the next left click fires it; Esc cancels. Without a guide,
right click cancels the aim as before.
The aim is drawn W:A's way on the gui's aim layer, `U_Aim`, under the rest of the HUD, in pixels over the snail every
frame: the power's cone, `POWER_DOTS` circles (clones of `PREFAB | PowerDot`, each later one drawn over the one before)
from `POWER_START` out along the aim, yellow through orange to red, blended into one (each circle's `UIGradient` runs the cone's colours from its back edge to its front, turned along the aim every frame), each growing in from nothing as the power passes it; then
`POWER_GAP` of room and the crosshair, `S_Crosshair` (a ring with an X, outlined), spinning, in the aiming snail's
`Color` (its team's, or its own in a free-for-all). Lengths are units, a stud at MatchCamera's `DISTANCE`, so the aim
looks the same at any zoom; zoomed in, the cone starts past the snail's grown ball instead. The held weapon turns with
the aim on this screen at once (Combat's `SetAim`). A turn that runs out drops a
charge without firing. Every player sees the active snail's crosshair and power. Number keys 1 to 6 pick a slot; on a pad LB and RB step through the
slots (a weapon is picked at once; a utility only gets the pad's cursor, its slot outlined with a Y hint, and Y uses
it), and X opens the emote wheel (`U_EmoteButton`'s key). It adds **Leave game** to the top bar,
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
takes over. When the player is next, `Turn_Next` plays and the "You're next!" line flashes `NEXT_FLASH_COLOR`.
The last seconds of the player's own turn tighten: the timer turns `TIMER_WARN_COLOR` from `TIMER_WARN_FROM` seconds
left and `TIMER_DANGER_COLOR` from `TICK_SOUND_FROM`, when `Turn_Tick` plays each second, each half second from
`TICK_FAST_FROM`, its pitch rising from 1 to 1.3, and `U_Tension`, a red band along the screen's sides, pulses
`TENSION_PULSE_RATE` times a second, up to twice as fast at the end.

Devices: the move, jump and FIRE buttons show only on touch screens (`U_Touch`'s `Utils_HideOnPlatform`, FIRE by
`I.Platform.Current`), on the player's turn; the power slider shows on every device while the player aims; the slot
key numbers only on Desktop; the gamepad hints only on Console (`Console_Hint`, drawn by the Console module: LB and RB
at the bar's ends, Y on the utility the pad's cursor rests on, X on the emote button and the `U_PadControls` strip of
the match's buttons). Every pad button is the Console module's scheme (`I.Console`).

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/MatchHud` |
| Runs on | Client · Match map, Studio map |
| Uses | `I.Match`, `I.Snails`, `I.SnailControl`, `I.G_Arsenal`, `I.G_Combat`, `I.Replicator`, `I.TopBar`, `I.PlayerSettings`, `I.WidgetManager`, `I.Haptic`, `I.Sound`, `I.Interact`, `I.Platform`, `I.Console`, `I.PlayerBadges`, `ContextActionService` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Turns the gui on while the player is in a match (and the `HIDDEN_IN_MATCH` guis off), lays it out below Roblox's top bar on Mobile (its `ScreenInsets` `CoreUISafeInsets`, `DeviceSafeInsets` elsewhere, following `Platform_Changed`), and starts the handlers |
| `Scripts/Client/Turn.lua` | Banner ("Your turn!" in the gui's colour, or on other snails' turns "Bax's turn" in that snail's `Color`, from its `DisplayName`), the wait under it on other snails' turns ("You're next!" / "You play in N turns", from Match's `TurnOrder`; hidden once the player's snail is out), timer ("0:30", blank while a shot flies and settles), wind (`&gt;` / `&lt;` and "+3" / "-3"), the turn list (the active snail in the current look, then the next ones from `TurnOrder`, up to `TURN_LIST_ENTRIES`, avatar and name, the player's badges after it (`I.PlayerBadges.Show`), outlined in their team colour), stamina (`U_Stamina`: its bar cut at the share by its `UIGradient`, `STAMINA_FORMAT`); the turn callout (`_onTurnStarted` fills `U_TurnCallout`'s avatar, title, line, gradient and accent colours; `_popCallout(scale)` opens the band, slides and settles the content, and closes it, a newer one taking over from an older one) and the "You're next!" flash; the last seconds' timer colours, ticks and `U_Tension` pulse (`_tick`); sounds: `Turn_Yours` and `Turn_Whoosh` when the player's turn starts, `Turn_Start` on others', `Turn_Next` (volume 0.5) when the player is next, `Turn_Tick` in the player's last `TICK_SOUND_FROM` seconds, `Turn_TimeUp` when the player's turn runs out without a shot, `Match_SuddenDeath` when sudden death starts, `Match_WaterRise` as each sudden-death turn starts (the sea rises) |
| `Scripts/Client/Teams.lua` | The team panels (`U_TeamsLeft`, `U_TeamsRight`), from the drop on: the participants grouped by `Team`, the player's own first on the left, the others in turn right and left; each team's avatars (headshots for players, `BOT_AVATAR` for bots; `OUT_AVATAR_COLOR` once out) outlined in its colour, the side's own pictures (`Look_Left*` / `Look_Right*`), and its name ("Your team", "Red team" from Match's `TEAMS`; in a free-for-all "You" or the snail's name). A side with more players than fit shrinks them (`TEAM_PLAYER_WIDTH`). `SetAvatar` is shared with the turn list, the turn callout and the results |
| `Scripts/Client/Panels.lua` | The waiting, drop and knocked-out blocks; which bars show |
| `Scripts/Client/LoadoutBar.lua` | The loadout bar and slot keys: one `BarSlot` per item (icon, name, uses, key), "+" slots up to `SLOT_KEYS`, the selected one in the slot's `Look_SelectedStrokeColor`, a cooling one darkened (`Look_CooldownIconColor`) under its turns left, and one with no uses left or cooling down can't be charged or fired (`IsReady`, which Aim checks); utilities are used as soon as they're picked on the player's turn. The pad's LB and RB (Console's `WeaponPrevious`, `WeaponNext`) step through the slots, resting on a utility (outlined, its `S_UseHint` shown) until Y (`UseUtility`) uses it. A weapon with no icon picture shows its 3D model in its icon instead (`I.G_Arsenal.GetModel`, in a ViewportFrame `S_Model`) |
| `Scripts/Client/Aim.lua` | The crosshair and charging (mouse, touch, pad), the power circles, firing (the mouse, RT or `U_Fire` let go, or a full charge; with the `Combat_Fire` haptic tick; firing ends the player's snail's emote on this screen at once, `I.SnailRig.StopEmote`), homing targets, detonating; another snail's crosshair and power (a player's or a bot's) while it aims; on the player's turn the power slider (`U_Power`: the bar cut at the power, the handle at its edge with "75%", the angle "45°" over it, or with a homing missile `TARGET_HINTS`), and FIRE on touch screens with the held weapon's icon. FIRE needs a homing missile's target |
| `Scripts/Client/KillFeed.lua` | Knockout lines; a line too long for the feed at its design size (`TextService:GetTextBoundsAsync`) gets two lines' height instead of shrinking |
| `Scripts/Client/TouchControls.lua` | Walk and jump buttons on touch screens, on the player's turn; the pad's controls strip (`U_PadControls`, Console only) then too |
| `Scripts/Client/Results.lua` | The Results screen (the studio's MatchOver: each card's place in its medal colour from the prefab's `Look_<Place>*` attributes, name with the player's badges after it, `I.PlayerBadges.Show`, and username), rematch votes; `Match_Win` for first place, `Match_Lose` otherwise |
| `Scripts/Client/TopBar.lua` | The Leave and Music top bar buttons |
| `Settings.lua` | `MatchHud_Settings` |

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
| `TICK_SOUND_FROM`, `TIMER_DANGER_COLOR` | `5`, `(255, 70, 50)` | From this many seconds left of the player's own turn the timer turns this red, ticks aloud each second (`Turn_Tick`, pitch rising to 1.3) and `U_Tension` shows |
| `TICK_FAST_FROM` | `3` | From this many seconds left it ticks every half second |
| `TENSION_PULSE_RATE` | `1.5` | `U_Tension`'s pulses a second at first, rising to twice as many at the end |
| `CALLOUT_START_SCALE`, `CALLOUT_SLIDE`, `CALLOUT_HOLD` | `1.3`, `0.06`, `1` | The turn callout's content settles from this many times its size (its `S_Pop` UIScale), slides this share of the screen in and on, and stays this many seconds |
| `CALLOUT_OTHER_SCALE` | `0.8` | Anyone else's callout's size, a share of the player's own |
| `CALLOUT_BAND_TWEENINFO` | 0.18 s quad out | How the band (`S_Band`) opens |
| `CALLOUT_IN_TWEENINFO`, `CALLOUT_OUT_TWEENINFO` | 0.35 s back out, 0.22 s quart in | How the content slides in and settles, and how it slides on as the band closes |
| `CALLOUT_ACCENT_COLOR` | `(255, 140, 20)` | The lines and the avatar frame on the player's own turn (anyone else's take their snail's `Color`) |
| `CALLOUT_MINE_GRADIENT`, `CALLOUT_OTHER_GRADIENT` | `(255, 232, 110)` to `(255, 140, 20)`; `(255, 255, 255)` to `(200, 215, 235)` | The title's gradient, top to bottom: gold on the player's own turn, white on anyone else's |
| `NEXT_FLASH_COLOR`, `NEXT_FLASH_TWEENINFO` | `(255, 220, 60)`, 1.2 s quad out | When the player is next, their "You're next!" line flashes this colour and fades back to its own |
| `STAMINA_FORMAT` | `"Stamina %d%%"` | The stamina bar's text |
| `TURN_LIST_ENTRIES` | `6` | How many snails the turn list shows |
| `TEAM_PLAYER_WIDTH` | `0.235` | A player's share of a team panel's width |
| `OUT_AVATAR_COLOR` | `(70, 70, 70)` | A knocked-out snail's avatar tint in the team panels |
| `BOT_AVATAR` | `rbxassetid://75705415395334` | A bot's avatar in the team panels, the turn list, the turn callout and the results: the default snail's voxel headshot (`art/bots`), uploaded to The Snail Studio group |
| `LEAVE_ICON`, `LEAVE_QUESTION` | | The Leave game button's icon (the repo's `art/topbar` `TopBar_Leave`, uploaded to The Snail Studio group) and its confirmation |
| `SLOT_KEYS` | One … Seven | Keys that pick boxes 1 to 7 (the Bazooka first, then loadout slots 1 to 6); also how many boxes the bar shows |
| `MODEL_FOV`, `MODEL_VIEW_DIRECTION`, `MODEL_PADDING` | `30`, `0.3, 0.25, 1`, `1.15` | A slot's weapon model: the camera's field of view, the direction it looks from (the muzzle points right), and the room around the model's longest side |
| `FEED_LINES`, `FEED_SECONDS` | `4`, `6` | Kill feed length and how long a line stays |
| `AIM_SEND_INTERVAL` | `0.1` | How often the aim is sent to others during the player's turn |
| `HOMING_AIM_REACH` | `60` | A homing missile fired with no target picked (the pad's RT, FIRE on touch, a lock-on) homes on the mouse's point on the arena, or this many studs along its aim |
| `FIRE_ANSWER_SECONDS` | `2` | After a shot is sent the aim hides and the held weapon stays on the shot's angle (its sound plays at once on the shooter's screen) until the match moves on; after this long without that (the server refused it), the player may aim again |
| `AIM_SHOW_GRACE`, `AIM_SMOOTHING` | `0.4`, `15` | Another snail's crosshair and power show while its aim keeps arriving (none for this long hides them), eased toward each update |
| `POWER_DOTS`, `POWER_COLORS`, `POWER_DOT_SIZE` | `14`, (255, 226, 92), (255, 148, 38), (240, 62, 46), `{ 0.9, 2.3 }` | The power cone's circles: how many, their colours (spread evenly, first to last) and sizes in units (a stud at MatchCamera's `DISTANCE`), first to last |
| `POWER_START`, `POWER_LENGTH`, `POWER_GAP` | `2.3`, `7`, `0.3` | In units: from the snail's middle to the first circle's (further zoomed in, past the snail's ball), from the first circle's middle to the last's, and the room after the last circle before the crosshair |
| `CROSSHAIR_SIZE`, `CROSSHAIR_SPIN` | `3.4`, `60` | The crosshair's size in units (the X's reach) and its spin in degrees a second |
| `BAR_FILL` | `1` | The share of the power and stamina bars' picture its fill covers (the rest is its empty end), so a full bar cuts its gradients (the bar's and its texture's, `S_BarMask`) there and the power handle stops there |
| `TARGET_COLOR` | red | The homing target marker |
| `TARGET_HINTS` | `Pick`, `Shoot` | The slider's text with a homing missile: before its target is picked, then until the aim starts |
| `STICK_DEADZONE` | `0.3` | How far the right stick leans to aim |
| `AIMBOT_EASE` | `0.4` | With an admin's aim guide on, how long a right click's lock-on takes to ease the aim onto the guide, in seconds |

## In the place

Clones the power circles into the gui's `U_Aim`, and puts the homing target marker (`AimTarget`) in
`Workspace.Ume.Combat`. Binds the CAS action `MatchHud_Slots` while the loadout bar shows. The Results screen greys out
**Rematch** after the tutorial match (`LOCKED_REMATCH_COLORS`, its gold `Mask` hidden; pressing it does nothing).
