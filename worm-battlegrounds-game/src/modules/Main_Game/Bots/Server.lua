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

-- The health of the players a bot's shot in flight may hurt, by the bot, for its taunt once it lands
local before = {} --- @type { [string]: { [Model]: number } }

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
	I.Topic.Subscribe("Combat_ShotFired", Module._onShotFired)
	I.Topic.Subscribe("Combat_ShotResolved", Module._onShotResolved)
	I.Topic.Subscribe("Snails_Died", Module._onDied)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Create Participant

--[[
	**SERVER** |
	Returns a new bot participant for a match: an unused name, its difficulty's loadout with the potion it rolled
	(POTIONS: maybe none), and the default skin. The match gives it its team and colour. The first bot of a match
	(number 1) starts the names and the bots' memory over.
]]
--- @return Match_Participant
function Module.CreateParticipant(difficulty: string, number: number)
	--[[ Local Variables ]]

	if number == 1 then
		usedNames = {}
		rangings = {}
		before = {}
	end
	local name: string = Module._getName()
	local loadout = table.clone(_settings.LOADOUTS[difficulty] or _settings.LOADOUTS.Easy) --- @type { string }
	local potion: string = _settings.POTIONS[random:NextInteger(1, #_settings.POTIONS)]
	if potion ~= "" and difficulty ~= "Tutorial" then
		table.insert(loadout, potion)
	end

	--[[ Returning ]]

	return {
		Id = `B_{number}`,
		UserId = 0,
		DisplayName = name,
		Team = 1,
		Color = Color3.new(),
		IsBot = true,
		Difficulty = difficulty,
		Loadout = loadout,
		MaxHealth = _settings.HEALTH[difficulty],
		Connected = true,
		Out = false,
	}
end

--%%%%%%%%%%%%%%%%%%%% Take Turn

--[[
	**SERVER** |
	Plays a bot's turn as a player would (or a dropped player's, at TAKEOVER_DIFFICULTY). While it thinks (THINK_TIME) its brain plans the turn with its difficulty's
	trained genome (ServerData/Brains) and skill (SKILLS): it heals when hurt, drinks a potion when its spot needs one,
	walks or flies its jetpack to the spot it picked, plans again from where it ended up if the walk fell short, and
	fires with its hand's error, which narrows as it keeps shooting at the same target. Gives up quietly when the turn
	ends meanwhile.
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

	-- The tutorial bot doesn't know how to shoot
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

	-- A spot past its walk or up a ledge its jump can't reach: the potion that gets it there first
	if plan.Spot.Potion and I.Combat.UseUtility(participantId, plan.Spot.Potion) then
		task.wait(_settings.ACTION_PAUSE)
	end
	if plan.Spot.Walk > 0 or plan.Spot.Air then
		flying = Module._walk(participantId, model, plan, row.Retreat ~= nil)
	end

	-- Check if the turn lasted the walk
	if not Module._isTurn(participantId) or not model:GetAttribute("Alive") then
		return
	end

	-- A walk that ended off its spot (along the plane, for a spot in the air) plans the shot again from the ground there
	local reached: Vector3 = model.PrimaryPart.Position
	local off: number = if plan.Spot.Air then math.abs(reached.X - plan.Spot.Position.X) else (reached - plan.Spot.Position).Magnitude
	if off > _settings.ARRIVE_DISTANCE + _settings.CLOSE_SLACK then
		Module._land(participantId, model)
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
	-- In the air it hovers at its spot on its jetpack while it aims, and fires from there
	local aiming: boolean = true
	if plan.Spot.Air then
		task.spawn(Move.Hover, model, plan.Spot.Position.Y, function(): boolean
			return aiming and Module._isTurn(participantId)
		end)
	end
	local ready: boolean = Module._showAim(participantId, plan.ItemId, angle, if row.Aim == "Feet" then 0 else power)
	local fired: boolean = ready and I.Combat.Fire(participantId, plan.ItemId, angle, power, plan.Target)
	aiming = false
	if not ready then
		return
	end
	if not fired then
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
	Walks a bot to its plan's spot, putting its jetpack on first when the spot needs it (its route is a flight: straight
	up to the spot's cruise height, along, then down) or when it's about to place Dynamite and run, then waits until it
	stands on the ground, unless the spot is in the air. Returns whether it wears a jetpack.
]]
--- @param plan Bots_Plan
--- @return boolean
function Module._walk(participantId: string, model: Model, plan, placing: boolean)
	--[[ Local Variables ]]

	local keepGoing: () -> boolean = function()
		return Module._isTurn(participantId)
	end

	--[[ Flying ]]

	local flying: boolean = (plan.Spot.Fly or placing) and I.Combat.CanUse(participantId, "Jetpack") and I.Combat.UseUtility(participantId, "Jetpack")

	--[[ Walking ]]

	Move.WalkTo(model, plan.Spot.Position.X, _settings.MOVE_SECONDS, if flying and plan.Spot.Fly then plan.Spot.Cruise else nil, keepGoing, true)

	--[[ Landing ]]

	-- Shoot from the ground, unless it means to shoot from the air
	if not (flying and plan.Spot.Air) then
		Module._land(participantId, model)
	end

	--[[ Returning ]]

	return flying
end

--%%%%%%%%%%%%%%%%%%%% Land

--[[
	Waits a moment, then until a bot's snail stands on the ground (LAND_SECONDS at most, and only while it's its turn).
]]
function Module._land(participantId: string, model: Model)
	--[[ Local Variables ]]

	local deadline: number = os.clock() + _settings.LAND_SECONDS

	--[[ Waiting ]]

	task.wait(_settings.ACTION_PAUSE)
	while not I.Snails.IsGrounded(model.Name) and os.clock() < deadline and Module._isTurn(participantId) do
		task.wait(0.1)
	end
