--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Cosmetics"

--- @type Cosmetics_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

--[[ Snail ]]

-- The outfit the snail wears (its text), its middle, height and the camera's distance for the whole snail
local shownOutfit: string = ""
local center: Vector3 = Vector3.zero
local height: number = 0
local reach: number = 0
local camera: Camera

--[[ Camera ]]

-- Where the camera eases to (the open slot's STAGE_FOCUS) and where it is now
local target = table.clone(_settings.STAGE_FOCUS.Body) --- @type Cosmetics_Focus
local current = table.clone(_settings.STAGE_FOCUS.Body) --- @type Cosmetics_Focus

-- The player's own spin on top of it, in degrees, and the drag that's turning it
local spinYaw: number = 0
local spinPitch: number = 0
local mouseDragging: boolean = false
local touchDragging: InputObject? = nil

-- Where the drag was last frame (nil until the mouse first moves after the press)
local lastPosition: Vector3? = nil

local looping: RBXScriptConnection? = nil

--[[ General ]]

local moduleGui: ScreenGui

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

--- @class Cosmetics_Client_SkinsStage
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI[_settings.SKINS_GUI_NAME]
	elems["Stage"] = moduleGui:FindFirstChild("U_Stage", true) --- @type Frame
	elems["View"] = elems["Stage"]:FindFirstChild("S_View") --- @type ViewportFrame
	elems["Drag"] = elems["Stage"]:FindFirstChild("S_Drag") --- @type ImageButton

	--[[ Camera ]]

	camera = I.Create("Camera")({
		Parent = elems["View"],
	})
	elems["View"].CurrentCamera = camera

	--[[ Texts ]]

	elems["Stage"]:FindFirstChild("S_PlayerName").Text = I.S.Players.LocalPlayer.DisplayName

	--[[ Connections ]]

	elems["Drag"].MouseButton1Down:Connect(Module._onMouseDown)
	elems["Drag"].InputBegan:Connect(Module._onTouchBegan)
	I.S.UserInputService.InputChanged:Connect(Module._onDragChanged)
	I.S.UserInputService.InputEnded:Connect(Module._onDragEnded)
	moduleGui:GetPropertyChangedSignal("Enabled"):Connect(Module._watch)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	Puts the snail in an outfit on the stage, held in its idle pose (`I.SnailRig.Pose`); an unchanged outfit is left as
	it is.
]]
--- @param outfit Cosmetics_Outfit
function Module.Show(outfit)
	--[[ Checks ]]

	-- Skip the outfit already shown
	local text: string = I.G_Cosmetics.GetOutfitText(outfit)
	if text == shownOutfit then
		return
	end

	--[[ Building ]]

	local model: Model? = I.G_Cosmetics.BuildSnail(outfit)
	if not model then
		return
	end
	local old: Model? = elems["View"]:FindFirstChildWhichIsA("Model")
	if old then
		old:Destroy()
	end
	model:PivotTo(CFrame.identity)
	I.SnailRig.Pose(model)
	model.Parent = elems["View"]

	--[[ Saving ]]

	local box: CFrame
	local size: Vector3
	box, size = model:GetBoundingBox()
	center = box.Position
	height = size.Y
	reach = size.Magnitude * _settings.STAGE_DISTANCE
	shownOutfit = text
	Module._place()
end

--%%%%%%%%%%%%%%%%%%%% Focus

--[[
	Turns the camera to a slot's view (STAGE_FOCUS): round to the shell, down onto the hat, in on the neck piece, back for
	the whole body. It eases there, and the player's own spin starts over.
]]
function Module.Focus(slot: string)
	--[[ Saving ]]

	target = table.clone(_settings.STAGE_FOCUS[slot])
	spinYaw = 0
	spinPitch = 0
end

--%%%%%%%%%%%%%%%%%%%% Watch

