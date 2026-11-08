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

--- @class Bots_Server_Aim
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Setup ]]

	arcParams.CollisionGroup = "Projectile"
	arcParams.FilterType = Enum.RaycastFilterType.Exclude
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Arcs

--[[
	Returns the angles and powers that carry an arc weapon from a snail's middle through a point under a sideways wind
	acceleration, ignoring the terrain: for each share of power in POWER_STEPS fast enough to reach it, the low and the
	high arc, as a Vector2 of the angle (X) and the power (Y). Each is solved in the frame where the wind and gravity
	together point down, then corrected once for the muzzle, which sits along the aim.
]]
--- @return { Vector2 }
function Module.GetArcs(origin: Vector3, aimAt: Vector3, itemId: string, wind: number)
	--[[ Data ]]

	local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData

	--[[ Local Variables ]]

	local pull: Vector3 = Vector3.new(wind, -I.S.Workspace.Gravity, 0)
	local strength: number = pull.Magnitude
	local down: Vector3 = pull.Unit
	local across: Vector3 = Vector3.new(-down.Y, down.X, 0)
	local muzzle: number = I.Settings["Snails"].ROOT_SIZE / 2 + I.Settings["Combat"].MUZZLE_GAP
	local minSpeed: number = row.MinSpeed or 0
	local maxSpeed: number = row.MaxSpeed or 0
	local arcs = {} --- @type { Vector2 }

	--[[ Solving ]]

	for _index: number, power: number in ipairs(_settings.POWER_STEPS) do
		local speed: number = minSpeed + (maxSpeed - minSpeed) * power
		for _arc: number, sign: number in ipairs({ -1, 1 }) do
			local direction: Vector3? = Module._getDirection(aimAt - origin, speed, strength, down, across, sign)
			if direction then
				direction = Module._getDirection(aimAt - (origin + direction * muzzle), speed, strength, down, across, sign)
			end
			if direction then
				table.insert(arcs, Vector2.new(math.atan2(direction.Y, direction.X), power))
			end
		end
	end

	--[[ Returning ]]

	return arcs
end

--%%%%%%%%%%%%%%%%%%%% Get Contact

--[[
	Returns where an arc shot first touches terrain or a snail (its path's last point when it touches nothing), from a
	snail's middle at an angle and power, with a wind acceleration; the shooter's model is left out.
]]
--- @return Vector3
function Module.GetContact(origin: Vector3, angle: number, power: number, itemId: string, wind: number, shooter: Model)
	--[[ Local Variables ]]

	local direction: Vector3 = Vector3.new(math.cos(angle), math.sin(angle), 0)
	local muzzle: number = I.Settings["Snails"].ROOT_SIZE / 2 + I.Settings["Combat"].MUZZLE_GAP
	local velocity: Vector3 = I.G_Combat.GetLaunchVelocity(itemId, angle, power)
	local points = I.G_Combat.PredictArc(origin + direction * muzzle, velocity, wind, _settings.ARC_SECONDS, _settings.ARC_STEP) --- @type { Vector3 }
	arcParams.FilterDescendantsInstances = { shooter, I.Dirs.UmeWorkspace:FindFirstChild("Combat") }

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

--%%%%%%%%%%%%%%%%%%%% Get Shaken

--[[
	Returns an angle and power after a bot's hand: off by its skill's AimNoise and PowerNoise (a bell curve), narrowed
	by Ranging for each earlier shot at the same target from about the same spot, never under RangingMin.
]]
--- @param skill Bots_Skill
--- @return number
--- @return number
function Module.GetShaken(angle: number, power: number, skill, shots: number)
	--[[ Local Variables ]]

	local narrowing: number = math.max(skill.Ranging ^ shots, skill.RangingMin)

	--[[ Returning ]]

	local shakenAngle: number = angle + math.rad(skill.AimNoise) * narrowing * Module._getBell()
	local shakenPower: number = math.clamp(power + skill.PowerNoise * narrowing * Module._getBell(), 0, 1)
	return shakenAngle, shakenPower
end

--%%%%%%%%%%%%%%%%%%%% Is Solver Right

--[[
	A self-check of GetArcs: in open air, every arc it gives for a few points and winds passes within half a stud of
	its point. The gym runs it before training.
]]
--- @return boolean
function Module.IsSolverRight()
	--[[ Local Variables ]]

	local origin: Vector3 = Vector3.new(0, 1000, 0)
	local muzzle: number = I.Settings["Snails"].ROOT_SIZE / 2 + I.Settings["Combat"].MUZZLE_GAP

	--[[ Checking ]]

	for _index: number, offset: Vector3 in ipairs({
		Vector3.new(40, 0, 0),
		Vector3.new(-60, 15, 0),
		Vector3.new(25, -20, 0),
	}) do
		for _windIndex: number, wind: number in ipairs({ 0, 24, -30 }) do
			for _arcIndex: number, arc: Vector2 in ipairs(Module.GetArcs(origin, origin + offset, "Bazooka", wind)) do
				local direction: Vector3 = Vector3.new(math.cos(arc.X), math.sin(arc.X), 0)
				local velocity: Vector3 = I.G_Combat.GetLaunchVelocity("Bazooka", arc.X, arc.Y)
				local nearest: number = math.huge
				for _pointIndex: number, point: Vector3 in ipairs(I.G_Combat.PredictArc(origin + direction * muzzle, velocity, wind, 6, 1 / 600)) do
					nearest = math.min(nearest, (point - (origin + offset)).Magnitude)
				end
				if nearest > 0.5 then
					return false
				end
			end
		end
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Get Direction

--[[
	Returns the launch direction at a speed that passes through an offset under a pull of some strength along `down`
	(`across` is the level axis of that frame), on the low arc (sign -1) or the high one (1), or nil when the speed
	can't reach it.
]]
--- @return Vector3?
function Module._getDirection(offset: Vector3, speed: number, strength: number, down: Vector3, across: Vector3, sign: number)
	--[[ Local Variables ]]

	local x: number = offset:Dot(across)
	local y: number = -offset:Dot(down)
	local distance: number = math.abs(x)
	local root: number = speed ^ 4 - strength * (strength * distance * distance + 2 * y * speed * speed)

	--[[ Checks ]]

	-- Check if the speed reaches the point, and it isn't straight up or down
	if root < 0 or distance < 1e-3 then
		return nil
	end

	--[[ Returning ]]

	local elevation: number = math.atan((speed * speed + sign * math.sqrt(root)) / (strength * distance))
	return across * math.sign(x) * math.cos(elevation) - down * math.sin(elevation)
end

--%%%%%%%%%%%%%%%%%%%% Get Bell

--[[
	Returns a random number on a bell curve around 0 with a spread of 1 (Box-Muller).
]]
--- @return number
function Module._getBell()
	return math.sqrt(-2 * math.log(1 - random:NextNumber())) * math.cos(2 * math.pi * random:NextNumber())
end

return Module