end

--%%%%%%%%%%%%%%%%%%%% Play Tutorial

--[[
	The tutorial bot's turn: it doesn't know how to shoot, so it raises the Bazooka at the sky, charges a little, gives
	up without firing and passes the turn back.
]]
function Module._playTutorial(participantId: string, _model: Model)
	--[[ Fumbling ]]

	local angle: number = math.rad(random:NextNumber(70, 110))
	if not Module._showAim(participantId, "Bazooka", angle, _settings.TUTORIAL_FUMBLE_POWER) then
		return
	end

	--[[ Passing ]]

	task.wait(_settings.ACTION_PAUSE)
	if Module._isTurn(participantId) then
		I.Match.SkipTurn()
	end
end

--%%%%%%%%%%%%%%%%%%%% Fire Anyway

--[[
	A turn the brain found no shot for (everyone out of reach or out of sight): the bot still fires its Bazooka at the
	nearest snail not on its team, on the arc that lands nearest it (never one that hits within DIG_MIN of itself), or
	lobbed toward it at full power when none does, so a bot never just lets its turn run out.
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
	local arc: Vector2 = Vector2.new(if aimAt.X < origin.X then math.rad(135) else math.rad(45), 1)
	local bestMiss: number = math.huge
	for _index: number, option: Vector2 in ipairs(I.Combat.GetArcs(origin, aimAt, "Bazooka", wind, _settings.POWER_STEPS)) do
		local contact: Vector3 = Aim.GetContact(origin, option.X, option.Y, "Bazooka", wind, model)
		if (contact - origin).Magnitude >= _settings.DIG_MIN and (contact - aimAt).Magnitude < bestMiss then
			arc = option
			bestMiss = (contact - aimAt).Magnitude
		end
	end
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

--%%%%%%%%%%%%%%%%%%%% On Shot Fired

--[[
	Notes the health of every player's snail not on a bot's team when the bot fires, so its taunt knows whom the shot
	hurt once it lands.
]]
function Module._onShotFired(participantId: string, _itemId: string)
	--[[ Data ]]

	local participant = I.Match.GetParticipant(participantId) --- @type Match_Participant?
	local model: Model? = I.Snails.Get(participantId)

	--[[ Checks ]]

	-- Check if a bot fired it (not one playing a dropped player's snail)
	if not participant or not participant.IsBot or not model then
		return
	end

	--[[ Saving ]]

	local healths = {} --- @type { [Model]: number }
	for _index: number, other: Model in ipairs(I.Snails.GetAlive()) do
		local owner = I.Match.GetParticipant(other.Name) --- @type Match_Participant?
		if owner and not owner.IsBot and other:GetAttribute("Team") ~= model:GetAttribute("Team") then
			healths[other] = other:GetAttribute("Health") or 0
		end
	end
	before[participantId] = healths
end

--%%%%%%%%%%%%%%%%%%%% On Shot Resolved

--[[
	A bot's shot landed: when it hurt a player for TAUNT_DAMAGE or more and knocked nobody out (a knockout taunts on its
	own, OnDied), the bot taunts at TAUNT_CHANCE.
]]
function Module._onShotResolved(participantId: string, _damage: number)
	--[[ Data ]]

	local healths = before[participantId] --- @type { [Model]: number }?
	before[participantId] = nil
	if not healths then
		return
	end

	--[[ Measuring ]]

	local most: number = 0
	for model: Model, health: number in pairs(healths) do
		local now: number = model:GetAttribute("Health") or 0
		if now <= 0 then
			return
		end
		most = math.max(most, health - now)
	end

	--[[ Taunting ]]

	if most >= _settings.TAUNT_DAMAGE and random:NextNumber() < _settings.TAUNT_CHANCE then
		Module._taunt(participantId, _settings.TAUNT_HIT)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Died

--[[
	A snail was knocked out: when a bot's blow did it to a snail not on its team, the bot taunts (TAUNT_KILL).
]]
function Module._onDied(participantId: string, _cause: string, killerId: string?, _itemId: string?)
	--[[ Checks ]]

	-- Check if someone else knocked it out
	if not killerId or killerId == participantId then
		return
	end

	--[[ Data ]]

	local killer = I.Match.GetParticipant(killerId) --- @type Match_Participant?
	local victim: Model? = I.Snails.Get(participantId)
	local model: Model? = I.Snails.Get(killerId)

	--[[ Checks ]]

	-- Check if a bot knocked out an enemy
	if not killer or not killer.IsBot or not model or not victim or victim:GetAttribute("Team") == model:GetAttribute("Team") then
		return
	end

	--[[ Taunting ]]

	Module._taunt(killerId, _settings.TAUNT_KILL)
end

--%%%%%%%%%%%%%%%%%%%% Taunt

--[[
	After TAUNT_DELAY, plays one of the emotes on a bot's snail for everyone (Cosmetics' PlaySnailEmote), while it's
	still in play.
]]
--- @param emotes { string }
function Module._taunt(participantId: string, emotes)
	--[[ Waiting ]]

	task.delay(_settings.TAUNT_DELAY, function()
		local model: Model? = I.Snails.Get(participantId)
		if model and model:GetAttribute("Alive") then
			I.Cosmetics.PlaySnailEmote(participantId, emotes[random:NextInteger(1, #emotes)])
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Start

--[[
	**SERVER** |
	Returns the land spot a bot parachutes onto from the match's spots, never within START_GAP of those taken already:
	a safe one its difficulty's genome likes, picked as loosely as its skill's StartNoise says.
]]
--- @param spots { Vector3 }
--- @param taken { Vector3 }
--- @return Vector3
function Module.GetStart(difficulty: string, spots, taken)
	return Brain.GetStart(spots, taken, Brains[difficulty] or Brains.Hard, _settings.SKILLS[difficulty] or _settings.SKILLS.Easy)
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
	--[[ Data ]]

	local participant = I.Match.GetParticipant(model.Name) --- @type Match_Participant?

	--[[ Returning ]]

	--- @type Bots_Snail
	local snail = {
		Id = model.Name,
		Model = model,
		Team = model:GetAttribute("Team"),
		IsBot = participant == nil or participant.IsBot == true,
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
