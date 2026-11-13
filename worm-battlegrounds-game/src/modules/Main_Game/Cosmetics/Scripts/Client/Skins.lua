--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
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
	elems["Skins"] = moduleGui:FindFirstChild("U_Skins", true) --- @type Frame
	elems["SkinsCategory"] = moduleGui:FindFirstChild("U_Categories", true):FindFirstChild("S_Skins") --- @type ImageButton
	prefabs["SkinTile"] = elems["Skins"]:FindFirstChild("PREFAB | SkinTile") --- @type ImageButton

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
	Shows the worn skin under the Skins category, and redraws the skins widget while it's open.
]]
function Module._refresh()
	--[[ Data ]]

	local item = I.G_Inventory.Items[Module._getEquipped()] --- @type Inventory_ItemData?

	--[[ Category ]]

	elems["SkinsCategory"]:FindFirstChild("Equipped").Text = if item then item.Name else ""

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
	Draws one tile per skin: its snail in a 3D preview, its name and its rarity's corner. The worn one takes the tile's
	selected look and comes first; owned ones equip on a press; the rest show the lock.
]]
function Module._draw()
	--[[ Clearing ]]

	for _index: number, child: Instance in ipairs(elems["Skins"]:GetChildren()) do
		if child:IsA("GuiButton") and child ~= prefabs["SkinTile"] then
			child:Destroy()
		end
	end

	--[[ Local Variables ]]

	local standard = I.Inventory.Items and I.Inventory.Items.Standard or {} --- @type { [string]: string }
	local equipped: string = Module._getEquipped()

	--[[ Tiles ]]

	--- @param skin Cosmetics_SkinData
	for skinId: string, skin in pairs(I.G_Cosmetics.GetSkins()) do
		--[[ Local Variables ]]

		local item = I.G_Inventory.Items[skinId] --- @type Inventory_ItemData?
		if not item then
			continue
		end
		local owned: boolean = standard[skinId] ~= nil
		local worn: boolean = skinId == equipped
		local rarityIndex: number = I.Rarity.GetRarityIndex(item.Rarity) or 0
		local look = I.Rarity.GetLook(item.Rarity) --- @type Rarity_Look?

		--[[ Cloning ]]

		local tile: ImageButton = prefabs["SkinTile"]:Clone()
		tile.Name = skinId
		tile.LayoutOrder = if worn then 0 elseif owned then rarityIndex + 1 else rarityIndex + 100
		tile.Visible = true

		--[[ Elements ]]

		local background: Frame = tile:FindFirstChild("Background")

		--[[ Texts ]]

		tile:FindFirstChild("S_Name").Text = item.Name
		tile:FindFirstChild("S_Rarity").ImageColor3 = if look then look.Base else Color3.new(1, 1, 1)
		tile:FindFirstChild("S_Locked").Visible = not owned

		--[[ Selected Look ]]

		background:FindFirstChild("Stroke2").Image = tile:GetAttribute(if worn then "Look_SelectedStroke2" else "Look_Stroke2")
		background:FindFirstChild("Stroke").Image = tile:GetAttribute(if worn then "Look_SelectedStroke" else "Look_Stroke")
		background:FindFirstChild("Stroke").ImageColor3 = tile:GetAttribute(if worn then "Look_SelectedStrokeColor" else "Look_StrokeColor")

		--[[ Saving ]]

		tile.Parent = elems["Skins"]
		Module._preview(tile:FindFirstChild("S_Preview"), skin.Model)
		if owned and not worn then
			I.Interact.OnPress(tile, function()
				I.Network.Fire("Cosmetics_Equip", skinId)
			end)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Preview

--[[
	Puts a skin's snail in a tile's viewport, seen from the front, held in its idle pose (`I.SnailRig.Pose`).
]]
function Module._preview(viewport: ViewportFrame, modelName: string)
	--[[ Data ]]

	local skins: Instance? = I.Dirs.Assets:FindFirstChild("Skins")
	local fallback: string = I.G_Cosmetics.GetSkin(_settings.DEFAULT_SKIN).Model
	local source: Instance? = skins and (skins:FindFirstChild(modelName) or skins:FindFirstChild(fallback))
	if not source or not source:IsA("Model") then
		return
	end

	--[[ Building ]]

	-- shortcut: every skin without its own model shows the default snail; drop the fallback once each skin has one
	local model: Model = source:Clone()
	model:PivotTo(CFrame.identity)
	I.SnailRig.Pose(model)
	model.Parent = viewport
	local camera: Camera = I.Create("Camera")({
		Parent = viewport,
	})
	local box: CFrame
	local size: Vector3
	box, size = model:GetBoundingBox()
	camera.CFrame = CFrame.lookAt(box.Position + Vector3.new(0, size.Y * 0.2, -size.Magnitude * _settings.PREVIEW_DISTANCE), box.Position)
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
