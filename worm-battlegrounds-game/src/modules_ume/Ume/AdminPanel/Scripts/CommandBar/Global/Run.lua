--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local MessagingService = I.Env.IsServer and I.S.MessagingService
local HttpService = I.S.HttpService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type AdminPanel_Permissions
local permissions = require(I.Dirs.GlobalData.AdminPanel.Permissions)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local shared --- @type AdminPanel_CommandBar_GlobalShared
local state --- @type AdminPanel_CommandBar_GlobalState

local utils --- @type AdminPanel_CommandBar_Utils

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

--- @class AdminPanel_CommandBar_Global_Run
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _shared AdminPanel_CommandBar_GlobalShared
function Module.Init(_shared)
	shared = _shared
	state = _shared.state

	utils = _shared.utils
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Run Control

--%%%%%%%%%%%%%%%%%%%% Run Command

--[[
	Runs command and returns whether it succeeded and the output message.
]]
--- @return boolean
--- @return AdminPanel_CommandBar_Output?
--- @return { any }?
function Module.RunCommand(invoker: Player | number, alias: string, args: table, isGlobal: boolean?)
	--[[ Data ]]

	local aliases = state.aliases --- @type { [string]: AdminPanel_CommandBar_CommandData_Global }
	local callbacks = state.callbacks --- @type { [string]: function }

	--[[ Checks ]]

	-- Check if alias and args are of valid types
	if type(alias) ~= "string" or type(args) ~= "table" then
		return false, _settings.DEBUG_MESSAGES.InvalidInput
	end

	--[[ Command Data ]]

	--- @type AdminPanel_CommandBar_CommandData_Global
	local commandData = aliases[alias]

	-- Check if the command exists
	if not commandData or not commandData.baseVariant then
		return false, not isGlobal and _settings.DEBUG_MESSAGES.UnknownCommand:format(`{alias}`) or nil
	end

	--[[ Getting Variant Data ]]

	--- @param variantData AdminPanel_CommandBar_VariantData
	local success: boolean, variantData, newArgs: { any } = utils.GetVariantDataFromArgs(commandData, args)

	-- Check if the variant was found
	if not success then
		return false, not isGlobal and _settings.DEBUG_MESSAGES.InvalidArguments or nil
	end

	--[[ Client: Permission Level Check ]]

	if I.Env.IsClient then
		local playerPermissionLevel: number = shared.Permissions.GetPermissionLevel(I.Env.LocalPlayer)

		-- Check if player can run that command variant on client
		if variantData.permissionLevel > playerPermissionLevel then
			return false, not isGlobal and _settings.DEBUG_MESSAGES.InsufficientPermissions or nil
		end
	end

	--[[ Global Check ]]

	-- Check if a global run is allowed for this variant
	if isGlobal and not variantData.globalEnabled then
		return false, not isGlobal and _settings.DEBUG_MESSAGES.GlobalDisabled:format(alias) or nil
	end

	--[[ Getting Arguments ]]

	local convertVariantSuccess: boolean
	local convertedVariantArgs --- @type { any } | string
	convertVariantSuccess, convertedVariantArgs = utils.ConvertArgsTable(variantData, newArgs, false)

	-- Check if the arguments convert to their types
	if not convertVariantSuccess then
		return false, not isGlobal and convertedVariantArgs or nil
	end

	--[[ Dictionary Check ]]

	local dictionaryError: string? = Module._getDictionaryError(invoker, variantData, args, newArgs)

	-- Check if every argument is in its required dictionary
	if dictionaryError then
		return false, not isGlobal and dictionaryError or nil
	end

	--[[ Executing ]]

	if callbacks[variantData.callbackUUID] then
		--[[ Getting Args Unpack Table ]]

		local toUnpack = {} --- @type { any }
		local unpackCount: number = 0

		-- Invoker
		if variantData.passInvoker then
			unpackCount += 1
			toUnpack[unpackCount] = invoker
		end

		-- Arguments
		if variantData.args then
			for count: number = 1, #variantData.args do
				unpackCount += 1
				toUnpack[unpackCount] = convertedVariantArgs[count]
			end
		end

		-- Global command
		unpackCount += 1
		toUnpack[unpackCount] = isGlobal == true

		--[[ Running Function ]]

		local runSuccess: boolean
		local runResult: string | boolean
		local runMessage --- @type AdminPanel_CommandBar_Output?
		local globalReturnArgs --- @type { any }?
		runSuccess, runResult, runMessage, globalReturnArgs = pcall(function()
			return callbacks[variantData.callbackUUID](table.unpack(toUnpack, 1, unpackCount))
		end)

		-- Warn when the callback threw
		if not runSuccess then
			warn(`[{_localName}::{script.Name}]: Command callback failed for alias ({alias}) - {runResult}`)
		end

		--[[ Returning ]]

		-- Returning without message
		if runResult == nil then
			return runSuccess
		end

		-- Returning with message
		if type(runResult) == "boolean" then
			if runMessage then
				return runResult, runMessage, globalReturnArgs -- Result is passed as a boolean with additional message
			else
				return runResult
			end
		else
			return runSuccess, runResult, globalReturnArgs -- `runResult` is a data that is different from a boolean
		end
	else
		return false
	end
