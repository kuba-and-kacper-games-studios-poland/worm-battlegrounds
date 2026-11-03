--[[
    Created By:     Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local RunService: RunService = game:GetService("RunService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

local COLLIDER_NAME: string = "RagdollCollider"
local COLLIDER_WELD_NAME: string = "RagdollColliderWeld"
local COLLIDER_NO_COLLISION_NAME: string = "RagdollColliderNoCollision"
local COLLIDER_SCALE: number = 0.85
local COLLIDER_MIN_SIZE: number = 0.2

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Random ]]

local generator: Random = Random.new()

--[[ Caches ]]

--- @type { [Ragdoll_RigCache]: boolean }
local heldCaches = {}

--[[ Connections ]]

local steppedConnection: RBXScriptConnection? = nil
local heartbeatConnection: RBXScriptConnection? = nil

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Hold Limb Collision

--[[
	Keeps real limbs non-colliding while ragdolled; the humanoid turns some back on every physics step.
]]
local function holdLimbCollision()
	--[[ Holding ]]

	--- @param cache Ragdoll_RigCache
	for cache in pairs(heldCaches) do
		--- @param entry Ragdoll_SavedCollision
		for _index: number, entry in ipairs(cache.SavedCollision or {}) do
			entry.Part.CanCollide = false
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Random Spin

--[[
	Returns an angular velocity with a random axis and the given speed.
]]
--- @return Vector3
local function randomSpin(speed: number)
	--[[ Checks ]]

	-- Skip the random axis when there is no spin
	if speed <= 0 then
		return Vector3.zero
	end

	--[[ Returning ]]

	return generator:NextUnitVector() * speed
end

--%%%%%%%%%%%%%%%%%%%% Get Living Humanoid

--[[
	Returns the model's humanoid when it is alive.
]]
--- @return Humanoid?
local function getLivingHumanoid(model: Model)
	--[[ Data ]]

	local humanoid: Humanoid? = model:FindFirstChildOfClass("Humanoid")

	--[[ Returning ]]

	if humanoid and humanoid.Health > 0 then
		return humanoid
	end

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Set Animate Enabled

--[[
	Stops or resumes the character's Animate script.
]]
local function setAnimateEnabled(model: Model, enabled: boolean)
	--[[ Finding ]]

	local animate: Instance? = model:FindFirstChild("Animate")

	--[[ Applying ]]

	-- Skip rigs without an Animate script
	if animate and animate:IsA("BaseScript") then
		animate.Enabled = enabled
	end
end

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

--- @class Ragdoll_Body
local Body = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply Joint Limits

--[[
	Shapes the sockets with the preset. Generated sockets get the preset's limits per joint group (`Default` as fallback);
	sockets the rig shipped with keep their authored limits, scaled by `LimitScale` and `FrictionScale`.
]]
--- @param cache Ragdoll_RigCache
--- @param preset Ragdoll_Preset
--- @param getJointGroup (socket: BallSocketConstraint) -> string?
function Body.ApplyJointLimits(cache, preset, getJointGroup)
	--%%%%%%%%%%%%%%%%%%%% Apply Limits

	--[[
		Writes one set of limits onto a socket.
	]]
	--- @param limits Ragdoll_JointLimits
	local function applyLimits(socket: BallSocketConstraint, limits)
		--[[ Applying ]]

		socket.LimitsEnabled = true
		socket.TwistLimitsEnabled = true
		socket.UpperAngle = limits.UpperAngle
		socket.TwistLowerAngle = limits.TwistLowerAngle
		socket.TwistUpperAngle = limits.TwistUpperAngle
		socket.MaxFrictionTorque = limits.MaxFrictionTorque
	end

	--[[ Saving ]]

	-- Save the rig's original limits once
	if not cache.SavedLimits then
		local savedLimits = {} --- @type { [BallSocketConstraint]: Ragdoll_SavedLimits }

		for _index: number, socket: BallSocketConstraint in ipairs(cache.ForeignSockets) do
			savedLimits[socket] = {
				UpperAngle = socket.UpperAngle,
				TwistLowerAngle = socket.TwistLowerAngle,
				TwistUpperAngle = socket.TwistUpperAngle,
				MaxFrictionTorque = socket.MaxFrictionTorque,
				LimitsEnabled = socket.LimitsEnabled,
				TwistLimitsEnabled = socket.TwistLimitsEnabled,
			}
		end

		cache.SavedLimits = savedLimits
	end

	--[[ Generated Sockets ]]

	for _index: number, socket: BallSocketConstraint in ipairs(cache.Sockets) do
		local jointGroup: string? = getJointGroup(socket)
		applyLimits(socket, jointGroup and preset.Joints[jointGroup] or preset.Joints.Default)
	end

	--[[ Rig Sockets ]]

	--- @param original Ragdoll_SavedLimits
	for socket: BallSocketConstraint, original in pairs(cache.SavedLimits) do
		local twistCenter: number = (original.TwistLowerAngle + original.TwistUpperAngle) / 2
		local twistHalf: number = (original.TwistUpperAngle - original.TwistLowerAngle) / 2 * preset.LimitScale

		applyLimits(socket, {
			UpperAngle = math.clamp(original.UpperAngle * preset.LimitScale, 0, 180),
			TwistLowerAngle = math.clamp(twistCenter - twistHalf, -180, 180),
			TwistUpperAngle = math.clamp(twistCenter + twistHalf, -180, 180),
			MaxFrictionTorque = original.MaxFrictionTorque * preset.FrictionScale,
		})
	end

	--[[ Root ]]

	-- Shape only the root socket this library created
	if cache.RootSocket and cache.RootSocketOwned then
		applyLimits(cache.RootSocket, preset.Root)
	end
end

--%%%%%%%%%%%%%%%%%%%% Restore Joint Limits

--[[
	Puts the original limits back on the sockets the rig shipped with.
]]
--- @param cache Ragdoll_RigCache
function Body.RestoreJointLimits(cache)
	--[[ Checks ]]

	-- Skip when no limits were saved
	if not cache.SavedLimits then
		return
	end

	--[[ Restoring ]]

	--- @param limits Ragdoll_SavedLimits
	for socket: BallSocketConstraint, limits in pairs(cache.SavedLimits) do
		socket.LimitsEnabled = limits.LimitsEnabled
		socket.TwistLimitsEnabled = limits.TwistLimitsEnabled
		socket.UpperAngle = limits.UpperAngle
		socket.TwistLowerAngle = limits.TwistLowerAngle
		socket.TwistUpperAngle = limits.TwistUpperAngle
		socket.MaxFrictionTorque = limits.MaxFrictionTorque
	end

	cache.SavedLimits = nil
end

--%%%%%%%%%%%%%%%%%%%% Ensure Colliders

--[[
	Creates the hidden limb colliders once per model (local, not replicated) and keeps them from hitting each other.
]]
--- @param cache Ragdoll_RigCache
function Body.EnsureColliders(model: Model, cache)
	--[[ Checks ]]

	-- Skip models that already have colliders
	if cache.Colliders then
		return
	end

	--[[ Colliders ]]

	local colliders = {} --- @type { BasePart }

	for _index: number, child: Instance in ipairs(model:GetChildren()) do
		--[[ Checks ]]

		-- Skip non-parts and the root part
		if not child:IsA("BasePart") or child.Name == "HumanoidRootPart" then
			continue
		end

		--[[ Finding ]]

		local collider: Instance? = child:FindFirstChild(COLLIDER_NAME)

		--[[ Creating ]]

		-- Create the collider when the part has none
		if not collider or not collider:IsA("BasePart") then
			-- Remove a non-part child with the collider name
			if collider then
				collider:Destroy()
			end

			local partSize: Vector3 = child.Size
			local newCollider: Part = Instance.new("Part")
			newCollider.Name = COLLIDER_NAME
			newCollider.Size = (partSize * COLLIDER_SCALE):Max(Vector3.one * COLLIDER_MIN_SIZE)
			newCollider.CFrame = child.CFrame
			newCollider.Transparency = 1
			newCollider.Massless = true
			newCollider.CanCollide = false
			newCollider.CanQuery = false
			newCollider.CanTouch = false
			newCollider.Parent = child

			local weld: WeldConstraint = Instance.new("WeldConstraint")
			weld.Name = COLLIDER_WELD_NAME
			weld.Part0 = child
			weld.Part1 = newCollider
			weld.Parent = newCollider

			collider = newCollider
		end

		--[[ Saving ]]

		collider.CollisionGroup = child.CollisionGroup
		table.insert(colliders, collider)
	end

	--[[ Self Collision ]]

	local humanoidRootPart: Instance? = model:FindFirstChild("HumanoidRootPart")

	for index: number, collider: BasePart in ipairs(colliders) do
		--[[ Root ]]

		-- Keep the root part out of the colliders
		if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			local rootNoCollision: NoCollisionConstraint = Instance.new("NoCollisionConstraint")
			rootNoCollision.Name = COLLIDER_NO_COLLISION_NAME
			rootNoCollision.Part0 = humanoidRootPart
			rootNoCollision.Part1 = collider
			rootNoCollision.Parent = collider
		end

		--[[ Limbs ]]

		for otherIndex: number = index + 1, #colliders do
			local noCollision: NoCollisionConstraint = Instance.new("NoCollisionConstraint")
			noCollision.Name = COLLIDER_NO_COLLISION_NAME
			noCollision.Part0 = collider
			noCollision.Part1 = colliders[otherIndex]
			noCollision.Parent = collider
		end
	end

	--[[ Saving ]]

	cache.Colliders = colliders
end

--%%%%%%%%%%%%%%%%%%%% Set Colliders Enabled

--[[
	Turns the hidden colliders on with the preset's physics, or back off and massless.
]]
--- @param cache Ragdoll_RigCache
--- @param preset Ragdoll_Preset?
function Body.SetCollidersEnabled(cache, enabled: boolean, preset)
	--[[ Local Variables ]]

	local properties: PhysicalProperties? = if preset then PhysicalProperties.new(preset.ColliderDensity, preset.ColliderFriction, preset.ColliderElasticity) else nil

	--[[ Applying ]]

	for _index: number, collider: BasePart in ipairs(cache.Colliders or {}) do
		collider.CanCollide = enabled
		collider.Massless = not enabled

		-- Keep the current physics when no preset is given
		if properties then
			collider.CustomPhysicalProperties = properties
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Hold Collision

--[[
	Saves the limbs' collision, turns it off, and keeps it off every physics step until released.
]]
--- @param cache Ragdoll_RigCache
function Body.HoldCollision(model: Model, cache)
	--[[ Saving ]]

	-- Save the limbs' collision once
	if not cache.SavedCollision then
		local saved = {} --- @type { Ragdoll_SavedCollision }

		for _index: number, child: Instance in ipairs(model:GetChildren()) do
			if child:IsA("BasePart") then
				table.insert(saved, { Part = child, CanCollide = child.CanCollide })
			end
		end

		cache.SavedCollision = saved
	end

	--[[ Holding ]]

	heldCaches[cache] = true
	holdLimbCollision()

	-- Connect the step loops once for every held model
	if not steppedConnection then
		steppedConnection = RunService.Stepped:Connect(holdLimbCollision)
		heartbeatConnection = RunService.Heartbeat:Connect(holdLimbCollision)
	end
end

--%%%%%%%%%%%%%%%%%%%% Release Collision

--[[
	Stops holding the limbs' collision and restores the saved values.
]]
--- @param cache Ragdoll_RigCache
function Body.ReleaseCollision(cache)
	--[[ Releasing ]]

	heldCaches[cache] = nil

	--- @param entry Ragdoll_SavedCollision
	for _index: number, entry in ipairs(cache.SavedCollision or {}) do
		-- Skip parts that were removed
		if entry.Part.Parent then
			entry.Part.CanCollide = entry.CanCollide
		end
	end

	cache.SavedCollision = nil

	--[[ Disconnecting ]]

	-- Keep the step connections while another model is held
	if next(heldCaches) ~= nil then
		return
	end

	-- Disconnect the step loops that are still connected
	if steppedConnection then
		steppedConnection:Disconnect()
		steppedConnection = nil
	end

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Launch

--[[
	Writes the launch velocity onto every body part, plus a torso tumble and limb flail from the preset.
	The same velocities are written again next frame so the humanoid state change cannot clear them.
]]
--- @param preset Ragdoll_Preset
--- @param isActive () -> boolean
function Body.Launch(model: Model, velocity: Vector3, preset, isActive)
	--[[ Local Variables ]]

	local launchVelocity: Vector3 = velocity * preset.LaunchMultiplier
	local torso: Instance? = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso") or model:FindFirstChild("LowerTorso")
	local spins = {} --- @type { [BasePart]: Vector3 }

	--[[ Spins ]]

	for _index: number, child: Instance in ipairs(model:GetChildren()) do
		-- Spin the torso and flail every limb except the root part
		if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
			spins[child] = randomSpin(if child == torso then preset.SpinSpeed else preset.LimbFlail)
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Apply Launch

	--[[
		Writes the chosen velocities onto the body parts while the ragdoll is still active.
	]]
	local function applyLaunch()
		--[[ Checks ]]

		-- Skip once the ragdoll ended or the model was removed
		if not model.Parent or not isActive() then
			return
		end

		--[[ Applying ]]

		for _index: number, child: Instance in ipairs(model:GetChildren()) do
			-- Skip non-parts
			if not child:IsA("BasePart") then
				continue
			end

			child.AssemblyLinearVelocity = launchVelocity

			-- Skip the spin for the root part
			if spins[child] then
				child.AssemblyAngularVelocity = spins[child]
			end
		end
	end

	--[[ Applying ]]

	applyLaunch()

	-- Apply again next frame so the state change cannot clear it
	task.defer(applyLaunch)
end

--%%%%%%%%%%%%%%%%%%%% Begin Humanoid

--[[
	Puts the humanoid into the Physics state and stops its animations.
]]
function Body.BeginHumanoid(model: Model)
	--[[ Data ]]

	local humanoid: Humanoid? = getLivingHumanoid(model)

	--[[ Checks ]]

	-- Check if the model has a living humanoid
	if not humanoid then
		return
	end

	--[[ State ]]

	humanoid.AutoRotate = false
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	--[[ Animations ]]

	setAnimateEnabled(model, false)

	local animator: Animator? = humanoid:FindFirstChildOfClass("Animator")

	-- Stop the tracks that are still playing
	if animator then
		for _index: number, track: AnimationTrack in ipairs(animator:GetPlayingAnimationTracks()) do
			track:Stop(0)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Finish Humanoid

--[[
	Stands a living character upright on the floor, clears its velocity, and gives control back.
]]
function Body.FinishHumanoid(model: Model)
	--[[ Data ]]

	local humanoid: Humanoid? = getLivingHumanoid(model)
	local rootPart: Instance? = model:FindFirstChild("HumanoidRootPart")

	--[[ Checks ]]

	-- Leave dead or rootless models where they fell
	if not humanoid or not rootPart or not rootPart:IsA("BasePart") then
		return
	end

	--[[ Standing ]]

	local raycastParams: RaycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { model }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local floorResult: RaycastResult? = workspace:Raycast(rootPart.Position + Vector3.new(0, 6, 0), Vector3.new(0, -18, 0), raycastParams)
	local rootHeight: number = if humanoid.HipHeight > 0 then humanoid.HipHeight + rootPart.Size.Y / 2 else rootPart.Size.Y * 1.5
	local standPosition: Vector3 = if floorResult then Vector3.new(rootPart.Position.X, floorResult.Position.Y + rootHeight, rootPart.Position.Z) else rootPart.Position

	local lookVector: Vector3 = rootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
	local lookDirection: Vector3 = if lookVector.Magnitude > 1e-4 then lookVector.Unit else Vector3.zAxis
	local targetRootCFrame: CFrame = CFrame.lookAt(standPosition, standPosition + lookDirection)

	model:PivotTo(targetRootCFrame * rootPart.CFrame:Inverse() * model:GetPivot())

	--[[ Velocity ]]

	for _index: number, descendant: Instance in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.AssemblyLinearVelocity = Vector3.zero
			descendant.AssemblyAngularVelocity = Vector3.zero
		end
	end

	--[[ State ]]

	humanoid.AutoRotate = true
	humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
	setAnimateEnabled(model, true)
	humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

	--[[ Recovering ]]

	task.defer(function()
		-- Skip when the humanoid died or was removed meanwhile
		if not humanoid.Parent or humanoid.Health <= 0 then
			return
		end

		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end)
end

return Body
