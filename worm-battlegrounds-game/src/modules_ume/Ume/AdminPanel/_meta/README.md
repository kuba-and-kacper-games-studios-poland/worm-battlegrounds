# AdminPanel

The game's admin tools, two windows opened from the keyboard. Each combination opens its window, or closes it when it is open:

- **The command bar**, for players at `OPEN_PERMISSION_LEVEL` (1, any member of the `Permissions.Groups` groups) or above: **Ctrl** + **[** (`COMMAND_BAR_KEYS`), also while typing in the bar. Modules register commands (aliases, variants, typed arguments with autocomplete dictionaries, a permission level) from `Scripts/AdminPanel/CommandBar/*.lua`. Each player sees and runs only the commands their permission level allows. Commands run on the client, the server, or every server at once. `/cmd` in chat still opens the bar directly: the server makes that chat command, so the message never shows in chat.
- **The dashboard**, for players at `Permissions.DashboardLevel` (255) or above: **Ctrl** + **]** (`DASHBOARD_KEYS`), outside any text box. It opens where it was left, on the players at first.
  - **Panels:** modules register panels from `Scripts/AdminPanel/Dashboard/Server.lua`. A panel is either a page on the dashboard's rail or sections on every player's page.
  - **Blocks:** each section holds blocks (buttons, switches, sliders, inputs, choices, info lines, item gives). The server builds every block's values for the viewer, and runs a block's callback after checking the viewer may use it.

The framework's loader runs the `Scripts/AdminPanel/CommandBar` and `Scripts/AdminPanel/Dashboard` scripts of every module after all modules have started: `_init`, then `_start` (`docs/architecture/startup-order.md`).

**Permissions.**
- **A player's level:** the higher of their rank in the `Permissions.Groups` groups and their `CustomLevels` entry, clamped to 0–255.
- **Commands:** a variant without its own `PermissionLevel` takes its parent's. The bar opens from `OPEN_PERMISSION_LEVEL` (1) up, checked on the client for the keys and on the server for `/cmd`. Below that level the server sends no commands or dictionaries and runs no command, and it still checks every command's own level.
- **The dashboard:** every dashboard remote checks `DashboardLevel`, and each panel's own `PermissionLevel` (default 255).
- **Global commands** need `GlobalLevel`.