--[[
	Runs the camera's easing while the Style screen shows, and stops it when the screen closes.
]]
function Module._watch()
	--[[ Looping ]]

	if moduleGui.Enabled and not looping then
		looping = I.S.RunService.RenderStepped:Connect(Module._step)
	elseif not moduleGui.Enabled and looping then
		looping:Disconnect()
		looping = nil
		mouseDragging = false
		touchDragging = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Eases the camera a frame toward the focus plus the player's spin (STAGE_EASE), and places it; a camera that has
	arrived isn't touched, so a still screen costs nothing.
]]
function Module._step(deltaTime: number)
	--[[ Local Variables ]]

	local alpha: number = 1 - math.exp(-_settings.STAGE_EASE * deltaTime)
	local yaw: number = target.Yaw + spinYaw
	local pitch: number = math.clamp(target.Pitch + spinPitch, _settings.STAGE_PITCH.Min, _settings.STAGE_PITCH.Max)

	--[[ Checks ]]

	-- Skip a camera already where it's going
	if math.abs(yaw - current.Yaw) < 0.01 and math.abs(pitch - current.Pitch) < 0.01 and math.abs(target.Zoom - current.Zoom) < 0.0005 and math.abs(target.Height - current.Height) < 0.0005 then
		return
	end

	--[[ Easing ]]

	-- A drag turns the camera at once; a new view eases in
	local turn: number = if mouseDragging or touchDragging then 1 else alpha
	current.Yaw += (yaw - current.Yaw) * turn
	current.Pitch += (pitch - current.Pitch) * turn
	current.Zoom += (target.Zoom - current.Zoom) * alpha
	current.Height += (target.Height - current.Height) * alpha

	--[[ Placing ]]

	Module._place()
end

--%%%%%%%%%%%%%%%%%%%% Place

--[[
	Puts the camera where the current view says: round the snail's middle (Yaw), above it (Pitch), at the whole snail's
	distance times Zoom, looking at a point Height of the snail up from its middle.
]]
function Module._place()
	--[[ Local Variables ]]

	local look: Vector3 = center + Vector3.new(0, height * current.Height, 0)
	local turn: CFrame = CFrame.Angles(0, math.rad(current.Yaw), 0) * CFrame.Angles(math.rad(current.Pitch), 0, 0)

	--[[ Placing ]]

	camera.CFrame = CFrame.lookAt(look + turn * Vector3.new(0, 0, -reach * current.Zoom), look)
end

--%%%%%%%%%%%%%%%%%%%% On Mouse Down

--[[
	Starts spinning the snail when the mouse button goes down on it.
]]
function Module._onMouseDown()
	--[[ Saving ]]

	mouseDragging = true
	lastPosition = nil
end

--%%%%%%%%%%%%%%%%%%%% On Touch Began

--[[
	Starts spinning the snail when a finger goes down on it.
]]
function Module._onTouchBegan(input: InputObject)
	--[[ Checks ]]

	-- Check if it's a finger
	if input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	--[[ Saving ]]

	touchDragging = input
	lastPosition = input.Position
end

--%%%%%%%%%%%%%%%%%%%% On Drag Changed

--[[
	Spins the snail with the mouse or finger: across turns it all the way round, up and down tilts it within
	STAGE_PITCH.
]]
function Module._onDragChanged(input: InputObject)
	--[[ Checks ]]

	-- Check if it moves the drag
	local mouse: boolean = mouseDragging and input.UserInputType == Enum.UserInputType.MouseMovement
	if not mouse and (touchDragging == nil or input ~= touchDragging) then
		return
	end

	--[[ Spinning ]]

	local delta: Vector3 = if lastPosition then input.Position - lastPosition else Vector3.zero
	lastPosition = input.Position
	spinYaw -= delta.X * _settings.STAGE_DRAG_SPEED
	spinPitch = math.clamp(spinPitch + delta.Y * _settings.STAGE_DRAG_SPEED * 0.5, _settings.STAGE_PITCH.Min - target.Pitch, _settings.STAGE_PITCH.Max - target.Pitch)
end

--%%%%%%%%%%%%%%%%%%%% On Drag Ended

--[[
	Stops spinning when the mouse button or the finger lets go.
]]
function Module._onDragEnded(input: InputObject)
	--[[ Saving ]]

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		mouseDragging = false
	elseif input == touchDragging then
		touchDragging = nil
	end
end

return Module
