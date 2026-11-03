--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local shared --- @type AdminPanel_CommandBar_GlobalShared

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

--- @class AdminPanel_CommandBar_Global_History
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _shared AdminPanel_CommandBar_GlobalShared
function Module.Init(_shared)
	shared = _shared
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Command History Control

--%%%%%%%%%%%%%%%%%%%% Update Player Command History

--[[
	Updates player's command history with the new data.
]]
--- @param commandHistory { string } | nil
function Module.UpdatePlayerCommandHistory(player: Player, commandHistory)
	-- Check if player is valid | SERVER
	if not I.Env.IsServer or not I.Player.Valid(player) then
		return
	end

	--[[ Checks ]]

	-- Return if command history is invalid
	if not commandHistory or #commandHistory == 0 or type(commandHistory) ~= "table" then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["AdminPanel"]

	--[[ Permission Check ]]

	if _settings.COMMAND_HISTORY_SAVE_PERMISSION_LEVEL > shared.Permissions.GetPermissionLevel(player) then
		return
	end

	--[[ Formatting Table ]]

	local formattedCommandHistory = moduleData.CommandHistory or {} --- @type { string }

	-- Reverse loop to append commands at the start
	for count: number = _settings.COMMAND_HISTORY_LIMIT, 1, -1 do
		-- Break if table ended
		if not commandHistory[count] then
			continue
		end

		-- Skip if invalid item -> Skip
		if type(commandHistory[count]) ~= "string" then
			continue
		end

		-- Command is too long -> Skip
		if #commandHistory[count] > _settings.COMMAND_HISTORY_MAX_COMMAND_LENGTH then
			continue
		end

		-- Saving command
		table.insert(formattedCommandHistory, 1, commandHistory[count])
	end

	-- Removing excess
	while #formattedCommandHistory > _settings.COMMAND_HISTORY_LIMIT do
		table.remove(formattedCommandHistory, #formattedCommandHistory)
	end

	--[[ Saving ]]

	moduleData.CommandHistory = formattedCommandHistory
end

--%%%%%%%%%%%%%%%%%%%% Get Player Command History

--[[
	Returns player command history.
]]
--- @return { string } | nil
function Module.GetPlayerCommandHistory(player: Player)
	-- Check if player is valid | SERVER
	if not I.Env.IsServer or not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["AdminPanel"]

	--[[ Returning ]]

	return moduleData.CommandHistory
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
