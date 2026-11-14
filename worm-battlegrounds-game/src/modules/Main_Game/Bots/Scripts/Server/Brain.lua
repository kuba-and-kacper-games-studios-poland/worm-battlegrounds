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

	-- Each spot, target, weapon and point on the target keeps its shot that lands nearest the point; a bouncing weapon whose direct arc misses tries bank shots too
	--- @param spot Bots_Spot
	for _index: number, spot in ipairs(spots) do
		--- @param target Bots_Snail
		for _targetIndex: number, target in ipairs(targets) do
			local direct = {} --- @type { [string]: number }
			for point: number, aimAt: Vector3 in ipairs(Module._getAimPoints(target, skill)) do
				for itemId: string, _uses: number in pairs(view.Uses) do
					if I.G_Arsenal.IsWeapon(itemId) then
						local plan = Module._getRough(view, skill, spot, target, itemId, aimAt, point) --- @type Bots_Plan?
						if plan then
							table.insert(candidates, plan)
							direct[itemId] = if point == 1 then plan.Score - spot.Walk * 0.01 else direct[itemId]
						end
					end
				end
			end
			for itemId: string, _uses: number in pairs(view.Uses) do
				if skill.Banks > 0 and Module._isBouncing(itemId) and (direct[itemId] or math.huge) > _settings.BANK_MISS then
					--- @param plan Bots_Plan
					for _planIndex: number, plan in ipairs(Module._getBanks(view, skill, spot, target, itemId, everyone)) do
						table.insert(candidates, plan)
					end
				end
			end
		end
	end

	--[[ Digging ]]

	-- No arc reaches anyone from anywhere: points along the way to each target instead, never right over its head
	if #candidates == 0 then
		--- @param spot Bots_Spot
		for _index: number, spot in ipairs(spots) do
			--- @param target Bots_Snail
			for _targetIndex: number, target in ipairs(targets) do
				local way: Vector3 = target.Position - spot.Position
				for distance: number = _settings.DIG_MIN, way.Magnitude, _settings.DIG_STEP do
					local aimAt: Vector3 = spot.Position + way.Unit * distance
					for itemId: string, _uses: number in pairs(view.Uses) do
						local plan = if I.G_Arsenal.IsWeapon(itemId) then Module._getRough(view, skill, spot, target, itemId, aimAt, 2) else nil --- @type Bots_Plan?
						if plan then
							plan.Score += (aimAt - target.Position).Magnitude * 0.5
							table.insert(candidates, plan)
						end
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
	Returns the spot a bot parachutes onto, from the match's land spots (random each match): never within START_GAP of
	a spot taken already (with none that far, the farthest from them), safe ones first (no deadly drop right beside it,
	no blast at its feet dropping it into the sea), then the one its genome likes best (away from edges and thin
	ground, high over the others) with its skill's StartNoise on top, so no map has a spot bots always take.
]]
--- @param spots { Vector3 }
--- @param taken { Vector3 }
--- @param genome Bots_Genome
--- @param skill Bots_Skill
--- @return Vector3
function Module.GetStart(spots, taken, genome, skill)
	--[[ Local Variables ]]

	Predict.ClearColumns()
	local jump: number = Move.GetJump()
	local meanHeight: number = 0
	local farthest: number = 0
	local apart = {} --- @type { number }
	for index: number, spot: Vector3 in ipairs(spots) do
		meanHeight += spot.Y / #spots
		apart[index] = math.huge
		for _takenIndex: number, other: Vector3 in ipairs(taken) do
			apart[index] = math.min(apart[index], (other - spot).Magnitude)
		end
		farthest = math.max(farthest, apart[index])
	end
	local best: Vector3 = spots[1]
	local bestScore: number = -math.huge

	--[[ Choosing ]]

	for index: number, spot: Vector3 in ipairs(spots) do
		if apart[index] >= math.min(_settings.START_GAP, farthest) then
			local edge: number = Module._getEdge(spot, jump)
			local footing: number = Module._getFooting(spot)
			local unsafe: number = if edge >= 0.5 or footing >= 1 then 10 else 0
			local height: number = math.clamp((spot.Y - meanHeight) / _settings.HEIGHT_SCALE, -1, 1)
			local score: number = -unsafe - genome.Edge * edge - genome.Footing * footing + genome.Height * height + random:NextNumber() * skill.StartNoise
			if score > bestScore then
				best = spot
				bestScore = score
			end
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
	wounded (its genome's Focus), the last to hurt it (Grudge) or a player rather than a bot (its skill's Hunt).
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
			local hunted: number = if snail.IsBot then 1 else 1 - skill.Hunt
			rank[snail.Id] = (snail.Position - view.Self.Position).Magnitude * (1 - 0.3 * math.clamp(genome.Focus * wounded + genome.Grudge * grudge, 0, 2)) * hunted
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
	Returns the spots a bot weighs shooting from: where it stands, the ground every MOVE_STEP studs its walk reaches
	within its stamina (up ledges its jump clears, with the way open), past that the ground its jetpack reaches (straight
	up to its cruise height under any ceiling, along it while nothing is in the way, then down), the spots beside each
	target it could swing or place Dynamite from, and with its skill's AirShots, spots in the air on its flight's way.
	With a potion, its walk goes further (Speed) or up higher ledges (Low gravity), and the spots only the potion
	reaches name it (Potion). All but where it stands and those beside targets are kept only as far as its skill's
	Spots (and AirShots), the ones its genome likes best.
]]
--- @param view Bots_View
--- @param genome Bots_Genome
--- @param skill Bots_Skill
--- @param targets { Bots_Snail }
--- @return { Bots_Spot }
function Module._getSpots(view, genome, skill, targets, stay: boolean)
	--[[ Local Variables ]]

	local origin: Vector3 = view.Self.Position
	local jump: number = Move.GetJump()
	local reach: number = math.floor(view.Stamina)
	local potion: string?
	local effect: string?
	potion, effect = Module._getPotion(view)
	local fullJump: number = if effect == "LowGravity" then Move.GetJump(true) else jump
	local fullReach: number = if effect == "Speed" then math.floor(view.Stamina * I.Settings["SnailControl"].SPEED_MULTIPLIER) else reach
	local radius: number = I.Settings["Snails"].ROOT_SIZE / 2
	local canFly: boolean = view.Uses["Jetpack"] ~= nil
	local cruise: number = Move.GetCruise(origin)
	local here = Module._getSpot(view, origin, 0, false, jump, nil) --- @type Bots_Spot
	local close = {} --- @type { Bots_Spot }
	local open = {} --- @type { Bots_Spot }
	local air = {} --- @type { Bots_Spot }

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

	-- Hovering right over where it stands
	local wantsAir: boolean = canFly and skill.AirShots > 0
	if wantsAir then
		--- @param hover Bots_Spot
		for _index: number, hover in ipairs(Module._getAirSpots(view, origin, 0, cruise, jump)) do
			table.insert(air, hover)
		end
	end

	-- Each side, a stud at a time: on foot while the ground and the way let it, by jetpack while its flight's way is open
	for _sideIndex: number, side: number in ipairs({ -1, 1 }) do
		local last: Vector3 = origin
		local onFoot: boolean = true
		local inFlight: boolean = canFly and cruise > origin.Y
		local boosted: boolean = false
		for step: number = 1, fullReach do
			local x: number = origin.X + side * step
			local ground: Vector3? = nil
			local fly: boolean = false
			inFlight = inFlight and Move.CanFly(x - side, x, cruise)
			if onFoot then
				ground = Move.GetGround(x, last.Y, fullJump)
				if ground and Move.CanStep(last, ground) then
					-- A ledge higher than its own jump reaches: the Low gravity potion's from here on
					boosted = boosted or ground.Y - radius - last.Y > jump
					last = ground
				else
					ground = nil
					onFoot = false
				end
			end
			local landing: Vector3? = if inFlight and (not ground or wantsAir) then Move.GetLanding(x, cruise) else nil
			if not ground and landing then
				ground = landing
				fly = true
			end
			if not onFoot and not inFlight then
				break
			end
			local marked: boolean = step % _settings.MOVE_STEP == 0
			if ground and (marked or closeX[math.round(x)]) then
				local spot = Module._getSpot(view, ground, step, fly, jump, nil) --- @type Bots_Spot
				spot.Cruise = if fly then cruise else nil
				spot.Potion = if step > reach or boosted and not fly then potion else nil
				table.insert(if closeX[math.round(x)] then close else open, spot)
			end
			if wantsAir and landing and marked then
				--- @param hover Bots_Spot
				for _hoverIndex: number, hover in ipairs(Module._getAirSpots(view, landing, step, cruise, jump)) do
					hover.Potion = if step > reach then potion else nil
					table.insert(air, hover)
				end
			end
			Module.Breathe()
		end
	end

	--[[ Choosing ]]

	-- The open and air spots its genome likes best, up to its skill's Spots with where it stands, and its AirShots (a high one's fall is weighed with its shot, Simulate)
	--- @param list { Bots_Spot }
	for _index: number, list in ipairs({ open, air }) do
		--- @param a Bots_Spot
		--- @param b Bots_Spot
		table.sort(list, function(a, b): boolean
			return Module._getPlace(a, genome, view, skill) + genome.SelfDamage * a.Fall / 100 > Module._getPlace(b, genome, view, skill) + genome.SelfDamage * b.Fall / 100
		end)
	end
	local spots = { here } --- @type { Bots_Spot }
	table.move(close, 1, #close, #spots + 1, spots)
	table.move(open, 1, math.min(#open, skill.Spots - 1), #spots + 1, spots)
	table.move(air, 1, math.min(#air, skill.AirShots), #spots + 1, spots)

	--[[ Returning ]]

	return spots
end

--%%%%%%%%%%%%%%%%%%%% Get Spot

--[[
	Returns what a bot knows about a spot: how far it walks there and whether it flies, how near a deadly drop is, how
	badly a blast at its feet would drop it, how low it is over the sea as sudden death nears, whether terrain covers
	it from above and whether its head is in a pond, its height over the enemies, and how many enemies see it, stand
	near it, and how many friends stand near it. A spot in the air takes the map's dangers of the `ground` it drops onto.
]]
--- @param view Bots_View
--- @return Bots_Spot
function Module._getSpot(view, position: Vector3, walk: number, fly: boolean, jump: number, ground: Vector3?)
	--[[ Local Variables ]]

	local standing: Vector3 = ground or position
	local head: Vector3 = standing + Vector3.yAxis * I.Settings["Match"].UNDERWATER_HEAD_HEIGHT
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
		Air = ground ~= nil,
		Cruise = nil,
		Potion = nil,
		Edge = Module._getEdge(standing, jump),
		Footing = Module._getFooting(standing),
		Low = if sea > -math.huge then math.clamp(1 - (standing.Y - sea) / _settings.LOW_RANGE, 0, 1) * (0.25 + 0.75 * urgency) else 0,
		Cover = if I.S.Workspace:Raycast(standing, Vector3.yAxis * _settings.COVER_HEIGHT, sightParams) then 1 else 0,
		Pond = if I.Arena.GetLiquid(head) then 1 else 0,
		Fall = if ground then math.clamp(math.floor(position.Y - ground.Y - I.Settings["Snails"].SAFE_FALL_HEIGHT), 0, I.Settings["Snails"].MAX_FALL_DAMAGE) else 0,
		Height = if enemies > 0 then math.clamp((position.Y - enemyHeight / enemies) / _settings.HEIGHT_SCALE, -1, 1) else 0,
		Exposure = if enemies > 0 then seen / enemies else 0,
		Crowd = crowd,
		Threat = threat,
	}
	return spot
end

--%%%%%%%%%%%%%%%%%%%% Get Air Spots

--[[
	Returns the spots in the air over the ground a jetpack flight passes (its `walk`th stud from where the bot stands),
	to hover and shoot from, at least AIR_MIN studs up: one no higher than a safe fall (Snails' SAFE_FALL_HEIGHT), and
	one as high as its cruise when that's higher still, whose fall after the shot costs health (its Fall), a trade its
	genome weighs against what the shot does from up there. Empty when there isn't room to hover.
]]
--- @param view Bots_View
--- @return { Bots_Spot }
function Module._getAirSpots(view, ground: Vector3, walk: number, cruise: number, jump: number)
	--[[ Local Variables ]]

	local safe: number = math.min(cruise, ground.Y + I.Settings["Snails"].SAFE_FALL_HEIGHT)
	local spots = {} --- @type { Bots_Spot }

	--[[ Listing ]]

	for _index: number, height: number in ipairs({ safe, cruise }) do
		if height - ground.Y >= _settings.AIR_MIN and (height == safe or height > safe + 1) then
			local spot = Module._getSpot(view, Vector3.new(ground.X, height, 0), walk, true, jump, ground) --- @type Bots_Spot
			spot.Cruise = cruise
			table.insert(spots, spot)
		end
	end

	--[[ Returning ]]

	return spots
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
	Returns how much a genome likes standing on a spot, for the spot alone: the getting there (a potion it drinks for
	it costs as a limited weapon's use does: Ammo), the fall after shooting from high in the air (as its own damage),
	the map's dangers there (the edge, its footing, low ground, a pond's damage over POND_TURNS turns) as much as its
	skill's MapSense minds them, the height, cover from above, being seen, crowded and threatened.
]]
--- @param spot Bots_Spot
--- @param genome Bots_Genome
--- @param view Bots_View
--- @param skill Bots_Skill
--- @return number
function Module._getPlace(spot, genome, view, skill)
	--[[ Local Variables ]]

	local walk: number = spot.Walk / math.max(view.Stamina, 1)
	local potion: number = if spot.Potion then genome.Ammo / math.max(view.Uses[spot.Potion] or 1, 1) else 0
	local pond: number = spot.Pond * I.Settings["Match"].UNDERWATER_DAMAGE * _settings.POND_TURNS / 100
	local danger: number = genome.Edge * spot.Edge + genome.Footing * spot.Footing + genome.Low * spot.Low + genome.SelfDamage * pond

	--[[ Returning ]]

	return -genome.Walk * walk
		- potion
		- genome.SelfDamage * spot.Fall / 100
		- genome.Jetpack * (if spot.Fly then 1 else 0)
		- skill.MapSense * danger
		+ genome.Height * spot.Height
		+ genome.Cover * spot.Cover
		- genome.Exposure * spot.Exposure
		- genome.Crowd * spot.Crowd
		- genome.Threat * spot.Threat
end

--%%%%%%%%%%%%%%%%%%%% Get Potion

--[[
	Returns the movement potion a bot can drink this turn (a utility whose Effect is Speed or LowGravity), and that
	effect; nil and nil without one.
]]
--- @param view Bots_View
--- @return string?
--- @return string?
function Module._getPotion(view)
	--[[ Searching ]]

	for itemId: string, _uses: number in pairs(view.Uses) do
		local row = if I.G_Arsenal.IsUtility(itemId) then I.G_Arsenal.Get(itemId) else nil --- @type Arsenal_UtilityData?
		if row and (row.Effect == "Speed" or row.Effect == "LowGravity") then
			return itemId, row.Effect
		end
	end

	--[[ Returning ]]

	return nil, nil
end

--%%%%%%%%%%%%%%%%%%%% Is Bouncing

--[[
	Returns whether a weapon's shot bounces before it bursts (a fused Bouncer: the Grenade, the Cluster bomb), so a
	bank shot can roll it in.
]]
--- @return boolean
function Module._isBouncing(itemId: string)
	--[[ Data ]]

	local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData

	--[[ Returning ]]

	return row.Kind == "Bouncer" and row.Aim == "Arc" and not row.BurstOnContact
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

	-- Only from the ground beside the target, on about its level
	if (row.Aim == "Melee" or row.Aim == "Feet") and point == 1 then
		local gap: number = if row.Aim == "Melee" then _settings.MELEE_GAP else _settings.DYNAMITE_GAP
		return if not spot.Air and math.abs(math.abs(toTarget.X) - gap) <= 1 and math.abs(toTarget.Y) <= _settings.CLOSE_HEIGHT then plan else nil
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

--%%%%%%%%%%%%%%%%%%%% Get Banks

--[[
	Returns a bouncing weapon's bank shots at a target from a spot, as many as its skill's Banks: arcs onto the ground
	BANK_STEP studs either side of the target, then onto a wall BANK_HEIGHT studs up past it, then twice as far out,
	each flown in full (Predict) with the wind its bot reads, its Score how far from the target it bursts.
]]
--- @param view Bots_View
--- @param skill Bots_Skill
--- @param spot Bots_Spot
--- @param target Bots_Snail
--- @param everyone { Bots_Snail }
--- @return { Bots_Plan }
function Module._getBanks(view, skill, spot, target, itemId: string, everyone)
	--[[ Local Variables ]]

	local feet: Vector3 = target.Position - Vector3.yAxis * (I.Settings["Snails"].ROOT_SIZE / 2)
	local far: number = if target.Position.X < spot.Position.X then -1 else 1
	local step: number = _settings.BANK_STEP
	local points = {
		feet - Vector3.xAxis * far * step,
		feet + Vector3.xAxis * far * step,
		feet + Vector3.new(far * step, _settings.BANK_HEIGHT, 0),
		feet - Vector3.xAxis * far * step * 2,
		feet + Vector3.xAxis * far * step * 2,
		feet + Vector3.new(far * step * 2, _settings.BANK_HEIGHT, 0),
	} --- @type { Vector3 }
	local banks = {} --- @type { Bots_Plan }

	--[[ Flying ]]

	for index: number = 1, math.min(skill.Banks, #points) do
		local plan = Module._getRough(view, skill, spot, target, itemId, points[index], 2) --- @type Bots_Plan?
		local shot = if plan then Predict.GetShot(spot.Position, itemId, plan.Angle, plan.Power, nil, view.Wind * skill.WindRead, view.Self.Model, everyone, nil) else nil --- @type Bots_Shot?
		if plan and shot then
			plan.Score = spot.Walk * 0.01 + (shot.Landed - target.Position).Magnitude
			table.insert(banks, plan)
		end
		Module.Breathe()
	end

	--[[ Returning ]]

	return banks
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
	spot it shoots from. A shot that hurts no enemy is worth its Pressure the nearer it lands to one (PRESSURE_RANGE),
	and one that knocks out the last enemy WIN_VALUE more. Placed Dynamite is scored with its bot run off as far as its
	ground and the fuse allow. Returns whether the weapon's shot could be foreseen.
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
	local enemiesLeft: number = 0
	local hurtEnemy: boolean = false
	local nearest: number = math.huge
	score -= if uses > 0 then genome.Ammo / uses else 0
	--- @param snail Bots_Snail
	for _index: number, snail in ipairs(placed) do
		local effect = effects[snail.Id] --- @type Bots_Effect?
		local damage: number = if effect then math.min(effect.Damage, snail.Health) / 100 else 0
		local out: number = if effect and (effect.Out or effect.Damage >= snail.Health) then 1 else 0
		if snail.Id == view.Self.Id then
			-- Its fall from a high air spot after the shot (its damage is the spot's, GetPlace) knocks it out too
			out = if (if effect then effect.Damage else 0) + plan.Spot.Fall >= snail.Health then 1 else out
			score -= genome.SelfDamage * damage + genome.SelfKnockout * out
		elseif snail.Team == view.Self.Team then
			score -= genome.AllyDamage * damage + genome.AllyKnockout * out
		else
			score += genome.EnemyDamage * damage + genome.Knockout * out + genome.Focus * damage * (1 - snail.Health / maxHealth)
			score += if snail.Id == view.LastAttacker then genome.Grudge * damage else 0
			enemiesLeft += 1 - out
			hurtEnemy = hurtEnemy or damage > 0
			nearest = math.min(nearest, (snail.Position - shot.Landed).Magnitude)
		end
	end

	-- Toward enemies it couldn't hurt, and the win
	score += if hurtEnemy then 0 else genome.Pressure * math.clamp(1 - nearest / _settings.PRESSURE_RANGE, 0, 1)
	score += if enemiesLeft == 0 and nearest < math.huge then _settings.WIN_VALUE else 0

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

return Module
