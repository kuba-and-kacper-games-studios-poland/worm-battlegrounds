--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type AdminPanel_Permissions
local permissions = require(I.Dirs.GlobalData.AdminPanel.Permissions)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local shared --- @type AdminPanel_CommandBar_ClientShared
local state --- @type AdminPanel_CommandBar_ClientState

local c_utils --- @type AdminPanel_CommandBar_ClientUtils

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Trim To Limit

--[[
	Trims given table from the back until the size is at or below the limit.
]]
local function trimToLimit(t: table, limit: number)
	while #t > limit do
		table.remove(t, #t)
	end
end

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

--- @class AdminPanel_CommandBar_Client_Control
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _shared AdminPanel_CommandBar_ClientShared
function Module.Init(_shared)
	shared = _shared
	state = _shared.state

	c_utils = _shared.c_utils
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Toggle Command Bar

--[[
	Toggles the command bar.
	Players below `OPEN_PERMISSION_LEVEL` can't open it.
]]
function Module.ToggleCommandBar()
	--[[ Data ]]

	local elems = state.elems --- @type { [string]: Instance | GuiObject }
	local commandBar: ScreenGui = state.commandBar

	--[[ Checks ]]

	-- Check if the player may open the command bar
	if not commandBar.Enabled and I.AdminPanel.GetPermissionLevel(I.Env.LocalPlayer) < _settings.OPEN_PERMISSION_LEVEL then
		return
	end

	--[[ Toggling ]]

	commandBar.Enabled = not commandBar.Enabled

	--[[ Updating ]]

	if commandBar.Enabled then
		-- Client Updates
		shared.Data.UpdateCommandsData("Client")
		shared.Data.UpdateDictionariesData("Client")

		-- Server Updates
		shared.Data.UpdateCommandsData("Server")
		shared.Data.UpdateDictionariesData("Server")

		-- Focusing
		elems["InputBox"]:CaptureFocus()
	else
		elems["InputBox"].Text = ""

		-- Saving command history
		Module._sendCommandHistory()

		-- Clearing Focus
		elems["InputBox"]:ReleaseFocus()
	end
end

--%%%%%%%%%%%%%%%%%%%% Execute Command

--[[
	Executes current text in the `InputBox` as a command.
	Server commands are checked against the Network argument limits first, so the bar can name the argument that is too large.
]]
function Module.ExecuteCommand()
	local elems = state.elems --- @type { [string]: Instance | GuiObject }
	local aliases = state.aliases --- @type { [string]: AdminPanel_CommandBar_CommandData_Global }

	--%%%%%%%%%%%%%%%%%%%% Input Data

	local command: string = elems["InputBox"].Text
	local inputData = c_utils.GetInputData(command, aliases) --- @type AdminPanel_CommandBar_InputData

	-- Stop executing if command is empty
	if inputData.command == "" or inputData.command == _settings.PREFIX or inputData.command == _settings.GLOBAL_PREFIX then
		return
	end

	-- Clearing TextBoxes
	elems["InputBox"].Text = ""
	elems["DisplayBox"].Text = ""

	-- Printing executed command to the output
	Module.PrintToOutput(true, nil, `> {command}`)

	-- Saving command
	table.insert(state.commandHistory, 1, command)
	table.insert(state.commandHistoryToSend, 1, command)

	-- Removing excess
	trimToLimit(state.commandHistory, _settings.COMMAND_HISTORY_LIMIT_CLIENT)
	trimToLimit(state.commandHistoryToSend, _settings.COMMAND_HISTORY_LIMIT_CLIENT)

	-- Sending the new history shortly, so it is saved even when the player leaves with the bar open
	Module._scheduleCommandHistorySend()

	-- Return if input is not a command
	if not inputData.isCommand then
		return
	end

	--%%%%%%%%%%%%%%%%%%%% Command Data

	local commandData = aliases[inputData.alias] --- @type AdminPanel_CommandBar_CommandData_Global
	local variantData = commandData and commandData.baseVariant --- @type AdminPanel_CommandBar_VariantData

	-- Check if the command exists
	if not commandData or not variantData then
		Module.PrintToOutput(false, "ERROR", _settings.DEBUG_MESSAGES.UnknownCommand:format(inputData.alias))
		return
	end

	--[[ Args Variables ]]

	local argsToSend = {} --- @type { AdminPanel_CommandBar_ParsedArg }
	local argsCount: number = 0

	--%%%%%%%%%%%%%%%%%%%% Arguments

	-- Clear last argument if it's empty
	local lastArg: string = inputData.argsToSend[#inputData.argsToSend]
	if lastArg == "" or lastArg == " " then
		table.remove(inputData.argsToSend, #inputData.argsToSend)
	end

	--%%%%%%%%%%%%%%%%%%%% Variant Data

	while true do
		--[[ Local Variables ]]

		local arg: string = inputData.argsToSend[1]
		local variantFound: boolean = false

		--[[ Checks ]]

		-- Stop if argument is missing or further variants are missing
		if not arg or not variantData.variants then
			break
		end

		--[[ Finding Child Variant ]]

		--- @param loopVariantData AdminPanel_CommandBar_VariantData
		for _index: number, loopVariantData in ipairs(variantData.variants) do
			-- Skip if arg is not matching any alias
			if not table.find(loopVariantData.aliases, arg) then
				continue
			end

			-- Updating variant
			variantFound = true
			variantData = loopVariantData

			-- Saving variant as argument
			table.insert(argsToSend, arg)
			argsCount += 1

			-- Removing argument
			table.remove(inputData.argsToSend, 1)
		end

		-- Stop searching if variant was not updated
		if not variantFound then
			break
		end
	end

	--[[ Matching Arguments ]]

	local variantArgsCount: number = #argsToSend

	if variantData.args then
		--- @param argData AdminPanel_CommandBar_CommandDataArgTable
		for i: number, argData in ipairs(variantData.args) do
			-- Counting required arguments
			if not argData.optional then
				argsCount += 1
			end

			-- Saving Argument
			if inputData.argsToSend[i] then
				table.insert(argsToSend, inputData.argsToSend[i])
			end
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Checks

	--[[ Arguments Count Check ]]

	-- Check if every required argument was typed
	if argsCount > #argsToSend then
		Module.PrintToOutput(false, "ERROR", _settings.DEBUG_MESSAGES.Client_UnmatchedArguments:format(argsCount, #argsToSend))
		return
	end

	--[[ Global Permissions Check ]]

	if inputData.isGlobalCommand then
		--[[ Global Command Check ]]

		-- Check if the variant can run globally
		if not variantData.globalEnabled then
			Module.PrintToOutput(false, "ERROR", _settings.DEBUG_MESSAGES.GlobalDisabled:format(inputData.alias))
			return
		end

		--[[ Permission Level Check ]]

		-- Caching permission level
		if not state.playerPermissionLevel then
			state.playerPermissionLevel = I.AdminPanel.GetPermissionLevel(I.Env.LocalPlayer) or 0
		end

		local canSendGlobalCommands: boolean = state.playerPermissionLevel >= permissions.GlobalLevel

		-- Check if the player may send global commands
		if not canSendGlobalCommands then
			Module.PrintToOutput(false, "ERROR", _settings.DEBUG_MESSAGES.Client_GlobalInsufficientPermissions)
			return
		end
	end

	--[[ Network Limits Check ]]

	local limitError: string? = commandData._isServerData and Module._getNetworkLimitError(argsToSend, variantData, variantArgsCount) or nil

	-- Check if the server would drop these arguments
	if limitError then
		Module.PrintToOutput(false, "ERROR", limitError)
		return
	end

	--%%%%%%%%%%%%%%%%%%%% Executing

	local success: boolean, output: string?

	--[[ Local Command ]]

	if not inputData.isGlobalCommand then
		if commandData._isServerData then
			success, output = I.Network.Invoke("_AdminPanel_CommandBar_Run", inputData.alias, argsToSend)
		else
			success, output = I.AdminPanel_CommandBar.RunCommand(I.Env.LocalPlayer, inputData.alias, argsToSend, false)
		end
	end

	--[[ Global Command ]]

	if inputData.isGlobalCommand then
		if commandData._isServerData then
			success, output = I.Network.Invoke("_AdminPanel_CommandBar_RunGlobal", inputData.alias, argsToSend)
		else
			Module.PrintToOutput(false, "ERROR", _settings.DEBUG_MESSAGES.Client_NotGlobal:format(inputData.alias))
			return
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Output

	-- Skip an empty output
	if output ~= "" then
		if success then
			Module.PrintToOutput(true, inputData.alias, output or _settings.DEBUG_MESSAGES.Success)
		else
			Module.PrintToOutput(false, inputData.alias, output or _settings.DEBUG_MESSAGES.Failure)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Print To Output

--[[
	Prints given message to the output.
]]
function Module.PrintToOutput(success: boolean, commandAlias: string, output: string | table)
	local elems = state.elems
	local prefabs = state.prefabs
	local createdOutputTexts = state.createdOutputTexts

	--%%%%%%%%%%%%%%%%%%%% Fixing Output Text

	-- Converting table into a string
	if type(output) == "table" then
		-- Multi-line table output
		if output[#output] == "_multilineOutput" then
			for i = 1, #output - 1 do
				Module.PrintToOutput(success, commandAlias, output[i])
			end
			return
		end

		-- Regular table output
		output = c_utils.ConvertTableToString(output)
	end

	-- Adding colors
	output = c_utils.ApplyCustomFormatting(output)

	--%%%%%%%%%%%%%%%%%%%% Getting Output Text

	local finalText: string = ""

	-- Adding timestamp
	if _settings.SHOW_TIMESTAMP then
		finalText ..= `{I.RichText.Format(c_utils.GetCurrentTimeWithMilliseconds(), { Transparency = 0.5 })} `
	end

	-- Updating message
	if commandAlias then
		if success then
			finalText ..= `{I.RichText.Format(`{commandAlias}`, { Color = _settings.COLORS.OutputCommand })} >> {I.RichText.Format(output, _settings.OUTPUT_RICHTEXT_PARAMS)}`
		else
			finalText ..= `{I.RichText.Format(`{commandAlias}`, { Color = _settings.COLORS.OutputError })} >> {I.RichText.Format(output, _settings.OUTPUT_RICHTEXT_PARAMS)}`
		end
	else
		finalText ..= `{I.RichText.Format(output, { Transparency = 0.5 })}`
	end

	--%%%%%%%%%%%%%%%%%%%% Getting Scroll

	-- Positions
	local canvasSizeY: number = elems["OutputScrollingFrame"].AbsoluteCanvasSize.Y
	local windowSizeY: number = elems["OutputScrollingFrame"].AbsoluteWindowSize.Y
	local scrollPosY: number = elems["OutputScrollingFrame"].CanvasPosition.Y

	-- Calculating
	local isScrolledToEnd: boolean = math.floor(windowSizeY + scrollPosY) == math.floor(canvasSizeY)

	--%%%%%%%%%%%%%%%%%%%% Creating Message

	-- Creating message
	local cloned: Frame = prefabs["OutputFrame"]:Clone()
	cloned.OutputText.Text = finalText

	-- Saving
	cloned.Visible = true
	cloned.Parent = elems["OutputScrollingFrame"]
	table.insert(createdOutputTexts, cloned)

	--%%%%%%%%%%%%%%%%%%%% Removing Excessive

	local aboveLimit: number = #createdOutputTexts - _settings.OUTPUT_LIMIT
	if aboveLimit > 0 then
		for _ = 1, aboveLimit do
			createdOutputTexts[1]:Destroy()
			table.remove(createdOutputTexts, 1)
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Scrolling To End

	if isScrolledToEnd then
		task.wait()

		-- Updating size
		canvasSizeY = elems["OutputScrollingFrame"].AbsoluteCanvasSize.Y
		windowSizeY = elems["OutputScrollingFrame"].AbsoluteWindowSize.Y

		-- Moving to the bottom
		elems["OutputScrollingFrame"].CanvasPosition = Vector2.new(0, canvasSizeY - windowSizeY)
	end
end

--%%%%%%%%%%%%%%%%%%%% Send Command History

--[[
	Sends the commands run since the last send to be saved, trimmed to what the server keeps.
	Players below `COMMAND_HISTORY_SAVE_PERMISSION_LEVEL` send nothing, since their history isn't saved.
]]
function Module._sendCommandHistory()
	--[[ Local Variables ]]

	local historyToSend = {} --- @type { string }
	local canSave: boolean = I.AdminPanel.GetPermissionLevel(I.Env.LocalPlayer) >= _settings.COMMAND_HISTORY_SAVE_PERMISSION_LEVEL

	--[[ Filtering ]]

	-- Only players whose history is saved send it
	if canSave then
		for _index: number, command: string in ipairs(state.commandHistoryToSend) do
			-- Stop at the number of commands the server keeps
			if #historyToSend >= _settings.COMMAND_HISTORY_LIMIT then
				break
			end

			-- Skip commands too long to be saved
			if #command > _settings.COMMAND_HISTORY_MAX_COMMAND_LENGTH then
				continue
			end

			table.insert(historyToSend, command)
		end
	end

	--[[ Clearing ]]

	table.clear(state.commandHistoryToSend)

	--[[ Checks ]]

	-- Skip when nothing is left to save
	if #historyToSend == 0 then
		return
	end

	--[[ Sending ]]

	I.Network.Fire("_AdminPanel_CommandBar_UpdateCommandHistory", historyToSend)
end

--%%%%%%%%%%%%%%%%%%%% Schedule Command History Send

--[[
	Sends the command history `COMMAND_HISTORY_SEND_DELAY` seconds after a command, once for every command run in that time.
]]
function Module._scheduleCommandHistorySend()
	--[[ Checks ]]

	-- Skip when a send is already waiting
	if state.commandHistorySendScheduled then
		return
	end

	--[[ Scheduling ]]

	state.commandHistorySendScheduled = true

	task.delay(_settings.COMMAND_HISTORY_SEND_DELAY, function()
		state.commandHistorySendScheduled = false
		Module._sendCommandHistory()
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Network Limit Error

--[[
	Returns a message naming the first argument the server's remote safety scan would drop, or nil when all pass.
	Uses the Network settings for string length, table size and table depth.
]]
--- @param argsToSend { AdminPanel_CommandBar_ParsedArg }
--- @param variantData AdminPanel_CommandBar_VariantData
--- @return string?
function Module._getNetworkLimitError(argsToSend, variantData, variantArgsCount: number)
	--[[ Local Variables ]]

	--- @type Network_Settings
	local networkSettings = I.Settings["Network"]

	--[[ Checks ]]

	-- Check if there are more arguments than a table may hold
	if #argsToSend > networkSettings.MAX_TABLE_SIZE then
		return _settings.DEBUG_MESSAGES.Client_TooManyArguments:format(networkSettings.MAX_TABLE_SIZE)
	end

	--[[ Scanning ]]

	--- @param arg AdminPanel_CommandBar_ParsedArg
	for index: number, arg in ipairs(argsToSend) do
		--[[ Naming ]]

		local argData = variantData.args and variantData.args[index - variantArgsCount] --- @type AdminPanel_CommandBar_CommandDataArgTable?
		local argName: string = if argData then argData.name else `{index}`

		--[[ Checking ]]

		-- The arguments table sits one level below the remote's payload, so each argument is at depth 2
		local limitError: string? = Module._getLimitError(arg, argName, 2, networkSettings)

		-- Stop at the first argument over a limit
		if limitError then
			return limitError
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Limit Error

--[[
	Returns the message for a value that breaks a Network scan limit at the given table depth, or nil when it doesn't.
]]
--- @param networkSettings Network_Settings
--- @return string?
function Module._getLimitError(value: any, argName: string, depth: number, networkSettings)
	--[[ Checks ]]

	-- Check if the value is nested too deep
	if depth > networkSettings.MAX_TABLE_DEPTH then
		return _settings.DEBUG_MESSAGES.Client_ArgumentTooDeep:format(argName, networkSettings.MAX_TABLE_DEPTH)
	end

	-- Check if a string is too long
	if type(value) == "string" and #value > networkSettings.MAX_STRING_LENGTH then
		return _settings.DEBUG_MESSAGES.Client_ArgumentTooLong:format(argName, networkSettings.MAX_STRING_LENGTH)
	end

	-- Skip values that are not tables
	if type(value) ~= "table" then
		return nil
	end

	--[[ Scanning ]]

	local count: number = 0

	for _key: any, entry: any in pairs(value) do
		count += 1

		-- Check if the table has too many entries
		if count > networkSettings.MAX_TABLE_SIZE then
			return _settings.DEBUG_MESSAGES.Client_ArgumentTooLarge:format(argName, networkSettings.MAX_TABLE_SIZE)
		end

		local entryError: string? = Module._getLimitError(entry, argName, depth + 1, networkSettings)

		-- Stop at the first entry over a limit
		if entryError then
			return entryError
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
