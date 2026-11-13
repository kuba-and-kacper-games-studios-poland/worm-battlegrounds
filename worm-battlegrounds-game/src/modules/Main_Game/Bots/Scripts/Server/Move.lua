--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Bots"

--- @type Bots_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("ServerSettings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Casts that hit only what snails stand on (the terrain), as SnailControl's do
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

--- @class Bots_Server_Move
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Setup ]]

	groundParams.CollisionGroup = "Snail"
	groundParams.RespectCanCollide = true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Walk To

--[[
	Walks a bot's snail along the plane toward an X as a player would, with SnailControl's speeds: up low ledges, jumping
	walls its jump clears (WALL_JUMPS times at most), flying its jetpack (JetpackFuel) over cliffs and gaps, and at
	`climbTo` (a height) when given: straight up to it first with `riseFirst`, as a flight's route is planned (GetCruise),
	or on the way. It never thrusts into a ceiling (HEADROOM), spends its Stamina, and writes back the fuel it has left.
	Stops at the X, when the stamina runs out, `seconds` pass or `keepGoing` says no, when it stops getting closer, at
	a cliff it can't fly over, and at an edge it would fall off into the sea or too far (unless its jetpack carries it).
	Returns how far it moved along X.
]]
--- @param keepGoing () -> boolean
--- @return number
function Module.WalkTo(model: Model, targetX: number, seconds: number, climbTo: number?, keepGoing, riseFirst: boolean?)
	--[[ Local Variables ]]

	local control = I.Settings["SnailControl"] --- @type SnailControl_Settings
	local root: BasePart = model.PrimaryPart
	local walk: LinearVelocity = root:FindFirstChild("Walk")
	local rest: PhysicalProperties = root.CustomPhysicalProperties
	local startX: number = root.Position.X
	local deadline: number = os.clock() + seconds
	local fuel: number = model:GetAttribute("JetpackFuel") or 0
	local closest: number = math.abs(targetX - startX)
	local stuckSince: number = os.clock()
	local wallJumps: number = 0
	local rising: boolean = climbTo ~= nil and riseFirst == true

	--[[ Walking ]]

	-- No grip while walking, as a player's snail, so it slides up slopes instead of sticking to them
	root.CustomPhysicalProperties = PhysicalProperties.new(rest.Density, 0, rest.Elasticity, 100, rest.ElasticityWeight)

	while os.clock() < deadline and keepGoing() and model.Parent and model:GetAttribute("Alive") do
		local position: Vector3 = root.Position
		local offset: number = targetX - position.X
		local stamina: number = model:GetAttribute("Stamina") or 0
		local headroom: boolean = Module._hasHeadroom(position)

		-- First straight up to its cruise height, until there, under a ceiling or out of fuel
		if rising and (climbTo and position.Y >= climbTo - 0.5 or not headroom or fuel <= 0) then
			rising = false
		end
		if not rising and math.abs(offset) <= _settings.ARRIVE_DISTANCE or stamina <= 0 then
			break
		end

		local side: number = if offset < 0 then -1 else 1
		local grounded: boolean = I.Snails.IsGrounded(model.Name)
		local velocity: Vector3 = root.AssemblyLinearVelocity
		local thrust: boolean = rising

		-- An edge ahead it can't walk off: fly over it with fuel, else stop there
		if not rising and grounded and not Module._isSafeStep(position, side) then
			if fuel <= 0 then
				break
			end
			thrust = true
		end

		-- A wall: walk up a ledge, jump one its jump clears, fly over the rest; with no fuel, give up on a cliff
		local wall: string? = if rising then nil else Module._getWall(position, side)
		if wall == "Ledge" then
			root.AssemblyLinearVelocity = Vector3.new(velocity.X, math.max(velocity.Y, control.STEP_SPEED), 0)
		elseif wall and grounded and fuel <= 0 and (wall == "Cliff" or wallJumps >= _settings.WALL_JUMPS) then
			break
		elseif wall == "Wall" and grounded then
			wallJumps += 1
			root.AssemblyLinearVelocity = Vector3.new(velocity.X, control.JUMP_SPEED, 0)
		elseif wall and velocity.Y < 1 then
			thrust = true
		end

		-- Over a gap keep up, and hold its cruise height until it's nearly there
		local falling: boolean = not grounded and velocity.Y < 0
		if falling and (not Module._isSafeStep(position, 0) or climbTo and position.Y < climbTo and math.abs(offset) > _settings.MOVE_STEP) then
			thrust = true
		end

		if thrust and fuel > 0 and headroom then
			velocity = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.new(velocity.X, math.max(velocity.Y, control.JETPACK_SPEED), 0)
		elseif not headroom and root.AssemblyLinearVelocity.Y > 0 then
			-- Under a ceiling: stop rising instead of bumping into it
			velocity = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.new(velocity.X, 0, 0)
		end

		walk.LineVelocity = if rising then 0 else side * control.WALK_SPEED * (model:GetAttribute("SpeedMultiplier") or 1)
		walk.Enabled = not rising
		root:FindFirstChild("Upright").CFrame = CFrame.lookAlong(Vector3.zero, Vector3.xAxis * side)
		model:SetAttribute("Facing", side)

		local deltaTime: number = I.S.RunService.Heartbeat:Wait()
		if thrust and fuel > 0 and headroom then
			fuel = math.max(fuel - deltaTime, 0)
		end

		-- Stamina goes as a player's does, by the distance walked
		local moved: number = math.abs(root.Position.X - position.X) / (model:GetAttribute("SpeedMultiplier") or 1)
		model:SetAttribute("Stamina", math.max(stamina - moved, 0))

		-- Give up once it stops getting closer (rising doesn't count)
		local left: number = math.abs(targetX - root.Position.X)
		if left < closest - _settings.STUCK_DISTANCE or rising then
			closest = math.min(left, closest)
			stuckSince = os.clock()
		elseif os.clock() - stuckSince >= _settings.STUCK_SECONDS then
			break
		end
	end

	--[[ Stopping ]]

	walk.Enabled = false
	if model.Parent then
		root.CustomPhysicalProperties = rest
	end
	if model:GetAttribute("JetpackFuel") ~= nil then
		model:SetAttribute("JetpackFuel", fuel)
	end

	--[[ Returning ]]

	return root.Position.X - startX
end

--%%%%%%%%%%%%%%%%%%%% Hover

--[[
	Holds a bot's snail in the air at a height on its jetpack while `keepGoing` says so, as a player taps the jump key
	to stay up and shoot: a short push up whenever it sinks below, never into a ceiling, while the fuel lasts. Writes
	back the fuel it has left.
]]
--- @param keepGoing () -> boolean
function Module.Hover(model: Model, height: number, keepGoing)
	--[[ Local Variables ]]

	local root: BasePart = model.PrimaryPart
	local push: number = I.Settings["SnailControl"].JETPACK_SPEED * 0.4
	local fuel: number = model:GetAttribute("JetpackFuel") or 0

	--[[ Hovering ]]

	while keepGoing() and model.Parent and model:GetAttribute("Alive") and fuel > 0 do
		local velocity: Vector3 = root.AssemblyLinearVelocity
		local thrust: boolean = root.Position.Y < height and velocity.Y <= 0 and Module._hasHeadroom(root.Position)
		if thrust then
			root.AssemblyLinearVelocity = Vector3.new(0, math.max(velocity.Y, push), 0)
		end
		local deltaTime: number = I.S.RunService.Heartbeat:Wait()
		if thrust then
			fuel = math.max(fuel - deltaTime, 0)
		end
	end

	--[[ Saving ]]

	if model.Parent and model:GetAttribute("JetpackFuel") ~= nil then
		model:SetAttribute("JetpackFuel", fuel)
	end
end

--%%%%%%%%%%%%%%%%%%%% Hop

--[[
	A small jump on the spot when the bot's snail stands on the ground, as players fidget before they shoot.
]]
function Module.Hop(model: Model)
	--[[ Checks ]]

	-- Check if it stands on something
	if not I.Snails.IsGrounded(model.Name) then
		return
	end

	--[[ Jumping ]]

	local root: BasePart = model.PrimaryPart
	root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, I.Settings["SnailControl"].JUMP_SPEED * 0.6, 0)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Ground

