--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--- @type Combat_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

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

--- @class Combat_Server_Arcs
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Arcs

--[[
	Returns the angles and powers that carry an arc weapon from a snail's middle through a point under a sideways wind
	acceleration, ignoring the terrain: for each share of power in `powers` fast enough to reach it, the low and the
	high arc, as a Vector2 of the angle (X) and the power (Y). Each is solved in the frame where the wind and gravity
	together point down, then corrected once for the muzzle, which sits along the aim. Bots and the aim guide use it.
]]
--- @param powers { number }
--- @return { Vector2 }
function Module.GetArcs(origin: Vector3, aimAt: Vector3, itemId: string, windAcceleration: number, powers)
	--[[ Data ]]

	local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData

	--[[ Local Variables ]]

	local pull: Vector3 = Vector3.new(windAcceleration, -I.S.Workspace.Gravity, 0)
	local strength: number = pull.Magnitude
	local down: Vector3 = pull.Unit
	local across: Vector3 = Vector3.new(-down.Y, down.X, 0)
	local muzzle: number = I.Settings["Snails"].ROOT_SIZE / 2 + _settings.MUZZLE_GAP
	local minSpeed: number = row.MinSpeed or 0
	local maxSpeed: number = row.MaxSpeed or 0
	local arcs = {} --- @type { Vector2 }

	--[[ Solving ]]

	for _index: number, power: number in ipairs(powers) do
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

--%%%%%%%%%%%%%%%%%%%% Predict Arc

--[[
	Returns the points a shot passes through, every step seconds for the given time, under gravity and a sideways wind
	acceleration. Bots and the aim guide use it.
]]
--- @return { Vector3 }
function Module.PredictArc(origin: Vector3, velocity: Vector3, windAcceleration: number, seconds: number, step: number?)
	--[[ Local Variables ]]

	local interval: number = step or 1 / 30
	local acceleration: Vector3 = Vector3.new(windAcceleration, -I.S.Workspace.Gravity, 0)
	local points = {} --- @type { Vector3 }

	--[[ Calculating ]]

	for time: number = 0, seconds, interval do
		table.insert(points, origin + velocity * time + acceleration * (0.5 * time * time))
	end

	--[[ Returning ]]

	return points
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

return Module
