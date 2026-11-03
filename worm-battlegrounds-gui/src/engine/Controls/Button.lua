--[[
	Created By: 	Nari
]]

local _localName: string = "Button"

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

--- @class UmeGui_Controls_Button
local Module = {

	--[[ Schema ]]

	Params = {
		Text = "string",
		AutoWidth = "boolean?",
		Disabled = "boolean?",
		Selected = "boolean?",
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

	local parts = ctx.Pressable(UDim2.new(if node.AutoWidth then 0 else 1, 0, 0, height), node.Text) --- @type UmeGui_Pressable
	local button: ImageButton = parts.Button
	local buttonText: TextLabel = parts.Text
	ctx.Typography(buttonText, style.Font, style.TextSize, true)
	ctx.Padding(parts.Content, "None", style.PaddingX)
	ctx.Corner(parts.Background, style.Radius)
	ctx.Tag(button, style.Tags)

	-- An auto-width button fits its styled text
	if node.AutoWidth then
		ctx.FitWidth(parts)
	end

	local stroke: UIStroke = ctx.Stroke(parts.Background, style.Stroke, style.StrokeThickness)

	--[[ States ]]

	local states = ctx.States({ --- @type UmeGui_States
		Fill = { Instance = parts.Background, Property = "BackgroundColor3" },
		Text = { Instance = buttonText, Property = "TextColor3" },
		Stroke = { Instance = stroke, Property = "Color" },
	}, style)
	states.Set("Disabled", node.Disabled == true)
	states.Set("Selected", node.Selected == true)
	states.Refresh(true)
	ctx.Hover(button, states)

	--[[ Handle ]]

	local handle = { Instance = parts.Container, Button = button, Clicked = ctx.Signal.new() } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Set Text

	--[[
		Replaces the label.
	]]
	function handle.SetText(text: string)
		--[[ Applying ]]

		buttonText.Text = text
		if node.AutoWidth then
			ctx.FitWidth(parts)
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Set Disabled

	--[[
		Greys the button out and stops it firing Clicked.
	]]
	function handle.SetDisabled(disabled: boolean)
		states.Set("Disabled", disabled)
	end

	--%%%%%%%%%%%%%%%%%%%% Set Selected

	--[[
		Shows the button as the active choice.
	]]
	function handle.SetSelected(selected: boolean)
		states.Set("Selected", selected)
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
