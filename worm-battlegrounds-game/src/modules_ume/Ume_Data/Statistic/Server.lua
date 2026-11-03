--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Statistic"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type Statistic_Statistics
local statisticsData = require(I.Dirs.GlobalData.Statistic.Statistic)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ BigNum ]]

local zeroBN = I.BN.new("0")

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

	--- @type Player_ProfileData
	local _pt = I.Player.ProfileTemplate
	_pt["Statistic"] = {
		["Standard"] = {}, --- @type { [string]: string }
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._createEntries()
	Module._createIndividualTopics()

	I.G_Player.OnPlayerAdded(I.Priority.Replicator, Module._createReplicator)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Statistic_Updated", { "Player", "string", "string", "string" })

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Statistic = {

		--[[ Control ]]

		Add = Module.Add,
		Subtract = Module.Subtract,
		Set = Module.Set,

		--[[ Methods ]]

		Get = Module.Get,
		GetAll = Module.GetAll,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Entries

--[[
	Checks every predefined statistic and creates its entry in the profile template.
	Errors on a value that isn't an integer string, an empty range, or a replicated name that isn't a valid attribute name.
]]
function Module._createEntries()
	--[[ Data ]]

	--- @type { [string]: string }
	local statisticsTable = I.Player.ProfileTemplate["Statistic"].Standard

	--[[ Creating Entries ]]

	--- @param statisticData Statistic_Statistic
	for statisticName: string, statisticData in pairs(statisticsData) do
		--[[ Checks ]]

		-- Check if the default is an integer string
		if not I.Number.IsIntegerString(statisticData.DefaultValue) then
			error(`[{_localName}::{script.Name}]: DefaultValue ({statisticData.DefaultValue}) of Statistic ({statisticName}) is not an integer string!`)
		end

		-- Check if a respected MinValue is an integer string
		if statisticData.RespectMinValue and not I.Number.IsIntegerString(statisticData.MinValue) then
			error(`[{_localName}::{script.Name}]: MinValue ({statisticData.MinValue}) of Statistic ({statisticName}) is not an integer string!`)
		end

		-- Check if a respected MaxValue is an integer string
		if statisticData.RespectMaxValue and not I.Number.IsIntegerString(statisticData.MaxValue) then
			error(`[{_localName}::{script.Name}]: MaxValue ({statisticData.MaxValue}) of Statistic ({statisticName}) is not an integer string!`)
		end

		-- Check if a respected range isn't empty
		if statisticData.RespectMinValue and statisticData.RespectMaxValue and I.BN.new(statisticData.MinValue) > I.BN.new(statisticData.MaxValue) then
			error(`[{_localName}::{script.Name}]: MinValue ({statisticData.MinValue}) of Statistic ({statisticName}) is above its MaxValue ({statisticData.MaxValue})!`)
		end

		-- Check if a replicated name is a valid attribute name
		if statisticData.ClientUpdate and (#statisticName > 100 or string.match(statisticName, "^[%w_]+$") == nil or string.sub(statisticName, 1, 3) == "RBX") then
			error(`[{_localName}::{script.Name}]: Statistic ({statisticName}) has ClientUpdate but is not a valid attribute name! Use letters, digits and _, at most 100 characters, not starting with RBX.`)
		end

		--[[ Saving ]]

		statisticsTable[statisticName] = statisticData.DefaultValue
	end
end

--%%%%%%%%%%%%%%%%%%%% Create Individual Topics

--[[
	Creates individual topics for each statistic.
]]
function Module._createIndividualTopics()
	--- @param statisticData Statistic_Statistic
	for name: string, statisticData in pairs(statisticsData) do
		-- Individual Server Topic
		if statisticData.ServerUpdateIndividual then
			I.Topic.Register(`Statistic_Updated-{name}`, { "Player", "string", "string" })
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Create Replicator

--[[
	Creates a `Statistic` Folder in player's Replicator.
]]
function Module._createReplicator(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Statistic"]

	--[[ Creating Folder ]]

	I.Replicator.CreateFolder(player, _localName)

	--[[ Adding Attributes ]]

	--- @param statisticData Statistic_Statistic
	for statisticName: string, statisticData in pairs(statisticsData) do
		if statisticData.ClientUpdate then
			I.Replicator.Set(player, _localName, statisticName, moduleData.Standard[statisticName] or "0")
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Add

--[[
	**SERVER** |
	Adds `amount` to the `statisticName` for player.
]]
--- @return boolean
function Module.Add(player: Player, statisticName: string, amount: string, sensitiveCap: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Statistic"]

	--[[ Checks ]]

	-- Read the amount as a string
	amount = `{amount}`

	-- Check if the statistic exists
	if not moduleData.Standard[statisticName] or not statisticsData[statisticName] then
		warn(`[{_localName}::{script.Name}]: ({statisticName}) is not a valid Statistic!`)
		return false
	end

	-- Check if the amount is an integer string
	if type(amount) ~= "string" or string.match(amount, "^%-?%d+$") == nil then
		warn(`[{_localName}::{script.Name}]: Invalid (amount) type. Expected (string), got ({amount}: {typeof(amount)})!`)
		return false
	end

	--- @type BigNum_Instance
	local amountBN = I.BN.new(amount)

	-- Check if the amount isn't negative
	if amountBN < zeroBN then
		warn(`[{_localName}::{script.Name}]: Amount ({amount}) cannot be less than (0)!`)
		return false
	end

	--[[ Calculating ]]

	local currentBN = I.BN.new(moduleData.Standard[statisticName]) --- @type BigNum_Instance
	local finalBN = currentBN + amountBN --- @type BigNum_Instance

	-- Cap the final value at MaxValue when it is respected
	if statisticsData[statisticName].RespectMaxValue then
		--- @type BigNum_Instance
		local maxBN = I.BN.new(statisticsData[statisticName].MaxValue)

		if finalBN > maxBN then
			--[[ Sensitive Cap Check ]]

			-- Failed -> Final value overshoots the cap
			if sensitiveCap then
				return false
			end

			--[[ Calculating Amount ]]

			-- Calculating the amount that can be added
			amountBN = maxBN - currentBN
			finalBN = maxBN
		end
	end

	--[[ Saving ]]

	moduleData.Standard[statisticName] = tostring(finalBN) or statisticsData[statisticName].MinValue

	--[[ Publishing ]]

	if statisticsData[statisticName].ClientUpdate then
		I.Replicator.Set(player, _localName, statisticName, moduleData.Standard[statisticName])
	end

	if statisticsData[statisticName].ServerUpdate then
		I.Topic.Publish("Statistic_Updated", player, statisticName, moduleData.Standard[statisticName], tostring(amountBN))
	end

	if statisticsData[statisticName].ServerUpdateIndividual then
		I.Topic.Publish(`Statistic_Updated-{statisticName}`, player, moduleData.Standard[statisticName], tostring(amountBN))
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Subtract

--[[
	**SERVER** |
	Subtracts `amount` from `statisticName` for player.
]]
--- @return boolean
function Module.Subtract(player: Player, statisticName: string, amount: string, sensitiveCap: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Statistic"]

	--[[ Checks ]]

	-- Read the amount as a string
	amount = `{amount}`

	-- Check if the statistic exists
	if not moduleData.Standard[statisticName] or not statisticsData[statisticName] then
		warn(`[{_localName}::{script.Name}]: ({statisticName}) is not a valid Statistic!`)
		return false
	end

	-- Check if the amount is an integer string
	if type(amount) ~= "string" or string.match(amount, "^%-?%d+$") == nil then
		warn(`[{_localName}::{script.Name}]: Invalid (amount) type. Expected (string), got ({amount}: {typeof(amount)})!`)
		return false
	end

	--- @type BigNum_Instance
	local amountBN = I.BN.new(amount)

	-- Check if the amount isn't negative
	if amountBN < zeroBN then
		warn(`[{_localName}::{script.Name}]: Amount ({amount}) cannot be less than (0)!`)
		return false
	end

	--[[ Calculating ]]

	local currentBN = I.BN.new(moduleData.Standard[statisticName]) --- @type BigNum_Instance
	local finalBN = currentBN - amountBN --- @type BigNum_Instance

	-- Floor the final value at MinValue when it is respected
	if statisticsData[statisticName].RespectMinValue then
		--- @type BigNum_Instance
		local minBN = I.BN.new(statisticsData[statisticName].MinValue)

		if minBN > finalBN then
			--[[ Sensitive Cap Check ]]

			-- Failed -> Final value overshoots the cap
			if sensitiveCap then
				return false
			end

			--[[ Calculating Amount ]]

			-- Calculating the amount that can be subtracted
			amountBN = currentBN - minBN
			finalBN = minBN
		end
	end

	--[[ Saving ]]

	moduleData.Standard[statisticName] = tostring(finalBN) or statisticsData[statisticName].MinValue

	--[[ Publishing ]]

	if statisticsData[statisticName].ClientUpdate then
		I.Replicator.Set(player, _localName, statisticName, moduleData.Standard[statisticName])
	end

	if statisticsData[statisticName].ServerUpdate then
		I.Topic.Publish("Statistic_Updated", player, statisticName, moduleData.Standard[statisticName], tostring(amountBN))
	end

	if statisticsData[statisticName].ServerUpdateIndividual then
		I.Topic.Publish(`Statistic_Updated-{statisticName}`, player, moduleData.Standard[statisticName], tostring(amountBN))
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Set

--[[
	**SERVER** |
	Sets `statisticName` to a certain `amount` for player.
	Publishes the signed change after clamping, negative when the value went down.
]]
--- @return boolean
function Module.Set(player: Player, statisticName: string, amount: string, sensitiveCap: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Statistic"]

	--[[ Checks ]]

	-- Read the amount as a string
	amount = `{amount}`

	-- Check if the statistic exists
	if not moduleData.Standard[statisticName] or not statisticsData[statisticName] then
		warn(`[{_localName}::{script.Name}]: ({statisticName}) is not a valid Statistic!`)
		return false
	end

	-- Check if the amount is an integer string
	if type(amount) ~= "string" or string.match(amount, "^%-?%d+$") == nil then
		warn(`[{_localName}::{script.Name}]: Invalid (amount) type. Expected (string), got ({amount}: {typeof(amount)})!`)
		return false
	end

	--- @type BigNum_Instance
	local amountBN = I.BN.new(amount)

	-- Check if the amount isn't negative
	if amountBN < zeroBN then
		warn(`[{_localName}::{script.Name}]: Amount ({amount}) cannot be less than (0)!`)
		return false
	end

	--[[ Calculating ]]

	local currentBN = I.BN.new(moduleData.Standard[statisticName]) --- @type BigNum_Instance
	local finalBN = amountBN --- @type BigNum_Instance

	-- Raise the final value to MinValue when it is respected
	if statisticsData[statisticName].RespectMinValue then
		--- @type BigNum_Instance
		local minBN = I.BN.new(statisticsData[statisticName].MinValue)

		if minBN > finalBN then
			--[[ Sensitive Cap Check ]]

			-- Failed -> Final value overshoots the cap
			if sensitiveCap then
				return false
			end

			--[[ Clamping To Min ]]

			finalBN = minBN
		end
	end

	-- Lower the final value to MaxValue when it is respected
	if statisticsData[statisticName].RespectMaxValue then
		--- @type BigNum_Instance
		local maxBN = I.BN.new(statisticsData[statisticName].MaxValue)

		if finalBN > maxBN then
			--[[ Sensitive Cap Check ]]

			-- Failed -> Final value overshoots the cap
			if sensitiveCap then
				return false
			end

			--[[ Clamping To Max ]]

			finalBN = maxBN
		end
	end

	-- Signed change of the stored value after clamping
	--- @type BigNum_Instance
	local differenceBN = finalBN - currentBN

	--[[ Saving ]]

	moduleData.Standard[statisticName] = tostring(finalBN) or statisticsData[statisticName].MinValue

	--[[ Publishing ]]

	if statisticsData[statisticName].ClientUpdate then
		I.Replicator.Set(player, _localName, statisticName, moduleData.Standard[statisticName])
	end

	if statisticsData[statisticName].ServerUpdate then
		I.Topic.Publish("Statistic_Updated", player, statisticName, moduleData.Standard[statisticName], tostring(differenceBN))
	end

	if statisticsData[statisticName].ServerUpdateIndividual then
		I.Topic.Publish(`Statistic_Updated-{statisticName}`, player, moduleData.Standard[statisticName], tostring(differenceBN))
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	**SERVER** |
    Returns value of the `statisticName` statistic for player.
]]
--- @return string?
function Module.Get(player: Player, statisticName: string)
	if not statisticsData[statisticName] then
		warn(`[{_localName}::{script.Name}]: ({statisticName}) is not a valid Statistic!`)
	end
	local defaultValue: string = statisticsData[statisticName] and statisticsData[statisticName].DefaultValue or "0"

	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Statistic"]

	--[[ Returning Single ]]

	if statisticName and moduleData.Standard[statisticName] then
		return moduleData.Standard[statisticName] or defaultValue
	else
		return defaultValue
	end
end

--%%%%%%%%%%%%%%%%%%%% Get All

--[[
	**SERVER** |
    Returns copy of player statistics table.
]]
--- @return { [string]: string }?
function Module.GetAll(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Statistic"]

	--[[ Returning All ]]

	return I.Table.DeepCopy(moduleData.Standard)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
