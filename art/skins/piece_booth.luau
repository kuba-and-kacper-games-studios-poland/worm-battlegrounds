--[[
	The snail pieces' picture booth (README → Pieces → Pictures). Run it in a playtest's client as a LocalScript (its
	Source set to this file), since it uses the game's own Cosmetics: each piece on Cosmetics' showcase snail
	(`BuildSnail` of `GetShowcase`), posed in its idle frame (`I.SnailRig.Pose`) and framed by `GetPieceShot`, exactly
	as a Crates card's S_Model shows it, six to a screen in 600 x 480 slots, in piece id order. Paint the booth black and
	white for each screen and capture both; make_pictures.py pieces turns the captures into pictures.

	_G.PieceBooth.Paint(Color3.new(0, 0, 0)) / Paint(Color3.new(1, 1, 1)), _G.PieceBooth.Screen(n) for screens 1 to 5,
	or set the LocalPlayer's BoothCommand attribute to "<n>:black" / "<n>:white" (both at once).
]]

local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local playerGui = game:GetService("Players").LocalPlayer.PlayerGui

-- Every piece, in id order (make_pictures.py reads the same order from the booth's printout)
local order = {}
for pieceId in pairs(I.G_Cosmetics.GetPieces()) do
	table.insert(order, pieceId)
end
table.sort(order)

local old = playerGui:FindFirstChild("PieceBooth")
if old then
	old:Destroy()
end
local gui = Instance.new("ScreenGui")
gui.Name = "PieceBooth"
gui.DisplayOrder = 1000
gui.IgnoreGuiInset = true
gui.Parent = playerGui
local back = Instance.new("Frame")
back.Size = UDim2.fromScale(1, 1)
back.BorderSizePixel = 0
back.Parent = gui

local slots = {}
for index, pieceId in order do
	local place = (index - 1) % 6
	local viewport = Instance.new("ViewportFrame")
	viewport.Name = pieceId
	viewport.Size = UDim2.fromOffset(600, 480)
	viewport.Position = UDim2.fromOffset(60 + (place % 3) * 620, 90 + math.floor(place / 3) * 500)
	viewport.BorderSizePixel = 0
	viewport.Ambient = Color3.fromRGB(150, 150, 158)
	viewport.LightColor = Color3.fromRGB(235, 235, 235)
	viewport.LightDirection = Vector3.new(-5, -9, 7)
	viewport.Visible = index <= 6

	local model = I.G_Cosmetics.BuildSnail(I.G_Cosmetics.GetShowcase(pieceId))
	model:PivotTo(CFrame.identity)
	I.SnailRig.Pose(model)
	local camera = Instance.new("Camera")
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	camera.CFrame = I.G_Cosmetics.GetPieceShot(model, pieceId)
	model.Parent = viewport
	viewport.Parent = gui
	table.insert(slots, viewport)
end

_G.PieceBooth = {
	Order = order,
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
_G.PieceBooth.Paint(Color3.new(0, 0, 0))
local player = game:GetService("Players").LocalPlayer
player:SetAttribute("PieceBooth", table.concat(order, ","))

-- Driven from Studio's command bar or MCP too: the player's BoothCommand attribute "<screen>:black" or "<screen>:white"
player:GetAttributeChangedSignal("BoothCommand"):Connect(function()
	local screen, paint = string.match(player:GetAttribute("BoothCommand") or "", "^(%d+):(%a+)$")
	if screen then
		_G.PieceBooth.Screen(tonumber(screen))
		_G.PieceBooth.Paint(if paint == "white" then Color3.new(1, 1, 1) else Color3.new(0, 0, 0))
	end
end)
