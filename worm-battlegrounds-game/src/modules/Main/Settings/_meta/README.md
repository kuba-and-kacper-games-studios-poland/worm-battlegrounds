# Settings

The player's settings: three volumes, `Master` (100 by default), `Music` and `SoundEffects` (both 50), each 0 to 100, and the switches a game adds (a boolean default: on or off). They are saved, the server and the client both read them, and the client changes them through one checked remote. The client sets each volume's sound groups to its value over 100, times `Master`'s over 100 (`Master` the `Master` group, where sounds with no group play; `Music` the `Music` group; `SoundEffects` the `SFX` and `UI` groups), when the settings arrive and whenever one changes: Master 50 and Music 50 play the music at 0.25. It draws them in the `Settings` widget (ume-gui's `System/Settings`): a heading per group and a row per setting in the group's colours, a volume between two chevrons that step it by 10, or a switch, green with On or red with Off, that flips it. It is exposed as `I.PlayerSettings`, since `I.Settings` holds every module's `Settings.lua`.

| | |
| --- | --- |
| Folder | `src/modules/Main/Settings` |
| Runs on | Server, Client |
| Exposes | `I.PlayerSettings` (server, client) |
| Uses | `I.Player`, `I.G_Player`, `I.Replicator`, `I.Network`, `I.Sound`, `I.Topic` (`WidgetManager_Opened`), `I.UserInterface`, `I.Interact`, `I.Platform`, `I.Env` |
| Saves | `Profile.Settings` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Profile template, the replicator folder, `Settings_Set`, `I.PlayerSettings` |
| `Client.lua` | `I.PlayerSettings`: reads the replicator, asks the server to change a setting and shows it at once; sets the sound groups' volumes and redraws the window when the replicator changes |
| `Settings.lua` | The groups and settings with their defaults, and the window's looks |
| `Scripts/Client/SettingsGui.lua` | The settings window: its headings and rows, the steppers and switches, its screen scale |
| `_meta/_types.lua` | `Settings_Section`, `Settings_Setting` |

## API

### Server: `I.PlayerSettings`

| Function | Returns | What it does |
| --- | --- | --- |
| `Set(player, settingName: string, value: boolean \| number)` | `boolean` | Turns a switch on or off, or sets a volume, saves it and writes the replicator; `false` with a warn for an unknown setting, a value of the other kind, or a volume that isn't a whole number from 0 to `VOLUME_MAX` |
| `Get(player, settingName: string)` | `boolean \| number` | Whether a switch is on, or a volume (0 to 100): the saved value, else its default; `false` for a player who isn't valid, and with a warn for an unknown setting |

### Client: `I.PlayerSettings`

| Function | Returns | What it does |
| --- | --- | --- |
| `Set(settingName: string, value: boolean \| number)` | | Asks the server to change a setting, and writes it into the replicator folder at once (the server's value replaces it when it arrives), so the window and the volume follow without the round trip |
| `Get(settingName: string)` | `boolean \| number` | Whether a switch is on, or a volume, from the replicator; its default before the server sent it; `false` with a warn for an unknown setting |

## Usage

```lua
-- Server: a volume, 0 to 100
local music: number = I.PlayerSettings.Get(player, "Music")

-- Client: a switch the game added to SETTINGS (a boolean Default)
I.PlayerSettings.Set("ShowTips", not I.PlayerSettings.Get("ShowTips"))

-- Client: the music at 70 (its sound group plays at 0.7, with Master at 100)
I.PlayerSettings.Set("Music", 70)

-- Client: open the window
I.WidgetManager.Open("Settings")
```

## Network

### Server

**Receive: RemoteEvents**

- `Settings_Set @ (player: Player, settingName: string, value: boolean | number)`: runs `Set`

### Client

**Send: RemoteEvents**

- `Settings_Set @ (settingName: string, value: boolean | number)`: when the player presses a switch or a volume's chevron

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Settings.<Setting>` | Each setting's value, starting at its default |
| Replicator `Settings` | `<Setting>` | Each setting's value; the volumes are set again and the window redraws when one changes |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `SECTIONS` | `Sound` (purple) | The groups: heading `Text`, `LayoutOrder`, `Colors` (light, dark: the heading's gradient, the rows' outline and tint, a volume box's outline) |
| `SETTINGS` | `Master` (`Default = 100`, `SoundGroups = { "Master" }`), `Music` (`Default = 50`, `SoundGroups = { "Music" }`) and `SoundEffects` (`Default = 50`, `SoundGroups = { "SFX", "UI" }`) in Sound; the game's switches `DamageNumbers` and `CameraFollowsShot` (`Default = true`) in Gameplay | Every setting: its `Section`, name `Text`, `Detail` (`""` centres the name in its row), `LayoutOrder` in its group, `Default`. A boolean `Default` is a switch; a number is a volume, whose `SoundGroups` play at its value over 100, times `MASTER_VOLUME`'s over 100. A new key is a new setting: the profile template, the replicator and the window follow it |
| `VOLUME_MAX`, `VOLUME_STEP` | `100`, `10` | A volume's highest value, and how much one chevron press changes it |
| `MASTER_VOLUME` | `"Master"` | The volume every other volume is multiplied by |
| `GUI_NAME` | `"Settings"` | The widget the window is |
| `DESIGN_HEIGHT` | `1080` | Screen height the window is laid out for; `S_ScreenScale` is the screen's height over it |
| `SMALL_SCREEN`, `MOBILE_BOOST` | `500`, `1.3` | Mobile screens shorter than this scale the window up by the boost |
| `ACCENT_TRANSPARENCY` | `0.5` | A row's outline transparency, in its group's dark colour |
| `SWITCH_LOOKS` | `[true]` green, `[false]` red | The switch's gradient, bottom to top, on both its faces (`Background_Front`, `Background_Back`): ume-gui's `System/_Primitives_ButtonsColors` Accept and Cancel |
| `SWITCH_TEXTS` | `[true] = "On"`, `[false] = "Off"` | The switch's word; a volume at 0 shows `[false]` |
| `CHEVRON_LOOKS` | `[true]` blue, `[false]` grey | A volume's chevrons, the same way: Blue while the volume can step that way, Gray (and not `Active`) at the end it has reached |

## In the place

| What | Where |
| --- | --- |
| The settings window | `StarterGui.Settings`, an export of ume-gui's `System/Settings`, or the game's own copy (its README → Integration) |

The gear button TopBar_Controller adds to the top bar opens and closes the window (`I.WidgetManager.Toggle`).
