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

--%%%%%%%%%%%%%%%%%%%% Get Contact

--[[
	Returns where an arc shot first touches terrain or a snail (its path's last point when it touches nothing), from a
	snail's middle at an angle and power, with a wind acceleration; the shooter's model is left out.
]]
--- @return Vector3
function Module.GetContact(origin: Vector3, angle: number, power: number, itemId: string, wind: number, shooter: Model)
	--[[ Local Variables ]]

	local direction: Vector3 = Vector3.new(math.cos(angle), math.sin(angle), 0)
	local velocity: Vector3 = I.G_Combat.GetLaunchVelocity(itemId, angle, power)
	local points = I.Combat.PredictArc(I.Combat.GetShotStart(origin, direction, shooter), velocity, wind, _settings.ARC_SECONDS, _settings.ARC_STEP) --- @type { Vector3 }
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
	A self-check of Combat's GetArcs: in open air, every arc it gives for a few points and winds passes within half a stud of
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
			for _arcIndex: number, arc: Vector2 in ipairs(I.Combat.GetArcs(origin, origin + offset, "Bazooka", wind, _settings.POWER_STEPS)) do
				local direction: Vector3 = Vector3.new(math.cos(arc.X), math.sin(arc.X), 0)
				local velocity: Vector3 = I.G_Combat.GetLaunchVelocity("Bazooka", arc.X, arc.Y)
				local nearest: number = math.huge
				for _pointIndex: number, point: Vector3 in ipairs(I.Combat.PredictArc(origin + direction * muzzle, velocity, wind, 6, 1 / 600)) do
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

--%%%%%%%%%%%%%%%%%%%% Get Bell

--[[
	Returns a random number on a bell curve around 0 with a spread of 1 (Box-Muller).
]]
--- @return number
function Module._getBell()
	return math.sqrt(-2 * math.log(1 - random:NextNumber())) * math.cos(2 * math.pi * random:NextNumber())
end

return Module
