--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Respawn_Controller"

--- @type Respawn_Controller_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local _defaultSpawnLocation: SpawnLocation

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

	I.G_Player.OnPlayerAdded(I.Priority.Setup, Module.UpdateRespawnLocation)

	--[[ Respawn Function Override ]]

	I.Player.OverrideRespawnFunction(function(player: Player, _: Model)
		task.wait(1) -- Delay before respawn

		if not player.RespawnLocation then
			Module.UpdateRespawnLocation(player)
		end

		-- Load new character
		if I.Player.Valid(player) then
			pcall(function()
				player:LoadCharacterAsync()
			end)
		end
	end)

	--[[ Getting Spawn ]]

	Module._getDefaultSpawnLocation()

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.RespawnController = {

		--[[ Control ]]

		UpdateRespawnLocation = Module.UpdateRespawnLocation,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Default Spawn Location

--[[
	Saves the default SpawnLocation. 
]]
function Module._getDefaultSpawnLocation()
	--[[ Getting SpawnLocation ]]

	local spawnLoc: SpawnLocation = I.Dirs.UmeWorkspace:FindFirstChild(_settings.DEFAULT_SPAWNLOCATION_NAME)

	--[[ Saving ]]

	if spawnLoc and spawnLoc:IsA("SpawnLocation") then
		_defaultSpawnLocation = spawnLoc
	else
		warn(`[{_localName}::{script.Name}]: Default SpawnLocation ({_settings.DEFAULT_SPAWNLOCATION_NAME}) is missing from (Workspace/Ume)!`)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Update Respawn Location

--[[
	**SERVER** |
	Updates `RespawnLocation` for the player, using either passed or the default one.
]]
function Module.UpdateRespawnLocation(player: Player, spawnLocation: SpawnLocation?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Custom ]]

	if spawnLocation then
		if spawnLocation:IsA("SpawnLocation") then
			player.RespawnLocation = spawnLocation
			return
		else
			warn(`[{_localName}::{script.Name}]: ({spawnLocation}) is not a valid SpawnLocation!`)
		end
	end

	--[[ Default ]]

	if _defaultSpawnLocation then
		player.RespawnLocation = _defaultSpawnLocation
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
