--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Bots"

--- @type Bots_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("ServerSettings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- What simulated shots touch, as Combat's own: terrain and snails in play, the arena's liquid
local world = {} --- @type Combat_World

-- Casts that see what snails stand on (the terrain), and bullets' casts (terrain and snails)
local groundParams: RaycastParams = RaycastParams.new()
local bulletParams: RaycastParams = RaycastParams.new()

-- The solid ground along each column of the arena this turn, by twice its X (GetColumn): Vector2s of a bottom and a top
local columns = {} --- @type { [number]: { Vector2 } }

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

--- @class Bots_Server_Predict
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Setup ]]

	world.Params = RaycastParams.new()
	world.Params.CollisionGroup = "Projectile"
	world.Params.FilterType = Enum.RaycastFilterType.Exclude
	world.Exclude = {}
	world.IsLiquid = function(position: Vector3): boolean
		return I.Arena.GetLiquid(position) ~= nil
	end
	groundParams.CollisionGroup = "Snail"
	groundParams.RespectCanCollide = true
	bulletParams.CollisionGroup = "Projectile"
	bulletParams.FilterType = Enum.RaycastFilterType.Exclude
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Shot

--[[
	Returns what a weapon fired from a snail's middle would do, as Combat's behaviors do it: the blasts it sets off and
	the snails it strikes directly (bullets, a swing, a piercing spear), with the same simulation (I.G_Combat's
	bodies), wind acceleration and fuses. `random` scatters bullets and bomblets as a real shot does; without it they
	spread evenly, so a plan is the same every time. Nil for a weapon whose shot it can't foresee (crawlers, rollers).
]]
--- @param snails { Bots_Snail }
--- @return Bots_Shot?
function Module.GetShot(origin: Vector3, itemId: string, angle: number, power: number, target: Vector3?, wind: number, shooter: Model, snails, random: Random?)
	--[[ Data ]]

	local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData

	--[[ Local Variables ]]

	local combat = I.Settings["Combat"] --- @type Combat_Settings
	local direction: Vector3 = Vector3.new(math.cos(angle), math.sin(angle), 0)
	local start: Vector3 = if row.Aim == "Feet" then origin else I.Combat.GetShotStart(origin, direction, shooter)
	--- @type Bots_Shot
	local shot = {
		Landed = start,
		Blasts = {},
		Strikes = {},
	}

	--[[ Guns ]]

	if row.Kind == "Hitscan" then
		local spread: number = math.rad(row.Spread or 0)
		local pellets: number = row.Pellets or 1
		local push: number = I.G_Arsenal.GetKnockback(row.Knockback) * combat.BULLET_KNOCK_SHARE
		bulletParams.FilterDescendantsInstances = { shooter, I.Dirs.UmeWorkspace:FindFirstChild("Combat") }
		for bullet: number = 1, pellets do
			local share: number = if random then random:NextNumber(-1, 1) elseif pellets > 1 then (bullet - 1) / (pellets - 1) * 2 - 1 else 0
			local bulletDirection: Vector3 = Vector3.new(math.cos(angle + spread * share), math.sin(angle + spread * share), 0)
			local result: RaycastResult? = I.S.Workspace:Raycast(start, bulletDirection * (row.Range or 60), bulletParams)
			local snail: Model? = I.G_Combat.GetBodySnail(result)
			if snail then
				table.insert(shot.Strikes, { Id = snail.Name, Damage = row.PerBulletDamage or 0, Velocity = bulletDirection * push })
			end
			shot.Landed = if result then result.Position else start + bulletDirection * (row.Range or 60)
		end
		return shot
	end

	--[[ Swings ]]

	if row.Kind == "Melee" then
		local side: number = if direction.X < 0 then -1 else 1
		local center: Vector3 = origin + Vector3.xAxis * side * (I.Settings["Snails"].ROOT_SIZE / 2 + (row.Reach or 4) / 2)
		local reach: number = combat.MELEE_BOX / 2 + 1
		local victim = nil --- @type Bots_Snail?
		--- @param snail Bots_Snail
		for _index: number, snail in ipairs(snails) do
			local offset: Vector3 = snail.Position - center
			if snail.Model ~= shooter and math.abs(offset.X) <= reach and math.abs(offset.Y) <= reach and (not victim or offset.Magnitude < (victim.Position - center).Magnitude) then
				victim = snail
			end
		end
		if victim then
			local launch: Vector3 = (Vector3.xAxis * side + Vector3.yAxis * (row.Lift or 0.6)).Unit * I.G_Arsenal.GetKnockback(row.Knockback)
			table.insert(shot.Strikes, { Id = victim.Id, Damage = row.DamageMax, Velocity = launch })
		end
		shot.Landed = center
		return shot
	end

	--[[ Checks ]]

	-- Check if it's a shot the simulation alone decides
	if row.Kind ~= "Rocket" and row.Kind ~= "Bouncer" and row.Kind ~= "Homing" then
		return nil
	end

	--[[ Flying ]]

	--- @type Combat_ShotOptions
	local options = {
		Radius = combat.PROJECTILE_SIZE / 2,
		Shooter = if row.Aim == "Feet" then nil else shooter,
		GraceSteps = math.round(combat.SHOOTER_GRACE / combat.PROJECTILE_STEP),
		Wind = I.G_Combat.GetWindAcceleration(itemId, wind),
		Pierce = row.Pierce,
		Bounce = if row.Kind == "Bouncer" and not row.BurstOnContact then row.Elasticity or 0.5 else nil,
		Target = if row.Kind == "Homing" then target else nil,
		HomingSpeed = row.HomingSpeed,
		LockStep = if row.Kind == "Homing" then math.round((row.LockDelay or 1) / combat.PROJECTILE_STEP) else nil,
	}
	local velocity: Vector3 = if row.Aim == "Feet" then Vector3.zero else I.G_Combat.GetLaunchVelocity(itemId, angle, power)

	-- A placed weapon is left behind by its snail, which runs from it
	local burst: Vector3?
	local pierced = {} --- @type { Model }
	burst, pierced = Module._fly(start, velocity, options, row, if row.Aim == "Feet" then shooter else nil)
	for _index: number, snail: Model in ipairs(pierced) do
		table.insert(shot.Strikes, {
			Id = snail.Name,
			Damage = row.DamageMax,
			Velocity = (direction + Vector3.yAxis * combat.UPWARD_BIAS).Unit * I.G_Arsenal.GetKnockback(row.Knockback),
		})
	end

	--[[ Bursting ]]

	-- A piercing shot sticks where it lands, without a blast
	if not burst then
		return shot
	end
	shot.Landed = burst
	if row.Pierce then
		return shot
	end
	table.insert(shot.Blasts, {
		Center = burst,
		Radius = row.BlastRadius,
		DamageMax = row.DamageMax,
		DamageEdge = row.DamageEdge,
		Knockback = row.Knockback,
	})

	-- A cluster bomb's bomblets fly out up and to the sides, each bursting where it touches
	if row.Bomblets then
		for bomblet: number = 1, row.Bomblets.Count do
			local share: number = if random then random:NextNumber() else (bomblet - 0.5) / row.Bomblets.Count
			local bombletAngle: number = math.rad(30 + 120 * share)
			local speed: number = if random then random:NextNumber(combat.BOMBLET_SPEED[1], combat.BOMBLET_SPEED[2]) else (combat.BOMBLET_SPEED[1] + combat.BOMBLET_SPEED[2]) / 2
			--- @type Combat_ShotOptions
			local bombletOptions = {
				Radius = combat.PROJECTILE_SIZE / 2,
				GhostSteps = math.round(combat.BOMBLET_GHOST / combat.PROJECTILE_STEP),
			}
			local bombletBurst: Vector3? = Module._fly(burst + Vector3.yAxis * 1.5, Vector3.new(math.cos(bombletAngle), math.sin(bombletAngle), 0) * speed, bombletOptions, nil, nil)
			if bombletBurst then
				table.insert(shot.Blasts, {
					Center = bombletBurst,
					Radius = row.Bomblets.Radius,
					DamageMax = row.Bomblets.DamageMax,
					DamageEdge = row.Bomblets.DamageEdge,
					Knockback = "Small",
				})
			end
		end
	end

	--[[ Returning ]]

	return shot
