--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "CountryCode"

--- @type CountryCode_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local LocalizationService = I.S.LocalizationService
local DataStoreService = I.S.DataStoreService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ DataStore ]]

--- Real `DataStore` from `DataStoreService`, or `I.MockDataStores.DataStore` when `I.DataStoreAccess == false`.
--- @type DataStore?
local countryDataStore

--[[ Runtime cache ]]

local cachedCountryCodes = {} --- @type { [number]: number }

--- Insertion order: `[1]` = first added userId, `[2]` = second, ... (FIFO for eviction).
local cachedCountryCodesOrder = {} --- @type { number }

--[[ Miss cache ]]

local missedCountryCodes = {} --- @type { [number]: number }
local missedCountryCodesOrder = {} --- @type { number }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Evict Oldest Cached Entries

--[[
	Removes up to `removeCount` oldest entries from `orderArray` and their keys from `mainCache`.
]]
--- @param orderArray { number }
--- @param mainCache { [number]: any }
local function evictOldestCachedEntries(orderArray, mainCache, removeCount: number)
	--[[ Remove Oldest Entries ]]

	for _ = 1, removeCount do
		local userId: number = orderArray[1]

		--[[ Stop When Empty ]]

		if userId == nil then
			break
		end
		table.remove(orderArray, 1)
		mainCache[userId] = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Trim Caches If Needed

