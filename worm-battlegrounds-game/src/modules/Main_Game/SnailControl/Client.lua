--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "SnailControl"

--- @type SnailControl_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Snail ]]

local mySnail: Model?
local moving: boolean = false
local stepConnection: RBXScriptConnection?

--[[
	The snail's ball grips the ground while it stands (so it doesn't slide down slopes) and loses its grip while it
	walks (so it doesn't stick to walls it walks into, and slides up slopes)
]]
local restPhysics: PhysicalProperties?
local walkPhysics: PhysicalProperties?
local slippery: boolean = false

--[[ Input ]]

-- Whether the walk keys or buttons are held, by direction
local held = { Left = false, Right = false } --- @type { [string]: boolean }
local stick: number = 0
local jumpHeld: boolean = false

-- Seconds of jetpack flight left this turn
local fuel: number = 0

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	groundParams.CollisionGroup = "Snail"

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.SnailControl = {

		--[[ Control ]]

		Hold = Module.Hold,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	-- Players move snails, not their parked avatars
	require(I.S.Players.LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")):GetControls():Disable()

	I.Dirs.UmeWorkspace:WaitForChild("Snails").ChildAdded:Connect(Module._onSnailAdded)
	local mine: Model? = I.Snails.GetMine()
	if mine then
		Module._onSnailAdded(mine)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Hold

--[[
	**CLIENT** |
	Presses or releases one of the snail's controls ("Left", "Right" or "Jump") from an on-screen button, as its key
	does. Does nothing while the player can't move their snail.
]]
function Module.Hold(control: string, state: boolean)
	--[[ Checks ]]

	-- Check if the player may move now
	if not moving then
		return
	end

	--[[ Holding ]]

	local inputState: Enum.UserInputState = if state then Enum.UserInputState.Begin else Enum.UserInputState.End
	if control == "Jump" then
		Module._onJump("SnailControl_Jump", inputState, nil)
	else
		Module._onWalk(`SnailControl_{control}`, inputState, nil)
	end
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Drives the local player's snail before each physics step while they may move it: flies it up while jump is held
	and jetpack fuel lasts, walks it along the plane at WALK_SPEED (faster under the Speed potion) until its Stamina
	runs out, turns it to face the way it walks, and pushes it up low ledges in front.
]]
function Module._step(deltaTime: number)
	--[[ Checks ]]

	-- Stop when the snail is gone
	if not mySnail or not mySnail.Parent then
		Module._setMoving(false)
		return
	end

	--[[ Local Variables ]]

	local root: BasePart = mySnail.PrimaryPart
	local walk: LinearVelocity = root:FindFirstChild("Walk")
	local direction: number = (if held.Right then 1 else 0) - (if held.Left then 1 else 0)
	if math.abs(stick) >= _settings.STICK_DEADZONE then
		direction = math.clamp(direction + stick, -1, 1)
	end

	-- Stand still once the stamina runs out
	if mySnail:GetAttribute("Stamina") <= 0 then
		direction = 0
	end

	--[[ Flying ]]

	if jumpHeld and fuel > 0 then
		fuel -= deltaTime
		local velocity: Vector3 = root.AssemblyLinearVelocity
		root.AssemblyLinearVelocity = Vector3.new(velocity.X, math.max(velocity.Y, _settings.JETPACK_SPEED), 0)
	end

	--[[ Walking ]]

	walk.Enabled = direction ~= 0
	walk.LineVelocity = direction * _settings.WALK_SPEED * (mySnail:GetAttribute("SpeedMultiplier") or 1)
	if slippery ~= (direction ~= 0) then
		slippery = direction ~= 0
		root.CustomPhysicalProperties = if slippery then walkPhysics else restPhysics
	end
	if direction == 0 then
		return
	end

	local side: number = math.sign(direction)
	root:FindFirstChild("Upright").CFrame = CFrame.lookAlong(Vector3.zero, Vector3.new(side, 0, 0))

	--[[ Climbing ]]

	if Module._isLedge(root.Position, side) then
		local velocity: Vector3 = root.AssemblyLinearVelocity
		root.AssemblyLinearVelocity = Vector3.new(velocity.X, math.max(velocity.Y, _settings.STEP_SPEED), 0)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Snail Added

--[[
	Follows the local player's snail, when it's the one that appeared: its CanMove attribute turns their controls on
	and off.
]]
function Module._onSnailAdded(model: Instance)
	--[[ Checks ]]

	-- Skip other players' snails
	if model ~= I.Snails.GetMine() then
		return
	end

	--[[ Saving ]]

	local physics: PhysicalProperties = model.PrimaryPart.CustomPhysicalProperties
	mySnail = model
	restPhysics = physics
	walkPhysics = PhysicalProperties.new(physics.Density, 0, physics.Elasticity, 100, physics.ElasticityWeight)

	--[[ Connections ]]

	model:GetAttributeChangedSignal("CanMove"):Connect(function()
		Module._setMoving(model:GetAttribute("CanMove") == true)
	end)
	model:GetAttributeChangedSignal("JetpackFuel"):Connect(function()
		fuel = model:GetAttribute("JetpackFuel") or 0
	end)
	Module._setMoving(model:GetAttribute("CanMove") == true)
