--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--- @type Combat_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local combatFolder: Folder
local active: number = 0

-- Casts that hit what projectiles hit (terrain and worms in play), with and without the shooter
local params: RaycastParams = RaycastParams.new()
local shooterParams: RaycastParams = RaycastParams.new()

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

--- @class Combat_Server_Projectiles
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Building ]]

	combatFolder = I.Create("Folder")({
		Name = _localName,
		Parent = I.Dirs.UmeWorkspace,
	})

	--[[ Saving ]]

	params.CollisionGroup = "Projectile"
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { combatFolder }
	shooterParams.CollisionGroup = "Projectile"
	shooterParams.FilterType = Enum.RaycastFilterType.Exclude
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Spawn

--[[
	Makes a server-owned projectile part on the arena's plane at a position, moving at a velocity: a placeholder neon
	ball in its kind's colour. `collide` lets it bounce off terrain and worms (with `elasticity`); `windAcceleration`
	pushes it along X; `anchored` parts are moved by their behavior instead of physics. It counts as in flight until
	it's destroyed.
]]
--- @return Part
function Module.Spawn(kind: string, name: string, position: Vector3, velocity: Vector3, collide: boolean, elasticity: number?, windAcceleration: number?, anchored: boolean?)
	--[[ Building ]]

	local part: Part = I.Create("Part")({
		Name = name,
		Shape = Enum.PartType.Ball,
		Size = Vector3.one * _settings.PROJECTILE_SIZE,
		Position = Vector3.new(position.X, position.Y, 0),
		Color = _settings.PROJECTILE_COLORS[kind] or Color3.new(1, 1, 1),
		Material = Enum.Material.Neon,
		Anchored = anchored == true,
		CanCollide = collide,
		CanQuery = false,
		CanTouch = false,
		CollisionGroup = "Projectile",
		CustomPhysicalProperties = PhysicalProperties.new(1, 0.3, elasticity or 0, 1, 100),
	})

	-- The match camera follows parts with this attribute
	part:SetAttribute("Projectile", true)

	if not anchored then
		local attachment: Attachment = I.Create("Attachment")({
			Parent = part,
		})
		I.Create("PlaneConstraint")({
			Attachment0 = I.Arena.GetPlane(),
			Attachment1 = attachment,
			Parent = part,
		})
		if windAcceleration and windAcceleration ~= 0 then
			I.Create("VectorForce")({
				Name = "Wind",
				Attachment0 = attachment,
				RelativeTo = Enum.ActuatorRelativeTo.World,
				ApplyAtCenterOfMass = true,
				Force = Vector3.xAxis * windAcceleration * part:GetMass(),
				Parent = part,
			})
		end
	end

	--[[ Launching ]]

	part.Parent = combatFolder
	if not anchored then
		part:SetNetworkOwner(nil)
		part.AssemblyLinearVelocity = velocity
	end

	--[[ Saving ]]

	active += 1
	part.Destroying:Connect(function()
		active -= 1
	end)

	--[[ Returning ]]

	return part
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Cast

--[[
	Returns what a projectile hits moving from one point to another: terrain or a worm in play, never another
	projectile. `shooter` is left out while the shot is still leaving it.
]]
--- @return RaycastResult?
function Module.Cast(from: Vector3, to: Vector3, shooter: Model?)
	--[[ Local Variables ]]

	local direction: Vector3 = to - from

	--[[ Checks ]]

	-- Check if it moved at all
	if direction.Magnitude < 1e-3 then
		return nil
	end

	--[[ Returning ]]

	if shooter then
		shooterParams.FilterDescendantsInstances = { combatFolder, shooter }
		return I.S.Workspace:Raycast(from, direction, shooterParams)
	end
	return I.S.Workspace:Raycast(from, direction, params)
end

--%%%%%%%%%%%%%%%%%%%% Get Worm

--[[
	Returns the worm a cast hit, or nil when it hit something else.
]]
--- @return Model?
function Module.GetWorm(result: RaycastResult?)
	--[[ Local Variables ]]

	local model: Model? = if result then result.Instance:FindFirstAncestorOfClass("Model") else nil

	--[[ Returning ]]

	return if model and model.Parent and model.Parent.Name == "Worms" then model else nil
end

--%%%%%%%%%%%%%%%%%%%% Get Active

--[[
	Returns how many projectiles are still in flight.
]]
--- @return number
function Module.GetActive()
	return active
end

--%%%%%%%%%%%%%%%%%%%% Is Lost

--[[
	Returns whether a projectile has left the arena (beside or below it) or flown longer than MAX_PROJECTILE_TIME.
]]
--- @return boolean
function Module.IsLost(position: Vector3, startedAt: number)
	return os.clock() - startedAt > _settings.MAX_PROJECTILE_TIME or I.Arena.GetHazard(position) == "Bounds"
end

return Module
