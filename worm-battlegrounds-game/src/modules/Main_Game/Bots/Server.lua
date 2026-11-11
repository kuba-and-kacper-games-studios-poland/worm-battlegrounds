--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Bots"

--- @type Bots_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("ServerSettings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")
local _data = script:FindFirstAncestor(_localName):FindFirstChild("ServerData")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local Brains = require(_data:FindFirstChild("Brains")) --- @type { [string]: Bots_Genome }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Aim = require(_scripts:FindFirstChild("Server"):FindFirstChild("Aim")) --- @type Bots_Server_Aim
local Brain = require(_scripts:FindFirstChild("Server"):FindFirstChild("Brain")) --- @type Bots_Server_Brain
local Gym = require(_scripts:FindFirstChild("Server"):FindFirstChild("Gym")) --- @type Bots_Server_Gym
local Move = require(_scripts:FindFirstChild("Server"):FindFirstChild("Move")) --- @type Bots_Server_Move
local Predict = require(_scripts:FindFirstChild("Server"):FindFirstChild("Predict")) --- @type Bots_Server_Predict

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local random: Random = Random.new()

-- Names already given out this match
local usedNames = {} --- @type { [string]: boolean }

-- Each bot's run of shots at one target from about one spot, which steadies its hand (Aim.GetShaken)
local rangings = {} --- @type { [string]: Bots_Ranging }

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
	------ INITIALIZATION ------
	----------------------------

	Aim.Init()
	Brain.Init()
	Move.Init()
	Predict.Init()
	Gym.Init()

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Bots = {

		--[[ Control ]]

		CreateParticipant = Module.CreateParticipant,
		TakeTurn = Module.TakeTurn,

		--[[ Methods ]]

		GetStart = Module.GetStart,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	-------- CONNECTIONS -------
	----------------------------

	Gym.Start()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Create Participant

--[[
	**SERVER** |
	Returns a new bot participant for a match: an unused name, its difficulty's loadout and the default skin. The
	match gives it its team and colour. The first bot of a match (number 1) starts the names and the bots' memory over.
]]
--- @return Match_Participant
function Module.CreateParticipant(difficulty: string, number: number)
	--[[ Local Variables ]]

	if number == 1 then
		usedNames = {}
		rangings = {}
	end
	local name: string = Module._getName()

	--[[ Returning ]]

	return {
		Id = `B_{number}`,
		UserId = 0,
		DisplayName = name,
		Team = 1,
		Color = Color3.new(),
		IsBot = true,
		Difficulty = difficulty,
		Loadout = table.clone(_settings.LOADOUTS[difficulty] or _settings.LOADOUTS.Easy),
		DamageTaken = _settings.DAMAGE_TAKEN[difficulty] or 1,
		Connected = true,
		Out = false,
	}
end

--%%%%%%%%%%%%%%%%%%%% Take Turn

--[[
	**SERVER** |
	Plays a bot's turn as a player would (or a dropped player's, at TAKEOVER_DIFFICULTY). While it thinks (THINK_TIME) its brain plans the turn with its difficulty's
	trained genome (ServerData/Brains) and skill (SKILLS): it heals when hurt, walks or flies its jetpack to the spot it
	picked, plans again from where it ended up if the walk fell short, and fires with its hand's error, which narrows
	as it keeps shooting at the same target. Gives up quietly when the turn ends meanwhile.
]]
function Module.TakeTurn(participantId: string)
	--[[ Data ]]

	local participant = I.Match.GetParticipant(participantId) --- @type Match_Participant?
	local model: Model? = I.Snails.Get(participantId)

	--[[ Local Variables ]]

	local thinkUntil: number = os.clock() + random:NextNumber(_settings.THINK_TIME[1], _settings.THINK_TIME[2])

	--[[ Checks ]]

	-- Check if it's still this bot's turn
	if not participant or not model or not Module._isTurn(participantId) then
		return
	end

	-- The tutorial bot only shoots beside the player
	if participant.Difficulty == "Tutorial" then
		task.wait(thinkUntil - os.clock())
		Module._playTutorial(participantId, model)
		return
	end

	--[[ Healing ]]

	local difficulty: string = participant.Difficulty or if participant.IsBot then "Easy" else _settings.TAKEOVER_DIFFICULTY
	local genome = Brains[difficulty] or Brains.Hard --- @type Bots_Genome
	local skill = _settings.SKILLS[difficulty] or _settings.SKILLS.Easy --- @type Bots_Skill
	model:SetAttribute("Stamina", I.Settings["SnailControl"].STAMINA_STUDS)
	local heal: string? = Brain.GetHeal(Module._getView(participantId, model), genome)
	if heal and I.Combat.UseUtility(participantId, heal) then
		task.wait(_settings.ACTION_PAUSE)
	end

	--[[ Planning ]]

	local plan = Brain.GetPlan(Module._getView(participantId, model), genome, skill) --- @type Bots_Plan?
	task.wait(math.max(thinkUntil - os.clock(), 0))
	if not Module._isTurn(participantId) or not model:GetAttribute("Alive") then
		return
	end

	-- No shot reaches anyone: it fires anyway, as a player would
	if not plan then
		Module._fireAnyway(participantId, model)
		return
	end

	--[[ Moving ]]

	local row = I.G_Arsenal.Get(plan.ItemId) --- @type Arsenal_WeaponData
	local flying: boolean = false
	if plan.Spot.Walk > 0 then
		flying = Module._walk(participantId, model, plan, row.Retreat ~= nil)
	end

	-- Check if the turn lasted the walk
	if not Module._isTurn(participantId) or not model:GetAttribute("Alive") then
		return
	end

	-- A walk that ended off its spot plans the shot again from where it stands
	if (model.PrimaryPart.Position - plan.Spot.Position).Magnitude > _settings.ARRIVE_DISTANCE + _settings.CLOSE_SLACK then
		plan = Brain.GetPlan(Module._getView(participantId, model), genome, skill, true)
		if not Module._isTurn(participantId) then
			return
		end
		if not plan then
			Module._fireAnyway(participantId, model)
			return
		end
		row = I.G_Arsenal.Get(plan.ItemId)
	end

	--[[ Firing ]]

	local angle: number = plan.Angle
	local power: number = plan.Power
	if row.Aim ~= "Melee" and row.Aim ~= "Feet" then
		angle, power = Aim.GetShaken(plan.Angle, plan.Power, skill, Module._countShots(participantId, plan))
	end
	if not Module._showAim(participantId, plan.ItemId, angle, if row.Aim == "Feet" then 0 else power) then
		return
	end
	if not I.Combat.Fire(participantId, plan.ItemId, angle, power, plan.Target) then
		I.Combat.Fire(participantId, "Bazooka", angle, power)
		return
	end

	--[[ Running ]]

	-- From placed Dynamite: toward the side with more ground, up into the air when it has fuel
	if row.Retreat then
		local position: Vector3 = model.PrimaryPart.Position
		local reach: number = I.Settings["SnailControl"].WALK_SPEED * row.Retreat
		local away: number = if Move.GetRunway(position, -1, reach) > Move.GetRunway(position, 1, reach) then -1 else 1
		Move.WalkTo(model, position.X + away * reach, row.Retreat, if flying then position.Y + _settings.ESCAPE_HEIGHT else nil, function()
			return true
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%% Walk

--[[
	Walks a bot to its plan's spot, putting its jetpack on first when the spot needs it (higher than a jump, or over a
	gap) or when it's about to place Dynamite and run, then waits until it stands on the ground. Returns whether it
	wears a jetpack.
]]
--- @param plan Bots_Plan
--- @return boolean
function Module._walk(participantId: string, model: Model, plan, placing: boolean)
	--[[ Local Variables ]]

	local origin: Vector3 = model.PrimaryPart.Position
	local jump: number = I.Settings["SnailControl"].JUMP_SPEED ^ 2 / (2 * I.S.Workspace.Gravity)
	local climbTo: number? = if plan.Spot.Position.Y - origin.Y > jump then plan.Spot.Position.Y else nil
	local keepGoing: () -> boolean = function()
		return Module._isTurn(participantId)
	end

	--[[ Flying ]]

	local flying: boolean = (plan.Spot.Fly or climbTo ~= nil or placing) and I.Combat.CanUse(participantId, "Jetpack") and I.Combat.UseUtility(participantId, "Jetpack")

	--[[ Walking ]]

	Move.WalkTo(model, plan.Spot.Position.X, _settings.MOVE_SECONDS, climbTo, keepGoing)

	--[[ Landing ]]

	-- Shoot from the ground, never in mid-air
	local deadline: number = os.clock() + _settings.LAND_SECONDS
	task.wait(_settings.ACTION_PAUSE)
	while not I.Snails.IsGrounded(model.Name) and os.clock() < deadline and keepGoing() do
		task.wait(0.1)
	end

	--[[ Returning ]]

	return flying
