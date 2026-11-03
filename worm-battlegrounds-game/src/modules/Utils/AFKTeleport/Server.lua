--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AFKTeleport"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _data = script:FindFirstAncestor(_localName):FindFirstChild("Data")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type AFKTeleport_S_TeleportData
local teleportData = require(_data.S_TeleportData)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local currentMapId: string = `{I.Config.PlaceLoader.PlaceId}-{I.Config.PlaceLoader.MapId}`

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
	_pt["AFKTeleport"] = {
		PlaceData = {}, --- @type { [number]: table }
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnCharacterAdded(I.Priority.Late, Module._resolveTeleport)
	I.S.TeleportService.TeleportInitFailed:Connect(Module._clearFailedTeleport)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("AFKController_RequestTeleport", { "Player" })
	I.Network.Fired("AFKController_RequestTeleport", Module.Teleport)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.AFKTeleport = {

		--[[ Control ]]

		Teleport = Module.Teleport,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Teleport

--[[
	**SERVER** |
	Updates AFKTeleport Data and teleports player to a lobby.
]]
--- @return boolean
function Module.Teleport(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Don't run on studio
	if I.Env.IsStudio then
		return false
	end

	-- Don't run in the lobby
	if I.Config.IsLobby then
		return false
	end

	-- Debounce
	if I.Debounce.Run("AFKTeleport_Teleport", 5, player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["AFKTeleport"]

	--[[ Setting Map Entry ]]

	if teleportData[currentMapId] and teleportData[currentMapId]["Update"] and teleportData[currentMapId]["Resolve"] then
		-- Creating table
		moduleData.PlaceData[currentMapId] = {}

		-- Updating table
		teleportData[currentMapId]["Update"](player)
	end

	--[[ Teleporting ]]

	local success: boolean = I.TeleportToDefaultLobby({ player }, "ShutdownTeleportGui")

	if success then
		return true
	else
		-- Clearing the map entry so the next respawn doesn't restore it
		moduleData.PlaceData[currentMapId] = nil

		warn(`[{_localName}::{script.Name}]: Failed to teleport player ({player}) to Default Lobby!`)
		return false
	end
end

--%%%%%%%%%%%%%%%%%%%% Resolve Teleport

--[[
	Resolves saved AFKTeleport Data.
]]
function Module._resolveTeleport(player: Player, character: Model)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Checks ]]

	-- Don't run on studio
	if I.Env.IsStudio then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["AFKTeleport"]

	--[[ Checks ]]

	-- No data set
	if not moduleData.PlaceData[currentMapId] then
		return
	end

	-- Missing resolve function
	if not teleportData[currentMapId] or not teleportData[currentMapId]["Resolve"] then
		-- Clearing just in case
		moduleData.PlaceData[currentMapId] = nil
		return
	end

	--[[ Resolving ]]

	task.delay(0.5, function()
		-- Check if player is valid | SERVER
		if not I.Player.Valid(player) then
			return
		end

		--[[ Running Resolve ]]

		local success: boolean, err: string? = pcall(function()
			teleportData[currentMapId]["Resolve"](player, character)
		end)

		if success then
			-- Cleaning after resolving
			moduleData.PlaceData[currentMapId] = nil
		else
			warn(`[{_localName}::{script.Name}]: Failed to resolve data! - {err}`)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Clear Failed Teleport

--[[
	Clears the saved AFKTeleport Data of a player whose teleport failed after it started, so the next respawn doesn't restore it.
]]
function Module._clearFailedTeleport(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["AFKTeleport"]

	--[[ Clearing ]]

	moduleData.PlaceData[currentMapId] = nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
