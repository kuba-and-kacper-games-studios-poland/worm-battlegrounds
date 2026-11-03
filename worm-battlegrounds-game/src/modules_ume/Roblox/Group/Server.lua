--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Group"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local HttpService = I.S.HttpService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type Group_Groups
local groupsList = require(I.Dirs.GlobalData.Group.Groups)

local proxyData = require(I.Dirs.GlobalData.Group.S_Proxy) --- @type Group_S_Proxy

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Proxy Check ]]

local proxyCheck: boolean = proxyData.Enabled

--[[ Client Lookups ]]

local maxClientLookups: number = 5

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

	--- @type Player_SessionData
	local _st = I.Player.SessionTemplate
	_st["Group"] = {
		FetchedData = {}, --- @type { [string]: table }
		ClientLookups = {}, --- @type { number }

		_firstCheck = true,
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnPlayerAdded(I.Priority.Replicator, Module._createReplicator)
	I.G_Player.OnPlayerAdded(I.Priority.Default, function(player: Player)
		for groupName: string, _groupId: number in pairs(groupsList) do
			task.spawn(function()
				Module.UpdateData(player, groupName)
			end)
		end
	end)

	--[[ Checks ]]

	-- Default Group check
	groupsList["Default"] = groupsList["Default"] or 0
	if groupsList["Default"] == 0 and I.Env.IsStudio then
		print(`[{_localName}::{script.Name}]: Please change Id of the Group (Default)!`)
	end

	-- Proxy check
	if proxyCheck and not HttpService.HttpEnabled then
		print(`[{_localName}::{script.Name}]: Please enable HTTP Requests in order to use Group Proxy check!`)
		proxyCheck = false
	end

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Group_DataUpdated", { "Player", { Types = { "string", "number" } } })

	--- @Network
	I.Network.GetEvent("Group_PromptJoin")

	I.Network.GetEvent("Group_RequestUpdateData", { "Player", { Types = { "string", "number" } } }, { RateLimit = 1, Per = 1 })
	I.Network.Fired("Group_RequestUpdateData", Module._requestUpdateData)

	--[[ Methods ]]

	I.Network.GetFunction("Group_IsMember", { "Player", { Types = { "string", "number" } } }, { RateLimit = 10, Per = 1 })
	I.Network.OnInvoke("Group_IsMember", Module._onIsMember)

	I.Network.GetFunction("Group_GetRole", { "Player", { Types = { "string", "number" } } }, { RateLimit = 10, Per = 1 })
	I.Network.OnInvoke("Group_GetRole", Module._onGetRole)

	I.Network.GetFunction("Group_GetRank", { "Player", { Types = { "string", "number" } } }, { RateLimit = 10, Per = 1 })
	I.Network.OnInvoke("Group_GetRank", Module._onGetRank)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Group = {

		--[[ Control ]]

		PromptJoin = Module.PromptJoin,
		UpdateData = Module.UpdateData,

		--[[ Methods ]]

		IsMember = Module.IsMember,
		GetRole = Module.GetRole,
		GetRank = Module.GetRank,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Replicator

--[[
	Creates folder in the player's replicator for storing group data.
]]
function Module._createReplicator(player: Player)
	-- Check if player is valid | SERVER
	if not I.Env.IsServer or not I.Player.Valid(player) then
		return
	end

	--[[ Creating Folder ]]

	I.Replicator.CreateFolder(player, _localName)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Prompt Join

--[[
	Prompts Group join for player.
]]
function Module.PromptJoin(player: Player, groupName: string | number)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	local groupId: number? = I.G_Group.GetId(groupName)
	if not groupId then
		return
	end

	--[[ Prompting ]]

	I.Network.Fire("Group_PromptJoin", player, groupId)
end

--%%%%%%%%%%%%%%%%%%%% Request Update Data

--[[
	Runs a refresh the client asked for after a join prompt.
	One proxy request per player every 10 seconds updates every listed group.
]]
function Module._requestUpdateData(player: Player, groupName: string | number)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Checks ]]

	-- Check if the group is listed in Groups.lua
	if not I.G_Group.GetName(groupName) then
		return
	end

	-- Skip while this player's refresh is on cooldown
	if I.Debounce.Run("Group_RequestUpdateData", 10, player) then
		return
	end

	--[[ Data ]]

	--- @type { [number]: Group_ProxyRole }?
	local proxyRoles = if proxyCheck then Module._getProxyRoles(player) else nil

	--[[ Updating ]]

	for _listedName: string, listedId: number in pairs(groupsList) do
		Module._updateGroupData(player, listedId, proxyRoles)
	end
