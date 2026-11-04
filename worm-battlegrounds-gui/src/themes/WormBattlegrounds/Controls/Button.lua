--[[
	Created By: 	Nari
]]

local _localName: string = "Button"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Rich-text escapes, put back after upper-casing a text ("&LT;" doesn't draw a "<")
--- @type { [string]: string }
local ENTITIES = { LT = "&lt;", GT = "&gt;", AMP = "&amp;", QUOT = "&quot;", APOS = "&apos;" }

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

--- @class UmeGui_Themes_WormBattlegrounds_Controls_Button
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

	-- The shared Button's structure, its look a flat framed slab behind the text
	local parts = ctx.Pressable(UDim2.new(if node.AutoWidth then 0 else 1, 0, 0, height), Module._getText(node.Text, style)) --- @type UmeGui_Pressable
	local button: ImageButton = parts.Button
	local buttonText: TextLabel = parts.Text
	parts.Background.BackgroundTransparency = 1
	ctx.Typography(buttonText, style.Font, style.TextSize, true)
	ctx.Padding(parts.Content, "None", style.PaddingX)
	ctx.Tag(button, style.Tags)

	local slab = ctx.Build({ Control = "Slab", Style = style.Slab }, parts.Background) --- @type UmeGui_Handle
	local textStroke: UIStroke = ctx.Stroke(buttonText, style.TextStroke, style.TextStrokeThickness)
	textStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	textStroke.Enabled = ctx.Number("Stroke", style.TextStrokeThickness) > 0

	-- An auto-width button fits its styled text
	if node.AutoWidth then
		ctx.FitWidth(parts)
	end

	--[[ States ]]

	local states = ctx.States({ --- @type UmeGui_States
		Fill = { Instance = slab.Face, Property = "BackgroundColor3" },
		Stroke = { Instance = slab.Stroke, Property = "Color" },
		BevelColor = { Instance = slab.Bevel, Property = "Color" },
		Text = { Instance = buttonText, Property = "TextColor3" },
		TextStroke = { Instance = textStroke, Property = "Color" },
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

		buttonText.Text = Module._getText(text, style)
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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Text

--[[
	Returns the text as the style shows it: upper-case when its Upper key is on, its rich-text escapes kept.
]]
--- @param style UmeGui_Style
--- @return string
function Module._getText(text: string, style)
	return if style.Upper then (string.gsub(string.upper(text), "&(%u+);", ENTITIES)) else text
end

return Module
