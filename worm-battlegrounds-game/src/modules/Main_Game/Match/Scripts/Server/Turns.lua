--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Match"

--- @type Match_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Roster = require(script.Parent:FindFirstChild("Roster")) --- @type Match_Server_Roster
local Stats = require(script.Parent:FindFirstChild("Stats")) --- @type Match_Server_Stats

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Order ]]

-- The teams in turn order, each with its members and who of them plays next
local teams = {} --- @type { Match_Team }
local teamIndex: number = 1

-- The order wrapped past the last team, so the next turn starts a new round
local roundPending: boolean = false

--[[ Turn ]]

local shotFired: boolean = false
local shotResolved: boolean = false
local random: Random = Random.new()

--[[ World ]]

local matchFolder: Folder
local setPhase: (phase: string) -> ()

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

--- @class Match_Server_Turns
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init(folder: Folder, setPhaseCallback: (phase: string) -> ())
	matchFolder = folder
	setPhase = setPhaseCallback
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Reset

--[[
	Sets up the turn order for a new match: the teams in a random order, each team's members in roster order.
]]
function Module.Reset()
	--[[ Local Variables ]]

	local byTeam = {} --- @type { [number]: Match_Team }
	teams = {}
	teamIndex = 1
	roundPending = false

	--[[ Grouping ]]

	--- @param participant Match_Participant
	for _index: number, participant in ipairs(Roster.GetParticipants()) do
		--- @type Match_Team?
		local team = byTeam[participant.Team]
		if not team then
			team = { Team = participant.Team, Members = {}, Next = 1 }
			byTeam[participant.Team] = team
			table.insert(teams, team)
		end
		table.insert(team.Members, participant.Id)
	end

	--[[ Shuffling ]]

	for index: number = #teams, 2, -1 do
		local swap: number = random:NextInteger(1, index)
		teams[index], teams[swap] = teams[swap], teams[index]
	end

	--[[ Saving ]]

	matchFolder:SetAttribute("Round", 1)
	matchFolder:SetAttribute("SuddenDeath", false)
	matchFolder:SetAttribute("TurnOrder", "")
end

--%%%%%%%%%%%%%%%%%%%% Run Turn

--[[
	Plays the next turn: picks the next snail (team by team), starts a new round when the order wrapped, raises the
	liquid in sudden death, rolls the wind, tells every client who plays after it (`TurnOrder`), hands the snail to
	its player (or its bot), waits for a shot or the timer, takes the snail back, waits for the shot and then the
	arena to settle, and knocks out every snail left at 0 health.
]]
function Module.RunTurn()
	--[[ Round ]]

	if roundPending then
		roundPending = false
		matchFolder:SetAttribute("Round", matchFolder:GetAttribute("Round") + 1)
		--- @param participant Match_Participant
		for _index: number, participant in ipairs(Roster.GetParticipants()) do
			if not participant.Out then
				Stats.AddRound(participant.Id)
			end
		end
	end

	--[[ Data ]]

	local participantId: string? = Module._getNext()
	if not participantId then
		task.wait(1)
		return
	end
	local participant = Roster.GetParticipant(participantId) --- @type Match_Participant
	local model: Model = I.Snails.Get(participantId)

	--[[ Sudden Death ]]

	local round: number = matchFolder:GetAttribute("Round")
	if round >= _settings.SUDDEN_DEATH_ROUND then
		matchFolder:SetAttribute("SuddenDeath", true)
		I.Arena.RaiseLiquid(_settings.SUDDEN_DEATH_RISE)
	end

	--[[ Starting ]]

	shotFired = false
	shotResolved = false
	model:SetAttribute("Active", true)
	matchFolder:SetAttribute("Wind", random:NextInteger(-_settings.WIND_MAX, _settings.WIND_MAX))
	matchFolder:SetAttribute("TurnOrder", table.concat(Module._getUpcoming(), ","))
	matchFolder:SetAttribute("ActiveId", participantId)
	matchFolder:SetAttribute("TurnEndsAt", I.S.Workspace:GetServerTimeNow() + _settings.TURN_SECONDS)
	setPhase("Turn")
	I.Topic.Publish("Match_TurnStarted", participantId)

	if participant.IsBot then
		task.spawn(I.Bots.TakeTurn, participantId)
	else
		I.SnailControl.StartTurn(participantId)
	end

	--[[ Waiting ]]

	-- The turn ends with a shot, the timer, the snail going out, or its player leaving
	local deadline: number = os.clock() + _settings.TURN_SECONDS
	while os.clock() < deadline and not shotFired and model:GetAttribute("Alive") and (participant.IsBot or participant.Connected) do
		task.wait()
	end
	I.SnailControl.EndTurn(participantId)

	if shotFired then
		setPhase("Flight")
		local flightEnd: number = os.clock() + _settings.MAX_FLIGHT
		while not shotResolved and os.clock() < flightEnd do
			task.wait()
		end
	end

	--[[ Settling ]]

	setPhase("Settle")
	Module._settle()
	Module._resolveDeaths()

	--[[ Ending ]]

	if model.Parent then
		model:SetAttribute("Active", nil)
	end
	matchFolder:SetAttribute("ActiveId", "")
	I.Topic.Publish("Match_TurnEnded", participantId)