end

--%%%%%%%%%%%%%%%%%%%% Play Tutorial

--[[
	The tutorial bot's turn: it stays put and fires the Bazooka at the ground beside the nearest enemy, never at it.
]]
function Module._playTutorial(participantId: string, model: Model)
	--[[ Local Variables ]]

	local origin: Vector3 = model.PrimaryPart.Position
	local target: Model? = nil
	for _index: number, other: Model in ipairs(I.Snails.GetAlive()) do
		if other ~= model and (not target or (other.PrimaryPart.Position - origin).Magnitude < (target.PrimaryPart.Position - origin).Magnitude) then
			target = other
		end
	end

	--[[ Checks ]]

	-- Check if anyone is left to aim near
	if not target then
		return
	end

	--[[ Firing ]]

	local aimAt: Vector3 = target.PrimaryPart.Position + Vector3.new(random:NextNumber(4, 8) * (if random:NextNumber() < 0.5 then -1 else 1), -2, 0)
	local wind: number = I.G_Combat.GetWindAcceleration("Bazooka", I.Match.GetWind())
	local arc: Vector2 = I.Combat.GetArcs(origin, aimAt, "Bazooka", wind, _settings.POWER_STEPS)[1] or Vector2.new(math.rad(45), 0.6)
	if Module._showAim(participantId, "Bazooka", arc.X, arc.Y) then
		I.Combat.Fire(participantId, "Bazooka", arc.X, arc.Y)
	end
