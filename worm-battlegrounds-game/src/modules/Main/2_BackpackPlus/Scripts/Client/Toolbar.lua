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

--[[ Slot Size ]]

local toolbarSlotSize: UDim2 = UDim2.new(0, 0, 0, 0)
local toolbarSlotAbsoluteSize: Vector2 = Vector2.zero
local lastToolbarAbsoluteY: number?
local toolbarSizeConnection: RBXScriptConnection?
local toolbarSizeTopicReady: boolean = false

--[[ Saving ]]

local TOOLBAR_SAVE_DELAY: number = 0.25
local isSaveDirty: boolean = false
local isSaveScheduled: boolean = false
local isLoadingToolbar: boolean = false

--[[ Hints ]]

-- How often the gamepad hints follow the toolbar, and the attribute ume's Console module hides a hint by
local HINTS_INTERVAL: number = 0.1
local HINT_HIDDEN_ATTRIBUTE: string = "Console_HintHidden"

--[[ Shared ]]

--- @type BackpackPlus_ClientContext
local ctx

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Set Hint Hidden

--[[
	Hides a gamepad hint even on Console, or lets it show again, writing the attribute only when it changes.
]]
local function setHintHidden(hint: Instance, hidden: boolean)
	--[[ Checks ]]

	-- Skip a hint already in that state
	if hint:GetAttribute(HINT_HIDDEN_ATTRIBUTE) == hidden then
		return
	end

	--[[ Applying ]]

	hint:SetAttribute(HINT_HIDDEN_ATTRIBUTE, hidden)
end

--%%%%%%%%%%%%%%%%%%%% Is Character Alive

--[[
	Returns whether a character exists and its Humanoid is alive.
]]
--- @return boolean
local function isCharacterAlive(character: Model?)
	--[[ Local Variables ]]

	local humanoid: Humanoid? = character and character:FindFirstChildOfClass("Humanoid")

	--[[ Returning ]]

	return humanoid ~= nil and humanoid.Health > 0
end

--%%%%%%%%%%%%%%%%%%%% Tool Matches Saved Id

--[[
	Returns whether a Tool matches a saved Toolbar slot id, by UUID or by name, following the saved retrieve type.
]]
--- @return boolean
local function toolMatchesSavedId(tool: Tool, savedId: string, matchBy: string)
	--[[ Local Variables ]]

	local savedParts = savedId:split("___") --- @type { string }
	local savedUUID: string? = savedParts[1]
	local savedName: string? = savedParts[2]
	local retrieveType: string? = savedParts[3]

	--[[ Matching ]]

	-- Matching by UUID unless the Tool is retrieved by name only
	if matchBy == "UUID" then
		local serverUUID: any = tool:GetAttribute("Tool_ServerUUID")
		return retrieveType ~= "rbName" and serverUUID ~= nil and `{serverUUID}` == savedUUID
	end

	-- Matching by name unless the Tool is retrieved by UUID only
	return retrieveType ~= "rbUUID" and tool.Name == savedName
end

--%%%%%%%%%%%%%%%%%%%% Sort Slots By Layout Order

--[[
	Sorts Slots by backpack LayoutOrder, then by Slot name, in place.
]]
--- @param slots { BackpackPlus_SlotData }
local function sortSlotsByLayoutOrder(slots)
	--[[ Sorting ]]

	--- @param a BackpackPlus_SlotData
	--- @param b BackpackPlus_SlotData
	table.sort(slots, function(a, b)
		-- Tie-breaking equal LayoutOrder by Slot name
		if a.LayoutOrder == b.LayoutOrder then
			return a.Slot.Name < b.Slot.Name
		end

		-- Sorting by LayoutOrder ascending
		return a.LayoutOrder < b.LayoutOrder
	end)
end

--%%%%%%%%%%%%%%%%%%%% Get Toolbar Slot Count

--[[
	Returns the visible Toolbar slot count for the current platform.
]]
--- @return number
local function getToolbarSlotCount()
	return _settings.TOOLBAR_SLOTS[I.Platform.Current] or _settings.TOOLBAR_SLOTS["Default"]
end

