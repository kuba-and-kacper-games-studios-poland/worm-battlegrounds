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
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Connections ]]

	I.S.Players.PlayerRemoving:Connect(function(player: Player)
		Module._removeUser(player.UserId)
	end)
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
		Wind = false,
		Players = {},
		Owner = owner,
	}
	rows[id] = row

	--[[ Publishing ]]

	Module.Publish(row)

	--[[ Returning ]]

	return row
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
	Launches a custom lobby's match with its players still here (its bots fill the empty seats) and closes it. Players
	who couldn't go stay on the board.
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

	--[[ Closing ]]

	Module.RemoveRow(row.Id)

	--[[ Launching ]]

	if #players > 0 then
		task.spawn(Launch.Launch, players, row.Kind, row.Mode, row.Size, row.MapId, row.Difficulty, false, row.Wind)
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

--%%%%%%%%%%%%%%%%%%%% Publish

--[[
	Writes a row into its Configuration for every client: Kind, Mode, Size, MapId ("" on a public card, whose map is
	the rotation's), Difficulty, Wind, Players (JSON user ids) and Owner.
]]
--- @param row MatchBoard_Row
function Module.Publish(row)
	--[[ Saving ]]

	row.Config:SetAttribute("Kind", row.Kind)
	row.Config:SetAttribute("Mode", row.Mode)
	row.Config:SetAttribute("Size", row.Size)
	row.Config:SetAttribute("MapId", row.MapId)
	row.Config:SetAttribute("Difficulty", row.Difficulty)
	row.Config:SetAttribute("Wind", row.Wind)
	row.Config:SetAttribute("Players", I.S.HttpService:JSONEncode(row.Players))
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
	**SERVER** |
	Returns the players who travel with a player: their party's members in this server, or just them.
]]
--- @return { Player }
function Module.GetGroup(player: Player)
	--[[ Data ]]

	local partyId: string? = player:GetAttribute("PartyId")
	if not partyId then
		return { player }
	end

	--[[ Returning ]]

	return I.Party.GetMembers(partyId)
end

return Module
