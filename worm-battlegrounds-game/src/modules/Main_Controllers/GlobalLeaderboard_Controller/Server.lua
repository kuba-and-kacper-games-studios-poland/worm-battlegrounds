--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "GlobalLeaderboard_Controller"

--- @type GlobalLeaderboard_Controller_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Players = I.S.Players

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _components = script:FindFirstAncestor(_localName):FindFirstChild("Components")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Cache ]]

local cachedNames = {} --- @type { [number]: string }
local cachedCountries = {} --- @type { [number]: Country_CountryData }

local cachedNamesOrder = {} --- @type { number }
local cachedCountriesOrder = {} --- @type { number }

--[[ Writes ]]

--- @type { [string]: { [number]: number } }
local lastWritten = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--- @type { [string]: (input: number) -> string }
local dataDisplayConvertFunctions = {
	["Default"] = function(input: number)
		--[[ e+ Value ]]

		if tostring(input):find("e+") then
			local separatedValue: { string } = tostring(input):split("e+")
			input = tostring(I.BN.MultiplyWithPrecision("1" .. string.rep("0", tonumber(separatedValue[2])), tonumber(separatedValue[1]), 6))

			return I.BN.AbbreviationConvertFormatted(input, 2)
		end

		--[[ Normal Value ]]

		return I.BN.AbbreviationConvertFormatted(`{math.round(input)}`, 2)
	end,
	["Time"] = function(input: number)
		return I.Time.FormatClean(input, {
			[1] = "Dtd HHlh",
			[2] = "HHth MMlm",
			[3] = "MMtm SSls",
			[4] = "SSts",
		})
	end,
}

--%%%%%%%%%%%%%%%%%%%% Evict Oldest Cached Entries

--[[
	Removes up to `removeCount` oldest entries from `orderArray` and matching keys from `mainCache`.
]]
local function evictOldestCachedEntries(orderArray: { number }, mainCache: { [number]: any }, removeCount: number)
	for _ = 1, removeCount do
		local userId: number = orderArray[1]
		if userId == nil then
			break
		end
		table.remove(orderArray, 1)
		mainCache[userId] = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Trim Caches If Needed

