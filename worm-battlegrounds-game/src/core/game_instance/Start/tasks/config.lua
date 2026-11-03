--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task

--- @class Ume_Task_Config
local _task = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Load

--[[
	Loads all configuration files into the Ume instance.
]]
function _task.Load(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	-- Table containing all configuration tables.
	I.Config = {

		--%%%%%%%%%%%%%%%%%%%% General Configs

		General = require(I._dirs.Configs.general), --- @type Ume_Config_General
		Modules = require(I._dirs.Configs.modules), --- @type Ume_Config_Modules
		PlaceLoader = require(I._dirs.Configs.place_loader), --- @type Ume_Config_PlaceLoader

		--%%%%%%%%%%%%%%%%%%%% Map Config

		-- Configuration for the currently loaded map.
		Map = nil, --- @type Ume_PlaceLoader_MapSettings

		-- Indicates if current map is a Lobby Server.
		IsLobby = false, --- @type boolean

		-- **SERVER** | Metadata for the currently loaded map.
		Metadata = nil, --- @type Ume_PlaceLoader_Metadata
	}
end

--%%%%%%%%%%%%%%%%%%%% Update

--[[
	Updates store names in the current map configuration to `Production` if they contain `UmeTesting`.
]]
function _task.Update(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started or I.Env.IsStudio then
		return
	end

	if not I.Config.General.IsProductionReady then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	-- Profile store
	if string.find(I.Config.Map.ProfileStoreName, "UmeTesting") then
		I.Config.Map.ProfileStoreName = "Production"
	end

	-- Leaderboards store
	if string.find(I.Config.Map.LeaderboardStoreName, "UmeTesting") then
		I.Config.Map.LeaderboardStoreName = "Production"
	end
end

return _task
