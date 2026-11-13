--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
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

-- The snails that played since the wind last changed; it changes once every snail still in play has
local windPlayed = {} --- @type { [string]: boolean }

-- When the turn playing now runs out (os.clock), and the length an admin set for every turn (nil is TURN_SECONDS)
local turnDeadline: number = 0
local turnSeconds: number? = nil

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
	Sets up the turn order for a new match: the teams in a random order, each team's members in roster order. The
	tutorial keeps the roster's order, so the player plays first.
]]
function Module.Reset()
	--[[ Local Variables ]]

	local byTeam = {} --- @type { [number]: Match_Team }
	teams = {}
	teamIndex = 1
	roundPending = false
	windPlayed = {}

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

	local shuffles: number = if Roster.GetMetadata().Kind == "Tutorial" then 1 else #teams
	for index: number = shuffles, 2, -1 do
		local swap: number = random:NextInteger(1, index)
		teams[index], teams[swap] = teams[swap], teams[index]
	end

	--[[ Saving ]]

	matchFolder:SetAttribute("Round", 1)
	matchFolder:SetAttribute("Wind", nil)
	matchFolder:SetAttribute("SuddenDeath", false)
	matchFolder:SetAttribute("TurnOrder", "")
end

--%%%%%%%%%%%%%%%%%%%% Run Turn

