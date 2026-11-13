--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "SnailControl"

--- @type SnailControl_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--- @type SnailControl_ServerSettings
local _serverSettings = require(script:FindFirstAncestor(_localName):FindFirstChild("ServerSettings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Effects = require(script.Parent:FindFirstChild("Effects")) --- @type SnailControl_Server_Effects

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The snails their players move right now, by participant id
local controls = {} --- @type { [string]: SnailControl_Control }

-- Finds what a snail stands on or passes through: what its ball collides with (the terrain), as its client's checks do
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

--- @class SnailControl_Server_Control
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Setup ]]

	groundParams.CollisionGroup = "Snail"
	groundParams.RespectCanCollide = true

	--[[ Connections ]]

	I.S.RunService.Heartbeat:Connect(Module._check)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Start Turn

--[[
	**SERVER** |
	Lets a snail's player move it: their client gets its physics, its Stamina fills and CanMove turns on. Returns
	whether it started (a snail out of play, or a bot's, can't).
]]
--- @return boolean
function Module.StartTurn(participantId: string)
	--[[ Data ]]

	local model: Model? = I.Snails.Get(participantId)

	--[[ Checks ]]

	-- Check if the snail is in play
	if not model or not model:GetAttribute("Alive") then
		return false
	end

	--[[ Data ]]

	local player: Player? = I.S.Players:GetPlayerByUserId(model:GetAttribute("UserId"))

	--[[ Checks ]]

	-- Check if a player in this server moves it
	if not player then
		return false
	end

	--[[ Saving ]]

	local position: Vector3 = model.PrimaryPart.Position
	controls[participantId] = {
		Player = player,
		Last = position,
		Overdraft = 0,
		Good = position,
		GoodTime = os.clock(),
		Ground = position.Y,
		Lift = 0,
	}
	model:SetAttribute("Stamina", _settings.STAMINA_STUDS)
	model:SetAttribute("CanMove", true)

	--[[ Applying ]]

	I.Snails.SetOwner(participantId, player)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% End Turn

--[[
	**SERVER** |
	Takes a snail back from its player: CanMove turns off and the server owns its physics again, facing the way the
	player left it. Call it before anything hits the snail.
]]
function Module.EndTurn(participantId: string)
	--[[ Data ]]

	local model: Model? = I.Snails.Get(participantId)

	--[[ Saving ]]

	controls[participantId] = nil

	--[[ Checks ]]

	-- Check if the snail still exists
	if not model then
		return
	end

	--[[ Applying ]]

	model:SetAttribute("CanMove", false)
	Effects.ClearTurnEffects(participantId)

	-- Ghosts are anchored and owned by the server already
	if not model:GetAttribute("Alive") then
		return
	end

	local facing: number = if model.PrimaryPart.CFrame.LookVector.X < 0 then -1 else 1
	model.PrimaryPart:FindFirstChild("Upright").CFrame = CFrame.lookAlong(Vector3.zero, Vector3.new(facing, 0, 0))
	model:SetAttribute("Facing", facing)
	I.Snails.SetOwner(participantId, nil)
end

--%%%%%%%%%%%%%%%%%%%% Retreat

--[[
	**SERVER** |
	Lets a snail run from a weapon it just placed (Dynamite): its Stamina fills again and its player keeps moving it for
	a number of seconds, then the server takes it back. A bot's snail runs on its own (Bots).
]]
function Module.Retreat(participantId: string, seconds: number)
	--[[ Checks ]]

	-- Check if the snail is in play
	if not Module.Refill(participantId) then
		return
	end

	--[[ Ending ]]

	task.delay(seconds, Module.EndTurn, participantId)
end

--%%%%%%%%%%%%%%%%%%%% Refill

--[[
	**SERVER** |
	Fills a snail's Stamina bar again, forgiving what it overspent. Returns false when the snail isn't in play.
]]
--- @return boolean
function Module.Refill(participantId: string)
	--[[ Data ]]

	local model: Model? = I.Snails.Get(participantId)
	local control = controls[participantId] --- @type SnailControl_Control?

	--[[ Checks ]]

	-- Check if the snail is in play
	if not model or not model:GetAttribute("Alive") then
		return false
	end

	--[[ Saving ]]

	model:SetAttribute("Stamina", _settings.STAMINA_STUDS)
	if control then
		control.Overdraft = 0
		control.Last = model.PrimaryPart.Position
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Check

--[[
	Checks every snail its player moves, each frame.
]]
function Module._check()
	--[[ Checking ]]

	--- @param control SnailControl_Control
	for participantId: string, control in pairs(controls) do
		Module._checkSnail(participantId, control)
	end
end

--%%%%%%%%%%%%%%%%%%%% Check Snail

