--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchBoard"

--- @type MatchBoard_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Launch = require(script.Parent:FindFirstChild("Launch")) --- @type MatchBoard_Server_Launch

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local boardFolder: Folder
local nextId: number = 0

-- Every row on the board and every custom lobby, by id
local rows = {} --- @type { [string]: MatchBoard_Row }

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

--- @class MatchBoard_Server_Rows
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Folder ]]

	boardFolder = I.Create("Folder")({
		Name = _localName,
		Parent = I.Dirs.UmeReplicated,
	})

	--[[ Network ]]

	I.Network.GetEvent("MatchBoard_Join", { "Player", "string" }, { RateLimit = 2 })
	I.Network.Fired("MatchBoard_Join", Module.Join)
	I.Network.GetEvent("MatchBoard_Leave", { "Player" }, { RateLimit = 2 })
	I.Network.Fired("MatchBoard_Leave", Module.Leave)
	I.Network.GetEvent("MatchBoard_Vote", { "Player" }, { RateLimit = 2 })
	I.Network.Fired("MatchBoard_Vote", Module._onVote)
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Rows ]]

	--- @param option MatchBoard_RowOption
	for _index: number, option in ipairs(_settings.PUBLIC_ROWS) do
		Module.AddRow("Public", option.Mode, option.Size, Launch.GetMap(option.Size))
	end

	--[[ Connections ]]

	I.S.Players.PlayerRemoving:Connect(function(player: Player)
		Module._removeUser(player.UserId)
	end)
	I.DoEvery.Every(0.25, Module._checkTimers)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Add Row

--[[
	**SERVER** |
	Adds a row (a public match or a custom lobby) to the board and returns it.
]]
--- @return MatchBoard_Row
function Module.AddRow(kind: "Public" | "Custom", mode: string, size: number, mapId: string, owner: number?)
	--[[ Local Variables ]]

	nextId += 1
	local id: string = `{kind}_{nextId}`

	--[[ Building ]]

	--- @type MatchBoard_Row
	local row = {
		Id = id,
		Config = I.Create("Configuration")({ Name = id, Parent = boardFolder }),
		Kind = kind,
		Mode = mode,
		Size = size,
		MapId = mapId,
		Difficulty = _settings.PUBLIC_DIFFICULTY,
		Players = {},
		Votes = {},
		EndsAt = if kind == "Public" then I.S.Workspace:GetServerTimeNow() + _settings.ROW_SECONDS else 0,
		Owner = owner,
	}
	rows[id] = row

	--[[ Publishing ]]

	Module.Publish(row)

	--[[ Returning ]]

	return row
end

--%%%%%%%%%%%%%%%%%%%% Join

--[[
	**SERVER** |
	Puts a player, with their whole party, in a public row. Refused when they're in a party but not its leader, when
	the party is bigger than a team, or when the row has no room. A full row starts at once.
]]
--- @return boolean
function Module.Join(player: Player, rowId: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	local row = rows[rowId] --- @type MatchBoard_Row?
	local group = Module._getGroup(player) --- @type { Player }

	--[[ Checks ]]

	-- Check if it's a public row
	if not row or row.Kind ~= "Public" then
		return false
	end

	-- Check if the player may bring the party
	if player:GetAttribute("PartyId") and not player:GetAttribute("PartyLeader") then
		Launch._tell({ player }, "Only your party's leader can join a match.")
		return false
	end

	-- Check if the party fits a team and the row
	if #group > (_settings.TEAM_SIZES[row.Mode] or 1) and row.Mode ~= "Deathmatch" or #row.Players + #group > row.Size then
		Launch._tell({ player }, "Your party doesn't fit in that match.")
		return false
	end

	--[[ Joining ]]

	for _index: number, member: Player in ipairs(group) do
		Module._removeUser(member.UserId)
		table.insert(row.Players, member.UserId)
	end
	Module.Publish(row)

	--[[ Starting ]]

	if #row.Players >= row.Size then
		Module.StartRow(row)
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Leave

--[[
	**SERVER** |
	Takes a player out of whichever row or lobby they're in.
]]
function Module.Leave(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Leaving ]]

	Module._removeUser(player.UserId)
end

--%%%%%%%%%%%%%%%%%%%% Remove User

--[[
	Takes a user out of whichever row or lobby they're in; a custom lobby whose owner leaves closes.
]]
function Module._removeUser(userId: number)
	--[[ Leaving ]]

	--- @param row MatchBoard_Row
	for id: string, row in pairs(rows) do
		local index: number? = table.find(row.Players, userId)
		if not index then
			continue
		end
		table.remove(row.Players, index)
		row.Votes[userId] = nil

		if row.Kind == "Custom" and row.Owner == userId then
			Module.RemoveRow(id)
		else
			Module.Publish(row)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Start Row