--[[
	Plays the next turn: picks the next snail (team by team), starts a new round when the order wrapped, raises the
	liquid in sudden death, rolls the wind once every snail played on the last one, tells every client who plays after it (`TurnOrder`), hands the snail to
	its player (or its bot, or a bot standing in for a player who dropped: `Autopilot`), waits for a shot or the timer,
	takes the snail back, waits for the shot and then the arena to settle, and knocks out every snail left at 0 health.
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
	Module._rollWind(participantId)
	matchFolder:SetAttribute("TurnOrder", table.concat(Module._getUpcoming(), ","))
	-- A dropped player's snail plays on under a bot until they come back
	local autopilot: boolean = participant.IsBot or not participant.Connected
	matchFolder:SetAttribute("Autopilot", autopilot and not participant.IsBot)
	matchFolder:SetAttribute("ActiveId", participantId)
	Module._setDeadline(turnSeconds or _settings.TURN_SECONDS)
	setPhase("Turn")
	I.Topic.Publish("Match_TurnStarted", participantId)

	if autopilot then
		task.spawn(I.Bots.TakeTurn, participantId)
	else
		I.SnailControl.StartTurn(participantId)
	end

	--[[ Waiting ]]

	-- As in Worms, getting hurt ends the turn (a fall, a mine, a barrel), until the shot is away
	local hurt: boolean = false
	local health: number = model:GetAttribute("Health")
	local hurtConnection: RBXScriptConnection = model:GetAttributeChangedSignal("Health"):Connect(function()
		local now: number = model:GetAttribute("Health")
		hurt = hurt or now < health
		health = now
	end)

	-- The turn ends with a shot, the timer (or an admin skipping it), the snail getting hurt, or it going out
	while os.clock() < turnDeadline and not shotFired and not hurt and model:GetAttribute("Alive") do
		-- A player who drops during their turn hands it to a bot, with at least TAKEOVER_SECONDS left to play it
		if not autopilot and not participant.Connected then
			autopilot = true
			matchFolder:SetAttribute("Autopilot", true)
			I.SnailControl.EndTurn(participantId)
			Module._setDeadline(math.max(turnDeadline - os.clock(), _settings.TAKEOVER_SECONDS))
			task.spawn(I.Bots.TakeTurn, participantId)
		end
		task.wait()
	end
	hurtConnection:Disconnect()

	-- Firing took the snail back already, or left it running from its Dynamite until the shot is over
	if shotFired then
		setPhase("Flight")
		local flightEnd: number = os.clock() + _settings.MAX_FLIGHT
		while not shotResolved and os.clock() < flightEnd do
			task.wait()
		end
	end
	I.SnailControl.EndTurn(participantId)

	--[[ Settling ]]

	setPhase("Settle")
	local soaked: boolean = Module._hurtUnderwater()
	Module._settle(shotFired or hurt or soaked)

	-- A snail knocked out here turns into its ghost before the next turn takes the camera away
	if Module._resolveDeaths() > 0 then
		task.wait(I.Settings["Snails"].GHOST_TIME)
	end

	--[[ Ending ]]

	if model.Parent then
		model:SetAttribute("Active", nil)
	end
	matchFolder:SetAttribute("ActiveId", "")
	matchFolder:SetAttribute("Autopilot", false)
	I.Topic.Publish("Match_TurnEnded", participantId)
end

--%%%%%%%%%%%%%%%%%%%% Roll Wind

--[[
	Rolls a new wind for the first turn, and again once every snail still in play has played on the current one (the
	testers, 2026-11-13: the wind stays for a whole round), then counts the snail starting its turn.
]]
function Module._rollWind(participantId: string)
	--[[ Checks ]]

	-- Check if every snail still in play has played on this wind
	local everyonePlayed: boolean = true
	--- @param participant Match_Participant
	for _index: number, participant in ipairs(Roster.GetParticipants()) do
		if not participant.Out and not windPlayed[participant.Id] then
			everyonePlayed = false
			break
		end
	end

	--[[ Rolling ]]

	if everyonePlayed or matchFolder:GetAttribute("Wind") == nil then
		windPlayed = {}
		matchFolder:SetAttribute("Wind", random:NextInteger(-_settings.WIND_MAX, _settings.WIND_MAX))
	end
	windPlayed[participantId] = true
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

--%%%%%%%%%%%%%%%%%%%% Skip

--[[
	Ends the turn playing now, as if its timer ran out. A shot already in flight still lands first.
]]
function Module.Skip()
	turnDeadline = 0
end

--%%%%%%%%%%%%%%%%%%%% Set Turn Seconds

--[[
	Sets how long every turn lasts from now on, the one playing now too, until the server closes; nil goes back to
	TURN_SECONDS. For testing.
]]
function Module.SetTurnSeconds(seconds: number?)
	--[[ Saving ]]

	turnSeconds = seconds

	--[[ Applying ]]

	if matchFolder:GetAttribute("Phase") == "Turn" then
		Module._setDeadline(seconds or _settings.TURN_SECONDS)
	end
end

--%%%%%%%%%%%%%%%%%%%% Set Deadline

--[[
	Makes the turn playing now run out in a number of seconds, on the server and on every player's timer.
]]
function Module._setDeadline(seconds: number)
	--[[ Saving ]]

	turnDeadline = os.clock() + seconds
	matchFolder:SetAttribute("TurnEndsAt", I.S.Workspace:GetServerTimeNow() + seconds)
end

--%%%%%%%%%%%%%%%%%%%% Settle

--[[
	Waits until the arena is calm (every snail at rest on the ground or in a liquid, no debris falling, no projectile,
	no health changing) for SETTLE_HOLD seconds, or HIT_HOLD after a shot or a hit, so everyone sees what happened.
	Something that stays unsettled while nothing happens (a snail stuck off the ground) moves on after STALL_SECONDS
	without any movement or damage, and MAX_SETTLE moves on whatever happens.
]]
function Module._settle(hit: boolean)
	--[[ Local Variables ]]

	local started: number = os.clock()
	local calmSince: number? = nil
	local activeAt: number = started
	local healths = {} --- @type { [Model]: number }
	for _index: number, model: Model in ipairs(I.Snails.GetAlive()) do
		healths[model] = model:GetAttribute("Health")
	end

	--[[ Waiting ]]

	while os.clock() - started < _settings.MAX_SETTLE do
		local now: number = os.clock()

		-- A snail's health changing (a blow, a fall, a mine, fire) is something happening, and holds the turn for HIT_HOLD
		local changed: boolean = false
		for _index: number, model: Model in ipairs(I.Snails.GetAlive()) do
			local health: number = model:GetAttribute("Health")
			changed = changed or (healths[model] ~= nil and health ~= healths[model])
			healths[model] = health
		end
		hit = hit or changed

		-- Moving is something happening; a snail off the ground that doesn't move only keeps the turn from being calm
		local moving: boolean = changed or not I.Snails.IsSettled() or not I.Arena.IsSettled() or not I.Combat.IsIdle()
		if moving then
			activeAt = now
		end
		if not moving and Module._areLanded() then
			calmSince = calmSince or now
		else
			calmSince = nil
		end

		-- Calm long enough, or nothing has happened for STALL_SECONDS
		if calmSince and now - calmSince >= (if hit then _settings.HIT_HOLD else _settings.SETTLE_HOLD) then
			return
		end
		if now - activeAt >= _settings.STALL_SECONDS then
			return
		end
		task.wait()
	end
end

--%%%%%%%%%%%%%%%%%%%% Hurt Underwater

--[[
	At the end of every turn, hurts each snail in play whose head is under a liquid that doesn't knock it out (a pond,
	like Desert's oasis) by UNDERWATER_DAMAGE, as Worms Armageddon's poison: it never takes a snail below 1 health. A
	snail with only its body under is fine. Returns whether it hurt any.
]]
--- @return boolean
function Module._hurtUnderwater()
	--[[ Local Variables ]]

	local hurtAny: boolean = false

	--[[ Hurting ]]

	for _index: number, model: Model in ipairs(I.Snails.GetAlive()) do
		local health: number = model:GetAttribute("Health")
		local head: Vector3 = model.PrimaryPart.Position + Vector3.yAxis * _settings.UNDERWATER_HEAD_HEIGHT
		if health > 1 and I.Arena.GetLiquid(head) then
			I.Snails.Damage(model.Name, math.min(_settings.UNDERWATER_DAMAGE, health - 1))
			hurtAny = true
		end
	end

	--[[ Returning ]]

	return hurtAny
end

--%%%%%%%%%%%%%%%%%%%% Resolve Deaths

--[[
	Knocks out every snail still in play at 0 health; the last snail that hurt it gets the knockout. Returns how many.
]]
--- @return number
function Module._resolveDeaths()
	--[[ Local Variables ]]

	local knocked: number = 0

	--[[ Resolving ]]

	for _index: number, model: Model in ipairs(I.Snails.GetAlive()) do
		if model:GetAttribute("Health") <= 0 then
			I.Snails.Kill(model.Name, "Damage")
			knocked += 1
		end
	end

	--[[ Returning ]]

	return knocked
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

--%%%%%%%%%%%%%%%%%%%% Are Landed

--[[
	Returns whether every snail in play stands on something or sits in a liquid, none in the air.
]]
--- @return boolean
function Module._areLanded()
	--[[ Checking ]]

	for _index: number, model: Model in ipairs(I.Snails.GetAlive()) do
		if not I.Snails.IsGrounded(model.Name) and not I.Arena.GetLiquid(model.PrimaryPart.Position) then
			return false
		end
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Can Play

--[[
	Returns whether a participant can take a turn: still in, with a snail in play (a dropped player's plays under a bot).
]]
--- @return boolean
function Module._canPlay(participantId: string)
	--[[ Data ]]

	local participant = Roster.GetParticipant(participantId) --- @type Match_Participant?
	local model: Model? = I.Snails.Get(participantId)

	--[[ Returning ]]

	return participant ~= nil and not participant.Out and model ~= nil and model:GetAttribute("Alive") == true
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