--[[
	Evicts oldest cached entries if the cache is over the maximum allowed entries.
]]
local function trimCachesIfNeeded(removeCount: number?)
	-- Names cache
	if #cachedNamesOrder > _settings.CACHE_MAX_ENTRIES then
		local n: number? = removeCount or (#cachedNamesOrder - _settings.CACHE_MAX_ENTRIES)
		evictOldestCachedEntries(cachedNamesOrder, cachedNames, n)
	end

	-- Countries cache
	if #cachedCountriesOrder > _settings.CACHE_MAX_ENTRIES then
		local n: number? = removeCount or (#cachedCountriesOrder - _settings.CACHE_MAX_ENTRIES)
		evictOldestCachedEntries(cachedCountriesOrder, cachedCountries, n)
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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnPlayerRemoving(I.Priority.Default, Module._clearLastWritten)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Component
	I.Component.Register("GLC_S_Leaderboard", _components.S_Leaderboard)
	I.Component.Register("GLC_S_Dummy", _components.S_Dummy)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.GlobalLeaderboard_Controller = {

		--[[ Methods ]]

		ConvertValue = Module.ConvertValue,
		GetPlayerName = Module.GetPlayerName,
		GetPlayerCountryData = Module.GetPlayerCountryData,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Module._createLeaderboards()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Clear Last Written

--[[
	Drops a leaving player's last written values.
]]
function Module._clearLastWritten(player: Player)
	--[[ Clearing ]]

	--- @param storeLastWritten { [number]: number }
	for _statisticName: string, storeLastWritten in pairs(lastWritten) do
		storeLastWritten[player.UserId] = nil
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Create Leaderboards

--[[
	Registers one update function per `TRACKED_STATISTICS` entry, writing that statistic
	into the store of the same name.
]]
function Module._createLeaderboards()
	--[[ Registering ]]

	--- @param trackedStatistic GlobalLeaderboard_Controller_TrackedStatistic
	for statisticName: string, trackedStatistic in pairs(_settings.TRACKED_STATISTICS) do
		lastWritten[statisticName] = {}

		I.GlobalLeaderboard.RegisterUpdateFunction(statisticName, nil, trackedStatistic.UpdateGroup, {
			UpdateFunction = function()
				Module._writeStatistic(statisticName)
			end,
			CacheOnUpdate = true,

			IsAscending = trackedStatistic.IsAscending,
			PageSize = trackedStatistic.PageSize,
		})
	end
end

--%%%%%%%%%%%%%%%%%%%% Write Statistic

--[[
	Writes every player's changed statistic value to its store in parallel,
	and returns once all writes finished so the page cached next includes them.
]]
function Module._writeStatistic(statisticName: string)
	--[[ Data ]]

	local dataStore: OrderedDataStore = I.GlobalLeaderboard.Get(statisticName)

	--[[ Local Variables ]]

	local pendingWrites: number = 0

	--[[ Writing ]]

	for _, player: Player in ipairs(Players:GetPlayers()) do
		-- Check if player is valid | SERVER
		if not I.Player.Valid(player) then
			continue
		end

		local value: number? = tonumber(I.Statistic.Get(player, statisticName))
		local valueToStore: number = if value then math.floor(value) else 0

		-- Skip empty values and values already written
		if valueToStore == 0 or lastWritten[statisticName][player.UserId] == valueToStore then
			continue
		end

		pendingWrites += 1
		task.spawn(function()
			Module._writeValue(dataStore, statisticName, player.UserId, valueToStore)
			pendingWrites -= 1
		end)
	end

	--[[ Waiting ]]

	-- Wait for the writes so the page cached after this function includes them
	while pendingWrites > 0 do
		task.wait()
	end
end

--%%%%%%%%%%%%%%%%%%%% Write Value

--[[
	Writes one user's value to the store, skipping the write when the store already has it,
	and remembers it while the player is in the server.
]]
function Module._writeValue(dataStore: OrderedDataStore, statisticName: string, userId: number, valueToStore: number)
	--[[ Writing ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(function()
		return dataStore:UpdateAsync(userId, function(storedValue: number?)
			-- Cancel the write when the store already has the value
			if storedValue == valueToStore then
				return nil
			end

			return valueToStore
		end)
	end)

	--[[ Checks ]]

	-- Warn when the write failed
	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to write ({statisticName}) for user ({userId})! - ({result})`)
		return
	end

	-- Skip players who left while the write ran
	if not Players:GetPlayerByUserId(userId) then
		return
	end

	--[[ Saving ]]

	lastWritten[statisticName][userId] = valueToStore
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Convert Value

--[[
	**SERVER** |
	Converts `value` so it's ready to be displayed in the Leaderboard.
]]
--- @return string
function Module.ConvertValue(value: number, displayType: string)
	-- Existing `displayType`
	if dataDisplayConvertFunctions[displayType] then
		return dataDisplayConvertFunctions[displayType](value)
	end

	-- default convert
	return dataDisplayConvertFunctions["Default"](value)
end

--%%%%%%%%%%%%%%%%%%%% Get Player Name

--[[
	**SERVER** |
	Gets and caches and returns player's name.
]]
--- @return string | nil
function Module.GetPlayerName(playerId: number)
	--[[ Returning Cached ]]

	if cachedNames[playerId] then
		-- Check if value is in a `being cached` state -> wait for value to appear
		if type(cachedNames[playerId]) == "boolean" then
			local repeats = 0
			repeat
				task.wait(0.1)
				repeats += 1
			until type(cachedNames[playerId]) ~= "boolean" or repeats >= 100
		end

		-- Returning cached value
		if cachedNames[playerId] and type(cachedNames[playerId]) ~= "boolean" then
			return cachedNames[playerId]
		else
			return nil
		end
	end

	--[[ Caching Value ]]

	-- Setting state to `being cached`
	cachedNames[playerId] = true

	-- Getting player's name
	local success: boolean, playerName: string = pcall(function()
		return Players:GetNameFromUserIdAsync(playerId)
	end)

	--[[ Returning ]]

	-- Success: save and return
	if success and playerName then
		cachedNames[playerId] = playerName
		table.insert(cachedNamesOrder, playerId)
		trimCachesIfNeeded()
		return playerName
	end

	-- Failed: clear and return nil
	cachedNames[playerId] = nil
	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Player Country Data

--[[
	**SERVER** |
	Gets and caches and returns player's Country Data.
]]
--- @return Country_CountryData | nil
function Module.GetPlayerCountryData(playerId: number)
	--[[ Returning Cached ]]

	if cachedCountries[playerId] then
		if type(cachedCountries[playerId]) == "boolean" then
			local repeats = 0
			repeat
				task.wait(0.1)
				repeats += 1
			until type(cachedCountries[playerId]) ~= "boolean" or repeats >= 100
		end

		-- Returning cached value
		if cachedCountries[playerId] and type(cachedCountries[playerId]) ~= "boolean" then
			return cachedCountries[playerId]
		else
			return nil
		end
	end

	--[[ Caching Value ]]

	-- Setting state to `being cached`
	cachedCountries[playerId] = true

	--[[ Caching Value ]]

	-- Getting player's Country Data
	local success: boolean, playerCountryData: table = pcall(function()
		return I.CountryCode.GetPlayerCountryDataById(playerId)
	end)

	--[[ Returning ]]

	-- Success: save and return
	if success and playerCountryData then
		-- Saving
		cachedCountries[playerId] = playerCountryData
		table.insert(cachedCountriesOrder, playerId)
		trimCachesIfNeeded()

		-- Returning
		return playerCountryData
	end

	-- Failed: clear and return nil
	cachedCountries[playerId] = nil
	return nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
