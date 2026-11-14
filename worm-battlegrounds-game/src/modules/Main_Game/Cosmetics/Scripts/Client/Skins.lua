--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Cosmetics"

--- @type Cosmetics_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local SkinsStage = require(script.Parent:FindFirstChild("SkinsStage")) --- @type Cosmetics_Client_SkinsStage

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

--[[ State ]]

-- The open category and the piece picked last (shown in the detail bar)
local openSlot: string = "Hat"
local picked: string = ""

-- What each viewport shows now (the outfit's text and the piece it's framed on), so an unchanged one isn't rebuilt
local shown = setmetatable({}, { __mode = "k" }) --- @type { [ViewportFrame]: string }

-- The last redraw asked for (Redraw), so only the newest one runs
local redrawCount: number = 0

-- The grid's tiles by piece ("" for none), and the list they were made for: the same list keeps its tiles and snails
local tiles = {} --- @type { [string]: ImageButton }
local tilesFor: string = ""

-- The pieces the player has seen (their Cosmetics folder's Seen); an owned piece missing here is NEW
local seen = {} --- @type { [string]: boolean }

--[[ General ]]

local moduleGui: ScreenGui
local moduleRep: Folder?

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

--- @class Cosmetics_Client_Skins
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI[_settings.SKINS_GUI_NAME]
	elems["Decks"] = moduleGui:FindFirstChild("U_Decks", true) --- @type Frame
	elems["Stage"] = moduleGui:FindFirstChild("U_Stage", true) --- @type Frame
	elems["Panel"] = moduleGui:FindFirstChild("U_Panel", true) --- @type Frame
	elems["Pieces"] = moduleGui:FindFirstChild("U_Pieces", true) --- @type ScrollingFrame
	elems["Detail"] = moduleGui:FindFirstChild("U_Detail", true) --- @type Frame
	prefabs["PieceTile"] = elems["Pieces"]:FindFirstChild("PREFAB | PieceTile") --- @type ImageButton
	elems["StyleNew"] = I.UserInterface.UI[_settings.LOBBY_GUI_NAME]:FindFirstChild("S_Style", true):FindFirstChild("S_New") --- @type Frame

	--[[ State ]]

	-- The starter body, until the screen first opens on the worn piece
	picked = _settings.DEFAULT_OUTFIT.Body
	SkinsStage.Start()

	--[[ Connections ]]

	for _index: number, slot: string in ipairs(_settings.SLOTS) do
		I.Interact.OnPress(elems["Decks"]:FindFirstChild("U_Deck" .. slot), function()
			Module._openCategory(slot)
		end)
	end
	I.Interact.OnPress(elems["Detail"]:FindFirstChild("S_Action"), Module._onAction)
	I.Topic.Subscribe("WidgetManager_Opened", Module._onOpened)
	I.Topic.Subscribe("Inventory_DataUpdated-Standard", Module._refresh)
	I.S.Players.LocalPlayer:GetAttributeChangedSignal("Outfit"):Connect(Module._refresh)
	moduleGui:GetPropertyChangedSignal("Enabled"):Connect(Module._onEnabledChanged)
	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Follows the player's Cosmetics folder: the pieces they've seen.
]]
function Module._connectReplicator()
	--[[ Data ]]

	moduleRep = I.Replicator.GetFolder(_localName)
	if not moduleRep then
		return
	end

	--[[ Connections ]]

	moduleRep:GetAttributeChangedSignal("Seen"):Connect(Module._refresh)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Opened

--[[
	Draws the Style screen when it opens, on the category left open, its worn piece picked.
]]
function Module._onOpened(widgetName: string)
	--[[ Checks ]]

	-- Check if it's the Style screen
	if widgetName ~= _settings.SKINS_GUI_NAME then
		return
	end

	--[[ Drawing ]]

	Module._openCategory(openSlot)
end

--%%%%%%%%%%%%%%%%%%%% Open Category

