--[[
	Created By: 	Nari
]]

local _localName: string = "ListItem"

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

--- @class UmeGui_Controls_ListItem
local Module = {

	--[[ Schema ]]

	Params = {
		Text = "string",
		Selected = "boolean?",
		Disabled = "boolean?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local height: number = ctx.Number("Size", style.Height)

	--[[ Building ]]

	local parts = ctx.Pressable(UDim2.new(1, 0, 0, height), node.Text) --- @type UmeGui_Pressable
	local button: ImageButton = parts.Button
	local itemText: TextLabel = parts.Text
	itemText.TextXAlignment = Enum.TextXAlignment.Left
	ctx.Typography(itemText, style.Font, style.TextSize, true)
	ctx.Padding(parts.Content, "None", style.PaddingX)
	ctx.Corner(parts.Background, style.Radius)

	--[[ States ]]

	local states = ctx.States({ --- @type UmeGui_States
		Fill = { Instance = parts.Background, Property = "BackgroundColor3" },
		Text = { Instance = itemText, Property = "TextColor3" },
	}, style)
	states.Set("Disabled", node.Disabled == true)
	states.Set("Selected", node.Selected == true)
	states.Refresh(true)
	ctx.Hover(button, states)

	--[[ Handle ]]

	local handle = { Instance = parts.Container, Button = button, Clicked = ctx.Signal.new() } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Set Text

	--[[
		Replaces the row's text.
	]]
	function handle.SetText(text: string)
		itemText.Text = text
	end

	--%%%%%%%%%%%%%%%%%%%% Set Selected

	--[[
		Shows the row as the picked one.
	]]
	function handle.SetSelected(selected: boolean)
		states.Set("Selected", selected)
	end

	--%%%%%%%%%%%%%%%%%%%% Set Disabled

	--[[
		Greys the row out and stops it firing Clicked.
	]]
	function handle.SetDisabled(disabled: boolean)
		states.Set("Disabled", disabled)
	end

	--[[ Connections ]]

	ctx.Connect(button.Activated, function()
		-- Ignore clicks while disabled
		if states.IsActive("Disabled") then
			return
		end

		handle.Clicked:Fire()
	end)

	--[[ Returning ]]

	return handle
end

return Module
