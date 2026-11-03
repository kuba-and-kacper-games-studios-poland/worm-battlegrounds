--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "BackpackPlus"

--- @type BackpackPlus_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance | GuiObject }
local prefabs = {} --- @type { [string]: Instance | GuiObject }

--[[ Viewport ]]

local viewportCamera: Camera

--[[ Shared ]]

--- @type BackpackPlus_ClientContext
local ctx

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

--- @class BackpackPlus_Client_Slot
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _ctx BackpackPlus_ClientContext
function Module.Init(_ctx)
	ctx = _ctx

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._getElements()

	ctx.DropSlot = Module.DropSlot
	ctx.ToggleItem = Module.ToggleItem
	ctx.CompactItemsContainerLayoutOrders = Module._compactItemsContainerLayoutOrders
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing slot elements.
]]
function Module._getElements()
	local backpackGui: ScreenGui = I.UserInterface.UI["BackpackPlus"]

	--[[ General ]]

	elems["Backpack"] = backpackGui:FindFirstChild("U_Backpack", true) --- @type Frame
	elems["Toolbar"] = backpackGui:FindFirstChild("U_Toolbar", true) --- @type Frame
	elems["ItemsContainer"] = elems["Backpack"]:FindFirstChild("S_ItemsContainer", true) --- @type Frame

	--[[ Prefabs ]]

	prefabs["Slot"] = backpackGui:FindFirstChild("PREFAB | Slot", true)

	-- Hiding prefabs
	prefabs["Slot"].Visible = false
end

--%%%%%%%%%%%%%%%%%%%% Create Viewport Camera

--[[
	Creates new `Camera` to display Units.
]]
function Module._createViewportCamera()
	viewportCamera = Instance.new("Camera")
	viewportCamera.FieldOfView = _settings.VIEWPORT_CAMERA_FOV
	viewportCamera.CFrame = _settings.VIEWPORT_CAMERA_CFRAME
	viewportCamera.Parent = elems["Backpack"]
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Slot Creation

--%%%%%%%%%%%%%%%%%%%% Add Item

