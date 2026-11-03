--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Settings"

--- @type Settings_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts: Folder = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local SettingsGui = require(_scripts:FindFirstChild("Client"):FindFirstChild("SettingsGui")) --- @type Settings_Client_SettingsGui

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local moduleRep: Folder?

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

	SettingsGui.Init()

	--[[ Framework Loaded ]]

	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)

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

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	SettingsGui.Start()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Keeps the settings folder the server made, sets the volumes, and sets them again and redraws the window whenever a
	setting changes.
]]
function Module._connectReplicator()
	--[[ Data ]]

	moduleRep = I.Replicator.GetFolder(_localName)

	--[[ Checks ]]

	-- Check if the server made the folder
	if not moduleRep then
		warn(`[{_localName}::{script.Name}]: Replicator folder ({_localName}) is missing - settings show their defaults!`)
		return
	end

	--[[ Applying ]]

	Module._applyVolumes()

	--[[ Connections ]]

	moduleRep.AttributeChanged:Connect(function()
		Module._applyVolumes()
		SettingsGui.Refresh()
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set

--[[
	Asks the server to turn one of the local player's switches on or off, or to set one of their volumes. The window and
	the volume follow at once; the server's value replaces it when it arrives.
]]
--- @param value boolean | number
function Module.Set(settingName: string, value)
	--[[ Sending ]]

	I.Network.Fire("Settings_Set", settingName, value)

	--[[ Applying ]]

	-- The folder is missing only when the server didn't make it (_connectReplicator warns)
	if moduleRep then
		moduleRep:SetAttribute(settingName, value)
	end
end

--%%%%%%%%%%%%%%%%%%%% Apply Volumes

--[[
	Sets every volume setting's sound groups to its value over 100, times the master volume's over 100 (Master 50 and
	Music 50 play the music at 0.25).
]]
function Module._applyVolumes()
	--[[ Local Variables ]]

	local master: number = Module.Get(_settings.MASTER_VOLUME) / 100

	--[[ Volumes ]]

	--- @param settingData Settings_Setting
	for settingName: string, settingData in pairs(_settings.SETTINGS) do
		--[[ Checks ]]

		-- Skip the switches
		if not settingData.SoundGroups then
			continue
		end

		--[[ Applying ]]

		local volume: number = Module.Get(settingName) / 100 * (if settingName == _settings.MASTER_VOLUME then 1 else master)

		for _index: number, soundGroupName: string in ipairs(settingData.SoundGroups) do
			I.Sound.ChangeSoundGroupVolume(soundGroupName, volume)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns one of the local player's settings (whether a switch is on, or a volume from 0 to VOLUME_MAX), read from the
	replicator; the setting's default before the server sent it, false for a setting that doesn't exist.
]]
--- @return boolean | number
function Module.Get(settingName: string)
	--[[ Checks ]]

	-- Check if the setting exists
	if not _settings.SETTINGS[settingName] then
		warn(`[{_localName}::{script.Name}]: Setting ({settingName}) doesn't exist!`)
		return false
	end

	--[[ Data ]]

	local value: (boolean | number)? = moduleRep and moduleRep:GetAttribute(settingName)

	--[[ Returning ]]

	if value == nil then
		return _settings.SETTINGS[settingName].Default
	end

	return value
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
