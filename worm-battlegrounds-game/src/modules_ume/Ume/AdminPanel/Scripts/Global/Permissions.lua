--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local groupsList = require(I.Dirs.GlobalData.Group.Groups) --- @type Group_Groups
local permissions = require(I.Dirs.GlobalData.AdminPanel.Permissions) --- @type AdminPanel_Permissions

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local cachedLocalLevel: number? = nil

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

--- @class AdminPanel_Global_Permissions
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Permission Level

--[[
	Returns a player's admin permission level: the higher of their rank in the `Permissions.Groups` groups and their
	`CustomLevels` entry, kept in `PERMISSION_LEVEL_RANGE`. The client keeps its own level after the first lookup.
]]
--- @return number
function Module.GetPermissionLevel(player: Player)
	-- Check if player is valid | SERVER
	if I.Env.IsServer and not I.Player.Valid(player) then
		return 0
	end

	--[[ Checks ]]

	-- Return the local player's level once it is known
	if I.Env.IsClient and player == I.Env.LocalPlayer and cachedLocalLevel then
		return cachedLocalLevel
	end

	--[[ Local Variables ]]

	local highestGroupRank: number = _settings.PERMISSION_LEVEL_RANGE.Min

	--[[ Group Ranks ]]

	for _index: number, groupId: string in ipairs(permissions.Groups) do
		-- Skip a group alias the game doesn't define
		if not groupsList[groupId] then
			continue
		end

		local success: boolean
		local result: any | string?
		success, result = pcall(player.GetRankInGroup, player, groupsList[groupId])

		-- Keep the highest rank
		if success and type(result) == "number" then
			highestGroupRank = math.max(highestGroupRank, result)
		end
	end

	--[[ Calculating ]]

	local customLevel: number = permissions.CustomLevels[player.UserId] or _settings.PERMISSION_LEVEL_RANGE.Min
	local level: number = math.clamp(math.max(highestGroupRank, customLevel), _settings.PERMISSION_LEVEL_RANGE.Min, _settings.PERMISSION_LEVEL_RANGE.Max)

	--[[ Saving ]]

	-- Keep the local player's level on the client
	if I.Env.IsClient and player == I.Env.LocalPlayer then
		cachedLocalLevel = level
	end

	--[[ Returning ]]

	return level
end

--%%%%%%%%%%%%%%%%%%%% Can Open Dashboard

--[[
	Returns whether a player's level reaches `Permissions.DashboardLevel`.
]]
--- @return boolean
function Module.CanOpenDashboard(player: Player)
	return Module.GetPermissionLevel(player) >= permissions.DashboardLevel
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