--[[
	Creates Slot for the newly added Item.
]]
function Module._addItem(tool: Tool)
	--[[ Checks ]]

	-- Return if slot is already created
	if ctx.CreatedSlots.ByTool[tool] then
		return
	end

	--%%%%%%%%%%%%%%%%%%%% Creating New Slot

	local newSlot: Frame = prefabs["Slot"]:Clone()
	newSlot.Name = tool:GetAttribute("Tool_ClientUUID") or tool.Name or "BackpackPlus_Slot"
	newSlot.Visible = true
	newSlot.Parent = elems["ItemsContainer"]

	--[[ Getting Elements ]]

	--- @type BackpackPlus_SlotElems
	local itemElems = {
		--[[ Default ]]

		["SlotButton"] = newSlot:FindFirstChild("S_SlotButton", true),

		["ItemViewportFrame"] = newSlot:FindFirstChild("S_ItemViewportFrame", true),
		["ItemWorldModel"] = newSlot:FindFirstChild("S_ItemWorldModel", true),
		["ItemIcon"] = newSlot:FindFirstChild("S_ItemIcon", true),

		["ItemNameText"] = newSlot:FindFirstChild("S_ItemName", true),
		["KeyCodeText"] = newSlot:FindFirstChild("S_KeyCode", true),
		["QuantityText"] = newSlot:FindFirstChild("S_Quantity", true),

		["Background"] = newSlot:FindFirstChild("S_Background", true),
		["BackgroundGlowContainer"] = newSlot:FindFirstChild("S_BackgroundGlowContainer", true),

		["FavoriteIconContainer"] = newSlot:FindFirstChild("S_FavoriteIconContainer", true),
		["FavoriteIcon"] = newSlot:FindFirstChild("S_FavoriteIcon", true),

		["UnequipHint"] = newSlot:FindFirstChild("S_UnequipHint", true),
	}

	--[[ Favorite Icon ]]

	local favoriteIcon: GuiObject? = itemElems["FavoriteIcon"]
	if favoriteIcon then
		itemElems["FavoriteIconDefaultSize"] = favoriteIcon.Size
	end

	if itemElems["FavoriteIconContainer"] then
		itemElems["FavoriteIconContainer"].Visible = false
	end

	--[[ Hiding Custom Containers ]]

	for _: number, elem: GuiObject in ipairs(itemElems["SlotButton"]:GetChildren()) do
		if elem:IsA("GuiObject") and string.find(`{elem.Name}`, "CustomContainer_", 1, true) then
			elem.Visible = false
		end
	end

	--[[ Saving ]]

	--- @type BackpackPlus_SlotData
	local slotTable = {
		Slot = newSlot,
		LayoutOrder = ctx.LastLayoutOrder,
		Tool = tool,

		Elems = itemElems,
		Connections = {},

		CustomDisplayData = {},
	}

	ctx.LastLayoutOrder += 1

	ctx.CreatedSlots.BySlot[newSlot] = slotTable
	ctx.CreatedSlots.ByTool[tool] = slotTable

	ctx.ApplyFavoriteSlot(slotTable, false)

	--%%%%%%%%%%%%%%%%%%%% Creating Update Connections

	--[[ Attribute Change ]]

	slotTable.Connections["Update"] = tool:GetAttributeChangedSignal("BackpackPlus_Update"):Connect(function()
		Module._updateItem(tool)
	end)
	slotTable.Connections["Update_Quantity"] = tool:GetAttributeChangedSignal("BackpackPlus_Quantity"):Connect(function()
		Module._updateItem(tool)
	end)
	slotTable.Connections["Update_DisplayType"] = tool:GetAttributeChangedSignal("BackpackPlus_DisplayType"):Connect(function()
		Module._updateItem(tool)
	end)
	slotTable.Connections["Update_FilterText"] = tool:GetAttributeChangedSignal("BackpackPlus_FilterText"):Connect(function()
		ctx.UpdateSearchBar()
	end)
	slotTable.Connections["Update_FilterCategory"] = tool:GetAttributeChangedSignal("BackpackPlus_FilterCategory"):Connect(function()
		ctx.UpdateSearchBar()
	end)

	--[[ Property Change ]]

	slotTable.Connections["Update_Name"] = tool:GetPropertyChangedSignal("Name"):Connect(function()
		Module._updateItem(tool)
	end)
	slotTable.Connections["Update_TextureId"] = tool:GetPropertyChangedSignal("TextureId"):Connect(function()
		Module._updateItem(tool)
	end)

	--%%%%%%%%%%%%%%%%%%%% Updating Slot

	-- Tagging before the initial update so a failing DisplayType still leaves a working Slot
	newSlot:AddTag("BackpackPlus_Slot")

	-- Initial Update
	Module._updateItem(tool, true)

	-- Moving reserved Tools to their Toolbar Slot
	local reservedSlotId: number? = ctx.GetReservedSlotIdForTool(tool)
	if reservedSlotId then
		ctx.DropSlot(newSlot, reservedSlotId)
		return
	end

	-- Moving to the saved Toolbar Slot, else the first free one, once the Toolbar is loaded
	if ctx.ToolbarServerLoaded then
		local toolbarSlotId: number? = ctx.TakePendingToolbarSlotId(tool) or ctx.GetFreeToolbarSlotIds()[1]
		if toolbarSlotId then
			ctx.DropSlot(newSlot, toolbarSlotId)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Remove Item

