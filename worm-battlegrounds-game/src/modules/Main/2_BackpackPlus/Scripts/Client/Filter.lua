--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "BackpackPlus"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance | GuiObject }

--[[ Filter ]]

local filters = {} --- @type { [string]: string }
local filterAttributeNames = { --- @type { [string]: { string } }
	["Category"] = { "BackpackPlus_FilterCategory", "BackpackPlus_DisplayType" },
}

--[[ Shared ]]

--- @type BackpackPlus_ClientContext
local ctx

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Matches Filter

--[[
	Returns whether a Slot matches a named filter.
]]
--- @param slotData BackpackPlus_SlotData
--- @return boolean
local function matchesFilter(slotData, filterName: string, filterValue: string)
	--[[ Search Bar ]]

	if filterName == "SearchBar" then
		-- Creating filter text for item
		local filterText: string = string.lower(`{slotData.Tool.Name} {slotData.Tool:GetAttribute("BackpackPlus_FilterText") or ""}`)

		-- Checking search tags
		for searchTag: string in string.lower(filterValue):gmatch("%S+") do
			if not filterText:find(searchTag, 1, true) then
				return false
			end
		end

		-- All search tags matched
		return true
	end

	--[[ Attribute Filter ]]

	local attributeNames = filterAttributeNames[filterName] or { filterName } --- @type { string }
	local attributeValue: any = nil

	for _index: number, attributeName: string in ipairs(attributeNames) do
		attributeValue = slotData.Tool:GetAttribute(attributeName)

		-- Stopping at the first attribute the Tool has
		if attributeValue ~= nil then
			break
		end
	end

	--[[ Returning ]]

	return attributeValue ~= nil and string.lower(`{attributeValue}`) == string.lower(filterValue)
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

--- @class BackpackPlus_Client_Filter
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _ctx BackpackPlus_ClientContext
function Module.Init(_ctx)
	ctx = _ctx

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._getElements()

	ctx.UpdateSearchBar = Module._updateSearchBar
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing filter elements.
]]
function Module._getElements()
	local backpackGui: ScreenGui = I.UserInterface.UI["BackpackPlus"]
	local backpack: Frame = backpackGui:FindFirstChild("U_Backpack", true)

	--[[ General ]]

	elems["Backpack"] = backpack

	elems["SearchBarContainer"] = backpack:FindFirstChild("S_SearchBarContainer", true) --- @type Frame
	elems["SearchBar"] = backpack:FindFirstChild("S_SearchBar", true) --- @type TextBox
	elems["ItemsContainer"] = backpack:FindFirstChild("S_ItemsContainer", true) --- @type Frame
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Filters Control

--%%%%%%%%%%%%%%%%%%%% Set Filter

--[[
	**CLIENT** |
	Sets a named filter and updates visible backpack slots.
]]
function Module.SetFilter(filterName: string, filterValue: string)
	--[[ Setting ]]

	filters[filterName] = `{filterValue}`

	--[[ Updating Display ]]

	Module._updateSearchBar()
	I.Topic.Publish("BackpackPlus_FilterSet", filterName, filterValue)
end

--%%%%%%%%%%%%%%%%%%%% Clear Filter

--[[
	**CLIENT** |
	Removes a named filter and updates visible backpack slots.
]]
function Module.ClearFilter(filterName: string)
	--[[ Clearing ]]

	filters[filterName] = nil

	--[[ Updating Display ]]

	Module._updateSearchBar()
	I.Topic.Publish("BackpackPlus_FilterSet", filterName, nil)
end

--%%%%%%%%%%%%%%%%%%%% Cycle Category

--[[
	**CLIENT** |
	Selects the category above (`-1`) or below (`1`) the active one, in the order the category buttons stand on screen,
	wrapping from the last to the first and back. Returns whether the category changed.
]]
--- @return boolean
function Module.CycleCategory(direction: number)
	--[[ Local Variables ]]

	local categories --- @type { string }
	local categoryButtons --- @type { [string]: GuiObject }
	categories, categoryButtons = Module._getCategories()

	--[[ Checks ]]

	-- Skip when there is no other category to move to
	if #categories <= 1 then
		return false
	end

	--[[ Calculating ]]

	local index: number = table.find(categories, filters["Category"] or "") or 1
	local nextIndex: number = (index - 1 + direction) % #categories + 1

	--[[ Selecting ]]

	-- The empty category is every item: clearing the filter, as its button does
	if categories[nextIndex] == "" then
		Module.ClearFilter("Category")
	else
		Module.SetFilter("Category", categories[nextIndex])
	end

	--[[ Feedback ]]

	-- The gamepad has no button of its own here: play the category button's click look and sound
	I.Utils.PlayPress(categoryButtons[categories[nextIndex]])

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Update Search Bar

--[[
	Updates visibility of `Slots` inside of `ItemsContainer` to match active filters. Toolbar Slots are always shown.
]]
function Module._updateSearchBar()
	--[[ Updating Visibility ]]

	--- @param slotData BackpackPlus_SlotData
	for slotFrame: Frame, slotData in pairs(ctx.CreatedSlots.BySlot) do
		-- Showing Slots equipped at the Toolbar, as filters only apply to the backpack
		if slotFrame.Parent ~= elems["ItemsContainer"] then
			slotFrame.Visible = true
			continue
		end

		--[[ Checking Filters ]]

		local allFiltersMatching: boolean = true
		for filterName: string, filterValue: string in pairs(filters) do
			-- Hide if slot is not matching filter
			if not matchesFilter(slotData, filterName, filterValue) then
				allFiltersMatching = false
				break
			end
		end

		-- All filters passed -> showing
		slotFrame.Visible = allFiltersMatching
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Categories

--[[
	Returns the categories of the backpack's category buttons (BackpackPlus_FilterButton), top to bottom, each once,
	and the first button of each.
]]
--- @return { string }
--- @return { [string]: GuiObject }
function Module._getCategories()
	--[[ Finding ]]

	local buttons = {} --- @type { GuiObject }
	local buttonCategories = {} --- @type { [GuiObject]: string }

	--- @param component BackpackPlus_FilterButton
	for _index: number, component in ipairs(I.Component.GetAll("BackpackPlus_FilterButton")) do
		-- Skip buttons without a category, and ones outside the backpack view
		if component.FilterCategory == nil or not component.Instance:IsDescendantOf(elems["Backpack"]) then
			continue
		end

		table.insert(buttons, component.Instance)
		buttonCategories[component.Instance] = component.FilterCategory
	end

	--[[ Sorting ]]

	table.sort(buttons, function(first: GuiObject, second: GuiObject)
		return first.AbsolutePosition.Y < second.AbsolutePosition.Y
	end)

	--[[ Collecting ]]

	local categories = {} --- @type { string }
	local categoryButtons = {} --- @type { [string]: GuiObject }

	for _index: number, button: GuiObject in ipairs(buttons) do
		-- Skip a category an earlier button already has
		if categoryButtons[buttonCategories[button]] then
			continue
		end

		table.insert(categories, buttonCategories[button])
		categoryButtons[buttonCategories[button]] = button
	end

	--[[ Returning ]]

	return categories, categoryButtons
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
