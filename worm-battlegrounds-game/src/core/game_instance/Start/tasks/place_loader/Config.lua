--[[
    Created By:     Nari
]]

local _localName = "place_loader"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Verify Map Config

--[[
	Verifies all settings in the given map table.
]]
--- @param mapTable Ume_PlaceLoader_MapSettings
--- @return boolean
local function verifyMapConfig(mapTable, placeId: string | number, mapId: string | number)
	local isValid = true

	--[[ Data ]]

	-- ProfileStoreName
	if mapTable["ProfileStoreName"] == nil or type(mapTable["ProfileStoreName"]) ~= "string" then
		warn(`[Ume::{_localName}]: ({mapTable["ProfileStoreName"]}) is not a valid (ProfileStoreName) for map ({placeId}||{mapId})!`)
		isValid = false
	end

	-- LeaderboardStoreName
	if mapTable["LeaderboardStoreName"] == nil or type(mapTable["LeaderboardStoreName"]) ~= "string" then
		warn(`[Ume::{_localName}]: ({mapTable["LeaderboardStoreName"]}) is not a valid (LeaderboardStoreName) for map ({placeId}||{mapId})!`)
		isValid = false
	end

	--[[ Accessibility ]]

	-- VRSupport
	if mapTable["VRSupport"] == nil or type(mapTable["VRSupport"]) ~= "boolean" then
		warn(`[Ume::{_localName}]: ({mapTable["VRSupport"]}) is not a valid (VRSupport) for map ({placeId}||{mapId})!`)
		isValid = false
	end

	--[[ Directories ]]

	-- GameDirs
	if mapTable.GameDirs and type(mapTable.GameDirs) == "table" then
		for _, entryName: string in ipairs({
			-- Ume Dirs
			"Workspace_Ume",
			"ReplicatedStorage_Ume",
			"ServerStorage_Ume",

			-- General
			"StarterGui",
			"StarterPack",
			"StarterPlayer",

			-- Assets
			"Assets",
			"SAssets",
		}) do
			if mapTable.GameDirs[entryName] == nil or type(mapTable.GameDirs[entryName]) ~= "table" then
				warn(`[Ume::{_localName}]: ({mapTable.GameDirs[entryName]}) is not a valid {entryName} (GameDirs) for map ({placeId}||{mapId})!`)
				isValid = false
			end
		end
	else
		warn(`[Ume::{_localName}]: ({mapTable["GameDirs"]}) is not a valid (GameDirs) for map ({placeId}||{mapId})!`)
		isValid = false
	end

	--[[ Modules ]]

	-- ModulesDirs
	if mapTable["ModulesDirs"] == nil or type(mapTable["ModulesDirs"]) ~= "table" then
		warn(`[Ume::{_localName}]: ({mapTable["ModulesDirs"]}) is not a valid (ModulesDirs) for map ({placeId}||{mapId})!`)
		isValid = false
	end

	-- DisabledModules
	if mapTable["DisabledModules"] == nil or type(mapTable["DisabledModules"]) ~= "table" then
		warn(`[Ume::{_localName}]: ({mapTable["DisabledModules"]}) is not a valid (DisabledModules) for map ({placeId}||{mapId})!`)
		isValid = false
	end

	-- LoadingOrder
	if mapTable["LoadingOrder"] == nil or type(mapTable["LoadingOrder"]) ~= "table" then
		warn(`[Ume::{_localName}]: ({mapTable["LoadingOrder"]}) is not a valid (LoadingOrder) for map ({placeId}||{mapId})!`)
		isValid = false
	end

	return isValid
end

--%%%%%%%%%%%%%%%%%%%% Verify Place Config

