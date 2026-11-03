--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Settings"

--- @type Settings_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

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
	_pt["Settings"] = {}

	--- @param settingData Settings_Setting
	for settingName: string, settingData in pairs(_settings.SETTINGS) do
		_pt["Settings"][settingName] = settingData.Default
	end

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnPlayerAdded(I.Priority.Replicator, Module._createReplicator)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("Settings_Set", { "Player", "string", { Types = { "boolean", "number" } } })
	I.Network.Fired("Settings_Set", Module.Set)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.PlayerSettings = {

		--[[ Control ]]

		Set = Module.Set,

		--[[ Methods ]]

		Get = Module.Get,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Create Replicator

--[[
	Creates the player's `Settings` replicator folder with one attribute per setting.
]]
function Module._createReplicator(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Creating ]]

	I.Replicator.CreateFolder(player, _localName)

	--[[ Filling ]]

	--- @param _settingData Settings_Setting
	for settingName: string, _settingData in pairs(_settings.SETTINGS) do
		I.Replicator.Set(player, _localName, settingName, Module.Get(player, settingName))
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set

--[[
	Turns one of the player's switches on or off, or sets one of their volumes (a whole number from 0 to VOLUME_MAX),
	saves it and writes the replicator. The client asks through `Settings_Set`.
]]
--- @param value boolean | number
--- @return boolean
function Module.Set(player: Player, settingName: string, value)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Check if the setting exists
	if not _settings.SETTINGS[settingName] then
		warn(`[{_localName}::{script.Name}]: Setting ({settingName}) doesn't exist!`)
		return false
	end

	-- Check if the value is the setting's kind: on or off for a switch, a number for a volume
	if typeof(value) ~= typeof(_settings.SETTINGS[settingName].Default) then
		warn(`[{_localName}::{script.Name}]: Setting ({settingName}) can't be ({value})!`)
		return false
	end

	-- Check if a volume is a whole number from 0 to VOLUME_MAX
	if typeof(value) == "number" and (value % 1 ~= 0 or value < 0 or value > _settings.VOLUME_MAX) then
		warn(`[{_localName}::{script.Name}]: Volume ({settingName}) can't be ({value})!`)
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Settings"]

	--[[ Saving ]]

	moduleData[settingName] = value
	I.Replicator.Set(player, _localName, settingName, value)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns one of the player's settings (whether a switch is on, or a volume from 0 to VOLUME_MAX): their saved value,
	else the setting's default; false for a player who isn't valid or a setting that doesn't exist.
]]
--- @return boolean | number
function Module.Get(player: Player, settingName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Check if the setting exists
	if not _settings.SETTINGS[settingName] then
		warn(`[{_localName}::{script.Name}]: Setting ({settingName}) doesn't exist!`)
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Settings"]

	--[[ Returning ]]

	if moduleData[settingName] == nil then
		return _settings.SETTINGS[settingName].Default
	end

	return moduleData[settingName]
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
