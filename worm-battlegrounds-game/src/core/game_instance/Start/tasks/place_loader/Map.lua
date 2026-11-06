--[[
    Created By:     Nari
]]

local _localName = "place_loader"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Map Control

--%%%%%%%%%%%%%%%%%%%% Create

--[[
	Returns map id resolution and config publishing for the shared place loader task.
]]
--- @param _task Ume_Task_Place_Loader
--- @return Ume_Task_Place_Loader_Map
return function(_task, attributeScript: ModuleScript)
	--- @class Ume_Task_Place_Loader_Map
	local Map = {}

	-- Seconds a Studio server waits for its first player, whose teleport data may name its map
	local STUDIO_JOIN_WAIT: number = 10

	--%%%%%%%%%%%%%%%%%%%% Save Map Data

	--[[
		Saves a map handed to this server (its MapId and metadata) when the MapId is valid for this place.
	]]
	local function saveMapData(mapData: any)
		--[[ Checks ]]

		-- Check if the MapId is one of this place's maps
		if not _task.PlaceConfig.MapConfigs[mapData.MapId] then
			warn(`[Ume::{_localName}]: MapId ({mapData.MapId}) is invalid for place ({_task.PlaceId})!`)
			return
		end

		--[[ Saving ]]

		_task.MapId = mapData.MapId
		_task.Metadata = mapData.Metadata

		-- Lobby check
		if _task.PlaceConfig.LobbyId == mapData.MapId then
			_task.IsLobby = true
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Fetch Map Id

	--[[
		**SERVER** |
		Fetches MapId for the current place using the `MemoryStoreService`, or a Studio test's teleport data.
	]]
	function Map.FetchMapId(umeInstance)
		--- @type Ume
		local I = umeInstance

		if I.Started or not I.Env.IsServer then
			return
		end

		-- Lobby is set to persistent, so the MapId already exists
		if _task.IsPersistentLobby then
			return
		end

		--%%%%%%%%%%%%%%%%%%%%

		if I.DataStoreAccess then
			--[[ Getting Private Status ]]

			local isPrivateServer: boolean = game.PrivateServerId and game.PrivateServerId ~= ""
			local isRobloxServer: boolean = game.PrivateServerOwnerId == 0

			--[[
				If the server is a private server without owner,
				then check which map was assigned to it and other metadata.
			]]
			if isPrivateServer and isRobloxServer then
				-- Getting MapId
				local success: boolean, mapData: table | string = pcall(function()
					return _task.MapHashMap and _task.MapHashMap:GetAsync(game.PrivateServerId)
				end)

				-- MapId found and exists
				if success and mapData and type(mapData) == "table" then
					saveMapData(mapData)
				else
					-- Printing `mapData` as an error message
					warn(`[Ume::{_localName}]: {mapData}`)
				end
			end
		end

		--[[ Studio Teleport ]]

		--[[
			A Studio test leaves reserved-server ids empty, so I.Teleport sends the map in the teleport data there.
			Only Studio reads it: teleport data passes through the client, so a live server trusts the MemoryStore alone.
			shortcut: waits up to STUDIO_JOIN_WAIT for a player, so a Run test without one starts that much later.
		]]
		if not _task.MapId and I.S.RunService:IsStudio() then
			local player: Player? = I.S.Players:GetPlayers()[1]
			local waitUntil: number = os.clock() + STUDIO_JOIN_WAIT
			while not player and os.clock() < waitUntil do
				task.wait(0.1)
				player = I.S.Players:GetPlayers()[1]
			end

			local teleportData: any = player and player:GetJoinData().TeleportData
			if type(teleportData) == "table" and type(teleportData.Ume_Map) == "table" then
				saveMapData(teleportData.Ume_Map)
			end
		end

		--[[ Not Found -> Default ]]

		if not _task.MapId then
			_task.MapId = _task.PlaceConfig.DefaultMapId
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Update Current Map Config

	--[[
		Finds and saves config for the current map.
	]]
	function Map.UpdateCurrentMapConfig(umeInstance)
		--- @type Ume
		local I = umeInstance

		if I.Started then
			return
		end

		--%%%%%%%%%%%%%%%%%%%%

		--[[ Server ]]

		if I.Env.IsServer then
			-- Saving for client
			attributeScript:SetAttribute("Ume_PlaceId", _task.PlaceId)
			attributeScript:SetAttribute("Ume_MapId", _task.MapId)

			_task.MapConfig = _task.PlaceConfig.MapConfigs[_task.MapId]
		end

		--[[ Client ]]

		if I.Env.IsClient then
			_task.PlaceId = attributeScript:GetAttribute("Ume_PlaceId")
			_task.MapId = attributeScript:GetAttribute("Ume_MapId")

			_task.MapConfig = I.Config.PlaceLoader.PlaceConfigs[_task.PlaceId].MapConfigs[_task.MapId]
		end

		--[[ Global Config Save ]]

		I.Config.PlaceLoader.PlaceId = _task.PlaceId
		I.Config.PlaceLoader.MapId = _task.MapId

		I.Config.Map = _task.MapConfig
		I.Config.Metadata = _task.Metadata or nil -- Server only
		I.Config.IsLobby = I.Config.PlaceLoader.PlaceConfigs[_task.PlaceId].LobbyId == _task.MapId
	end

	return Map
end
