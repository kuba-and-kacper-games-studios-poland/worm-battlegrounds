--[[
    Created By:     Nari
]]

local _localName = "place_loader"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Teleport Control

--%%%%%%%%%%%%%%%%%%%% Create

--[[
	Returns temporary lobby teleport and the shared teleport functions for the shared place loader task.
]]
--- @param _task Ume_Task_Place_Loader
--- @return Ume_Task_Place_Loader_Teleport
return function(_task)
	--- @class Ume_Task_Place_Loader_Teleport
	local Teleport = {}

	--%%%%%%%%%%%%%%%%%%%% Teleport Players To Main Server

	--[[
		**SERVER** |
		Teleports all active and new players to the main server.
		Used when the current server is a temporary lobby.
	]]
	function Teleport.TeleportPlayersToMainServer(umeInstance)
		--- @type Ume
		local I = umeInstance

		if I.Started or not I.Env.IsServer then
			return
		end

		--%%%%%%%%%%%%%%%%%%%%

		--[[
			Teleports players from the given table to the main server.
		]]
		local function publicTeleport(playersList: { Player })
			task.spawn(function()
				local targetPlaceId: number = _task.MapConfig.ReturnPlaceId or I.Config.PlaceLoader.DefaultPlaceId

				local success: boolean, result: TeleportAsyncResult | string? = false, nil
				local repeats: number = 0

				while repeats <= 20 do
					success, result = pcall(function(): TeleportAsyncResult
						return I.S.TeleportService:TeleportAsync(targetPlaceId, playersList)
					end)

					if success and result ~= nil then
						return -- Success, exit silently
					end

					-- Only wait if we have more attempts left
					repeats += 1
					if repeats <= 20 then
						task.wait(3)
					end
				end

				-- All retries exhausted
				warn(`[Ume::{_localName}]: Public Teleport failed after {repeats} attempts! - {result}`)
			end)
		end

		--%%%%%%%%%%%%%%%%%%%%

		--[[ LobbyGui Setup ]]

		-- Getting LobbyGui
		local utilityGuis: Folder = I.Dirs.UmeServer:FindFirstChild("UtilityGuis")
		local lobbyGui: ScreenGui = utilityGuis and utilityGuis:FindFirstChild("LobbyGui")

		-- Moving it to ReplicatedFirst
		if lobbyGui then
			lobbyGui.Parent = I.S.ReplicatedFirst
		end

		-- Making server close only when all players left or minute passed
		game:BindToClose(function()
			local waitUntil: number = os.clock() + 60
			repeat
				task.wait(1)
			until #I.S.Players:GetPlayers() == 0 or os.clock() >= waitUntil
		end)

		--%%%%%%%%%%%%%%%%%%%%

		--[[ Teleporting ]]

		-- New players
		I.S.Players.PlayerAdded:Connect(function(player)
			publicTeleport({ player })
		end)

		-- Active
		publicTeleport(I.S.Players:GetPlayers())
	end

	--%%%%%%%%%%%%%%%%%%%% Create Teleport Function

	--[[
	    **SERVER** |
		Creates universal function for teleportation between Ume places/maps or external places.
	]]
	function Teleport.CreateTeleportFunction(umeInstance)
		--- @type Ume
		local I = umeInstance

		if I.Started or not I.Env.IsServer then
			return
		end

		--%%%%%%%%%%%%%%%%%%%% Local Functions

		--[[
			Clones and displays teleport gui for players in given table.
			Returns the list of cloned ScreenGuis so the caller can destroy them on teleport failure.
		]]
		--- @return { ScreenGui }
		local function moveTeleportGui(playersList: { Player }, guiName: string?)
			local clones: { ScreenGui } = {}

			if guiName then
				-- Getting TeleportGui
				local utilityGuis: Folder = I.Dirs.UmeServer:FindFirstChild("UtilityGuis")
				local teleportGui: ScreenGui = utilityGuis and utilityGuis:FindFirstChild(tostring(guiName))

				-- Teleport Gui found
				if teleportGui then
					-- Cloning for all players that are teleported
					for _, player: Player in ipairs(playersList) do
						local playerGui: PlayerGui = player:FindFirstChild("PlayerGui")
						if playerGui then
							local cloned: ScreenGui = teleportGui:Clone()
							cloned.Parent = playerGui
							table.insert(clones, cloned)
						end
					end

					--[[ Animation Delay ]]

					local guiAnimDurationValue: NumberValue = teleportGui:FindFirstChild("GuiAnimDuration")
					local guiAnimDuration: number? = guiAnimDurationValue and guiAnimDurationValue.Value

					-- Slight delay for GUI animation to play before teleporting
					if guiAnimDuration then
						task.wait(guiAnimDuration)
					end
				end
			end

			return clones
		end

		--[[
			Destroys previously-cloned teleport guis. Called when a teleport fails so players aren't stuck with a loading overlay.
		]]
		local function cleanupTeleportGui(clones: { ScreenGui })
			for _, gui: ScreenGui in ipairs(clones) do
				if gui and gui.Parent then
					gui:Destroy()
				end
			end
		end

		--%%%%%%%%%%%%%%%%%%%% Teleport Functions

		--[[
	        **SERVER** |
			Teleports players to a different place within the same game.
	    ]]
		--- @param metadata Ume_PlaceLoader_Metadata?
		--- @return boolean
		I.Teleport = function(playersList: { Player }, placeId: number, mapId: string, metadata, guiName: string?)
			--%%%%%%%%%%%%%%%%%%%% Checks

			--[[ Players Checks ]]

			-- Table missing or empty
			if not playersList or type(playersList) ~= "table" or #playersList == 0 then
				return false
			end

			-- Invalid table entries
			for _, player: Player in ipairs(playersList) do
				if not player:IsA("Player") then
					warn(`[Ume::{_localName}]: ({player}) is not a Player!`)
					return false
				end
			end

			--[[ Place/Map Checks ]]

			-- Invalid placeId
			if not placeId or not I.Config.PlaceLoader.PlaceConfigs[placeId] then
				warn(`[Ume::{_localName}]: ({placeId}) is not a valid placeId!`)
				return false
			end

			-- Invalid mapId
			local placeMapConfigs = I.Config.PlaceLoader.PlaceConfigs[placeId].MapConfigs --- @type { Ume_PlaceLoader_MapSettings }
			if not mapId or type(placeMapConfigs) ~= "table" or not placeMapConfigs[mapId] then
				warn(`[Ume::{_localName}]: ({mapId}) is not a valid mapId for place ({placeId})!`)
				return false
			end

			if not _task.MapHashMap then
				warn(`[Ume::{_localName}]: Cannot teleport with reserved server: MapHashMap is not initialized.`)
				return false
			end

			--%%%%%%%%%%%%%%%%%%%% Reserving Server

			-- Reserving Server (on success: accessCode, reservedServerId; on failure: errorMessage)
			local reserveSuccess: boolean, accessCodeOrError: string, reservedServerId: string = pcall(function()
				return I.S.TeleportService:ReserveServerAsync(placeId)
			end)

			-- Reserving failed
			if not reserveSuccess then
				warn(`[Ume::{_localName}]: Reserving server failed! {accessCodeOrError}`)
				return false
			end

			local accessCode: string = accessCodeOrError

			-- Creating valid metadata (copy so we don't mutate caller's table)
			local localMetadata: { [string]: any } = (metadata and type(metadata) == "table") and table.clone(metadata) or {}
			localMetadata.AccessCode = accessCode

			-- Saving MapId
			local setSuccess: boolean, setResult: any = pcall(function()
				return _task.MapHashMap and _task.MapHashMap:UpdateAsync(reservedServerId, function(_value: any | nil)
					return {
						MapId = mapId,
						Metadata = localMetadata,
					}
				end, 5 * 60)
			end)

			-- Updating HashMap Failed (pcall error or MapHashMap was missing)
			if not setSuccess or setResult == nil then
				warn(`[Ume::{_localName}]: Updating (MapHashMap) failed! - {setResult}`)
				return false
			end

			--%%%%%%%%%%%%%%%%%%%% Teleporting

			-- Moving gui for players
			local guiClones: { ScreenGui } = moveTeleportGui(playersList, guiName)

			--[[ Teleport Options ]]

			local teleportOptions: TeleportOptions = Instance.new("TeleportOptions")
			teleportOptions.ReservedServerAccessCode = accessCode

			--[[ Teleporting ]]

			local teleportSuccess: boolean, result: TeleportAsyncResult | string = pcall(function()
				return I.S.TeleportService:TeleportAsync(placeId, playersList, teleportOptions)
			end)

			--[[ Returning ]]

			if not teleportSuccess or type(result) == "string" then
				warn(`[Ume::{_localName}]: Teleport failed! - {result}`)
				cleanupTeleportGui(guiClones)
				return false
			end

			return true
		end

		--[[
	        **SERVER** |
			Teleports player to a place with specific jobId.
	    ]]
		--- @return boolean
		I.TeleportToServer = function(playersList: { Player }, placeId: number, jobId: string?, accessCode: string?, guiName: string?)
			--%%%%%%%%%%%%%%%%%%%% Checks

			--[[ Players Checks ]]

			-- Table missing or empty
			if not playersList or type(playersList) ~= "table" or #playersList == 0 then
				return false
			end

			-- Invalid table entries
			for _, player: Player in ipairs(playersList) do
				if not player:IsA("Player") then
					warn(`[Ume::{_localName}]: ({player}) is not a Player!`)
					return false
				end
			end

			--[[ Place/Map Checks ]]

			-- Invalid placeId
			if not placeId or not I.Config.PlaceLoader.PlaceConfigs[placeId] then
				warn(`[Ume::{_localName}]: ({placeId}) is not a valid placeId!`)
				return false
			end

			--[[ jobId / accessCode Checks ]]

			-- Return if both values are provided
			if jobId and accessCode then
				warn(`[Ume::{_localName}]: (accessCode) and (jobId) cannot be passed alongside each other!`)
				return false
			end

			if not jobId and not accessCode then
				warn(`[Ume::{_localName}]: Both (accessCode) and (jobId) are missing!`)
				return false
			end

			-- jobId check
			if jobId and not accessCode then
				if type(jobId) ~= "string" then
					warn(`[Ume::{_localName}]: ({jobId}) is not a valid (jobId)!`)
					return false
				end
			end

			-- accessCode check
			if accessCode and not jobId then
				if type(accessCode) ~= "string" then
					warn(`[Ume::{_localName}]: ({accessCode}) is not a valid (accessCode)!`)
					return false
				end
			end

			--%%%%%%%%%%%%%%%%%%%% Teleporting

			-- Moving gui for players
			local guiClones: { ScreenGui } = moveTeleportGui(playersList, guiName)

			--[[ Teleport Options ]]

			local teleportOptions: TeleportOptions = Instance.new("TeleportOptions")
			teleportOptions.ServerInstanceId = jobId
			teleportOptions.ReservedServerAccessCode = accessCode

			--[[ Teleporting ]]

			local teleportSuccess: boolean, result: TeleportAsyncResult | string = pcall(function()
				return I.S.TeleportService:TeleportAsync(placeId, playersList, teleportOptions)
			end)

			--[[ Returning ]]

			if not teleportSuccess or type(result) == "string" then
				warn(`[Ume::{_localName}]: Teleport failed! - {result}`)
				cleanupTeleportGui(guiClones)
				return false
			end

			return true
		end

		--[[
	        **SERVER** |
			Teleports player to a different game.
	    ]]
		--- @return boolean
		I.TeleportExternal = function(playersList: { Player }, placeId: number, guiName: string?)
			--%%%%%%%%%%%%%%%%%%%% Checks

			--[[ Players Checks ]]

			-- Table missing or empty
			if not playersList or type(playersList) ~= "table" or #playersList == 0 then
				return false
			end

			-- Invalid table entries
			for _, player: Player in ipairs(playersList) do
				if not player:IsA("Player") then
					warn(`[Ume::{_localName}]: ({player}) is not a Player!`)
					return false
				end
			end

			--[[ Place/Map Checks ]]

			-- Invalid placeId
			if not placeId or type(placeId) ~= "number" then
				warn(`[Ume::{_localName}]: ({placeId}) is not a valid placeId!`)
				return false
			end

			--%%%%%%%%%%%%%%%%%%%% Teleporting

			-- Moving gui for players
			local guiClones: { ScreenGui } = moveTeleportGui(playersList, guiName)

			--[[ Teleporting ]]

			local teleportSuccess: boolean, result: TeleportAsyncResult | string = pcall(function()
				return I.S.TeleportService:TeleportAsync(placeId, playersList)
			end)

			--[[ Returning ]]

			if not teleportSuccess or type(result) == "string" then
				warn(`[Ume::{_localName}]: Teleport failed! - {result}`)
				cleanupTeleportGui(guiClones)
				return false
			end

			return true
		end

		--[[
			**SERVER** |
			Creates a new lobby server under the default place and teleports players to it. Returns whether the teleport succeeded.
		]]
		--- @return boolean
		I.TeleportToDefaultLobby = function(playersList: { Player }, guiName: string?)
			--[[ Getting Lobby Map Id ]]

			--- @type Ume_PlaceLoader_PlaceSettings
			local defaultPlaceConfig = I.Config.PlaceLoader.PlaceConfigs[I.Config.PlaceLoader.DefaultPlaceId]
			local lobbyMapId: string = defaultPlaceConfig and defaultPlaceConfig.LobbyId

			--[[ Teleporting ]]

			if lobbyMapId then
				return I.Teleport(playersList, I.Config.PlaceLoader.DefaultPlaceId, lobbyMapId, nil, guiName)
			end

			return false
		end
	end

	return Teleport
end
