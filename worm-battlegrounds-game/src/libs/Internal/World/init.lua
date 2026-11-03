--[[
    Created By:     Nari
]]

local _localName = "World"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Stop Model

--[[
	Clears the linear velocity of every assembly in the model before it is moved.
]]
local function stopModel(model: Model)
	--[[ Stopping ]]

	for _index: number, descendant: Instance in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.AssemblyLinearVelocity = Vector3.zero
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Disable Part Collisions

--[[
	Turns off collision, touch, and query on one part.
]]
local function disablePartCollisions(part: BasePart)
	--[[ Applying ]]

	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
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

--- @class Ume_Library_World : Ume_Library
local World = {}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Assigns this library onto Ume.
]]
--- @param umeInstance Ume
function World._injectUme(umeInstance)
	--- @type Ume
	local I = umeInstance

	--[[ Assigning ]]

	I.World = World --- @type Ume_Library_World
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Move Model To Position

--[[
	Moves a model so the bottom of its bounding box sits on `goalPos` instead of its pivot.
]]
function World.MoveModelToPosition(model: Model, goalPos: CFrame)
	--[[ Checks ]]

	-- Check if the value is a model
	if not model or not model:IsA("Model") then
		warn(`[{_localName}::{script.Name}]: Invalid (model), expected a Model!`)
		return
	end

	--[[ Calculating ]]

	local boundingCFrame: CFrame, boundingSize: Vector3 = model:GetBoundingBox()
	local bottomY: number = boundingCFrame.Position.Y - boundingSize.Y / 2
	local offsetY: number = model:GetPivot().Position.Y - bottomY

	--[[ Moving ]]

	stopModel(model)
	model:PivotTo(goalPos * CFrame.new(0, offsetY, 0))
end

--%%%%%%%%%%%%%%%%%%%% Move Character To Position

--[[
	Moves a character so the midpoint of its foot attachments stands on `goalPos`.
]]
function World.MoveCharacterToPosition(character: Model, goalPos: CFrame)
	--[[ Checks ]]

	-- Check if the value is a model
	if not character or not character:IsA("Model") then
		warn(`[{_localName}::{script.Name}]: Invalid (character), expected a Model!`)
		return
	end

	--[[ Elements ]]

	local leftFootAttachment: Attachment? = character:FindFirstChild("LeftFootAttachment", true)
	local rightFootAttachment: Attachment? = character:FindFirstChild("RightFootAttachment", true)

	--[[ Checks ]]

	-- Check if the character has both foot attachments
	if not leftFootAttachment or not rightFootAttachment then
		warn(`[{_localName}::{script.Name}]: Character ({character.Name}) is missing LeftFootAttachment or RightFootAttachment!`)
		return
	end

	--[[ Calculating ]]

	local standingY: number = (leftFootAttachment.WorldPosition.Y + rightFootAttachment.WorldPosition.Y) / 2
	local offsetY: number = character:GetPivot().Position.Y - standingY

	--[[ Moving ]]

	stopModel(character)
	character:PivotTo(goalPos * CFrame.new(0, offsetY, 0))
end

--%%%%%%%%%%%%%%%%%%%% Weld

--[[
	Welds every BasePart in the model to `rootPart` and unanchors them.
]]
--- @return { WeldConstraint }
function World.Weld(rootPart: BasePart, model: Model)
	--[[ Checks ]]

	-- Check if a root part and a model were passed
	if not rootPart or not model or not model:IsA("Model") then
		warn(`[{_localName}::{script.Name}]: (rootPart) and a (model) Model are required!`)
		return {}
	end

	--[[ Welding ]]

	local createdWelds = {} --- @type { WeldConstraint }

	for _index: number, descendant: Instance in ipairs(model:GetDescendants()) do
		-- Skip non-parts and the root part itself
		if not descendant:IsA("BasePart") or descendant == rootPart then
			continue
		end

		local weld: WeldConstraint = Instance.new("WeldConstraint")
		weld.Part0 = rootPart
		weld.Part1 = descendant
		weld.Parent = rootPart

		descendant.Anchored = false

		table.insert(createdWelds, weld)
	end

	--[[ Returning ]]

	return createdWelds
end

--%%%%%%%%%%%%%%%%%%%% Disable Collisions

--[[
	Disables collision, touch, and query on `instance` and every BasePart under it.
]]
function World.DisableCollisions(instance: Instance)
	--[[ Checks ]]

	-- Check if an instance was passed
	if not instance then
		return
	end

	--[[ Instance ]]

	if instance:IsA("BasePart") then
		disablePartCollisions(instance)
	end

	--[[ Descendants ]]

	for _index: number, descendant: Instance in ipairs(instance:GetDescendants()) do
		if descendant:IsA("BasePart") then
			disablePartCollisions(descendant)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Scale Model To Studs

