--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _module = script:FindFirstAncestor(_localName)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

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

--- @class AdminPanel_CommandBar_Global_Register
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _shared AdminPanel_CommandBar_GlobalShared
function Module.Init(_shared)
	state = _shared.state

	utils = _shared.utils
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Register Control

--%%%%%%%%%%%%%%%%%%%% Register

--[[
	Registers command using the given setup table.
]]
--- @param setupTable AdminPanel_CommandBar_CommandSetupTable
--- @return boolean
--- @return string?
function Module.Register(commandIdentifier: string, setupTable)
	local commands = state.commands
	local aliases = state.aliases
	local callbacks = state.callbacks

	--%%%%%%%%%%%%%%%%%%%% Local Variables

	--- @type AdminPanel_CommandBar_CommandData_Global
	local newCommandTable = {
		uuid = I.Obfuscate.GetRandomString(16),

		baseVariant = nil,
		callbacksUUIDs = {},
	}

	--%%%%%%%%%%%%%%%%%%%% Local Functions

	--[[
		Validates the given variant data, and transforms it so it can be send to clients by saving the callbacks outside of the table.
	]]
	--- @param variantData AdminPanel_CommandBar_CommandSetupTable
	--- @return boolean
	--- @return AdminPanel_CommandBar_VariantData?
	local function transformVariantTable(variantData, debugPrefix: string, baseTable: boolean)
		--- @type AdminPanel_CommandBar_VariantData
		local transformedVariant = {
			aliases = {},
			args = nil,
			variants = nil,

			callbackUUID = nil,
			permissionLevel = nil,

			callbackUUID_globalReturn = nil,
			globalReturnArgsCount = nil,

			passInvoker = false,
			globalEnabled = false,
			globalOutput = false,

			variantsAreGlobal = false,
		}

		--%%%%%%%%%%%%%%%%%%%% Aliases

		if variantData.Aliases and type(variantData.Aliases) == "table" and #variantData.Aliases >= 1 then
			for _, alias: string in ipairs(variantData.Aliases) do
				--[[ Checks ]]

				-- Invalid type
				if type(alias) ~= "string" then
					warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - ({alias}: {typeof(alias)}) is not a valid command alias!`)
					continue
				end

				-- Already registered
				if baseTable and aliases[alias] then
					warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - Alias ({alias}) is already registered!`)
					continue
				end

				-- Whitespace check
				if alias:match("%s+") then
					warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - Alias ({alias}) cannot contain whitespaces!`)
					continue
				end

				--[[ Saving ]]

				table.insert(transformedVariant["aliases"], alias)
			end
		else
			warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - ({variantData.Aliases}) is not a valid 'Aliases' table!`)
			return false
		end

		-- Updating debug prefix to match the current variant
		debugPrefix = `{debugPrefix}||{variantData.Aliases[1]}`

		--%%%%%%%%%%%%%%%%%%%% General Checks

		-- Args exists but no callback is set
		if variantData.Args and not variantData.Callback then
			warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - Arguments table exists but no callback is declared!`)
			return false
		end

		-- Command is empty without args, variants and callback
		if not variantData.Args and not variantData.Variants and not variantData.Callback then
			warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - Command is missing 'Args', 'Variants' tables and 'Callback' function!`)
			return false
		end

		--%%%%%%%%%%%%%%%%%%%% Pass Invoker

		transformedVariant.passInvoker = variantData.PassInvoker == true

		--%%%%%%%%%%%%%%%%%%%% Arguments

		if variantData.Args then
			-- Creating args table
			transformedVariant.args = {}

			if type(variantData.Args) == "table" and #variantData.Args >= 1 then
				--- @param argData AdminPanel_CommandBar_CommandDataArgTable
				for _, argData in ipairs(variantData.Args) do
					if type(argData) == "table" then
						--[[ Name Checks ]]

						if not argData.name or type(argData.name) ~= "string" then
							warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - Argument 'name' - ({argData.name}: {typeof(argData.name)}) is not valid type!`)
							return false
						end

						--[[ Types Check ]]

						if argData.types and type(argData.types) == "table" and #argData.types >= 1 then
							-- Search for invalid arg types
							for _, argType: string in ipairs(argData.types) do
								if not table.find(_settings.ARG_TYPES, argType) then
									warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - Argument type ({argType}) is not valid!`)
									return false
								end
							end

							--[[ Sorting Args ]]

							--[[
								Sorting arguments so when they're used later the expected type is chosen first.
								If there are two types { Player, string } - we want Player to have higher priority.
							]]
							table.sort(argData.types, function(a: string, b: string)
								local lastIndex: number = #_settings.ARG_TYPES + 1
								return (table.find(_settings.ARG_TYPES, a) or lastIndex) < (table.find(_settings.ARG_TYPES, b) or lastIndex)
							end)

							--[[ Boolean Dict ]]

							-- Only boolean values have boolean dictionary set by default
							if #argData.types == 1 and argData.types[1] == "boolean" then
								argData.requireDict = true
								argData.dict = "boolean"
							end
						else
							warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - Types table ({argData.types}) is not valid!`)
							return false
						end

						--[[ Dictionary Check ]]

						if argData.requireDict and (not argData.dict or type(argData.dict) ~= "string") then
							warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - Dictionary is required but it's not valid!`)
							return false
						end

						if argData.dictNegate and not argData.dict then
							warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - Dictionary negate is present, but the default dictionary is missing!`)
							return false
						end

						--[[ Saving ]]

						table.insert(transformedVariant.args, {
							--[[ General ]]

							name = argData.name,
							types = argData.types,
							optional = argData.optional == true,

							--[[ Dictionary ]]

							dict = argData.dict,
							dictNegate = argData.dictNegate,
							requireDict = argData.requireDict == true,
						})
					else
						warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - ({argData}) is not a valid argument!`)
						return false
					end
				end
			else
				warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - ({variantData.Args}) is not a valid Args table!`)
				return false
			end
		end

		--%%%%%%%%%%%%%%%%%%%% Permission Level

		if variantData.PermissionLevel and type(variantData.PermissionLevel) == "number" then
			-- Clamping permission level to range
			transformedVariant.permissionLevel = math.clamp(math.round(variantData.PermissionLevel), _settings.PERMISSION_LEVEL_RANGE.Min, _settings.PERMISSION_LEVEL_RANGE.Max)
		elseif baseTable then
			-- Setting the base permission to max if it's missing, variants without one inherit their parent's
			transformedVariant.permissionLevel = _settings.PERMISSION_LEVEL_RANGE.Max
		end

		--%%%%%%%%%%%%%%%%%%%% Global Command

		if variantData.EnableGlobally ~= nil and I.Env.IsServer then
			transformedVariant.globalEnabled = variantData.EnableGlobally == true
		end

		if variantData.GlobalOutput ~= nil and I.Env.IsServer then
			if variantData.EnableGlobally then
				transformedVariant.globalOutput = variantData.GlobalOutput == true
			else
				warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - 'GlobalOutput' is set, but the command is not enabled globally!`)
				return false
			end
		end

		if variantData.Callback_GlobalReturn and I.Env.IsServer then
			if variantData.EnableGlobally then
				if type(variantData.Callback_GlobalReturn) == "function" then
					--[[ Getting UUID ]]

					local callbackUUID: string = I.Obfuscate.GetRandomString(16)

					--[[ Saving ]]

					callbacks[callbackUUID] = variantData.Callback_GlobalReturn
					transformedVariant.callbackUUID_globalReturn = callbackUUID

					-- Passing no return args unless 'GlobalReturnArgsCount' is set
					transformedVariant.globalReturnArgsCount = 0

					-- Saving command to command table
					table.insert(newCommandTable.callbacksUUIDs, callbackUUID)
				else
					warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - ({variantData.Callback_GlobalReturn}) is not a valid 'Callback_GlobalReturn' function!`)
					return false
				end
			else
				warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - 'Callback_GlobalReturn' is set, but the command is not enabled globally!`)
				return false
			end
		end

		if variantData.GlobalReturnArgsCount and I.Env.IsServer then
			if variantData.EnableGlobally then
				if tonumber(variantData.GlobalReturnArgsCount) and tonumber(variantData.GlobalReturnArgsCount) >= 0 then
					transformedVariant.globalReturnArgsCount = tonumber(variantData.GlobalReturnArgsCount)
				else
					warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - ({variantData.GlobalReturnArgsCount}) is not a valid 'GlobalReturnArgsCount'!`)
					return false
				end
			else
				warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - 'GlobalReturnArgsCount' is set, but the command is not enabled globally!`)
				return false
			end
		end

		--%%%%%%%%%%%%%%%%%%%% Callback

		if variantData.Callback then
			if type(variantData.Callback) == "function" then
				--[[ Getting UUID ]]

				local callbackUUID: string = I.Obfuscate.GetRandomString(16)

				--[[ Saving ]]

				callbacks[callbackUUID] = variantData.Callback
				transformedVariant.callbackUUID = callbackUUID

				-- Saving command to command table
				table.insert(newCommandTable.callbacksUUIDs, callbackUUID)
			else
				warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - ({variantData.Callback}) is not a valid 'Callback' function!`)
				return false
			end
		end

		--%%%%%%%%%%%%%%%%%%%% Variants

		if variantData.Variants and type(variantData.Variants) == "table" and #variantData.Variants >= 1 then
			-- Creating variants table
			transformedVariant.variants = {}

			-- Table for tracking which aliases were used to avoid duplicated for current variants
			local variantsAliases = {} --- @type { string }

			--[[ Validating Variants ]]

			--- @param innerVariantData AdminPanel_CommandBar_CommandSetupTable
			for _, innerVariantData in ipairs(variantData.Variants) do
				--[[ Variant Type Check ]]

				if type(innerVariantData) ~= "table" then
					warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - Variant ({innerVariantData}: {typeof(innerVariantData)}) is of invalid type!`)
					return false
				end

				--[[ Aliases Check ]]

				if innerVariantData.Aliases then
					for _, alias: string in ipairs(innerVariantData.Aliases) do
						if table.find(variantsAliases, alias) then
							warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - Alias ({alias}) for variants is duplicated!`)
							return false
						end
					end
				end

				--[[ Transforming Variant ]]

				--- @param commandData AdminPanel_CommandBar_VariantData
				local success: boolean, innerTransformedVariant = transformVariantTable(innerVariantData, debugPrefix, false)

				--[[ Saving ]]

				if success then
					-- Saving aliases
					for _, alias: string in ipairs(innerVariantData.Aliases) do
						table.insert(variantsAliases, alias)
					end

					-- Saving variant
					table.insert(transformedVariant.variants, innerTransformedVariant)
				else
					warn(`[{_localName}::{script.Name}]: Command [{debugPrefix}] - Variant transform failed!`)
					return false
				end
			end

			--[[ Updating Global Child Variants ]]

			--- @param loopVariantData AdminPanel_CommandBar_VariantData
			for _, loopVariantData in ipairs(transformedVariant.variants) do
				if loopVariantData.globalEnabled then
					transformedVariant.variantsAreGlobal = true
					break
				end
			end
		end

		--%%%%%%%%%%%%%%%%%%%% Returning

		return true, transformedVariant
	end

	--%%%%%%%%%%%%%%%%%%%% Registering

	--- @param baseVariant AdminPanel_CommandBar_VariantData
	local success: boolean, baseVariant = transformVariantTable(setupTable, commandIdentifier, true)
	if not success then
		-- Removing callbacks
		for _, callbackUUID: string in ipairs(newCommandTable.callbacksUUIDs) do
			callbacks[callbackUUID] = nil
		end

		return false
	end

	--[[ Updating Permissions ]]

	utils.UpdateVariantPermissionLevel(baseVariant, commandIdentifier)

	--[[ Saving ]]

	-- Saving base aliases globally
	for _, alias: string in ipairs(baseVariant.aliases) do
		aliases[alias] = newCommandTable
	end

	-- Saving base variant
	newCommandTable.baseVariant = baseVariant

	-- Saving command
	table.insert(commands, newCommandTable)

	--[[ Updating Client ]]

	-- Clearing the copies built for each permission level
	table.clear(state.commandsCache)

	_module:SetAttribute(`AdminPanel_CommandsVersion_{I.Env.Key}`, math.random(-10 ^ 6, 10 ^ 6))

	--[[ Returning ]]

	return success, newCommandTable.uuid
end

--%%%%%%%%%%%%%%%%%%%% Unregister

--[[
	Unregisters command and removes all connections to it.
]]
function Module.Unregister(commandUUID: string)
	local commands = state.commands
	local aliases = state.aliases
	local callbacks = state.callbacks

	--[[ Getting Command ]]

	--- @type AdminPanel_CommandBar_CommandData_Global
	local foundCommand
	for _, commandData in ipairs(commands) do
		if commandData.uuid == commandUUID then
			foundCommand = commandData
			break
		end
	end

	if not foundCommand then
		warn(`[{_localName}::{script.Name}]: Command with UUID ({commandUUID}) was not found!`)
		return
	end

	--[[ Removing ]]

	-- Removing global aliases
	for _, alias: string in ipairs(foundCommand.baseVariant.aliases) do
		aliases[alias] = nil
	end

	-- Removing callbacks
	for _, callbackUUID: string in ipairs(foundCommand.callbacksUUIDs) do
		callbacks[callbackUUID] = nil
	end

	-- Removing command
	local commandPos: number = table.find(commands, foundCommand)
	if commandPos then
		table.remove(commands, commandPos)
	end

	--[[ Updating Client ]]

	-- Clearing the copies built for each permission level
	table.clear(state.commandsCache)

	_module:SetAttribute(`AdminPanel_CommandsVersion_{I.Env.Key}`, math.random(-10 ^ 6, 10 ^ 6))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
