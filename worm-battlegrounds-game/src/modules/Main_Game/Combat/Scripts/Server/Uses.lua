--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Uses left (-1 is unlimited) and own turns of cooldown left, by participant id, then item id
local uses = {} --- @type { [string]: { [string]: number } }
local cooldowns = {} --- @type { [string]: { [string]: number } }

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

--- @class Combat_Server_Uses
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Connections ]]

	I.G_Player.OnPlayerAdded(I.Priority.Replicator, function(player: Player)
		I.Replicator.CreateFolder(player, _localName)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Connections ]]

	I.Topic.Subscribe("Match_PhaseChanged", function(phase: string)
		if phase == "Drop" then
			Module.Reset()
		end
	end)
	I.Topic.Subscribe("Match_TurnStarted", Module._onTurnStarted)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Reset

--[[
	**SERVER** |
	Fills every participant's uses for a new match from their loadout (the Bazooka always), with no cooldowns, and
	tells each player their loadout and uses.
]]
function Module.Reset()
	--[[ Saving ]]

	uses = {}
	cooldowns = {}

	--- @param participant Match_Participant
	for _index: number, participant in ipairs(I.Match.GetParticipants()) do
		uses[participant.Id] = { Bazooka = -1 }
		cooldowns[participant.Id] = { Bazooka = 0 }
		for _slot: number, itemId: string in ipairs(participant.Loadout) do
			local row = I.G_Arsenal.Get(itemId) --- @type (Arsenal_WeaponData | Arsenal_UtilityData)?
			if row then
				uses[participant.Id][itemId] = row.Uses
				cooldowns[participant.Id][itemId] = 0
			end
		end
		Module._publish(participant)
	end
end

--%%%%%%%%%%%%%%%%%%%% Take

--[[
	**SERVER** |
	Takes one use of an item and starts its cooldown: the player waits Cooldown of their own turns before the next.
]]
function Module.Take(participantId: string, itemId: string)
	--[[ Data ]]

	local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData
	local itemUses: number = uses[participantId][itemId]

	--[[ Saving ]]

	if itemUses > 0 then
		uses[participantId][itemId] = itemUses - 1
	end

	-- The turn it's used on counts down too, so the cooldown starts one higher
	if row.Cooldown and row.Cooldown > 0 then
		cooldowns[participantId][itemId] = row.Cooldown + 1
	end

	--[[ Publishing ]]

	Module._publish(I.Match.GetParticipant(participantId))
end

--%%%%%%%%%%%%%%%%%%%% On Turn Started

--[[
	Counts one of the participant's own turns off every cooldown they have.
]]
function Module._onTurnStarted(participantId: string)
	--[[ Data ]]

	local itemCooldowns: { [string]: number }? = cooldowns[participantId]
	if not itemCooldowns then
		return
	end

	--[[ Saving ]]

	for itemId: string, turns: number in pairs(itemCooldowns) do
		itemCooldowns[itemId] = math.max(turns - 1, 0)
	end

	--[[ Publishing ]]

	Module._publish(I.Match.GetParticipant(participantId))
end

--%%%%%%%%%%%%%%%%%%%% Publish

--[[
	Writes a player's loadout, uses and cooldowns into their Combat replicator folder: Slots (item ids joined by
	commas), Uses_<ItemId> and Cooldown_<ItemId>. Bots have no folder.
]]
--- @param participant Match_Participant?
function Module._publish(participant)
	--[[ Data ]]

	local player: Player? = if participant and not participant.IsBot then I.S.Players:GetPlayerByUserId(participant.UserId) else nil
	if not player or not participant then
		return
	end

	--[[ Saving ]]

	I.Replicator.Set(player, _localName, "Slots", table.concat(participant.Loadout, ","))
	for itemId: string, left: number in pairs(uses[participant.Id]) do
		I.Replicator.Set(player, _localName, `Uses_{itemId}`, left)
		I.Replicator.Set(player, _localName, `Cooldown_{itemId}`, cooldowns[participant.Id][itemId])
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Can Use

--[[
	**SERVER** |
	Returns whether a participant may use an item now: it's the Bazooka or in their loadout, with uses left and no
	cooldown.
]]
--- @return boolean
function Module.CanUse(participantId: string, itemId: string)
	--[[ Data ]]

	local itemUses: number? = uses[participantId] and uses[participantId][itemId]

	--[[ Returning ]]

	return itemUses ~= nil and itemUses ~= 0 and cooldowns[participantId][itemId] == 0
end

--%%%%%%%%%%%%%%%%%%%% Get Uses

--[[
	**SERVER** |
	Returns an item's uses left (-1 is unlimited) and its cooldown turns left for a participant, nil when it isn't in
	their loadout.
]]
--- @return number?, number?
function Module.GetUses(participantId: string, itemId: string)
	--[[ Data ]]

	local itemUses: { [string]: number }? = uses[participantId]
	if not itemUses or not itemUses[itemId] then
		return nil, nil
	end

	--[[ Returning ]]

	return itemUses[itemId], cooldowns[participantId][itemId]
end

return Module
