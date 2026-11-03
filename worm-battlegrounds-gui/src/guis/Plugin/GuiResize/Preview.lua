--[[
	Created By: 	Nari
]]

local _localName: string = "GuiResizePreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Example rows, as the GuiResize tool lists them
local CLASS_NAMES = { "Frame", "TextLabel", "TextButton", "ImageLabel", "ImageButton", "ScrollingFrame", "TextBox", "ViewportFrame" } --- @type { string }
local PROPERTY_NAMES = { "Size", "Position" } --- @type { string }

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

--- @class UmeGui_Guis_Plugin_GuiResize_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Classes", Label = "Classes", Value = 4, Min = 0, Max = #CLASS_NAMES, Step = 1 },
		{ Control = "Toggle", Id = "S_Expanded", Label = "Open first class", Value = true },
		{ Control = "Button", Id = "S_Status", Text = "Show status" },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Builds the example class rows, opening the first one with its properties.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local count: number = preview.Values.S_Classes
	local items = {} --- @type { { [string]: any } }
	for index: number = 1, count do
		table.insert(items, { Text = CLASS_NAMES[index] })
	end

	--[[ Rows ]]

	local rows = preview.Fill("PREFAB | Class", items) --- @type { UmeGui_Subview }
	local first = rows[1] --- @type UmeGui_Subview?

	--[[ Properties ]]

	local properties = {} --- @type { { [string]: any } }
	if first and preview.Values.S_Expanded then
		for _index: number, propertyName: string in ipairs(PROPERTY_NAMES) do
			table.insert(properties, { Text = propertyName, Value = "Checked" })
		end
		first.Root.Set("Checked")
		first.Root.SetExpanded(true)
	end
	preview.Fill("PREFAB | Property", properties, if first then first.Root else nil)

	--[[ Applying ]]

	-- The message takes the list's place without rows
	preview.View:Get("U_Count").SetText(`{count} classes`)
	preview.View:Get("U_Empty").Instance.Visible = count == 0
	preview.View:Get("U_List").Instance.Visible = count > 0
end

--%%%%%%%%%%%%%%%%%%%% Action

--[[
	Runs a button setting.
]]
--- @param preview UmeGui_Preview
function Module.Action(preview, id: string)
	--[[ Checks ]]

	-- Only the status button acts
	if id ~= "S_Status" then
		return
	end

	--[[ Applying ]]

	local status = preview.View:Get("U_Status") --- @type UmeGui_Handle
	status.SetText("Resized 12 objects")
	status.Instance.Visible = true
end

return Module
