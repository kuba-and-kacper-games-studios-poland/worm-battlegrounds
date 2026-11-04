--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Party"

--- @type Party_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Each party's members (user ids, the leader first), by party id
local parties = {} --- @type { [string]: { number } }

-- Open invites: when each runs out (os.clock), by invited user id, then by inviter's user id
local invites = {} --- @type { [number]: { [number]: number } }

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
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("Party_Invite", { "Player", "Player" }, { RateLimit = 2 })
	I.Network.Fired("Party_Invite", Module.Invite)
	I.Network.GetEvent("Party_Answer", { "Player", "number", "boolean" }, { RateLimit = 2 })
	I.Network.Fired("Party_Answer", Module.Answer)
	I.Network.GetEvent("Party_Leave", { "Player" }, { RateLimit = 1 })
	I.Network.Fired("Party_Leave", Module.Leave)
	I.Network.GetEvent("Party_Kick", { "Player", "Player" }, { RateLimit = 2 })
	I.Network.Fired("Party_Kick", Module.Kick)
	I.Network.GetEvent("Party_Invited")

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Party = {

		--[[ Control ]]

		Leave = Module.Leave,

		--[[ Methods ]]

		GetParty = Module.GetParty,
		GetMembers = Module.GetMembers,
		IsLeader = Module.IsLeader,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	I.S.Players.PlayerRemoving:Connect(function(player: Player)
		invites[player.UserId] = nil
		Module._remove(player.UserId)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Leave

--[[
	**SERVER** |
	Takes a player out of their party.
]]
function Module.Leave(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Leaving ]]

	Module._remove(player.UserId)
end

--%%%%%%%%%%%%%%%%%%%% Invite

--[[
	A player invites someone in this server who isn't in a party; they're asked (Party_Invited) for INVITE_SECONDS.
]]
function Module.Invite(player: Player, target: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	local partyId: string? = Module.GetParty(player)

	--[[ Checks ]]

	-- Check if the target is someone else here, not in a party
	if target == player or target.Parent ~= I.S.Players or Module.GetParty(target) then
		return
	end

	-- Check if the inviter's party has room and they lead it
	if partyId and (#parties[partyId] >= _settings.MAX_PARTY or not Module.IsLeader(player)) then
		I.Notify.ShowNotification(player, "Only the party's leader can invite, up to 4 players.")
		return
	end

	--[[ Inviting ]]

	invites[target.UserId] = invites[target.UserId] or {}
	invites[target.UserId][player.UserId] = os.clock() + _settings.INVITE_SECONDS
	I.Network.Fire("Party_Invited", target, player.UserId)
end

--%%%%%%%%%%%%%%%%%%%% Answer

--[[
	A player answers an invite: yes joins the inviter's party (made now if they had none) while it has room.
]]
function Module.Answer(player: Player, fromUserId: number, accept: boolean)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	local expires: number? = invites[player.UserId] and invites[player.UserId][fromUserId]
	local inviter: Player? = I.S.Players:GetPlayerByUserId(fromUserId)

	--[[ Checks ]]

	-- Check if the invite is real and still open
	if not expires then
		return
	end
	invites[player.UserId][fromUserId] = nil
	if not accept or os.clock() > expires or not inviter then
		return
	end

	--[[ Joining ]]

	local partyId: string = Module.GetParty(inviter) or I.S.HttpService:GenerateGUID(false)
	parties[partyId] = parties[partyId] or { inviter.UserId }
	if #parties[partyId] >= _settings.MAX_PARTY then
		return
	end
	Module._remove(player.UserId)
	table.insert(parties[partyId], player.UserId)

	--[[ Publishing ]]

	Module._publish(partyId)
end

--%%%%%%%%%%%%%%%%%%%% Kick

--[[
	A party's leader takes a member out.
]]
function Module.Kick(player: Player, target: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Checks ]]

	-- Check if the player leads the target's party
	if not Module.IsLeader(player) or target == player or Module.GetParty(target) ~= Module.GetParty(player) then
		return
	end

	--[[ Kicking ]]

	Module._remove(target.UserId)
end

--%%%%%%%%%%%%%%%%%%%% Remove

--[[
	Takes a user out of their party: the lead passes to the next member, and a party of one breaks up.
]]
function Module._remove(userId: number)
	--[[ Searching ]]

	for partyId: string, members: { number } in pairs(parties) do
		local index: number? = table.find(members, userId)
		if not index then
			continue
		end

		--[[ Removing ]]

		table.remove(members, index)
		Module._clear(userId)
		if #members <= 1 then
			for _index: number, memberId: number in ipairs(members) do
				Module._clear(memberId)
			end
			parties[partyId] = nil
		else
			Module._publish(partyId)
		end
		return
	end
end

--%%%%%%%%%%%%%%%%%%%% Publish

--[[
	Writes a party onto its members' Player attributes: PartyId on each, PartyLeader on the first.
]]
function Module._publish(partyId: string)
	--[[ Saving ]]

	for index: number, userId: number in ipairs(parties[partyId]) do
		local member: Player? = I.S.Players:GetPlayerByUserId(userId)
		if member then
			member:SetAttribute("PartyId", partyId)
			member:SetAttribute("PartyLeader", index == 1)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Clear

--[[
	Takes the party attributes off a user who left it.
]]
function Module._clear(userId: number)
	--[[ Data ]]

	local player: Player? = I.S.Players:GetPlayerByUserId(userId)
	if not player then
		return
	end

	--[[ Saving ]]

	player:SetAttribute("PartyId", nil)
	player:SetAttribute("PartyLeader", nil)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Party

--[[
	**SERVER** |
	Returns the id of a player's party, or nil.
]]
--- @return string?
function Module.GetParty(player: Player)
	return player:GetAttribute("PartyId")
end

--%%%%%%%%%%%%%%%%%%%% Get Members

--[[
	**SERVER** |
	Returns a party's members in this server, the leader first.
]]
--- @return { Player }
function Module.GetMembers(partyId: string)
	--[[ Local Variables ]]

	local members = {} --- @type { Player }

	--[[ Collecting ]]

	for _index: number, userId: number in ipairs(parties[partyId] or {}) do
		local member: Player? = I.S.Players:GetPlayerByUserId(userId)
		if member then
			table.insert(members, member)
		end
	end

	--[[ Returning ]]

	return members
end

--%%%%%%%%%%%%%%%%%%%% Is Leader

--[[
	**SERVER** |
	Returns whether a player leads their party.
]]
--- @return boolean
function Module.IsLeader(player: Player)
	return player:GetAttribute("PartyLeader") == true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