--[[
	Removes the oldest cached entries when the cache exceeds its maximum size.
]]
local function trimCachesIfNeeded(removeCount: number?)
	--[[ Check Cache Size ]]

	if #cachedCountryCodesOrder > _settings.CACHE_MAX_ENTRIES then
		--[[ Calculate Removal Count ]]

		local n: number? = removeCount or (#cachedCountryCodesOrder - _settings.CACHE_MAX_ENTRIES)
		evictOldestCachedEntries(cachedCountryCodesOrder, cachedCountryCodes, n)
	end
end

--%%%%%%%%%%%%%%%%%%%% Remember Cached Country Code

--[[
	Stores a country code in the cache, tracks new users, and trims the cache when needed.
]]
local function rememberCachedCountryCode(userId: number, code: number)
	--[[ Store Code ]]

	local isNewKey: boolean = cachedCountryCodes[userId] == nil
	cachedCountryCodes[userId] = code

	if isNewKey then
		--[[ Track New Key ]]

		table.insert(cachedCountryCodesOrder, userId)
		trimCachesIfNeeded()
	end
end

--%%%%%%%%%%%%%%%%%%%% Resolve Country Alpha 2

--[[
	Resolves an ISO alpha-2 country code from geo data, the player's locale, or the default Roblox locale.
]]
--- @return string?
local function resolveCountryAlpha2(player: Player)
	--%%%%%%%%%%%%%%%%%%%% Geo Region

	local success: boolean, region: string = pcall(function()
		return LocalizationService:GetCountryRegionForPlayerAsync(player)
	end)

	if success and type(region) == "string" and region ~= "" and I.Country.GetByAlpha2(region) then
		return string.upper(region)
	end

	--%%%%%%%%%%%%%%%%%%%% Local Functions

	--[[
		Extracts an ISO alpha-2 code from a locale id.
	]]
	--- @return string?
	local function alpha2FromLocaleId(localeId: string?)
		--[[ Validate Locale ]]

		if type(localeId) ~= "string" or localeId == "" then
			return nil
		end

		--[[ Read Region ]]

		local parts: { string } = string.split(localeId, "-")
		local last: string? = parts[#parts]

		--[[ Validate Region ]]

		if #last ~= 2 or string.match(last, "^%a%a$") == nil then
			return nil
		end

		return string.upper(last)
	end

	--%%%%%%%%%%%%%%%%%%%% Player Locale

	--[[ Check Player Locale ]]

	local fromPlayerLocale: string? = alpha2FromLocaleId(player.LocaleId)
	if fromPlayerLocale and I.Country.GetByAlpha2(fromPlayerLocale) then
		return fromPlayerLocale
	end

	--%%%%%%%%%%%%%%%%%%%% Default Roblox Locale

	--[[ Check Default Locale ]]

	local fromRobloxLocale: string? = alpha2FromLocaleId(LocalizationService.RobloxLocaleId)
	if fromRobloxLocale and I.Country.GetByAlpha2(fromRobloxLocale) then
		return fromRobloxLocale
	end

	return nil
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

	--- @type Player_ProfileData
	local _pt = I.Player.ProfileTemplate
	_pt["CountryCode"] = {
		SavedCountryCode = nil,
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._getCountryDataStore()

	I.G_Player.OnPlayerAdded(I.Priority.Default, function(player: Player)
		task.spawn(function()
			Module.SavePlayerCountry(player)
		end)
	end)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("CountryCode_DataUpdated", { "Player", { Type = "table" } })

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.CountryCode = {

		--[[ Control ]]

		SavePlayerCountry = Module.SavePlayerCountry,

		--[[ Methods ]]

		GetPlayerCountryData = Module.GetPlayerCountryData,
		GetPlayerCountryDataById = Module.GetPlayerCountryDataById,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Country DataStore

--[[
	Gets and saves `DataStore` used for saving player country codes, or a mock in-memory store when DataStores are unavailable.
]]
function Module._getCountryDataStore()
	--[[ Already initialized ]]

	if countryDataStore then
		return
	end

	--[[ Mock DataStore ]]

	if not I.DataStoreAccess then
		countryDataStore = I.MockDataStores.DataStore.new()
		return
	end

	--[[ Real DataStore ]]

	local success: boolean, dataStore: DataStore | string = pcall(function()
		return DataStoreService:GetDataStore("CountryData")
	end)

	if success then
		countryDataStore = dataStore
	else
		warn(`[{_localName}::{script.Name}]: Failed while getting (CountryCode) DataStore! - {dataStore}`)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Save Player Country

--[[
	**SERVER** |
	Reads the player's country and saves its code when it differs from the saved one.
	`force` skips the debounce and saves even an unchanged code.
]]
--- @return boolean
function Module.SavePlayerCountry(player: Player, force: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["CountryCode"]

	--[[ Checks ]]

	-- Skip while a recent save is debounced
	if not force and I.Debounce.Run("CountryCode_SaveCountryCode", 30, player) then
		return false
	end

	--%%%%%%%%%%%%%%%%%%%% Getting Localization

	local alpha2: string? = resolveCountryAlpha2(player)

	--- @type Country_CountryData
	local countryData = alpha2 and I.Country.GetByAlpha2(alpha2)
	if not countryData then
		return false
	end

	local codeNum: number? = tonumber(countryData.Code)
	if not codeNum then
		return false
	end

	--[[ Checks ]]

	-- Skip the save when the code matches the saved one, caching it
	if not force and tonumber(moduleData.SavedCountryCode) == codeNum then
		rememberCachedCountryCode(player.UserId, codeNum)
		return false
	end

	--%%%%%%%%%%%%%%%%%%%% Saving CountryCode

	Module._getCountryDataStore()

	-- Check if the DataStore is available
	if not countryDataStore then
		return false
	end

	--[[ Saving Country ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(function()
		countryDataStore:SetAsync(player.UserId, codeNum)
	end)

	-- Check if the DataStore write worked
	if not success then
		warn(`[{_localName}::{script.Name}]: Failed while saving (CountryCode)! - {result}`)
		return false
	end

	--[[ Saving ]]

	rememberCachedCountryCode(player.UserId, codeNum)
	moduleData.SavedCountryCode = codeNum

	--[[ Publishing ]]

	I.Topic.Publish("CountryCode_DataUpdated", player, countryData)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Player Country

--[[
	**SERVER** |
	Returns player's country data.
]]
--- @return Country_CountryData | nil
function Module.GetPlayerCountryData(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["CountryCode"]

	--[[ Returning Cached ]]

	if cachedCountryCodes[player.UserId] then
		return I.Country.GetByCountryCode(cachedCountryCodes[player.UserId])
	end

	--[[ Returning Saved ]]

	if moduleData.SavedCountryCode then
		-- Getting country data
		--- @type Country_CountryData
		local countryData = I.Country.GetByCountryCode(moduleData.SavedCountryCode)

		-- Data found: return
		if countryData then
			return countryData
		end

		-- Invalid data: try saving again
		task.spawn(function()
			Module.SavePlayerCountry(player, true)
		end)
	end

	--[[ Getting Data ]]

	local alpha2: string? = resolveCountryAlpha2(player)

	--- @type Country_CountryData
	local countryData = alpha2 and I.Country.GetByAlpha2(alpha2)

	--[[ Returning ]]

	if countryData then
		local codeNum: number? = tonumber(countryData.Code)
		if codeNum then
			rememberCachedCountryCode(player.UserId, codeNum)
		end
		return countryData
	else
		return nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Get Player Country By Id

--[[
	**SERVER** |
	Returns a user's country data by user id, from the cache or the `CountryData` DataStore.
	A user id with no saved country is not read again for `MISS_RETRY_SEC`.
]]
--- @return Country_CountryData | nil
function Module.GetPlayerCountryDataById(playerId: number)
	--[[ DataStore ]]

	Module._getCountryDataStore()

	--[[ Checks ]]

	-- Check if the DataStore is available
	if not countryDataStore then
		return nil
	end

	--[[ Returning Cached ]]

	-- Return the cached country
	if cachedCountryCodes[playerId] then
		return I.Country.GetByCountryCode(cachedCountryCodes[playerId])
	end

	-- Skip a user id whose last read found nothing, until the retry time
	if missedCountryCodes[playerId] and os.time() - missedCountryCodes[playerId] < _settings.MISS_RETRY_SEC then
		return nil
	end

	--[[ Getting CountryData ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(function()
		return countryDataStore:GetAsync(playerId)
	end)

	local countryCode: number? = if success then tonumber(result) else nil

	--- @type Country_CountryData
	local countryData = countryCode and I.Country.GetByCountryCode(countryCode)

	--[[ Caching Miss ]]

	-- Remember the miss so the next lookups skip the DataStore
	if not countryData then
		if missedCountryCodes[playerId] == nil then
			table.insert(missedCountryCodesOrder, playerId)
		end
		missedCountryCodes[playerId] = os.time()

		-- Drop the oldest misses past the cache size
		if #missedCountryCodesOrder > _settings.CACHE_MAX_ENTRIES then
			evictOldestCachedEntries(missedCountryCodesOrder, missedCountryCodes, #missedCountryCodesOrder - _settings.CACHE_MAX_ENTRIES)
		end
		return nil
	end

	--[[ Returning ]]

	rememberCachedCountryCode(playerId, countryCode)
	return countryData
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
