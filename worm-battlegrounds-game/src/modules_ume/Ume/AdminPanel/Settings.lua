--- @class AdminPanel_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Admin Panel

	--%%%%%%%%%%%%%%%%%%%% Permissions

	-- Range every permission level is clamped to: players' levels and the levels commands are registered with.
	PERMISSION_LEVEL_RANGE = {
		Min = 0,
		Max = 255,
	},

	-- Lowest level that opens the command bar, 1 being any member of the `Permissions.Groups` groups. Commands are still
	-- filtered by their own level.
	OPEN_PERMISSION_LEVEL = 1,

	-- Lowest level whose command history is saved in their player data.
	COMMAND_HISTORY_SAVE_PERMISSION_LEVEL = 200,

	--%%%%%%%%%%%%%%%%%%%% Guis

	-- ScreenGuis the command bar and the dashboard are drawn on.
	COMMAND_BAR_GUI = "CommandBar",
	DASHBOARD_GUI = "Dashboard",

	--%%%%%%%%%%%%%%%%%%%% Keys

	-- Key combinations that open or close each window: the last key pressed while the others are held.
	--- @type { Enum.KeyCode }
	COMMAND_BAR_KEYS = {
		Enum.KeyCode.LeftControl, -- 1st
		Enum.KeyCode.LeftBracket, -- 2nd
	},
	--- @type { Enum.KeyCode }
	DASHBOARD_KEYS = {
		Enum.KeyCode.LeftControl, -- 1st
		Enum.KeyCode.RightBracket, -- 2nd
	},

	--%%%%%%%%%%%%%%%%%%%% Windows

	-- Pixels kept between the windows and the screen's edges.
	SCREEN_MARGIN = 8,

	-- The smallest size a resize leaves each window.
	COMMAND_BAR_MIN_SIZE = Vector2.new(360, 150),
	DASHBOARD_MIN_SIZE = Vector2.new(600, 360),

	--%%%%%%%%%%%%%%%%%%%% Edge Glow

	-- The longest bar the edge glow lights, in pixels.
	GLOW_SEGMENT_LENGTH = 60,

	-- How fast the edge glow fades in and out.
	GLOW_TWEEN = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Dashboard

	--%%%%%%%%%%%%%%%%%%%% General

	-- Width of the player list beside the rail.
	DASHBOARD_LIST_WIDTH = 220,

	-- Seconds between one player's dashboard actions.
	DASHBOARD_RUN_DEBOUNCE = 0.2,

	-- The search button's icon at the top of the rail.
	DASHBOARD_SEARCH_ICON = "rbxassetid://70531937773504",

	--%%%%%%%%%%%%%%%%%%%% Colors

	-- What lights picked and switched-on parts (the System look's white).
	DASHBOARD_ACCENT = Color3.fromRGB(255, 255, 255),

	-- Colors of the dashboard's blocks and icons.
	DASHBOARD_COLORS = {
		--[[ Text ]]

		Text = Color3.fromRGB(230, 230, 234),
		Label = Color3.fromRGB(200, 200, 206),
		Danger = Color3.fromRGB(255, 110, 110),
		Dark = Color3.fromRGB(14, 14, 16),
		Letter = Color3.fromRGB(255, 255, 255),

		--[[ Surfaces ]]

		Surface = Color3.fromRGB(255, 255, 255),
		Off = Color3.fromRGB(80, 80, 86),
		Swatch = Color3.fromRGB(40, 40, 44),
		SearchIcon = Color3.fromRGB(200, 200, 206),
	},

	-- Luminance (`I.Color.GetColorLuminance`, 0 to 1) above which an icon's letter is drawn dark.
	DASHBOARD_LIGHT_LUMINANCE = 0.6,

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Command Bar

	--%%%%%%%%%%%%%%%%%%%% Commands

	-- Prefix that starts a command.
	PREFIX = "/",

	-- Prefix that runs a command on every server.
	GLOBAL_PREFIX = "!g",

	-- Argument types a command may declare. When an argument takes several, the earlier ones here are tried first.
	ARG_TYPES = {
		"Player",
		"BigNum",
		"Color",
		"Vector3",
		"Vector2",

		"table",
		"number",
		"boolean",
		"string",
	},

	-- Seconds between one player's server commands.
	SERVER_DEBOUNCE_DURATION = 0.2,

	--%%%%%%%%%%%%%%%%%%%% Global Commands

	-- MessagingService topic for global commands. Studio sessions add `_Studio` to it.
	GLOBAL_TOPIC = "__Ume_GlobalCommand",

	-- Seconds between one player's global commands.
	GLOBAL_DEBOUNCE_DURATION = 2,

	-- How many times a server tries to subscribe to the global topics before it gives up.
	GLOBAL_SUBSCRIBE_ATTEMPTS = 8,

	-- Seconds a global command stays valid; a server that receives it later skips it.
	GLOBAL_VALIDITY_PERIOD = 30,

	-- Longest global output message in characters (MessagingService allows 1kB); a longer output is replaced by a marker.
	GLOBAL_MESSAGE_SIZE_LIMIT = 1000,

	-- Seconds before a global command's returned result is shown, so it prints after the command's own output.
	GLOBAL_MESSAGE_DISPLAY_DELAY = 0.15,

	--%%%%%%%%%%%%%%%%%%%% Chat Command

	-- Chat command that opens the command bar directly. Leave empty to turn it off.
	TOGGLE_COMMAND = "/cmd",

	-- Whether the chat command shows in the chat's autocomplete.
	COMMAND_VISIBLE = true,

	--%%%%%%%%%%%%%%%%%%%% History

	-- How many commands the saved history keeps.
	COMMAND_HISTORY_LIMIT = 30,

	-- How many commands the client keeps, for walking back through them with Up and Down.
	COMMAND_HISTORY_LIMIT_CLIENT = 100,

	-- Longest command the history saves, in characters.
	COMMAND_HISTORY_MAX_COMMAND_LENGTH = 100,

	-- Seconds after a command before the new history is sent to be saved.
	COMMAND_HISTORY_SEND_DELAY = 5,

	--%%%%%%%%%%%%%%%%%%%% Messages

	-- Messages the command bar prints: invalid input, permissions, global results.
	DEBUG_MESSAGES = {
		--[[ General ]]

		InvalidInput = "Passed input is invalid",
		InvalidArguments = "Passed arguments are invalid",
		UnknownCommand = "Unknown command: $|cr$|%s#|",
		InsufficientPermissions = "Insufficient permissions",
		Debounce = "You are sending commands too fast!",

		--[[ Arguments ]]

		InvalidArgument = "Argument $|cr$|%s#| is invalid",
		MissingArgument = "Argument $|cr$|%s#| is missing",

		--[[ Results ]]

		Success = "Command succeeded",
		Failure = "Command failed",

		--[[ Global ]]

		GlobalDisabled = "$|cr$|%s#| is not a Global command",
		GlobalPublishSuccess = "Global publish succeeded",
		GlobalPublishFailed = "Global publish failed",
		GlobalOutputTooLarge = "Output is too large to send back",

		--[[ Client ]]

		Client_UnmatchedArguments = "Expected $|cr$|%s#| arguments but got $|cr$|%s#|",
		Client_GlobalInsufficientPermissions = "Insufficient permissions",
		Client_NotGlobal = "Command $|cr$|%s#| is not a global command",
		Client_TooManyArguments = "Too many arguments, the limit is $|cr$|%s#|",
		Client_ArgumentTooLong = "Argument $|cr$|%s#| is longer than $|cr$|%s#| characters",
		Client_ArgumentTooLarge = "Argument $|cr$|%s#| has more than $|cr$|%s#| entries",
		Client_ArgumentTooDeep = "Argument $|cr$|%s#| is nested deeper than $|cr$|%s#| levels",
	},

	--%%%%%%%%%%%%%%%%%%%% Output

	-- How many messages the output panel keeps.
	OUTPUT_LIMIT = 100,

	-- Whether each output message starts with its time.
	SHOW_TIMESTAMP = true,

	-- RichText params applied to a command result's text in the output panel.
	--- @type RichText_Table
	OUTPUT_RICHTEXT_PARAMS = {},

	--%%%%%%%%%%%%%%%%%%%% Suggestions

	-- How many suggestions show at once.
	SUGGESTIONS_LIMIT = 16,

	-- Dictionary matches are collected for this many `SUGGESTIONS_LIMIT` windows, the rest are skipped.
	SUGGESTIONS_MATCH_WINDOWS = 4,

	-- Seconds Up or Down is held before the selection starts moving on its own.
	SUGGESTION_MOVE_THRESHOLD = 0.275,

	-- Seconds between the selection's steps while it moves on its own.
	SUGGESTION_MOVE_STEP = 0.05,

	-- Direction the suggestions are listed in: 1 from top to bottom, -1 from bottom to top.
	SUGGESTIONS_DIRECTION = 1,

	-- Order the kinds of suggestions are listed in.
	SUGGESTIONS_ORDER = {
		"Variant",
		"Argument",
		"Alias",
	},

	--%%%%%%%%%%%%%%%%%%%% Cursor

	-- Seconds between the cursor's blinks.
	CURSOR_FLICKER_SPEED = 0.3,

	-- Offset added to the cursor's position.
	CURSOR_OFFSET = UDim2.fromScale(0.006, 0.9),

	--%%%%%%%%%%%%%%%%%%%% Colors

	-- Colors of the input's prefix, autocomplete and errors, and of the output's command names and errors.
	COLORS = {
		--[[ Input ]]

		GlobalPrefix = "rgb(65,225,65)",
		AutoComplete = "rgb(255,255,0)",
		Error = "rgb(255,50,50)",

		--[[ Output ]]

		OutputCommand = "rgb(65,225,65)",
		OutputError = "rgb(255,50,50)",
	},

	-- How many of `ARGS_COLORS` the input cycles through, one per argument.
	ARGS_COLORS_AMOUNT = 2,

	-- Colors of the arguments in the input; 0 is the fallback.
	ARGS_COLORS = {
		[0] = "rgb(255,255,255)", -- Fallback
		[1] = "rgb(255,225,30)",
		[2] = "rgb(247, 157, 255)",
	},

	-- Colors of selected text and the selection behind it.
	SELECTION_TEXT_COLOR = "rgb(0,0,0)",
	SELECTION_BACKGROUND_COLOR = "rgb(193, 196, 255)",

	-- Colors an output message's color tags pick from: `$|cr$|` takes the next in turn, `$|c1$|` the first.
	OUTPUT_DYNAMIC_COLORS = {
		[1] = "#FF894F",
		[2] = "#FFCB61",
		[3] = "#77BEF0",
	},

	-- Colors an output message's highlight tags pick from (`$|mcr$|`, `$|mc1$|`), the same way.
	OUTPUT_DYNAMIC_MARK_COLORS = {
		[1] = "rgb(0,0,0)",
		[2] = "rgb(100,100,100)",
	},

	--%%%%%%%%%%%%%%%%%%%% Debug

	-- Show each argument's type index after it in the input.
	DEBUG_TEXT_INDEX = false,
}
return _settings