--%%%%%%%%%%%%%%%%%%%% Get Toolbar Slot Count For Platform

--[[
	Returns the visible Toolbar slot count for a platform key.
]]
--- @return number
local function getToolbarSlotCountForPlatform(platform: string?)
	return _settings.TOOLBAR_SLOTS[platform] or _settings.TOOLBAR_SLOTS["Default"]
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

--- @class BackpackPlus_Client_Toolbar
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _ctx BackpackPlus_ClientContext
function Module.Init(_ctx)
	ctx = _ctx

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._getElements()

	ctx.SaveToolbarToServer = Module._saveToolbarToServer
	ctx.UpdateToolbarSlotDefaults = Module._updateSlotDefaults
	ctx.TakePendingToolbarSlotId = Module._takePendingToolbarSlotId
	ctx.GetFreeToolbarSlotIds = Module._getFreeToolbarSlotIds

	I.DoEvery.Every(HINTS_INTERVAL, Module._updateHints)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing toolbar elements.
]]
function Module._getElements()
	local backpackGui: ScreenGui = I.UserInterface.UI["BackpackPlus"]

	--[[ General ]]

	elems["Toolbar"] = backpackGui:FindFirstChild("U_Toolbar", true) --- @type Frame
	elems["Backpack"] = backpackGui:FindFirstChild("U_Backpack", true) --- @type Frame
	elems["ItemsContainer"] = elems["Backpack"]:FindFirstChild("S_ItemsContainer", true) --- @type Frame
	elems["PreviousHint"] = elems["Toolbar"]:FindFirstChild("S_PreviousHint") --- @type ImageLabel
	elems["NextHint"] = elems["Toolbar"]:FindFirstChild("S_NextHint") --- @type ImageLabel

	--[[ Prefabs ]]

	prefabs["Slot"] = backpackGui:FindFirstChild("PREFAB | Slot", true)
end

--%%%%%%%%%%%%%%%%%%%% Update Hints

--[[
	Keeps the gamepad hints true to the toolbar, through the attribute ume's Console module follows: the bumpers only
	while the toolbar holds a Tool, and the unequip hint (D-pad down) over the equipped Tool's toolbar slot while the
	backpack is closed. A Tool equipped from the backpack shows none.
]]
function Module._updateHints()
	--[[ Finding ]]

	local occupied: boolean = false
	local equippedSlotData = nil --- @type BackpackPlus_SlotData?

	for slotId: number = 1, ctx.ToolbarSlotCount do
		local slotData = ctx.EquippedSlots[slotId] --- @type BackpackPlus_SlotData?

		-- Skip empty toolbar slots
		if not slotData then
			continue
		end

		occupied = true
		equippedSlotData = if slotData.Tool == ctx.CurrentlyEquipped then slotData else equippedSlotData
	end

	--[[ Bumpers ]]

	setHintHidden(elems["PreviousHint"], not occupied)
	setHintHidden(elems["NextHint"], not occupied)

	--[[ Unequip ]]

	local backpackOpen: boolean = ctx.GetState()

	--- @param slotData BackpackPlus_SlotData
	for _slot: Frame, slotData in pairs(ctx.CreatedSlots.BySlot) do
		setHintHidden(slotData.Elems["UnequipHint"], backpackOpen or slotData ~= equippedSlotData)
	end
end

--%%%%%%%%%%%%%%%%%%%% Update Slot Defaults

--[[
	Updates the shared slot size values from the first empty Toolbar slot.
]]
function Module._updateSlotDefaults()
	--[[ Local Variables ]]

	local toolbarSlot: Frame? = ctx.ToolbarSlots[1]
	local toolbarSlotButton: ImageButton? = toolbarSlot and toolbarSlot:FindFirstChild("S_SlotButton", true) --- @type ImageButton

	--[[ Checks ]]

	-- Missing first Toolbar Slot
	if not toolbarSlot then
		return
	end

	-- Missing Slot Button
	if not toolbarSlotButton then
		return
	end

	--[[ Getting Size ]]

	local previousSlotSize: UDim2 = toolbarSlotSize
	local previousAbsoluteSize: Vector2 = toolbarSlotAbsoluteSize

	toolbarSlotSize = toolbarSlotButton.Size
	toolbarSlotAbsoluteSize = toolbarSlotButton.AbsoluteSize

	--[[ Publishing ]]

	-- Publishing only when size actually changed
	if toolbarSizeTopicReady and (previousSlotSize ~= toolbarSlotSize or previousAbsoluteSize ~= toolbarSlotAbsoluteSize) then
		I.Topic.Publish("BackpackPlus_ToolbarSizeChanged")
	end
