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

	--%%%%%%%%%%%%%%%%%%%% Fetch Map Id

	--[[
		**SERVER** |
		Fetches MapId for the current place using the `MemoryStoreService`.
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
					if _task.PlaceConfig.MapConfigs[mapData.MapId] then
						-- Saving
						_task.MapId = mapData.MapId
						_task.Metadata = mapData.Metadata

						-- Lobby check
						if _task.PlaceConfig.LobbyId == mapData.MapId then
							_task.IsLobby = true
						end
					else
						warn(`[Ume::{_localName}]: MapId ({mapData.MapId}) is invalid for place ({_task.PlaceId})!`)
					end
				else
					-- Printing `mapData` as an error message
					warn(`[Ume::{_localName}]: {mapData}`)
				end
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
