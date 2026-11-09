# MatchHud

The match screen and its input, on the `MatchHud` gui (the studio's HUD design). It shows the teams in the top
corners, the timer, whose turn it is and the wind at the top, the turn order on the left, the stamina bar, the kill
feed, the loadout bar (the Bazooka and the player's items, with icons, uses and cooldowns, empty slots as "+"), the
power slider, touch move, jump and FIRE buttons, the waiting, drop and knocked-out blocks, and the Results screen. On
PC the weapon always points from the player's snail toward the mouse, held or not; pressing and holding sets the power
by how far the mouse (or a held finger on touch) is from the snail on the screen (`MIN_PULL` to `MAX_PULL`, shares of
the screen's height), and letting go of the mouse fires (closer than `MIN_PULL` cancels). On touch screens letting go
of the finger keeps the aim and its power on the slider, and **FIRE** fires it (a new drag replaces it). On a pad the
right stick aims and holding RT runs the power bar up and down (Combat's `CHARGE_SECONDS` each way) until it's let go.
With an admin's aim guide on (Combat's `aimbot` command), a right click locks on: the aim eases over `AIMBOT_EASE`
seconds onto the guide whose target is nearest the mouse (Combat's `GetAimGuides`; a homing missile's target becomes
that snail), stays there whatever the mouse does, and the next left click fires it; Esc cancels. Without a guide,
right click cancels the aim as before.
The aim shows as an angle marker, the studio's crosshair picture `CROSSHAIR_DISTANCE` studs from the snail, and a
power bar, a row of circles from the held weapon's muzzle (Combat's `GetMuzzle`) to it that lights up yellow to red;
both keep their size on the screen at any zoom, sized for MatchCamera's `DISTANCE`. The held weapon turns with the aim
on this screen at once (Combat's `SetAim`). Nothing fires by itself: a turn that runs out drops the aim. Every player
sees the active snail's angle marker and power. Number keys 1 to 6, LB and RB pick a slot. It adds **Leave game** and
**Mute music** to the top bar. The HUD and those buttons show while the player is in the match (the `InMatch` Player
attribute); on the Studio map, going back to the lobby hides them and closes Results.

Devices: the move, jump and FIRE buttons show only on touch screens (`U_Touch`'s `Utils_HideOnPlatform`, FIRE by
`I.Platform.Current`), on the player's turn; the power slider shows on every device while the player aims; the slot
key numbers only on Desktop; the LB / RB hints only on Console.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/MatchHud` |
| Runs on | Client · Match map, Studio map |
| Uses | `I.Match`, `I.Snails`, `I.SnailControl`, `I.G_Arsenal`, `I.G_Combat`, `I.Replicator`, `I.TopBar`, `I.PlayerSettings`, `I.WidgetManager`, `I.Haptic`, `I.Sound`, `I.Interact`, `I.Platform`, `ContextActionService` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Turns the gui on while the player is in a match (and the `HIDDEN_IN_MATCH` guis off), and starts the handlers |
| `Scripts/Client/Turn.lua` | Banner ("Your turn!" in the gui's colour, or on other snails' turns "Bax's turn" in that snail's `Color`, from its `DisplayName`), the wait under it on other snails' turns ("You're next!" / "Your turn in N turns", from Match's `TurnOrder`; hidden once the player's snail is out), timer ("0:30", blank while a shot flies and settles), wind (`&gt;` / `&lt;` and "+3" / "-3"), the turn list (the active snail in the current look, then the next ones from `TurnOrder`, up to `TURN_LIST_ENTRIES`, avatar and name, outlined in their team colour), stamina (`U_Stamina`: its bar cut at the share by its `UIGradient`, `STAMINA_FORMAT`); sounds: `Turn_Yours` when the player's turn starts and `Turn_Start` on others', `Turn_Tick` each second of the player's last `TICK_SOUND_FROM`, `Match_SuddenDeath` when sudden death starts |
| `Scripts/Client/Teams.lua` | The team panels (`U_TeamsLeft`, `U_TeamsRight`), from the drop on: the participants grouped by `Team`, the player's own first on the left, the others in turn right and left; each team's avatars (headshots for players, `BOT_AVATAR` for bots; `OUT_AVATAR_COLOR` once out) outlined in its colour, the side's own pictures (`Look_Left*` / `Look_Right*`), and its name ("Your team", "Red team" from Match's `TEAMS`; in a free-for-all "You" or the snail's name). A side with more players than fit shrinks them (`TEAM_PLAYER_WIDTH`). `SetAvatar` is shared with the turn list |
| `Scripts/Client/Panels.lua` | The waiting, drop and knocked-out blocks; which bars show |
| `Scripts/Client/LoadoutBar.lua` | The loadout bar and slot keys: one `BarSlot` per item (icon, name, uses, key), "+" slots up to `SLOT_KEYS`, the selected one in the slot's `Look_SelectedStrokeColor`, a cooling one darkened (`Look_CooldownIconColor`) under its turns left; utilities are used as soon as they're picked on the player's turn. A weapon with no icon picture shows its 3D model in its icon instead (`I.G_Arsenal.GetModel`, in a ViewportFrame `S_Model`) |
| `Scripts/Client/Aim.lua` | The crosshair and charging (mouse, touch, pad), the power circles, firing (the mouse or RT let go, or `U_Fire` on touch; with the `Combat_Fire` haptic tick), homing targets, detonating; another snail's crosshair and power (a player's or a bot's) while it aims; on the player's turn the power slider (`U_Power`: the bar cut at the power, the handle at its edge with "75%", the angle "45°" over it, or with a homing missile `TARGET_HINTS`), and FIRE on touch screens with the held weapon's icon. FIRE needs a homing missile's target, and power for a thrown weapon |
| `Scripts/Client/KillFeed.lua` | Knockout lines; a line too long for the feed at its design size (`TextService:GetTextBoundsAsync`) gets two lines' height instead of shrinking |
| `Scripts/Client/TouchControls.lua` | Walk and jump buttons on touch screens, on the player's turn |
| `Scripts/Client/Results.lua` | The Results screen, rematch votes; `Match_Win` for first place, `Match_Lose` otherwise |
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
| `HIDDEN_IN_MATCH` | `{ "Currency" }` | Guis the framework keeps on (`UserInterface_PreventHiding`) that are hidden while the player is in a match; the currency bar sits where the team panel goes |
| `TICK_SOUND_FROM` | `5` | The timer ticks aloud each second from this many seconds left of the player's own turn |
| `STAMINA_FORMAT` | `"Stamina %d%%"` | The stamina bar's text |
| `TURN_LIST_ENTRIES` | `6` | How many snails the turn list shows |
| `TEAM_PLAYER_WIDTH` | `0.235` | A player's share of a team panel's width |
| `OUT_AVATAR_COLOR` | `(70, 70, 70)` | A knocked-out snail's avatar tint in the team panels |
| `BOT_AVATAR` | the theme's `wb-smiley` | A bot's avatar in the team panels and the turn list (the design's own player picture draws blank in the game) |
| `LEAVE_TEXT`, `MUSIC_TEXT`, `LEAVE_QUESTION` | | The top bar buttons and the leave confirmation |
| `SLOT_KEYS` | One … Six | Keys that pick slots 1 to 6 (the Bazooka first); also how many slots the bar shows |
| `MODEL_FOV`, `MODEL_VIEW_DIRECTION`, `MODEL_PADDING` | `30`, `0.3, 0.25, 1`, `1.15` | A slot's weapon model: the camera's field of view, the direction it looks from (the muzzle points right), and the room around the model's longest side |
| `FEED_LINES`, `FEED_SECONDS` | `4`, `6` | Kill feed length and how long a line stays |
| `AIM_SEND_INTERVAL` | `0.1` | How often the aim is sent to others during the player's turn |
| `MIN_PULL`, `MAX_PULL` | `0.02`, `0.3` | How far the held mouse or finger is from the snail on the screen, in shares of its height: closer than `MIN_PULL` cancels when let go, `MAX_PULL` is full power |
| `AIM_SHOW_GRACE`, `AIM_SMOOTHING` | `0.4`, `15` | Another snail's crosshair and power show while its aim keeps arriving (none for this long hides them), eased toward each update |
| `CROSSHAIR_DISTANCE`, `CROSSHAIR_SIZE`, `CROSSHAIR_IMAGE` | `9`, `3`, the studio's crosshair | The angle marker: studs from the snail's middle, its size in studs, its picture |
| `POWER_DOTS`, `POWER_COLORS`, `POWER_DOT_SIZE` | `32`, yellow to red, `{ 0.5, 2.1 }` | The power circles, overlapping into a smooth trail (round on-top billboards in `Workspace.Ume.Combat.AimPower`, drawn over the arena like the crosshair) from the muzzle out: how many, their colours and sizes in studs, first to last |
| `BAR_FILL` | `0.744` | The share of the power and stamina bars' picture its fill covers (the rest is its empty end), so a full bar cuts its gradient there and the power handle stops there |
| `TARGET_COLOR` | red | The homing target marker |
| `TARGET_HINTS` | `Pick`, `Shoot` | The slider's text with a homing missile: before its target is picked, then until the aim starts |
| `STICK_DEADZONE` | `0.3` | How far the right stick leans to aim |
| `AIMBOT_EASE` | `0.4` | With an admin's aim guide on, how long a right click's lock-on takes to ease the aim onto the guide, in seconds |

## In the place

Puts the crosshair (`AimCrosshair`, a part with a stud-sized BillboardGui holding the crosshair picture), the power
circles (`AimPower`, a folder of parts `Dot1`…, each with a round stud-sized BillboardGui) and the target marker in
`Workspace.Ume.Combat`. Binds the CAS action `MatchHud_Slots` while the loadout bar shows. The Results screen hides
**Rematch** after the tutorial match.