end

--%%%%%%%%%%%%%%%%%%%% Run Command Server

--[[
	Runs received command from client with prior permission level check.
	Players below `OPEN_PERMISSION_LEVEL` run none, as they can't open the bar.
]]
--- @return boolean
--- @return AdminPanel_CommandBar_Output?
--- @return { any }?
function Module.RunCommandServer(player: Player, alias: string, args: table)
	-- Check if player is valid | SERVER
	if I.Env.IsClient or not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type { [string]: AdminPanel_CommandBar_CommandData_Global }
	local aliases = state.aliases

	--[[ Checks ]]

	-- Check if alias and args are of valid types
	if type(alias) ~= "string" or type(args) ~= "table" then
		return false, _settings.DEBUG_MESSAGES.InvalidInput
	end

	-- Check if the player ran a server command too recently
	if I.Debounce.Run("AdminPanel_RunServerCommand", _settings.SERVER_DEBOUNCE_DURATION, player) then
		return false, _settings.DEBUG_MESSAGES.Debounce
	end

	--[[ Command Data ]]

	--- @type AdminPanel_CommandBar_CommandData_Global
	local commandData = aliases[alias]

	-- Check if the command exists
	if not commandData or not commandData.baseVariant then
		return false, _settings.DEBUG_MESSAGES.UnknownCommand:format(`{alias}`)
	end

	--[[ Getting Variant Data ]]

	local success: boolean
	local variantData --- @type AdminPanel_CommandBar_VariantData
	success, variantData = utils.GetVariantDataFromArgs(commandData, args)

	-- Check if the variant was found
	if not success then
		return false, _settings.DEBUG_MESSAGES.InvalidArguments
	end

	--[[ Permission Level Check ]]

	local playerPermissionLevel: number = shared.Permissions.GetPermissionLevel(player)

	-- Check if the player may open the command bar and run that command variant
	if playerPermissionLevel < _settings.OPEN_PERMISSION_LEVEL or variantData.permissionLevel > playerPermissionLevel then
		return false, _settings.DEBUG_MESSAGES.InsufficientPermissions
	end

	--[[ Running ]]

	return Module.RunCommand(player, alias, args, false)
end

--%%%%%%%%%%%%%%%%%%%% Run Command Global

--[[
	Runs received command on all active servers with prior permission level check.
	Permission is checked before the arguments are converted, and each player may publish once per `GLOBAL_DEBOUNCE_DURATION`.
]]
--- @return boolean
--- @return AdminPanel_CommandBar_Output?
function Module.RunCommandGlobal(player: Player, alias: string, args: table)
	-- Check if player is valid | SERVER
	if I.Env.IsClient or not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	local aliases = state.aliases --- @type { [string]: AdminPanel_CommandBar_CommandData_Global }

	--[[ Checks ]]

	-- Check if alias and args are of valid types
	if type(alias) ~= "string" or type(args) ~= "table" then
		return false, _settings.DEBUG_MESSAGES.InvalidInput
	end

	--[[ Command Data ]]

	--- @type AdminPanel_CommandBar_CommandData_Global
	local commandData = aliases[alias]

	-- Check if the command exists
	if not commandData or not commandData.baseVariant then
		return false, _settings.DEBUG_MESSAGES.UnknownCommand:format(`{alias}`)
	end

	--[[ Getting Variant Data ]]

	--- @param variantData AdminPanel_CommandBar_VariantData
	local success: boolean, variantData, newArgs: { any } = utils.GetVariantDataFromArgs(commandData, args)

	-- Check if the variant was found
	if not success then
		return false, _settings.DEBUG_MESSAGES.InvalidArguments
	end

	--[[ Permission Level Check ]]

	local playerPermissionLevel: number = shared.Permissions.GetPermissionLevel(player)

	-- Check if player can run that command variant
	if variantData.permissionLevel > playerPermissionLevel then
		return false, _settings.DEBUG_MESSAGES.InsufficientPermissions
	end

	-- Check if player have global permissions
	if permissions.GlobalLevel > playerPermissionLevel then
		return false, _settings.DEBUG_MESSAGES.InsufficientPermissions
	end

	--[[ Global Command Check ]]

	-- Check if the variant can run globally
	if not variantData.globalEnabled then
		return false, _settings.DEBUG_MESSAGES.GlobalDisabled:format(alias)
	end

	--[[ Validating Arguments ]]

	local convertVariantSuccess: boolean
	local convertedVariantArgs --- @type { any } | string
	convertVariantSuccess, convertedVariantArgs = utils.ConvertArgsTable(variantData, newArgs, true, true)

	-- Check if the arguments convert to their types
	if not convertVariantSuccess then
		return false, convertedVariantArgs
	end

	--[[ Debounce ]]

	-- Check if the player published a global command too recently
	if I.Debounce.Run("AdminPanel_RunGlobalCommand", _settings.GLOBAL_DEBOUNCE_DURATION, player) then
		return false, _settings.DEBUG_MESSAGES.Debounce
	end

	--[[ Running ]]

	local result: any | string?
	success, result = pcall(function()
		MessagingService:PublishAsync(
			shared.Messaging.GetGlobalTopic(),
			HttpService:JSONEncode({
				invoker = player.UserId,
				alias = alias,
				args = args,
			})
		)
	end)

	-- Warn when the publish failed
	if not success then
		warn(`[{_localName}::{script.Name}]: Global publish failed for alias ({alias}) - {result}`)
	end

	--[[ Returning ]]

	return success, success and _settings.DEBUG_MESSAGES.GlobalPublishSuccess or { _settings.DEBUG_MESSAGES.GlobalPublishFailed, result, "_multilineOutput" }
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Dictionary Error