end

--%%%%%%%%%%%%%%%%%%%% Get Effects

--[[
	Returns what a shot does to each snail it reaches, as Combat's blasts and hits do it: the damage (blasts fall off
	from the center to the edge), then where the knockback throws it, or where it drops when the craters take the
	ground under it, and whether that, or the damage, knocks it out.
]]
--- @param shot Bots_Shot
--- @param snails { Bots_Snail }
--- @return { [string]: Bots_Effect }
function Module.GetEffects(shot, snails)
	--[[ Local Variables ]]

	local combat = I.Settings["Combat"] --- @type Combat_Settings
	local rootRadius: number = I.Settings["Snails"].ROOT_SIZE / 2
	local damages = {} --- @type { [string]: number }
	local pushes = {} --- @type { [string]: Vector3 }
	local effects = {} --- @type { [string]: Bots_Effect }

	--[[ Hurting ]]

	--- @param blast Bots_Blast
	for _index: number, blast in ipairs(shot.Blasts) do
		local knockSpeed: number = I.G_Arsenal.GetKnockback(blast.Knockback)
		--- @param snail Bots_Snail
		for _snailIndex: number, snail in ipairs(snails) do
			local offset: Vector3 = snail.Position - blast.Center
			local distance: number = math.max(offset.Magnitude - rootRadius, 0)
			if distance <= blast.Radius then
				local share: number = if blast.Radius > 0 then distance / blast.Radius else 0
				local away: Vector3 = if offset.Magnitude > 0.05 then offset.Unit else Vector3.yAxis
				damages[snail.Id] = (damages[snail.Id] or 0) + math.floor(blast.DamageMax + (blast.DamageEdge - blast.DamageMax) * share + 0.5)
				pushes[snail.Id] = (pushes[snail.Id] or Vector3.zero) + (away + Vector3.yAxis * combat.UPWARD_BIAS).Unit * knockSpeed * (1 - (1 - combat.KNOCKBACK_EDGE) * share)
			end
		end
	end

	--- @param strike Bots_Strike
	for _index: number, strike in ipairs(shot.Strikes) do
		damages[strike.Id] = (damages[strike.Id] or 0) + strike.Damage
		pushes[strike.Id] = (pushes[strike.Id] or Vector3.zero) + strike.Velocity
	end

	--[[ Throwing ]]

	-- A hurt snail is thrown; one whose ground the blasts cut away drops, through the craters
	local holes = {} --- @type { Bots_Blast }
	--- @param blast Bots_Blast
	for _index: number, blast in ipairs(shot.Blasts) do
		if blast.Radius > 0 then
			table.insert(holes, blast)
		end
	end
	--- @param snail Bots_Snail
	for _index: number, snail in ipairs(snails) do
		local landed: Vector3? = nil
		local out: boolean = false
		local fall: number = 0
		if pushes[snail.Id] then
			landed, out, fall = Module.GetThrow(snail.Position, pushes[snail.Id], holes)
		elseif Module._isUndermined(snail.Position, holes) then
			landed, out, fall = Module.GetDrop(snail.Position, holes)
		end
		local damage: number = (damages[snail.Id] or 0) + fall
		if landed and (damage > 0 or out or (landed - snail.Position).Magnitude > 0.5) then
			effects[snail.Id] = { Id = snail.Id, Damage = damage, Position = landed, Out = out or damage >= snail.Health }
		end
	end

	--[[ Returning ]]

	return effects
