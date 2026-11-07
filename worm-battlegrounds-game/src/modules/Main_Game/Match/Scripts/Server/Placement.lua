--[[
	Created By: 	Nari
]]

-- --- @type Ume
-- local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Match"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Roster = require(script.Parent:FindFirstChild("Roster")) --- @type Match_Server_Roster

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Participant ids in the order they went out
local outOrder = {} --- @type { string }

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

--- @class Match_Server_Placement
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Reset

--[[
	Forgets who went out, for a new match.
]]
function Module.Reset()
	outOrder = {}
end

--%%%%%%%%%%%%%%%%%%%% Record Out

--[[
	Marks a participant out of the match, after everyone already out: a knockout, or a player leaving, who is placed
	last among those still in.
]]
function Module.RecordOut(participantId: string)
	--[[ Data ]]

	--- @type Match_Participant?
	local participant = Roster.GetParticipant(participantId)

	--[[ Checks ]]

	-- Check if the participant is still in
	if not participant or participant.Out then
		return
	end

	--[[ Saving ]]

	participant.Out = true
	table.insert(outOrder, participantId)
	Roster.SetInfo(participantId, "Out", true)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Placements

--[[
	Returns every participant's place: teams still in come first, then teams by how late their last snail went out.
	In team modes every member gets the team's place.
]]
--- @return { Match_Placement }
function Module.GetPlacements()
	--[[ Local Variables ]]

	-- Each team's last time out (its position in outOrder), with teams still in counting as never out
	local lastOut = {} --- @type { [number]: number }
	local outIndex = {} --- @type { [string]: number }
	for index: number, id: string in ipairs(outOrder) do
		outIndex[id] = index
	end

	--- @param participant Match_Participant
	for _index: number, participant in ipairs(Roster.GetParticipants()) do
		local index: number = if participant.Out then outIndex[participant.Id] or 0 else math.huge
		lastOut[participant.Team] = math.max(lastOut[participant.Team] or 0, index)
	end

	--[[ Ranking ]]

	local teams = {} --- @type { number }
	for team: number in pairs(lastOut) do
		table.insert(teams, team)
	end
	table.sort(teams, function(a: number, b: number)
		return lastOut[a] > lastOut[b]
	end)

	local places = {} --- @type { [number]: number }
	for rank: number, team: number in ipairs(teams) do
		places[team] = rank
	end

	--[[ Returning ]]

	local placements = {} --- @type { Match_Placement }
	--- @param participant Match_Participant
	for _index: number, participant in ipairs(Roster.GetParticipants()) do
		table.insert(placements, { ParticipantId = participant.Id, Place = places[participant.Team] })
	end
	--- @param a Match_Placement
	--- @param b Match_Placement
	table.sort(placements, function(a, b)
		return a.Place < b.Place
	end)
	return placements
end

--%%%%%%%%%%%%%%%%%%%% Is Over

--[[
	Returns whether at most one team is still in.
]]
--- @return boolean
function Module.IsOver()
	--[[ Local Variables ]]

	local teams = {} --- @type { [number]: boolean }
	local count: number = 0

	--[[ Counting ]]

	--- @param participant Match_Participant
	for _index: number, participant in ipairs(Roster.GetParticipants()) do
		if not participant.Out and not teams[participant.Team] then
			teams[participant.Team] = true
			count += 1
		end
	end

	--[[ Returning ]]

	return count <= 1
end

return Module