end

--%%%%%%%%%%%%%%%%%%%% Connect Size Changes

--[[
	Publishes when the Toolbar's absolute Y size changes.
]]
function Module._connectSizeChanges()
	--[[ Checks ]]

	-- Already connected
	if toolbarSizeConnection then
		return
	end

	--[[ Setup ]]

	toolbarSizeTopicReady = true
	lastToolbarAbsoluteY = elems["Toolbar"].AbsoluteSize.Y
	Module._updateSlotDefaults()

	--[[ Connecting ]]

	toolbarSizeConnection = elems["Toolbar"]:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local toolbarAbsoluteY: number = elems["Toolbar"].AbsoluteSize.Y

		-- Skipping when Y size has not changed
		if toolbarAbsoluteY == lastToolbarAbsoluteY then
			return
		end

		--[[ Saving and Updating ]]

		lastToolbarAbsoluteY = toolbarAbsoluteY
		ctx.UpdateDisplay()
		Module._updateSlotDefaults()
	end)
end

--%%%%%%%%%%%%%%%%%%%% Create Toolbar Item Slots

--[[
	Creates Toolbar slots up to the Default capacity.
]]
function Module._createToolbarItemSlots()
	local maxToolbarSlots: number = _settings.TOOLBAR_SLOTS["Default"]

	for slotId: number = 1, maxToolbarSlots do
		-- Creating new slot
		local newSlot: Frame = prefabs["Slot"]:Clone()
		newSlot.LayoutOrder = slotId
		newSlot.Name = `ToolbarSlot_{slotId}`
		newSlot.Visible = false -- Hiding by default

		-- Getting slot elements
		local slotButton: ImageButton = newSlot:FindFirstChild("S_SlotButton", true)
		local keyCodeText: TextLabel = newSlot:FindFirstChild("S_KeyCode", true)
		local quantityText: TextLabel = newSlot:FindFirstChild("S_Quantity", true)
		local ItemName: TextLabel = newSlot:FindFirstChild("S_ItemName", true)
		local ItemIcon: ImageLabel = newSlot:FindFirstChild("S_ItemIcon", true)
		local ItemViewportFrame: ViewportFrame = newSlot:FindFirstChild("S_ItemViewportFrame", true)
		local favoriteIconContainer: GuiObject? = newSlot:FindFirstChild("S_FavoriteIconContainer", true)

		-- Hiding all non-used elements
		ItemName.Visible = false
		ItemIcon.Visible = false
		quantityText.Visible = false
		ItemViewportFrame.Visible = false
		if favoriteIconContainer then
			favoriteIconContainer.Visible = false
		end

		-- Hiding all custom containers
		for _: number, elem: GuiObject in ipairs(slotButton:GetChildren()) do
			if elem:IsA("GuiObject") and string.find(`{elem.Name}`, "CustomContainer_", 1, true) then
				elem.Visible = false
			end
		end

		-- Updating KeyCode
		keyCodeText.Visible = true
		keyCodeText.Text = slotId ~= 10 and `{slotId}` or `{0}`

		--[[ Saving ]]

		ctx.ToolbarSlots[slotId] = newSlot
		newSlot.Parent = elems["Toolbar"]
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization - Server

--%%%%%%%%%%%%%%%%%%%% Load Toolbar From Server