end

--%%%%%%%%%%%%%%%%%%%% On Shot Fired

--[[
	Marks the active snail's shot as fired, which ends its turn.
]]
function Module.OnShotFired()
	shotFired = true
end

--%%%%%%%%%%%%%%%%%%%% On Shot Resolved

--[[
	Marks the shot in flight as over: every projectile is done.
]]
function Module.OnShotResolved()
	shotResolved = true
end

--%%%%%%%%%%%%%%%%%%%% Settle

--[[
	Waits until the snails, the falling debris and every projectile have been at rest for SETTLE_HOLD seconds, or
	MAX_SETTLE seconds have passed.
]]
function Module._settle()
	--[[ Local Variables ]]

	local deadline: number = os.clock() + _settings.MAX_SETTLE
	local calmSince: number? = nil

	--[[ Waiting ]]

	while os.clock() < deadline do
		if I.Snails.IsSettled() and I.Arena.IsSettled() and I.Combat.IsIdle() then
			calmSince = calmSince or os.clock()
			if os.clock() - calmSince >= _settings.SETTLE_HOLD then
				return
			end
		else
			calmSince = nil
		end
		task.wait()
	end
end

--%%%%%%%%%%%%%%%%%%%% Resolve Deaths

--[[
	Knocks out every snail still in play at 0 health; the last snail that hurt it gets the knockout.
]]
function Module._resolveDeaths()
	--[[ Resolving ]]

	for _index: number, model: Model in ipairs(I.Snails.GetAlive()) do
		if model:GetAttribute("Health") <= 0 then
			I.Snails.Kill(model.Name, "Damage")
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Next

--[[
	Returns who plays next, moving the order on: the next team in order that still has a snail who can play, and the
	next such snail in that team. Nil when nobody can play.
]]
--- @return string?
function Module._getNext()
	--[[ Searching ]]

	local participantId: string?
	local wrapped: boolean
	participantId, teamIndex, wrapped = Module._findNext(teams, teamIndex)
	if wrapped then
		roundPending = true
	end

	--[[ Returning ]]

	return participantId
end

--%%%%%%%%%%%%%%%%%%%% Get Upcoming

--[[
	Returns every snail that can play, in the order its next turn comes after the one playing now, walking a copy of
	the turn order so the real one doesn't move.
]]
--- @return { string }
function Module._getUpcoming()
	--[[ Local Variables ]]

	local order = {} --- @type { Match_Team }
	local index: number = teamIndex
	local upcoming = {} --- @type { string }
	local playable: number = 0
	local steps: number = 0

	--- @param team Match_Team
	for _index: number, team in ipairs(teams) do
		table.insert(order, { Team = team.Team, Members = team.Members, Next = team.Next })
		for _member: number, id: string in ipairs(team.Members) do
			if Module._canPlay(id) then
				playable += 1
			end
		end
		steps += #team.Members * #teams
	end

	--[[ Walking ]]

	-- A snail already listed comes up again before a bigger team's last members, so walk until each one came up
	for _step: number = 1, steps do
		if #upcoming >= playable then
			break
		end
		local participantId: string?
		participantId, index = Module._findNext(order, index)
		if not participantId then
			break
		end
		if not table.find(upcoming, participantId) then
			table.insert(upcoming, participantId)
		end
	end

	--[[ Returning ]]

	return upcoming
end

--%%%%%%%%%%%%%%%%%%%% Can Play

--[[
	Returns whether a participant can take a turn: still in, with a snail in play, and here (bots always are).
]]
--- @return boolean
function Module._canPlay(participantId: string)
	--[[ Data ]]

	local participant = Roster.GetParticipant(participantId) --- @type Match_Participant?
	local model: Model? = I.Snails.Get(participantId)

	--[[ Returning ]]

	return participant ~= nil and not participant.Out and model ~= nil and model:GetAttribute("Alive") == true and (participant.IsBot or participant.Connected)
end

--%%%%%%%%%%%%%%%%%%%% Find Next

--[[
	Walks a turn order from a team's index to the next snail who can play, moving each team's `Next` on as it goes.
	Returns that snail (nil when nobody can play), the index to start from next time, and whether it wrapped past the
	last team.
]]
--- @param order { Match_Team }
--- @return string?
--- @return number
--- @return boolean
function Module._findNext(order, index: number)
	--[[ Local Variables ]]

	local wrapped: boolean = false

	--[[ Searching ]]

	for _try: number = 1, #order do
		--- @type Match_Team
		local team = order[index]
		index += 1
		if index > #order then
			index = 1
			wrapped = true
		end

		for _member: number = 1, #team.Members do
			local id: string = team.Members[team.Next]
			team.Next = team.Next % #team.Members + 1
			if Module._canPlay(id) then
				return id, index, wrapped
			end
		end
	end

	--[[ Returning ]]

	return nil, index, wrapped
end

return Module
