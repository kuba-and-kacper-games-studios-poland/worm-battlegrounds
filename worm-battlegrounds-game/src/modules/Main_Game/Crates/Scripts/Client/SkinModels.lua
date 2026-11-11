--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Crates"

--- @type Crates_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ State ]]

-- Each item's snail model name, or false for an item with no snail (worked out once)
local names = {} --- @type { [string]: string | boolean }

-- Posed snails taken off cards, by model name, ready for the next card that shows that skin
local pool = {} --- @type { [string]: { Model } }

-- The snail each card shows now (weak keys, so a destroyed card lets its snail go)
local held = setmetatable({}, { __mode = "k" }) --- @type { [GuiObject]: Crates_HeldSnail }

-- The loop that draws settled snails again, while the Crates screen shows
local watching: RBXScriptConnection? = nil

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

--- @class Crates_Client_SkinModels
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI[_settings.GUI_NAME]

	--[[ Connections ]]

	moduleGui:GetPropertyChangedSignal("Enabled"):Connect(Module._watch)
	Module._watch()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Put

--[[
	Shows a skin's snail on a card, posed in its idle frame and framed as the Skins window frames it (from the front, a
	little from above), in the card's S_Model viewport; a card that shows one already keeps it. It's drawn again each
	time the card settles where it's seen (Redraw).
]]
function Module.Put(card: GuiObject, itemId: string)
	--[[ Checks ]]

	-- Check if the card shows a snail already
	if held[card] then
		return
	end

	--[[ Data ]]

	local name: string? = Module.GetModelName(itemId)
	if not name then
		return
	end

	--[[ Local Variables ]]

	local viewport: ViewportFrame = card:FindFirstChild("S_Model", true)
	local model: Model = Module.Take(name)

	--[[ Camera ]]

	local camera: Camera? = viewport.CurrentCamera
	if not camera then
		camera = Instance.new("Camera")
		camera.Parent = viewport
		viewport.CurrentCamera = camera
	end
	local box: CFrame
	local size: Vector3
	box, size = model:GetBoundingBox()
	camera.CFrame = CFrame.lookAt(box.Position + Vector3.new(0, size.Y * 0.2, -size.Magnitude * I.Settings["Cosmetics"].PREVIEW_DISTANCE), box.Position)

	--[[ Placing ]]

	model.Parent = viewport
	held[card] = {
		Model = model,
		Viewport = viewport,
		Camera = camera,
		Shot = camera.CFrame,
		Shown = false,
		Position = Vector2.zero,
		Size = Vector2.zero,
		Still = 0,
		Drawn = false,
		Nudged = false,
	}
end

--%%%%%%%%%%%%%%%%%%%% Release

--[[
	Takes a card's snail away and keeps it in the pool for the next card that shows that skin.
]]
function Module.Release(card: GuiObject)
	--[[ Data ]]

	local snail = held[card] --- @type Crates_HeldSnail?
	if not snail then
		return
	end

	--[[ Pooling ]]

	held[card] = nil
	Module.Store(snail.Model)
end

--%%%%%%%%%%%%%%%%%%%% Take

--[[
	Returns a posed snail of a skin (by model name), its pivot at the origin: a spare one from the pool, or a new clone
	held in its idle frame (`I.SnailRig.Pose`).
]]
--- @return Model
function Module.Take(name: string)
	--[[ Pooling ]]

	local spare = pool[name] --- @type { Model }?
	if spare and #spare > 0 then
		local model: Model = table.remove(spare)
		model:PivotTo(CFrame.identity)
		return model
	end

	--[[ Cloning ]]

	local model: Model = I.Dirs.Assets:FindFirstChild("Skins"):FindFirstChild(name):Clone()
	model:PivotTo(CFrame.identity)
	I.SnailRig.Pose(model)

	--[[ Returning ]]

	return model
end

--%%%%%%%%%%%%%%%%%%%% Store

--[[
	Keeps a snail taken off the screen in the pool, for the next card that shows that skin.
]]
function Module.Store(model: Model)
	--[[ Pooling ]]

	model.Parent = nil
	pool[model.Name] = pool[model.Name] or {}
	table.insert(pool[model.Name], model)
end

--%%%%%%%%%%%%%%%%%%%% Watch

--[[
	Runs the redraw loop (Redraw) while the Crates screen shows, and stops it when the screen closes.
]]
function Module._watch()
	--[[ Looping ]]

	if moduleGui.Enabled and not watching then
		watching = I.S.RunService.RenderStepped:Connect(Module._redraw)
	elseif not moduleGui.Enabled and watching then
		watching:Disconnect()
		watching = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Redraw

--[[
	Draws a card's snail again once the card has held still where it's seen for SKIN_REDRAW_FRAMES, after it moved,
	changed size or came into view: its camera moves a hair (back and forth). Roblox doesn't draw a viewport that
	changed while it moved or was hidden until it changes again where it's seen, so a card that flew into place, or
	came back into view, kept an empty picture box.
]]
function Module._redraw()
	--[[ Drawing ]]

	--- @param snail Crates_HeldSnail
	for _card: GuiObject, snail in pairs(held) do
		local shown: boolean = I.Utils.IsGuiShown(snail.Viewport)
		local position: Vector2 = snail.Viewport.AbsolutePosition
		local size: Vector2 = snail.Viewport.AbsoluteSize
		if shown ~= snail.Shown or position ~= snail.Position or size ~= snail.Size then
			snail.Shown = shown
			snail.Position = position
			snail.Size = size
			snail.Still = 0
			snail.Drawn = false
		elseif shown and not snail.Drawn then
			snail.Still += 1
			if snail.Still >= _settings.SKIN_REDRAW_FRAMES then
				snail.Drawn = true
				snail.Nudged = not snail.Nudged
				snail.Camera.CFrame = snail.Shot * CFrame.new(0, 0, if snail.Nudged then 0.001 else 0)
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Model Name

--[[
	Returns the name of an item's snail in Assets/Skins: its skin row's Model, when the place has that snail; nil for an
	item that isn't a skin or a skin with no snail yet (it keeps its picture).
]]
--- @return string?
function Module.GetModelName(itemId: string)
	--[[ Checks ]]

	-- Check if it was worked out already
	if names[itemId] ~= nil then
		return names[itemId] or nil
	end

	--[[ Data ]]

	local skin = I.G_Cosmetics.GetSkins()[itemId] --- @type Cosmetics_SkinData?
	local skins: Instance? = I.Dirs.Assets:FindFirstChild("Skins")

	--[[ Saving ]]

	names[itemId] = if skin and skins and skins:FindFirstChild(skin.Model) then skin.Model else false

	--[[ Returning ]]

	return names[itemId] or nil
end

return Module