--[[
	Returns where a snail's ball would stand at an X, on the highest ground no more than `above` studs over a height
	(its middle, ROOT_SIZE / 2 over the ground), or nil when there's no ground within FALL_LOOK below, the ground is in
	the sea, or the drop from that height is far enough to hurt (Snails' SAFE_FALL_HEIGHT). Whether the way there is
	open is CanStep's to say.
]]
--- @return Vector3?
function Module.GetGround(x: number, height: number, above: number)
	--[[ Local Variables ]]

	local radius: number = I.Settings["Snails"].ROOT_SIZE / 2
	local from: Vector3 = Vector3.new(x, height + above, 0)
	local result: RaycastResult? = I.S.Workspace:Raycast(from, Vector3.yAxis * -(above + _settings.FALL_LOOK), groundParams)

	--[[ Checks ]]

	-- Check if there's ground to stand on, out of the sea
	if not result or I.Arena.GetHazard(result.Position + Vector3.yAxis * radius) then
		return nil
	end

	-- Check if getting down there doesn't hurt
	local spot: Vector3 = result.Position + Vector3.yAxis * radius
	if height - spot.Y > I.Settings["Snails"].SAFE_FALL_HEIGHT then
		return nil
	end

	--[[ Returning ]]

	return spot
end

--%%%%%%%%%%%%%%%%%%%% Get Runway

--[[
	Returns how far a snail can walk from a position toward a side, a stud at a time over ground its jump reaches and it
	can safely step down to (GetGround), with the way open (CanStep), up to `max` studs.
]]
--- @return number
function Module.GetRunway(position: Vector3, side: number, max: number)
	--[[ Local Variables ]]

	local jump: number = Module.GetJump()
	local last: Vector3 = position

	--[[ Walking ]]

	for step: number = 1, max do
		local spot: Vector3? = Module.GetGround(position.X + side * step, last.Y, jump)
		if not spot or not Module.CanStep(last, spot) then
			return step - 1
		end
		last = spot
	end

	--[[ Returning ]]

	return max
end

--%%%%%%%%%%%%%%%%%%%% Get Jump

--[[
	Returns how high a snail's jump carries it, in studs.
]]
--- @return number
function Module.GetJump()
	return I.Settings["SnailControl"].JUMP_SPEED ^ 2 / (2 * I.S.Workspace.Gravity * I.Settings["Snails"].GRAVITY_SCALE)
end

--%%%%%%%%%%%%%%%%%%%% Get Cruise

--[[
	Returns the height a jetpack flight from a position goes at: CLIMB_MAX studs up, or as high as a ceiling leaves room
	for (HEADROOM). The flight goes straight up to it, along at it (CanFly), then down (GetLanding).
]]
--- @return number
function Module.GetCruise(position: Vector3)
	--[[ Local Variables ]]

	local radius: number = I.Settings["Snails"].ROOT_SIZE / 2
	local ceiling: RaycastResult? = I.S.Workspace:Raycast(position, Vector3.yAxis * (_settings.CLIMB_MAX + radius + _settings.HEADROOM), groundParams)

	--[[ Returning ]]

	return position.Y + (if ceiling then math.max(ceiling.Distance - radius - _settings.HEADROOM, 0) else _settings.CLIMB_MAX)
end

--%%%%%%%%%%%%%%%%%%%% Can Step

--[[
	Returns whether a snail's ball walks from where it stands to a spot a step away: up to the higher of the two (with
	room for its ball over it), along at that height, then down onto it, with nothing in the way. The casts start where
	the ball already is, so they see a wall or rock a ground cast started inside of.
]]
--- @return boolean
function Module.CanStep(from: Vector3, to: Vector3)
	--[[ Local Variables ]]

	local radius: number = I.Settings["Snails"].ROOT_SIZE / 2
	local top: number = math.max(from.Y, to.Y) + 0.2
	local along: Vector3 = Vector3.xAxis * (to.X - from.X)
	local over: Vector3 = Vector3.new(from.X, top, 0)

	--[[ Checks ]]

	-- Check if there's room over it to rise to the step
	if I.S.Workspace:Raycast(from, Vector3.yAxis * (top - from.Y + radius * 0.8), groundParams) then
		return false
	end

	-- Check if the way along is open at its middle and its top
	if I.S.Workspace:Raycast(over, along, groundParams) or I.S.Workspace:Raycast(over + Vector3.yAxis * radius * 0.7, along, groundParams) then
		return false
	end

	--[[ Returning ]]

	return top - to.Y < 0.3 or not I.S.Workspace:Raycast(over + along, Vector3.yAxis * -(top - to.Y), groundParams)