--[[
	Removes Item Slot from backpack.
]]
function Module._removeItem(tool: Tool)
	--[[ Data ]]

	--- @type BackpackPlus_SlotData
	local slotTable = ctx.CreatedSlots.ByTool[tool]
	if not slotTable then
		return
	end

	--[[ Clearing ]]

	local wasToolbarItem: boolean = false

	-- Clearing from Toolbar Slot
	for slotId: number, slotData: table in pairs(ctx.EquippedSlots) do
		if tool == slotData.Tool then
			ctx.EquippedSlots[slotId] = nil
			if ctx.ToolbarSlots[slotId] then
				local isWithinCapacity: boolean = slotId <= ctx.ToolbarSlotCount
				ctx.ToolbarSlots[slotId].Visible = isWithinCapacity and elems["Backpack"].Visible
			end
			wasToolbarItem = true
			break
		end
	end

	-- Clearing connections
	for _connectionName: string, connection: RBXScriptConnection in pairs(slotTable.Connections) do
		connection:Disconnect()
	end

	-- Clearing tables
	ctx.CreatedSlots.BySlot[slotTable.Slot] = nil
	ctx.CreatedSlots.ByTool[slotTable.Tool] = nil

	-- Removing slot
	slotTable.Slot:Destroy()

	-- Updating Toolbar with removed item
	if ctx.ToolbarServerLoaded and wasToolbarItem then
		ctx.SaveToolbarToServer()
	end
end

--%%%%%%%%%%%%%%%%%%%% Update Item

--[[
	Updates Item Slot display.
]]
function Module._updateItem(tool: Tool, initialUpdate: boolean?)
	--[[ Data ]]

	--- @type BackpackPlus_SlotData
	local slotData = tool and ctx.CreatedSlots.ByTool[tool]
	if not slotData then
		return
	end

	--[[ Slot Info ]]

	local equippedSlotId: number?

	--- @param equippedSlotData BackpackPlus_SlotData
	for slotId: number, equippedSlotData in pairs(ctx.EquippedSlots) do
		if slotData == equippedSlotData then
			equippedSlotId = slotId
			break
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Display Update

	-- Updating LayoutOrder
	if initialUpdate then
		slotData.Slot.LayoutOrder = slotData.LayoutOrder
	end

	-- Hiding Viewport on initial update
	if initialUpdate then
		slotData.Elems["ItemViewportFrame"].Visible = false
		slotData.Elems["ItemViewportFrame"].CurrentCamera = viewportCamera
	end

	-- Hiding KeyCode on initial update
	if initialUpdate then
		slotData.Elems["KeyCodeText"].Visible = false
	end

	-- Quantity
	local quantity: number? = tool:GetAttribute("BackpackPlus_Quantity")
	if quantity then
		slotData.Elems["QuantityText"].Visible = true
		slotData.Elems["QuantityText"].Text = `x{quantity}`
	else
		slotData.Elems["QuantityText"].Visible = false
	end

	-- Updating Icon
	slotData.Elems["ItemIcon"].Image = tool.TextureId
	slotData.Elems["ItemIcon"].Visible = tool.TextureId ~= "" and not slotData.Elems["ItemViewportFrame"].Visible

	-- Updating Name Text
	slotData.Elems["ItemNameText"].Text = tool.Name
	slotData.Elems["ItemNameText"].Visible = not slotData.Elems["ItemIcon"].Visible and not slotData.Elems["ItemViewportFrame"].Visible

	--%%%%%%%%%%%%%%%%%%%% Custom Display Update

	local displayType: string? = tool:GetAttribute("BackpackPlus_DisplayType")
	if displayType and _settings.CUSTOM_DISPLAY_UPDATES[displayType] then
		local success: boolean
		local result: any | string?
		success, result = pcall(_settings.CUSTOM_DISPLAY_UPDATES[displayType], slotData, viewportCamera, tool.Parent == I.Env.LocalPlayer.Character, equippedSlotId)

		-- Warning when the DisplayType errors
		if not success then
			warn(`[{_localName}::{script.Name}]: DisplayType ({displayType}) failed for Tool ({tool.Name})! - ({result})`)
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Other

	-- Updating visibility
	ctx.UpdateSearchBar()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Slot Control

--%%%%%%%%%%%%%%%%%%%% Toggle Item