--[[
	Opens a category: its deck lights and fans out, its pieces fill the grid, its worn piece (or its first) is picked,
	and the camera turns to it.
]]
function Module._openCategory(slot: string)
	--[[ Local Variables ]]

	local outfit = Module._getOutfit() --- @type Cosmetics_Outfit

	--[[ Seeing ]]

	-- Leaving a deck sees its new pieces
	if slot ~= openSlot then
		Module._see(openSlot)
	end

	--[[ Saving ]]

	openSlot = slot
	picked = if outfit[slot] ~= "" then outfit[slot] else Module._getSlotPieces(slot)[1]

	--[[ Drawing ]]

	SkinsStage.Focus(slot)
	Module._draw()
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Shows the lobby STYLE button's NEW tag while any owned piece is unseen, and redraws the Style screen while it shows,
	when the outfit, the inventory or the seen pieces change.
]]
function Module._refresh()
	--[[ Seen ]]

	seen = {}
	for _index: number, pieceId: string in ipairs(string.split(if moduleRep then moduleRep:GetAttribute("Seen") or "" else "", ",")) do
		seen[pieceId] = true
	end
	local anyNew: boolean = false

	--- @param _piece Cosmetics_PieceData
	for pieceId: string, _piece in pairs(I.G_Cosmetics.GetPieces()) do
		anyNew = anyNew or Module._isNew(pieceId)
	end
	elems["StyleNew"].Visible = anyNew

	--[[ Checks ]]

	-- Check if the Style screen shows
	if not moduleGui.Enabled then
		return
	end

	--[[ Drawing ]]

	Module._draw()
end

--%%%%%%%%%%%%%%%%%%%% Draw

--[[
	Draws the whole screen from the worn outfit: the decks, the open category's pieces, the snail, and the picked piece.
]]
function Module._draw()
	--[[ Local Variables ]]

	local outfit = Module._getOutfit() --- @type Cosmetics_Outfit

	--[[ Drawing ]]

	for _index: number, slot: string in ipairs(_settings.SLOTS) do
		Module._drawDeck(slot, outfit)
	end
	Module._drawPieces(outfit)
	SkinsStage.Show(outfit)
	Module._drawDetail(outfit)
	Module._redraw()
end

--%%%%%%%%%%%%%%%%%%%% Draw Deck

--[[
	Draws one category's deck: its name lit while it's open, how many of its pieces are owned, the worn one, and its
	first three pieces on the cards, fanned out while it's open.
]]
--- @param outfit Cosmetics_Outfit
function Module._drawDeck(slot: string, outfit)
	--[[ Local Variables ]]

	local deck: ImageButton = elems["Decks"]:FindFirstChild("U_Deck" .. slot)
	local background: Frame = deck:FindFirstChild("Background")
	local pieces = Module._getSlotPieces(slot) --- @type { string }
	local open: boolean = slot == openSlot
	local owned: number = 0
	for _index: number, pieceId: string in ipairs(pieces) do
		owned += if Module._isOwned(pieceId) then 1 else 0
	end

	--[[ Texts ]]

	deck:FindFirstChild("S_Owned").Text = `{owned}/{#pieces} owned`
	deck:FindFirstChild("S_New").Visible = Module._hasNew(slot)
	deck:FindFirstChild("S_Wearing").Text = if outfit[slot] ~= "" then I.G_Inventory.Items[outfit[slot]].Name else "None"

	--[[ Open Look ]]

	background:FindFirstChild("Stroke2").Image = deck:GetAttribute(if open then "Look_OpenStroke2" else "Look_Stroke2")
	background:FindFirstChild("Stroke").Image = deck:GetAttribute(if open then "Look_OpenStroke" else "Look_Stroke")
	background:FindFirstChild("Stroke").ImageColor3 = deck:GetAttribute(if open then "Look_OpenStrokeColor" else "Look_StrokeColor")
	deck:FindFirstChild("S_Name").TextColor3 = deck:GetAttribute(if open then "Look_OpenTextColor" else "Look_TextColor")

	--[[ Cards ]]

	for index: number = 1, 3 do
		--[[ Card ]]

		local card: Frame = deck:FindFirstChild("S_Fan"):FindFirstChild(`S_Card{index}`)
		local pieceId: string = pieces[index]
		card:FindFirstChild("Stroke").ImageColor3 = Module._getRarityColor(pieceId)
		Module._show(card:FindFirstChild("View"), I.G_Cosmetics.GetShowcase(pieceId), pieceId)

		--[[ Fanning ]]

		local Fan_TweenInfo: TweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local Fan_TweenGoal = { Position = card:GetAttribute(if open then "Look_OpenPosition" else "Look_ClosedPosition") }
		local Fan_Tween: Tween = I.S.TweenService:Create(card, Fan_TweenInfo, Fan_TweenGoal)
		Fan_Tween:Play()
	end
end

