# MatchHud

The match screen and its input. It shows whose turn it is, the timer and the wind, the stamina bar, the kill feed, the
loadout bar (the Bazooka and the player's items, with uses and cooldowns), touch walk and jump buttons, the waiting,
drop and knocked-out blocks, and the Results screen. On PC the weapon always points from the player's snail toward the
mouse, held or not; pressing and holding sets the power by how far the mouse (or a held finger on touch) is from the
snail on the screen (`MIN_PULL` to `MAX_PULL`, shares of the screen's height), and letting go fires (closer than
`MIN_PULL` cancels); on a pad the right stick aims and
holding RT runs the power bar up and down (Combat's `CHARGE_SECONDS` each way) until it's let go. The aim shows as an
angle marker, a crosshair `CROSSHAIR_DISTANCE` studs from the snail, and a power bar, a row of circles from the held
weapon's muzzle (Combat's `GetMuzzle`) to it that lights up yellow to red; both keep their size on the screen at any
zoom, sized for MatchCamera's `DISTANCE`. The held weapon turns with the aim on this screen at once (Combat's `SetAim`).
Nothing fires by itself: a turn that runs out mid-drag drops the aim. Every player sees the active snail's angle marker
and power. Number keys 1 to 6, LB and RB pick a slot. It
adds **Leave game** and **Mute music** to the top bar. The HUD and those buttons show while the player is in the match (the
`InMatch` Player attribute); on the Studio map, going back to the lobby hides them and closes Results.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/MatchHud` |
| Runs on | Client · Match map, Studio map |
| Uses | `I.Match`, `I.Snails`, `I.SnailControl`, `I.G_Arsenal`, `I.G_Combat`, `I.Replicator`, `I.TopBar`, `I.PlayerSettings`, `I.WidgetManager`, `I.Haptic`, `I.Sound`, `ContextActionService` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Turns the gui on while the player is in a match (and the `HIDDEN_IN_MATCH` guis off), and starts the handlers |
| `Scripts/Client/Turn.lua` | Banner ("Your turn!" in the gui's colour, or on other snails' turns "Bax's turn" in that snail's `Color`, from its `DisplayName`), the wait under it on other snails' turns ("You're next!" / "Your turn in N turns", from Match's `TurnOrder`; hidden once the player's snail is out), timer (blank while a shot flies and settles), wind (its strength, the arrow turned its way), stamina ("Stamina 70%", the gui's own label before the share; `U_Stamina` sits inside `U_LoadoutBar`, found recursively); sounds: `Turn_Yours` when the player's turn starts and `Turn_Start` on others', `Turn_Tick` each second of the player's last `TICK_SOUND_FROM`, `Match_SuddenDeath` when sudden death starts |
| `Scripts/Client/Panels.lua` | The waiting, drop and knocked-out blocks; which bars show |
| `Scripts/Client/LoadoutBar.lua` | The loadout bar and slot keys; utilities are used as soon as they're picked on the player's turn. A weapon with no icon picture shows its 3D model in its box instead (`I.G_Arsenal.GetModel`, in a ViewportFrame `S_Model` over `S_Icon`) |
| `Scripts/Client/Aim.lua` | The crosshair and charging (mouse, touch, pad), the power cone, firing (with the `Combat_Fire` haptic tick), homing targets, detonating; another snail's crosshair and power (a player's or a bot's) while it aims; on the player's turn the power reads "Power 60%" (the gui's own label before the share) and the angle "45°" beside it; with a homing missile it reads `TARGET_HINTS` ("Click on a target", then "Shoot!" until the aim starts) (`U_Power` sits inside `U_LoadoutBar`, found recursively). shortcut: the crosshair is drawn in code from frames until the kit has a picture for it |
| `Scripts/Client/KillFeed.lua` | Knockout lines; a line too long for the feed at its design size (`TextService:GetTextBoundsAsync`) gets two lines' height instead of shrinking |
| `Scripts/Client/TouchControls.lua` | Walk and jump buttons on touch screens |
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
| `TICK_SOUND_FROM` | `5` | The timer ticks aloud each second from this many seconds left of the player's own turn |
| `HIDDEN_IN_MATCH` | `{ "Currency" }` | Guis the framework keeps on (`UserInterface_PreventHiding`) that are hidden while the player is in a match; the currency bar sits where the turn banner and timer go |
| `SELECTED_COLOR`, `SELECTED_TRANSPARENCY`, `TILE_COLOR`, `TILE_TRANSPARENCY` | `(40, 140, 255)`, `0.2`, `(0, 0, 0)`, `0.7` | The selected loadout slot's fill (its `Body`), and the others' |
| `LEAVE_TEXT`, `MUSIC_TEXT`, `LEAVE_QUESTION` | | The top bar buttons and the leave confirmation |
| `SLOT_KEYS` | One … Six | Keys that pick slots 1 to 6 (the Bazooka first) |
| `MODEL_FOV`, `MODEL_VIEW_DIRECTION`, `MODEL_PADDING` | `30`, `0.3, 0.25, 1`, `1.15` | A box's weapon model: the camera's field of view, the direction it looks from (the muzzle points right), and the room around the model's longest side |
| `FEED_LINES`, `FEED_SECONDS` | `4`, `6` | Kill feed length and how long a line stays |
| `AIM_SEND_INTERVAL` | `0.1` | How often the aim is sent to others during the player's turn |
| `MIN_PULL`, `MAX_PULL` | `0.02`, `0.3` | How far the held mouse or finger is from the snail on the screen, in shares of its height: closer than `MIN_PULL` cancels when let go, `MAX_PULL` is full power |
| `AIM_SHOW_GRACE`, `AIM_SMOOTHING` | `0.4`, `15` | Another snail's crosshair and power show while its aim keeps arriving (none for this long hides them), eased toward each update |
| `CROSSHAIR_DISTANCE`, `CROSSHAIR_SIZE`, `CROSSHAIR_COLOR` | `9`, `3`, light green | The angle marker, a crosshair: studs from the snail's middle, its size in studs, its colour |
| `POWER_DOTS`, `POWER_COLORS`, `POWER_DOT_SIZE` | `32`, yellow to red, `{ 0.5, 2.1 }` (the last fills the crosshair's ring) | The power circles, overlapping into a smooth trail (round on-top billboards in `Workspace.Ume.Combat.AimPower`, drawn over the arena like the crosshair) from the muzzle out: how many, their colours and sizes in studs, first to last |
| `TARGET_COLOR` | red | The homing target marker |
| `TARGET_HINTS` | `Pick`, `Shoot` | The power bar's text with a homing missile: before its target is picked, then until the aim starts |
| `STICK_DEADZONE` | `0.3` | How far the right stick leans to aim |

## In the place

Puts the crosshair (`AimCrosshair`, a part with a stud-sized BillboardGui), the power circles (`AimPower`, a folder of
parts `Dot1`…, each with a round stud-sized BillboardGui) and the target marker in `Workspace.Ume.Combat`. Binds the CAS action `MatchHud_Slots` while the
loadout bar shows. The Results screen hides **Rematch** after the tutorial match.