end

--%%%%%%%%%%%%%%%%%%%% Fire Anyway

--[[
	A turn the brain found no shot for (everyone out of reach or out of sight): the bot still fires its Bazooka at the
	nearest snail not on its team, on the arc that lands nearest it, or lobbed toward it at full power when no arc
	reaches, so a bot never just lets its turn run out.
]]
function Module._fireAnyway(participantId: string, model: Model)
	--[[ Local Variables ]]

	local origin: Vector3 = model.PrimaryPart.Position
	local target: Model? = nil
	for _index: number, other: Model in ipairs(I.Snails.GetAlive()) do
		local enemy: boolean = other ~= model and other:GetAttribute("Team") ~= model:GetAttribute("Team")
		if enemy and (not target or (other.PrimaryPart.Position - origin).Magnitude < (target.PrimaryPart.Position - origin).Magnitude) then
			target = other
		end
	end

	--[[ Checks ]]

	-- Check if anyone is left to shoot at
	if not target then
		return
	end

	--[[ Firing ]]

	local aimAt: Vector3 = target.PrimaryPart.Position
	local wind: number = I.G_Combat.GetWindAcceleration("Bazooka", I.Match.GetWind())
	local toward: number = if aimAt.X < origin.X then math.rad(135) else math.rad(45)
	local arc: Vector2 = I.Combat.GetArcs(origin, aimAt, "Bazooka", wind, _settings.POWER_STEPS)[1] or Vector2.new(toward, 1)
	if Module._showAim(participantId, "Bazooka", arc.X, arc.Y) then
		I.Combat.Fire(participantId, "Bazooka", arc.X, arc.Y)
	end
end

--%%%%%%%%%%%%%%%%%%%% Show Aim