--[[
	Uniformly scales a model so it fits inside the given stud dimensions (omitted axes are ignored).
]]
function World.ScaleModelToStuds(model: Model, x: number?, y: number?, z: number?)
	--[[ Checks ]]

	-- Check if at least one dimension was passed
	if not x and not y and not z then
		warn(`[{_localName}::{script.Name}]: No dimensions were provided!`)
		return
	end

	-- Check if the value is a model
	if not model or not model:IsA("Model") then
		warn(`[{_localName}::{script.Name}]: Invalid (model), expected a Model!`)
		return
	end

	--[[ Local Variables ]]

	local extents: Vector3 = model:GetExtentsSize()

	--[[ Checks ]]

	-- Check if every used axis has a size to divide by
	if (x and extents.X <= 0) or (y and extents.Y <= 0) or (z and extents.Z <= 0) then
		warn(`[{_localName}::{script.Name}]: Model ({model.Name}) has zero extent on a used axis!`)
		return
	end

	--[[ Scaling ]]

	local scaleX: number = if x then x / extents.X else math.huge
	local scaleY: number = if y then y / extents.Y else math.huge
	local scaleZ: number = if z then z / extents.Z else math.huge

	model:ScaleTo(model:GetScale() * math.min(scaleX, scaleY, scaleZ))
end

--%%%%%%%%%%%%%%%%%%%% Adjust Model Origin Offset

--[[
	Moves the model's pivot to a point inside its bounding box without moving the model.
	Ratios run from 0 to 1 per axis (0.5 is the center); omitted axes stay centered.
]]
function World.AdjustModelOriginOffset(model: Model, xRatio: number?, yRatio: number?, zRatio: number?)
	--[[ Checks ]]

	-- Check if at least one ratio was passed
	if not xRatio and not yRatio and not zRatio then
		warn(`[{_localName}::{script.Name}]: No ratios were provided!`)
		return
	end

	-- Check if the value is a model
	if not model or not model:IsA("Model") then
		warn(`[{_localName}::{script.Name}]: Invalid (model), expected a Model!`)
		return
	end

	--[[ Calculating ]]

	local boundingCFrame: CFrame, boundingSize: Vector3 = model:GetBoundingBox()
	local offset: Vector3 = Vector3.new(if xRatio then boundingSize.X * (xRatio - 0.5) else 0, if yRatio then boundingSize.Y * (yRatio - 0.5) else 0, if zRatio then boundingSize.Z * (zRatio - 0.5) else 0)
	local targetPivot: CFrame = CFrame.new(boundingCFrame:PointToWorldSpace(offset)) * model:GetPivot().Rotation

	--[[ Applying ]]

	-- Models with a primary part store the pivot relative to that part
	if model.PrimaryPart then
		model.PrimaryPart.PivotOffset = model.PrimaryPart.CFrame:ToObjectSpace(targetPivot)
		return
	end

	model.WorldPivot = targetPivot
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Point In Region

--[[
	Returns whether a point is inside an oriented box.
]]
--- @return boolean
function World.IsPointInRegion(point: Vector3, regionCFrame: CFrame, regionSize: Vector3)
	--[[ Local Variables ]]

	local halfSize: Vector3 = regionSize / 2
	local relativePoint: Vector3 = regionCFrame:PointToObjectSpace(point)

	--[[ Returning ]]

	return math.abs(relativePoint.X) <= halfSize.X and math.abs(relativePoint.Y) <= halfSize.Y and math.abs(relativePoint.Z) <= halfSize.Z
end

--%%%%%%%%%%%%%%%%%%%% Is Point In Model

--[[
	Returns whether a point is inside the model's bounding box.
]]
--- @return boolean
function World.IsPointInModel(point: Vector3, model: Model)
	--[[ Checks ]]

	-- Check if the value is a model
	if not model or not model:IsA("Model") then
		return false
	end

	--[[ Returning ]]

	local boundingCFrame: CFrame, boundingSize: Vector3 = model:GetBoundingBox()

	return World.IsPointInRegion(point, boundingCFrame, boundingSize)
end

--%%%%%%%%%%%%%%%%%%%% Is Facing

--[[
	Returns whether `pos1` looks at `pos2` within `maxAngleDegrees`. Coincident positions count as facing.
]]
--- @return boolean
function World.IsFacing(pos1: CFrame, pos2: CFrame, maxAngleDegrees: number)
	--[[ Local Variables ]]

	local delta: Vector3 = pos2.Position - pos1.Position

	--[[ Checks ]]

	-- Treat coincident positions as facing
	if delta.Magnitude < 1e-6 then
		return true
	end

	--[[ Calculating ]]

	local dot: number = math.clamp(pos1.LookVector:Dot(delta.Unit), -1, 1)

	--[[ Returning ]]

	return math.deg(math.acos(dot)) <= maxAngleDegrees
end

return World
