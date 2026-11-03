--[[
    Created By:     Nari
]]

local _localName = "place_loader"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Lobby Control

--%%%%%%%%%%%%%%%%%%%% Create

--[[
	Returns persistent lobby checks and lobby state functions for the shared place loader task.
]]
--- @param _task Ume_Task_Place_Loader
--- @return Ume_Task_Place_Loader_Lobby
return function(_task)
	--- @class Ume_Task_Place_Loader_Lobby
	local Lobby = {}

	--%%%%%%%%%%%%%%%%%%%% Is Lobby Persistent

	--[[
		**SERVER** |
		Checks if lobby is set to persistent using the `LobbyStore` Data Store.
	]]
	function Lobby.IsLobbyPersistent(umeInstance)
		--- @type Ume
		local I = umeInstance

		if I.Started or not I.Env.IsServer then
			return
		end

		-- Skip if DataStore access is not available
		if not I.DataStoreAccess then
			return
		end

		-- Persistent lobby is disabled for studio
		if I.Env.IsStudio and not I.Config.PlaceLoader.PersistentLobbyInStudio then
			return
		end

		-- Persistent lobby is disabled for the current server
		if table.find(I.Config.PlaceLoader.PersistentLobbyExcludedServers, game.PrivateServerId) then
			return
		end

		--%%%%%%%%%%%%%%%%%%%%

		--[[ Checks ]]

		local success: boolean, isPersistent: boolean | string? = pcall(function()
			return _task.LobbyStore and _task.LobbyStore:GetAsync("IsLobbyPersistent")
		end)

		--[[ Updating Variables ]]

		if success and isPersistent then
			_task.MapId = _task.PlaceConfig.LobbyId
			_task.IsLobby = true
			_task.IsPersistentLobby = true
		else
			if type(isPersistent) == "string" then -- Only print if error message
				warn(`[Ume::{_localName}]: {isPersistent}`)
			end
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Create Lobby Functions

	--[[
		**SERVER** |
		Creates function to get and update state of the persistent lobby.
	]]
	function Lobby.CreateLobbyFunctions(umeInstance)
		--- @type Ume
		local I = umeInstance

		if I.Started or not I.Env.IsServer then
			return
		end

		--%%%%%%%%%%%%%%%%%%%%

		--[[
			**SERVER** |
			Fetches state of the persistent lobby.
		]]
		--- @return boolean
		--- @return boolean | string
		I.GetPersistentLobbyState = function()
			-- Skip if DataStore access is not available
			if not I.DataStoreAccess then
				return false, "DataStore access is not available"
			end

			if not _task.LobbyStore then
				return false, "Lobby store is not available"
			end

			--[[ Getting State ]]

			local success: boolean, isPersistent: boolean | string? = pcall(function()
				return _task.LobbyStore:GetAsync("IsLobbyPersistent")
			end)

			if not success then
				warn(`[Ume::{_localName}]: {isPersistent}`)
			end

			return success, isPersistent
		end

		--%%%%%%%%%%%%%%%%%%%%

		--[[
			**SERVER** |
			Updates state of the persistent lobby.
		]]
		--- @return boolean
		--- @return string
		I.UpdatePersistentLobbyState = function(state: boolean)
			-- Skip if DataStore access is not available
			if not I.DataStoreAccess then
				return false, "DataStore access is not available"
			end

			if not _task.LobbyStore then
				return false, "Lobby store is not available"
			end

			--[[ Updating State ]]

			local success: boolean, errorMessage: string = pcall(function()
				_task.LobbyStore:SetAsync("IsLobbyPersistent", state == true)
			end)

			if not success then
				warn(`[Ume::{_localName}]: {errorMessage}`)
			end

			return success, errorMessage
		end
	end

	return Lobby
end
