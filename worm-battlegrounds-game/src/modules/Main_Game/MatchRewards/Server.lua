--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchRewards"

--- @type MatchRewards_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The participants another worm knocked out this match
local knockedOutByOther = {} --- @type { [string]: boolean }

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
	I.Network.GetEvent("Match_Results")
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	I.Topic.Subscribe("Match_ParticipantOut", Module._onParticipantOut)
	I.Topic.Subscribe("Match_PhaseChanged", Module._onPhaseChanged)
	I.Topic.Subscribe("Match_Ended", Module._payOut)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Participant Out

--[[
	Remembers a knockout by another worm, which pays the last places even before ANTI_FARM_ROUNDS.
]]
function Module._onParticipantOut(participantId: string, _cause: string, killerId: string?, _itemId: string?)
	--[[ Saving ]]

	if killerId and killerId ~= participantId then
		knockedOutByOther[participantId] = true
	end
end

--%%%%%%%%%%%%%%%%%%%% On Phase Changed

--[[
	Forgets the last match's knockouts when a new one drops in.
]]
function Module._onPhaseChanged(phase: string)
	--[[ Clearing ]]

	if phase == "Drop" then
		knockedOutByOther = {}
	end
end

--%%%%%%%%%%%%%%%%%%%% Pay Out

--[[
	Pays every player still here at the end of a match: coins by the kind of match and their place (doubled with the
	Double Coins pass), XP, and their statistics. Saves each profile at once, then sends them their results.
]]
--- @param placements { Match_Placement }
--- @param stats { [string]: Match_Stats }
--- @param metadata Match_Metadata
function Module._payOut(placements, stats, metadata)
	--[[ Local Variables ]]

	local lastPlace: number = 0
	--- @param placement Match_Placement
	for _index: number, placement in ipairs(placements) do
		lastPlace = math.max(lastPlace, placement.Place)
	end

	local coins = {} --- @type { [string]: string }
	--- @param placement Match_Placement
	for _index: number, placement in ipairs(placements) do
		coins[placement.ParticipantId] = tostring(Module._getCoins(placement, stats[placement.ParticipantId], metadata, #placements, lastPlace))
	end

	--[[ Paying ]]

	--- @param placement Match_Placement
	for _index: number, placement in ipairs(placements) do
		local participant = I.Match.GetParticipant(placement.ParticipantId) --- @type Match_Participant?
		local player: Player? = if participant and not participant.IsBot then I.S.Players:GetPlayerByUserId(participant.UserId) else nil
		if not player or not I.Player.Valid(player) then
			continue
		end

		local success: boolean
		local result: any | string?
		success, result = pcall(Module._payPlayer, player, placement, placements, stats, metadata, table.clone(coins))
		if not success then
			warn(`[{_localName}::{script.Name}]: Failed to pay player ({player.Name})! - ({result})`)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Pay Player

--[[
	Pays one player their coins, XP and statistics, saves their profile, and sends them their results.
]]
--- @param placement Match_Placement
--- @param placements { Match_Placement }
--- @param stats { [string]: Match_Stats }
--- @param metadata Match_Metadata
--- @param coins { [string]: string }
function Module._payPlayer(player: Player, placement, placements, stats, metadata, coins)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Coins ]]

	local entry = stats[placement.ParticipantId] --- @type Match_Stats?
	local amount: string = coins[placement.ParticipantId]
	if I.G_Marketplace.PlayerOwnsGamePass(player, _settings.DOUBLE_COINS_PASS) then
		amount = tostring(I.BN.new(amount) * I.BN.new("2"))
	end
	coins[placement.ParticipantId] = amount
	if amount ~= "0" then
		I.Currency.Add(player, "Coins", amount)
	end

	--[[ XP ]]

	local xp: number = if _settings.XP_KINDS[metadata.Kind] then _settings.XP_PER_MATCH else 0
	local level: number
	local leveledUp: boolean
	level, leveledUp = I.Progression.AddXP(player, xp)

	--[[ Statistics ]]

	I.Statistic.Add(player, "MatchesPlayed", "1")
	if placement.Place == 1 then
		I.Statistic.Add(player, "Wins", "1")
	end
	if entry then
		I.Statistic.Add(player, "Knockouts", tostring(entry.Knockouts))
		I.Statistic.Add(player, "DamageDealt", tostring(math.floor(entry.Damage)))
	end

	--[[ Saving ]]

	-- Saved before the results show, so a quick trip to the lobby can't lose the reward
	I.Player.GetProfile(player):Save()

	--[[ Sending ]]

	--- @type MatchRewards_Earned
	local earned = {
		Coins = coins,
		Xp = xp,
		Level = level,
		LevelUp = leveledUp,
	}
	I.Network.Fire("Match_Results", player, placements, stats, earned)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Coins

--[[
	Returns the coins a place pays: public deathmatches by player count, public team matches by team count (75 for
	winning a 2v2), solo matches a win by difficulty, custom and tutorial matches nothing. The last 2 places get
	nothing before ANTI_FARM_ROUNDS unless another worm knocked them out.
]]
--- @param placement Match_Placement
--- @param entry Match_Stats?
--- @param metadata Match_Metadata
--- @return number
function Module._getCoins(placement, entry, metadata, participantCount: number, lastPlace: number)
	--[[ Checks ]]

	-- Check if the place is one the anti-farming rule holds back
	local lastTwo: boolean = placement.Place > 1 and placement.Place > lastPlace - 2
	local played: boolean = (entry and entry.Rounds or 0) >= _settings.ANTI_FARM_ROUNDS or knockedOutByOther[placement.ParticipantId] == true
	if lastTwo and not played then
		return 0
	end

	--[[ Returning ]]

	if metadata.Kind == "Solo" then
		return if placement.Place == 1 then _settings.SOLO_COINS[metadata.Difficulty] or 0 else 0
	end
	if metadata.Kind ~= "Public" then
		return 0
	end

	local teamSize: number = I.Settings["Match"].TEAM_SIZES[metadata.Mode] or 1
	if teamSize == 1 then
		local row = _settings.DEATHMATCH_COINS[participantCount] or _settings.DEATHMATCH_COINS[8] --- @type { number }
		return row[placement.Place] or 0
	end
	if lastPlace == 2 and teamSize == 2 and placement.Place == 1 then
		return _settings.TEAM_2V2_WIN
	end
	local row = _settings.TEAM_COINS[lastPlace] or _settings.TEAM_COINS[2] --- @type { number }
	return row[placement.Place] or 0
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