--[[
	**CLIENT** |
	Equips or Unequips Tool of `slotFrame` Slot.
]]
function Module.ToggleItem(slotFrame: Frame)
	--[[ Checks ]]

	-- Locked
	if ctx.IsLocked then
		return
	end

	-- Missing Slot
	if not ctx.CreatedSlots.BySlot[slotFrame] then
		return
	end

	--[[ Getting Data ]]

	local slotData: table = ctx.CreatedSlots.BySlot[slotFrame]
	local toolToEquip: Tool = slotData.Tool

	local character: Model? = I.Env.LocalPlayer.Character
	local hum: Humanoid? = character and character:FindFirstChildOfClass("Humanoid")

	--[[ Equipping ]]

	if hum and hum.Health > 0 then
		if toolToEquip.Parent ~= character then
			hum:EquipTool(toolToEquip)
		else
			hum:UnequipTools()
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Unequip

--[[
	**CLIENT** |
	Unequips the equipped Tool, and plays its toolbar slot's click look and sound when it stands on the toolbar. Returns
	whether a Tool was equipped.
]]
--- @return boolean
function Module.Unequip()
	--[[ Checks ]]

	local character: Model? = I.Env.LocalPlayer.Character
	local hum: Humanoid? = character and character:FindFirstChildOfClass("Humanoid")
	local tool: Tool? = character and character:FindFirstChildOfClass("Tool")

	-- Skip while locked, without a living character, and with nothing equipped
	if ctx.IsLocked or not hum or hum.Health <= 0 or not tool then
		return false
	end

	--[[ Unequipping ]]

	hum:UnequipTools()

	--[[ Feedback ]]

	--- @param slotData BackpackPlus_SlotData
	for _slotId: number, slotData in pairs(ctx.EquippedSlots) do
		-- Press only the toolbar slot that held it; a backpack Tool has no button on screen
		if slotData.Tool == tool then
			I.Utils.PlayPress(slotData.Slot:FindFirstChild("S_SlotButton"))
		end
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Update Equipped Tool

