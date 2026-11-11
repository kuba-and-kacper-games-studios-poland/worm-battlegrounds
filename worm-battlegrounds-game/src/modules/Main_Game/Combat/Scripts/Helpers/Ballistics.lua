--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--- @type Combat_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[
	The shot's own time in one fixed step of the simulation, in seconds: a real step (PROJECTILE_STEP) slowed by
	PROJECTILE_TIME_SCALE, so shots fly their usual paths slower. The server and every client step a shot the same way
]]
local STEP: number = _settings.PROJECTILE_STEP * _settings.PROJECTILE_TIME_SCALE

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

--- @class Combat_Ballistics
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% New

--[[
	Returns a new shot body on the arena's plane at a position, moving at a velocity, at step 0: a tumbling one already
	turning the way it's thrown.
]]
--- @param options Combat_ShotOptions
--- @return Combat_Body
function Module.New(position: Vector3, velocity: Vector3, options)
	--[[ Returning ]]

	--- @type Combat_Body
	local body = {
		Id = 0,
		Kind = "",
		Name = "",
		Start = 0,
		Options = options,
		Step = 0,
		Position = Vector3.new(position.X, position.Y, 0),
		Velocity = Vector3.new(velocity.X, velocity.Y, 0),
		Angle = 0,
		Spin = if options.Tumble then math.clamp(-velocity.X * _settings.AIR_SPIN, -_settings.AIR_SPIN_MAX, _settings.AIR_SPIN_MAX) else 0,
		Grounded = false,
		Stopped = false,
		Sunk = false,
		SunkStep = 0,
		Ignore = {},
	}
	return body
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Moves a body one fixed step: gravity and wind (or homing), sinking in liquid, and its contacts with the terrain and
	snails. A body without Bounce stops on the first thing it touches; one with Bounce bounces off it, keeping
	BOUNCE_FRICTION of its speed along the surface, and rests and rolls when it hits softer than REST_SPEED. Returns the
	last thing it touched this step.
]]
--- @param body Combat_Body
--- @param world Combat_World
--- @return RaycastResult?
function Module.Step(body, world)
	--[[ Local Variables ]]

	local options = body.Options --- @type Combat_ShotOptions
	local wasGrounded: boolean = body.Grounded
	local gravity: number = I.S.Workspace.Gravity * (options.GravityScale or 1)
	local acceleration: Vector3 = Vector3.new(options.Wind or 0, -gravity, 0)
	local result: RaycastResult? = nil
	body.Step += 1
	body.Grounded = false

	--[[ Checks ]]

	-- Check if it's still moving
	if body.Stopped then
		return nil
	end

	--[[ Steering ]]

	-- A homing shot locks on: no more gravity or wind, straight at its target
	if options.Target and body.Step >= (options.LockStep or 0) then
		local toTarget: Vector3 = options.Target - body.Position
		acceleration = Vector3.zero
		if toTarget.Magnitude > 1e-3 then
			body.Velocity = toTarget.Unit * (options.HomingSpeed or 60)
		end
	end

	-- A rolling shot drives itself along at a steady speed, on the ground and over bumps
	if options.Drive then
		body.Velocity = Vector3.new(options.Drive, body.Velocity.Y, 0)
	end

	--[[ Sinking ]]

	-- Liquid slows a shot as it splashes in, then drags it along while it's under; it keeps flying through
	local inLiquid: boolean = world.IsLiquid(body.Position)
	if inLiquid and not body.Sunk then
		body.SunkStep = body.Step
		body.Velocity *= _settings.SINK_ENTRY_KEEP
	end
	body.Sunk = inLiquid
	if body.Sunk then
		acceleration = Vector3.new(0, -gravity * _settings.SINK_GRAVITY, 0)
		body.Velocity *= _settings.SINK_KEEP ^ STEP
	end

	--[[ Moving ]]

	local exclude = table.clone(world.Exclude) --- @type { Instance }
	if options.Shooter and body.Step <= (options.GraceSteps or 0) then
		table.insert(exclude, options.Shooter)
	end
	for _index: number, instance: Instance in ipairs(body.Ignore) do
		table.insert(exclude, instance)
	end
	world.Params.FilterDescendantsInstances = exclude

	local remaining: number = STEP
	local groundNormal: Vector3? = nil
	for _contact: number = 1, _settings.PROJECTILE_MAX_CONTACTS do
		--[[ Casting ]]

		-- Exact for a constant acceleration, so a shot flies the arc the aim and the bots predict
		local move: Vector3 = body.Velocity * remaining + acceleration * (0.5 * remaining * remaining)
		local touches: boolean = move.Magnitude > 1e-5 and body.Step > (options.GhostSteps or 0)
		local hit: RaycastResult? = if touches then I.S.Workspace:Spherecast(body.Position, options.Radius, move, world.Params) else nil

		if not hit then
			body.Position += move
			body.Velocity += acceleration * remaining
			break
		end

		--[[ Touching ]]

		local time: number = remaining * hit.Distance / move.Magnitude
		body.Position += move.Unit * hit.Distance
		body.Velocity += acceleration * time
		remaining -= time
		result = hit

		-- A piercing shot passes through every snail
		local snail: Model? = Module.GetSnail(hit)
		if snail and options.Pierce then
			table.insert(body.Ignore, snail)
			table.insert(exclude, snail)
			world.Params.FilterDescendantsInstances = exclude
			continue
		end

		-- One that bursts on contact stops where it touched
		if not options.Bounce then
			body.Stopped = true
			body.Velocity = Vector3.zero
			break
		end

		--[[ Bouncing ]]

		local normal: Vector3 = Vector3.new(hit.Normal.X, hit.Normal.Y, 0)
		normal = if normal.Magnitude > 1e-3 then normal.Unit else -move.Unit
		local into: number = body.Velocity:Dot(normal)
		if into < 0 then
			local along: Vector3 = body.Velocity - normal * into
			if -into > _settings.REST_SPEED and not body.Sunk then
				body.Velocity = along * _settings.BOUNCE_FRICTION - normal * into * options.Bounce
			else
				body.Velocity = along
				groundNormal = normal
			end
		end
		body.Position += normal * _settings.PROJECTILE_SKIN

		-- A rolling shot on the ground hops over a bump in its way (only from the ground, so it can't climb a wall)
		if options.HopSpeed and options.Drive and wasGrounded and math.abs(normal.X) > 0.7 and normal.X * options.Drive < 0 then
			body.Velocity = Vector3.new(body.Velocity.X, options.HopSpeed, 0)
		end
	end

	--[[ Rolling ]]

	if groundNormal and groundNormal.Y > 0 then
		body.Grounded = true
		local speed: number = body.Velocity.Magnitude
		local slowed: number = math.max(speed - _settings.ROLL_DRAG * STEP, 0)
		body.Velocity = if slowed < _settings.STOP_SPEED and groundNormal.Y >= _settings.REST_NORMAL_Y and not options.Drive then Vector3.zero elseif speed > 0 then body.Velocity * (slowed / speed) else Vector3.zero

		-- Rolls without slipping: turns as fast as it moves along the ground
		local tangent: Vector3 = Vector3.new(groundNormal.Y, -groundNormal.X, 0)
		body.Spin = -body.Velocity:Dot(tangent) / options.Radius
	end
	body.Angle += body.Spin * STEP

	--[[ Returning ]]

	return result
end

--%%%%%%%%%%%%%%%%%%%% Load

--[[
	Puts a body back in a state saved from it (or sent by the server).
]]
--- @param body Combat_Body
--- @param state Combat_BodyState
function Module.Load(body, state)
	--[[ Applying ]]

	body.Step = state.Step
	body.Position = state.Position
	body.Velocity = state.Velocity
	body.Angle = state.Angle
	body.Spin = state.Spin
	body.Grounded = state.Grounded
	body.Stopped = state.Stopped
	body.Sunk = state.Sunk
	while #body.Ignore > state.IgnoreCount do
		table.remove(body.Ignore)
	end
end

--%%%%%%%%%%%%%%%%%%%% Make Part

--[[
	Returns a new projectile part at a position, not yet parented: a placeholder neon ball in its kind's colour, which
	clients draw the weapon's model on and the match camera follows (its Projectile attribute).
]]
--- @return Part
function Module.MakePart(kind: string, name: string, position: Vector3)
	--[[ Building ]]

	local part: Part = I.Create("Part")({
		Name = name,
		Shape = Enum.PartType.Ball,
		Size = Vector3.one * _settings.PROJECTILE_SIZE,
		CFrame = CFrame.new(position),
		Color = _settings.PROJECTILE_COLORS[kind] or Color3.new(1, 1, 1),
		Material = Enum.Material.Neon,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		CollisionGroup = "Projectile",
	})
	part:SetAttribute("Projectile", true)

	--[[ Returning ]]

	return part
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get CFrame

--[[
	Returns where a body is drawn: its position, turned by its spin around Z.
]]
--- @param body Combat_Body
--- @return CFrame
function Module.GetCFrame(body)
	return CFrame.new(body.Position) * CFrame.Angles(0, 0, body.Angle)
end

--%%%%%%%%%%%%%%%%%%%% Get State

--[[
	Returns a copy of a body's moving state, to put it back later (Load) or send it.
]]
--- @param body Combat_Body
--- @return Combat_BodyState
function Module.GetState(body)
	--- @type Combat_BodyState
	local state = {
		Step = body.Step,
		Position = body.Position,
		Velocity = body.Velocity,
		Angle = body.Angle,
		Spin = body.Spin,
		Grounded = body.Grounded,
		Stopped = body.Stopped,
		Sunk = body.Sunk,
		IgnoreCount = #body.Ignore,
	}
	return state
end

--%%%%%%%%%%%%%%%%%%%% Get Snail

--[[
	Returns the snail a cast hit, or nil when it hit something else.
]]
--- @return Model?
function Module.GetSnail(result: RaycastResult?)
	--[[ Local Variables ]]

	local model: Model? = if result then result.Instance:FindFirstAncestorOfClass("Model") else nil

	--[[ Returning ]]

	return if model and model.Parent and model.Parent.Name == "Snails" then model else nil
end

return Module
