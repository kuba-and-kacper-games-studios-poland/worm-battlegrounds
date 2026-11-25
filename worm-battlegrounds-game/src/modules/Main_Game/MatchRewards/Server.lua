--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchRewards"

--- @type MatchRewards_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("ServerSettings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The participants another snail knocked out this match
local knockedOutByOther = {} --- @type { [string]: boolean }

-- What each participant paid when their team went out before the end was paid, so the end only sends their results
local paidEarly = {} --- @type { [string]: MatchRewards_Earned }

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
	I.Network.GetEvent("MatchRewards_Earned")
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
	Remembers a knockout by another snail, which pays the last places even before ANTI_FARM_ROUNDS, and pays the snail's
	team at once when it was their last one in (not for a player leaving the match, who forfeits: that waits for the
	end, as before).
]]
function Module._onParticipantOut(participantId: string, cause: string, killerId: string?, _itemId: string?)
	--[[ Saving ]]

	if killerId and killerId ~= participantId then
		knockedOutByOther[participantId] = true
	end

	--[[ Paying ]]

	if cause ~= "Left" then
		Module._payTeamOut(participantId)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Phase Changed

--[[
	Forgets the last match's knockouts and early pay when a new one drops in.
]]
function Module._onPhaseChanged(phase: string)
	--[[ Clearing ]]

	if phase == "Drop" then
		knockedOutByOther = {}
		paidEarly = {}
	end
end

--%%%%%%%%%%%%%%%%%%%% Pay Team Out

