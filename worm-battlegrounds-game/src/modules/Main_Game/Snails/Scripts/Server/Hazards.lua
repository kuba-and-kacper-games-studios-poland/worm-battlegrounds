--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Snails"

--- @type Snails_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Bodies = require(script.Parent:FindFirstChild("Bodies")) --- @type Snails_Server_Bodies
local Health = require(script.Parent:FindFirstChild("Health")) --- @type Snails_Server_Health

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Each snail's position last frame, and the highest point of its fall while airborne; weak, so removed snails go
local lastPositions = setmetatable({}, { __mode = "k" }) --- @type { [Model]: Vector3 }
local peaks = setmetatable({}, { __mode = "k" }) --- @type { [Model]: number }

-- The snails that touched lava and haven't left it since: one burn per dip, so a snail left in a pool can walk out
local dipped = setmetatable({}, { __mode = "k" }) --- @type { [Model]: boolean }

-- Casts that hit only what snails stand on
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

--- @class Snails_Server_Hazards
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Setup ]]

	groundParams.CollisionGroup = "Snail"

	--[[ Connections ]]

	I.S.RunService.Heartbeat:Connect(Module._check)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Check

--[[
	Checks every snail still in play each frame: knocks out the ones in the open sea or out of bounds, sets the ones
	touching other lava burning, and charges a fall's damage when a snail lands.
]]
function Module._check()
	--[[ Checking ]]

	for _index: number, model: Model in ipairs(Bodies.GetAlive()) do
		Module._checkSnail(model)
	end
end

--%%%%%%%%%%%%%%%%%%%% Check Snail

--[[
	Knocks one snail out when it's in a hazard, or passed through one since last frame; otherwise sets it burning when
	it dips into lava (once a dip, while not already burning), and follows its fall from where it last rose and charges 1 health per stud above SAFE_FALL_HEIGHT
	when it lands, MAX_FALL_DAMAGE at most.
]]
function Module._checkSnail(model: Model)
	--[[ Local Variables ]]

	local position: Vector3 = model.PrimaryPart.Position
	local previous: Vector3 = lastPositions[model] or position
	local hazard: string? = Module._getHazardOnPath(previous, position)
	lastPositions[model] = position

	--[[ Hazards ]]

	if hazard then
		Health.Kill(model.Name, hazard)
		return
	end

	--[[ Burning ]]

	if not I.Arena.IsInLava(position, _settings.ROOT_SIZE / 2) then
		dipped[model] = nil
	elseif not dipped[model] then
		dipped[model] = true
		if not model:GetAttribute("Burning") then
			task.spawn(Module._burn, model)
		end
	end

	--[[ Falling ]]

	-- An open parachute cancels the fall's damage
	if model:GetAttribute("Parachute") then
		peaks[model] = nil
		return
	end

	-- Rising starts the fall over (a jump's top, or where a jetpack last held it up), so only the last drop counts
	if not Module.IsGrounded(position) then
		peaks[model] = if position.Y > previous.Y then position.Y else math.max(peaks[model] or position.Y, position.Y)
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

--%%%%%%%%%%%%%%%%%%%% Burn

--[[
	Sets a snail Burning, then takes BURN_DAMAGE health BURN_TICKS times, BURN_DELAY seconds after it touched lava and
	every BURN_INTERVAL seconds from then (the first ends its turn, as any hurt does), while it's in play.
]]
function Module._burn(model: Model)
	--[[ Starting ]]

	model:SetAttribute("Burning", true)
	task.wait(_settings.BURN_DELAY)

	--[[ Hurting ]]

	for tick: number = 1, _settings.BURN_TICKS do
		if not model.Parent or not model:GetAttribute("Alive") then
			break
		end
		Health.Damage(model.Name, _settings.BURN_DAMAGE)
		if tick < _settings.BURN_TICKS then
			task.wait(_settings.BURN_INTERVAL)
		end
	end

	--[[ Ending ]]

	if model.Parent then
		model:SetAttribute("Burning", nil)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Hazard On Path

--[[
	Returns the first hazard along the way from one position to another, checked every liquid cell, so a fast fall
	(or a player's snail the server sees only now and then) can't skip through water.
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
	Returns whether a snail whose ball is centered at a position stands on something, on flat ground or a slope.
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
