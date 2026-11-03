--[[
	Created By: 	Nari
]]

local _localName: string = "BackpackPlusPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local TweenService: TweenService = game:GetService("TweenService")
local UserInputService: UserInputService = game:GetService("UserInputService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Slots ]]

-- The toolbar's slot count by device (ume's BackpackPlus TOOLBAR_SLOTS; devices it leaves out use Default), and the
-- fills BackpackPlus gives a slot's background: black at rest, grey while its tool is equipped
--- @type { [string]: number }
local TOOLBAR_SLOTS = { Default = 10, Mobile = 6 }
local SLOT_COLOR: Color3 = Color3.fromRGB(0, 0, 0)
local EQUIPPED_COLOR: Color3 = Color3.fromRGB(50, 50, 50)

--[[ Items ]]

-- Example tools the slots take in turn: a name, a quantity above one shows as "x<quantity>", an icon replaces the
-- name, a favourite shows its mark, and the category the left buttons filter by (the demo's Category1 and Category2)
--- @type { { [string]: any } }
local ITEMS = {
	{ Name = "Sword" },
	{ Name = "Pickaxe", Icon = "rbxassetid://136406065725570", Category = "Category1" },
	{ Name = "Apple", Quantity = 12, Category = "Category2" },
	{ Name = "Bow", Favorite = true },
	{ Name = "Torch", Quantity = 3, Category = "Category1" },
	{ Name = "Shovel" },
	{ Name = "Potion", Quantity = 5, Favorite = true, Category = "Category2" },
	{ Name = "Rope" },
}

--[[ Looks ]]

-- What BackpackPlus and its components draw in game: the Gold gradient on the favourite button while favourite mode
-- is on (FAVORITE_GRADIENT_NAME), the selected category's grey, and the favourite mark's pop in and out
local FAVORITE_GRADIENT: ColorSequence = ColorSequence.new(Color3.fromRGB(255, 183, 0), Color3.fromRGB(252, 231, 0))
local SELECTED_CATEGORY: ColorSequence = ColorSequence.new(Color3.fromRGB(60, 60, 60))
local FavoriteShow_TweenInfo: TweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
local FavoriteHide_TweenInfo: TweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

--[[ State ]]

-- Each previewed view's simulated backpack: its tools, what is equipped, favourite mode, the filters, the slots on
-- screen and the press under way. Weak by view, so it goes with it
local states = setmetatable({}, { __mode = "k" }) --- @type { [UmeGui_View]: { [string]: any } }

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

--- @class UmeGui_Guis_System_BackpackPlus_Preview
local Module = {

	--[[ Settings ]]

	-- Where the simulation starts, and again whenever one changes: whether the backpack view is open, how many toolbar
	-- slots hold a tool, how many more tools the backpack holds, and which toolbar slot is equipped (0 for none)
	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Toggle", Id = "S_Open", Label = "Backpack open", Value = true },
		{ Control = "Slider", Id = "S_Toolbar", Label = "Toolbar tools", Value = 4, Min = 0, Max = TOOLBAR_SLOTS.Default, Step = 1 },
		{ Control = "Slider", Id = "S_Items", Label = "Backpack tools", Value = 12, Min = 0, Max = 40, Step = 1 },
		{ Control = "Slider", Id = "S_Equipped", Label = "Equipped slot", Value = 1, Min = 0, Max = TOOLBAR_SLOTS.Default, Step = 1 },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Starts the simulated backpack from the settings on the previewed device, and makes the gui work as BackpackPlus does
	in game: click to equip, right-click to favourite, drag between the toolbar and the backpack, favourite mode, the
	category buttons, the search, and the gamepad (bumpers, D-pad, B).
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local view = preview.View --- @type UmeGui_View
	local slotCount: number = TOOLBAR_SLOTS[preview.Device] or TOOLBAR_SLOTS.Default
	local toolbarTools: number = math.min(preview.Values.S_Toolbar, slotCount)
	local connected: boolean = states[view] ~= nil

	--[[ Tools ]]

	-- Copies, so favourites change on this preview's tools only
	local toolbar = {} --- @type { [number]: { [string]: any } }
	local backpack = {} --- @type { { [string]: any } }

	for index: number = 1, toolbarTools do
		toolbar[index] = table.clone(ITEMS[(index - 1) % #ITEMS + 1])
	end
	for index: number = 1, preview.Values.S_Items do
		table.insert(backpack, table.clone(ITEMS[(toolbarTools + index - 1) % #ITEMS + 1]))
	end

	--[[ State ]]

	states[view] = {
		Preview = preview,
		SlotCount = slotCount,
		Open = preview.Values.S_Open,
		Toolbar = toolbar,
		Backpack = backpack,
		Equipped = toolbar[preview.Values.S_Equipped],
		FavoriteMode = false,
		Category = "",
		Search = "",
		Slots = {},
		Mouse = Vector2.zero,
		Press = nil,
		Dragging = false,
		DidDrag = false,
		Animating = {},
		Defaults = if connected then states[view].Defaults else {},
	}

	--[[ Building ]]

	-- Wire the view's own buttons and the gamepad once per build of the gui
	if not connected then
		Module._connectView(view)
	end

	Module._build(view)
end

--%%%%%%%%%%%%%%%%%%%% Connect View

--[[
	Wires the parts of the gui that stay between refills: the favourite mode button, the category buttons, the search
	bar, a frame over the whole preview that follows the mouse (for drags), and the gamepad. Everything goes with the
	view's root.
]]
--- @param view UmeGui_View
function Module._connectView(view)
	--[[ Local Variables ]]

	local root: Instance = view.Root
	local connections = {} --- @type { RBXScriptConnection }

	--[[ Favourite Mode ]]

	local favoriteButton: ImageButton = view:Get("U_Backpack", "S_FavoriteButton").Instance
	table.insert(
		connections,
		favoriteButton.MouseButton1Click:Connect(function()
			states[view].FavoriteMode = not states[view].FavoriteMode
			Module._paint(view)
		end)
	)

	--[[ Categories ]]

	for _index: number, button: Instance in ipairs(root:GetDescendants()) do
		-- Skip anything but the category buttons (BackpackPlus_FilterButton)
		if not button:IsA("GuiButton") or button:GetAttribute("BackpackPlus_FilterCategory") == nil then
			continue
		end

		table.insert(
			connections,
			button.MouseButton1Click:Connect(function()
				states[view].Category = button:GetAttribute("BackpackPlus_FilterCategory")
				Module._paint(view)
			end)
		)
	end

	--[[ Search ]]

	local searchBar: TextBox = view:Get("U_Backpack", "S_SearchBar").Instance
	table.insert(
		connections,
		searchBar:GetPropertyChangedSignal("Text"):Connect(function()
			states[view].Search = searchBar.Text
			Module._paint(view)
		end)
	)

	--[[ Mouse ]]

	-- MouseMoved gives the mouse in the gui's own space; UserInputService only follows it while the 3D view has focus
	local tracker: Frame = Instance.new("Frame")
	tracker.Name = "__MouseTracker"
	tracker.Archivable = false
	tracker.BackgroundTransparency = 1
	tracker.Size = UDim2.fromScale(1, 1)
	tracker.ZIndex = -100
	tracker.Parent = root

	table.insert(
		connections,
		tracker.MouseMoved:Connect(function(x: number, y: number)
			Module._moveMouse(view, Vector2.new(x, y))
		end)
	)
	table.insert(
		connections,
		tracker.InputEnded:Connect(function(input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				Module._endPress(view)
			end
		end)
	)

	--[[ Gamepad ]]

	table.insert(
		connections,
		UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
			-- Skip input typed into a field
			if processed then
				return
			end

			Module._pressKey(view, input.KeyCode)
		end)
	)

	--[[ Cleanup ]]

	root.Destroying:Once(function()
		for _index: number, connection: RBXScriptConnection in ipairs(connections) do
			connection:Disconnect()
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Build

--[[
	Clones the slots the simulated backpack shows, as BackpackPlus does: every toolbar slot while the backpack is open
	(only the ones holding a tool while it is closed), and the backpack's tools in its grid; then wires and draws them.
]]
--- @param view UmeGui_View
function Module._build(view)
	--[[ Local Variables ]]

	local state = states[view] --- @type { [string]: any }
	local itemsContainer: Frame = view:Get("U_Backpack", "S_ItemsContainer").Instance
	local places = {} --- @type { { [string]: any } }

	for index: number = 1, state.SlotCount do
		-- Skip empty toolbar slots while the backpack is closed
		if state.Open or state.Toolbar[index] then
			table.insert(places, { Area = "Toolbar", Index = index })
		end
	end
	if state.Open then
		for index: number = 1, #state.Backpack do
			table.insert(places, { Area = "Backpack", Index = index })
		end
	end

	--[[ Slots ]]

	local slots = state.Preview.Fill("PREFAB | Slot", #places) --- @type { UmeGui_Subview }
	state.Slots = {}
	state.Animating = {}

	--- @param slot UmeGui_Subview
	for index: number, slot in ipairs(slots) do
		local place = places[index] --- @type { [string]: any }
		local keyCode: TextLabel = slot:Get("S_KeyCode").Instance

		-- The favourite mark's built size, which its pop tweens to
		if not state.Defaults.FavoriteIconSize then
			state.Defaults.FavoriteIconSize = slot:Get("S_FavoriteIcon").Instance.Size
		end

		slot.Root.Instance.LayoutOrder = place.Index
		keyCode.Visible = place.Area == "Toolbar"
		keyCode.Text = if place.Index ~= 10 then `{place.Index}` else "0"
		if place.Area == "Backpack" then
			slot.Root.Instance.Parent = itemsContainer
		end

		state.Slots[slot] = place
		Module._connectSlot(view, slot)
	end

	--[[ Drawing ]]

	view:Get("U_Backpack").Instance.Visible = state.Open
	Module._paint(view)
	Module._followToolbar(view)
end

--%%%%%%%%%%%%%%%%%%%% Connect Slot

--[[
	Wires one slot's button as BackpackPlus's Slot component does: a click equips or unequips its tool (or favourites
	it in favourite mode), a right-click favourites it, and a press that moves a fifth of the slot starts a drag.
]]
--- @param view UmeGui_View
--- @param slot UmeGui_Subview
function Module._connectSlot(view, slot)
	--[[ Local Variables ]]

	local button: ImageButton = slot:Get("S_SlotButton").Instance

	--[[ Click ]]

	button.MouseButton1Click:Connect(function()
		local state = states[view] --- @type { [string]: any }
		local item = Module._getItem(state, slot) --- @type { [string]: any }?

		-- Skip the click a drag's release fires, and a slot without a tool
		if state.DidDrag or not item then
			state.DidDrag = false
			return
		end

		if state.FavoriteMode then
			Module._toggleFavorite(view, slot)
		else
			state.Equipped = if state.Equipped == item then nil else item
			Module._paint(view)
		end
	end)

	--[[ Right Click ]]

	button.MouseButton2Click:Connect(function()
		-- Skip a slot without a tool
		if not Module._getItem(states[view], slot) then
			return
		end

		Module._toggleFavorite(view, slot)
	end)

	--[[ Drag ]]

	button.MouseButton1Down:Connect(function()
		local state = states[view] --- @type { [string]: any }

		-- Skip presses while the backpack is closed, and on a slot without a tool
		if not state.Open or not Module._getItem(state, slot) then
			return
		end

		state.DidDrag = false
		state.Press = { Slot = slot, Start = state.Mouse }
	end)
	button.MouseMoved:Connect(function(x: number, y: number)
		Module._moveMouse(view, Vector2.new(x, y))
	end)
	button.MouseButton1Up:Connect(function()
		Module._endPress(view)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Paint

--[[
	Draws the simulated backpack on the slots on screen: each slot's tool, the equipped one's grey, the favourite marks,
	the backpack's tools that match the category and the search, the favourite button's gold in favourite mode, and
	the selected category's grey.
]]
--- @param view UmeGui_View
function Module._paint(view)
	--[[ Local Variables ]]

	local state = states[view] --- @type { [string]: any }
	local root: Instance = view.Root

	--[[ Slots ]]

	--- @param slot UmeGui_Subview
	--- @param place { [string]: any }
	for slot, place in pairs(state.Slots) do
		local item = Module._getItem(state, slot) --- @type { [string]: any }?
		local icon: ImageLabel = slot:Get("S_ItemIcon").Instance
		local name: TextLabel = slot:Get("S_ItemName").Instance
		local quantity: TextLabel = slot:Get("S_Quantity").Instance

		icon.Image = if item and item.Icon then item.Icon else ""
		icon.Visible = item ~= nil and item.Icon ~= nil
		name.Text = if item then item.Name else ""
		name.Visible = item ~= nil and not icon.Visible
		quantity.Text = if item and item.Quantity then `x{item.Quantity}` else ""
		quantity.Visible = item ~= nil and item.Quantity ~= nil and item.Quantity > 1
		slot:Get("S_Background").Instance.BackgroundColor3 = if item and item == state.Equipped then EQUIPPED_COLOR else SLOT_COLOR

		-- Leave a mark that is popping in or out to its tween
		if not state.Animating[slot] then
			slot:Get("S_FavoriteIconContainer").Instance.Visible = item ~= nil and item.Favorite == true
		end

		-- Filters apply to the backpack only, as in game
		slot.Root.Instance.Visible = place.Area == "Toolbar" or Module._matches(state, item)
	end

	--[[ Hints ]]

	-- On Console, as BackpackPlus keeps them: the bumpers only while the toolbar holds a tool, the unequip hint only over
	-- the equipped tool's toolbar slot while the backpack is closed
	local console: boolean = state.Preview.Device == "Console"
	local occupied: boolean = false

	for index: number = 1, state.SlotCount do
		occupied = occupied or state.Toolbar[index] ~= nil
	end

	view:Get("U_Toolbar", "S_PreviousHint").Instance.Visible = console and occupied
	view:Get("U_Toolbar", "S_NextHint").Instance.Visible = console and occupied

	--- @param slot UmeGui_Subview
	--- @param place { [string]: any }
	for slot, place in pairs(state.Slots) do
		local item = Module._getItem(state, slot) --- @type { [string]: any }?
		slot:Get("S_UnequipHint").Instance.Visible = console and not state.Open and place.Area == "Toolbar" and item ~= nil and item == state.Equipped
	end

	--[[ Favourite Mode ]]

	local favoriteGradient: UIGradient = view:Get("U_Backpack", "S_FavoriteButton").Instance:FindFirstChild("S_Background", true):FindFirstChildOfClass("UIGradient")
	if not state.Defaults[favoriteGradient] then
		state.Defaults[favoriteGradient] = { Color = favoriteGradient.Color, Transparency = favoriteGradient.Transparency }
	end
	favoriteGradient.Color = if state.FavoriteMode then FAVORITE_GRADIENT else state.Defaults[favoriteGradient].Color
	favoriteGradient.Transparency = if state.FavoriteMode then NumberSequence.new(0) else state.Defaults[favoriteGradient].Transparency

	--[[ Categories ]]

	for _index: number, button: Instance in ipairs(root:GetDescendants()) do
		-- Skip anything but the category buttons
		if not button:IsA("GuiButton") or button:GetAttribute("BackpackPlus_FilterCategory") == nil then
			continue
		end

		local gradient: UIGradient = button:FindFirstChild("S_Background", true):FindFirstChildOfClass("UIGradient")
		if not state.Defaults[gradient] then
			state.Defaults[gradient] = { Color = gradient.Color }
		end
		gradient.Color = if button:GetAttribute("BackpackPlus_FilterCategory") == state.Category then SELECTED_CATEGORY else state.Defaults[gradient].Color
	end
end

--%%%%%%%%%%%%%%%%%%%% Toggle Favorite

--[[
	Favourites or unfavourites a slot's tool and pops its mark in or out, with BackpackPlus's favourite tweens.
]]
--- @param view UmeGui_View
--- @param slot UmeGui_Subview
function Module._toggleFavorite(view, slot)
	--[[ Local Variables ]]

	local state = states[view] --- @type { [string]: any }
	local item = Module._getItem(state, slot) --- @type { [string]: any }
	local container: Frame = slot:Get("S_FavoriteIconContainer").Instance
	local icon: GuiObject = slot:Get("S_FavoriteIcon").Instance
	local defaultSize: UDim2 = state.Defaults.FavoriteIconSize

	--[[ Saving ]]

	item.Favorite = not item.Favorite
	state.Animating[slot] = true

	--[[ Tweening ]]

	if item.Favorite then
		icon.Size = UDim2.new()
		icon.Rotation = -45
		container.Visible = true

		local FavoriteShow_TweenGoal = { Size = defaultSize, Rotation = 0 }
		local FavoriteShow_Tween: Tween = TweenService:Create(icon, FavoriteShow_TweenInfo, FavoriteShow_TweenGoal)
		FavoriteShow_Tween.Completed:Once(function()
			state.Animating[slot] = nil
		end)
		FavoriteShow_Tween:Play()
	else
		local FavoriteHide_TweenGoal = { Size = UDim2.new() }
		local FavoriteHide_Tween: Tween = TweenService:Create(icon, FavoriteHide_TweenInfo, FavoriteHide_TweenGoal)
		FavoriteHide_Tween.Completed:Once(function()
			state.Animating[slot] = nil
			container.Visible = item.Favorite == true
			icon.Size = defaultSize
		end)
		FavoriteHide_Tween:Play()
	end
end

--%%%%%%%%%%%%%%%%%%%% Move Mouse

--[[
	Follows the mouse, starts a drag once a press moved a fifth of its slot, and keeps the dragged slot under the mouse.
]]
--- @param view UmeGui_View
function Module._moveMouse(view, mouse: Vector2)
	--[[ Checks ]]

	local state = states[view] --- @type { [string]: any }
	state.Mouse = mouse

	-- Skip moves while nothing is pressed
	if not state.Press then
		return
	end

	--[[ Starting ]]

	local slot = state.Press.Slot --- @type UmeGui_Subview
	local button: ImageButton = slot:Get("S_SlotButton").Instance
	local stage: GuiObject = view.Root.Parent

	if not state.Dragging then
		local slotSize: Vector2 = slot.Root.Instance.AbsoluteSize

		-- Skip until the press has moved a fifth of the slot, as BackpackPlus does
		if (mouse - state.Press.Start).Magnitude < math.min(slotSize.X, slotSize.Y) / 5 then
			return
		end

		-- The slot's button follows the mouse over everything, as in game
		state.Dragging = true
		state.DidDrag = true
		button.Size = UDim2.fromOffset(button.AbsoluteSize.X, button.AbsoluteSize.Y)
		button.ZIndex = 100
		button.Parent = view.Root
	end

	--[[ Moving ]]

	button.Position = UDim2.fromOffset(mouse.X - stage.AbsolutePosition.X, mouse.Y - stage.AbsolutePosition.Y)
end

--%%%%%%%%%%%%%%%%%%%% End Press

--[[
	Ends a press. A drag drops its tool where it was let go, as BackpackPlus's DropSlot does: on a toolbar slot it takes
	that slot (swapping with its tool), over the backpack it goes back into it, anywhere else it stays where it was.
]]
--- @param view UmeGui_View
function Module._endPress(view)
	--[[ Checks ]]

	local state = states[view] --- @type { [string]: any }
	local press = state.Press --- @type { [string]: any }?
	state.Press = nil

	-- Skip a press that never became a drag
	if not press or not state.Dragging then
		return
	end

	state.Dragging = false

	--[[ Target ]]

	local from = state.Slots[press.Slot] --- @type { [string]: any }
	local item = Module._getItem(state, press.Slot) --- @type { [string]: any }
	local target: number? = nil

	--- @param slot UmeGui_Subview
	--- @param place { [string]: any }
	for slot, place in pairs(state.Slots) do
		if place.Area == "Toolbar" and slot ~= press.Slot and Module._isOver(slot.Root.Instance, state.Mouse) then
			target = place.Index
		end
	end

	--[[ Dropping ]]

	if target and from.Area == "Toolbar" then
		state.Toolbar[from.Index], state.Toolbar[target] = state.Toolbar[target], item
	elseif target then
		local replaced = state.Toolbar[target] --- @type { [string]: any }?
		table.remove(state.Backpack, from.Index)
		state.Toolbar[target] = item
		if replaced then
			table.insert(state.Backpack, replaced)
		end
	elseif from.Area == "Toolbar" and Module._isOver(view:Get("U_Backpack").Instance, state.Mouse) then
		state.Toolbar[from.Index] = nil
		table.insert(state.Backpack, item)
	end

	--[[ Building ]]

	-- The dragged button left its slot, so the refill wouldn't remove it
	press.Slot:Get("S_SlotButton").Instance:Destroy()

	-- The rebuild removes the dragged button before its click fires; nothing is left to swallow
	Module._build(view)
	state.DidDrag = false
end

--%%%%%%%%%%%%%%%%%%%% Press Key

--[[
	The gamepad, as ume's Console module binds it: the bumpers equip the previous or next toolbar tool, D-pad up opens
	the backpack and D-pad down unequips while it is closed, and while it is open D-pad up and down select the category
	above or below and B closes it.
]]
--- @param view UmeGui_View
function Module._pressKey(view, keyCode: Enum.KeyCode)
	--[[ Local Variables ]]

	local state = states[view] --- @type { [string]: any }

	--[[ Toolbar ]]

	-- The bumpers equip the previous or next toolbar tool
	if keyCode == Enum.KeyCode.ButtonL1 or keyCode == Enum.KeyCode.ButtonR1 then
		Module._cycleToolbar(state, if keyCode == Enum.KeyCode.ButtonR1 then 1 else -1)
		Module._paint(view)

		--- @param slot UmeGui_Subview
		--- @param place { [string]: any }
		for slot, place in pairs(state.Slots) do
			if place.Area == "Toolbar" and state.Equipped and Module._getItem(state, slot) == state.Equipped then
				Module._playPress(state, slot:Get("S_SlotButton").Instance)
			end
		end
		return
	end

	--[[ Backpack ]]

	-- D-pad up opens the closed backpack, B closes the open one
	if (keyCode == Enum.KeyCode.DPadUp and not state.Open) or (keyCode == Enum.KeyCode.ButtonB and state.Open) then
		state.Open = not state.Open
		Module._build(view)
		return
	end

	--[[ Unequip ]]

	-- D-pad down puts the equipped tool away while the backpack is closed
	if keyCode == Enum.KeyCode.DPadDown and not state.Open and state.Equipped then
		--- @param slot UmeGui_Subview
		--- @param place { [string]: any }
		for slot, place in pairs(state.Slots) do
			if place.Area == "Toolbar" and Module._getItem(state, slot) == state.Equipped then
				Module._playPress(state, slot:Get("S_SlotButton").Instance)
			end
		end

		state.Equipped = nil
		Module._paint(view)
		return
	end

	--[[ Categories ]]

	-- D-pad up and down select the category above or below while the backpack is open
	if (keyCode == Enum.KeyCode.DPadUp or keyCode == Enum.KeyCode.DPadDown) and state.Open then
		local button: GuiObject? = Module._cycleCategory(view, if keyCode == Enum.KeyCode.DPadDown then 1 else -1)
		Module._paint(view)
		if button then
			Module._playPress(state, button)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Cycle Toolbar

--[[
	Equips the tool on the next occupied toolbar slot after the equipped one, or before it, wrapping around, as
	BackpackPlus's CycleToolbar does.
]]
--- @param state { [string]: any }
function Module._cycleToolbar(state, direction: number)
	--[[ Local Variables ]]

	local occupied = {} --- @type { number }
	local current: number = 0

	for index: number = 1, state.SlotCount do
		if state.Toolbar[index] then
			table.insert(occupied, index)
			current = if state.Toolbar[index] == state.Equipped then #occupied else current
		end
	end

	--[[ Checks ]]

	-- Skip an empty toolbar
	if #occupied == 0 then
		return
	end

	--[[ Equipping ]]

	local nextIndex: number = if current == 0 then (if direction > 0 then 1 else #occupied) else (current - 1 + direction) % #occupied + 1
	state.Equipped = state.Toolbar[occupied[nextIndex]]
end

--%%%%%%%%%%%%%%%%%%%% Cycle Category

--[[
	Selects the category above or below the selected one, in the order the category buttons stand on screen, wrapping
	from the last to the first and back, as BackpackPlus's CycleCategory does. Returns the first button of the category
	it moved to, nil when there is none other.
]]
--- @param view UmeGui_View
--- @return GuiObject?
function Module._cycleCategory(view, direction: number)
	--[[ Finding ]]

	local buttons = {} --- @type { GuiObject }

	for _index: number, button: Instance in ipairs(view.Root:GetDescendants()) do
		if button:IsA("GuiButton") and button:GetAttribute("BackpackPlus_FilterCategory") ~= nil then
			table.insert(buttons, button)
		end
	end

	table.sort(buttons, function(first: GuiObject, second: GuiObject)
		return first.AbsolutePosition.Y < second.AbsolutePosition.Y
	end)

	--[[ Collecting ]]

	local categories = {} --- @type { string }
	local categoryButtons = {} --- @type { [string]: GuiObject }

	for _index: number, button: GuiObject in ipairs(buttons) do
		local category: string = button:GetAttribute("BackpackPlus_FilterCategory")

		-- Skip a category an earlier button already has
		if not categoryButtons[category] then
			table.insert(categories, category)
			categoryButtons[category] = button
		end
	end

	--[[ Selecting ]]

	local state = states[view] --- @type { [string]: any }

	-- Skip when there is no other category to move to
	if #categories <= 1 then
		return nil
	end

	local index: number = table.find(categories, state.Category) or 1
	local nextCategory: string = categories[(index - 1 + direction) % #categories + 1]

	--[[ Returning ]]

	state.Category = nextCategory
	return categoryButtons[nextCategory]
end

--%%%%%%%%%%%%%%%%%%%% Play Press

--[[
	Plays a press on a button the gamepad acted on, its click look and sound, as ume's BackpackPlus does in game
	(`I.Utils.PlayPress`). A Gui tool too old to pass `PlayPress` skips it.
]]
--- @param state { [string]: any }
function Module._playPress(state, button: GuiObject)
	--[[ Checks ]]

	-- Skip with a Gui tool that doesn't pass PlayPress
	if not state.Preview.PlayPress then
		return
	end

	--[[ Pressing ]]

	state.Preview.PlayPress(button)
end

--%%%%%%%%%%%%%%%%%%%% Follow Toolbar

--[[
	Lays the view out from its toolbar's width and keeps it so as the preview resizes, as BackpackPlus does in game.
	Connects once per view.
]]
--- @param view UmeGui_View
function Module._followToolbar(view)
	--[[ Layout ]]

	local state = states[view] --- @type { [string]: any }
	Module._layout(view)

	--[[ Checks ]]

	-- Skip views that already follow their toolbar
	if state.Defaults.FollowsToolbar then
		return
	end

	--[[ Connections ]]

	state.Defaults.FollowsToolbar = true
	view:Get("U_Toolbar").Instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		Module._layout(view)
	end)
	view:Get("U_Backpack", "S_ItemsContainer").Instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		Module._layout(view)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Layout

--[[
	Sizes the view as BackpackPlus's display update does: square toolbar slots that share the toolbar's width, the
	backpack as wide as the toolbar and just above its slots, and grid cells as wide as a toolbar slot's share of
	the backpack.
]]
--- @param view UmeGui_View
function Module._layout(view)
	--[[ Local Variables ]]

	local slotCount: number = states[view].SlotCount
	local toolbar: Frame = view:Get("U_Toolbar").Instance
	local backpack: Frame = view:Get("U_Backpack").Instance
	local itemsContainer: Frame = view:Get("U_Backpack", "S_ItemsContainer").Instance
	local gridLayout: UIGridLayout = view:Get("U_Backpack", "S_ItemsContainerGridLayout").Instance
	local screen: GuiBase2d = backpack:FindFirstAncestorWhichIsA("GuiBase2d")
	local slotSize: number = toolbar.AbsoluteSize.X / slotCount
	local slotTop: number = toolbar.AbsolutePosition.Y - screen.AbsolutePosition.Y + toolbar.AbsoluteSize.Y - slotSize

	--[[ Toolbar ]]

	for _index: number, slot: Instance in ipairs(toolbar:GetChildren()) do
		if slot:IsA("Frame") then
			slot.Size = UDim2.fromOffset(slotSize, slotSize)
		end
	end

	--[[ Backpack ]]

	backpack.Size = UDim2.new(0, slotSize * slotCount, 1, 0)
	backpack.Position = UDim2.new(0.5, 0, 0, slotTop - slotSize / 10)

	--[[ Items ]]

	local cellWidth: number = itemsContainer.AbsoluteSize.X / slotCount
	gridLayout.CellSize = UDim2.fromOffset(cellWidth, cellWidth)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Item

--[[
	Returns the tool a slot on screen holds in the simulated backpack.
]]
--- @param state { [string]: any }
--- @param slot UmeGui_Subview
--- @return { [string]: any }?
function Module._getItem(state, slot)
	--[[ Returning ]]

	local place = state.Slots[slot] --- @type { [string]: any }?
	return if place then state[place.Area][place.Index] else nil
end

--%%%%%%%%%%%%%%%%%%%% Matches

--[[
	Returns whether a backpack tool matches the selected category ("" is every tool) and every word of the search.
]]
--- @param state { [string]: any }
--- @param item { [string]: any } | nil
--- @return boolean
function Module._matches(state, item)
	--[[ Checks ]]

	-- An empty slot never shows in the backpack
	if not item then
		return false
	end

	-- Skip tools of another category
	if state.Category ~= "" and item.Category ~= state.Category then
		return false
	end

	--[[ Search ]]

	for word: string in string.lower(state.Search):gmatch("%S+") do
		-- Skip tools whose name misses a word
		if not string.lower(item.Name):find(word, 1, true) then
			return false
		end
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Is Over

--[[
	Returns whether a point on screen is inside a gui object.
]]
--- @return boolean
function Module._isOver(object: GuiObject, point: Vector2)
	--[[ Returning ]]

	local offset: Vector2 = point - object.AbsolutePosition
	return offset.X >= 0 and offset.Y >= 0 and offset.X <= object.AbsoluteSize.X and offset.Y <= object.AbsoluteSize.Y
end

return Module