end

--%%%%%%%%%%%%%%%%%%%% Can Fly

--[[
	Returns whether a snail's ball flies along at a height from one X to another with nothing in the way (at its middle,
	near its top and near its bottom).
]]
--- @return boolean
function Module.CanFly(fromX: number, toX: number, height: number)
	--[[ Local Variables ]]

	local radius: number = I.Settings["Snails"].ROOT_SIZE / 2
	local along: Vector3 = Vector3.xAxis * (toX - fromX)

	--[[ Checking ]]

	for _index: number, offset: number in ipairs({ 0, radius * 0.7, -radius * 0.7 }) do
		if I.S.Workspace:Raycast(Vector3.new(fromX, height + offset, 0), along, groundParams) then
			return false
		end
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Get Landing

--[[
	Returns where a snail's ball lands coming down from a height at an X, on the ground under it, or nil when there's
	none or it's in the sea or out of the arena.
]]
--- @return Vector3?
function Module.GetLanding(x: number, height: number)
	--[[ Local Variables ]]

	local radius: number = I.Settings["Snails"].ROOT_SIZE / 2
	local result: RaycastResult? = I.S.Workspace:Raycast(Vector3.new(x, height, 0), Vector3.yAxis * -(_settings.CLIMB_MAX + _settings.FALL_LOOK), groundParams)

	--[[ Checks ]]

	-- Check if there's ground to land on, out of the sea
	if not result or I.Arena.GetHazard(result.Position + Vector3.yAxis * radius) then
		return nil
	end

	--[[ Returning ]]

	return result.Position + Vector3.yAxis * radius