**Checks on the server.** Server and global commands are checked again on the server:
- the permission level (at least `OPEN_PERMISSION_LEVEL`, and the command's own), before the arguments are converted;
- every required argument, and an exact entry for each `requireDict` argument whose dictionary the server has;
- a rate: each player may run a server command once per `SERVER_DEBOUNCE_DURATION`, publish a global command once per `GLOBAL_DEBOUNCE_DURATION`, and run a dashboard block once per `DASHBOARD_RUN_DEBOUNCE`.

The bar also checks server arguments against the Network limits first, so it can name the argument that is too large.

**Global commands.** Studio sessions use their own topic (`GLOBAL_TOPIC` + `_Studio`), so they never reach live servers. Subscribing retries with a growing delay (up to `GLOBAL_SUBSCRIBE_ATTEMPTS` tries). A failed publish warns, and an output longer than `GLOBAL_MESSAGE_SIZE_LIMIT` comes back as a short marker.

**History.** The client sends its new command history:
- **When:** `COMMAND_HISTORY_SEND_DELAY` seconds after a command (once for several commands), and when the bar closes.
- **How much:** at most `COMMAND_HISTORY_LIMIT` entries, each up to `COMMAND_HISTORY_MAX_COMMAND_LENGTH` characters.
- **Whose:** only from players at `COMMAND_HISTORY_SAVE_PERMISSION_LEVEL` or above.

**Windows.** The command bar and the dashboard are windows:
- their header drags them, kept `SCREEN_MARGIN` inside the screen;
- on Desktop their edges and corners resize them, down to `COMMAND_BAR_MIN_SIZE` / `DASHBOARD_MIN_SIZE`, and the edge or corner under the mouse glows.

Both can be open together. A dashboard block's result shows as a Roblox notification and as a line in the command bar's output.

| | |
| --- | --- |
| Folder | `src/modules_ume/Ume/AdminPanel` |
| Runs on | Global (the command registry, both sides), Server (the dashboard's panels, the `/cmd` chat command), Client (the bar, the dashboard, their keys) |
| Exposes | `I.AdminPanel` (both sides), `I.AdminPanel_CommandBar` (both sides), `I.AdminPanel_Dashboard` (server) |
| Uses | `I.Network`, `I.Topic` (global commands over MessagingService), `I.Player`, `I.Debounce`, `I.World`, `I.Validate`, `I.UserInterface`, `I.Color`, `I.Number`, `I.Date`, `I.Table`, `src/global_data/AdminPanel/Permissions.lua`, `src/global_data/Group/Groups.lua` |
| Saves | `Profile.AdminPanel.CommandHistory` (players at or above `COMMAND_HISTORY_SAVE_PERMISSION_LEVEL`) |

## Files

| File | What it controls |
| --- | --- |
| `Global.lua` | The profile template, the command bar's registry and server remotes, assigns `I.AdminPanel_CommandBar` |
| `Server.lua` | The dashboard's server side and the `/cmd` chat command, assigns `I.AdminPanel` and `I.AdminPanel_Dashboard` on the server |
| `Client.lua` | Starts the command bar, binds the dashboard and both windows' keys once the player has loaded, assigns `I.AdminPanel` on the client |
| `Settings.lua` | In three groups: the Admin Panel (permission levels, the guis' names, the windows' keys, sizes and edge glow), the Dashboard (its layout and colours), the Command Bar (commands, global commands, the chat command, history, messages, output, suggestions, cursor and colours) |
| `Scripts/Global/Permissions.lua` | `GetPermissionLevel`, `CanOpenDashboard` |
| `Scripts/Client/Window.lua` | Drags and resizes a panel by its header and handles, with the edge glow; one state per window |
| `Scripts/CommandBar/Global/Register.lua` | `Register` / `Unregister`: validates a setup table and stores the command |
| `Scripts/CommandBar/Global/Run.lua` | Runs a command: parses arguments, checks permission and debounce, calls the callback |
| `Scripts/CommandBar/Global/Dictionary.lua` | Autocomplete dictionaries: `SetDictionary`, `UpdateDictionary`, dictionaries bound to a player |
| `Scripts/CommandBar/Global/Methods.lua` | `GetData`, the commands and dictionaries a player may see |
| `Scripts/CommandBar/Global/Messaging.lua` | Global commands: publishes them to every server and sends each server's output back |
| `Scripts/CommandBar/Global/History.lua` | Each player's command history |
| `Scripts/CommandBar/Client/Bootstrap.lua` | Finds the bar's gui, checks the settings, loads the history |
| `Scripts/CommandBar/Server/ChatCommand.lua` | The `/cmd` chat command (`TOGGLE_COMMAND`), made on the server so its message never reaches the chat; tells the sender's client to open or close the bar when they may |
| `Scripts/CommandBar/Client/Connections.lua` | The bar's input, buttons, cursor, and refreshing commands and dictionaries when the server's version attributes change |
| `Scripts/CommandBar/Client/Control.lua` | Opens and closes the bar, runs the typed command, prints to the output panel |
| `Scripts/CommandBar/Client/Input.lua` | Parses the typed text, highlights each argument, marks what is invalid |
| `Scripts/CommandBar/Client/Suggestions.lua` | The suggestion list, moving through it, autocomplete |
| `Scripts/CommandBar/Client/Cursor.lua`, `Selection.lua` | The bar's custom cursor and selection highlight |
| `Scripts/CommandBar/Client/Data.lua` | The local copy of commands and dictionaries |
| `Scripts/CommandBar/Client/UIEmitterShowcase.lua` | A gui that shows UIEmitter presets, opened from the library tests |
| `Scripts/CommandBar/Helpers/Defaults.lua` | The framework's own commands (`ume`, `s_ume`, `kick`, `kill`, `tp`, `morph`) |
| `Scripts/CommandBar/Helpers/Utils.lua`, `Client_Utils.lua` | Parsing, formatting and output helpers |
| `Scripts/CommandBar/Helpers/LibraryTests.lua` | Library checks run from a command |
| `Scripts/Dashboard/Server/Registry.lua` | `Register`, `Unregister`, `Refresh`; the pages a viewer may see, resolved for them |
| `Scripts/Dashboard/Server/Run.lua` | Runs a pressed block's callback after the checks, with its section's values |
| `Scripts/Dashboard/Server/Defaults.lua` | The built-in Player panel (below) |
| `Scripts/Dashboard/Client/Rail.lua` | The dashboard: the rail, the search page, the player list, fetching pages, running blocks, refreshing on changes |
| `Scripts/Dashboard/Client/Panels.lua` | Builds a page's header, sections and blocks from the gui's prefabs, keeps each block's value |

## API

### Both sides: `I.AdminPanel`

| Function | Returns | What it does |
| --- | --- | --- |
| `GetPermissionLevel(player: Player)` | `number` | The player's admin level, 0–255. The client keeps its own level after the first lookup. |
| `CanOpenDashboard(player: Player)` | `boolean` | Whether the level reaches `Permissions.DashboardLevel`. |

The client's `I.AdminPanel` also has:

| Function | Returns | What it does |
| --- | --- | --- |
| `OpenCommandBar()` | | Opens the command bar when it is on and closed. |
| `OpenDashboard(page: string?)` | | Opens the dashboard on `"Players"`, `"Modules"`, or where it was left, for a player who may, once it is on (bound when the player has loaded). |
| `CloseAll()` | | Closes the bar and the dashboard, each when it is on. |

### Both sides: `I.AdminPanel_CommandBar`

| Function | Returns | What it does |
| --- | --- | --- |
| `Register(commandIdentifier: string, setupTable: AdminPanel_CommandBar_CommandSetupTable)` | `boolean`, `string?` | Registers a command on this side. Returns `false` and the reason when the setup table is invalid. |
| `Unregister(commandUUID: string)` | | Removes a command and its connections. |
| `RunCommand(invoker: Player \| number, alias: string, args: table, isGlobal: boolean?)` | `boolean`, `AdminPanel_CommandBar_Output?`, `{ any }?` | Runs a command from code, as `invoker`. |
| `SetDictionary(dictName: string, dictTable: { string }?, permissionLevel: number?, metadata: table?)` | | Sets an autocomplete dictionary; `nil` removes it. |
| `UpdateDictionary(dictName: string, addTable: { string }?, removeTable: { string }?, permissionLevel: number?, metadata: table?)` | | Adds and removes entries. |
| `GetData(dataType: string, env: string)` | `{ AdminPanel_CommandBar_CommandData_Global }` or `{ [string]: AdminPanel_CommandBar_DictionaryEntry }` | The commands or dictionaries of one side. |

**A command's setup table** (`AdminPanel_CommandBar_CommandSetupTable`) has these fields:
- `Aliases`.
- `Args`, optional: each is `{ name, types, optional?, dict?, dictNegate?, requireDict? }`. A list typed in the bar (`{a, b}`) only matches the `table` type; every other type takes one word. A `Vector3`, `Vector2` or `Color` with a number that isn't finite (`v3(nan,0,0)`, `rgb(1e999,0,0)`) doesn't convert.
- `Variants`: nested setup tables, which are subcommands.
- `Callback`. It returns `success, message`, and messages use the output's colour tags (`$|cr$|text#|`).
- `PermissionLevel`. A variant without one takes its parent's; the base defaults to 255.
- The global options: `EnableGlobally`, `GlobalOutput`, `Callback_GlobalReturn`, `GlobalReturnArgsCount` (default `0`) and `PassInvoker`.

### Server: `I.AdminPanel_Dashboard`

| Function | Returns | What it does |
| --- | --- | --- |
| `Register(panelId: string, setup: AdminPanel_DashboardPanelSetup)` | `boolean` | Adds a panel; registering an id again replaces it. Returns `false` (and warns) for an unknown `Scope`, no `Sections`, or the id `Player`. |
| `Unregister(panelId: string)` | | Removes a panel. |
| `Refresh(panelId: string)` | | Tells every admin's dashboard that the panel's page changed; an open one fetches it again. |

**A panel** (`AdminPanel_DashboardPanelSetup`):

| Field | What |
| --- | --- |
| `Name`, `Description?` | What the rail, the search and the page header show |
| `Scope` | `"Game"`: a page on the rail. `"Player"`: sections added to every player's page, in the order panels were registered |
| `PermissionLevel?` | Level needed to see and use it (default 255) |
| `Icon?`, `Color?` | The rail icon: an image, or a swatch with the name's initial |
| `Stats?` | A rich-text line under the page's name, or a function `(target) -> string` |
| `Sections` | `{ Title, Blocks }` each |

**A block** (`AdminPanel_DashboardBlockSetup`) has a `Type`, an `Id` (unique in its section) and a `Text`, and by type:

| Type | Fields | Runs |
| --- | --- | --- |
| `Button` | `Danger?` (red label) | On a press |
| `Toggle` | `Value?` (boolean) | On each switch |
| `Slider` | `Value?`, `Min`, `Max`, `Step?` (1), `Format?` (`"×{}"`) | When let go |
| `Input` | `Value?`, `Placeholder?`, `Button?` ("Send") | On its button or Enter |
| `Choice` | `Options`, `Value?` | On a pick |
| `Info` | `Value` | Never |
| `Give` | `Items` (`{ Name, Icon?, Color? }`) | On Give, once an item is picked; its value is `{ Item, Amount }` |

- **Values:** `Value`, `Options`, `Items` and `Stats` may be functions. The server calls them with the page's player (nil on a Game page) each time the page is fetched.
- **What a block shows:** the server's `Value` when it sends one, else what the admin last picked or typed in it.
- **Callbacks:** a block runs only when it has a `Callback(admin, values, target)`. `values` holds every block of its section by `Id`, and `target` is the page's player (nil on a Game page). It returns `success, message`.
- **What the server keeps:** each value only in its block's shape, else nil: a Toggle's boolean, a Slider's number on its `Step` between `Min` and `Max`, an Input's text, one of a Choice's `Options`, and a Give block's `{ Item, Amount }` with one of its `Items` and a whole `Amount` of at least 1. Buttons and Info lines send nothing.

**The built-in Player panel** (`AdminPanel_Player`, `Scripts/Dashboard/Server/Defaults.lua`) starts every player's page:

| Section | Blocks |
| --- | --- |
| Player | Info: user id, account age, admin level |
| Actions | Respawn, Kill, Bring (to the admin), Go to (the admin to them) |
| Kick | Reason (an Input whose button kicks the player with it) |

## Usage

```lua
-- Scripts/AdminPanel/CommandBar/Server.lua, in Init
I.AdminPanel_CommandBar.Register("Currency_Server", {
	Aliases = { "currency" },
	PermissionLevel = 200,
	Variants = {
		{
			Aliases = { "add" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "amount", types = { "BigNum" } },
			},
			Callback = add,
		},
	},
})
I.AdminPanel_CommandBar.SetDictionary("Currency_CurrencyNames", { "Cash" }, 255)

-- Scripts/AdminPanel/Dashboard/Server.lua, in Init
I.AdminPanel_Dashboard.Register("Weather", {
	Name = "Weather",
	Scope = "Game",
	Sections = {
		{ Title = "Weather", Blocks = {
			{ Type = "Choice", Id = "Pick", Text = "Weather", Options = getWeatherIds },
			{ Type = "Button", Id = "Start", Text = "Start", Callback = startWeather },
		} },
	},
})
```

## Network

### Server

**Receive: RemoteEvents**

- `_AdminPanel_CommandBar_UpdateCommandHistory @ (player: Player, commandHistory: table)`

**Receive: RemoteFunctions**

- `_AdminPanel_CommandBar_Run @ (player: Player, alias: string, args: table)`: runs a server command after the permission and debounce checks.
- `_AdminPanel_CommandBar_RunGlobal @ (player: Player, alias: string, args: table)`: publishes a global command to every server, after the permission check and once per `GLOBAL_DEBOUNCE_DURATION` per player.
- `_AdminPanel_CommandBar_GetCommands @ (player: Player)`, `_AdminPanel_CommandBar_GetDictionaries @ (player: Player)`: what this player may see (commands cached per permission level); empty below `OPEN_PERMISSION_LEVEL`.
- `_AdminPanel_CommandBar_GetCommandHistory @ (player: Player)`
- `_AdminPanel_Dashboard_GetPages @ (player: Player)`: the Game pages this player may see (`{ Id, Name, Description, Icon?, Color? }`); empty below `DashboardLevel`.
- `_AdminPanel_Dashboard_GetPage @ (player: Player, pageId: string, targetUserId: number?)`: one page resolved for the player, or (`pageId` `"Player"`) the page of the player with `targetUserId`; nil when not allowed.
- `_AdminPanel_Dashboard_Run @ (player: Player, panelId: string, sectionIndex: number, blockId: string, values: table, targetUserId: number?)`: runs a block's callback; returns `success, message`.

**Send: RemoteEvents**

- `_AdminPanel_CommandBar_PrintToOutput @ (player: Player, success: boolean, commandAlias: string, output: string | table)`: a global command's output, from any server.
- `_AdminPanel_Dashboard_PageChanged @ (player: Player, pageId: string)`: to every player who may open the dashboard, when `Refresh` (or `Register` / `Unregister`) changes a page.
- `_AdminPanel_CommandBar_ChatCommand @ (player: Player)`: when the player sends `/cmd` in chat and is at `OPEN_PERMISSION_LEVEL` or above.

### Client

**Receive: RemoteEvents**

- `_AdminPanel_CommandBar_PrintToOutput @ (success: boolean, commandAlias: string, output: string | table)`
- `_AdminPanel_CommandBar_ChatCommand @ ()`: opens or closes the command bar.
- `_AdminPanel_Dashboard_PageChanged @ (pageId: string)`: an open dashboard showing that page builds it again.

**Receive: RemoteFunctions**

- `_AdminPanel_CommandBar_GetCommandHistory @ ()`

**Send: RemoteEvents**

- `_AdminPanel_CommandBar_UpdateCommandHistory @ (commandHistory: table)`

**Send: RemoteFunctions**

- `_AdminPanel_CommandBar_Run @ (alias: string, args: table)`, `_AdminPanel_CommandBar_RunGlobal @ (alias: string, args: table)`, `_AdminPanel_CommandBar_GetCommands @ ()`, `_AdminPanel_CommandBar_GetDictionaries @ ()`, `_AdminPanel_CommandBar_GetCommandHistory @ ()`
- `_AdminPanel_Dashboard_GetPages @ ()`, `_AdminPanel_Dashboard_GetPage @ (pageId: string, targetUserId: number?)`, `_AdminPanel_Dashboard_Run @ (panelId: string, sectionIndex: number, blockId: string, values: table, targetUserId: number?)`

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `AdminPanel.CommandHistory` | The last `COMMAND_HISTORY_LIMIT` commands, each cut to `COMMAND_HISTORY_MAX_COMMAND_LENGTH` |
| AdminPanel module instance | `AdminPanel_CommandsVersion_<Env>`, `AdminPanel_DictionariesVersion_<Env>` attributes | Set to a new random number on every change; clients refresh their copy when it changes |
| `src/global_data/AdminPanel/Permissions.lua` | `Groups`, `GlobalLevel`, `DashboardLevel`, `CustomLevels` | Which groups give a rank, the level global commands need, the level the dashboard needs (255), per-user levels |

## Settings

In the order `Settings.lua` groups them.

### Admin Panel

| Key | Default | What |
| --- | --- | --- |
| `PERMISSION_LEVEL_RANGE` | `0`–`255` | Range every permission level is clamped to: players' levels and commands' levels |
| `OPEN_PERMISSION_LEVEL` | `1` | Level needed to open the bar, and for the server to send commands and dictionaries or run a command; 1 is any member of the `Permissions.Groups` groups (commands are still filtered by level) |
| `COMMAND_HISTORY_SAVE_PERMISSION_LEVEL` | `200` | Level from which history is saved |
| `COMMAND_BAR_GUI`, `DASHBOARD_GUI` | `"CommandBar"`, `"Dashboard"` | The ScreenGuis the windows are drawn on; a window whose gui isn't exported is turned off (with a Studio warning) |
| `COMMAND_BAR_KEYS`, `DASHBOARD_KEYS` | `LeftControl`, `LeftBracket`; `LeftControl`, `RightBracket` | Keys that open or close each window: the last pressed while the others are held |
| `SCREEN_MARGIN` | `8` | Pixels kept between the windows and the screen's edges |
| `COMMAND_BAR_MIN_SIZE`, `DASHBOARD_MIN_SIZE` | 360 × 150, 600 × 360 | The smallest size a resize leaves each window |
| `GLOW_SEGMENT_LENGTH`, `GLOW_TWEEN` | `60`, 0.1 s `Quad` `Out` | The edge glow's longest bar and its fade |

### Dashboard

| Key | Default | What |
| --- | --- | --- |
| `DASHBOARD_LIST_WIDTH` | `220` | Width of the player list beside the rail |
| `DASHBOARD_RUN_DEBOUNCE` | `0.2` | Seconds between one player's dashboard actions |
| `DASHBOARD_SEARCH_ICON` | an image | The rail's search icon |
| `DASHBOARD_ACCENT`, `DASHBOARD_COLORS`, `DASHBOARD_LIGHT_LUMINANCE` | white, …, `0.6` | The dashboard's accent, block and icon colours, and the luminance above which a letter is drawn dark |

### Command Bar

| Key | Default | What |
| --- | --- | --- |
| `PREFIX`, `GLOBAL_PREFIX` | `"/"`, `"!g"` | Prefixes for normal and global commands |
| `ARG_TYPES` | | Argument types a command may declare; when an argument takes several, the earlier ones are tried first |
| `SERVER_DEBOUNCE_DURATION` | `0.2` | Seconds between one player's server commands |
| `GLOBAL_TOPIC` | `"__Ume_GlobalCommand"` | MessagingService topic for global commands (`_Studio` is added in Studio) |
| `GLOBAL_DEBOUNCE_DURATION` | `2` | Seconds between one player's global commands |
| `GLOBAL_SUBSCRIBE_ATTEMPTS` | `8` | Tries to subscribe to the global topics before giving up |
| `GLOBAL_VALIDITY_PERIOD` | `30` | Seconds a global command stays valid |
| `GLOBAL_MESSAGE_SIZE_LIMIT` | `1000` | Longest global output message, in characters |
| `GLOBAL_MESSAGE_DISPLAY_DELAY` | `0.15` | Delay before a global command's returned result is shown |
| `TOGGLE_COMMAND` | `"/cmd"` | Chat command that opens the bar directly (empty turns it off) |
| `COMMAND_VISIBLE` | `true` | Show `/cmd` in chat autocomplete |
| `COMMAND_HISTORY_LIMIT`, `COMMAND_HISTORY_LIMIT_CLIENT` | `30`, `100` | History kept in the profile and on the client |
| `COMMAND_HISTORY_MAX_COMMAND_LENGTH` | `100` | Characters kept per stored command |
| `COMMAND_HISTORY_SEND_DELAY` | `5` | Seconds after a command before the new history is sent |
| `DEBUG_MESSAGES` | | Every message the bar prints (invalid input, permissions, global results) |
| `OUTPUT_LIMIT`, `SHOW_TIMESTAMP`, `OUTPUT_RICHTEXT_PARAMS` | `100`, `true`, `{}` | The output panel |
| `SUGGESTIONS_LIMIT`, `SUGGESTION_MOVE_THRESHOLD`, `SUGGESTION_MOVE_STEP`, `SUGGESTIONS_DIRECTION`, `SUGGESTIONS_ORDER` | | The suggestion list |
| `SUGGESTIONS_MATCH_WINDOWS` | `4` | Dictionary matches are collected for this many `SUGGESTIONS_LIMIT` windows; the rest are skipped |
| `CURSOR_FLICKER_SPEED`, `CURSOR_OFFSET` | `0.3`, … | The bar's cursor |
| `COLORS`, `ARGS_COLORS_AMOUNT`, `ARGS_COLORS`, `SELECTION_TEXT_COLOR`, `SELECTION_BACKGROUND_COLOR` | | The input's and output's colours: prefix, autocomplete, errors, each argument, the selection |
| `OUTPUT_DYNAMIC_COLORS`, `OUTPUT_DYNAMIC_MARK_COLORS` | | The colours an output message's colour and highlight tags pick from (`$\|cr$\|`, `$\|mc1$\|`) |
| `DEBUG_TEXT_INDEX` | `false` | Show each argument's type index after it in the input |

## In the place

| Instance | What |
| --- | --- |
| `StarterGui.CommandBar` | The bar, an export of ume-gui's `System/CommandBar` (or the game's own copy): `U_CommandBar` with its `S_` elements, `S_Header`, `ResizeHandles`, `EdgeGlow` and the three prefabs |
| `StarterGui.Dashboard` | The dashboard, an export of ume-gui's `System/Dashboard` (or the game's own copy): `U_Dashboard` › `S_Header`, `S_Body`, `S_CloseButton`, `ResizeHandles`, `EdgeGlow`, and its `PREFAB \| …` pieces |
| `TextChatService.__Ume_CommandBar_Toggle` | The `/cmd` chat command, made by the server (clients see it for autocomplete) |

## Commands

The framework's own, from `Scripts/CommandBar/Helpers/Defaults.lua`:

| Command | Side | Subcommands |
| --- | --- | --- |
| `ume` | client | `config` (`get_game_version`, `get_framework_version`, `get_placeId`, `get_mapId`), `info` (loading and execution times) |
| `s_ume` | server | `get_server_metadata`, `info`, `persistent_lobby` (`get_state`, `update_state`), `teleport` (`new_server`, `external`, `lobby`, `existing_server`), `get_player_job_id` |
| `kick`, `kill`, `tp` | server | Act on players |
| `morph` | server | `by_player`, `by_name`, `by_id`, `reset` |

## Dashboard

The built-in `AdminPanel_Player` panel (a Player panel, level 255) is above, under API.