--[[
	Returns the error message for the first argument that is not an exact entry of its required dictionary, or nil when all pass.
	Only dictionaries registered on this side are checked; client-only ones such as `players` are covered by type conversion.
]]
--- @param variantData AdminPanel_CommandBar_VariantData
--- @param args { any }
--- @param newArgs { any }
--- @return string?
function Module._getDictionaryError(invoker: Player | number, variantData, args, newArgs)
	--[[ Checks ]]

	-- Skip variants without arguments
	if not variantData.args then
		return nil
	end

	--[[ Local Variables ]]

	local argsOffset: number = #args - #newArgs
	local invokerId: string = if typeof(invoker) == "Instance" then `{invoker.UserId}` else `{invoker}`

	--[[ Checking ]]

	--- @param argData AdminPanel_CommandBar_CommandDataArgTable
	for argId: number, argData in ipairs(variantData.args) do
		--[[ Checks ]]

		local currentArg: any = newArgs[argId]

		-- Skip arguments without a required dictionary, and optional ones left out
		if not argData.requireDict or currentArg == nil then
			continue
		end

		-- Skip an optional argument set to nil or left empty
		if argData.optional and (currentArg == "nil" or currentArg == "") then
			continue
		end

		--[[ Resolving Dictionary ]]

		-- Replacing the invoker and argument regions, as the client does
		local dictName: string = string.gsub(argData.dict, "%$|(.-)#|", function(region: string)
			local parts = string.split(region, ":") --- @type { string }
			local offset: number? = tonumber(parts[2])

			-- Invoker region
			if parts[1] == "invoker" then
				return invokerId
			end

			-- Argument region, relative to this argument
			if parts[1] == "arg" and offset then
				local goalArg: any = args[argsOffset + argId + offset]
				return if type(goalArg) == "string" then goalArg else ""
			end

			return ""
		end)

		--- @type AdminPanel_CommandBar_DictionaryEntry?
		local dictData = state.argsDict[dictName]

		-- Skip dictionaries this side does not have
		if not dictData then
			continue
		end

		--[[ Matching ]]

		-- Check if the argument is an exact dictionary entry
		if not Module._isInDictionary(currentArg, dictData) then
			return _settings.DEBUG_MESSAGES.InvalidArgument:format(argData.name)
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Is In Dictionary

--[[
	Checks if an argument, or every entry of a table argument, is an exact entry of the dictionary.
]]
--- @param dictData AdminPanel_CommandBar_DictionaryEntry
--- @return boolean
function Module._isInDictionary(arg: any, dictData)
	--[[ Table ]]

	if type(arg) == "table" then
		for _index: number, entry: any in ipairs(arg) do
			-- Stop at the first entry outside the dictionary
			if not Module._isInDictionary(entry, dictData) then
				return false
			end
		end

		return true
	end

	--[[ Returning ]]

	return table.find(dictData, `{arg}`) ~= nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