end

--%%%%%%%%%%%%%%%%%%%% Get Throw

--[[
	Returns where a snail thrown from a position at a velocity comes to rest (on ground it lands on; it slides down
	walls), whether it falls into the sea or out of the arena on the way, and the fall damage its drop costs (Snails'
	SAFE_FALL_HEIGHT and MAX_FALL_DAMAGE). It flies through the craters `holes` cut. A shortcut of the snail's real
	physics: it doesn't roll or bounce.
]]
--- @param holes { Bots_Blast }
--- @return Vector3
--- @return boolean
--- @return number
function Module.GetThrow(position: Vector3, velocity: Vector3, holes)
	--[[ Local Variables ]]

	local snails = I.Settings["Snails"] --- @type Snails_Settings
	local radius: number = snails.ROOT_SIZE / 2
	local gravity: Vector3 = Vector3.new(0, -I.S.Workspace.Gravity, 0)
	local at: Vector3 = position
	local speed: Vector3 = velocity
	local peak: number = position.Y

	--[[ Flying ]]

	for _step: number = 1, math.ceil(_settings.KNOCK_SECONDS / _settings.KNOCK_STEP) do
		local move: Vector3 = speed * _settings.KNOCK_STEP + gravity * (0.5 * _settings.KNOCK_STEP ^ 2)
		speed += gravity * _settings.KNOCK_STEP
		local hit: RaycastResult? = if move.Magnitude > 1e-4 then I.S.Workspace:Spherecast(at, radius, move, groundParams) else nil
		if hit and Module._isInHole(hit.Position, holes) then
			hit = nil
		end
		if hit and hit.Normal.Y > 0.6 then
			at += move.Unit * hit.Distance
			break
		elseif hit then
			at += move.Unit * hit.Distance
			speed = Vector3.new(0, math.min(speed.Y, 0), 0)
		else
			at += move
		end
		peak = math.max(peak, at.Y)
		if I.Arena.GetHazard(at) then
			return at, true, 0
		end
	end

	--[[ Returning ]]

	return at, false, math.clamp(math.floor(peak - at.Y - snails.SAFE_FALL_HEIGHT), 0, snails.MAX_FALL_DAMAGE)
