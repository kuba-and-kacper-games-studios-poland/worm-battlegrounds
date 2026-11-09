--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Bots"

--- @type Bots_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("ServerSettings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Aim = require(script.Parent:FindFirstChild("Aim")) --- @type Bots_Server_Aim
local Move = require(script.Parent:FindFirstChild("Move")) --- @type Bots_Server_Move
local Predict = require(script.Parent:FindFirstChild("Predict")) --- @type Bots_Server_Predict

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local random: Random = Random.new()

-- Casts that see only the terrain, for who sees a spot
local sightParams: RaycastParams = RaycastParams.new()

-- When the current slice of thinking started, and how long a slice lasts (Breathe)
local sliceStart: number = 0
local thinkSlice: number = _settings.THINK_SLICE

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

--- @class Bots_Server_Brain
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Setup ]]

	sightParams.CollisionGroup = "Snail"
	sightParams.RespectCanCollide = true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Plan

--[[
	Returns a bot's plan for its turn: where to stand, which weapon, at whom, and the angle and power, chosen as its
	genome weighs them. It lists the spots it can reach (or only where it stands, when `stay`), keeps the ones its
	genome likes best for its skill, solves every usable weapon's shot at its nearest targets from each (at the snail,
	and with a skill's AimPoints at the ground under it too), simulates the most promising in full (Predict, craters
	and drops included) and scores what they do. With no shot at anyone, it blasts the ground in the way to a target
	instead, from the spot nearest it, as players dig. Nil when it can't even do that.
]]
--- @param view Bots_View
--- @param genome Bots_Genome
--- @param skill Bots_Skill
--- @return Bots_Plan?
function Module.GetPlan(view, genome, skill, stay: boolean?)
	--[[ Local Variables ]]

	Predict.ClearColumns()
	local everyone = Module._getEveryone(view) --- @type { Bots_Snail }
	local targets = Module._getTargets(view, genome, skill) --- @type { Bots_Snail }
	local spots = Module._getSpots(view, genome, skill, targets, stay == true) --- @type { Bots_Spot }
	local candidates = {} --- @type { Bots_Plan }
	sliceStart = os.clock()

	--[[ Checks ]]

	-- Check if anyone is left to aim at
	if #targets == 0 then
		return nil
	end

	--[[ Solving ]]

	-- Each spot, target, weapon and point on the target keeps its shot that lands nearest the point
	--- @param spot Bots_Spot
	for _index: number, spot in ipairs(spots) do
		--- @param target Bots_Snail
		for _targetIndex: number, target in ipairs(targets) do
			for point: number, aimAt: Vector3 in ipairs(Module._getAimPoints(target, skill)) do
				for itemId: string, _uses: number in pairs(view.Uses) do
					if I.G_Arsenal.IsWeapon(itemId) then
						local plan = Module._getRough(view, skill, spot, target, itemId, aimAt, point) --- @type Bots_Plan?
						if plan then
							table.insert(candidates, plan)
						end
					end
				end
			end
		end
	end

	--[[ Digging ]]

	-- Nothing to hit from anywhere: the terrain blocking the way to each target, nearer spots first
	if #candidates == 0 then
		--- @param spot Bots_Spot
		for _index: number, spot in ipairs(spots) do
			--- @param target Bots_Snail
			for _targetIndex: number, target in ipairs(targets) do
				local blocker: RaycastResult? = I.S.Workspace:Raycast(spot.Position, target.Position - spot.Position, sightParams)
				for itemId: string, _uses: number in pairs(if blocker then view.Uses else {}) do
					local plan = if I.G_Arsenal.IsWeapon(itemId) then Module._getRough(view, skill, spot, target, itemId, blocker.Position, 2) else nil --- @type Bots_Plan?
					if plan then
						plan.Score += (spot.Position - target.Position).Magnitude * 0.1
						table.insert(candidates, plan)
					end
				end
			end
		end
	end

	--[[ Simulating ]]

	-- The nearest misses are simulated in full and scored
	--- @param a Bots_Plan
	--- @param b Bots_Plan
	table.sort(candidates, function(a, b): boolean
		return a.Score < b.Score
	end)
	local finalists = {} --- @type { Bots_Plan }
	--- @param plan Bots_Plan
	for index: number, plan in ipairs(candidates) do
		if index > skill.Finalists then
			break
		end
		if Module._simulate(view, genome, skill, plan, everyone) then
			table.insert(finalists, plan)
		end
		Module.Breathe()
	end

	--[[ Returning ]]

	return Module._choose(finalists, skill)
