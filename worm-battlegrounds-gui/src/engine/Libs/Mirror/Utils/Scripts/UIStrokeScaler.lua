--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(script:FindFirstAncestor("Libs"):FindFirstChild("Runtime"))
local _localName = "Utils"

--- @type UmeGui_Utils_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local CollectionService = I.S.CollectionService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Tags ]]

local UISTROKE_TAG: string = "Utils_UIStroke"

-- The attribute a stroke keeps its built thickness in
local ORIGINAL_THICKNESS: string = "StrokeScaler_OriginalThickness"

--[[ Screen ]]

local defaultScreenValue: number
local currentScreenValue: number

--[[ Strokes ]]

local storedStrokes = {} --- @type { [UIStroke]: boolean }

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

--- @class UmeGui_Utils_UIStrokeScaler
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

		for stroke: UIStroke, _stored: boolean in pairs(storedStrokes) do
			Module._resize(stroke)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Add Stroke

--[[
	Keeps a tagged stroke's built thickness and scales it, warning on an instance that isn't a UIStroke.
]]
function Module._addStroke(instance: Instance)
	--[[ Checks ]]

	-- Check if the instance is a UIStroke
	if not instance:IsA("UIStroke") then
		warn(`[{_localName}::{script.Name}]: ({instance.Name}) is not a (UIStroke)! -`, instance)
		return
	end

	--[[ Saving ]]

	-- Keep the built thickness on the first tag
	if not instance:GetAttribute(ORIGINAL_THICKNESS) then
		instance:SetAttribute(ORIGINAL_THICKNESS, instance.Thickness)
	end

	storedStrokes[instance] = true

	--[[ Resizing ]]

	Module._resize(instance)
end

--%%%%%%%%%%%%%%%%%%%% Remove Stroke

--[[
	Stops scaling an untagged stroke and gives it its built thickness back.
]]
function Module._removeStroke(instance: Instance)
	--[[ Checks ]]

	-- Skip an instance that was never scaled
	if not storedStrokes[instance] then
		return
	end

	--[[ Restoring ]]

	storedStrokes[instance] = nil
	instance.Thickness = instance:GetAttribute(ORIGINAL_THICKNESS) or instance.Thickness
end

--%%%%%%%%%%%%%%%%%%%% Resize

--[[
	Sets a stroke's thickness to its built thickness, scaled by the screen's smaller side against the reference size.
]]
function Module._resize(stroke: UIStroke)
	--[[ Calculating ]]

	local originalThickness: number = tonumber(stroke:GetAttribute(ORIGINAL_THICKNESS)) or 1
	local screenRatio: number = currentScreenValue / math.max(defaultScreenValue, 1e-6)

	--[[ Applying ]]

	stroke.Thickness = originalThickness * screenRatio
end

return Module
