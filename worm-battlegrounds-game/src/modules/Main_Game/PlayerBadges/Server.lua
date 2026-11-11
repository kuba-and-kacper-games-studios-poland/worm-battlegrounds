--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "PlayerBadges"

--- @type PlayerBadges_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--- @type PlayerBadges_ServerSettings
local _serverSettings = require(script:FindFirstAncestor(_localName):FindFirstChild("ServerSettings"))

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

	I.G_Player.OnPlayerAdded(I.Priority.Default, Module._onPlayerAdded)
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	I.Topic.Subscribe("Group_DataUpdated", Module._onGroupUpdated)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% On Player Added

--[[
	Publishes a joining player's badges on a thread of its own, since group ranks and the admin level are web calls,
	and again whenever their Premium starts or ends.
]]
function Module._onPlayerAdded(player: Player)
	--[[ Connections ]]

	player:GetPropertyChangedSignal("MembershipType"):Connect(function()
		Module._publish(player)
	end)

	--[[ Publishing ]]

	task.spawn(Module._publish, player)
end

--%%%%%%%%%%%%%%%%%%%% On Group Updated

--[[
	Publishes a player's badges again when their place in a group that gives one changes (a new role, or a join).
]]
function Module._onGroupUpdated(player: Player, groupName: string | number)
	--[[ Checks ]]

	-- Check if the group gives a badge
	if not table.find({ _serverSettings.STUDIO_GROUP, _serverSettings.STAFF_GROUP, _serverSettings.STAR_GROUP }, groupName) then
		return
	end

	--[[ Publishing ]]

	task.spawn(Module._publish, player)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Publish

--[[
	Works out which badges a player wears and writes them, in BADGES' order, to their ATTRIBUTE, which every client
	reads.
]]
function Module._publish(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Local Variables ]]

	local badges = {} --- @type { string }

	--[[ Badges ]]

	--- @param badge PlayerBadges_Badge
	for _index: number, badge in ipairs(_settings.BADGES) do
		if Module._hasBadge(player, badge.Id) then
			table.insert(badges, badge.Id)
		end
	end

	--[[ Publishing ]]

	player:SetAttribute(_settings.ATTRIBUTE, table.concat(badges, ","))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Has Badge

--[[
	Returns whether a player wears a badge: by their rank or role in the studio's group (I.Group reads them once a
	session), the admin list (I.AdminPanel), Roblox's staff and Video Stars groups, their verified badge and their
	Premium.
]]
--- @return boolean
function Module._hasBadge(player: Player, badgeId: string)
	--[[ Badges ]]

	-- The studio's group (its rank, or a role named for the badge), then the admin list, then Roblox's
	if badgeId == "Owner" then
		local ownsGame: boolean = game.CreatorType == Enum.CreatorType.User and game.CreatorId == player.UserId
		local role: string = I.Group.GetRole(player, _serverSettings.STUDIO_GROUP) or ""
		return ownsGame or (I.Group.GetRank(player, _serverSettings.STUDIO_GROUP) or 0) >= _serverSettings.OWNER_RANK or table.find(_serverSettings.OWNER_ROLES, role) ~= nil
	elseif badgeId == "Developer" then
		local role: string = I.Group.GetRole(player, _serverSettings.STUDIO_GROUP) or ""
		return (I.Group.GetRank(player, _serverSettings.STUDIO_GROUP) or 0) >= _serverSettings.DEVELOPER_RANK or table.find(_serverSettings.DEVELOPER_ROLES, role) ~= nil
	elseif badgeId == "Admin" then
		return I.AdminPanel.CanOpenDashboard(player)
	elseif badgeId == "Staff" then
		return I.Group.IsMember(player, _serverSettings.STAFF_GROUP) == true
	elseif badgeId == "Star" then
		return I.Group.IsMember(player, _serverSettings.STAR_GROUP) == true
	elseif badgeId == "Verified" then
		return player.HasVerifiedBadge
	elseif badgeId == "Premium" then
		return player.MembershipType == Enum.MembershipType.Premium
	end

	--[[ Checks ]]

	-- Warn about a badge nothing decides
	warn(`[{_localName}::{script.Name}]: Badge ({badgeId}) has no check!`)
	return false
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
