--%%%%%%%%%%%%%%%%%%%% Command Data

--- @class AdminPanel_CommandBar_CommandData @ Used in client script.
--- @field baseVariant AdminPanel_CommandBar_VariantData
--- @field _isServerData boolean
local _adminPanel_CommandBar_CommandData = {}

--- @class AdminPanel_CommandBar_CommandData_Global @ Used in global script.
--- @field uuid string @ Used on client to keep track what commands were added/deleted
--- @field baseVariant AdminPanel_CommandBar_VariantData
--- @field callbacksUUIDs { string }
--- @field _isServerData boolean @ Only in client script
local _adminPanel_CommandBar_GlobalCommandData = {}

--- @class AdminPanel_CommandBar_VariantData
---
--- # Structure #
---
--- @field aliases { string }
--- @field args { AdminPanel_CommandBar_CommandDataArgTable }?
--- @field variants { AdminPanel_CommandBar_VariantData }?
---
--- # Callback #
---
--- @field callbackUUID string?
--- @field permissionLevel number
---
--- # Global Return #
---
--- @field callbackUUID_globalReturn string?
--- @field globalReturnArgsCount number?
---
--- # Options #
---
--- @field passInvoker boolean
--- @field globalEnabled boolean
--- @field globalOutput boolean
---
--- # Variant Scope #
---
--- @field variantsAreGlobal boolean
local _adminPanel_CommandBar_VariantData = {}

--- @class AdminPanel_CommandBar_CommandDataArgTable
--- @field name string
--- @field types { string }
--- @field optional boolean
--- @field dict string
--- @field dictNegate string?
--- @field requireDict boolean
local _adminPanel_CommandBar_CommandDataArgTable = {}

--%%%%%%%%%%%%%%%%%%%% Dictionary

--- @class AdminPanel_CommandBar_DictionaryEntry
--- @field permissionLevel number?
--- @field Protected boolean? @ Client only - skips sync removal
--- @field _isServerData boolean? @ Client only - tracks Server vs Client source
--- @field _lowered { string }? @ Client only - lowercase copy of the entries, for suggestions
--- @field BoundTo string? @ Metadata stored as string via SetDictionary / UpdateDictionary
local _adminPanel_CommandBar_DictionaryEntry = {}

--%%%%%%%%%%%%%%%%%%%% Client Input Control

--- @class AdminPanel_CommandBar_InputData
---
--- # Input #
---
--- @field command string
--- @field cleared string
--- @field alias string
---
--- # Command Type #
---
--- @field isCommand boolean
--- @field isGlobalCommand boolean
---
--- # Variant #
---
--- @field commandData AdminPanel_CommandBar_CommandData
--- @field variantData AdminPanel_CommandBar_VariantData
--- @field previousVariantData AdminPanel_CommandBar_VariantData
--- @field variantDepth number
---
--- # Arguments #
---
--- @field args table
--- @field argsToSend table
--- @field argRanges table
---
--- # Prefix #
---
--- @field prefixLength number
--- @field globalPrefixLength number
--- @field totalPrefixLength number
local _adminPanel_CommandBar_InputData = {}

--- @class AdminPanel_CommandBar_ArgParseData
---
--- # Input #
---
--- @field i number
--- @field inputData AdminPanel_CommandBar_InputData
---
--- # Variant #
---
--- @field commandData AdminPanel_CommandBar_CommandData_Global?
--- @field variantData AdminPanel_CommandBar_VariantData
--- @field variantDepth number
---
--- # Available #
---
--- @field availableAliases { string } | nil
--- @field availableVariants { string } | nil
---
--- # Argument #
---
--- @field arg string | table
--- @field totalArgs number
---
--- # Table #
---
--- @field isInTable boolean
--- @field tableId number
--- @field tableIndex number
--- @field tableArgs number
local _adminPanel_CommandBar_ArgParseData = {}

--%%%%%%%%%%%%%%%%%%%% Global

