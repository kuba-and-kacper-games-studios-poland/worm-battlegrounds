--[[
	Created By: 	Nari
]]

local _localName: string = "IconButton"

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

--- @class UmeGui_Controls_IconButton
local Module = {

	--[[ Schema ]]

	Params = {
		Icon = "string",
		Text = "string?",
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

	local size: number = ctx.Number("Size", style.Size)

	--[[ Building ]]

	-- An icon name is an image (the Builder variant); anything else is a text glyph
	local parts = ctx.Pressable(UDim2.fromOffset(size, size), if style.Image then nil else node.Icon) --- @type UmeGui_Pressable
	local button: ImageButton = parts.Button
	local image: ImageLabel? = nil
	local glyph: GuiObject
	if style.Image then
		image = ctx.Glyph(node.Icon, ctx.Number("TextSize", style.IconSize), nil)
		image.AnchorPoint = Vector2.new(0.5, 0.5)
		image.Position = UDim2.fromScale(0.5, 0.5)
		image.Parent = parts.Content
		glyph = image
	else
		glyph = parts.Text
	end
	ctx.Corner(parts.Background, style.Radius)
	ctx.Tag(button, style.Tags)

	local stroke: UIStroke = ctx.Stroke(parts.Background, style.Stroke, style.StrokeThickness)

	-- With a label the glyph keeps a square slot on the left, and the label sits after it. Inside a wide button the
	-- glyph starts centred and the pair is centred on hover
	local label: TextLabel? = nil
	local expandedWidth: number = size
	local labelWidth: number = 0
	local gap: number = ctx.Number("Spacing", style.LabelPadding)
	if node.Text then
		if not image then
			glyph.Size = UDim2.fromOffset(size, 0)
		end
		glyph.Position = if style.LabelInside then UDim2.fromScale(0.5, 0.5) else UDim2.new(0, size / 2, 0.5, 0)
		parts.Content.ClipsDescendants = true

		label = ctx.Create("TextLabel", {
			Name = "Label",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, size, 0.5, 0),
			Text = node.Text,
			Parent = parts.Content,
		})
		ctx.Typography(label, style.LabelFont, style.LabelSize, true)

		labelWidth = ctx.MeasureText(label)
		label.Size = UDim2.new(0, labelWidth, label.Size.Y.Scale, label.Size.Y.Offset)
		expandedWidth = size + labelWidth + gap
	end
	if not image then
		ctx.Typography(parts.Text, style.Font, style.TextSize, true)
	end

	--[[ States ]]

	local states = ctx.States({ --- @type UmeGui_States
		Fill = { Instance = parts.Background, Property = "BackgroundColor3" },
		Text = { Instance = glyph, Property = if image then "ImageColor3" else "TextColor3" },
		Stroke = { Instance = stroke, Property = "Color" },
	}, style)
	local labelStates = if label then ctx.States({ Text = { Instance = label, Property = "TextColor3" } }, style) else nil --- @type UmeGui_States?

	--%%%%%%%%%%%%%%%%%%%% Apply Expanded

	--[[
		Slides the label out while the button is hovered or selected, and back in otherwise. A wide button keeps its
		size and only shows the label while hovered: the glyph moves left and the label fades in after it.
	]]
	local function applyExpanded(instant: boolean?)
		--[[ Checks ]]

		-- Only buttons with a label expand
		if not label then
			return
		end

		--[[ Wide ]]

		if style.LabelInside then
			local shown: boolean = states.IsActive("Hover")
			local labelLeft: number = (size + gap - labelWidth) / 2
			ctx.Animate(glyph, { Position = UDim2.new(0.5, if shown then -(gap + labelWidth) / 2 else 0, 0.5, 0) }, instant)
			ctx.Animate(label, { Position = UDim2.new(0.5, if shown then labelLeft else labelLeft + gap, 0.5, 0), TextTransparency = if shown then 0 else 1 }, instant)
			return
		end

		--[[ Applying ]]

		local expanded: boolean = states.IsActive("Hover") or states.IsActive("Selected")
		ctx.Animate(parts.Container, { Size = UDim2.fromOffset(if expanded then expandedWidth else size, size) }, instant)
		ctx.Animate(label, { TextTransparency = if expanded then 0 else 1 }, instant)
	end

	-- Every state change reaches the label's color and the width too
	local driver = { --- @type UmeGui_States
		Set = function(stateName: string, isActive: boolean)
			states.Set(stateName, isActive)
			if labelStates then
				labelStates.Set(stateName, isActive)
			end
			applyExpanded()
		end,
		SetBase = states.SetBase,
		Refresh = states.Refresh,
		IsActive = states.IsActive,
	}

	driver.Set("Disabled", node.Disabled == true)
	driver.Set("Selected", node.Selected == true)
	states.Refresh(true)
	if labelStates then
		labelStates.Refresh(true)
	end
	applyExpanded(true)
	ctx.Hover(button, driver)

	--[[ Handle ]]

	local handle = { Instance = parts.Container, Button = button, Clicked = ctx.Signal.new() } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Set Icon

	--[[
		Replaces the glyph: an icon name for the Builder variant, a text glyph otherwise.
	]]
	function handle.SetIcon(icon: string)
		--[[ Applying ]]

		if image then
			image.Image = ctx.Icon(icon)
		else
			parts.Text.Text = icon
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Set Text

	--[[
		Replaces the label of a button built with `Text`.
	]]
	function handle.SetText(text: string)
		--[[ Checks ]]

		-- Only buttons built with a label have one
		if not label then
			return
		end

		--[[ Applying ]]

		label.Text = text
		labelWidth = ctx.MeasureText(label)
		label.Size = UDim2.new(0, labelWidth, label.Size.Y.Scale, label.Size.Y.Offset)
		expandedWidth = size + labelWidth + gap
		applyExpanded(true)
	end

	--%%%%%%%%%%%%%%%%%%%% Set Disabled

	--[[
		Greys the button out and stops it firing Clicked.
	]]
	function handle.SetDisabled(disabled: boolean)
		driver.Set("Disabled", disabled)
	end

	--%%%%%%%%%%%%%%%%%%%% Set Selected

	--[[
		Shows the button as toggled on; a button with a label stays expanded while selected.
	]]
	function handle.SetSelected(selected: boolean)
		driver.Set("Selected", selected)
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
