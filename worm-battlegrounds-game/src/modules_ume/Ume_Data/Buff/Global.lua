--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Buff"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type Buff_Buffs
local buffsData = require(I.Dirs.GlobalData.Buff.Buff)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Table for storing buffs on the client
local clientBuffs: table

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Has Command Permission

--[[
	Returns whether the player may use the buff commands, the only users of the debug remotes.
]]
--- @return boolean
local function hasCommandPermission(player: Player)
	return I.AdminPanel.GetPermissionLevel(player) >= 255
end

--%%%%%%%%%%%%%%%%%%%% Get Buffs Table

--[[
	Returns the player's buff session table on the server, or the local buff table on the client.
]]
--- @return Buff_State
local function getBuffsTable(player: Player?)
	return I.Env.IsServer and I.Player.Sessions[player].Data["Buff"] or clientBuffs
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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	----------- DATA -----------
	----------------------------

	if I.Env.IsServer then
		--- @type Player_SessionData
		local _st = I.Player.SessionTemplate
		_st["Buff"] = {
			Current = {}, --- @type { [string]: Buff_BuffTable }
			Expiry = {}, --- @type { [string]: { [string]: number } }
		}
	elseif I.Env.IsClient then
		clientBuffs = {
			Current = {}, --- @type { [string]: Buff_BuffTable }
			Expiry = {}, --- @type { [string]: { [string]: number } }
		}
	end

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._createEntries()
	Module._createIndividualTopics()

	if I.Env.IsServer then
		I.G_Player.OnPlayerAdded(I.Priority.Replicator, Module._createReplicator)
		I.G_Player.OnPlayerAdded(I.Priority.Late, Module._registerCommandDictionariesForPlayer)
	end

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	if I.Env.IsServer then
		I.Topic.Register("Buff_Updated", { "Player", "string", { Types = { "string", "number" } } })
	elseif I.Env.IsClient then
		I.Topic.Register("Buff_Updated", { "string", { Types = { "string", "number" } } })
	end

	--- @Network
	if I.Env.IsServer then
		I.Network.GetFunction("Buff_Set")

		--[[ Get ]]

		I.Network.GetFunction("Buff_GetSum", { "Player", "string" })
		I.Network.GetFunction("Buff_GetValues", { "Player", "string" })
		I.Network.GetFunction("Buff_GetValue", { "Player", "string", "string" })

		I.Network.OnInvoke("Buff_GetSum", function(player: Player, buffName: string)
			return hasCommandPermission(player) and Module.GetSum(buffName, player) or nil
		end)
		I.Network.OnInvoke("Buff_GetValues", function(player: Player, buffName: string)
			return hasCommandPermission(player) and Module.GetValues(buffName, player) or nil
		end)
		I.Network.OnInvoke("Buff_GetValue", function(player: Player, buffName: string, valueName: string)
			return hasCommandPermission(player) and Module.GetValue(buffName, valueName, player) or nil
		end)

		--[[ Get All ]]

		I.Network.GetFunction("Buff_GetAll", { "Player" })
		I.Network.GetFunction("Buff_GetAllSums", { "Player" })
		I.Network.GetFunction("Buff_GetAllValues", { "Player" })

		I.Network.OnInvoke("Buff_GetAll", function(player: Player)
			return hasCommandPermission(player) and Module.GetAll(player) or nil
		end)
		I.Network.OnInvoke("Buff_GetAllSums", function(player: Player)
			return hasCommandPermission(player) and Module.GetAllSums(player) or nil
		end)
		I.Network.OnInvoke("Buff_GetAllValues", function(player: Player)
			return hasCommandPermission(player) and Module.GetAllValues(player) or nil
		end)
	elseif I.Env.IsClient then
		I.Network.GetFunction("Buff_Set", {
			"string",
			"string",
			{ Types = { "number", "string" }, Optional = true },
		})

		--[[ Get ]]

		I.Network.GetFunction("Buff_GetSum", { "string" })
		I.Network.GetFunction("Buff_GetValues", { "string" })
		I.Network.GetFunction("Buff_GetValue", { "string", "string" })

		I.Network.OnInvoke("Buff_Set", Module.Set)
		I.Network.OnInvoke("Buff_GetSum", Module.GetSum)
		I.Network.OnInvoke("Buff_GetValues", Module.GetValues)
		I.Network.OnInvoke("Buff_GetValue", Module.GetValue)

		--[[ Get All ]]

		I.Network.GetFunction("Buff_GetAll", {})
		I.Network.GetFunction("Buff_GetAllSums", {})
		I.Network.GetFunction("Buff_GetAllValues", {})

		I.Network.OnInvoke("Buff_GetAll", Module.GetAll)
		I.Network.OnInvoke("Buff_GetAllSums", Module.GetAllSums)
		I.Network.OnInvoke("Buff_GetAllValues", Module.GetAllValues)
	end

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Buff = {

		--[[ Control ]]

		Set = Module.Set,
		SetTimed = Module.SetTimed,

		Recalculate = Module.Recalculate,
		RecalculateAll = Module.RecalculateAll,

		--[[ Methods ]]

		-- Get
		GetSum = Module.GetSum,
		GetValues = Module.GetValues,
		GetValue = Module.GetValue,

		-- Get All
		GetAll = Module.GetAll,
		GetAllSums = Module.GetAllSums,
		GetAllValues = Module.GetAllValues,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Module._mainLoop()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Main Loop

--[[
	Removes timed buff values whose duration ran out, once a second.
]]
function Module._mainLoop()
	I.DoEvery.Every(1, function()
		--[[ Client ]]

		-- Sweep only the local buffs on the client
		if I.Env.IsClient then
			Module._removeExpiredValues()
			return
		end

		--[[ Server ]]

		for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
			local success: boolean
			local result: any | string?
			success, result = pcall(Module._removeExpiredValues, player)
			if not success then
				warn(`[{_localName}::{script.Name}]: Failed to remove expired buff values for ({player.Name})! - ({result})`)
			end
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Remove Expired Values

--[[
	Removes the timed values whose duration ran out, for the player on the server or locally on the client.
]]
function Module._removeExpiredValues(player: Player?)
	-- Check if player is valid | SERVER
	if I.Env.IsServer and not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Buff_State
	local buffsTable = getBuffsTable(player)

	--[[ Finding Expired ]]

	local timestamp: number = os.clock()
	local expiredValues = {} --- @type { { string } }

	--- @param valueEndTimes { [string]: number }
	for buffName: string, valueEndTimes in pairs(buffsTable.Expiry) do
		for valueName: string, endTime: number in pairs(valueEndTimes) do
			-- Collect a value whose duration ran out
			if endTime <= timestamp then
				table.insert(expiredValues, { buffName, valueName })
			end
		end
	end

	--[[ Removing ]]

	--- @param expiredValue { string }
	for _index: number, expiredValue in ipairs(expiredValues) do
		Module.Set(expiredValue[1], expiredValue[2], nil, player)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Entries

--[[
	Checks every predefined buff and creates its entry in the session template.
	Errors on a bad default or an unknown Mode.
]]
function Module._createEntries()
	--[[ Getting Buff Table ]]

	--- @type Buff_State?
	local buffsTable = I.Env.IsServer and I.Player.SessionTemplate["Buff"] or (I.Env.IsClient and clientBuffs) or nil

	--[[ Checks ]]

	-- Check if the environment has a buff table
	if not buffsTable then
		warn(`[{_localName}::{script.Name}]: Buff table is missing for ({I.Env.Key}) environment!`)
		return
	end

	-- Check if the environment has Buff global data
	if not buffsData[I.Env.Key] then
		warn(`[{_localName}::{script.Name}]: ({I.Env.Key}) environment is missing its Buff global data!`)
		return
	end

	--[[ Creating Entries ]]

	--- @param buffData Buff_BuffData
	for name: string, buffData in pairs(buffsData[I.Env.Key]) do
		--[[ Checks ]]

		-- Check if the default is a number or an integer string
		if type(buffData.DefaultValue) ~= "number" and not I.Number.IsIntegerString(buffData.DefaultValue) then
			error(`[{_localName}::{script.Name}]: DefaultValue ({buffData.DefaultValue}) of Buff ({name}) is neither a number nor an integer string!`)
		end

		-- Check if the mode is known
		if buffData.Mode ~= nil and buffData.Mode ~= "Add" and buffData.Mode ~= "Multiply" and buffData.Mode ~= "Max" then
			error(`[{_localName}::{script.Name}]: Mode ({buffData.Mode}) of Buff ({name}) is not Add, Multiply or Max!`)
		end

		--[[ Creating Entry ]]

		buffsTable.Current[name] = {
			Values = {
				Standard = buffData.DefaultValue,
			},
			Sum = buffData.DefaultValue,
		}
	end
end

--%%%%%%%%%%%%%%%%%%%% Create Replicator

--[[
	Creates folder in the player's replicator for storing buffs.
]]
function Module._createReplicator(player: Player)
	-- Check if player is valid | SERVER
	if not I.Env.IsServer or not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Buff"]

	--[[ Creating Folder ]]

	I.Replicator.CreateFolder(player, _localName)

	--[[ Adding Attributes ]]

	--- @param buffData Buff_BuffData
	for buffName: string, buffData in pairs(buffsData[I.Env.Key]) do
		-- Skip buffs the client doesn't see
		if not buffData.ClientUpdate then
			continue
		end

		I.Replicator.Set(player, _localName, buffName, moduleSessionData.Current[buffName].Sum)
	end
end

--%%%%%%%%%%%%%%%%%%%% Create Individual Topics

--[[
	Creates individual topics for each buff.
]]
function Module._createIndividualTopics()
	--[[ Checks ]]

	-- Missing buffs for environment
	if not buffsData[I.Env.Key] then
		warn(`[{_localName}::{script.Name}]: ({I.Env.Key}) environment is missing its Buff global data!`)
		return
	end

	--[[ Creating Entries ]]

	--- @param buffData Buff_BuffData
	for name: string, buffData in pairs(buffsData[I.Env.Key]) do
		if I.Env.IsServer and buffData.ServerUpdateIndividual then
			I.Topic.Register(`Buff_Updated-{name}`, { "Player", { Types = { "string", "number" } } })
		elseif I.Env.IsClient and buffData.ClientUpdateIndividual then
			I.Topic.Register(`Buff_Updated-{name}`, { { Types = { "string", "number" } } })
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Register Command Dictionaries For Player

--[[
	Registers dictionaries used by module commands for player.
]]
function Module._registerCommandDictionariesForPlayer(player: Player)
	-- Check if player is valid | SERVER
	if not I.Env.IsServer or not I.Player.Valid(player) then
		return
	end

	--[[ Updating Directories ]]

	--- @param buffData Buff_BuffData
	for name: string, _buffData in pairs(buffsData.Server) do
		I.AdminPanel_CommandBar.SetDictionary(`Buff_BuffValues-{player.Name}-{name}`, { "Standard" }, 255, { BoundTo = player.UserId })
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set

--[[
	Updates value of a buff and recalculates it.
	Clears the duration of a value set with SetTimed.
]]
--- @return boolean
function Module.Set(buffName: string, valueName: string, value: number | string, player: Player?)
	--[[ Checks ]]

	--- @type Buff_BuffData
	local buffData = buffsData[I.Env.Key][buffName]

	-- Check if the buff exists
	if not buffData then
		warn(`[{_localName}::{script.Name}]: ({buffName}) is not a valid Buff`)
		return false
	end

	-- Check if the value is a number, a string or nil
	if type(value) ~= "number" and type(value) ~= "string" and value ~= nil then
		warn(`[{_localName}::{script.Name}]: Invalid value type. Expected (string, number, nil), got ({value}: {typeof(value)})!`)
		return false
	end

	-- Check if the value fits the buff's type
	if value then
		-- Check if a BigNum buff gets an integer string
		if type(buffData.DefaultValue) == "string" and string.match(value, "^%-?%d+$") == nil then
			warn(`[{_localName}::{script.Name}]: Invalid value type. Expected (string, nil), got ({value}: {typeof(value)}) for Buff ({buffName})!`)
			return false
		end

		-- Check if a number buff gets a number
		if type(buffData.DefaultValue) == "number" and string.match(`{value}`, "^%-?%d+%.?%d*$") == nil then
			warn(`[{_localName}::{script.Name}]: Invalid value type. Expected (number, nil), got ({value}: {typeof(value)}) for Buff ({buffName})!`)
			return false
		end
	end

	--[[ Fixing Standard nil ]]

	-- Reset Standard to the default instead of removing it
	if valueName == "Standard" and value == nil then
		value = buffData.DefaultValue
	end

	--[[ Getting Buff Table ]]

	local buffsTable --- @type Buff_State

	if I.Env.IsServer then
		-- Check if player is valid | SERVER
		if not I.Player.Valid(player) then
			return false
		end

		--[[ Data ]]

		--- @type Player_SessionData
		local sessionData = I.Player.Sessions[player].Data
		local moduleSessionData = sessionData["Buff"]

		buffsTable = moduleSessionData
	elseif I.Env.IsClient then
		buffsTable = clientBuffs
	end

	--[[ Dictionary Update Data ]]

	-- Keep the value names dictionary current on the client, and on the server only in Studio
	local updateDict: boolean = (I.Env.IsClient or I.Env.IsStudio) and (value == nil or buffsTable.Current[buffName].Values[valueName] == nil)

	--[[ Setting Value ]]

	if value ~= nil then
		if type(buffData.DefaultValue) == "string" then
			buffsTable.Current[buffName].Values[valueName] = `{value}`
		elseif type(buffData.DefaultValue) == "number" then
			buffsTable.Current[buffName].Values[valueName] = tonumber(value)
		end
	else
		buffsTable.Current[buffName].Values[valueName] = nil
	end

	--[[ Clearing Duration ]]

	-- Drop the end time of a timed value
	if buffsTable.Expiry[buffName] then
		buffsTable.Expiry[buffName][valueName] = nil

		-- Drop the buff's end times once none are left
		if next(buffsTable.Expiry[buffName]) == nil then
			buffsTable.Expiry[buffName] = nil
		end
	end

	--[[ Recalculating ]]

	Module.Recalculate(buffName, player)

	--[[ Updating Dictionaries ]]

	if updateDict then
		if I.Env.IsClient then
			if value then
				I.AdminPanel_CommandBar.UpdateDictionary(`Buff_BuffValues-{buffName}`, { valueName }, nil)
			else
				I.AdminPanel_CommandBar.UpdateDictionary(`Buff_BuffValues-{buffName}`, nil, { valueName })
			end
		elseif I.Env.IsServer then
			if value then
				I.AdminPanel_CommandBar.UpdateDictionary(`Buff_BuffValues-{player.Name}-{buffName}`, { valueName }, nil, 255, { BoundTo = player.UserId })
			else
				I.AdminPanel_CommandBar.UpdateDictionary(`Buff_BuffValues-{player.Name}-{buffName}`, nil, { valueName }, 255, { BoundTo = player.UserId })
			end
		end
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Set Timed

--[[
	Sets a buff value that is removed again after `duration` seconds, for the session only.
	Setting the same value again, timed or not, replaces its duration.
]]
--- @return boolean
function Module.SetTimed(buffName: string, valueName: string, value: number | string, duration: number, player: Player?)
	--[[ Checks ]]

	-- Check if duration is a positive number
	if type(duration) ~= "number" or not (duration > 0) then
		warn(`[{_localName}::{script.Name}]: Invalid (duration). Expected a number above 0, got ({duration}: {typeof(duration)})!`)
		return false
	end

	-- Check if a value is given
	if value == nil then
		warn(`[{_localName}::{script.Name}]: Timed Value ({valueName}) of Buff ({buffName}) needs a value!`)
		return false
	end

	--[[ Setting Value ]]

	-- Stop when the value was rejected
	if not Module.Set(buffName, valueName, value, player) then
		return false
	end

	--[[ Data ]]

	--- @type Buff_State
	local buffsTable = getBuffsTable(player)

	--[[ Saving ]]

	-- Create the buff's end times on first use
	if not buffsTable.Expiry[buffName] then
		buffsTable.Expiry[buffName] = {}
	end

	buffsTable.Expiry[buffName][valueName] = os.clock() + duration

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Recalculating

--%%%%%%%%%%%%%%%%%%%% Recalculate All

--[[
	Recalculates all buffs for player or locally if called on client.
]]
function Module.RecalculateAll(player: Player?)
	--[[ Server ]]

	if I.Env.IsServer then
		-- Check if player is valid | SERVER
		if not I.Player.Valid(player) then
			return
		end

		for name, _ in pairs(buffsData[I.Env.Key]) do
			Module.Recalculate(name, player)
		end
	end

	--[[ Client ]]

	if I.Env.IsClient then
		for name, _ in pairs(buffsData[I.Env.Key]) do
			Module.Recalculate(name)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Recalculate

--[[
	Recalculates all `buffName` buff for player or locally if called on client.
	Combines the values by the buff's Mode: added (the default), multiplied, or the largest one.
]]
function Module.Recalculate(buffName: string, player: Player?)
	--[[ Getting Table ]]

	local currentTable --- @type Buff_State?

	if I.Env.IsServer and player and I.Player.Valid(player) then
		--- @type Player_SessionData
		local sessionData = I.Player.Sessions[player].Data
		currentTable = sessionData["Buff"]
	end

	if I.Env.IsClient then
		if not currentTable then
			currentTable = clientBuffs
		end
	end

	--[[ Checks ]]

	-- Check if a buff table was found
	if not currentTable then
		return
	end

	--[[ Buff Data ]]

	--- @type Buff_BuffData
	local buffData = buffsData[I.Env.Key][buffName]

	-- Check if the buff exists
	if not buffData or not currentTable.Current[buffName] then
		warn(`[{_localName}::{script.Name}]: ({buffName}) is not a valid Buff`)
		return
	end

	--[[ Local Variables ]]

	local isBigNum: boolean = type(buffData.DefaultValue) == "string"
	local mode: string = buffData.Mode or "Add"
	local sum --- @type number | BigNum_Instance | nil

	--[[ Combining Values ]]

	for _name: string, value: number | string in pairs(currentTable.Current[buffName].Values) do
		--[[ Converting ]]

		local typedValue = isBigNum and I.BN.new(value) or value --- @type number | BigNum_Instance

		--[[ Combining ]]

		-- Start from the first value
		if sum == nil then
			sum = typedValue
		elseif mode == "Multiply" then
			sum *= typedValue
		elseif mode == "Max" then
			sum = typedValue > sum and typedValue or sum
		else
			sum += typedValue
		end
	end

	--[[ Saving ]]

	if isBigNum then
		currentTable.Current[buffName].Sum = tostring(sum or I.BN.new("0"))
	else
		currentTable.Current[buffName].Sum = sum or 0
	end

	--[[ Publishing Changes ]]

	-- Global Publish
	if (I.Env.IsServer and buffData.ServerUpdate) or (I.Env.IsClient and buffData.ClientUpdate) then
		if I.Env.IsServer then
			I.Topic.Publish("Buff_Updated", player, buffName, currentTable.Current[buffName].Sum)
		elseif I.Env.IsClient then
			I.Topic.Publish("Buff_Updated", buffName, currentTable.Current[buffName].Sum)
		end
	end

	-- Updating Replicator
	if I.Env.IsServer and buffData.ClientUpdate then
		I.Replicator.Set(player, _localName, buffName, currentTable.Current[buffName].Sum)
	end

	-- Individual Publish
	if I.Env.IsServer and buffData.ServerUpdateIndividual then
		I.Topic.Publish(`Buff_Updated-{buffName}`, player, currentTable.Current[buffName].Sum)
	elseif I.Env.IsClient and buffData.ClientUpdateIndividual then
		I.Topic.Publish(`Buff_Updated-{buffName}`, currentTable.Current[buffName].Sum)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Methods

--%%%%%%%%%%%%%%%%%%%% Get Sum

--[[
	Returns sum of the given `buffName`.
]]
--- @return number | string | nil
function Module.GetSum(buffName: string, player: Player?)
	local currentTable: table

	--[[ Getting Table ]]

	-- Server buffs
	if I.Env.IsServer and player and I.Player.Valid(player) then
		--- @type Player_SessionData
		local sessionData = I.Player.Sessions[player].Data
		currentTable = sessionData["Buff"]
	end

	-- Client buffs
	if I.Env.IsClient then
		if not currentTable then
			currentTable = clientBuffs
		end
	end

	--[[ Checks ]]

	-- Invalid table check
	if not currentTable then
		return nil
	end

	-- Making sure buff exists
	if not buffsData[I.Env.Key][buffName] or not currentTable.Current[buffName] then
		warn(`[{_localName}::{script.Name}]: ({buffName}) is not a valid Buff`)
		return nil
	end

	--[[ Returning ]]

	return currentTable.Current[buffName].Sum
end

--%%%%%%%%%%%%%%%%%%%% Get Value

--[[
	Returns `valueName` value of the given `buffName`.
]]
--- @return number | string | nil
function Module.GetValue(buffName: string, valueName: string, player: Player?)
	local currentTable: table

	--[[ Getting Table ]]

	-- Server buffs
	if I.Env.IsServer and player and I.Player.Valid(player) then
		--- @type Player_SessionData
		local sessionData = I.Player.Sessions[player].Data
		currentTable = sessionData["Buff"]
	end

	-- Client buffs
	if I.Env.IsClient then
		if not currentTable then
			currentTable = clientBuffs
		end
	end

	--[[ Checks ]]

	-- Invalid table check
	if not currentTable then
		return nil
	end

	-- Making sure buff exists
	if not buffsData[I.Env.Key][buffName] or not currentTable.Current[buffName] then
		warn(`[{_localName}::{script.Name}]: ({buffName}) is not a valid Buff`)
		return nil
	end

	-- Invalid value
	if not currentTable.Current[buffName].Values[valueName] then
		warn(`[{_localName}::{script.Name}]: Value ({valueName}) is not set for Buff ({buffName})!`)
		return nil
	end

	--[[ Returning ]]

	return currentTable.Current[buffName].Values[valueName]
end

--%%%%%%%%%%%%%%%%%%%% Get Values

--[[
	Returns all values of the given `buffName`.
]]
--- @return { [string]: number | string } | nil
function Module.GetValues(buffName: string, player: Player?)
	local currentTable: table

	--[[ Getting Table ]]

	-- Server buffs
	if I.Env.IsServer and player and I.Player.Valid(player) then
		--- @type Player_SessionData
		local sessionData = I.Player.Sessions[player].Data
		currentTable = sessionData["Buff"]
	end

	-- Client buffs
	if I.Env.IsClient then
		if not currentTable then
			currentTable = clientBuffs
		end
	end

	--[[ Checks ]]

	-- Invalid table check
	if not currentTable then
		return nil
	end

	-- Making sure buff exists
	if not buffsData[I.Env.Key][buffName] or not currentTable.Current[buffName] then
		warn(`[{_localName}::{script.Name}]: ({buffName}) is not a valid Buff`)
		return nil
	end

	--[[ Returning ]]

	return I.Table.DeepCopy(currentTable.Current[buffName].Values)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get All Methods

--%%%%%%%%%%%%%%%%%%%% Get All

--[[
	Returns table containing all buffs and their data.
]]
--- @return { [string]: Buff_BuffTable }
function Module.GetAll(player: Player?)
	local currentTable: table

	--[[ Getting Table ]]

	-- Server buffs
	if I.Env.IsServer and player and I.Player.Valid(player) then
		--- @type Player_SessionData
		local sessionData = I.Player.Sessions[player].Data
		currentTable = sessionData["Buff"]
	end

	-- Client buffs
	if I.Env.IsClient then
		if not currentTable then
			currentTable = clientBuffs
		end
	end

	--[[ Checks ]]

	-- Invalid table check
	if not currentTable then
		return nil
	end

	--[[ Returning ]]

	return I.Table.DeepCopy(currentTable.Current)
end

--%%%%%%%%%%%%%%%%%%%% Get All Sums

--[[
	Returns table containing all buff sums.
]]
--- @return { [string]: number | string }
function Module.GetAllSums(player: Player?)
	local currentTable: table

	--[[ Getting Table ]]

	-- Server buffs
	if I.Env.IsServer and player and I.Player.Valid(player) then
		--- @type Player_SessionData
		local sessionData = I.Player.Sessions[player].Data
		currentTable = sessionData["Buff"]
	end

	-- Client buffs
	if I.Env.IsClient then
		if not currentTable then
			currentTable = clientBuffs
		end
	end

	--[[ Checks ]]

	-- Invalid table check
	if not currentTable then
		return nil
	end

	--[[ Returning ]]

	local allSums = {} --- @type { [string]: number | string }

	--- @param buffData Buff_BuffTable
	for buffName: string, buffData in pairs(currentTable.Current) do
		allSums[buffName] = buffData.Sum
	end

	return allSums
end

--%%%%%%%%%%%%%%%%%%%% Get All Values

--[[
	Returns table containing all Buff values tables.
]]
--- @return { [string]: { [string]: number | string } }
function Module.GetAllValues(player: Player?)
	local currentTable: table

	--[[ Getting Table ]]

	-- Server buffs
	if I.Env.IsServer and player and I.Player.Valid(player) then
		--- @type Player_SessionData
		local sessionData = I.Player.Sessions[player].Data
		currentTable = sessionData["Buff"]
	end

	-- Client buffs
	if I.Env.IsClient then
		if not currentTable then
			currentTable = clientBuffs
		end
	end

	--[[ Checks ]]

	-- Invalid table check
	if not currentTable then
		return nil
	end

	--[[ Returning ]]

	local allValues = {} --- @type { [string]: number | string }

	--- @param buffData Buff_BuffTable
	for buffName: string, buffData in pairs(currentTable.Current) do
		allValues[buffName] = I.Table.DeepCopy(buffData.Values)
	end

	return allValues
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