end

--%%%%%%%%%%%%%%%%%%%% Set Moving

--[[
	Binds the walk and jump controls (keys, gamepad and touch buttons) and starts driving the snail, or undoes it all.
]]
function Module._setMoving(state: boolean)
	--[[ Checks ]]

	-- Skip when nothing changes
	if state == moving then
		return
	end

	--[[ Saving ]]

	moving = state
	held.Left = false
	held.Right = false
	stick = 0
	jumpHeld = false

	--[[ Binding ]]

	-- The keys here, the pad's buttons through the Console module's scheme
	local priority: number = Enum.ContextActionPriority.High.Value
	if state then
		I.S.ContextActionService:BindActionAtPriority("SnailControl_Left", Module._onWalk, false, priority, Enum.KeyCode.A, Enum.KeyCode.Left)
		I.S.ContextActionService:BindActionAtPriority("SnailControl_Right", Module._onWalk, false, priority, Enum.KeyCode.D, Enum.KeyCode.Right)
		I.S.ContextActionService:BindActionAtPriority("SnailControl_Jump", Module._onJump, false, priority, Enum.KeyCode.Space)
		I.Console.Bind("WalkLeft", Module._onWalk)
		I.Console.Bind("WalkRight", Module._onWalk)
		I.Console.Bind("Jump", Module._onJump)
		I.Console.Bind("Move", Module._onStick)
		stepConnection = I.S.RunService.PreSimulation:Connect(Module._step)
		return
	end

	for _index: number, action: string in ipairs({ "SnailControl_Left", "SnailControl_Right", "SnailControl_Jump" }) do
		I.S.ContextActionService:UnbindAction(action)
	end
	for _index: number, action: string in ipairs({ "WalkLeft", "WalkRight", "Jump", "Move" }) do
		I.Console.Unbind(action)
	end
	if stepConnection then
		stepConnection:Disconnect()
		stepConnection = nil
	end

	-- The server owns the snail again, but stop this side's walk too
	if mySnail and mySnail.Parent then
		mySnail.PrimaryPart:FindFirstChild("Walk").Enabled = false
		mySnail.PrimaryPart.CustomPhysicalProperties = restPhysics
	end
	slippery = false
end

--%%%%%%%%%%%%%%%%%%%% On Walk

--[[
	Holds or releases a walk direction: its keys' action, or the pad's (WalkLeft, WalkRight).
]]
--- @return Enum.ContextActionResult
function Module._onWalk(action: string, state: Enum.UserInputState, _input: InputObject?)
	--[[ Saving ]]

	held[if action == "SnailControl_Left" or action == "WalkLeft" then "Left" else "Right"] = state == Enum.UserInputState.Begin

	--[[ Returning ]]

	return Enum.ContextActionResult.Sink
end

--%%%%%%%%%%%%%%%%%%%% On Stick

--[[
	Follows the left stick's lean along X.
]]
--- @return Enum.ContextActionResult
function Module._onStick(_action: string, state: Enum.UserInputState, input: InputObject)
	--[[ Saving ]]

	stick = if state == Enum.UserInputState.Change or state == Enum.UserInputState.Begin then input.Position.X else 0

	--[[ Returning ]]

	return Enum.ContextActionResult.Sink
end

--%%%%%%%%%%%%%%%%%%%% On Jump

--[[
	Jumps when the snail stands on something, as often as the player likes; holding it flies with a jetpack.
]]
--- @return Enum.ContextActionResult
function Module._onJump(_action: string, state: Enum.UserInputState, _input: InputObject?)
	--[[ Saving ]]

	jumpHeld = state == Enum.UserInputState.Begin

	--[[ Jumping ]]

	if state == Enum.UserInputState.Begin and mySnail and Module._isGrounded(mySnail.PrimaryPart.Position) then
		local root: BasePart = mySnail.PrimaryPart
		root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, _settings.JUMP_SPEED, 0)
	end

	--[[ Returning ]]

	return Enum.ContextActionResult.Sink
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Grounded

--[[
	Returns whether a snail whose ball is centered at a position stands on something, on flat ground or a slope.
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

--%%%%%%%%%%%%%%%%%%%% Is Ledge

--[[
	Returns whether a wall no higher than STEP_HEIGHT stands right in front of a snail's ball, so walking into it should
	lift the snail onto it. Slopes don't count: their own push carries the snail up.
]]
--- @return boolean
function Module._isLedge(position: Vector3, side: number)
	--[[ Local Variables ]]

	local radius: number = I.Settings["Snails"].ROOT_SIZE / 2
	local reach: Vector3 = Vector3.xAxis * side * (radius + 0.4)
	local low: RaycastResult? = I.S.Workspace:Raycast(position - Vector3.yAxis * (radius - 0.3), reach, groundParams)

	--[[ Checks ]]

	-- Check if a wall stands in front of the snail's foot
	if not low or math.abs(low.Normal.X) < 0.8 then
		return false
	end

	--[[ Returning ]]

	return I.S.Workspace:Raycast(position + Vector3.yAxis * (_settings.STEP_HEIGHT - radius + 0.1), reach, groundParams) == nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