--[[
	**SERVER** |
	Launches a row's match with its players still here (bots fill the empty seats); a public row is replaced by a fresh
	one of its mode on another map, its timer starting over, and a custom lobby closes. Players who couldn't go stay
	on the board.
]]
--- @param row MatchBoard_Row
function Module.StartRow(row)
	--[[ Local Variables ]]

	local players = {} --- @type { Player }
	for _index: number, userId: number in ipairs(row.Players) do
		local player: Player? = I.S.Players:GetPlayerByUserId(userId)
		if player then
			table.insert(players, player)
		end
	end

	--[[ Replacing ]]

	Module.RemoveRow(row.Id)
	if row.Kind == "Public" then
		Module.AddRow("Public", row.Mode, row.Size, Launch.GetMap(row.Size, row.MapId))
	end

	--[[ Launching ]]

	if #players > 0 then
		task.spawn(Launch.Launch, players, row.Kind, row.Mode, row.Size, row.MapId, row.Difficulty)
	end
end

--%%%%%%%%%%%%%%%%%%%% Remove Row

--[[
	**SERVER** |
	Takes a row off the board.
]]
function Module.RemoveRow(rowId: string)
	--[[ Data ]]

	local row = rows[rowId] --- @type MatchBoard_Row?
	if not row then
		return
	end

	--[[ Removing ]]

	rows[rowId] = nil
	row.Config:Destroy()
end

--%%%%%%%%%%%%%%%%%%%% On Vote

--[[
	A player in a public row votes to start it now; the row starts once VOTE_FRACTION of its players voted.
]]
function Module._onVote(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	local row = Module.GetRowOf(player) --- @type MatchBoard_Row?

	--[[ Checks ]]

	-- Check if they wait in a public row
	if not row or row.Kind ~= "Public" then
		return
	end

	--[[ Voting ]]

	row.Votes[player.UserId] = true
	Module.Publish(row)
	if Module._getVoteCount(row) >= Module._getVotesNeeded(row) then
		Module.StartRow(row)
	end
end

--%%%%%%%%%%%%%%%%%%%% Check Timers

--[[
	Starts every public row whose timer ran out: with whoever joined, or with nobody, so the board keeps moving and its
	maps change.
]]
function Module._checkTimers()
	--[[ Checking ]]

	local now: number = I.S.Workspace:GetServerTimeNow()
	--- @param row MatchBoard_Row
	for _id: string, row in pairs(rows) do
		if row.Kind == "Public" and now >= row.EndsAt then
			Module.StartRow(row)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Publish

--[[
	Writes a row into its Configuration for every client: Kind, Mode, Size, MapId, Difficulty, Players (JSON user
	ids), EndsAt, Votes, VotesNeeded and Owner.
]]
--- @param row MatchBoard_Row
function Module.Publish(row)
	--[[ Saving ]]

	row.Config:SetAttribute("Kind", row.Kind)
	row.Config:SetAttribute("Mode", row.Mode)
	row.Config:SetAttribute("Size", row.Size)
	row.Config:SetAttribute("MapId", row.MapId)
	row.Config:SetAttribute("Difficulty", row.Difficulty)
	row.Config:SetAttribute("Players", I.S.HttpService:JSONEncode(row.Players))
	row.Config:SetAttribute("EndsAt", row.EndsAt)
	row.Config:SetAttribute("Votes", Module._getVoteCount(row))
	row.Config:SetAttribute("VotesNeeded", Module._getVotesNeeded(row))
	row.Config:SetAttribute("Owner", row.Owner or 0)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Row

--[[
	**SERVER** |
	Returns a row by its id.
]]
--- @return MatchBoard_Row?
function Module.GetRow(rowId: string)
	return rows[rowId]
end

--%%%%%%%%%%%%%%%%%%%% Get Row Of

--[[
	**SERVER** |
	Returns the row or lobby a player is in.
]]
--- @return MatchBoard_Row?
function Module.GetRowOf(player: Player)
	--[[ Searching ]]

	--- @param row MatchBoard_Row
	for _id: string, row in pairs(rows) do
		if table.find(row.Players, player.UserId) then
			return row
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Group

--[[
	Returns the players who travel with a player: their party's members in this server, or just them.
]]
--- @return { Player }
function Module._getGroup(player: Player)
	--[[ Data ]]

	local partyId: string? = player:GetAttribute("PartyId")
	if not partyId then
		return { player }
	end

	--[[ Returning ]]

	return I.Party.GetMembers(partyId)
end

--%%%%%%%%%%%%%%%%%%%% Get Vote Count

--[[
	Returns how many of a row's players voted to start.
]]
--- @param row MatchBoard_Row
--- @return number
function Module._getVoteCount(row)
	--[[ Counting ]]

	local count: number = 0
	for _userId: number, _voted: boolean in pairs(row.Votes) do
		count += 1
	end

	--[[ Returning ]]

	return count
end

--%%%%%%%%%%%%%%%%%%%% Get Votes Needed

--[[
	Returns the votes that start a row now: VOTE_FRACTION of its players, rounded up (at least 1).
]]
--- @param row MatchBoard_Row
--- @return number
function Module._getVotesNeeded(row)
	return math.max(math.ceil(#row.Players * _settings.VOTE_FRACTION), 1)
end

return Module
