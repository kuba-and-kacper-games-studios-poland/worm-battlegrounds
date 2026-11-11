--[[
	The skin snails' picture booth (README → Pictures). Run in a playtest's client (Studio's MCP execute_luau, Client).
	It shows each snail posed in Idle's first frame (as SnailRig.Pose holds it), framed and lit as a Crates card's
	S_Model viewport (SkinModels.Put, Cosmetics' PREVIEW_DISTANCE), six to a screen in 600 x 480 slots. Paint the booth
	black and white for each screen and capture both; make_pictures.py turns the captures into pictures.

	_G.SnailBooth.Paint(Color3.new(0, 0, 0)) / Paint(Color3.new(1, 1, 1)), _G.SnailBooth.Screen(2) for the last four.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerGui = game:GetService("Players").LocalPlayer.PlayerGui

-- The snails, in make_pictures.py's ORDER
local ORDER = { "Classic", "Soldier", "Pirate", "Cowboy", "Ninja", "Knight", "Clown", "Devil", "Robot", "Skeleton" }

local skins = ReplicatedStorage:FindFirstChild("Skins", true)
local animations = ReplicatedStorage:FindFirstChild("Snails", true):FindFirstChild("Animations")
local keyframes = animations:FindFirstChild("Idle"):FindFirstChildOfClass("KeyframeSequence")

-- Idle's first frame (GetKeyframes isn't in time order)
local first = nil
for _, keyframe in keyframes:GetKeyframes() do
	if not first or keyframe.Time < first.Time then
		first = keyframe
	end
end
local poses = {}
for _, pose in first:GetDescendants() do
	if pose:IsA("Pose") then
		poses[pose.Name] = pose.CFrame
	end
end

local old = playerGui:FindFirstChild("SnailBooth")
if old then
	old:Destroy()
end
local gui = Instance.new("ScreenGui")
gui.Name = "SnailBooth"
gui.DisplayOrder = 1000
gui.IgnoreGuiInset = true
gui.Parent = playerGui
local back = Instance.new("Frame")
back.Size = UDim2.fromScale(1, 1)
back.BorderSizePixel = 0
back.Parent = gui

local slots = {}
for index, name in ORDER do
	local place = (index - 1) % 6
	local viewport = Instance.new("ViewportFrame")
	viewport.Name = name
	viewport.Size = UDim2.fromOffset(600, 480)
	viewport.Position = UDim2.fromOffset(60 + (place % 3) * 620, 90 + math.floor(place / 3) * 500)
	viewport.BorderSizePixel = 0
	viewport.Ambient = Color3.fromRGB(150, 150, 158)
	viewport.LightColor = Color3.fromRGB(235, 235, 235)
	viewport.LightDirection = Vector3.new(-5, -9, 7)
	viewport.Visible = index <= 6

	-- Posed as SnailRig.Pose holds it: the pose's moves scaled with the model
	local model = skins:FindFirstChild(name):Clone()
	model:PivotTo(CFrame.identity)
	local scale = model:GetScale()
	for _, bone in model.PrimaryPart:GetDescendants() do
		local pose = poses[bone.Name]
		if bone:IsA("Bone") and pose then
			bone.Transform = pose.Rotation + pose.Position * scale
		end
	end

	-- Framed as SkinModels.Put frames it (the default camera's 70° field of view)
	local camera = Instance.new("Camera")
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	local box, size = model:GetBoundingBox()
	camera.CFrame = CFrame.lookAt(box.Position + Vector3.new(0, size.Y * 0.2, -size.Magnitude * 0.6), box.Position)
	model.Parent = viewport
	viewport.Parent = gui
	table.insert(slots, viewport)
end

_G.SnailBooth = {
	Paint = function(color)
		back.BackgroundColor3 = color
		for _, viewport in slots do
			viewport.BackgroundColor3 = color
		end
	end,
	Screen = function(screen)
		for index, viewport in slots do
			viewport.Visible = math.ceil(index / 6) == screen
		end
	end,
}
_G.SnailBooth.Paint(Color3.new(0, 0, 0))
