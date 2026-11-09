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
	at walls, flying its jetpack (JetpackFuel) over higher walls and gaps, and up to `climbTo` (a height) when given, and
	spending its Stamina. Stops at the X, when the stamina runs out, `seconds` pass or `keepGoing` says no, when it's
	stuck, and at an edge it would fall off into the sea or too far (unless its jetpack carries it). Returns how far it
	moved along X.
]]
--- @param keepGoing () -> boolean
--- @return number
function Module.WalkTo(model: Model, targetX: number, seconds: number, climbTo: number?, keepGoing)
	--[[ Local Variables ]]

	local control = I.Settings["SnailControl"] --- @type SnailControl_Settings
	local root: BasePart = model.PrimaryPart
	local walk: LinearVelocity = root:FindFirstChild("Walk")
	local rest: PhysicalProperties = root.CustomPhysicalProperties
	local startX: number = root.Position.X
	local deadline: number = os.clock() + seconds
	local fuel: number = model:GetAttribute("JetpackFuel") or 0
	local lastX: number = startX
	local stuckSince: number = os.clock()

	--[[ Walking ]]

	-- No grip while walking, as a player's snail, so it slides up slopes instead of sticking to them
	root.CustomPhysicalProperties = PhysicalProperties.new(rest.Density, 0, rest.Elasticity, 100, rest.ElasticityWeight)

	while os.clock() < deadline and keepGoing() and model.Parent and model:GetAttribute("Alive") do
		local position: Vector3 = root.Position
		local offset: number = targetX - position.X
		local stamina: number = model:GetAttribute("Stamina") or 0
		if math.abs(offset) <= _settings.ARRIVE_DISTANCE or stamina <= 0 then
			break
		end

		local side: number = math.sign(offset)
		local grounded: boolean = I.Snails.IsGrounded(model.Name)
		local flying: boolean = false

		-- An edge ahead it can't walk off: fly over it with fuel, else stop there
		if grounded and not Module._isSafeStep(position, side) then
			if fuel <= 0 then
				break
			end
			flying = true
		end

		-- A wall: climb a low ledge, jump a higher one, fly over what the jump can't clear
		local wall: string? = Module._getWall(position, side)
		local velocity: Vector3 = root.AssemblyLinearVelocity
		if wall == "Ledge" then
			root.AssemblyLinearVelocity = Vector3.new(velocity.X, math.max(velocity.Y, control.STEP_SPEED), 0)
		elseif wall == "Wall" and grounded then
			root.AssemblyLinearVelocity = Vector3.new(velocity.X, control.JUMP_SPEED, 0)
		elseif wall == "Wall" and velocity.Y < 1 then
			flying = fuel > 0
		end

		-- Over a gap keep up, and fly up to a ledge it's heading for, while the fuel lasts
		if not grounded and not Module._isSafeStep(position, 0) and velocity.Y < 0 or climbTo and position.Y < climbTo + 1 then
			flying = fuel > 0
		end

		if flying then
			velocity = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.new(velocity.X, math.max(velocity.Y, control.JETPACK_SPEED), 0)
		end

		walk.LineVelocity = side * control.WALK_SPEED * (model:GetAttribute("SpeedMultiplier") or 1)
		walk.Enabled = true
		root:FindFirstChild("Upright").CFrame = CFrame.lookAlong(Vector3.zero, Vector3.xAxis * side)
		model:SetAttribute("Facing", side)

		local deltaTime: number = I.S.RunService.Heartbeat:Wait()
		if flying then
			fuel = math.max(fuel - deltaTime, 0)
		end

		-- Stamina goes as a player's does, by the distance walked
		local moved: number = math.abs(root.Position.X - position.X) / (model:GetAttribute("SpeedMultiplier") or 1)
		model:SetAttribute("Stamina", math.max(stamina - moved, 0))

		-- Give up on a wall it can't get past
		if math.abs(root.Position.X - lastX) >= _settings.STUCK_DISTANCE then
			lastX = root.Position.X
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

	--[[ Returning ]]

	return root.Position.X - startX
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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Ground

--[[
	Returns where a snail's ball would stand at an X, on the highest ground no more than `above` studs over a height
	(its middle, ROOT_SIZE / 2 over the ground), or nil when there's no ground within FALL_LOOK below, the ground is in
	the sea, or the drop from that height is far enough to hurt (Snails' SAFE_FALL_HEIGHT).
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
	can safely step down to (GetGround), up to `max` studs.
]]
--- @return number
function Module.GetRunway(position: Vector3, side: number, max: number)
	--[[ Local Variables ]]

	local control = I.Settings["SnailControl"] --- @type SnailControl_Settings
	local jump: number = control.JUMP_SPEED ^ 2 / (2 * I.S.Workspace.Gravity)
	local height: number = position.Y

	--[[ Walking ]]

	for step: number = 1, max do
		local spot: Vector3? = Module.GetGround(position.X + side * step, height, jump)
		if not spot then
			return step - 1
		end
		height = spot.Y
	end

	--[[ Returning ]]

	return max
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

--%%%%%%%%%%%%%%%%%%%% Get Wall

--[[
	Returns what stands right in front of a snail's ball toward a side: "Ledge" (no higher than SnailControl's
	STEP_HEIGHT, walked up), "Wall" (higher), or nil. Slopes don't count: walking carries the snail up them.
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

	--[[ Returning ]]

	local high: RaycastResult? = I.S.Workspace:Raycast(position + Vector3.yAxis * (I.Settings["SnailControl"].STEP_HEIGHT - radius + 0.1), reach, groundParams)
	return if high then "Wall" else "Ledge"
end

return Module