end

--%%%%%%%%%%%%%%%%%%%% Get Heal

--[[
	Returns the heal a bot uses at the start of its turn: under its genome's HealBelow, the usable one that heals most
	of what it's missing (the smaller one when both fill it). Nil when it doesn't heal.
]]
--- @param view Bots_View
--- @param genome Bots_Genome
--- @return string?
function Module.GetHeal(view, genome)
	--[[ Local Variables ]]

	local missing: number = I.Settings["Snails"].MAX_HEALTH - view.Self.Health
	local best: string? = nil
	local bestScore: number = 0

	--[[ Checks ]]

	-- Check if it's hurt enough to heal
	if view.Self.Health >= genome.HealBelow then
		return nil
	end

	--[[ Choosing ]]

	for itemId: string, _uses: number in pairs(view.Uses) do
		local row = if I.G_Arsenal.IsUtility(itemId) then I.G_Arsenal.Get(itemId) else nil --- @type Arsenal_UtilityData?
		if row and row.Effect == "Heal" then
			local score: number = math.min(row.Amount or 0, missing) - (row.Amount or 0) * 0.01
			if score > bestScore then
				best = itemId
				bestScore = score
			end
		end
	end

	--[[ Returning ]]

	return best
end

--%%%%%%%%%%%%%%%%%%%% Get Start

--[[
	Returns the spot a bot parachutes onto, from the match's land spots: the one its genome likes best away from deadly
	edges and ground a blast would drop it through, high over the others, and apart from the spots already taken.
]]
--- @param spots { Vector3 }
--- @param taken { Vector3 }
--- @param genome Bots_Genome
--- @return Vector3
function Module.GetStart(spots, taken, genome)
	--[[ Local Variables ]]

	Predict.ClearColumns()
	local jump: number = Module._getJump()
	local meanHeight: number = 0
	for _index: number, spot: Vector3 in ipairs(spots) do
		meanHeight += spot.Y / #spots
	end
	local best: Vector3 = spots[1]
	local bestScore: number = -math.huge

	--[[ Choosing ]]

	for _index: number, spot: Vector3 in ipairs(spots) do
		local crowd: number = 0
		for _takenIndex: number, other: Vector3 in ipairs(taken) do
			if (other - spot).Magnitude < _settings.CROWD_RANGE * 2 then
				crowd += 1
			end
		end
		local height: number = math.clamp((spot.Y - meanHeight) / _settings.HEIGHT_SCALE, -1, 1)
		local danger: number = genome.Edge * Module._getEdge(spot, jump) + genome.Footing * Module._getFooting(spot)
		local score: number = -danger + genome.Height * height - genome.Crowd * crowd * 4 + random:NextNumber() * 0.05
		if score > bestScore then
			best = spot
			bestScore = score
		end
	end

	--[[ Returning ]]

	return best
end

--%%%%%%%%%%%%%%%%%%%% Set Think Slice

--[[
	Sets how long bots think before giving the server a frame (Breathe), or THINK_SLICE again with nil. The gym thinks in
	longer slices, since no player is waiting on its server.
]]
function Module.SetThinkSlice(seconds: number?)
	thinkSlice = seconds or _settings.THINK_SLICE
end

--%%%%%%%%%%%%%%%%%%%% Breathe

--[[
	Gives the server a frame once a bot has thought for THINK_SLICE seconds in a row (or the slice SetThinkSlice set),
	so planning never stalls it.
]]
function Module.Breathe()
	--[[ Waiting ]]

	if os.clock() - sliceStart >= thinkSlice then
		task.wait()
		sliceStart = os.clock()
	end