--%%%%%%%%%%%%%%%%%%%% Draw Pieces

--[[
	Fills the grid with the open category's pieces: no hat or neck piece first where the slot can be empty, then the
	owned ones by rarity, then the locked ones. The worn one takes the selected look; pressing one picks it and wears it
	when it's owned. The same list keeps its tiles, so wearing a piece only changes their looks.
]]
--- @param outfit Cosmetics_Outfit
function Module._drawPieces(outfit)
	--[[ Local Variables ]]

	local entries = Module._getSlotPieces(openSlot) --- @type { string }
	local canBeEmpty: boolean = openSlot == "Hat" or openSlot == "Neck"
	if canBeEmpty then
		table.insert(entries, 1, "")
	end
	local list: string = `{openSlot}|{table.concat(entries, ",")}`

	--[[ Clearing ]]

	-- Another list (a slot opened, a piece bought) gets new tiles
	if list ~= tilesFor then
		for _pieceId: string, tile: ImageButton in pairs(tiles) do
			tile:Destroy()
		end
		tiles = {}
		tilesFor = list
	end

	--[[ Panel ]]

	local owned: number = 0
	for _index: number, pieceId: string in ipairs(entries) do
		owned += if pieceId ~= "" and Module._isOwned(pieceId) then 1 else 0
	end
	elems["Panel"]:FindFirstChild("S_Title").Text = elems["Decks"]:FindFirstChild("U_Deck" .. openSlot):FindFirstChild("S_Name").Text
	elems["Panel"]:FindFirstChild("S_Count").Text = `{owned} / {#entries - (if canBeEmpty then 1 else 0)} owned`

	--[[ Tiles ]]

	for order: number, pieceId: string in ipairs(entries) do
		--[[ Local Variables ]]

		local owns: boolean = pieceId == "" or Module._isOwned(pieceId)
		local worn: boolean = outfit[openSlot] == pieceId

		--[[ Cloning ]]

		local tile: ImageButton? = tiles[pieceId]
		local made: boolean = tile == nil
		if not tile then
			tile = prefabs["PieceTile"]:Clone()
			tile.Name = if pieceId ~= "" then pieceId else "None"
			tile.LayoutOrder = order
			tile.Visible = true
			tiles[pieceId] = tile
		end

		--[[ Elements ]]

		local background: Frame = tile:FindFirstChild("Background")

		--[[ Texts ]]

		tile:FindFirstChild("S_Name").Text = if pieceId ~= "" then I.G_Inventory.Items[pieceId].Name elseif openSlot == "Hat" then "No hat" else "No neck piece"
		tile:FindFirstChild("S_Rarity").ImageColor3 = Module._getRarityColor(pieceId)
		tile:FindFirstChild("S_Locked").Visible = not owns
		tile:FindFirstChild("S_Worn").Visible = worn
		tile:FindFirstChild("S_New").Visible = pieceId ~= "" and Module._isNew(pieceId)

		--[[ Selected Look ]]

		background:FindFirstChild("Stroke2").Image = tile:GetAttribute(if worn then "Look_SelectedStroke2" else "Look_Stroke2")
		background:FindFirstChild("Stroke").Image = tile:GetAttribute(if worn then "Look_SelectedStroke" else "Look_Stroke")
		background:FindFirstChild("Stroke").ImageColor3 = tile:GetAttribute(if worn then "Look_SelectedStrokeColor" else "Look_StrokeColor")

		--[[ Saving ]]

		if made then
			tile.Parent = elems["Pieces"]
			Module._show(tile:FindFirstChild("S_Preview"), Module._getTileOutfit(pieceId), if pieceId ~= "" then pieceId else _settings.DEFAULT_OUTFIT.Body)
			I.Interact.OnPress(tile, function()
				Module._pick(pieceId)
			end)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Draw Detail