end

--%%%%%%%%%%%%%%%%%%%% Get Drop

--[[
	Returns where a snail at a position comes to rest when the craters `holes` cut the ground (GetColumn) away under it:
	the highest ground left below its feet, whether it drops into the sea or out of the arena instead, and the fall
	damage of its drop.
]]
--- @param holes { Bots_Blast }
--- @return Vector3
--- @return boolean
--- @return number
function Module.GetDrop(position: Vector3, holes)
	--[[ Local Variables ]]

	local snails = I.Settings["Snails"] --- @type Snails_Settings
	local radius: number = snails.ROOT_SIZE / 2
	local feet: number = position.Y - radius + 0.5
	local best: number? = nil

	--[[ Searching ]]

	-- Each solid stretch below its feet, cut down past any crater that reaches its top
	for _index: number, solid: Vector2 in ipairs(Module.GetColumn(position.X)) do
		local top: number = math.min(solid.Y, feet)
		local cut: boolean = true
		while cut and top > solid.X do
			cut = false
			--- @param hole Bots_Blast
			for _holeIndex: number, hole in ipairs(holes) do
				local across: number = position.X - hole.Center.X
				local half: number = if math.abs(across) < hole.Radius then math.sqrt(hole.Radius ^ 2 - across ^ 2) else -1
				if half >= 0 and top <= hole.Center.Y + half and top >= hole.Center.Y - half then
					top = hole.Center.Y - half - 0.01
					cut = true
				end
			end
		end
		if top > solid.X and (not best or top > best) then
			best = top
		end
	end

	--[[ Returning ]]

	local landed: Vector3 = Vector3.new(position.X, if best then best + radius else position.Y, 0)
	if not best or I.Arena.GetHazard(landed) then
		return landed, true, 0
	end
	return landed, false, math.clamp(math.floor(position.Y - landed.Y - snails.SAFE_FALL_HEIGHT), 0, snails.MAX_FALL_DAMAGE)
end

--%%%%%%%%%%%%%%%%%%%% Get Column

--[[
	Returns the solid ground along a vertical line of the arena at an X, as Vector2s of each terrain part's bottom (X)
	and top (Y) there, kept until ClearColumns. Rays don't see a part they start in, so casting on from just inside
	each part's top finds the next part down, and the same from below finds bottoms. A part with a cave through it at
	that X counts as solid across it.
]]
--- @return { Vector2 }
function Module.GetColumn(x: number)
	--[[ Checks ]]

	-- Check if it's known this turn
	local key: number = math.round(x * 2)
	if columns[key] then
		return columns[key]
	end

	--[[ Local Variables ]]

	local bounds: BasePart = I.Arena.GetBounds()
	local top: number = bounds.Position.Y + bounds.Size.Y / 2 + 5
	local bottom: number = bounds.Position.Y - bounds.Size.Y / 2 - 5
	local tops = {} --- @type { [Instance]: number }
	local bottoms = {} --- @type { [Instance]: number }
	local order = {} --- @type { Instance }

	--[[ Casting ]]

	local from: Vector3 = Vector3.new(x, top, 0)
	for _cast: number = 1, 24 do
		local hit: RaycastResult? = I.S.Workspace:Raycast(from, Vector3.new(0, bottom - from.Y, 0), groundParams)
		if not hit then
			break
		end
		if not tops[hit.Instance] then
			tops[hit.Instance] = hit.Position.Y
			table.insert(order, hit.Instance)
		end
		from = hit.Position - Vector3.yAxis * 0.01
	end
	from = Vector3.new(x, bottom, 0)
	for _cast: number = 1, 24 do
		local hit: RaycastResult? = I.S.Workspace:Raycast(from, Vector3.new(0, top - from.Y, 0), groundParams)
		if not hit then
			break
		end
		bottoms[hit.Instance] = bottoms[hit.Instance] or hit.Position.Y
		from = hit.Position + Vector3.yAxis * 0.01
	end

	--[[ Saving ]]

	local solids = {} --- @type { Vector2 }
	for _index: number, part: Instance in ipairs(order) do
		table.insert(solids, Vector2.new(bottoms[part] or bottom, tops[part]))
	end
	columns[key] = solids

	--[[ Returning ]]

	return solids
