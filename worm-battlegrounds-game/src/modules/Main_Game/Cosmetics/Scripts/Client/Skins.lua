--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Cosmetics"

--- @type Cosmetics_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

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
	elems["Skins"] = moduleGui:FindFirstChild("U_Skins", true) --- @type ScrollingFrame
	elems["SkinButton"] = I.UserInterface.UI[_settings.LOBBY_GUI_NAME]:FindFirstChild("U_Skins", true) --- @type Frame
	prefabs["SkinTile"] = elems["Skins"]:FindFirstChild("PREFAB | SkinTile") --- @type Frame

	--[[ Connections ]]

	I.Topic.Subscribe("WidgetManager_Opened", Module._onOpened)
	I.Topic.Subscribe("Inventory_DataUpdated-Standard", Module._refresh)
	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Follows the player's Cosmetics folder: the skin they wear.
]]
function Module._connectReplicator()
	--[[ Data ]]

	moduleRep = I.Replicator.GetFolder(_localName)
	if not moduleRep then
		return
	end

	--[[ Connections ]]

	moduleRep.AttributeChanged:Connect(Module._refresh)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Shows the worn skin on the lobby's skin button, and redraws the skins widget while it's open.
]]
function Module._refresh()
	--[[ Data ]]

	local item = I.G_Inventory.Items[Module._getEquipped()] --- @type Inventory_ItemData?

	--[[ Skin Button ]]

	elems["SkinButton"]:FindFirstChild("S_Info", true).Text = if item then item.Name else ""
	elems["SkinButton"]:FindFirstChild("S_Icon", true).Image = if item then item.IconId else ""

	--[[ Widget ]]

	if moduleGui.Enabled then
		Module._draw()
	end
end

--%%%%%%%%%%%%%%%%%%%% On Opened

--[[
	Draws the skins widget when it opens.
]]
function Module._onOpened(widgetName: string)
	--[[ Checks ]]

	-- Check if it's the skins widget
	if widgetName ~= _settings.SKINS_GUI_NAME then
		return
	end

	--[[ Drawing ]]

	Module._draw()
end

--%%%%%%%%%%%%%%%%%%%% Draw

--[[
	Draws one tile per owned skin: its worm in a 3D preview, its name and copies toward shiny, and Equip (or Equipped
	on the worn one).
]]
function Module._draw()
	--[[ Clearing ]]

	for _index: number, child: Instance in ipairs(elems["Skins"]:GetChildren()) do
		if child:IsA("Frame") and child ~= prefabs["SkinTile"] then
			child:Destroy()
		end
	end

	--[[ Local Variables ]]

	local standard = I.Inventory.Items and I.Inventory.Items.Standard or {} --- @type { [string]: string }
	local equipped: string = Module._getEquipped()

	--[[ Tiles ]]

	--- @param skin Cosmetics_SkinData
	for skinId: string, skin in pairs(I.G_Cosmetics.GetSkins()) do
		local item = I.G_Inventory.Items[skinId] --- @type Inventory_ItemData?
		if not item or not standard[skinId] then
			continue
		end
		local tile: Frame = prefabs["SkinTile"]:Clone()
		tile.Name = skinId
		tile.LayoutOrder = if skinId == equipped then 0 else (I.Rarity.GetRarityIndex(item.Rarity) or 0) + 1
		tile.Visible = true
		local caption: Frame = tile:FindFirstChild("Caption", true)
		local equip: Frame = tile:FindFirstChild("S_Equip", true)
		caption:FindFirstChild("Title").Text = item.Name
		caption:FindFirstChild("Subtext").Text = `{math.min(tonumber(standard[skinId]) or 0, _settings.SHINY_COPIES)}/{_settings.SHINY_COPIES} to shiny`
		tile:FindFirstChild("Status", true).Text = ""
		equip:FindFirstChild("ButtonText", true).Text = if skinId == equipped then "EQUIPPED" else "EQUIP"
		tile.Parent = elems["Skins"]
		Module._preview(tile:FindFirstChild("Viewport", true), skin.Model)
		I.Interact.OnPress(equip:FindFirstChild("Button"), function()
			I.Network.Fire("Cosmetics_Equip", skinId)
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%% Preview

--[[
	Puts a skin's worm in a tile's viewport, seen from the front.
]]
function Module._preview(viewport: ViewportFrame, modelName: string)
	--[[ Data ]]

	local skins: Instance? = I.Dirs.Assets:FindFirstChild("Skins")
	local source: Instance? = skins and (skins:FindFirstChild(modelName) or skins:FindFirstChild(I.Settings["Worms"].DEFAULT_SKIN))
	if not source or not source:IsA("Model") then
		return
	end

	--[[ Building ]]

	-- shortcut: every skin without its own model shows the default worm; drop the fallback once each skin has one
	local model: Model = source:Clone()
	model:PivotTo(CFrame.identity)
	model.Parent = viewport
	local camera: Camera = I.Create("Camera")({
		Parent = viewport,
	})
	local size: Vector3 = model:GetExtentsSize()
	camera.CFrame = CFrame.lookAt(Vector3.new(0, size.Y * 0.2, -size.Magnitude * _settings.PREVIEW_DISTANCE), Vector3.zero)
	viewport.CurrentCamera = camera
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Equipped

--[[
	Returns the id of the skin the player wears.
]]
--- @return string
function Module._getEquipped()
	return moduleRep and moduleRep:GetAttribute("EquippedSkin") or _settings.DEFAULT_SKIN
end

return Module
