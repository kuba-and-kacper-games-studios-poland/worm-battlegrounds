--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Bots"

--- @type Bots_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local random: Random = Random.new()

-- Names already given out this match
local usedNames = {} --- @type { [string]: boolean }

-- Casts that see what shots hit: terrain and snails in play
local arcParams: RaycastParams = RaycastParams.new()

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

	arcParams.CollisionGroup = "Projectile"
	arcParams.FilterType = Enum.RaycastFilterType.Exclude

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Bots = {

		--[[ Control ]]

		CreateParticipant = Module.CreateParticipant,
		TakeTurn = Module.TakeTurn,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Create Participant

--[[
	**SERVER** |
	Returns a new bot participant for a match: an unused name, its difficulty's loadout and the default skin. The
	match gives it its team and colour. The first bot of a match (number 1) starts the name list over.
]]
--- @return Match_Participant
function Module.CreateParticipant(difficulty: string, number: number)
	--[[ Local Variables ]]

	if number == 1 then
		usedNames = {}
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
	Plays a bot's turn: thinks for a moment, picks a target and a weapon for its difficulty, solves the shot, misses on
	purpose often enough to match its HIT_RATE, and fires through Combat like a player. Gives up quietly when the turn
	ends meanwhile.
]]
function Module.TakeTurn(participantId: string)
	--[[ Thinking ]]

	task.wait(random:NextNumber(_settings.THINK_TIME[1], _settings.THINK_TIME[2]))

	--[[ Data ]]

	local participant = I.Match.GetParticipant(participantId) --- @type Match_Participant?
	local model: Model? = I.Snails.Get(participantId)

	--[[ Checks ]]

	-- Check if it's still this bot's turn
	if not participant or not model or I.Match.GetActive() ~= participantId or I.Match.GetPhase() ~= "Turn" then
		return
	end

	--[[ Choosing ]]

	local difficulty: string = participant.Difficulty or "Easy"
	local target: Model? = Module._getTarget(model, difficulty)
	if not target then
		return
	end
	local origin: Vector3 = model.PrimaryPart.Position
	local aimAt: Vector3 = target.PrimaryPart.Position

	-- The tutorial bot shoots at the ground beside the player, never at them
	if difficulty == "Tutorial" then
		aimAt += Vector3.new(random:NextNumber(-8, 8), -2, 0)
	end
	local itemId: string = Module._getWeapon(participantId, difficulty, (aimAt - origin).Magnitude)

	--[[ Solving ]]

	local angle: number
	local power: number
	angle, power = Module._solve(model, itemId, aimAt, difficulty)

	-- Miss on purpose often enough to match the difficulty
	if random:NextNumber() > (_settings.HIT_RATE[difficulty] or 0.5) then
		angle += (if random:NextNumber() < 0.5 then -1 else 1) * random:NextNumber(0.08, _settings.MISS_ANGLE)
		power = math.clamp(power * (1 + random:NextNumber(-_settings.MISS_POWER, _settings.MISS_POWER)), 0, 1)
	end

	--[[ Aiming ]]

	-- Everyone watches the bot take aim; the turn may run out meanwhile
	if not Module._showAim(participantId, itemId, angle, power) then
		return
	end

	--[[ Firing ]]

	if not I.Combat.Fire(participantId, itemId, angle, power, aimAt) then
		I.Combat.Fire(participantId, "Bazooka", angle, power)
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
		if I.Match.GetActive() ~= participantId or I.Match.GetPhase() ~= "Turn" then
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

--%%%%%%%%%%%%%%%%%%%% Get Target