--[[
	Snaps a snail back where it last was and takes it from its player when it left the arena's plane, passed through
	the terrain, moved faster than walking or jumping allows, climbed higher than its jump and jetpack fuel reach, or walked more than
	STAMINA_GRACE past an empty Stamina bar.
]]
--- @param control SnailControl_Control
function Module._checkSnail(participantId: string, control)
	--[[ Data ]]

	local model: Model? = I.Snails.Get(participantId)

	--[[ Checks ]]

	-- Check if the snail is in play and its player still here
	if not model or not model:GetAttribute("Alive") or not control.Player.Parent then
		Module.EndTurn(participantId)
		return
	end

	--[[ Local Variables ]]

	local root: BasePart = model.PrimaryPart
	local position: Vector3 = root.Position
	local now: number = os.clock()
	local elapsed: number = now - control.GoodTime
	local sideways: number = math.abs(position.X - control.Good.X)
	local upwards: number = position.Y - control.Good.Y
	local speedMultiplier: number = model:GetAttribute("SpeedMultiplier") or 1

	--[[ Plane ]]

	-- Snap it back when it left the arena's plane, which only its client's copy of the Plane constraint holds it to
	if math.abs(position.Z - I.Arena.GetPlane().WorldPosition.Z) > _serverSettings.PLANE_SLACK then
		Module._snapBack(participantId, control, "left the arena's plane")
		return
	end

	--[[ Path ]]

	-- Snap it back when it went through the ground or a wall since the last frame (its ball keeps its middle off them)
	if I.S.Workspace:Raycast(control.Last, position - control.Last, groundParams) then
		Module._snapBack(participantId, control, "went through the terrain")
		return
	end

	--[[ Speed ]]

	-- Snap it back when it moved faster than its player could have made it
	-- Positions reach the server in bursts, so it always allows at least one interval's worth of movement
	local tolerance: number = _serverSettings.SPEED_TOLERANCE * math.max(elapsed, _serverSettings.CHECK_INTERVAL)
	if sideways > _settings.WALK_SPEED * speedMultiplier * tolerance + _serverSettings.MOVE_SLACK or upwards > _settings.JUMP_SPEED * tolerance + _serverSettings.MOVE_SLACK then
		Module._snapBack(participantId, control, "moved too fast")
		return
	end

	if elapsed >= _serverSettings.CHECK_INTERVAL then
		control.Good = position
		control.GoodTime = now
	end

	--[[ Height ]]

	-- Every stud it climbs above a jump's reach from the ground it last stood on is the jetpack's, at JETPACK_SPEED a second
	if Module._isGrounded(position) then
		control.Ground = position.Y
	end
	local reach: number = control.Ground + Module._getJumpHeight(model) + _serverSettings.MOVE_SLACK
	local from: number = math.max(control.Last.Y, reach)
	control.Lift += math.max(position.Y - from, 0)

	-- Snap it back when it climbed higher than its jetpack's fuel lifts it
	if control.Lift > _settings.JETPACK_SPEED * (model:GetAttribute("JetpackFuel") or 0) + _serverSettings.LIFT_GRACE then
		Module._snapBack(participantId, control, "flew higher than its jump and jetpack reach")
		return
	end

	--[[ Stamina ]]

	-- An empty bar only stops the walk on its client: the snail keeps its turn, and can still jump; speed stretches it
	local moved: number = math.abs(position.X - control.Last.X) / speedMultiplier
	local stamina: number = model:GetAttribute("Stamina")
	control.Last = position
	control.Overdraft += math.max(moved - stamina, 0)
	model:SetAttribute("Stamina", math.max(stamina - moved, 0))

	-- Snap it back when it kept going well past an empty bar
	if control.Overdraft > _serverSettings.STAMINA_GRACE then
		Module._snapBack(participantId, control, "walked past its stamina")
	end
end

--%%%%%%%%%%%%%%%%%%%% Snap Back

--[[
	Takes a snail from its player for breaking a check, and puts it back where it last was, at rest.
]]
--- @param control SnailControl_Control
function Module._snapBack(participantId: string, control, reason: string)
	--[[ Local Variables ]]

	local root: BasePart = I.Snails.Get(participantId).PrimaryPart

	--[[ Applying ]]

	warn(`[{_localName}::{script.Name}]: Snail ({participantId}) {reason} - snapped back.`)
	Module.EndTurn(participantId)
	root.AssemblyLinearVelocity = Vector3.zero
	root.CFrame = CFrame.new(control.Good) * root.CFrame.Rotation
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Jump Height

--[[
	Returns how high a snail's jump carries it, in studs: higher under the Low gravity potion, whose Lift holds up part of
	its weight (every snail's Lift holds up some: Snails' GRAVITY_SCALE).
]]
--- @return number
function Module._getJumpHeight(model: Model)
	--[[ Local Variables ]]

	local root: BasePart = model.PrimaryPart
	local lift: VectorForce = root:FindFirstChild("Lift")
	local gravity: number = I.S.Workspace.Gravity - lift.Force.Y / root:GetMass()

	--[[ Returning ]]

	return _settings.JUMP_SPEED ^ 2 / (2 * gravity)
end

--%%%%%%%%%%%%%%%%%%%% Is Grounded

--[[
	Returns whether a snail whose ball is centered at a position stands on the terrain, as its client's own check finds.
]]
--- @return boolean
function Module._isGrounded(position: Vector3)
	--[[ Local Variables ]]

	-- A slightly smaller sphere, cast down, finds ground under any part of the ball
	local shrink: number = 0.15
	local radius: number = I.Settings["Snails"].ROOT_SIZE / 2 - shrink

	--[[ Returning ]]

	return I.S.Workspace:Spherecast(position, radius, Vector3.new(0, -(shrink + I.Settings["Snails"].GROUND_GAP), 0), groundParams) ~= nil
end

return Module