--[[ Setup ]]

--- @class AdminPanel_CommandBar_CommandSetupTable
---
--- # Structure #
---
--- @field Aliases { string }
--- @field Args { AdminPanel_CommandBar_CommandDataArgTable }?
--- @field Variants { AdminPanel_CommandBar_CommandSetupTable }?
---
--- # Callback #
---
--- @field Callback function?
--- @field PermissionLevel number?
---
--- # Global Return #
---
--- @field Callback_GlobalReturn function?
--- @field GlobalReturnArgsCount number?
---
--- # Options #
---
--- @field PassInvoker boolean?
--- @field EnableGlobally boolean?
--- @field GlobalOutput boolean?
local _adminPanel_CommandBar_CommandSetupTable = {}

--[[ Global Message ]]

--- @class AdminPanel_CommandBar_GlobalMessage_SendData
--- @field sender string
--- @field alias string
--- @field args { string }
local _adminPanel_CommandBar_GlobalMessage_SendData = {}

--- @class AdminPanel_CommandBar_GlobalMessage_OutputData
---
--- # Command #
---
--- @field invoker number
--- @field alias string
--- @field args { AdminPanel_CommandBar_ParsedArg }
---
--- # Result #
---
--- @field success boolean
--- @field message AdminPanel_CommandBar_Output
--- @field globalReturnArgs { any }?
local _adminPanel_CommandBar_GlobalMessage_OutputData = {}

--%%%%%%%%%%%%%%%%%%%% Scripts

--- @alias AdminPanel_CommandBar_Output string | { AdminPanel_CommandBar_Output }
--- @alias AdminPanel_CommandBar_ParsedArg string | { AdminPanel_CommandBar_ParsedArg }
--- @alias AdminPanel_CommandBar_TrimmedTable { [string]: string | AdminPanel_CommandBar_TrimmedTable }

--- @class AdminPanel_CommandBar_TokenStack
--- @field start number
--- @field depth number
local _adminPanel_CommandBar_TokenStack = {}

--- @class AdminPanel_CommandBar_TokenGroup
--- @field start number
--- @field ending number
--- @field depth number
local _adminPanel_CommandBar_TokenGroup = {}

--%%%%%%%%%%%%%%%%%%%% Shared Tables

--[[ Client ]]

--- @class AdminPanel_CommandBar_ClientState
---
--- # Interface #
---
--- @field commandBar ScreenGui
---
--- # Elements #
---
--- @field elems { [string]: Instance | GuiObject }
--- @field prefabs { [string]: Instance | GuiObject }
--- @field connections { [string]: RBXScriptConnection }
---
--- # Command Data #
---
--- @field commands { AdminPanel_CommandBar_CommandData_Global }
--- @field aliases { [string]: AdminPanel_CommandBar_CommandData_Global }
--- @field dictionaries { [string]: AdminPanel_CommandBar_DictionaryEntry }
--- @field dataVersions { [string]: number }
---
--- # Suggestions #
---
--- @field createdSuggestions { [string]: TextLabel }
--- @field createdSuggestionsSeparators { [string]: Frame }
--- @field defContainerPos UDim2
---
--- # Autocomplete #
---
--- @field autoCompletePhrase string?
--- @field autoCompleteType string?
--- @field autoCompleteTable table?
--- @field suggestionsWindowStart number?
---
--- # Selection #
---
--- @field activeArgIndex number?
---
--- # History #
---
--- @field commandHistory { string }
--- @field commandHistoryIndex number?
--- @field commandHistoryToSend { string }
--- @field commandHistorySendScheduled boolean
---
--- # Output #
---
--- @field createdOutputTexts { TextLabel }
---
--- # Player State #
---
--- @field playerPermissionLevel number?
local _adminPanel_CommandBar_ClientState = {}

