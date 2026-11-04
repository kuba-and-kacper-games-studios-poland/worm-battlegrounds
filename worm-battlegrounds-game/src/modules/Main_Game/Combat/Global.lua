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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.G_Combat = {

		--[[ Methods ]]

		GetLaunchVelocity = Module.GetLaunchVelocity,
		GetWindAcceleration = Module.GetWindAcceleration,
		PredictArc = Module.PredictArc,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Launch Velocity

--[[
	Returns the velocity a weapon leaves the worm at: along the angle (radians, 0 is right, counterclockwise), from
	MinSpeed at power 0 to MaxSpeed at power 1.
]]
--- @return Vector3
function Module.GetLaunchVelocity(itemId: string, angle: number, power: number)
	--[[ Data ]]

	local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData

	--[[ Returning ]]

	local speed: number = (row.MinSpeed or 0) + ((row.MaxSpeed or 0) - (row.MinSpeed or 0)) * math.clamp(power, 0, 1)
	return Vector3.new(math.cos(angle), math.sin(angle), 0) * speed
end

--%%%%%%%%%%%%%%%%%%%% Get Wind Acceleration

--[[
	Returns how hard the wind pushes a weapon along X, in studs per second squared: nothing for weapons the wind
	doesn't touch.
]]
--- @return number
function Module.GetWindAcceleration(itemId: string, wind: number)
	--[[ Data ]]

	local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData

	--[[ Returning ]]

	return if row.Wind then wind * _settings.WIND_ACCEL else 0
end

--%%%%%%%%%%%%%%%%%%%% Predict Arc

--[[
	Returns the points a shot passes through, every step seconds for the given time, under gravity and a sideways wind
	acceleration. The aim line, bots and the server share it, so they agree.
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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
