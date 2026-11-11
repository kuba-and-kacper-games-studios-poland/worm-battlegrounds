--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchBoard"

--- @type MatchBoard_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Rows = require(script.Parent:FindFirstChild("Rows")) --- @type MatchBoard_Server_Rows
local Launch = require(script.Parent:FindFirstChild("Launch")) --- @type MatchBoard_Server_Launch

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The lobbies each player was invited to, by user id
local invites = {} --- @type { [number]: { [string]: boolean } }

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

--- @class MatchBoard_Server_Custom
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Network ]]

	I.Network.GetEvent("MatchBoard_CreateCustom", { "Player", "string", "string", { Type = "number", Min = 2, Max = 8 }, "string" }, { RateLimit = 1 })
	I.Network.Fired("MatchBoard_CreateCustom", Module.Create)
	I.Network.GetEvent("MatchBoard_InviteCustom", { "Player", "Player" }, { RateLimit = 2 })
	I.Network.Fired("MatchBoard_InviteCustom", Module.Invite)
	I.Network.GetEvent("MatchBoard_InviteAnswer", { "Player", "string", "boolean" }, { RateLimit = 2 })
	I.Network.Fired("MatchBoard_InviteAnswer", Module.Answer)
	I.Network.GetEvent("MatchBoard_StartCustom", { "Player" }, { RateLimit = 1 })
	I.Network.Fired("MatchBoard_StartCustom", Module.Start)
	I.Network.GetEvent("MatchBoard_LeaveCustom", { "Player" }, { RateLimit = 1 })
	I.Network.Fired("MatchBoard_LeaveCustom", Rows.Leave)
	I.Network.GetEvent("MatchBoard_Invited")
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Create

--[[
	**SERVER** |
	Makes a custom lobby the player owns, on a map from MAP_POOL, in Deathmatch or Teams, for 2 to 8 snails, its empty
	places filled with bots of a CUSTOM_DIFFICULTIES difficulty, or with none. Only a party's leader makes one, and
	their party is in it at once (their windows stay closed until they open CUSTOM).
]]
--- @return boolean
function Module.Create(player: Player, mapId: string, mode: string, size: number, difficulty: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Check if the lobby's settings are allowed
	if not table.find(_settings.MAP_POOL, mapId) or (mode ~= "Deathmatch" and mode ~= "Teams") or size % 2 ~= 0 then
		return false
	end

	-- Check if the bots' difficulty is allowed
	if not table.find(_settings.CUSTOM_DIFFICULTIES, difficulty) then
		return false
	end

	-- Check if the player may bring the party
	if player:GetAttribute("PartyId") and not player:GetAttribute("PartyLeader") then
		Launch._tell({ player }, "Only your party's leader can make a custom lobby.")
		return false
	end

	local group = Rows.GetGroup(player) --- @type { Player }

	-- Check if the party fits the lobby, on one team in Teams
	if #group > (if mode == "Teams" then size // 2 else size) then
		Launch._tell({ player }, "Your party doesn't fit: pick more players.")
		return false
	end

	--[[ Creating ]]

	Rows.Leave(player)
	local row = Rows.AddRow("Custom", mode, size, mapId, player.UserId) --- @type MatchBoard_Row
	row.Difficulty = difficulty
	table.insert(row.Players, player.UserId)

	-- The party joins with its leader, who stays first
	for _index: number, member: Player in ipairs(group) do
		if member ~= player then
			Rows.Leave(member)
			table.insert(row.Players, member.UserId)
		end
	end
	Rows.Publish(row)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Invite

--[[
	**SERVER** |
	The lobby's owner invites a player in this server; they're asked whether to join (MatchBoard_Invited).
]]
--- @return boolean
function Module.Invite(player: Player, target: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	local row = Rows.GetRowOf(player) --- @type MatchBoard_Row?

	--[[ Checks ]]

	-- Check if the player owns a lobby, and the target is someone else here
	if not row or row.Kind ~= "Custom" or row.Owner ~= player.UserId or target == player or target.Parent ~= I.S.Players then
		return false
	end

	--[[ Inviting ]]

	invites[target.UserId] = invites[target.UserId] or {}
	invites[target.UserId][row.Id] = true
	I.Network.Fire("MatchBoard_Invited", target, player.UserId, row.Id)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Answer

--[[
	**SERVER** |
	A player answers a lobby invite: yes joins the lobby when it has room.
]]
--- @return boolean
function Module.Answer(player: Player, roomId: string, accept: boolean)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	local row = Rows.GetRow(roomId) --- @type MatchBoard_Row?
	local invited: boolean = invites[player.UserId] ~= nil and invites[player.UserId][roomId] == true

	--[[ Checks ]]

	-- Check if the invite is real and the lobby still open
	if not invited then
		return false
	end
	invites[player.UserId][roomId] = nil
	if not accept or not row or #row.Players >= row.Size then
		return false
	end

	--[[ Joining ]]

	Rows.Leave(player)
	table.insert(row.Players, player.UserId)
	Rows.Publish(row)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Start

--[[
	**SERVER** |
	The lobby's owner starts it: everyone in it travels to the match, and its bots fill the empty places (Match's
	roster). A lobby without bots needs 2 or more players; with bots the owner may start it alone.
]]
--- @return boolean
function Module.Start(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	local row = Rows.GetRowOf(player) --- @type MatchBoard_Row?

	--[[ Checks ]]

	-- Check if the player owns the lobby
	if not row or row.Kind ~= "Custom" or row.Owner ~= player.UserId then
		return false
	end

	-- Check if anyone else, or bots, will play
	if #row.Players < 2 and row.Difficulty == "None" then
		Launch._tell({ player }, "Invite at least one more player, or add bots.")
		return false
	end

	-- Players outside the owner's party: a party always shares a team
	local partyId: string? = player:GetAttribute("PartyId")
	local rivals: number = 0
	for _index: number, userId: number in ipairs(row.Players) do
		local member: Player? = I.S.Players:GetPlayerByUserId(userId)
		if not partyId or not member or member:GetAttribute("PartyId") ~= partyId then
			rivals += 1
		end
	end

	-- Check if a Teams lobby without bots has someone to play against
	if row.Mode == "Teams" and row.Difficulty == "None" and rivals == 0 then
		Launch._tell({ player }, "Your party plays on one team: invite players from outside it, or add bots.")
		return false
	end

	--[[ Starting ]]

	Rows.StartRow(row)

	--[[ Returning ]]

	return true
end

return Module