--- @class AdminPanel_CommandBar_ClientShared
---
--- # State #
---
--- @field state AdminPanel_CommandBar_ClientState
---
--- # Utilities #
---
--- @field c_utils AdminPanel_CommandBar_ClientUtils
--- @field utils AdminPanel_CommandBar_Utils
---
--- # Client Systems #
---
--- @field Bootstrap AdminPanel_CommandBar_Client_Bootstrap
--- @field Connections AdminPanel_CommandBar_Client_Connections
--- @field Data AdminPanel_CommandBar_Client_Data
--- @field Control AdminPanel_CommandBar_Client_Control
--- @field Cursor AdminPanel_CommandBar_Client_Cursor
--- @field Selection AdminPanel_CommandBar_Client_Selection
--- @field Suggestions AdminPanel_CommandBar_Client_Suggestions
--- @field Input AdminPanel_CommandBar_Client_Input
local _adminPanel_CommandBar_ClientShared = {}

--[[ Global ]]

--- @class AdminPanel_CommandBar_GlobalState
---
--- # Command Data #
---
--- @field commands { AdminPanel_CommandBar_CommandData_Global }
--- @field argsDict { [string]: AdminPanel_CommandBar_DictionaryEntry }
--- @field callbacks { [string]: function }
--- @field aliases { [string]: AdminPanel_CommandBar_CommandData_Global }
---
--- # Caches #
---
--- @field commandsCache { [number]: { AdminPanel_CommandBar_CommandData_Global } } @ Commands a permission level may see, cleared on Register / Unregister
--- @field dictLevels { [string]: number } @ Last permission level passed for each dictionary
local _adminPanel_CommandBar_GlobalState = {}

--- @class AdminPanel_CommandBar_GlobalShared
---
--- # State #
---
--- @field state AdminPanel_CommandBar_GlobalState
---
--- # Defaults #
---
--- @field commandDefaults AdminPanel_CommandBar_Defaults
--- @field utils AdminPanel_CommandBar_Utils
---
--- # Systems #
---
--- @field Messaging AdminPanel_CommandBar_Global_Messaging
--- @field History AdminPanel_CommandBar_Global_History
--- @field Run AdminPanel_CommandBar_Global_Run
--- @field Register AdminPanel_CommandBar_Global_Register
--- @field Dictionary AdminPanel_CommandBar_Global_Dictionary
--- @field Methods AdminPanel_CommandBar_Global_Methods
---
--- # Admin Panel #
---
--- @field Permissions AdminPanel_Global_Permissions
local _adminPanel_CommandBar_GlobalShared = {}

--%%%%%%%%%%%%%%%%%%%% Window

--- @class AdminPanel_Window
---
--- # Elements #
---
--- @field Panel Frame
--- @field Screen GuiBase2d
--- @field Segment Frame
--- @field Corner Frame
--- @field ResizeHandles Frame
---
--- # Limits #
---
--- @field MinSize Vector2
---
--- # Press #
---
--- @field PressInput InputObject?
--- @field PressStart Vector2
--- @field PressMin Vector2
--- @field PressMax Vector2
--- @field PressEdges Vector2
---
--- # Glow #
---
--- @field GlowLit string
local _adminPanel_Window = {}

--%%%%%%%%%%%%%%%%%%%% Dashboard Setup

--- @class AdminPanel_DashboardPanelSetup
---
--- # General #
---
--- @field Name string
--- @field Description string?
--- @field Scope "Game" | "Player"
--- @field PermissionLevel number?
---
--- # Look #
---
--- @field Icon string?
--- @field Color Color3?
---
--- # Content #
---
--- @field Stats (string | (target: Player | nil) -> string?)?
--- @field Sections { AdminPanel_DashboardSectionSetup }
local _adminPanel_DashboardPanelSetup = {}

--- @class AdminPanel_DashboardSectionSetup
---
--- # General #
---
--- @field Title string
--- @field Blocks { AdminPanel_DashboardBlockSetup }
local _adminPanel_DashboardSectionSetup = {}