--[[
	Pays a team as soon as its last snail goes out while two or more teams are still in: its place can't change any more
	(teams that go out later finish above it), so its players get their diamonds and XP now, as the end would pay them, and
	their knocked-out screen shows them (`MatchRewards_Earned`). A local match, whose guests the host plays, waits for
	the end; so does the knockout that ends the match.
]]
function Module._payTeamOut(participantId: string)
	--[[ Data ]]

	local out = I.Match.GetParticipant(participantId) --- @type Match_Participant?
	local metadata = I.Match.GetMetadata() --- @type Match_Metadata
	if not out or metadata.Kind == "Local" then
		return
	end

	--[[ Checks ]]

	-- Check if the team is out and the match goes on
	local teamsIn = {} --- @type { [number]: boolean }
	local teamCount: number = 0
	--- @param participant Match_Participant
	for _index: number, participant in ipairs(I.Match.GetParticipants()) do
		if not participant.Out and not teamsIn[participant.Team] then
			teamsIn[participant.Team] = true
			teamCount += 1
		end
	end
	if teamsIn[out.Team] or teamCount < 2 then
		return
	end

	--[[ Local Variables ]]

	local placements = I.Match.GetPlacements() --- @type { Match_Placement }
	local stats = I.Match.GetStats() --- @type { [string]: Match_Stats }
	local lastPlace: number = 0
	--- @param placement Match_Placement
	for _index: number, placement in ipairs(placements) do
		lastPlace = math.max(lastPlace, placement.Place)
	end

	--[[ Paying ]]

	--- @param placement Match_Placement
	for _index: number, placement in ipairs(placements) do
		local participant = I.Match.GetParticipant(placement.ParticipantId) --- @type Match_Participant?
		local player: Player? = if participant and not participant.IsBot then I.S.Players:GetPlayerByUserId(participant.UserId) else nil
		if not participant or participant.Team ~= out.Team or paidEarly[placement.ParticipantId] or not player or not I.Player.Valid(player) then
			continue
		end

		local diamonds = { [placement.ParticipantId] = tostring(Module._getDiamonds(placement, stats[placement.ParticipantId], metadata, #placements, lastPlace)) } --- @type { [string]: string }
		local success: boolean
		local result: any | string?
		success, result = pcall(Module._payPlayer, player, placement, stats, metadata, diamonds)
		if not success then
			warn(`[{_localName}::{script.Name}]: Failed to pay player ({player.Name}) on their team's knockout! - ({result})`)
			continue
		end
		paidEarly[placement.ParticipantId] = result
		I.Network.Fire("MatchRewards_Earned", player, placement.Place, lastPlace, result, stats[placement.ParticipantId])
	end
end

--%%%%%%%%%%%%%%%%%%%% Pay Out

--[[
	Pays every player still here at the end of a match: diamonds by the kind of match and their place (doubled with the
	Double Diamonds pass), XP, and their statistics. Saves each profile at once, then sends them their results. Players
	their team's knockout already paid (`_payTeamOut`) only get their results, with what they were paid.
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

	local diamonds = {} --- @type { [string]: string }
	--- @param placement Match_Placement
	for _index: number, placement in ipairs(placements) do
		diamonds[placement.ParticipantId] = tostring(Module._getDiamonds(placement, stats[placement.ParticipantId], metadata, #placements, lastPlace))
	end

	--[[ Paying ]]

	--- @param placement Match_Placement
	for _index: number, placement in ipairs(placements) do
		local participant = I.Match.GetParticipant(placement.ParticipantId) --- @type Match_Participant?
		local player: Player? = if participant and not participant.IsBot then I.S.Players:GetPlayerByUserId(participant.UserId) else nil
		-- A local match's guests are the host's own snails: the host is paid (and sent the results) once, as their own
		if not player or not I.Player.Valid(player) or (participant and participant.Guest) then
			continue
		end

		-- Already paid on their team's knockout: the results show the others' diamonds and what they were paid
		local early = paidEarly[placement.ParticipantId] --- @type MatchRewards_Earned?
		if early then
			local shown = table.clone(diamonds) --- @type { [string]: string }
			shown[placement.ParticipantId] = early.Diamonds[placement.ParticipantId]
			early.Diamonds = shown
			I.Network.Fire("Match_Results", player, placements, stats, early)
			continue
		end

		local success: boolean
		local result: any | string?
		success, result = pcall(Module._payPlayer, player, placement, stats, metadata, table.clone(diamonds))
		if not success then
			warn(`[{_localName}::{script.Name}]: Failed to pay player ({player.Name})! - ({result})`)
			continue
		end
		I.Network.Fire("Match_Results", player, placements, stats, result)
	end
end

--%%%%%%%%%%%%%%%%%%%% Pay Player

--[[
	Pays one player their diamonds, XP (line by line, queued for their lobby's replay) and statistics, saves their
	profile, and returns what they earned (their results show it).
]]
--- @param placement Match_Placement
--- @param stats { [string]: Match_Stats }
--- @param metadata Match_Metadata
--- @param diamonds { [string]: string }
--- @return MatchRewards_Earned?
function Module._payPlayer(player: Player, placement, stats, metadata, diamonds)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Diamonds ]]

	local entry = stats[placement.ParticipantId] --- @type Match_Stats?
	local amount: string = diamonds[placement.ParticipantId]
	if I.G_Marketplace.PlayerOwnsGamePass(player, _settings.DOUBLE_DIAMONDS_PASS) then
		amount = tostring(I.BN.new(amount) * I.BN.new("2"))
	end
	diamonds[placement.ParticipantId] = amount
	if amount ~= "0" then
		I.Currency.Add(player, "Diamonds", amount)
	end

	--[[ XP ]]

	local lines = Module._getXpLines(placement, entry, metadata) --- @type { Progression_XpLine }
	local xp: number = 0
	--- @param line Progression_XpLine
	for _index: number, line in ipairs(lines) do
		xp += line.Amount
	end
	local before = I.Progression.GetProgress(player) --- @type Progression_Progress
	local level: number
	local leveledUp: boolean
	level, leveledUp = I.Progression.AddXP(player, xp)
	local after = I.Progression.GetProgress(player) --- @type Progression_Progress
	if xp > 0 then
		Module._queueReplay(player, lines, before, after)
	end
	I.Progression.AddReplayDiamonds(player, amount)

	--[[ Statistics ]]

	-- A local match is friends on one screen: it counts toward no statistic
	if metadata.Kind ~= "Local" then
		I.Statistic.Add(player, "MatchesPlayed", "1")
		if placement.Place == 1 then
			I.Statistic.Add(player, "Wins", "1")
		end
		if entry then
			I.Statistic.Add(player, "Knockouts", tostring(entry.Knockouts))
			I.Statistic.Add(player, "DamageDealt", tostring(math.floor(entry.Damage)))
		end
	end

	--[[ Saving ]]

	-- Saved before the results show, so a quick trip to the lobby can't lose the reward
	I.Player.GetProfile(player):Save()

	--[[ Returning ]]

	--- @type MatchRewards_Earned
	local earned = {
		Diamonds = diamonds,
		Xp = xp,
		Level = level,
		LevelUp = leveledUp,
		XpLines = lines,
		XpBefore = before,
		XpAfter = after,
	}
	return earned
end

--%%%%%%%%%%%%%%%%%%%% Queue Replay

--[[
	Adds a match's XP to what the player's lobby will play back: added to the lines still waiting from earlier matches
	(their level before stays the first match's), so a rematch on the same server shows both.
]]
--- @param lines { Progression_XpLine }
--- @param before Progression_Progress
--- @param after Progression_Progress
function Module._queueReplay(player: Player, lines, before, after)
	--[[ Data ]]

	local waiting = I.Progression.GetReplay(player) --- @type Progression_Replay?

	--[[ Merging ]]

	local merged = {} --- @type { Progression_XpLine }
	local byKey = {} --- @type { [string]: Progression_XpLine }
	--- @param line Progression_XpLine
	for _index: number, line in ipairs(if waiting then waiting.Lines else {}) do
		table.insert(merged, line)
		byKey[line.Key] = line
	end
	--- @param line Progression_XpLine
	for _index: number, line in ipairs(lines) do
		local kept = byKey[line.Key] --- @type Progression_XpLine?
		if kept then
			kept.Count += line.Count
			kept.Amount += line.Amount
			kept.Label = Module._getXpLabel(kept.Key, kept.Count)
		else
			table.insert(merged, table.clone(line))
		end
	end

	--[[ Saving ]]

	I.Progression.SetReplay(player, {
		Lines = merged,
		Before = if waiting then waiting.Before else before,
		After = after,
		Costs = {},
		Diamonds = if waiting then waiting.Diamonds else nil,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Xp Lines

--[[
	Returns the XP a place earns, line by line: XP_PER_MATCH for playing, XP_WIN for a win and XP_PER_KNOCKOUT for
	each snail knocked out. Nothing for the kinds of match XP_KINDS leaves out.
]]
--- @param placement Match_Placement
--- @param entry Match_Stats?
--- @param metadata Match_Metadata
--- @return { Progression_XpLine }
function Module._getXpLines(placement, entry, metadata)
	--[[ Checks ]]

	-- Check if the kind of match gives XP
	if not _settings.XP_KINDS[metadata.Kind] then
		return {}
	end

	--[[ Local Variables ]]

	local knockouts: number = if entry then entry.Knockouts else 0

	--- @type { Progression_XpLine }
	local lines = {
		{ Key = "Played", Label = Module._getXpLabel("Played", 1), Count = 1, Amount = _settings.XP_PER_MATCH },
	}

	--[[ Building ]]

	if placement.Place == 1 then
		table.insert(lines, { Key = "Win", Label = Module._getXpLabel("Win", 1), Count = 1, Amount = _settings.XP_WIN })
	end
	if knockouts > 0 then
		table.insert(lines, {
			Key = "Knockouts",
			Label = Module._getXpLabel("Knockouts", knockouts),
			Count = knockouts,
			Amount = knockouts * _settings.XP_PER_KNOCKOUT,
		})
	end

	--[[ Returning ]]

	return lines
end

--%%%%%%%%%%%%%%%%%%%% Get Xp Label

--[[
	Returns an XP line's text for a count of it (XP_LABELS).
]]
--- @return string
function Module._getXpLabel(key: string, count: number)
	--[[ Local Variables ]]

	local labels = _settings.XP_LABELS[key] --- @type { string }

	--[[ Returning ]]

	return if count == 1 then labels[1] else string.format(labels[2], count)
end

--%%%%%%%%%%%%%%%%%%%% Get Diamonds

--[[
	Returns the diamonds a place pays: public deathmatches by player count, public team matches by team count (38 for
	winning a 2v2), solo matches a win by difficulty, party matches as a deathmatch of their size (PARTY_NO_BOTS_SHARE
	of it without bots), custom and tutorial matches nothing. The last 2 places get nothing before ANTI_FARM_ROUNDS
	unless another snail knocked them out.
]]
--- @param placement Match_Placement
--- @param entry Match_Stats?
--- @param metadata Match_Metadata
--- @return number
function Module._getDiamonds(placement, entry, metadata, participantCount: number, lastPlace: number)
	--[[ Checks ]]

	-- Check if the place is one the anti-farming rule holds back
	local lastTwo: boolean = placement.Place > 1 and placement.Place > lastPlace - 2
	local played: boolean = (entry and entry.Rounds or 0) >= _settings.ANTI_FARM_ROUNDS or knockedOutByOther[placement.ParticipantId] == true
	if lastTwo and not played then
		return 0
	end

	--[[ Returning ]]

	if metadata.Kind == "Solo" then
		return if placement.Place == 1 then _settings.SOLO_DIAMONDS[metadata.Difficulty] or 0 else 0
	end
	if metadata.Kind == "Party" then
		local row = _settings.DEATHMATCH_DIAMONDS[participantCount] or _settings.DEATHMATCH_DIAMONDS[8] --- @type { number }
		local share: number = if metadata.Difficulty == "None" then _settings.PARTY_NO_BOTS_SHARE else 1
		return math.floor((row[placement.Place] or 0) * share)
	end
	if metadata.Kind ~= "Public" then
		return 0
	end

	local teamSize: number = I.Settings["Match"].TEAM_SIZES[metadata.Mode] or 1
	if teamSize == 1 then
		local row = _settings.DEATHMATCH_DIAMONDS[participantCount] or _settings.DEATHMATCH_DIAMONDS[8] --- @type { number }
		return row[placement.Place] or 0
	end
	if lastPlace == 2 and teamSize == 2 and placement.Place == 1 then
		return _settings.TEAM_2V2_WIN
	end
	local row = _settings.TEAM_DIAMONDS[lastPlace] or _settings.TEAM_DIAMONDS[2] --- @type { number }
	return row[placement.Place] or 0
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
