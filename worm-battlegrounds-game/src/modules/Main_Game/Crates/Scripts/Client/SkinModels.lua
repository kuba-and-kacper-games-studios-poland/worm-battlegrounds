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

-- Each item's snail (the piece's own id), or false for an item that isn't a snail piece (worked out once)
local names = {} --- @type { [string]: string | boolean }

-- Posed snails taken off cards, by the piece they show, ready for the next card that shows that piece
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
	Shows a snail wearing a piece on a card, posed in its idle frame and framed as the Style screen frames that slot, in
	the card's S_Model viewport; a card that shows one already keeps it. It's drawn again each time the card settles
	where it's seen (Redraw).
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
	camera.CFrame = I.G_Cosmetics.GetPieceShot(model, name)

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
	Takes a card's snail away and keeps it in the pool for the next card that shows that piece.
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
	Returns a posed snail wearing a piece (by its id, on Cosmetics' showcase outfit), its pivot at the origin: a spare
	one from the pool, or a new one held in its idle frame (`I.SnailRig.Pose`).
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

	local model: Model = I.G_Cosmetics.BuildSnail(I.G_Cosmetics.GetShowcase(name))
	model.Name = name
	model:PivotTo(CFrame.identity)
	I.SnailRig.Pose(model)

	--[[ Returning ]]

	return model
end

--%%%%%%%%%%%%%%%%%%%% Store

--[[
	Keeps a snail taken off the screen in the pool, for the next card that shows that piece.
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
	Returns the snail an item shows on a card: the piece's own id, when the place has its set's snail; nil for an item
	that isn't a snail piece (it keeps its picture).
]]
--- @return string?
function Module.GetModelName(itemId: string)
	--[[ Checks ]]

	-- Check if it was worked out already
	if names[itemId] ~= nil then
		return names[itemId] or nil
	end

	--[[ Data ]]

	local piece = I.G_Cosmetics.GetPieces()[itemId] --- @type Cosmetics_PieceData?
	local skins: Instance? = I.Dirs.Assets:FindFirstChild("Skins")

	--[[ Saving ]]

	names[itemId] = if piece and skins and skins:FindFirstChild(I.G_Cosmetics.GetSet(piece.Set).Model) then itemId else false

	--[[ Returning ]]

	return names[itemId] or nil
end

--%%%%%%%%%%%%%%%%%%%% Get Picture

--[[
	Returns the picture a rolling reel's card shows for a snail piece (PIECE_PICTURES); nil for any other item.
]]
--- @return string?
function Module.GetPicture(itemId: string)
	return _settings.PIECE_PICTURES[itemId]
end

return Module