--[[
	Returns the snail a bot aims at: Easy any enemy, Medium the nearest, Hard the one easiest to knock out (low health,
	near liquid or the arena's edge), then the nearest.
]]
--- @return Model?
function Module._getTarget(model: Model, difficulty: string)
	--[[ Local Variables ]]

	local team: number = model:GetAttribute("Team")
	local enemies = {} --- @type { Model }
	for _index: number, other: Model in ipairs(I.Snails.GetAlive()) do
		if other ~= model and other:GetAttribute("Team") ~= team then
			table.insert(enemies, other)
		end
	end

	--[[ Checks ]]

	-- Check if anyone is left to aim at
	if #enemies == 0 then
		return nil
	end

	--[[ Returning ]]

	if difficulty == "Easy" then
		return enemies[random:NextInteger(1, #enemies)]
	end

	local origin: Vector3 = model.PrimaryPart.Position
	local best: Model = enemies[1]
	local bestScore: number = math.huge
	for _index: number, enemy: Model in ipairs(enemies) do
		local position: Vector3 = enemy.PrimaryPart.Position
		local score: number = (position - origin).Magnitude
		if difficulty == "Hard" then
			score += enemy:GetAttribute("Health") * 0.3
			if I.Arena.GetHazard(position - Vector3.yAxis * 6) then
				score -= 40
			end
		end
		if score < bestScore then
			best = enemy
			bestScore = score
		end
	end
	return best
end

--%%%%%%%%%%%%%%%%%%%% Get Weapon

--[[
	Returns the weapon a bot uses at a distance: Easy mostly the Bazooka; harder bots swing a melee weapon up close,
	fire a gun at mid range, and otherwise throw their strongest usable arc weapon.
]]
--- @return string
function Module._getWeapon(participantId: string, difficulty: string, distance: number)
	--[[ Local Variables ]]

	local participant = I.Match.GetParticipant(participantId) --- @type Match_Participant
	local usable = {} --- @type { string }
	for _index: number, itemId: string in ipairs(participant.Loadout) do
		if I.G_Arsenal.IsWeapon(itemId) and I.Combat.CanUse(participantId, itemId) then
			table.insert(usable, itemId)
		end
	end

	--[[ Choosing ]]

	if difficulty == "Easy" or difficulty == "Tutorial" then
		return if #usable > 0 and random:NextNumber() < 0.2 then usable[random:NextInteger(1, #usable)] else "Bazooka"
	end

	local best: string = "Bazooka"
	local bestDamage: number = I.G_Arsenal.Get("Bazooka").DamageMax
	for _index: number, itemId: string in ipairs(usable) do
		local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData
		local fits: boolean = if row.Aim == "Melee" then distance <= _settings.MELEE_RANGE elseif row.Aim == "Straight" then distance <= _settings.GUN_RANGE elseif row.Aim == "Feet" then false else true
		local damage: number = row.DamageMax + (row.PerBulletDamage or 0) * (row.Pellets or 0)
		if fits and damage > bestDamage then
			best = itemId
			bestDamage = damage
		end
	end

	--[[ Returning ]]

	return best
end

--%%%%%%%%%%%%%%%%%%%% Solve

--[[
	Returns the angle and power a bot fires at to reach a point: straight at it for guns, melee and the homing missile
	(which steers itself); for arcs, the tried angle and power whose path lands nearest it, with the wind counted on
	Medium and Hard.
]]
--- @return number, number
function Module._solve(model: Model, itemId: string, aimAt: Vector3, difficulty: string)
	--[[ Local Variables ]]

	local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData
	local origin: Vector3 = model.PrimaryPart.Position
	local toTarget: Vector3 = aimAt - origin
	local straight: number = math.atan2(toTarget.Y, toTarget.X)

	--[[ Straight ]]

	if row.Aim ~= "Arc" then
		return if row.Aim == "Target" then math.rad(if toTarget.X < 0 then 110 else 70) else straight, 0.7
	end

	--[[ Searching ]]

	local wind: number = if difficulty == "Easy" then 0 else I.G_Combat.GetWindAcceleration(itemId, I.Match.GetWind())
	local muzzle: number = I.Settings["Snails"].ROOT_SIZE / 2 + I.Settings["Combat"].MUZZLE_GAP
	local bestAngle: number = straight
	local bestPower: number = 0.6
	local bestMiss: number = math.huge
	local tried: number = 0
	arcParams.FilterDescendantsInstances = { model, I.Dirs.UmeWorkspace:FindFirstChild("Combat") }

	for degrees: number = 5, 175, _settings.ANGLE_STEP do
		local angle: number = math.rad(degrees)
		local direction: Vector3 = Vector3.new(math.cos(angle), math.sin(angle), 0)
		for power: number = _settings.POWER_STEP, 1, _settings.POWER_STEP do
			local velocity: Vector3 = I.G_Combat.GetLaunchVelocity(itemId, angle, power)
			local landed: Vector3 = Module._getLanding(I.G_Combat.PredictArc(origin + direction * muzzle, velocity, wind, _settings.ARC_SECONDS, _settings.ARC_STEP))
			local miss: number = (landed - aimAt).Magnitude
			if miss < bestMiss then
				bestAngle = angle
				bestPower = power
				bestMiss = miss
			end
			tried += 1
			if tried % _settings.SEARCH_BATCH == 0 then
				task.wait()
			end
		end
	end

	--[[ Returning ]]

	return bestAngle, bestPower
end

--%%%%%%%%%%%%%%%%%%%% Get Landing

--[[
	Returns where a predicted path first hits terrain or a snail, or its last point when it hits nothing.
]]
--- @param points { Vector3 }
--- @return Vector3
function Module._getLanding(points)
	--[[ Searching ]]

	for index: number = 2, #points do
		local result: RaycastResult? = I.S.Workspace:Raycast(points[index - 1], points[index] - points[index - 1], arcParams)
		if result then
			return result.Position
		end
	end

	--[[ Returning ]]

	return points[#points]
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