--[[
	Shows the picked piece in the detail bar: its snail, name, rarity and set, and what pressing does (WORN, EQUIP, or GET
	for one in the Skin crate), in that button's colours.
]]
--- @param outfit Cosmetics_Outfit
function Module._drawDetail(outfit)
	--[[ Local Variables ]]

	local action: ImageButton = elems["Detail"]:FindFirstChild("S_Action")
	local background: Frame = action:FindFirstChild("Background")
	local item = I.G_Inventory.Items[picked] --- @type Inventory_ItemData
	local state: string = if outfit[openSlot] == picked then "Worn" elseif Module._isOwned(picked) then "Equip" else "Get"
	local color: Color3 = Module._getRarityColor(picked)

	--[[ Texts ]]

	elems["Detail"]:FindFirstChild("S_Name").Text = item.Name
	elems["Detail"]:FindFirstChild("S_Info").Text = `<font color="#{color:ToHex()}">{item.Rarity}</font> · {I.G_Cosmetics.GetSet(I.G_Cosmetics.GetPiece(picked).Set).Name} set`
	action:FindFirstChild("S_ActionText").Text = state

	--[[ Button Look ]]

	background:FindFirstChild("Main").ImageColor3 = action:GetAttribute(`Look_{state}MainColor`)
	background:FindFirstChild("Stroke").ImageColor3 = action:GetAttribute(`Look_{state}StrokeColor`)

	--[[ Preview ]]

	Module._show(elems["Detail"]:FindFirstChild("S_View"), I.G_Cosmetics.GetShowcase(picked), picked)
end

--%%%%%%%%%%%%%%%%%%%% Pick

--[[
	Picks a piece (or none, ""): the detail bar shows it, the camera turns to its slot, and the server is asked to wear
	it when the player owns it.
]]
function Module._pick(pieceId: string)
	--[[ Saving ]]

	if pieceId ~= "" then
		picked = pieceId
	end

	--[[ Wearing ]]

	if (pieceId == "" or Module._isOwned(pieceId)) and Module._getOutfit()[openSlot] ~= pieceId then
		I.Network.Fire("Cosmetics_Equip", openSlot, pieceId)
	end

	--[[ Drawing ]]

	SkinsStage.Focus(openSlot)
	Module._draw()
end

--%%%%%%%%%%%%%%%%%%%% On Action

--[[
	The detail bar's button: wears the picked piece, or opens the Skin crate when the player doesn't own it.
]]
function Module._onAction()
	--[[ Checks ]]

	-- Skip a piece already worn
	if Module._getOutfit()[openSlot] == picked then
		return
	end

	--[[ Acting ]]

	if Module._isOwned(picked) then
		Module._pick(picked)
	else
		I.Crates.ShowTab("Skin")
	end
end

--%%%%%%%%%%%%%%%%%%%% On Enabled Changed

--[[
	Closing the Style screen sees the open deck's new pieces.
]]
function Module._onEnabledChanged()
	--[[ Checks ]]

	-- Check if the screen closed
	if moduleGui.Enabled then
		return
	end

	--[[ Seeing ]]

	Module._see(openSlot)
end

--%%%%%%%%%%%%%%%%%%%% See

--[[
	Tells the server the player has seen a slot's pieces, when any of them is still NEW.
]]
function Module._see(slot: string)
	--[[ Checks ]]

	-- Skip a slot with nothing new
	if not Module._hasNew(slot) then
		return
	end

	--[[ Sending ]]

	I.Network.Fire("Cosmetics_See", slot)
end

--%%%%%%%%%%%%%%%%%%%% Redraw

--[[
	Draws every small viewport again once the deck cards have fanned (VIEWPORT_REDRAW_DELAY): its camera moves a hair,
	so Roblox draws the snails it skipped while they moved.
]]
function Module._redraw()
	--[[ Local Variables ]]

	redrawCount += 1
	local count: number = redrawCount

	--[[ Drawing ]]

	task.delay(_settings.VIEWPORT_REDRAW_DELAY, function()
		if count ~= redrawCount or not moduleGui.Enabled then
			return
		end
		for viewport: ViewportFrame, _key: string in pairs(shown) do
			local camera: Camera? = viewport.CurrentCamera
			if camera and viewport.Parent then
				camera.CFrame *= CFrame.new(0, 0, if count % 2 == 0 then 0.001 else -0.001)
			end
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	Puts a snail in an outfit in a viewport, held in its idle pose (`I.SnailRig.Pose`), framed on a piece
	(`GetPieceShot`). A viewport already showing it is left alone.
]]
--- @param outfit Cosmetics_Outfit
function Module._show(viewport: ViewportFrame, outfit, pieceId: string)
	--[[ Checks ]]

	-- Skip a viewport that already shows this
	local key: string = `{I.G_Cosmetics.GetOutfitText(outfit)}|{pieceId}`
	if shown[viewport] == key then
		return
	end

	--[[ Building ]]

	local model: Model? = I.G_Cosmetics.BuildSnail(outfit)
	if not model then
		return
	end
	viewport:ClearAllChildren()
	model:PivotTo(CFrame.identity)
	I.SnailRig.Pose(model)
	model.Parent = viewport
	local camera: Camera = I.Create("Camera")({
		Parent = viewport,
	})
	camera.CFrame = I.G_Cosmetics.GetPieceShot(model, pieceId)
	viewport.CurrentCamera = camera

	--[[ Saving ]]

	shown[viewport] = key
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Outfit

