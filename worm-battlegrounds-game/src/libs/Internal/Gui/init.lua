--[[
    Created By:     Nari
]]

local _localName = "Gui"

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

--- @class Ume_Library_Gui : Ume_Library
local Gui = {}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Assigns this library onto Ume.
]]
--- @param umeInstance Ume
function Gui._injectUme(umeInstance)
	--- @type Ume
	local I = umeInstance

	--[[ Assigning ]]

	I.Gui = Gui --- @type Ume_Library_Gui
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Fit Model To Viewport Camera

--[[
	Scales and places a model so it appears `x` by `y` studs wide in the camera view, accounting for `rotation`.
	Mutates the model (ScaleTo, PivotTo), so pass a preview clone rather than a live gameplay model.
]]
function Gui.FitModelToViewportCamera(model: Model, camera: Camera, rotation: CFrame, x: number?, y: number?)
	--[[ Checks ]]

	-- Check if a model and camera were passed
	if not model or not camera then
		warn(`[{_localName}::{script.Name}]: (model) and (camera) are required!`)
		return
	end

	-- Check if at least one target dimension was passed
	if not x and not y then
		warn(`[{_localName}::{script.Name}]: No (x) or (y) dimensions were provided!`)
		return
	end

	--[[ Measuring ]]

	model:ScaleTo(1)

	local _boundingCFrame: CFrame, boundingSize: Vector3 = model:GetBoundingBox()
	local halfSize: Vector3 = boundingSize * 0.5
	local minCorner: Vector3 = Vector3.one * math.huge
	local maxCorner: Vector3 = -Vector3.one * math.huge

	for signX: number = -1, 1, 2 do
		for signY: number = -1, 1, 2 do
			for signZ: number = -1, 1, 2 do
				local corner: Vector3 = camera.CFrame:VectorToObjectSpace(rotation:VectorToWorldSpace(halfSize * Vector3.new(signX, signY, signZ)))
				minCorner = minCorner:Min(corner)
				maxCorner = maxCorner:Max(corner)
			end
		end
	end

	--[[ Calculating Distance ]]

	local apparentSize: Vector3 = maxCorner - minCorner
	local fovFactor: number = 1 / (2 * math.tan(math.rad(camera.FieldOfView) * 0.5))
	local distanceX: number = if x and x > 0 then (apparentSize.X / x) * fovFactor else 0
	local distanceY: number = if y and y > 0 then (apparentSize.Y / y) * fovFactor else 0

	--[[ Positioning ]]

	local target: CFrame = camera.CFrame * CFrame.new(0, 0, -math.max(distanceX, distanceY))
	model:PivotTo(CFrame.new(target.Position) * rotation.Rotation)

	local centeredCFrame: CFrame = model:GetBoundingBox()
	local shift: Vector3 = target.Position - centeredCFrame.Position
	model:PivotTo(CFrame.new(model:GetPivot().Position + shift) * rotation.Rotation)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Mouse Over Object

--[[
	**CLIENT** |
	Returns whether the mouse is inside the GuiObject's absolute rect.
]]
--- @return boolean
function Gui.IsMouseOverObject(mouse: Mouse, guiObject: GuiObject)
	--[[ Checks ]]

	-- Check if a mouse and gui object were passed
	if not mouse or not guiObject then
		warn(`[{_localName}::{script.Name}]: No (mouse) or (guiObject) were provided!`)
		return false
	end

	--[[ Local Variables ]]

	local position: Vector2 = guiObject.AbsolutePosition
	local size: Vector2 = guiObject.AbsoluteSize

	--[[ Returning ]]

	return mouse.X >= position.X and mouse.X < position.X + size.X and mouse.Y >= position.Y and mouse.Y < position.Y + size.Y
end

return Gui
