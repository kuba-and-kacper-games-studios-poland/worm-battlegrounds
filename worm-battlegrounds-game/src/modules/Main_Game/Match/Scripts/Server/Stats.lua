--[[
	Created By: 	Nari
]]

-- --- @type Ume
-- local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Match"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Each participant's match stats, by id
local stats = {} --- @type { [string]: Match_Stats }

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

--- @class Match_Server_Stats
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Reset

--[[
	Starts empty stats for each participant of a new match.
]]
--- @param participantIds { string }
function Module.Reset(participantIds)
	--[[ Saving ]]

	stats = {}
	for _index: number, id: string in ipairs(participantIds) do
		stats[id] = { Damage = 0, Knockouts = 0, Rounds = 0, BestShot = 0 }
	end
end

--%%%%%%%%%%%%%%%%%%%% Add Shot

--[[
	Counts a participant's resolved shot: its damage, and their best shot.
]]
function Module.AddShot(participantId: string, damage: number)
	--[[ Data ]]

	--- @type Match_Stats?
	local entry = stats[participantId]
	if not entry then
		return
	end

	--[[ Saving ]]

	entry.Damage += damage
	entry.BestShot = math.max(entry.BestShot, damage)
end

--%%%%%%%%%%%%%%%%%%%% Add Knockout

--[[
	Counts a knockout for the participant who caused it.
]]
function Module.AddKnockout(participantId: string)
	--[[ Data ]]

	--- @type Match_Stats?
	local entry = stats[participantId]
	if not entry then
		return
	end

	--[[ Saving ]]

	entry.Knockouts += 1
end

--%%%%%%%%%%%%%%%%%%%% Add Round

--[[
	Counts a round a participant played while still in.
]]
function Module.AddRound(participantId: string)
	--[[ Data ]]

	--- @type Match_Stats?
	local entry = stats[participantId]
	if not entry then
		return
	end

	--[[ Saving ]]

	entry.Rounds += 1
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns every participant's stats, by id.
]]
--- @return { [string]: Match_Stats }
function Module.Get()
	return stats
end

return Module
