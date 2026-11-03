--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Friends"

--- @type Friends_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Players = I.S.Players
local HttpService = I.S.HttpService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Tracking ]]

local trackedPlayers = {} --- @type { [Player]: boolean }

--[[ Periodic Check ]]

local isChecking: boolean = false
local secondsSinceCheck: number = 0

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
	_st["Friends"] = {
		Active = {}, --- @type { string }
		Count = 0,
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnPlayerAdded(I.Priority.Replicator, Module._createReplicator)

	I.G_Player.OnPlayerAdded(I.Priority.Default, Module._onPlayerAdded)
	I.G_Player.OnPlayerRemoving(I.Priority.Default, Module._onPlayerRemoving)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Friends_DataUpdated", { "Player", { Type = "Player", Optional = true } })

	--- @Network
	I.Network.GetEvent("Friends_PromptGameInvite")
	I.Network.GetFunction("Friends_PromptGameInvite-Return")

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Friends = {

		--[[ Control ]]

		PromptGameInvite = Module.PromptGameInvite,

		--[[ Methods ]]

		GetActiveCount = Module.GetCount,
		GetActiveList = Module.GetList,
		GetActivePlayers = Module.GetActivePlayers,
		IsFriendsWith = Module.IsFriendsWith,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Module._mainLoop()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Main Loop

--[[
	Connects the periodic friends check to the shared one-second timer.
]]
function Module._mainLoop()
	--[[ Connections ]]

	I.DoEvery.Every(1, Module._tick)
end

--%%%%%%%%%%%%%%%%%%%% Tick

--[[
	Counts time since the last check and runs a new one when the delay for the current player count has passed.
]]
function Module._tick(elapsed: number)
	--[[ Counting ]]

	secondsSinceCheck += elapsed

	--[[ Checks ]]

	-- Skip until the delay for the current player count has passed
	if secondsSinceCheck < Module._getCheckDelay() then
		return
	end

	-- Skip while the previous check is still running
	if isChecking then
		return
	end

	--[[ Checking ]]

	secondsSinceCheck = 0
	Module._checkAll()
end

--%%%%%%%%%%%%%%%%%%%% Check All

--[[
	Checks every pair of players in the server once and updates the lists that changed.
	Picks up friendships made during the session.
]]
function Module._checkAll()
	--[[ Local Variables ]]

	isChecking = true

	local players = {} --- @type { Player }
	local changedPlayers = {} --- @type { [Player]: boolean }

	for player: Player, _tracked: boolean in pairs(trackedPlayers) do
		table.insert(players, player)
	end

	--[[ Checking ]]

	for index: number = 1, #players do
		for otherIndex: number = index + 1, #players do
			local player: Player = players[index]
			local friend: Player = players[otherIndex]

			--[[ Checks ]]

			-- Skip a pair when either player left
			if not trackedPlayers[player] or not trackedPlayers[friend] then
				continue
			end

			--[[ Finding ]]

			local isFriend: boolean? = Module._isFriendsAsync(player, friend)

			-- Skip when the check failed or either player left during it
			if isFriend == nil or not trackedPlayers[player] or not trackedPlayers[friend] then
				continue
			end

			--[[ Saving ]]

			if Module._setFriend(player, friend, isFriend) then
				changedPlayers[player] = true
			end
			if Module._setFriend(friend, player, isFriend) then
				changedPlayers[friend] = true
			end
		end
	end

	--[[ Applying ]]

	for player: Player, _changed: boolean in pairs(changedPlayers) do
		-- Skip players who left during the check
		if not trackedPlayers[player] then
			continue
		end

		local success: boolean
		local result: any | string?
		success, result = pcall(Module._applyList, player)
		if not success then
			warn(`[{_localName}::{script.Name}]: Failed to update friends for ({player.Name})! - ({result})`)
		end
	end

	isChecking = false
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Replicator

--[[
	Creates folder in the player's replicator for storing friends data.
]]
function Module._createReplicator(player: Player)
	-- Check if player is valid | SERVER
	if not I.Env.IsServer or not I.Player.Valid(player) then
		return
	end

	--[[ Creating Folder ]]

	I.Replicator.CreateFolder(player, _localName)

	--[[ Adding Attributes ]]

	I.Replicator.Set(player, _localName, "ActiveCount", 0)
	I.Replicator.Set(player, _localName, "ActiveList", HttpService:JSONEncode({}))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% On Player Added

--[[
	Starts tracking a joined player and checks them against everyone already in the server.
]]
function Module._onPlayerAdded(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Tracking ]]

	trackedPlayers[player] = true

	--[[ Checking ]]

	task.spawn(Module._checkJoined, player)
end

--%%%%%%%%%%%%%%%%%%%% Check Joined

--[[
	Checks a joined player against every other player once and updates both lists of each pair.
	Always publishes the joined player's list, even when it is empty.
]]
function Module._checkJoined(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Checking ]]

	for _: number, friend: Player in ipairs(Players:GetPlayers()) do
		--[[ Checks ]]

		-- Skip the player and anyone not tracked
		if friend == player or not trackedPlayers[friend] then
			continue
		end

		--[[ Finding ]]

		local isFriend: boolean? = Module._isFriendsAsync(player, friend)

		-- Stop when the joined player left during the check
		if not trackedPlayers[player] then
			return
		end

		-- Skip when the check failed or the friend left during it
		if isFriend == nil or not trackedPlayers[friend] then
			continue
		end

		--[[ Saving ]]

		Module._setFriend(player, friend, isFriend)

		-- Tell the other player's subscribers which friend joined
		if Module._setFriend(friend, player, isFriend) then
			Module._applyList(friend, player)
		end
	end

	--[[ Applying ]]

	Module._applyList(player)
end

