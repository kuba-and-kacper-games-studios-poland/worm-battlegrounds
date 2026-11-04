--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Worms"

--- @type Worms_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Bodies = require(script.Parent:FindFirstChild("Bodies")) --- @type Worms_Server_Bodies
local Health = require(script.Parent:FindFirstChild("Health")) --- @type Worms_Server_Health

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Each worm's position last frame, and the highest point of its fall while airborne; weak, so removed worms go
local lastPositions = setmetatable({}, { __mode = "k" }) --- @type { [Model]: Vector3 }
local peaks = setmetatable({}, { __mode = "k" }) --- @type { [Model]: number }

-- Casts that hit only what worms stand on
--- @type RaycastParams
local groundParams = RaycastParams.new()

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

--- @class Worms_Server_Hazards
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Setup ]]

	groundParams.CollisionGroup = "Worm"

	--[[ Connections ]]

	I.S.RunService.Heartbeat:Connect(Module._check)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Check

--[[
	Checks every worm still in play each frame: knocks out the ones in liquid or out of bounds, and charges a fall's
	damage when a worm lands.
]]
function Module._check()
	--[[ Checking ]]

	for _index: number, model: Model in ipairs(Bodies.GetAlive()) do
		Module._checkWorm(model)
	end
end

--%%%%%%%%%%%%%%%%%%%% Check Worm

--[[
	Knocks one worm out when it's in a hazard, or passed through one since last frame; otherwise follows its fall
	and charges 1 health per stud above SAFE_FALL_HEIGHT when it lands, MAX_FALL_DAMAGE at most.
]]
function Module._checkWorm(model: Model)
	--[[ Local Variables ]]

	local position: Vector3 = model.PrimaryPart.Position
	local hazard: string? = Module._getHazardOnPath(lastPositions[model] or position, position)
	lastPositions[model] = position

	--[[ Hazards ]]

	if hazard then
		Health.Kill(model.Name, hazard)
		return
	end

	--[[ Falling ]]

	-- An open parachute cancels the fall's damage
	if model:GetAttribute("Parachute") then
		peaks[model] = nil
		return
	end

	if not Module.IsGrounded(position) then
		peaks[model] = math.max(peaks[model] or position.Y, position.Y)
		return
	end

	--[[ Landing ]]

	local peak: number? = peaks[model]
	peaks[model] = nil
	if peak then
		local damage: number = math.min(math.floor(peak - position.Y - _settings.SAFE_FALL_HEIGHT), _settings.MAX_FALL_DAMAGE)
		Health.Damage(model.Name, damage)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Hazard On Path

--[[
	Returns the first hazard along the way from one position to another, checked every liquid cell, so a fast fall
	(or a player's worm the server sees only now and then) can't skip through water.
]]
--- @return string?
function Module._getHazardOnPath(from: Vector3, to: Vector3)
	--[[ Local Variables ]]

	local steps: number = math.max(math.ceil((to - from).Magnitude / I.Settings["Arena"].LIQUID_CELL), 1)

	--[[ Checking ]]

	for step: number = 1, steps do
		local hazard: string? = I.Arena.GetHazard(from:Lerp(to, step / steps))
		if hazard then
			return hazard
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Is Grounded

--[[
	Returns whether a worm whose ball is centered at a position stands on something, on flat ground or a slope.
]]
--- @return boolean
function Module.IsGrounded(position: Vector3)
	--[[ Local Variables ]]

	-- A slightly smaller sphere, cast down, finds ground under any part of the ball
	local shrink: number = 0.15
	local radius: number = _settings.ROOT_SIZE / 2 - shrink

	--[[ Returning ]]

	return I.S.Workspace:Spherecast(position, radius, Vector3.new(0, -(shrink + _settings.GROUND_GAP), 0), groundParams) ~= nil
end

return Module