--- @class AdminPanel_DashboardBlockSetup
---
--- # General #
---
--- @field Type "Button" | "Toggle" | "Slider" | "Input" | "Choice" | "Info" | "Give"
--- @field Id string
--- @field Text string
---
--- # Value #
---
--- @field Value any
--- @field Min number?
--- @field Max number?
--- @field Step number?
--- @field Format string?
--- @field Options ({ string } | (target: Player | nil) -> { string })?
--- @field Items ({ AdminPanel_DashboardItem } | (target: Player | nil) -> { AdminPanel_DashboardItem })?
---
--- # Input #
---
--- @field Placeholder string?
--- @field Button string?
---
--- # Look #
---
--- @field Danger boolean?
---
--- # Action #
---
--- @field Callback ((admin: Player, values: { [string]: any }, target: Player | nil) -> (boolean, string?))?
local _adminPanel_DashboardBlockSetup = {}

--- @class AdminPanel_DashboardItem
---
--- # General #
---
--- @field Name string
---
--- # Look #
---
--- @field Icon string?
--- @field Color Color3?
local _adminPanel_DashboardItem = {}

--- @class AdminPanel_DashboardPanel
---
--- # General #
---
--- @field Id string
--- @field PermissionLevel number
--- @field Setup AdminPanel_DashboardPanelSetup
local _adminPanel_DashboardPanel = {}

--%%%%%%%%%%%%%%%%%%%% Dashboard Pages

--- @class AdminPanel_DashboardPageInfo
---
--- # General #
---
--- @field Id string
--- @field Name string
--- @field Description string
---
--- # Look #
---
--- @field Icon string?
--- @field Color Color3?
local _adminPanel_DashboardPageInfo = {}

--- @class AdminPanel_DashboardPage
---
--- # General #
---
--- @field Id string
--- @field Name string
--- @field Description string
---
--- # Look #
---
--- @field Icon string?
--- @field Color Color3?
--- @field Round boolean?
---
--- # Content #
---
--- @field Stats string?
--- @field Sections { AdminPanel_DashboardPageSection }
local _adminPanel_DashboardPage = {}

--- @class AdminPanel_DashboardPageSection
---
--- # General #
---
--- @field Title string
--- @field PanelId string
--- @field Index number
--- @field Blocks { AdminPanel_DashboardPageBlock }
local _adminPanel_DashboardPageSection = {}

--- @class AdminPanel_DashboardPageBlock
---
--- # General #
---
--- @field Type "Button" | "Toggle" | "Slider" | "Input" | "Choice" | "Info" | "Give"
--- @field Id string
--- @field Text string
---
--- # Value #
---
--- @field Value any
--- @field Min number?
--- @field Max number?
--- @field Step number?
--- @field Format string?
--- @field Options { string }?
--- @field Items { AdminPanel_DashboardItem }?
---
--- # Input #
---
--- @field Placeholder string?
--- @field Button string?
---
--- # Look #
---
--- @field Danger boolean?
---
--- # Action #
---
--- @field Run boolean
local _adminPanel_DashboardPageBlock = {}

--%%%%%%%%%%%%%%%%%%%% Dashboard Client

--- @class AdminPanel_DashboardState
---
--- # General #
---
--- @field Kind "Search" | "Player" | "Module"
--- @field PlayerUserId number
--- @field PageId string
---
--- # Search #
---
--- @field Query string
local _adminPanel_DashboardState = {}

--- @class AdminPanel_DashboardSlider
---
--- # General #
---
--- @field Block AdminPanel_DashboardPageBlock
--- @field Key string
---
--- # Elements #
---
--- @field Root GuiObject
--- @field Track ImageButton
---
--- # Action #
---
--- @field Run (() -> ())?
local _adminPanel_DashboardSlider = {}

--- @class AdminPanel_DashboardSearchEntry
---
--- # General #
---
--- @field Row GuiObject
--- @field Text string
--- @field Group GuiObject?
local _adminPanel_DashboardSearchEntry = {}