end

--%%%%%%%%%%%%%%%%%%%% Is Safe Step

--[[
	Returns whether the ground a step to a side (0: right under it) is safe to walk onto: there's some, out of the sea,
	and not so far down that the fall hurts.
]]
--- @return boolean
function Module._isSafeStep(position: Vector3, side: number)
	--[[ Local Variables ]]

	local ahead: number = position.X + side * (I.Settings["Snails"].ROOT_SIZE / 2 + _settings.WALK_LOOK)

	--[[ Returning ]]

	return Module.GetGround(ahead, position.Y, 0) ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Has Headroom

--[[
	Returns whether a snail's ball has HEADROOM studs free over it to fly up into.
]]
--- @return boolean
function Module._hasHeadroom(position: Vector3)
	return I.S.Workspace:Raycast(position, Vector3.yAxis * (I.Settings["Snails"].ROOT_SIZE / 2 + _settings.HEADROOM), groundParams) == nil
end

--%%%%%%%%%%%%%%%%%%%% Get Wall

--[[
	Returns what stands right in front of a snail's ball toward a side: "Ledge" (no higher than SnailControl's
	STEP_HEIGHT, walked up), "Wall" (higher, but a jump clears it), "Cliff" (higher than a jump), or nil. Slopes don't
	count: walking carries the snail up them.
]]
--- @return string?
function Module._getWall(position: Vector3, side: number)
	--[[ Local Variables ]]

	local radius: number = I.Settings["Snails"].ROOT_SIZE / 2
	local reach: Vector3 = Vector3.xAxis * side * (radius + 0.4)
	local low: RaycastResult? = I.S.Workspace:Raycast(position - Vector3.yAxis * (radius - 0.3), reach, groundParams)

	--[[ Checks ]]

	-- Check if a wall stands in front of the snail's foot
	if not low or math.abs(low.Normal.X) < 0.8 then
		return nil
	end

	-- Check if it's higher than a step
	if not I.S.Workspace:Raycast(position + Vector3.yAxis * (I.Settings["SnailControl"].STEP_HEIGHT - radius + 0.1), reach, groundParams) then
		return "Ledge"
	end

	--[[ Returning ]]

	local high: RaycastResult? = I.S.Workspace:Raycast(position + Vector3.yAxis * (Module.GetJump() - radius - 0.1), reach, groundParams)
	return if high then "Cliff" else "Wall"
end

return Module
