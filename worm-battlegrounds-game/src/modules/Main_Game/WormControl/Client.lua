--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "WormControl"

--- @type WormControl_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Worm ]]

local myWorm: Model?
local moving: boolean = false
local stepConnection: RBXScriptConnection?

--[[
	The worm's ball grips the ground while it stands (so it doesn't slide down slopes) and loses its grip while it
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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	groundParams.CollisionGroup = "Worm"

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.WormControl = {

		--[[ Control ]]

		Hold = Module.Hold,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	-- Players move worms, not their parked avatars
	require(I.S.Players.LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")):GetControls():Disable()

	I.Dirs.UmeWorkspace:WaitForChild("Worms").ChildAdded:Connect(Module._onWormAdded)
	local mine: Model? = I.Worms.GetMine()
	if mine then
		Module._onWormAdded(mine)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Hold

--[[
	**CLIENT** |
	Presses or releases one of the worm's controls ("Left", "Right" or "Jump") from an on-screen button, as its key
	does. Does nothing while the player can't move their worm.
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
		Module._onJump("WormControl_Jump", inputState, nil)
	else
		Module._onWalk(`WormControl_{control}`, inputState, nil)
	end
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Drives the local player's worm before each physics step while they may move it: flies it up while jump is held
	and jetpack fuel lasts, walks it along the plane at WALK_SPEED (faster under the Speed potion) until its Stamina
	runs out, turns it to face the way it walks, and pushes it up low ledges in front.
]]
function Module._step(deltaTime: number)
	--[[ Checks ]]

	-- Stop when the worm is gone
	if not myWorm or not myWorm.Parent then
		Module._setMoving(false)
		return
	end

	--[[ Local Variables ]]

	local root: BasePart = myWorm.PrimaryPart
	local walk: LinearVelocity = root:FindFirstChild("Walk")
	local direction: number = (if held.Right then 1 else 0) - (if held.Left then 1 else 0)
	if math.abs(stick) >= _settings.STICK_DEADZONE then
		direction = math.clamp(direction + stick, -1, 1)
	end

	-- Stand still once the stamina runs out
	if myWorm:GetAttribute("Stamina") <= 0 then
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
	walk.LineVelocity = direction * _settings.WALK_SPEED * (myWorm:GetAttribute("SpeedMultiplier") or 1)
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

--%%%%%%%%%%%%%%%%%%%% On Worm Added

--[[
	Follows the local player's worm, when it's the one that appeared: its CanMove attribute turns their controls on
	and off.
]]
function Module._onWormAdded(model: Instance)
	--[[ Checks ]]

	-- Skip other players' worms
	if model ~= I.Worms.GetMine() then
		return
	end

	--[[ Saving ]]

	local physics: PhysicalProperties = model.PrimaryPart.CustomPhysicalProperties
	myWorm = model
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
	Binds the walk and jump controls (keys, gamepad and touch buttons) and starts driving the worm, or undoes it all.
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

	local priority: number = Enum.ContextActionPriority.High.Value
	if state then
		I.S.ContextActionService:BindActionAtPriority("WormControl_Left", Module._onWalk, false, priority, Enum.KeyCode.A, Enum.KeyCode.Left, Enum.KeyCode.DPadLeft)
		I.S.ContextActionService:BindActionAtPriority("WormControl_Right", Module._onWalk, false, priority, Enum.KeyCode.D, Enum.KeyCode.Right, Enum.KeyCode.DPadRight)
		I.S.ContextActionService:BindActionAtPriority("WormControl_Jump", Module._onJump, false, priority, Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
		I.S.ContextActionService:BindActionAtPriority("WormControl_Stick", Module._onStick, false, priority, Enum.KeyCode.Thumbstick1)
		stepConnection = I.S.RunService.PreSimulation:Connect(Module._step)
		return
	end

	for _index: number, action: string in ipairs({ "WormControl_Left", "WormControl_Right", "WormControl_Jump", "WormControl_Stick" }) do
		I.S.ContextActionService:UnbindAction(action)
	end
	if stepConnection then
		stepConnection:Disconnect()
		stepConnection = nil
	end

	-- The server owns the worm again, but stop this side's walk too
	if myWorm and myWorm.Parent then
		myWorm.PrimaryPart:FindFirstChild("Walk").Enabled = false
		myWorm.PrimaryPart.CustomPhysicalProperties = restPhysics
	end
	slippery = false
end

--%%%%%%%%%%%%%%%%%%%% On Walk

--[[
	Holds or releases a walk direction.
]]
--- @return Enum.ContextActionResult
function Module._onWalk(action: string, state: Enum.UserInputState, _input: InputObject?)
	--[[ Saving ]]

	held[if action == "WormControl_Left" then "Left" else "Right"] = state == Enum.UserInputState.Begin

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
	Jumps when the worm stands on something, as often as the player likes; holding it flies with a jetpack.
]]
--- @return Enum.ContextActionResult
function Module._onJump(_action: string, state: Enum.UserInputState, _input: InputObject?)
	--[[ Saving ]]

	jumpHeld = state == Enum.UserInputState.Begin

	--[[ Jumping ]]

	if state == Enum.UserInputState.Begin and myWorm and Module._isGrounded(myWorm.PrimaryPart.Position) then
		local root: BasePart = myWorm.PrimaryPart
		root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, _settings.JUMP_SPEED, 0)
	end

	--[[ Returning ]]

	return Enum.ContextActionResult.Sink
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Grounded

--[[
	Returns whether a worm whose ball is centered at a position stands on something, on flat ground or a slope.
]]
--- @return boolean
function Module._isGrounded(position: Vector3)
	--[[ Local Variables ]]

	-- A slightly smaller sphere, cast down, finds ground under any part of the ball
	local shrink: number = 0.15
	local radius: number = I.Settings["Worms"].ROOT_SIZE / 2 - shrink

	--[[ Returning ]]

	return I.S.Workspace:Spherecast(position, radius, Vector3.new(0, -(shrink + I.Settings["Worms"].GROUND_GAP), 0), groundParams) ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Is Ledge

--[[
	Returns whether a wall no higher than STEP_HEIGHT stands right in front of a worm's ball, so walking into it should
	lift the worm onto it. Slopes don't count: their own push carries the worm up.
]]
--- @return boolean
function Module._isLedge(position: Vector3, side: number)
	--[[ Local Variables ]]

	local radius: number = I.Settings["Worms"].ROOT_SIZE / 2
	local reach: Vector3 = Vector3.xAxis * side * (radius + 0.4)
	local low: RaycastResult? = I.S.Workspace:Raycast(position - Vector3.yAxis * (radius - 0.3), reach, groundParams)

	--[[ Checks ]]

	-- Check if a wall stands in front of the worm's foot
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
