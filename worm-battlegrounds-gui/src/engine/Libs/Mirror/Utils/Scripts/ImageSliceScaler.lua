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

local SLICEDIMAGE_TAG: string = "Utils_SlicedImage"

-- The attribute an image keeps its built slice scale in
local ORIGINAL_SCALE: string = "ImageSliceScaler_OriginalScale"

--[[ Screen ]]

local defaultScreenAverage: number
local currentScreenAverage: number

--[[ Images ]]

local storedImages = {} --- @type { [ImageLabel | ImageButton]: boolean }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Screen Average

--[[
	Returns the average of a screen size's sides.
]]
--- @return number
local function getScreenAverage(screenSize: Vector2)
	return (screenSize.X + screenSize.Y) / 2
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

--- @class UmeGui_Utils_ImageSliceScaler
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	defaultScreenAverage = getScreenAverage(_settings.DEFAULT_VIEWPORT_SIZE)
	currentScreenAverage = getScreenAverage(I.Env.Camera.ViewportSize)

	Module._connectTag()
	Module._connectViewport()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Connect Tag

--[[
	Scales every image already tagged, each one tagged later, and gives an untagged image its built slice scale back.
]]
function Module._connectTag()
	--[[ Existing ]]

	for _index: number, instance: Instance in ipairs(CollectionService:GetTagged(SLICEDIMAGE_TAG)) do
		Module._addImage(instance)
	end

	--[[ Connections ]]

	CollectionService:GetInstanceAddedSignal(SLICEDIMAGE_TAG):Connect(Module._addImage)
	CollectionService:GetInstanceRemovedSignal(SLICEDIMAGE_TAG):Connect(Module._removeImage)
end

--%%%%%%%%%%%%%%%%%%%% Connect Viewport

--[[
	Rescales every image when the screen size changes.
]]
function Module._connectViewport()
	--[[ Connections ]]

	I.Env.Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		currentScreenAverage = getScreenAverage(I.Env.Camera.ViewportSize)

		for image: ImageLabel | ImageButton, _stored: boolean in pairs(storedImages) do
			Module._resize(image)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Add Image

--[[
	Keeps a tagged image's built slice scale and scales it, warning on an instance that isn't an image.
]]
function Module._addImage(instance: Instance)
	--[[ Checks ]]

	-- Check if the instance is an ImageLabel or ImageButton
	if not instance:IsA("ImageLabel") and not instance:IsA("ImageButton") then
		warn(`[{_localName}::{script.Name}]: ({instance.Name}) is not an (ImageLabel) or (ImageButton)! -`, instance)
		return
	end

	--[[ Saving ]]

	-- Keep the built slice scale on the first tag
	if not instance:GetAttribute(ORIGINAL_SCALE) then
		instance:SetAttribute(ORIGINAL_SCALE, instance.SliceScale)
	end

	storedImages[instance] = true

	--[[ Resizing ]]

	Module._resize(instance)
end

--%%%%%%%%%%%%%%%%%%%% Remove Image

--[[
	Stops scaling an untagged image and gives it its built slice scale back.
]]
function Module._removeImage(instance: Instance)
	--[[ Checks ]]

	-- Skip an instance that was never scaled
	if not storedImages[instance] then
		return
	end

	--[[ Restoring ]]

	storedImages[instance] = nil
	instance.SliceScale = instance:GetAttribute(ORIGINAL_SCALE) or instance.SliceScale
end

--%%%%%%%%%%%%%%%%%%%% Resize

--[[
	Sets an image's slice scale to its built scale, scaled by the screen's average side against the reference size.
]]
function Module._resize(image: ImageLabel | ImageButton)
	--[[ Calculating ]]

	local originalScale: number = tonumber(image:GetAttribute(ORIGINAL_SCALE)) or 1
	local screenRatio: number = currentScreenAverage / math.max(defaultScreenAverage, 1e-6)

	--[[ Applying ]]

	image.SliceScale = originalScale * screenRatio
end

return Module
