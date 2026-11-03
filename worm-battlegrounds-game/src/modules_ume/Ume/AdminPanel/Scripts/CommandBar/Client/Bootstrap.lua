--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local state --- @type AdminPanel_CommandBar_ClientState

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--   __       __                  __            __
--  /  \     /  |                /  |          /  |
--  $$  \   /$$ |  ______    ____$$ | __    __ $$ |  ______
--  $$$  \ /$$$ | /      \  /    $$ |/  |  /  |$$ | /      \
--  $$$$  /$$$$ |/$$$$$$  |/$$$$$$$ |$$ |  $$ |$$ |/$$$$$$  |
--  $$ $$ $$/$$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |$$    $$ |
--  $$ |$$$/ $$ |$$ \__$$ |$$ \__$$ |$$ \__$$ |$$ |$$$$$$$$/
--  $$ | $/  $$ |$$    $$/ $$    $$ |$$    $$/ $$ |$$       |
--  $$/      $$/  $$$$$$/   $$$$$$$/  $$$$$$/  $$/  $$$$$$$/
--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--- @class AdminPanel_CommandBar_Client_Bootstrap
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _shared AdminPanel_CommandBar_ClientShared
function Module.Init(_shared)
	state = _shared.state
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Setup

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing key elements.
]]
function Module.GetElements()
	state.commandBar = I.UserInterface.UI[_settings.COMMAND_BAR_GUI]

	local commandBar: ScreenGui = state.commandBar
	local console: Frame = commandBar:FindFirstChild("U_CommandBar", true)
	local elems = state.elems
	local prefabs = state.prefabs

	--%%%%%%%%%%%%%%%%%%%% Elements

	--[[ Getting ]]

	-- Input/Display
	elems["InputBox"] = console:FindFirstChild("S_InputBox", true) --- @type TextBox
	elems["DisplayBox"] = console:FindFirstChild("S_DisplayBox", true) --- @type TextBox

	-- Selection
	elems["SelectionBox"] = console:FindFirstChild("S_SelectionBox", true) --- @type TextBox

	-- Cursor
	elems["Cursor"] = console:FindFirstChild("S_Cursor", true) --- @type Frame
	elems["CursorPosBox"] = console:FindFirstChild("S_CursorPosBox", true) --- @type TextBox

	-- Buttons
	elems["ExecuteButton"] = console:FindFirstChild("S_ExecuteButton", true) --- @type ImageButton
	elems["CloseButton"] = console:FindFirstChild("S_CloseButton", true) --- @type ImageButton

	-- Suggestions
	elems["SuggestionPosBox"] = console:FindFirstChild("S_SuggestionPosBox", true) --- @type TextBox
	elems["SuggestionsContainer"] = console:FindFirstChild("S_SuggestionsContainer", true) --- @type Frame
	elems["SuggestionsContainerBg"] = console:FindFirstChild("S_SuggestionsContainerBackground", true) --- @type Frame

	-- Output
	elems["OutputScrollingFrame"] = console:FindFirstChild("S_OutputScrollingFrame", true) --- @type ScrollingFrame

	--[[ Updating ]]

	-- Updating Elements
	elems["InputBox"].Text = ""
	elems["DisplayBox"].Text = ""
	state.defContainerPos = elems["SuggestionsContainer"].Position

	-- Hiding
	elems["Cursor"].Visible = false
	elems["SuggestionsContainer"].Visible = false
	elems["SuggestionsContainerBg"].Visible = false

	--%%%%%%%%%%%%%%%%%%%% Prefabs

	--[[ Getting ]]

	prefabs["SuggestionSeparator"] = commandBar:FindFirstChild("PREFAB | SuggestionSeparator", true) --- @type Frame
	prefabs["SuggestionText"] = commandBar:FindFirstChild("PREFAB | SuggestionText", true) --- @type TextLabel
	prefabs["OutputFrame"] = commandBar:FindFirstChild("PREFAB | OutputFrame", true) --- @type TextLabel

	--[[ Updating ]]

	-- Hiding
	prefabs["SuggestionSeparator"].Visible = false
	prefabs["SuggestionText"].Visible = false
	prefabs["OutputFrame"].Visible = false

	-- Making sure the command bar stays hidden
	commandBar.Enabled = false
end

--%%%%%%%%%%%%%%%%%%%% Check Prefixes

--[[
	Checks if the prefixes defined in the settings are valid.
]]
function Module.CheckPrefixes()
	--[[
		Validates given prefix.
	]]
	--- @return string
	local function validatePrefix(prefix: string, prefixType: string)
		-- Spaces check
		if string.find(prefix, "%s+") then
			if I.Env.IsStudio then
				warn(`[{_localName}::{script.Name}]: ({prefixType}) prefix ({prefix}) cannot contain any spaces!`)
			end

			prefix = string.gsub(prefix, "%s+", "")
		end

		-- RichText syntaxes check
		if string.find(prefix, "[<>]") then
			if I.Env.IsStudio then
				warn(`[{_localName}::{script.Name}]: ({prefixType}) prefix ({prefix}) cannot contain RichText syntaxes!`)
			end

			prefix = string.gsub(prefix, "[<>]", "")
		end

		-- Empty check
		if #prefix == 0 then
			if I.Env.IsStudio then
				warn(`[{_localName}::{script.Name}]: ({prefixType}) prefix ({prefix}) is empty!`)
			end

			prefix = "/"
		end

		return prefix
	end

	--%%%%%%%%%%%%%%%%%%%% Validating

	_settings.PREFIX = validatePrefix(_settings.PREFIX, "Default")
	_settings.GLOBAL_PREFIX = validatePrefix(_settings.GLOBAL_PREFIX, "Global")

	--[[ Identical Check ]]

	if _settings.PREFIX == _settings.GLOBAL_PREFIX then
		_settings.PREFIX = "/"
		_settings.GLOBAL_PREFIX = "!g"
	end
end

--%%%%%%%%%%%%%%%%%%%% Validate Settings

--[[
	Checks and validates important settings properties.
]]
function Module.ValidateSettings()
	--[[ SUGGESTIONS_DIRECTION ]]

	if _settings.SUGGESTIONS_DIRECTION ~= 1 and _settings.SUGGESTIONS_DIRECTION ~= -1 then
		if I.Env.IsStudio then
			warn(`[{_localName}::{script.Name}]: Settings property 'SUGGESTIONS_DIRECTION' cannot be set to ({_settings.SUGGESTIONS_DIRECTION})!`)
		end

		_settings.SUGGESTIONS_DIRECTION = 1
	end
end

--%%%%%%%%%%%%%%%%%%%% Retrieve Command History

--[[
	Retrieves command history from server.
]]
function Module.RetrieveCommandHistory()
	-- Wrapping to avoid lag on other functions
	task.spawn(function()
		-- Getting command history
		local savedCommandHistory: table | nil = I.Network.Invoke("_AdminPanel_CommandBar_GetCommandHistory")

		-- Updating
		if savedCommandHistory then
			state.commandHistory = savedCommandHistory
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