--[[
	Updates display of equipped Tool Slot.
]]
function Module._updateEquippedTool()
	--[[ Getting Equipped ]]

	local character: Model = I.Env.LocalPlayer.Character
	local currentTool: Tool? = character and character:FindFirstChildOfClass("Tool")

	local currentSlot: table? = currentTool and ctx.CreatedSlots.ByTool[currentTool]
	local equippedSlot: table? = ctx.CurrentlyEquipped and ctx.CreatedSlots.ByTool[ctx.CurrentlyEquipped]

	--[[ Equipped -> Clearing Previous and Updating Equipped ]]

	if currentSlot then
		-- Clearing previous
		if equippedSlot then
			equippedSlot.Elems["Background"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		end

		-- Updating equipped
		if currentSlot then
			currentSlot.Elems["Background"].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		end
	end

	--[[ Empty -> Clearing Equipped ]]

	if not currentSlot then
		if equippedSlot then
			equippedSlot.Elems["Background"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		end
	end

	--[[ Custom Display Update ]]

	if currentTool then
		Module._updateItem(currentTool)
	end
	if ctx.CurrentlyEquipped and ctx.CurrentlyEquipped ~= currentTool then
		Module._updateItem(ctx.CurrentlyEquipped)
	end
end

--%%%%%%%%%%%%%%%%%%%% Get Items Container Slots Ordered

--[[
	Returns ItemsContainer SlotData sorted by LayoutOrder, optionally excluding a Slot.
]]
--- @return { BackpackPlus_SlotData }
function Module._getItemsContainerSlotsOrdered(excludeSlotFrame: Frame?, visibleOnly: boolean?)
	--[[ Local Variables ]]

	--- @type { BackpackPlus_SlotData }
	local orderedSlots = {}

	--[[ Getting Visible Slots ]]

	--- @param slotData BackpackPlus_SlotData
	for slotFrame: Frame, slotData in pairs(ctx.CreatedSlots.BySlot) do
		--[[ Checks ]]

		-- Skipping excluded Slot
		if slotFrame == excludeSlotFrame then
			continue
		end

		-- Skipping Slots outside ItemsContainer
		if slotFrame.Parent ~= elems["ItemsContainer"] then
			continue
		end

		-- Skipping hidden Slots when visibleOnly is set
		if visibleOnly and not slotFrame.Visible then
			continue
		end

		--[[ Saving ]]

		table.insert(orderedSlots, slotData)
	end

	--[[ Sorting ]]

	table.sort(orderedSlots, function(a: table, b: table)
		-- Tie-breaking equal LayoutOrder by Slot name
		if a.LayoutOrder == b.LayoutOrder then
			return a.Slot.Name < b.Slot.Name
		end

		-- Sorting by LayoutOrder ascending
		return a.LayoutOrder < b.LayoutOrder
	end)

	--[[ Returning ]]

	return orderedSlots
end

--%%%%%%%%%%%%%%%%%%%% Compact Items Container Layout Orders

--[[
	Reassigns contiguous LayoutOrder values for all Slots in ItemsContainer.
]]
function Module._compactItemsContainerLayoutOrders()
	--[[ Getting Ordered Created Slots ]]

	local orderedSlots = Module._getItemsContainerSlotsOrdered(nil, false)

	--[[ Updating Their LayourOrder ]]

	for index: number, slotData: table in ipairs(orderedSlots) do
		local layoutOrder: number = index - 1
		slotData.LayoutOrder = layoutOrder
		slotData.Slot.LayoutOrder = layoutOrder
	end

	--[[ General LayourOrder Update ]]

	ctx.LastLayoutOrder = #orderedSlots
end

--%%%%%%%%%%%%%%%%%%%% Set Items Container Order

--[[
	Places `slotData` at `insertIndex` among ItemsContainer Slots and renumbers contiguously.
]]
--- @param slotData BackpackPlus_SlotData
function Module._setItemsContainerOrder(slotData, insertIndex: number)
	--[[ Getting Ordered Slots ]]

	local orderedSlots = Module._getItemsContainerSlotsOrdered(slotData.Slot, false)

	--[[ Inserting Slot ]]

	local clampedIndex: number = math.clamp(insertIndex, 0, #orderedSlots)
	table.insert(orderedSlots, clampedIndex + 1, slotData)

	--[[ Updating Their LayoutOrder ]]

	for index: number, orderedSlotData: table in ipairs(orderedSlots) do
		local layoutOrder: number = index - 1
		orderedSlotData.LayoutOrder = layoutOrder
		orderedSlotData.Slot.LayoutOrder = layoutOrder
	end

	--[[ General LayoutOrder Update ]]

	ctx.LastLayoutOrder = #orderedSlots
end

--%%%%%%%%%%%%%%%%%%%% Resolve Items Container Insert Index

--[[
	Returns a 0-based insert index from the mouse position among ItemsContainer Slots.
]]
--- @param excludeSlotFrame Frame?
--- @return number?
function Module._resolveItemsContainerInsertIndex(excludeSlotFrame)
	--[[ Checks ]]

	-- Mouse is outside ItemsContainer
	if not I.Gui.IsMouseOverObject(I.Env.Mouse, elems["ItemsContainer"]) then
		return nil
	end

	--[[ Local Variables ]]

	local mouseX: number, mouseY: number = I.Env.Mouse.X, I.Env.Mouse.Y
	local visibleSlots = Module._getItemsContainerSlotsOrdered(excludeSlotFrame, true)
	local allSlots = Module._getItemsContainerSlotsOrdered(excludeSlotFrame, false)

	--[[ Finding Hit Slot ]]

	--- @param hitSlotData BackpackPlus_SlotData
	for _index: number, hitSlotData in ipairs(visibleSlots) do
		local pos: Vector2 = hitSlotData.Slot.AbsolutePosition
		local size: Vector2 = hitSlotData.Slot.AbsoluteSize

		-- Skipping Slots the mouse is not over
		if not (mouseX >= pos.X and mouseX <= (pos.X + size.X) and mouseY >= pos.Y and mouseY <= (pos.Y + size.Y)) then
			continue
		end

		--[[ Resolving Full Index ]]

		local fullIndex: number? = nil
		for orderIndex: number, orderedSlotData: table in ipairs(allSlots) do
			if orderedSlotData == hitSlotData then
				fullIndex = orderIndex - 1
				break
			end
		end

		-- Hit Slot missing from full order list
		if fullIndex == nil then
			return nil
		end

		--[[ Returning Insert Index ]]

		-- Inserting before Slot when mouse is on the left half
		local midX: number = pos.X + (size.X / 2)
		if mouseX < midX then
			return fullIndex
		end

		-- Inserting after Slot when mouse is on the right half
		return fullIndex + 1
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Drop Slot

--[[
	**CLIENT** |
	Drops Slot at Toolbar or ItemsContainer and updates its properties.
]]
function Module.DropSlot(slotFrame: Frame, setToolbarSlotId: number?)
	--[[ Data ]]

	--- @type BackpackPlus_SlotData
	local slotData = ctx.CreatedSlots.BySlot[slotFrame]
	if not slotData then
		return
	end

	local isProgrammatic: boolean = setToolbarSlotId ~= nil

	--[[ Reservation Check ]]

	-- User drops cannot move reservation-locked Tools
	if not isProgrammatic and ctx.IsToolReservationLocked(slotData.Tool) then
		return
	end

	--[[ Equipped Check ]]

	local equippedSlotId: number?

	--- @param equippedSlotData BackpackPlus_SlotData
	for slotId: number, equippedSlotData in pairs(ctx.EquippedSlots) do
		if slotFrame == equippedSlotData.Slot then
			equippedSlotId = slotId
			break
		end
	end

	--[[ Getting Toolbar Slot ]]

	local overToolbarSlotId: number? = tonumber(setToolbarSlotId)

	-- Ignoring Toolbar Slot ids outside capacity
	if overToolbarSlotId and overToolbarSlotId > ctx.ToolbarSlotCount then
		overToolbarSlotId = nil
	end

	local overToolbarSlot: Frame? = overToolbarSlotId and ctx.ToolbarSlots[overToolbarSlotId]

	-- Leaving a programmatic drop to a missing or out-of-capacity Toolbar Slot where it is
	if isProgrammatic and not overToolbarSlot then
		return
	end

	-- Resolving Toolbar Slot under the mouse when none was forced
	if not overToolbarSlotId or not overToolbarSlot then
		for toolbarSlotId: number, toolbarSlot: Frame in ipairs(ctx.ToolbarSlots) do
			-- Skipping Toolbar Slots outside capacity
			if toolbarSlotId > ctx.ToolbarSlotCount then
				continue
			end

			local isMouseOver: boolean = I.Gui.IsMouseOverObject(I.Env.Mouse, toolbarSlot)

			-- Occupied placeholders are hidden from layout; hit-test the equipped item Frame instead
			if not isMouseOver and ctx.EquippedSlots[toolbarSlotId] then
				isMouseOver = I.Gui.IsMouseOverObject(I.Env.Mouse, ctx.EquippedSlots[toolbarSlotId].Slot)
			end

			if isMouseOver then
				overToolbarSlotId = toolbarSlotId
				overToolbarSlot = toolbarSlot
				break
			end
		end
	end

	--[[ Reservation Destination Check ]]

	-- User drops cannot occupy a reserved Toolbar Slot with a non-matching Tool
	if not isProgrammatic and overToolbarSlotId and ctx.IsToolbarSlotReserved(overToolbarSlotId) then
		if not ctx.DoesToolMatchReservation(overToolbarSlotId, slotData.Tool) then
			return
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Backpack Drop

	if not overToolbarSlot then
		--[[ Resolving Insert Index ]]

		-- Resolving insert index before reparenting to keep AbsolutePositions stable
		local insertIndex: number? = Module._resolveItemsContainerInsertIndex(slotFrame)
		local movedToBackpack: boolean = false

		--[[ Moving to ItemsContainer ]]

		if equippedSlotId and I.Gui.IsMouseOverObject(I.Env.Mouse, elems["Backpack"]) then
			slotData.Slot.Parent = elems["ItemsContainer"]

			-- Hiding KeyCode
			slotData.Elems["KeyCodeText"].Visible = false
			ctx.EquippedSlots[equippedSlotId] = nil

			-- Showing Toolbar Slot
			if equippedSlotId <= ctx.ToolbarSlotCount then
				ctx.ToolbarSlots[equippedSlotId].Visible = true
			end

			equippedSlotId = nil
			movedToBackpack = true
		end

		--[[ Updating Layout Order ]]

		if slotData.Slot.Parent == elems["ItemsContainer"] then
			if insertIndex ~= nil then
				Module._setItemsContainerOrder(slotData, insertIndex)
			elseif movedToBackpack then
				Module._setItemsContainerOrder(slotData, math.huge)
			end
		end

		--[[ Saving ]]

		-- Saving toolbar to server
		if ctx.ToolbarServerLoaded then
			ctx.SaveToolbarToServer()
		end

		-- Updating visibility
		ctx.UpdateSearchBar()

		return
	end

	--%%%%%%%%%%%%%%%%%%%% Toolbar Drop

	--[[ Checks ]]

	-- Same-slot drop is a no-op
	if equippedSlotId and equippedSlotId == overToolbarSlotId then
		return
	end

	--[[ Local Variables ]]

	-- Resolving destination occupant before mutating source ownership
	--- @type BackpackPlus_SlotData?
	local switchedSlotData = ctx.EquippedSlots[overToolbarSlotId]

	-- Capturing backpack index before leaving ItemsContainer
	local leavingBackpackIndex: number? = nil
	if slotData.Slot.Parent == elems["ItemsContainer"] then
		leavingBackpackIndex = slotData.LayoutOrder
	end

	--[[ Clearing Source Toolbar Occupancy ]]

	if equippedSlotId then
		ctx.EquippedSlots[equippedSlotId] = nil

		-- Showing Toolbar Slot
		if equippedSlotId <= ctx.ToolbarSlotCount then
			ctx.ToolbarSlots[equippedSlotId].Visible = true
		end
	end

	--[[ Handling Destination Occupant ]]

	if switchedSlotData then
		if equippedSlotId then
			-- Swapping with the Slot's previous Toolbar position
			ctx.EquippedSlots[equippedSlotId] = switchedSlotData
			ctx.ToolbarSlots[equippedSlotId].Visible = false
			switchedSlotData.Slot.LayoutOrder = equippedSlotId
			switchedSlotData.Slot.Parent = elems["Toolbar"]
			switchedSlotData.Elems["KeyCodeText"].Text = equippedSlotId ~= 10 and `{equippedSlotId}` or `{0}`
			switchedSlotData.Elems["KeyCodeText"].Visible = true
		else
			--[[ Inserting Displaced Slot ]]

			-- Inserting displaced Slot at the backpack Slot's previous index
			slotData.Slot.Parent = elems["Toolbar"]
			switchedSlotData.Slot.Parent = elems["ItemsContainer"]
			switchedSlotData.Elems["KeyCodeText"].Visible = false

			Module._setItemsContainerOrder(switchedSlotData, leavingBackpackIndex or math.huge)
		end
	end

	--[[ Equipping ]]

	-- Hiding Toolbar Slot
	overToolbarSlot.Visible = false

	-- Moving and Updating Slot
	slotData.Slot.LayoutOrder = overToolbarSlotId
	slotData.Slot.Parent = elems["Toolbar"]
	slotData.Elems["KeyCodeText"].Text = overToolbarSlotId ~= 10 and `{overToolbarSlotId}` or `{0}`
	slotData.Elems["KeyCodeText"].Visible = true

	-- Saving Data
	ctx.EquippedSlots[overToolbarSlotId] = slotData
	ctx.UpdateToolbarSlotsSize()

	--[[ Compacting Layout Orders ]]

	-- Closing gaps left in ItemsContainer when this Slot left the backpack
	if leavingBackpackIndex ~= nil then
		Module._compactItemsContainerLayoutOrders()
	end

	--[[ Saving ]]

	-- Saving toolbar to server
	if ctx.ToolbarServerLoaded then
		ctx.SaveToolbarToServer()
	end

	-- Updating visibility
	ctx.UpdateSearchBar()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
