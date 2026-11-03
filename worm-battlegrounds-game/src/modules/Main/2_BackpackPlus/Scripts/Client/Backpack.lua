--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "BackpackPlus"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance | GuiObject }

--[[ Shared ]]

--- @type BackpackPlus_ClientContext
local ctx

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Toolbar Slot Size

--[[
	Returns the square Toolbar slot size for the current platform capacity.
]]
--- @return number
local function getToolbarSlotSize()
	return elems["Toolbar"].AbsoluteSize.X / ctx.ToolbarSlotCount
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

--- @class BackpackPlus_Client_Backpack
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _ctx BackpackPlus_ClientContext
function Module.Init(_ctx)
	ctx = _ctx

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._getElements()

	ctx.GetState = Module.GetState
	ctx.ForceClose = Module.ForceClose
	ctx.UpdateToolbarSlotsSize = Module._updateToolbarSlotsSize
	ctx.UpdateDisplay = Module._updateDisplay
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing backpack display elements.
]]
function Module._getElements()
	local backpackGui: ScreenGui = I.UserInterface.UI["BackpackPlus"]

	--[[ General ]]

	elems["Backpack"] = backpackGui:FindFirstChild("U_Backpack", true) --- @type Frame
	elems["Toolbar"] = backpackGui:FindFirstChild("U_Toolbar", true) --- @type Frame
	elems["ItemsContainer"] = elems["Backpack"]:FindFirstChild("S_ItemsContainer", true) --- @type Frame
	elems["ItemsContainerGridLayout"] = elems["Backpack"]:FindFirstChild("S_ItemsContainerGridLayout", true) --- @type UIGridLayout

	-- Hiding general
	elems["Backpack"].Visible = false
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Toggle

--[[
	**CLIENT** |
	Toggles the backpack view.
]]
function Module.Toggle()
	--[[ Checks ]]

	-- Locked
	if ctx.IsLocked then
		return
	end

	--[[ Updating ]]

	-- Updating backpack visibility
	local newVisibility: boolean = not elems["Backpack"].Visible
	elems["Backpack"].Visible = newVisibility

	-- Updating Toolbar slots visibility
	if newVisibility then
		for i: number, slot: Frame in ipairs(ctx.ToolbarSlots) do
			if i > ctx.ToolbarSlotCount then
				-- Toolbar Slot out of display bounds
				slot.Visible = false
			else
				-- Show if there's no Slot on top of it
				slot.Visible = ctx.EquippedSlots[i] == nil
			end
		end
	else
		-- Hiding all Toolbar Slots from view (do not affect Item Slots placed over them)
		for _, slot: Frame in ipairs(ctx.ToolbarSlots) do
			slot.Visible = false
		end
	end

	-- Updating display
	Module._updateDisplay()
end

--%%%%%%%%%%%%%%%%%%%% Force Close

--[[
	Closes the backpack view without lock checks.
]]
function Module.ForceClose()
	--[[ Checks ]]

	-- Already closed
	if not elems["Backpack"].Visible then
		return
	end

	--[[ Updating ]]

	elems["Backpack"].Visible = false

	for _, slot: Frame in ipairs(ctx.ToolbarSlots) do
		slot.Visible = false
	end

	Module._updateDisplay()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Display Control

--%%%%%%%%%%%%%%%%%%%% Update Display

--[[
	Runs all display update functions.
]]
function Module._updateDisplay()
	Module._updateToolbarSlotsSize()
	Module._updateBackpackSize()
	Module._updateBackpackPosition()
end

--%%%%%%%%%%%%%%%%%%%% Update Toolbar Slots Size

--[[
	Updates size of the Item Slots inside of the Toolbar.
]]
function Module._updateToolbarSlotsSize()
	-- Calculating slot size
	local goalSlotSize: number = getToolbarSlotSize()

	--[[ Updating Sizes ]]

	for _, slot: Frame | any in ipairs(elems["Toolbar"]:GetChildren()) do
		if slot:IsA("Frame") then
			slot.Size = UDim2.fromOffset(goalSlotSize, goalSlotSize)
		end
	end

	--[[ Updating Display ]]

	ctx.UpdateToolbarSlotDefaults()
	task.defer(ctx.UpdateToolbarSlotDefaults)
end

--%%%%%%%%%%%%%%%%%%%% Update Backpack Size

--[[
	Updates size of the backpack and it's inner Items Container.
]]
function Module._updateBackpackSize()
	--[[ Backpack Size ]]

	local toolbarSlotCount: number = ctx.ToolbarSlotCount
	local goalSlotSize: number = getToolbarSlotSize()
	local goalBackpackWidth: number = goalSlotSize * toolbarSlotCount

	elems["Backpack"].Size = UDim2.new(0, goalBackpackWidth, 1, 0)

	--[[ Items Container ]]

	local itemsContainerWidth: number = elems["ItemsContainer"].AbsoluteSize.X
	local itemWidth: number = itemsContainerWidth / toolbarSlotCount

	elems["ItemsContainerGridLayout"].CellSize = UDim2.fromOffset(itemWidth, itemWidth)
end

--%%%%%%%%%%%%%%%%%%%% Update Backpack Position

--[[
	Updates position of the backpack to be above the toolbar.
]]
function Module._updateBackpackPosition()
	--[[ Calculating Toolbar Slot Top Y ]]

	local goalSlotSize: number = getToolbarSlotSize()
	local toolbarPosY: number = elems["Toolbar"].AbsolutePosition.Y
	local toolbarSizeY: number = elems["Toolbar"].AbsoluteSize.Y
	local slotTopY: number = toolbarPosY + toolbarSizeY - goalSlotSize
	local insetSize: Rect = I.S.GuiService.TopbarInset

	--[[ Updating Position ]]

	elems["Backpack"].Position = UDim2.new(0.5, 0, 0, slotTopY + insetSize.Height - (goalSlotSize / 10))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get State

--[[
	**CLIENT** |
	Returns if the Backpack is open.
]]
--- @return boolean
function Module.GetState()
	return elems["Backpack"].Visible
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