end

--%%%%%%%%%%%%%%%%%%%% Get Everyone

--[[
	Returns every snail in a view, the bot's own first.
]]
--- @param view Bots_View
--- @return { Bots_Snail }
function Module._getEveryone(view)
	--[[ Local Variables ]]

	local everyone = { view.Self } --- @type { Bots_Snail }

	--[[ Returning ]]

	table.move(view.Snails, 1, #view.Snails, 2, everyone)
	return everyone
end

--%%%%%%%%%%%%%%%%%%%% Get Targets

--[[
	Returns the enemies a bot aims at this turn, as many as its skill's Targets: the nearest first, nearer still when
	wounded (its genome's Focus) or the last to hurt it (Grudge).
]]
--- @param view Bots_View
--- @param genome Bots_Genome
--- @param skill Bots_Skill
--- @return { Bots_Snail }
function Module._getTargets(view, genome, skill)
	--[[ Local Variables ]]

	local maxHealth: number = I.Settings["Snails"].MAX_HEALTH
	local enemies = {} --- @type { Bots_Snail }
	local rank = {} --- @type { [string]: number }

	--[[ Ranking ]]

	--- @param snail Bots_Snail
	for _index: number, snail in ipairs(view.Snails) do
		if snail.Team ~= view.Self.Team then
			table.insert(enemies, snail)
			local wounded: number = 1 - snail.Health / maxHealth
			local grudge: number = if snail.Id == view.LastAttacker then 1 else 0
			rank[snail.Id] = (snail.Position - view.Self.Position).Magnitude * (1 - 0.3 * math.clamp(genome.Focus * wounded + genome.Grudge * grudge, 0, 2))
		end
	end
	--- @param a Bots_Snail
	--- @param b Bots_Snail
	table.sort(enemies, function(a, b): boolean
		return rank[a.Id] < rank[b.Id]
	end)

	--[[ Returning ]]

	return { table.unpack(enemies, 1, math.min(skill.Targets, #enemies)) }
end

--%%%%%%%%%%%%%%%%%%%% Get Spots

--[[
	Returns the spots a bot weighs shooting from: where it stands, the ground every MOVE_STEP studs its walk (or its
	jetpack, up to CLIMB_MAX higher and over gaps) reaches within its stamina, and the spots beside each target it could
	swing or place Dynamite from. All but where it stands and those beside targets are kept only as far as its skill's
	Spots, the ones its genome likes best.
]]
--- @param view Bots_View
--- @param genome Bots_Genome
--- @param skill Bots_Skill
--- @param targets { Bots_Snail }
--- @return { Bots_Spot }
function Module._getSpots(view, genome, skill, targets, stay: boolean)
	--[[ Local Variables ]]

	local origin: Vector3 = view.Self.Position
	local jump: number = Module._getJump()
	local reach: number = math.floor(view.Stamina)
	local canFly: boolean = view.Uses["Jetpack"] ~= nil
	local here = Module._getSpot(view, origin, 0, false, jump) --- @type Bots_Spot
	local close = {} --- @type { Bots_Spot }
	local open = {} --- @type { Bots_Spot }

	--[[ Checks ]]

	-- Check if it means to stay where it stands
	if stay or reach <= 0 then
		return { here }
	end

	--[[ Walking ]]

	-- Each side, a stud at a time: on foot while the ground lets it, then by jetpack
	local closeX = {} --- @type { [number]: boolean }
	--- @param target Bots_Snail
	for _index: number, target in ipairs(targets) do
		local side: number = if target.Position.X < origin.X then 1 else -1
		closeX[math.round(target.Position.X + side * _settings.MELEE_GAP)] = true
		closeX[math.round(target.Position.X + side * _settings.DYNAMITE_GAP)] = true
	end

	for _sideIndex: number, side: number in ipairs({ -1, 1 }) do
		local height: number = origin.Y
		local onFoot: boolean = true
		for step: number = 1, reach do
			local x: number = origin.X + side * step
			local ground: Vector3? = if onFoot then Move.GetGround(x, height, jump) else nil
			local fly: boolean = false
			if not ground then
				onFoot = false
				ground = if canFly then Move.GetGround(x, origin.Y, _settings.CLIMB_MAX) else nil
				fly = true
			else
				height = ground.Y
			end
			if ground and (step % _settings.MOVE_STEP == 0 or closeX[math.round(x)]) then
				local spot = Module._getSpot(view, ground, step, fly, jump) --- @type Bots_Spot
				table.insert(if closeX[math.round(x)] then close else open, spot)
			end
			Module.Breathe()
		end
	end

	--[[ Choosing ]]

	-- The open spots its genome likes best, up to its skill's Spots with where it stands
	--- @param a Bots_Spot
	--- @param b Bots_Spot
	table.sort(open, function(a, b): boolean
		return Module._getPlace(a, genome, view, skill) > Module._getPlace(b, genome, view, skill)
	end)
	local spots = { here } --- @type { Bots_Spot }
	table.move(close, 1, #close, #spots + 1, spots)
	table.move(open, 1, math.min(#open, skill.Spots - 1), #spots + 1, spots)

	--[[ Returning ]]

	return spots
end

--%%%%%%%%%%%%%%%%%%%% Get Spot

--[[
	Returns what a bot knows about a spot: how far it walks there and whether it flies, how near a deadly drop is, how
	badly a blast at its feet would drop it, how low it is over the sea as sudden death nears, its height over the
	enemies, and how many enemies see it, stand near it, and how many friends stand near it.
]]
--- @param view Bots_View
--- @return Bots_Spot
function Module._getSpot(view, position: Vector3, walk: number, fly: boolean, jump: number)
	--[[ Local Variables ]]

	local enemies: number = 0
	local enemyHeight: number = 0
	local seen: number = 0
	local crowd: number = 0
	local threat: number = 0
	local match = I.Settings["Match"] --- @type Match_Settings
	local urgency: number = math.clamp((view.Round - (match.SUDDEN_DEATH_ROUND - _settings.URGENCY_ROUNDS)) / _settings.URGENCY_ROUNDS, 0, 1)
	local sea: number = I.Arena.GetSeaLevel()

	--[[ Looking ]]

	--- @param snail Bots_Snail
	for _index: number, snail in ipairs(view.Snails) do
		local distance: number = (snail.Position - position).Magnitude
		if snail.Team == view.Self.Team then
			crowd += if distance < _settings.CROWD_RANGE then 1 else 0
		else
			enemies += 1
			enemyHeight += snail.Position.Y
			threat += if distance < _settings.CROWD_RANGE then 1 else 0
			if distance < _settings.SIGHT_RANGE and not I.S.Workspace:Raycast(snail.Position, position - snail.Position, sightParams) then
				seen += 1
			end
		end
	end

	--[[ Returning ]]

	--- @type Bots_Spot
	local spot = {
		Position = position,
		Walk = walk,
		Fly = fly,
		Edge = Module._getEdge(position, jump),
		Footing = Module._getFooting(position),
		Low = if sea > -math.huge then math.clamp(1 - (position.Y - sea) / _settings.LOW_RANGE, 0, 1) * (0.25 + 0.75 * urgency) else 0,
		Height = if enemies > 0 then math.clamp((position.Y - enemyHeight / enemies) / _settings.HEIGHT_SCALE, -1, 1) else 0,
		Exposure = if enemies > 0 then seen / enemies else 0,
		Crowd = crowd,
		Threat = threat,
	}
	return spot
end

--%%%%%%%%%%%%%%%%%%%% Get Edge

--[[
	Returns how near a spot is to a drop a snail can't step down safely (the sea, nothing, or a drop that hurts), within
	EDGE_LOOK studs either side: 1 right at it, 0 with none in reach.
]]
--- @return number
function Module._getEdge(position: Vector3, jump: number)
	--[[ Searching ]]

	for distance: number = 1, _settings.EDGE_LOOK do
		if not Move.GetGround(position.X - distance, position.Y, jump) or not Move.GetGround(position.X + distance, position.Y, jump) then
			return (_settings.EDGE_LOOK - distance + 1) / _settings.EDGE_LOOK
		end
	end

	--[[ Returning ]]

	return 0
end

--%%%%%%%%%%%%%%%%%%%% Get Footing

--[[
	Returns how badly a blast of UNDERMINE_RADIUS at a spot's feet would drop a snail standing there (Predict.GetDrop):
	1 into the sea or out of the arena, else its fall damage as a share of the most, halved.
]]
--- @return number
function Module._getFooting(position: Vector3)
	--[[ Local Variables ]]

	local snails = I.Settings["Snails"] --- @type Snails_Settings
	--- @type Bots_Blast
	local hole = {
		Center = position - Vector3.yAxis * (snails.ROOT_SIZE / 2),
		Radius = _settings.UNDERMINE_RADIUS,
		DamageMax = 0,
		DamageEdge = 0,
		Knockback = "Small",
	}

	--[[ Dropping ]]

	local _landed: Vector3
	local out: boolean
	local fall: number
	_landed, out, fall = Predict.GetDrop(position, { hole })

	--[[ Returning ]]

	return if out then 1 else fall / snails.MAX_FALL_DAMAGE / 2
end

--%%%%%%%%%%%%%%%%%%%% Get Place

--[[
	Returns how much a genome likes standing on a spot, for the spot alone: the getting there, the map's dangers there
	(the edge, its footing, low ground) as much as its skill's MapSense minds them, the height, being seen, crowded and
	threatened.
]]
--- @param spot Bots_Spot
--- @param genome Bots_Genome
--- @param view Bots_View
--- @param skill Bots_Skill
--- @return number
function Module._getPlace(spot, genome, view, skill)
	--[[ Local Variables ]]

	local walk: number = spot.Walk / math.max(view.Stamina, 1)
	local danger: number = genome.Edge * spot.Edge + genome.Footing * spot.Footing + genome.Low * spot.Low

	--[[ Returning ]]

	return -genome.Walk * walk
		- genome.Jetpack * (if spot.Fly then 1 else 0)
		- skill.MapSense * danger
		+ genome.Height * spot.Height
		- genome.Exposure * spot.Exposure
		- genome.Crowd * spot.Crowd
		- genome.Threat * spot.Threat
end

--%%%%%%%%%%%%%%%%%%%% Get Rough

--[[
	Returns a weapon's best rough shot at a point on a target (its `point`th, GetAimPoints) from a spot, with how far
	off it lands as its Score for now: arcs solved exactly for the wind it reads and checked against the terrain, the
	homing missile marked on the point, guns at the snail only with a clear line in range, a swing or Dynamite only
	from beside it. Nil when the weapon has no shot there.
]]
--- @param view Bots_View
--- @param skill Bots_Skill
--- @param spot Bots_Spot
--- @param target Bots_Snail
--- @return Bots_Plan?
function Module._getRough(view, skill, spot, target, itemId: string, aimAt: Vector3, point: number)
	--[[ Data ]]

	local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData

	--[[ Local Variables ]]

	local origin: Vector3 = spot.Position
	local toTarget: Vector3 = target.Position - origin
	local side: number = if toTarget.X < 0 then -1 else 1
	local level: number = if side < 0 then math.pi else 0
	--- @type Bots_Plan
	local plan = {
		ItemId = itemId,
		TargetId = target.Id,
		Spot = spot,
		Angle = level,
		Power = 1,
		Target = nil,
		Score = spot.Walk * 0.01,
		Outcome = nil,
	}

	--[[ Melee and Feet ]]

	-- Only from beside the target, on about its level
	if (row.Aim == "Melee" or row.Aim == "Feet") and point == 1 then
		local gap: number = if row.Aim == "Melee" then _settings.MELEE_GAP else _settings.DYNAMITE_GAP
		return if math.abs(math.abs(toTarget.X) - gap) <= 1 and math.abs(toTarget.Y) <= _settings.CLOSE_HEIGHT then plan else nil
	end

	--[[ Guns ]]

	if row.Aim == "Straight" and point == 1 then
		plan.Angle = math.atan2(toTarget.Y, toTarget.X)
		local blocked: boolean = toTarget.Magnitude > (row.Range or 60) or I.S.Workspace:Raycast(origin, toTarget, sightParams) ~= nil
		return if blocked then nil else plan
	end

	--[[ Homing ]]

	-- Fired up toward the target's side, it steers itself
	if row.Aim == "Target" then
		plan.Angle = math.rad(if side < 0 then 110 else 70)
		plan.Power = 0.7
		plan.Target = aimAt
		return plan
	end

	--[[ Checks ]]

	-- Check if it's an arc it can solve
	if row.Aim ~= "Arc" then
		return nil
	end

	--[[ Solving ]]

	local wind: number = I.G_Combat.GetWindAcceleration(itemId, view.Wind) * skill.WindRead
	local bestMiss: number = math.huge
	for _index: number, arc: Vector2 in ipairs(I.Combat.GetArcs(origin, aimAt, itemId, wind, _settings.POWER_STEPS)) do
		local miss: number = (Aim.GetContact(origin, arc.X, arc.Y, itemId, wind, view.Self.Model) - aimAt).Magnitude
		if miss < bestMiss then
			bestMiss = miss
			plan.Angle = arc.X
			plan.Power = arc.Y
		end
		Module.Breathe()
	end

	--[[ Returning ]]

	plan.Score += bestMiss
	return if bestMiss < math.huge then plan else nil
end

--%%%%%%%%%%%%%%%%%%%% Get Aim Points

--[[
	Returns the points a bot tries to land a shot on a target, as many as its skill's AimPoints: the snail, its feet,
	then the ground under it UNDER_SIDE studs to the side nearer a deadly drop and UNDER_DEPTH below its feet (to blast
	it out from under it), then the other side.
]]
--- @param target Bots_Snail
--- @param skill Bots_Skill
--- @return { Vector3 }
function Module._getAimPoints(target, skill)
	--[[ Local Variables ]]

	local radius: number = I.Settings["Snails"].ROOT_SIZE / 2
	local position: Vector3 = target.Position
	local points = { position } --- @type { Vector3 }

	--[[ Checks ]]

	-- Check if it aims at more than the snail
	if skill.AimPoints <= 1 then
		return points
	end

	--[[ Listing ]]

	local nearer: number = if Move.GetRunway(position, -1, _settings.EDGE_LOOK) < Move.GetRunway(position, 1, _settings.EDGE_LOOK) then -1 else 1
	local under: number = -radius - _settings.UNDER_DEPTH
	table.insert(points, position - Vector3.yAxis * (radius + 0.3))
	table.insert(points, position + Vector3.new(nearer * _settings.UNDER_SIDE, under, 0))
	table.insert(points, position + Vector3.new(-nearer * _settings.UNDER_SIDE, under, 0))

	--[[ Returning ]]

	return { table.unpack(points, 1, math.min(skill.AimPoints, #points)) }
end

--%%%%%%%%%%%%%%%%%%%% Simulate

--[[
	Simulates a rough plan in full (Predict) with the wind its bot reads, and scores what it does with the genome: harm
	to enemies (knockouts, wounded ones, the last to hurt it), harm to friends and itself, the ammo it spends, and the
	spot it shoots from. Placed Dynamite is scored with its bot run off as far as its ground and the fuse allow.
	Returns whether the weapon's shot could be foreseen.
]]
--- @param view Bots_View
--- @param genome Bots_Genome
--- @param skill Bots_Skill
--- @param plan Bots_Plan
--- @param everyone { Bots_Snail }
--- @return boolean
function Module._simulate(view, genome, skill, plan, everyone)
	--[[ Data ]]

	local row = I.G_Arsenal.Get(plan.ItemId) --- @type Arsenal_WeaponData

	--[[ Local Variables ]]

	local origin: Vector3 = plan.Spot.Position
	local maxHealth: number = I.Settings["Snails"].MAX_HEALTH
	local placed = {} --- @type { Bots_Snail }
	--- @param snail Bots_Snail
	for _index: number, snail in ipairs(everyone) do
		table.insert(placed, if snail == view.Self then table.clone(snail) else snail)
	end
	placed[1].Position = origin

	-- From placed Dynamite it runs toward the side with more ground
	if row.Retreat then
		local run: number = I.Settings["SnailControl"].WALK_SPEED * row.Retreat
		local left: number = Move.GetRunway(origin, -1, run)
		local right: number = Move.GetRunway(origin, 1, run)
		placed[1].Position = origin + Vector3.xAxis * (if left > right then -left else right)
	end

	--[[ Predicting ]]

	local shot = Predict.GetShot(origin, plan.ItemId, plan.Angle, plan.Power, plan.Target, view.Wind * skill.WindRead, view.Self.Model, placed, nil) --- @type Bots_Shot?
	if not shot then
		return false
	end
	local effects = Predict.GetEffects(shot, placed) --- @type { [string]: Bots_Effect }

	--[[ Scoring ]]

	local score: number = Module._getPlace(plan.Spot, genome, view, skill)
	local uses: number = view.Uses[plan.ItemId] or -1
	score -= if uses > 0 then genome.Ammo / uses else 0
	--- @param snail Bots_Snail
	for _index: number, snail in ipairs(placed) do
		local effect = effects[snail.Id] --- @type Bots_Effect?
		if effect then
			local damage: number = math.min(effect.Damage, snail.Health) / 100
			local out: number = if effect.Out then 1 else 0
			if snail.Id == view.Self.Id then
				score -= genome.SelfDamage * damage + genome.SelfKnockout * out
			elseif snail.Team == view.Self.Team then
				score -= genome.AllyDamage * damage + genome.AllyKnockout * out
			else
				score += genome.EnemyDamage * damage + genome.Knockout * out + genome.Focus * damage * (1 - snail.Health / maxHealth)
				score += if snail.Id == view.LastAttacker then genome.Grudge * damage else 0
			end
		end
	end

	--[[ Saving ]]

	plan.Score = score
	plan.Outcome = { Shot = shot, Effects = effects }

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Choose

--[[
	Returns the plan a bot goes with: the best scored, or with its skill's Choice above 0, any of them, more often the
	better they score (a softmax), as a player doesn't always see the best shot.
]]
--- @param plans { Bots_Plan }
--- @param skill Bots_Skill
--- @return Bots_Plan?
function Module._choose(plans, skill)
	--[[ Local Variables ]]

	local best = plans[1] --- @type Bots_Plan?
	--- @param plan Bots_Plan
	for _index: number, plan in ipairs(plans) do
		if plan.Score > best.Score then
			best = plan
		end
	end

	--[[ Checks ]]

	-- Check if it always takes the best
	if not best or skill.Choice <= 0 then
		return best
	end

	--[[ Choosing ]]

	local total: number = 0
	--- @param plan Bots_Plan
	for _index: number, plan in ipairs(plans) do
		total += math.exp((plan.Score - best.Score) / skill.Choice)
	end
	local pick: number = random:NextNumber() * total
	--- @param plan Bots_Plan
	for _index: number, plan in ipairs(plans) do
		pick -= math.exp((plan.Score - best.Score) / skill.Choice)
		if pick <= 0 then
			return plan
		end
	end

	--[[ Returning ]]

	return best
end

--%%%%%%%%%%%%%%%%%%%% Get Jump

--[[
	Returns how high a snail's jump carries it, in studs.
]]
--- @return number
function Module._getJump()
	return I.Settings["SnailControl"].JUMP_SPEED ^ 2 / (2 * I.S.Workspace.Gravity)
end

return Module
