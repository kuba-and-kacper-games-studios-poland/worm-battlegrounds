# MatchHud

The match screen and its input. It shows whose turn it is, the timer and the wind, the stamina bar, the kill feed, the
loadout bar (the Bazooka and the player's items, with uses and cooldowns), touch walk and jump buttons, the waiting,
drop and knocked-out blocks, and the Results screen. Aiming is a drag back from the worm with mouse or touch (the
direction is the angle, the length the power), or the right stick and RT on a gamepad; letting go fires. Number keys 1
to 6, LB and RB pick a slot. It adds **Leave** and **Music** to the top bar. The HUD and those buttons show while the
player is in the match (the `InMatch` Player attribute); on the Studio map, going back to the lobby hides them and
closes Results.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/MatchHud` |
| Runs on | Client · Match map, Studio map |
| Uses | `I.Match`, `I.Worms`, `I.WormControl`, `I.G_Arsenal`, `I.G_Combat`, `I.Replicator`, `I.TopBar`, `I.PlayerSettings`, `I.WidgetManager`, `I.Haptic`, `ContextActionService` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Turns the gui on while the player is in a match (and the `HIDDEN_IN_MATCH` guis off), and starts the handlers |
| `Scripts/Client/Turn.lua` | Banner, timer, wind, stamina |
| `Scripts/Client/Panels.lua` | The waiting, drop and knocked-out blocks; which bars show |
| `Scripts/Client/LoadoutBar.lua` | The loadout bar and slot keys; utilities are used as soon as they're picked on the player's turn. A weapon with no icon picture shows its 3D model in its box instead (`I.G_Arsenal.GetModel`, in a ViewportFrame `S_Model` over `S_Icon`) |
| `Scripts/Client/Aim.lua` | Drag and pad aiming, the aim dots, firing (with the `Combat_Fire` haptic tick), homing targets, detonating; the dots of another worm's aim (a player's or a bot's) while it aims |
| `Scripts/Client/KillFeed.lua` | Knockout lines |
| `Scripts/Client/TouchControls.lua` | Walk and jump buttons on touch screens |
| `Scripts/Client/Results.lua` | The Results screen, rematch votes |
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
| `HIDDEN_IN_MATCH` | `{ "Currency" }` | Guis the framework keeps on (`UserInterface_PreventHiding`) that are hidden while the player is in a match; the currency bar sits where the turn banner and timer go |
| `SELECTED_COLOR`, `SELECTED_TRANSPARENCY`, `TILE_COLOR`, `TILE_TRANSPARENCY` | `(40, 140, 255)`, `0.2`, `(0, 0, 0)`, `0.7` | The selected loadout slot's fill (its `Body`), and the others' |
| `LEAVE_TEXT`, `MUSIC_TEXT`, `LEAVE_QUESTION` | | The top bar buttons and the leave confirmation |
| `SLOT_KEYS` | One … Six | Keys that pick slots 1 to 6 (the Bazooka first) |
| `MODEL_FOV`, `MODEL_VIEW_DIRECTION`, `MODEL_PADDING` | `30`, `0.3, 0.25, 1`, `1.15` | A box's weapon model: the camera's field of view, the direction it looks from (the muzzle points right), and the room around the model's longest side |
| `FEED_LINES`, `FEED_SECONDS` | `4`, `6` | Kill feed length and how long a line stays |
| `MIN_DRAG`, `MAX_DRAG` | `24`, `260` | Drag length in pixels for no power and full power |
| `AIM_SEND_INTERVAL` | `0.1` | How often the aim is sent to others |
| `AIM_SHOW_GRACE`, `AIM_SMOOTHING` | `0.4`, `15` | Another worm's aim dots show while its aim keeps arriving (none for this long hides them), eased toward each update |
| `AIM_LINE_SECONDS`, `AIM_LINE_DOTS`, `AIM_DOT_SIZE`, `AIM_DOT_COLOR` | `0.6`, `10`, `0.35`, white | The aim dots |
| `TARGET_COLOR` | red | The homing target marker |
| `STICK_DEADZONE`, `PAD_POWER_SPEED` | `0.3`, `0.8` | Gamepad aiming |

## In the place

Puts the aim dots and the target marker in `Workspace.Ume.Combat`. Binds the CAS action `MatchHud_Slots` while the
loadout bar shows. The Results screen hides **Rematch** after the tutorial match.