--[[
	Verifies the given place config and all its maps.
]]
--- @param placeTable Ume_PlaceLoader_PlaceSettings
--- @return boolean
local function verifyPlaceConfig(placeTable: table, placeId: string | number)
	local isValid = true

	--[[ General Checks ]]

	-- MapConfigs check (must be validated before indexing below)
	if placeTable.MapConfigs == nil or type(placeTable.MapConfigs) ~= "table" then
		warn(`[Ume::{_localName}]: ({placeTable.MapConfigs}) is not a valid (MapConfigs) for place ({placeId})!`)
		return false
	end

	-- Default MapId check
	if placeTable.DefaultMapId == nil or type(placeTable.DefaultMapId) ~= "string" or placeTable.MapConfigs[placeTable.DefaultMapId] == nil or type(placeTable.MapConfigs[placeTable.DefaultMapId]) ~= "table" then
		warn(`[Ume::{_localName}]: ({placeTable.DefaultMapId}) is not a valid (DefaultMapId) for place ({placeId})!`)
		isValid = false
	end

	-- LobbyId check
	if placeTable.LobbyId == nil or type(placeTable.LobbyId) ~= "string" or placeTable.MapConfigs[placeTable.LobbyId] == nil or type(placeTable.MapConfigs[placeTable.LobbyId]) ~= "table" then
		warn(`[Ume::{_localName}]: ({placeTable.LobbyId}) is not a valid (LobbyId) for place ({placeId})!`)
		isValid = false
	end

	--[[ Maps Checks ]]

	for mapId: string | number, mapConfig: table in pairs(placeTable.MapConfigs) do
		isValid = isValid and verifyMapConfig(mapConfig, placeId, mapId)
	end

	return isValid
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create

--[[
	Returns config checks and store setup for the shared place loader task.
]]
--- @param _task Ume_Task_Place_Loader
--- @return Ume_Task_Place_Loader_Config
return function(_task)
	--- @class Ume_Task_Place_Loader_Config
	local Config = {}

	--%%%%%%%%%%%%%%%%%%%% Verify Configs

	--[[
		**SERVER** |
		Verifies if place/map configs are valid.
	]]
	function Config.VerifyConfigs(umeInstance)
		--- @type Ume
		local I = umeInstance

		if I.Started or not I.Env.IsServer then
			return
		end

		--%%%%%%%%%%%%%%%%%%%%

		-- Default Config check
		if not I.Config.PlaceLoader.PlaceConfigs[I.Config.PlaceLoader.DefaultPlaceId] then
			error(`[Ume::{_localName}]: Default config for place ({I.Config.PlaceLoader.DefaultPlaceId}) is missing!`)
		end

		--[[ Verifying ]]

		local arePlacesValid = true

		-- Verifying all configs
		--- @param placeConfig Ume_PlaceLoader_PlaceSettings
		for placeId: string | number, placeConfig in pairs(I.Config.PlaceLoader.PlaceConfigs) do
			arePlacesValid = arePlacesValid and verifyPlaceConfig(placeConfig, placeId)
		end

		--[[ Loading Failed ]]

		if not arePlacesValid then
			error("Ume framework cannot start when there is a problem with the 'place_loader' config!", 2)
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Get Stores

	--[[
		**SERVER** |
		Gets and saves missing Data/Memory stores.
	]]
	function Config.GetStores(umeInstance)
		--- @type Ume
		local I = umeInstance

		if I.Started or not I.Env.IsServer then
			return
		end

		-- Skip if DataStore access is not available
		if not I.DataStoreAccess then
			return
		end

		--%%%%%%%%%%%%%%%%%%%%

		--[[ Data Store ]]

		if not _task.LobbyStore then
			local success: boolean, result: DataStore | string? = pcall(function()
				return I.S.DataStoreService:GetDataStore(I.Config.PlaceLoader._lobbyStoreId)
			end)

			if success then
				_task.LobbyStore = result
			else
				warn(`[Ume::{_localName}]: {result}`)
			end
		end

		--[[ Memory Store Service ]]

		if not _task.MapHashMap then
			local success: boolean, result: MemoryStoreHashMap | string? = pcall(function()
				return I.S.MemoryStoreService:GetHashMap(I.Config.PlaceLoader._mapStoreId)
			end)

			if success then
				_task.MapHashMap = result
			else
				warn(`[Ume::{_localName}]: {result}`)
			end
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Get Current Place Config

	--[[
		**SERVER** |
		Getting config for the current place.
	]]
	function Config.GetCurrentPlaceConfig(umeInstance)
		--- @type Ume
		local I = umeInstance

		if I.Started or not I.Env.IsServer then
			return
		end

		--%%%%%%%%%%%%%%%%%%%%

		--[[ Getting Configs ]]

		local defaultPlaceConfig = I.Config.PlaceLoader.PlaceConfigs[I.Config.PlaceLoader.DefaultPlaceId]
		local currentPlaceConfig = I.Config.PlaceLoader.PlaceConfigs[game.PlaceId]

		--[[ Saving ]]

		_task.PlaceId = currentPlaceConfig and game.PlaceId or I.Config.PlaceLoader.DefaultPlaceId
		_task.PlaceConfig = currentPlaceConfig or defaultPlaceConfig
	end

	return Config
end
