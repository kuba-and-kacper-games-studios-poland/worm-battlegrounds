--[[
	Created By: 	Nari
]]

local _localName: string = "GuiPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- Example guis by category, then by kind, as a game's UmeGui might hold them
--- @type { [string]: { [string]: { string } } }
local EXAMPLES = {
	Hud = {
		Default = { "Codes", "DailyRewards", "Inventory", "Quests", "Rebirth", "Settings", "Shop", "Trading" },
		Surface = { "Leaderboard", "ShopSign" },
		Billboard = { "HealthBar", "Nameplate" },
		Prompt = { "Chest", "Door" },
	},
	Plugin = {
		Default = { "Character", "ColorPalette", "Gui", "GuiResize", "LightingManager", "Photobooth", "Sync", "Ume" },
	},
	System = {
		Default = { "TopBar" },
		Prompt = { "Prompt" },
	},
}
local FIRST_CATEGORY: string = "Hud"
-- The Kind switch's order
--- @type { string }
local KINDS = { "Default", "Surface", "Billboard", "Prompt" }

--[[ State ]]

-- The view the widget's own controls were last wired on, and the gui picked in the list
local boundView --- @type UmeGui_View?
local selectedGui: string = "Inventory"

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

--- @class UmeGui_Guis_Plugin_Gui_Preview
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the widget with example guis and wires its Category, Kind and search to the list, so the preview behaves
	like the tool.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Checks ]]

	-- Wire each build once
	if preview.View == boundView then
		return
	end

	--[[ Data ]]

	local view = preview.View --- @type UmeGui_View
	local category = view:Get("U_Category") --- @type UmeGui_Handle
	local search = view:Get("U_Search") --- @type UmeGui_Handle

	--[[ Local Variables ]]

	local categories = {} --- @type { string }

	--[[ Categories ]]

	for categoryName: string in pairs(EXAMPLES) do
		table.insert(categories, categoryName)
	end
	table.sort(categories)

	--[[ Applying ]]

	boundView = view
	category.SetOptions(categories)
	category.Set(FIRST_CATEGORY)
	view:Get("U_PreviewSection").Instance.Visible = true
	Module._refresh(preview)

	--[[ Connections ]]

	category.Changed:Connect(function()
		Module._refresh(preview)
	end)
	view:Get("U_Kind").Changed:Connect(function()
		Module._refresh(preview)
	end)
	search.Field:GetPropertyChangedSignal("Text"):Connect(function()
		Module._refresh(preview)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Lists the picked category's guis of the picked kind that match the search, and shows what that kind adds: the
	part settings for Surface, and a prompt style export for Prompt. The Kind switch offers only the kinds the
	category has guis of, and shows only when there are two to pick from.
]]
--- @param preview UmeGui_Preview
function Module._refresh(preview)
	--[[ Data ]]

	local view = preview.View --- @type UmeGui_View
	local kindSwitch = view:Get("U_Kind") --- @type UmeGui_Handle
	local examples = EXAMPLES[view:Get("U_Category").Get()] or {} --- @type { [string]: { string } }

	--[[ Local Variables ]]

	local kind: string = kindSwitch.Get()
	local query: string = string.lower(view:Get("U_Search").Field.Text)
	local kinds = {} --- @type { string }
	local items = {} --- @type { { [string]: any } }
	local names = {} --- @type { string }

	--[[ Kinds ]]

	for _index: number, kindName: string in ipairs(KINDS) do
		if examples[kindName] then
			table.insert(kinds, kindName)
		end
	end

	-- Fall back to the category's first kind, Default when it has Default guis
	if not table.find(kinds, kind) and kinds[1] then
		kind = kinds[1]
	end

	--[[ Kind Switch ]]

	kindSwitch.SetOptions(kinds)
	kindSwitch.Set(kind)
	kindSwitch.Instance.Visible = #kinds > 1

	--[[ Filtering ]]

	for _index: number, guiName: string in ipairs(examples[kind] or {}) do
		-- Skip guis the search leaves out
		if query ~= "" and not string.find(string.lower(guiName), query, 1, true) then
			continue
		end

		table.insert(names, guiName)
		table.insert(items, { Text = guiName, Selected = guiName == selectedGui })
	end

	--[[ Rows ]]

	local rows = preview.Fill("PREFAB | GuiRow", items) --- @type { UmeGui_Subview }

	--- @param row UmeGui_Subview
	for index: number, row in ipairs(rows) do
		row.Root.Clicked:Connect(function()
			--[[ Selecting ]]

			selectedGui = names[index]

			--- @param other UmeGui_Subview
			for _otherIndex: number, other in ipairs(rows) do
				other.Root.SetSelected(other == row)
			end
		end)
	end

	--[[ Applying ]]

	view:Get("U_Guis").SetCount(#names)
	view:Get("U_List").Instance.Visible = #names > 0
	view:Get("U_Empty").Instance.Visible = #names == 0
	view:Get("U_Surface").Instance.Visible = kind == "Surface"
	view:Get("U_Export").SetText(if kind == "Prompt" then "Export prompt style" else "Export to StarterGui")
end

return Module