end

--%%%%%%%%%%%%%%%%%%%% Clear Columns

--[[
	Forgets the ground GetColumn found, for a new turn after blasts changed it.
]]
function Module.ClearColumns()
	columns = {}
end

--%%%%%%%%%%%%%%%%%%%% Is Undermined

--[[
	Returns whether a crater in `holes` reaches the ground right under a snail at a position.
]]
--- @param holes { Bots_Blast }
--- @return boolean
function Module._isUndermined(position: Vector3, holes)
	--[[ Local Variables ]]

	local radius: number = I.Settings["Snails"].ROOT_SIZE / 2

	--[[ Searching ]]

	--- @param hole Bots_Blast
	for _index: number, hole in ipairs(holes) do
		if math.abs(position.X - hole.Center.X) <= hole.Radius + radius and hole.Center.Y + hole.Radius >= position.Y - radius - 1 then
			return true
		end
	end

	--[[ Returning ]]

	return false
end

--%%%%%%%%%%%%%%%%%%%% Is In Hole

--[[
	Returns whether a point is inside one of the craters `holes` (with half a stud to spare).
]]
--- @param holes { Bots_Blast }
--- @return boolean
function Module._isInHole(point: Vector3, holes)
	--[[ Searching ]]

	--- @param hole Bots_Blast
	for _index: number, hole in ipairs(holes) do
		if (point - hole.Center).Magnitude < hole.Radius + 0.5 then
			return true
		end
	end

	--[[ Returning ]]

	return false
end

--%%%%%%%%%%%%%%%%%%%% Fly

--[[
	Steps a shot body until it bursts or is gone, as the behaviors do: a contact shot bursts where it touches, a fused
	one when its fuse runs out, a homing one at its target, any but the spear in liquid. Returns where it burst (nil
	when it's lost, sunk or flew past PREDICT_SECONDS) and the snails a piercing shot passed through. `left` is a
	snail it never touches (the one that placed it and ran).
]]
--- @param options Combat_ShotOptions
--- @param row Arsenal_WeaponData?
--- @return Vector3?
--- @return { Model }
function Module._fly(start: Vector3, velocity: Vector3, options, row, left: Model?)
	--[[ Local Variables ]]

	local combat = I.Settings["Combat"] --- @type Combat_Settings
	local body = I.G_Combat.NewBody(start, velocity, options) --- @type Combat_Body
	local fuse: number? = if row and row.Fuse and row.Aim ~= "Feet" then row.Fuse / combat.PROJECTILE_TIME_SCALE elseif row then row.Fuse else nil
	world.Exclude = { I.Dirs.UmeWorkspace:FindFirstChild("Combat"), left }

	--[[ Flying ]]

	for _step: number = 1, math.ceil(_settings.PREDICT_SECONDS / (combat.PROJECTILE_STEP * combat.PROJECTILE_TIME_SCALE)) do
		local hit: RaycastResult? = I.G_Combat.StepBody(body, world)
		local elapsed: number = body.Step * combat.PROJECTILE_STEP
		local sunkFor: number = if body.Sunk and not body.Grounded then (body.Step - body.SunkStep) * combat.PROJECTILE_STEP else 0
		if I.Arena.GetHazard(body.Position) == "Bounds" or sunkFor >= combat.SINK_SECONDS then
			return nil, body.Ignore
		elseif body.Stopped then
			return if hit then hit.Position else body.Position, body.Ignore
		elseif fuse and elapsed >= fuse then
			return body.Position, body.Ignore
		elseif options.Target and body.Step >= (options.LockStep or 0) and (options.Target - body.Position).Magnitude <= combat.CONTACT_DISTANCE then
			return body.Position, body.Ignore
		end
	end

	--[[ Returning ]]

	return nil, body.Ignore
end

return Module