--[[
	Holds the weapon, swings the bot's crosshair from level to its shot over AIM_TIME, then charges its power from none
	to the shot's over the time a player's held button would take (Combat's CHARGE_SECONDS), shown to every player like
	a player's aim. Guns and melee weapons fire without charging. Returns whether it's still the bot's turn at the end.
]]
--- @return boolean
function Module._showAim(participantId: string, itemId: string, angle: number, power: number)
	--[[ Local Variables ]]

	local startAngle: number = if math.cos(angle) < 0 then math.pi else 0
	local aim: string = I.G_Arsenal.Get(itemId).Aim
	local chargeTime: number = if aim == "Straight" or aim == "Melee" then 0 else power * I.Settings["Combat"].CHARGE_SECONDS
	local started: number = os.clock()

	--[[ Aiming ]]

	while true do
		-- The turn may have run out while the bot solved or aimed
		if not Module._isTurn(participantId) then
			return false
		end

		local elapsed: number = os.clock() - started
		local turned: number = math.min(1, elapsed / _settings.AIM_TIME)
		local eased: number = 1 - (1 - turned) ^ 3
		local charged: number = if chargeTime > 0 then math.clamp((elapsed - _settings.AIM_TIME) / chargeTime, 0, 1) else 1
		I.Combat.ShowAim(participantId, itemId, startAngle + (angle - startAngle) * eased, if chargeTime > 0 then power * charged else 0)
		if turned >= 1 and charged >= 1 then
			break
		end
		task.wait(_settings.AIM_STEP)
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Start

--[[
	**SERVER** |
	Returns the land spot a bot parachutes onto, picked by its difficulty's trained genome from the match's spots, apart
	from those taken already.
]]
--- @param spots { Vector3 }
--- @param taken { Vector3 }
--- @return Vector3
function Module.GetStart(difficulty: string, spots, taken)
	return Brain.GetStart(spots, taken, Brains[difficulty] or Brains.Hard)
end

--%%%%%%%%%%%%%%%%%%%% Is Turn

--[[
	Returns whether a bot may still act: it's its turn, before its shot.
]]
--- @return boolean
function Module._isTurn(participantId: string)
	return I.Match.GetActive() == participantId and I.Match.GetPhase() == "Turn"
end

--%%%%%%%%%%%%%%%%%%%% Get View

--[[
	Returns what a bot knows at this moment, for its brain: its snail and every other one in play, the wind, the
	round, its stamina, the items it may use now with their uses left, and who hurt it last.
]]
--- @return Bots_View
function Module._getView(participantId: string, model: Model)
	--[[ Data ]]

	local participant = I.Match.GetParticipant(participantId) --- @type Match_Participant

	--[[ Local Variables ]]

	local snails = {} --- @type { Bots_Snail }
	local uses = {} --- @type { [string]: number }
	for _index: number, other: Model in ipairs(I.Snails.GetAlive()) do
		if other ~= model then
			table.insert(snails, Module._getSnail(other))
		end
	end
	for _index: number, itemId: string in ipairs({ "Bazooka", table.unpack(participant.Loadout) }) do
		if I.Combat.CanUse(participantId, itemId) then
			uses[itemId] = I.Combat.GetUses(participantId, itemId)
		end
	end

	--[[ Returning ]]

	--- @type Bots_View
	local view = {
		Self = Module._getSnail(model),
		Snails = snails,
		Wind = I.Match.GetWind(),
		Round = I.Dirs.UmeWorkspace:FindFirstChild("Match"):GetAttribute("Round") or 1,
		Stamina = model:GetAttribute("Stamina") or 0,
		Uses = uses,
		LastAttacker = model:GetAttribute("LastAttacker"),
	}
	return view
end

--%%%%%%%%%%%%%%%%%%%% Get Snail

--[[
	Returns a snail in play as a bot's brain sees it.
]]
--- @return Bots_Snail
function Module._getSnail(model: Model)
	--- @type Bots_Snail
	local snail = {
		Id = model.Name,
		Model = model,
		Team = model:GetAttribute("Team"),
		Position = model.PrimaryPart.Position,
		Health = model:GetAttribute("Health"),
	}
	return snail
end

--%%%%%%%%%%%%%%%%%%%% Count Shots

--[[
	Returns how many shots in a row a bot has fired at its plan's target from about the plan's spot, and counts this
	one: a new target or a spot more than MOVE_STEP studs away starts over.
]]
--- @param plan Bots_Plan
--- @return number
function Module._countShots(participantId: string, plan)
	--[[ Local Variables ]]

	local ranging = rangings[participantId] --- @type Bots_Ranging?
	local same: boolean = ranging ~= nil and ranging.TargetId == plan.TargetId and (ranging.From - plan.Spot.Position).Magnitude <= _settings.MOVE_STEP
	local shots: number = if same and ranging then ranging.Shots else 0

	--[[ Saving ]]

	rangings[participantId] = { TargetId = plan.TargetId, From = plan.Spot.Position, Shots = shots + 1 }

	--[[ Returning ]]

	return shots
end

--%%%%%%%%%%%%%%%%%%%% Get Name

--[[
	Returns a bot name not used yet this match (with a number once they run out).
]]
--- @return string
function Module._getName()
	--[[ Local Variables ]]

	local free = {} --- @type { string }
	for _index: number, name: string in ipairs(_settings.BOT_NAMES) do
		if not usedNames[name] then
			table.insert(free, name)
		end
	end

	--[[ Returning ]]

	local name: string = if #free > 0 then free[random:NextInteger(1, #free)] else `Bot {random:NextInteger(10, 99)}`
	usedNames[name] = true
	return name
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