--[[
	Returns the outfit the player wears (the Outfit attribute the server writes).
]]
--- @return Cosmetics_Outfit
function Module._getOutfit()
	return I.G_Cosmetics.GetOutfit(I.S.Players.LocalPlayer:GetAttribute("Outfit"))
end

--%%%%%%%%%%%%%%%%%%%% Get Tile Outfit

--[[
	Returns the outfit a tile shows: the starter snail wearing the piece, or wearing nothing in the open slot for "".
]]
--- @return Cosmetics_Outfit
function Module._getTileOutfit(pieceId: string)
	return if pieceId ~= "" then I.G_Cosmetics.GetShowcase(pieceId) else table.clone(_settings.DEFAULT_OUTFIT)
end

--%%%%%%%%%%%%%%%%%%%% Get Slot Pieces

--[[
	Returns a slot's pieces in the order the screen shows them: owned ones first, each by rarity (commonest first), then
	by set.
]]
--- @return { string }
function Module._getSlotPieces(slot: string)
	--[[ Local Variables ]]

	local list = {} --- @type { string }

	--[[ Collecting ]]

	--- @param piece Cosmetics_PieceData
	for pieceId: string, piece in pairs(I.G_Cosmetics.GetPieces()) do
		if piece.Slot == slot then
			table.insert(list, pieceId)
		end
	end

	--[[ Sorting ]]

	table.sort(list, function(a: string, b: string)
		local ownsA: boolean = Module._isOwned(a)
		local ownsB: boolean = Module._isOwned(b)
		if ownsA ~= ownsB then
			return ownsA
		end
		local rarityA: number = I.Rarity.GetRarityIndex(I.G_Inventory.Items[a].Rarity) or 0
		local rarityB: number = I.Rarity.GetRarityIndex(I.G_Inventory.Items[b].Rarity) or 0
		if rarityA ~= rarityB then
			return rarityA < rarityB
		end
		return I.G_Cosmetics.GetSet(I.G_Cosmetics.GetPiece(a).Set).LayoutOrder < I.G_Cosmetics.GetSet(I.G_Cosmetics.GetPiece(b).Set).LayoutOrder
	end)

	--[[ Returning ]]

	return list
end

--%%%%%%%%%%%%%%%%%%%% Get Rarity Color

--[[
	Returns a piece's rarity colour (Common's for "", the empty slot).
]]
--- @return Color3
function Module._getRarityColor(pieceId: string)
	--[[ Local Variables ]]

	local look = I.Rarity.GetLook(if pieceId ~= "" then I.G_Inventory.Items[pieceId].Rarity else "Common") --- @type Rarity_Look?

	--[[ Returning ]]

	return if look then look.Base else Color3.new(1, 1, 1)
end

--%%%%%%%%%%%%%%%%%%%% Is New

--[[
	Returns whether a piece is NEW: owned, and not seen yet.
]]
--- @return boolean
function Module._isNew(pieceId: string)
	return Module._isOwned(pieceId) and not seen[pieceId]
end

--%%%%%%%%%%%%%%%%%%%% Has New

--[[
	Returns whether any of a slot's pieces is NEW.
]]
--- @return boolean
function Module._hasNew(slot: string)
	--[[ Checking ]]

	--- @param piece Cosmetics_PieceData
	for pieceId: string, piece in pairs(I.G_Cosmetics.GetPieces()) do
		if piece.Slot == slot and Module._isNew(pieceId) then
			return true
		end
	end

	--[[ Returning ]]

	return false
end

--%%%%%%%%%%%%%%%%%%%% Is Owned

--[[
	Returns whether the player owns a piece.
]]
--- @return boolean
function Module._isOwned(pieceId: string)
	--[[ Data ]]

	local standard = I.Inventory.Items and I.Inventory.Items.Standard or {} --- @type { [string]: string }

	--[[ Returning ]]

	return standard[pieceId] ~= nil
end

return Module