--[[
	Runs one Toolbar load at a time and warns when it errors. A call while a load runs does nothing.
]]
function Module._loadToolbarFromServer()
	--[[ Checks ]]

	-- Skipping while another load is running
	if isLoadingToolbar then
		return
	end

	--[[ Loading ]]

	isLoadingToolbar = true

	local success: boolean
	local result: any | string?
	success, result = pcall(Module._loadSavedToolbar)

	isLoadingToolbar = false

	-- Warning when the load errors
	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to load the saved Toolbar! - ({result})`)
	end
end

--%%%%%%%%%%%%%%%%%%%% Load Saved Toolbar

--[[
	Loads the saved Toolbar order and moves the matching Tools onto it.
	Saved slots whose Tools have not arrived yet stay pending until those Tools are added.
]]
function Module._loadSavedToolbar()
	--[[ Checks ]]

	local character: Model? = I.Env.LocalPlayer.Character

	-- Skipping while the character is missing or dead
	if not isCharacterAlive(character) then
		return
	end

	--[[ Getting Saved Toolbar ]]

	local response = nil --- @type { [string]: any }?

	if _settings.TOOLBAR_SAVE then
		-- Sending a waiting save before asking for the saved order
		Module._flushToolbarSave()
		response = I.Network.Invoke("_backpackPlus_GetSavedToolbarslots", I.Platform.Current)

		-- Keeping the current Toolbar when the server didn't answer or the character changed meanwhile
		if not response or not response.ToolbarSlots or I.Env.LocalPlayer.Character ~= character or not isCharacterAlive(character) then
			return
		end
	end

	--[[ Reset Occupancy ]]

	-- Blocking saves while the Toolbar is rebuilt
	ctx.ToolbarServerLoaded = false
	table.clear(ctx.PendingToolbarSlots)

	Module._clearToolbarOccupancy()
	Module._applyToolbarSlotCount()

	ctx.ApplyReservations()

	--%%%%%%%%%%%%%%%%%%%% SAVE DISABLED

	if not _settings.TOOLBAR_SAVE then
		-- Moving Tools to the Toolbar, as no order is saved
		Module._fillToolbar()
		ctx.ToolbarServerLoaded = true
		ctx.ApplyReservations()
		return
	end

	--%%%%%%%%%%%%%%%%%%%% SAVE ENABLED

	--[[ Local Variables ]]

	local savedSlotsIds = response.ToolbarSlots --- @type { [string]: string }
	local lastPlatform: string? = response.LastPlatform
	local toolbarSlotCount: number = ctx.ToolbarSlotCount

	--[[ Resolving Saved Slots ]]

	local resolvedSlots = Module._resolveSavedToolbarSlots(savedSlotsIds) --- @type { [number]: BackpackPlus_SlotData }

	--[[ Moving to Toolbar ]]

	local movedSlots: number = 0

	for slotId: number = 1, toolbarSlotCount do
		local savedId: string? = savedSlotsIds[`{slotId}`]
		local slotData = resolvedSlots[slotId] --- @type BackpackPlus_SlotData?

		-- Keeping saved slots whose Tools have not arrived yet as pending
		if not slotData then
			if type(savedId) == "string" and not ctx.IsToolbarSlotReserved(slotId) then
				ctx.PendingToolbarSlots[slotId] = savedId
			end
			continue
		end

		--[[ Equipping ]]

		ctx.DropSlot(slotData.Slot, slotId)
		movedSlots += 1
	end

	--[[ Filling ]]

	-- Filling empty toolbar slots
	if _settings.TOOLBAR_FILL_ONLY_WHEN_EMPTY then
		if movedSlots == 0 then
			Module._fillToolbar()
		end
	else
		Module._fillToolbar()
	end

	-- Filling remaining slots once when joining with more capacity than the previous platform
	if _settings.TOOLBAR_FILL_ON_PLATFORM_CHANGED then
		local lastPlatformSlotCount: number = getToolbarSlotCountForPlatform(lastPlatform)
		if lastPlatformSlotCount < toolbarSlotCount then
			Module._fillToolbar()
		end
	end

	-- Marking as loaded from server
	ctx.ToolbarServerLoaded = true

	--[[ Reservations ]]

	ctx.ApplyReservations()
end

--%%%%%%%%%%%%%%%%%%%% Resolve Saved Toolbar Slots

--[[
	Matches saved Toolbar slot ids to existing Slots, by UUID first and then by name.
	Each Slot is matched once, so same-named Tools fill their own saved slots.
]]
--- @param savedSlotsIds { [string]: string }
--- @return { [number]: BackpackPlus_SlotData }
function Module._resolveSavedToolbarSlots(savedSlotsIds)
	--[[ Local Variables ]]

	local resolvedSlots = {} --- @type { [number]: BackpackPlus_SlotData }
	local placedSlots = {} --- @type { [BackpackPlus_SlotData]: boolean }
	local candidateSlots = {} --- @type { BackpackPlus_SlotData }

	--[[ Getting Candidate Slots ]]

	--- @param slotData BackpackPlus_SlotData
	for _slotFrame: Frame, slotData in pairs(ctx.CreatedSlots.BySlot) do
		-- Skipping reservation-locked Tools
		if ctx.IsToolReservationLocked(slotData.Tool) then
			continue
		end

		table.insert(candidateSlots, slotData)
	end

	-- Stable match order by backpack LayoutOrder
	sortSlotsByLayoutOrder(candidateSlots)

	--[[ Matching ]]

	for _index: number, matchBy: string in ipairs({ "UUID", "Name" }) do
		for slotId: number = 1, ctx.ToolbarSlotCount do
			local savedId: string? = savedSlotsIds[`{slotId}`]

			-- Skipping empty, already matched and reserved Toolbar Slots
			if type(savedId) ~= "string" or resolvedSlots[slotId] or ctx.IsToolbarSlotReserved(slotId) then
				continue
			end

			--- @param slotData BackpackPlus_SlotData
			for _candidateIndex: number, slotData in ipairs(candidateSlots) do
				-- Skipping placed and non-matching Slots
				if placedSlots[slotData] or not toolMatchesSavedId(slotData.Tool, savedId, matchBy) then
					continue
				end

				--[[ Saving ]]

				resolvedSlots[slotId] = slotData
				placedSlots[slotData] = true
				break
			end
		end
	end

	--[[ Returning ]]

	return resolvedSlots
end

--%%%%%%%%%%%%%%%%%%%% Clear Toolbar Occupancy

--[[
	Moves any toolbar-equipped Slots back to the backpack and clears occupancy.
]]
function Module._clearToolbarOccupancy()
	--[[ Local Variables ]]

	local maxToolbarSlots: number = _settings.TOOLBAR_SLOTS["Default"]

	--[[ Clearing ]]

	for slotId: number = 1, maxToolbarSlots do
		--- @type BackpackPlus_SlotData?
		local occupiedSlotData = ctx.EquippedSlots[slotId]

		-- Moving occupied Slot back to ItemsContainer
		if occupiedSlotData and occupiedSlotData.Slot and occupiedSlotData.Slot.Parent then
			occupiedSlotData.Slot.LayoutOrder = occupiedSlotData.LayoutOrder
			occupiedSlotData.Slot.Parent = elems["ItemsContainer"]
			occupiedSlotData.Elems["KeyCodeText"].Visible = false
		end

		-- Clearing occupancy
		ctx.EquippedSlots[slotId] = nil

		-- Restoring Toolbar Slot visibility within capacity
		if ctx.ToolbarSlots[slotId] then
			local isWithinCapacity: boolean = slotId <= ctx.ToolbarSlotCount
			ctx.ToolbarSlots[slotId].Visible = isWithinCapacity and elems["Backpack"].Visible
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Toggle Item At Slot

--[[
	**CLIENT** |
	Toggles Item equipped at `slotId` Toolbar Slot.
]]
function Module.ToggleItemAtSlot(slotId: number)
	--[[ Checks ]]

	-- Locked
	if ctx.IsLocked then
		return
	end

	-- Slot id outside capacity
	if slotId > ctx.ToolbarSlotCount then
		return
	end

	--[[ Toggling ]]

	-- Toggling Item at occupied Toolbar Slot
	if ctx.EquippedSlots[slotId] then
		ctx.ToggleItem(ctx.EquippedSlots[slotId].Slot)
	end
end

--%%%%%%%%%%%%%%%%%%%% Cycle Toolbar

--[[
	**CLIENT** |
	Equips the Tool on the next occupied Toolbar Slot after the equipped one (`direction` 1) or before it (-1),
	wrapping around. With nothing equipped it starts from the first or the last occupied Slot.
]]
function Module.CycleToolbar(direction: number)
	--[[ Checks ]]

	-- Locked
	if ctx.IsLocked then
		return
	end

	--[[ Finding ]]

	local occupiedSlotIds = {} --- @type { number }
	local equippedIndex: number? = nil

	for slotId: number = 1, ctx.ToolbarSlotCount do
		-- Skipping empty Toolbar Slots
		if not ctx.EquippedSlots[slotId] then
			continue
		end

		table.insert(occupiedSlotIds, slotId)
		if ctx.EquippedSlots[slotId].Tool == ctx.CurrentlyEquipped then
			equippedIndex = #occupiedSlotIds
		end
	end

	--[[ Checks ]]

	-- No Tools on the Toolbar
	if #occupiedSlotIds == 0 then
		return
	end

	--[[ Calculating ]]

	local nextIndex: number = if direction > 0 then 1 else #occupiedSlotIds
	if equippedIndex then
		nextIndex = (equippedIndex - 1 + direction) % #occupiedSlotIds + 1
	end

	--[[ Checks ]]

	-- Keeping the only Tool equipped
	if nextIndex == equippedIndex then
		return
	end

	--[[ Equipping ]]

	local slotId: number = occupiedSlotIds[nextIndex]
	Module.ToggleItemAtSlot(slotId)

	--[[ Feedback ]]

	-- The gamepad has no button on the slot: play the slot's click look and sound
	I.Utils.PlayPress(ctx.EquippedSlots[slotId].Slot:FindFirstChild("S_SlotButton"))
end

--%%%%%%%%%%%%%%%%%%%% Reload Toolbar

--[[
	**CLIENT** |
	Loads the saved Toolbar order again and moves the matching Tools onto it, for Tools granted after spawning.
]]
function Module.ReloadToolbar()
	--[[ Loading ]]

	Module._loadToolbarFromServer()
end

--%%%%%%%%%%%%%%%%%%%% Fill Toolbar

--[[
	Fills empty toolbar slots with unequipped Tools.
]]
function Module._fillToolbar()
	--[[ Getting All Free Slots ]]

	local freeToolbarSlotsIds = Module._getFreeToolbarSlotIds() --- @type { number }

	--[[ Getting Unequipped Slots ]]

	--- @type { BackpackPlus_SlotData }
	local unequippedSlots = {}

	--- @param slotData BackpackPlus_SlotData
	for _slotFrame: Frame, slotData in pairs(ctx.CreatedSlots.BySlot) do
		local isEquipped: boolean = false

		-- Checking if Slot is already on the Toolbar
		--- @param equippedSlotData BackpackPlus_SlotData
		for _slotId: number, equippedSlotData in pairs(ctx.EquippedSlots) do
			if equippedSlotData == slotData then
				isEquipped = true
				break
			end
		end

		-- Collecting unequipped Slots
		if not isEquipped and not ctx.GetReservedSlotIdForTool(slotData.Tool) then
			table.insert(unequippedSlots, slotData)
		end
	end

	--[[ Sorting ]]

	-- Stable fill order by backpack LayoutOrder
	sortSlotsByLayoutOrder(unequippedSlots)

	--[[ Filling Empty Slots ]]

	local unequippedIndex: number = 1
	for _, toolbarSlotId: number in ipairs(freeToolbarSlotsIds) do
		local slotData = unequippedSlots[unequippedIndex] --- @type BackpackPlus_SlotData?

		-- No more unequipped Slots left to fill with
		if not slotData then
			break
		end

		ctx.DropSlot(slotData.Slot, toolbarSlotId)
		unequippedIndex += 1
	end

	--[[ Saving ]]

	-- Saving only when a Slot was moved
	if unequippedIndex > 1 then
		Module._saveToolbarToServer()
	end
end

--%%%%%%%%%%%%%%%%%%%% Apply Toolbar Slot Count

--[[
	Applies the current platform Toolbar slot count and migrates overflow slots.
]]
function Module._applyToolbarSlotCount()
	--[[ Local Variables ]]

	local previousSlotCount: number = ctx.ToolbarSlotCount
	local toolbarSlotCount: number = getToolbarSlotCount()
	ctx.ToolbarSlotCount = toolbarSlotCount

	--[[ Migrating Overflow ]]

	local movedOverflow: boolean = false
	local maxToolbarSlots: number = _settings.TOOLBAR_SLOTS["Default"]

	for slotId: number = toolbarSlotCount + 1, maxToolbarSlots do
		--- @type BackpackPlus_SlotData?
		local occupiedSlotData = ctx.EquippedSlots[slotId]

		-- Moving overflow Slot back to ItemsContainer
		if occupiedSlotData and occupiedSlotData.Slot and occupiedSlotData.Slot.Parent then
			occupiedSlotData.Slot.LayoutOrder = occupiedSlotData.LayoutOrder
			occupiedSlotData.Slot.Parent = elems["ItemsContainer"]
			occupiedSlotData.Elems["KeyCodeText"].Visible = false
			movedOverflow = true
		end

		-- Clearing occupancy
		ctx.EquippedSlots[slotId] = nil

		-- Hiding overflow Toolbar Slot
		if ctx.ToolbarSlots[slotId] then
			ctx.ToolbarSlots[slotId].Visible = false
		end
	end

	--[[ Restoring Visible Placeholders ]]

	if elems["Backpack"].Visible then
		for slotId: number = 1, toolbarSlotCount do
			-- Showing empty Toolbar Slots within capacity
			if ctx.ToolbarSlots[slotId] then
				ctx.ToolbarSlots[slotId].Visible = ctx.EquippedSlots[slotId] == nil
			end
		end
	end

	--[[ Updating Layout ]]

	-- Compacting and syncing after overflow moved into the backpack
	if movedOverflow then
		ctx.CompactItemsContainerLayoutOrders()
		ctx.UpdateSearchBar()

		-- Saving toolbar to server
		if ctx.ToolbarServerLoaded then
			ctx.SaveToolbarToServer()
		end
	end

	-- Refreshing display when capacity changed
	if previousSlotCount ~= toolbarSlotCount then
		ctx.UpdateDisplay()
	end
end

--%%%%%%%%%%%%%%%%%%%% Take Pending Toolbar Slot Id

--[[
	Returns the empty Toolbar slot a newly added Tool was saved in, and removes that pending entry.
]]
--- @return number?
function Module._takePendingToolbarSlotId(tool: Tool)
	--[[ Finding ]]

	for _index: number, matchBy: string in ipairs({ "UUID", "Name" }) do
		for slotId: number = 1, ctx.ToolbarSlotCount do
			local savedId: string? = ctx.PendingToolbarSlots[slotId]

			-- Skipping Toolbar Slots with no matching pending entry
			if not savedId or not toolMatchesSavedId(tool, savedId, matchBy) then
				continue
			end

			-- Dropping entries whose Toolbar Slot got taken or reserved
			if ctx.EquippedSlots[slotId] or ctx.IsToolbarSlotReserved(slotId) then
				ctx.PendingToolbarSlots[slotId] = nil
				continue
			end

			--[[ Taking ]]

			ctx.PendingToolbarSlots[slotId] = nil
			return slotId
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Reset Toolbar State

--[[
	Forgets the loaded Toolbar when the character dies or is removed, so removing its Tools doesn't save a shrinking Toolbar.
]]
function Module._resetToolbarState()
	--[[ Resetting ]]

	-- Blocking saves and Toolbar placement until the next load
	ctx.ToolbarServerLoaded = false
	table.clear(ctx.PendingToolbarSlots)

	-- Resetting LayoutOrder and occupancy
	ctx.LastLayoutOrder = 0
	table.clear(ctx.EquippedSlots)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control - Server

--%%%%%%%%%%%%%%%%%%%% Save Toolbar To Server

--[[
	Marks the Toolbar order as changed and sends it once after a short delay, so a burst of changes is one save.
]]
function Module._saveToolbarToServer()
	--[[ Checks ]]

	-- Toolbar saving is disabled
	if not _settings.TOOLBAR_SAVE then
		return
	end

	--[[ Scheduling ]]

	isSaveDirty = true

	-- Skipping when a save is already scheduled
	if isSaveScheduled then
		return
	end

	isSaveScheduled = true
	task.delay(TOOLBAR_SAVE_DELAY, function()
		isSaveScheduled = false
		Module._flushToolbarSave()
	end)
end

--%%%%%%%%%%%%%%%%%%%% Flush Toolbar Save

--[[
	Sends the current Toolbar order to the server when it changed.
	Saved slots whose Tools have not arrived yet are sent back unchanged so the server keeps them.
]]
function Module._flushToolbarSave()
	--[[ Checks ]]

	-- Nothing changed since the last save
	if not isSaveDirty then
		return
	end

	isSaveDirty = false

	-- Toolbar is not loaded (respawning or loading)
	if not ctx.ToolbarServerLoaded then
		return
	end

	--[[ Getting Toolbar Slot Ids ]]

	local equippedIds = {} --- @type { [string]: string }

	--- @param slotData BackpackPlus_SlotData
	for slotId: number, slotData in pairs(ctx.EquippedSlots) do
		-- Skipping Toolbar Slots outside capacity
		if slotId > ctx.ToolbarSlotCount then
			continue
		end

		-- Skipping empty Slots
		if not slotData.Tool then
			continue
		end

		-- Skipping reserved Toolbar Slots
		if ctx.IsToolbarSlotReserved(slotId) then
			continue
		end

		-- Saving Id
		local toolUUID: string = slotData.Tool:GetAttribute("Tool_ServerUUID")
		local retrieveType: string? = slotData.Tool:GetAttribute("BackpackPlus_ToolbarRetrieve")
		equippedIds[`{slotId}`] = `{toolUUID}___{slotData.Tool.Name}___{retrieveType}`
	end

	--[[ Keeping Pending Slots ]]

	for slotId: number, savedId: string in pairs(ctx.PendingToolbarSlots) do
		-- Dropping entries whose Toolbar Slot got taken
		if ctx.EquippedSlots[slotId] then
			ctx.PendingToolbarSlots[slotId] = nil
			continue
		end

		-- Skipping Toolbar Slots outside capacity or reserved
		if slotId > ctx.ToolbarSlotCount or ctx.IsToolbarSlotReserved(slotId) then
			continue
		end

		equippedIds[`{slotId}`] = savedId
	end

	--[[ Saving ]]

	-- Firing saved Toolbar Slot ids to the server
	I.Network.Fire("_backpackPlus_UpdateSavedToolbarSlots", equippedIds)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Slot Size

--[[
	Returns the shared Toolbar slot size.
]]
--- @return UDim2
function Module._getSlotSize()
	return toolbarSlotSize
end

--%%%%%%%%%%%%%%%%%%%% Get Slot Absolute Size

--[[
	Returns the shared absolute Toolbar slot size.
]]
--- @return Vector2
function Module._getSlotAbsoluteSize()
	return toolbarSlotAbsoluteSize
end

--%%%%%%%%%%%%%%%%%%%% Get Free Toolbar Slot Ids

--[[
	Returns the empty, unreserved Toolbar slot ids within capacity.
	Slots saved for Tools that have not arrived yet come last.
]]
--- @return { number }
function Module._getFreeToolbarSlotIds()
	--[[ Local Variables ]]

	local freeSlotIds = {} --- @type { number }
	local pendingSlotIds = {} --- @type { number }

	--[[ Collecting ]]

	for slotId: number = 1, ctx.ToolbarSlotCount do
		-- Skipping occupied and reserved Toolbar Slots
		if ctx.EquippedSlots[slotId] or ctx.IsToolbarSlotReserved(slotId) then
			continue
		end

		-- Keeping Toolbar Slots with a pending saved Tool for last
		if ctx.PendingToolbarSlots[slotId] then
			table.insert(pendingSlotIds, slotId)
		else
			table.insert(freeSlotIds, slotId)
		end
	end

	--[[ Merging ]]

	table.move(pendingSlotIds, 1, #pendingSlotIds, #freeSlotIds + 1, freeSlotIds)

	--[[ Returning ]]

	return freeSlotIds
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
