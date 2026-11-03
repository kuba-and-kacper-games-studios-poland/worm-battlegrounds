--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(script:FindFirstAncestor("Libs"):FindFirstChild("Runtime"))
local _localName = "Utils"

--- @type UmeGui_Utils_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local RunService = I.S.RunService
local CollectionService = I.S.CollectionService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local GuiVisibility = require(script.Parent:FindFirstChild("GuiVisibility")) --- @type UmeGui_Utils_GuiVisibility

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Tags ]]

local UISTROKE_TAG: string = "Utils_UIStroke-Billboard"

-- The attribute a stroke keeps its built thickness in
local ORIGINAL_THICKNESS: string = "StrokeScaler_OriginalThickness"

--[[ Scaling ]]

-- Seconds between two rescales of every stroke
local UPDATE_DELAY: number = 0.1

-- The camera distance at which a stroke keeps its built thickness; it thins further away
local REFERENCE_DISTANCE: number = 30

--[[ Screen ]]

local defaultScreenValue: number
local currentScreenValue: number

--[[ Strokes ]]

-- Each scaled stroke and the BillboardGui it sits in
local billboardMap = {} --- @type { [UIStroke]: BillboardGui }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Min

--[[
	Returns the smaller side of a screen size.
]]
--- @return number
local function getMin(screenSize: Vector2)
	return math.min(screenSize.X, screenSize.Y)
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

--- @class UmeGui_Utils_UIStrokeScaler_Billboard
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	defaultScreenValue = getMin(_settings.DEFAULT_VIEWPORT_SIZE)
	currentScreenValue = getMin(I.Env.Camera.ViewportSize)

	Module._connectTag()
	Module._connectViewport()
	Module._mainLoop()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Main Loop

--[[
	Rescales every stroke each `UPDATE_DELAY` seconds, as the camera moves.
]]
function Module._mainLoop()
	--[[ Local Variables ]]

	local lastUpdate: number = os.clock()

	--[[ Connections ]]

	RunService.RenderStepped:Connect(function(_deltaTime: number)
		-- Skip until the delay passed
		if os.clock() < lastUpdate + UPDATE_DELAY then
			return
		end

		lastUpdate = os.clock()
		Module._resizeAll()
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Connect Tag

--[[
	Scales every stroke already tagged, each one tagged later, and gives an untagged stroke its built thickness back.
]]
function Module._connectTag()
	--[[ Existing ]]

	for _index: number, instance: Instance in ipairs(CollectionService:GetTagged(UISTROKE_TAG)) do
		Module._addStroke(instance)
	end

	--[[ Connections ]]

	CollectionService:GetInstanceAddedSignal(UISTROKE_TAG):Connect(Module._addStroke)
	CollectionService:GetInstanceRemovedSignal(UISTROKE_TAG):Connect(Module._removeStroke)
end

--%%%%%%%%%%%%%%%%%%%% Connect Viewport

--[[
	Rescales every stroke when the screen size changes.
]]
function Module._connectViewport()
	--[[ Connections ]]

	I.Env.Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		currentScreenValue = getMin(I.Env.Camera.ViewportSize)
		Module._resizeAll()
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Add Stroke

--[[
	Keeps a tagged stroke's built thickness and its BillboardGui, warning on an instance that isn't a UIStroke inside one.
]]
function Module._addStroke(instance: Instance)
	--[[ Checks ]]

	-- Check if the instance is a UIStroke
	if not instance:IsA("UIStroke") then
		warn(`[{_localName}::{script.Name}]: ({instance.Name}) is not a (UIStroke)! -`, instance)
		return
	end

	local billboard: BillboardGui? = instance:FindFirstAncestorOfClass("BillboardGui")

	-- Check if the stroke sits in a BillboardGui
	if not billboard then
		warn(`[{_localName}::{script.Name}]: ({instance.Name}) is not parented under a (BillboardGui)! -`, instance)
		return
	end

	--[[ Saving ]]

	-- Keep the built thickness on the first tag
	if not instance:GetAttribute(ORIGINAL_THICKNESS) then
		instance:SetAttribute(ORIGINAL_THICKNESS, instance.Thickness)
	end

	billboardMap[instance] = billboard

	--[[ Resizing ]]

	Module._resize(instance, billboard)
end

--%%%%%%%%%%%%%%%%%%%% Remove Stroke

--[[
	Stops scaling an untagged stroke and gives it its built thickness back.
]]
function Module._removeStroke(instance: Instance)
	--[[ Checks ]]

	-- Skip an instance that was never scaled
	if not billboardMap[instance] then
		return
	end

	--[[ Restoring ]]

	billboardMap[instance] = nil
	instance.Thickness = instance:GetAttribute(ORIGINAL_THICKNESS) or instance.Thickness
end

--%%%%%%%%%%%%%%%%%%%% Resize All

--[[
	Rescales every stored stroke.
]]
function Module._resizeAll()
	--[[ Resizing ]]

	for stroke: UIStroke, billboard: BillboardGui in pairs(billboardMap) do
		Module._resize(stroke, billboard)
	end
end

--%%%%%%%%%%%%%%%%%%%% Resize

--[[
	Thins a stroke with the camera's distance to its billboard and the screen size, never above its built thickness.
	Leaves it alone while it is hidden or the billboard is out of range.
]]
function Module._resize(stroke: UIStroke, billboard: BillboardGui)
	--[[ Checks ]]

	-- Skip a stroke whose billboard is disabled or that sits in a hidden frame
	if not GuiVisibility.IsShown(stroke) then
		return
	end

	local origin: Vector3? = Module._getOrigin(billboard.Adornee or billboard.Parent)

	-- Skip a billboard with nothing in the world to measure from
	if not origin then
		return
	end

	local distance: number = (I.Env.Camera.CFrame.Position - origin).Magnitude

	-- Skip a billboard out of its MaxDistance (0 is unlimited)
	if billboard.MaxDistance > 0 and distance > billboard.MaxDistance then
		return
	end

	--[[ Calculating ]]

	local originalThickness: number = tonumber(stroke:GetAttribute(ORIGINAL_THICKNESS)) or stroke.Thickness
	local distanceRatio: number = REFERENCE_DISTANCE / math.max(distance, 1e-4)
	local screenRatio: number = currentScreenValue / math.max(defaultScreenValue, 1e-6)

	--[[ Applying ]]

	stroke.Thickness = math.min(originalThickness * distanceRatio * screenRatio, originalThickness)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Origin

--[[
	Returns the world position of a billboard's adornee or parent: a part, a model's pivot or an attachment; nil for
	anything else.
]]
--- @return Vector3?
function Module._getOrigin(instance: Instance?)
	--[[ Returning ]]

	if not instance then
		return nil
	end

	if instance:IsA("BasePart") then
		return instance.Position
	end

	if instance:IsA("Model") then
		return instance:GetPivot().Position
	end

	if instance:IsA("Attachment") then
		return instance.WorldCFrame.Position
	end

	return nil
end

return Module