--%%%%%%%%%%%%%%%%%%%% On Player Removing

--[[
	Stops tracking a leaving player and removes them from every other player's list, without web calls.
]]
function Module._onPlayerRemoving(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Tracking ]]

	trackedPlayers[player] = nil

	--[[ Removing ]]

	for friend: Player, _tracked: boolean in pairs(trackedPlayers) do
		-- Tell the other player's subscribers which friend left
		if Module._setFriend(friend, player, false) then
			Module._applyList(friend, player)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Prompt Game Invite

--[[
	Asks the player's client to open the Roblox game invite prompt.
	With `invoke`, waits for the client and returns whether the prompt opened.
]]
--- @param inviteOptions Friends_InviteOptions?
--- @return boolean?
function Module.PromptGameInvite(player: Player, inviteOptions, invoke: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Check if the invite options are a table
	if inviteOptions ~= nil and type(inviteOptions) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Invalid (inviteOptions) type. Expected (table), got ({typeof(inviteOptions)})!`)
		return false
	end

	--[[ Prompting ]]

	-- Wait for the client in invoke mode and only trust an exact true
	if invoke then
		return I.Network.Invoke("Friends_PromptGameInvite-Return", player, inviteOptions) == true
	end

	I.Network.Fire("Friends_PromptGameInvite", player, inviteOptions)
	return nil
end

--%%%%%%%%%%%%%%%%%%%% Set Friend

--[[
	Adds `friend` to or removes them from the player's in-server list.
	Returns whether the list changed.
]]
--- @return boolean
function Module._setFriend(player: Player, friend: Player, isFriend: boolean)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleData = sessionData["Friends"]

	--[[ Local Variables ]]

	local friendId: string = tostring(friend.UserId)
	local index: number? = table.find(moduleData.Active, friendId)

	--[[ Checks ]]

	-- Skip when the list already matches
	if isFriend == (index ~= nil) then
		return false
	end

	--[[ Saving ]]

	if isFriend then
		table.insert(moduleData.Active, friendId)
	else
		table.remove(moduleData.Active, index)
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Apply List

--[[
	Writes the player's list and count to the session and the Replicator, then publishes the update.
	`friend` is the one friend who joined or left, when that is what changed the list.
]]
function Module._applyList(player: Player, friend: Player?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleData = sessionData["Friends"]

	--[[ Saving ]]

	moduleData.Count = #moduleData.Active

	I.Replicator.Set(player, _localName, "ActiveCount", moduleData.Count)
	I.Replicator.Set(player, _localName, "ActiveList", HttpService:JSONEncode(moduleData.Active))

	--[[ Publishing ]]

	I.Topic.Publish("Friends_DataUpdated", player, friend)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Count

--[[
	**SERVER** |
	Returns the number of friends that are currently in the same server as the player.
]]
--- @return number?
function Module.GetCount(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleData = sessionData["Friends"]

	return moduleData.Count or 0
end

--%%%%%%%%%%%%%%%%%%%% Get List

--[[
	**SERVER** |
	Returns a copy of the user ids of the player's friends who are in the same server.
]]
--- @return { string }?
function Module.GetList(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleData = sessionData["Friends"]

	--[[ Returning ]]

	return table.clone(moduleData.Active)
end

--%%%%%%%%%%%%%%%%%%%% Get Active Players

--[[
	**SERVER** |
	Returns the player's friends who are in the same server as `Player` instances.
]]
--- @return { Player }?
function Module.GetActivePlayers(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleData = sessionData["Friends"]

	--[[ Finding ]]

	local activePlayers = {} --- @type { Player }

	for _: number, friendId: string in ipairs(moduleData.Active) do
		local friend: Player? = Players:GetPlayerByUserId(tonumber(friendId))

		-- Skip a friend who already left the server
		if not friend then
			continue
		end

		table.insert(activePlayers, friend)
	end

	--[[ Returning ]]

	return activePlayers
end

--%%%%%%%%%%%%%%%%%%%% Is Friends With

--[[
	Returns whether `player` is friends with `friend` based on the in-server friends list.
]]
--- @return boolean?
function Module.IsFriendsWith(player: Player, friend: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Checks ]]

	-- Check if friend is valid | SERVER
	if not I.Player.Valid(friend) then
		return nil
	end

	-- Check if both are the same player
	if player == friend then
		return false
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleData = sessionData["Friends"]

	--[[ Returning ]]

	return table.find(moduleData.Active, tostring(friend.UserId)) ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Get Check Delay

--[[
	Returns the seconds between periodic checks for the current player count.
	Up to `COUNT_CHECK_PLAYERS` players it is `COUNT_CHECK_DELAY`; above, it grows with the number of pairs so the check rate stays the same.
]]
--- @return number
function Module._getCheckDelay()
	--[[ Local Variables ]]

	local playerCount: number = #Players:GetPlayers()
	local pairCount: number = playerCount * (playerCount - 1) / 2
	local targetPairCount: number = _settings.COUNT_CHECK_PLAYERS * (_settings.COUNT_CHECK_PLAYERS - 1) / 2

	--[[ Returning ]]

	return _settings.COUNT_CHECK_DELAY * math.max(1, pairCount / targetPairCount)
end

--%%%%%%%%%%%%%%%%%%%% Is Friends Async

--[[
	Asks Roblox whether two players are friends.
	Returns nil and warns when the request fails.
]]
--- @return boolean?
function Module._isFriendsAsync(player: Player, friend: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Requesting ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(player.IsFriendsWithAsync, player, friend.UserId)

	--[[ Checks ]]

	-- Check if the request failed
	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to check if ({player.Name}) is friends with ({friend.Name})! - ({result})`)
		return nil
	end

	--[[ Returning ]]

	return result == true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