end

--%%%%%%%%%%%%%%%%%%%% Update Data

--[[
	**SERVER** |
	Reads the player's membership, role and rank in a group again, optionally through the groups proxy.
]]
function Module.UpdateData(player: Player, groupName: string | number, useProxy: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	local groupId: number? = I.G_Group.GetId(groupName)
	if not groupId then
		return
	end

	--- @type { [number]: Group_ProxyRole }?
	local proxyRoles = if proxyCheck and useProxy then Module._getProxyRoles(player) else nil

	--[[ Updating ]]

	Module._updateGroupData(player, groupId, proxyRoles)
end

--%%%%%%%%%%%%%%%%%%%% Update Group Data

--[[
	Reads the player's membership in one group, prefers the proxy's answer when it has that group, then saves, mirrors and publishes it.
]]
--- @param proxyRoles { [number]: Group_ProxyRole }?
function Module._updateGroupData(player: Player, groupId: number, proxyRoles)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Local Variables ]]

	-- Getting pre-defined group name if exists
	local groupName: string | number = I.G_Group.GetName(groupId) or groupId

	--%%%%%%%%%%%%%%%%%%%% Retrieving Group Data

	--[[ Default Membership Check ]]

	local success: boolean
	local isInGroup: boolean | string
	local groupRole: string?
	local groupRank: number?
	success, isInGroup, groupRole, groupRank = pcall(function()
		return player:IsInGroupAsync(groupId), player:GetRoleInGroupAsync(groupId), player:GetRankInGroupAsync(groupId)
	end)

	--[[ Proxy Membership Check ]]

	--- @type Group_ProxyRole?
	local proxyRole = if proxyRoles then proxyRoles[groupId] else nil

	-- Use the proxy's answer when it has this group
	if proxyRole then
		success = true

		isInGroup = proxyRole.Rank > 0
		groupRole = proxyRole.Role
		groupRank = proxyRole.Rank
	end

	--[[ Checks ]]

	-- Check if the membership was read
	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to update player data for Group ({groupName})! - {isInGroup}`)
		return
	end

	--%%%%%%%%%%%%%%%%%%%% Updating Group Data

	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Group"]

	--%%%%%%%%%%%%%%%%%%%% Saving Data

	--[[ Getting Group Data ]]

	-- Making sure group entry exists
	moduleSessionData.FetchedData[groupId] = moduleSessionData.FetchedData[groupId] or {}

	--- @type Group_StoredData
	local groupData = moduleSessionData.FetchedData[groupId]
	local previousRole: string? = groupData.Role

	--[[ Updating ]]

	groupData.IsMember = isInGroup
	groupData.Role = groupRole
	groupData.Rank = groupRank

	--%%%%%%%%%%%%%%%%%%%% Publishing Changes

	--[[ Updating Attributes ]]

	I.Replicator.Set(player, _localName, `{groupId}_IsMember`, isInGroup)
	I.Replicator.Set(player, _localName, `{groupId}_Role`, groupRole)
	I.Replicator.Set(player, _localName, `{groupId}_Rank`, groupRank)

	-- Mirror under the listed name too
	if groupName ~= groupId then
		I.Replicator.Set(player, _localName, `{groupName}_IsMember`, isInGroup)
		I.Replicator.Set(player, _localName, `{groupName}_Role`, groupRole)
		I.Replicator.Set(player, _localName, `{groupName}_Rank`, groupRank)
	end

	--[[ Publishing ]]

	-- Return if the role hasn't changed
	if previousRole == groupData.Role and moduleSessionData._firstCheck == false then
		return
	end
	moduleSessionData._firstCheck = false

	-- Publishing
	I.Topic.Publish("Group_DataUpdated", player, groupName)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Member

--[[
	Returns if player is in the group.
]]
--- @return boolean?
function Module.IsMember(player: Player, groupName: string | number)
	return Module._getCertainData(player, "IsMember", groupName)
end

--%%%%%%%%%%%%%%%%%%%% Get Role

--[[
	Returns name of the player role in the group.
]]
--- @return string?
function Module.GetRole(player: Player, groupName: string | number)
	return Module._getCertainData(player, "Role", groupName)
end

--%%%%%%%%%%%%%%%%%%%% Get Rank

--[[
	Returns player rank in the group.
]]
--- @return number?
function Module.GetRank(player: Player, groupName: string | number)
	return Module._getCertainData(player, "Rank", groupName)
end

--%%%%%%%%%%%%%%%%%%%% Get Certain Data

--[[
	Returns specified data from the player's group data, reading it first when the group wasn't fetched yet.
]]
--- @return string | number | boolean | nil
function Module._getCertainData(player: Player, dataName: string, groupName: string | number)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Group"]

	local groupId: number? = I.G_Group.GetId(groupName)
	if not groupId then
		return nil
	end

	--[[ Fetching ]]

	-- Updating data if missing for the group
	if not moduleSessionData.FetchedData[groupId] then
		Module._updateGroupData(player, groupId)
	end

	--[[ Data ]]

	--- @type Group_StoredData?
	local groupData = moduleSessionData.FetchedData[groupId]
	if not groupData then
		return nil
	end

	--[[ Returning ]]

	return groupData[dataName]
end

--%%%%%%%%%%%%%%%%%%%% On Is Member

--[[
	Answers a client's `Group_IsMember` invoke.
]]
--- @return boolean?
function Module._onIsMember(player: Player, groupName: string | number)
	return Module._getClientData(player, "IsMember", groupName)
end

--%%%%%%%%%%%%%%%%%%%% On Get Role

--[[
	Answers a client's `Group_GetRole` invoke.
]]
--- @return string?
function Module._onGetRole(player: Player, groupName: string | number)
	return Module._getClientData(player, "Role", groupName)
end

--%%%%%%%%%%%%%%%%%%%% On Get Rank

--[[
	Answers a client's `Group_GetRank` invoke.
]]
--- @return number?
function Module._onGetRank(player: Player, groupName: string | number)
	return Module._getClientData(player, "Rank", groupName)
end

--%%%%%%%%%%%%%%%%%%%% Get Client Data

--[[
	Returns group data for a client request.
	A group the server hasn't fetched for the player is read once, and at most `maxClientLookups` such groups per player.
]]
--- @return string | number | boolean | nil
function Module._getClientData(player: Player, dataName: string, groupName: string | number)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Group"]

	local groupId: number? = I.G_Group.GetId(groupName)
	if not groupId then
		return nil
	end

	--[[ Fetching ]]

	-- Read a group the server hasn't fetched for this player yet
	if not moduleSessionData.FetchedData[groupId] then
		-- Skip a group this player already asked for
		if table.find(moduleSessionData.ClientLookups, groupId) then
			return nil
		end

		-- Check if the player reached the lookup limit
		if #moduleSessionData.ClientLookups >= maxClientLookups then
			return nil
		end

		table.insert(moduleSessionData.ClientLookups, groupId)
		Module._updateGroupData(player, groupId)
	end

	--[[ Data ]]

	--- @type Group_StoredData?
	local groupData = moduleSessionData.FetchedData[groupId]
	if not groupData then
		return nil
	end

	--[[ Returning ]]

	return groupData[dataName]
end

--%%%%%%%%%%%%%%%%%%%% Get Proxy Roles

--[[
	Reads the player's role in every group they are in through the groups proxy.
	Returns group id -> role, leaving out ranks above the proxy's trusted maximum, or nil when the request fails.
]]
--- @return { [number]: Group_ProxyRole }?
function Module._getProxyRoles(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Requesting ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(HttpService.GetAsync, HttpService, proxyData.Url:format(player.UserId), true)

	-- Check if the request succeeded
	if not success then
		warn(`[{_localName}::{script.Name}]: Group proxy request failed for ({player.Name})! - {result}`)
		return nil
	end

	--[[ Decoding ]]

	local decodeSuccess: boolean
	local decoded: any | string?
	decodeSuccess, decoded = pcall(HttpService.JSONDecode, HttpService, result)

	-- Check if the answer has a data list
	if not decodeSuccess or type(decoded) ~= "table" or type(decoded.data) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Group proxy answer for ({player.Name}) is not valid!`)
		return nil
	end

	--[[ Finding ]]

	local proxyRoles = {} --- @type { [number]: Group_ProxyRole }

	for _: number, entry: any in ipairs(decoded.data) do
		--[[ Checks ]]

		-- Skip entries without group and role tables
		if type(entry) ~= "table" or type(entry.group) ~= "table" or type(entry.role) ~= "table" then
			continue
		end

		-- Skip entries missing a group id, rank or role name
		if type(entry.group.id) ~= "number" or type(entry.role.rank) ~= "number" or type(entry.role.name) ~= "string" then
			continue
		end

		-- Skip ranks above what the proxy is trusted for
		if entry.role.rank > proxyData.MaxRank then
			continue
		end

		--[[ Saving ]]

		proxyRoles[entry.group.id] = { Rank = entry.role.rank, Role = entry.role.name }
	end

	--[[ Returning ]]

	return proxyRoles
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
