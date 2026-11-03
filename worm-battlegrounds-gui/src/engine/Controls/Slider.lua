--[[
	Created By: 	Nari
]]

local _localName: string = "Slider"

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

--- @class UmeGui_Controls_Slider
local Module = {

	--[[ Schema ]]

	Params = {
		Label = "string?",
		Value = "number",
		Min = "number?",
		Max = "number?",
		Step = "number?",
		Format = "string?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local minimum: number = node.Min or 0
	local maximum: number = node.Max or 1
	local step: number? = node.Step
	local value: number = math.clamp(node.Value, minimum, maximum)
	local knobSize: number = ctx.Number("Size", style.KnobSize)
	local decimals: number = if step then math.max(0, -math.floor(math.log10(step) + 1e-9)) else 0

	--[[ Building ]]

	local slider: Frame = ctx.Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
	})
	ctx.List(slider, "Vertical", style.Gap)

	-- Label row: the title, then the value field on the right
	local labelRow: Frame = ctx.Create("Frame", {
		Name = "LabelRow",
		LayoutOrder = 0,
		Size = UDim2.new(1, 0, 0, ctx.Number("Size", style.ValueHeight)),
		Parent = slider,
	})
	ctx.List(labelRow, "Horizontal", style.Gap)

	local title = ctx.FieldTitle(node.Label or "", style.Font, style.TextSize, style.Label) --- @type UmeGui_FieldTitle
	title.Row.LayoutOrder = 0
	title.Row.Visible = node.Label ~= nil
	title.Row.Parent = labelRow

	local spacer: Frame = ctx.Create("Frame", {
		Name = "Spacer",
		LayoutOrder = 1,
		Size = UDim2.fromScale(0, 1),
		Parent = labelRow,
	})
	ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Grow, Parent = spacer })

	local box = ctx.Surface(UDim2.new(0, ctx.Number("Size", style.ValueWidth), 1, 0)) --- @type UmeGui_Surface
	box.Root.Name = "ValueBox"
	box.Root.LayoutOrder = 2
	box.Root.Parent = labelRow
	ctx.Color(box.Background, "BackgroundColor3", style.ValueFill)
	ctx.Corner(box.Background, style.ValueRadius)
	local boxStroke: UIStroke = ctx.Stroke(box.Background, style.ValueStroke, style.ValueStrokeThickness)
	ctx.Padding(box.Content, "None", style.ValuePadding)

	local valueText: TextBox = ctx.Create("TextBox", {
		Name = "Value",
		AnchorPoint = Vector2.new(0.5, 0.5),
		ClearTextOnFocus = false,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		TextEditable = ctx.Interactive,
		Parent = box.Content,
	})
	ctx.Typography(valueText, style.ValueFont, style.ValueSize, true)
	ctx.Color(valueText, "TextColor3", style.Value)

	-- Hit area holding the track
	local area: ImageButton = ctx.Create("ImageButton", {
		Name = "Area",
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, knobSize),
		Parent = slider,
	})

	local bar: Frame = ctx.Create("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, 0, 0, ctx.Number("Size", style.TrackHeight)),
		Parent = area,
	})
	ctx.Color(bar, "BackgroundColor3", style.Track)
	ctx.Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = bar })

	local fill: Frame = ctx.Create("Frame", {
		Name = "Fill",
		BackgroundTransparency = 0,
		Parent = bar,
	})
	ctx.Color(fill, "BackgroundColor3", style.Fill)
	ctx.Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = fill })

	local knob: Frame = ctx.Create("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 0,
		Size = UDim2.fromOffset(knobSize, knobSize),
		Parent = area,
	})
	ctx.Color(knob, "BackgroundColor3", style.Knob)
	ctx.Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = knob })
	ctx.Stroke(knob, style.KnobStroke, style.KnobStrokeThickness)

	--%%%%%%%%%%%%%%%%%%%% Get Number Text

	--[[
		Returns the value as plain number text, with the decimals the step allows.
	]]
	--- @return string
	local function getNumberText()
		return if decimals > 0 then string.format(`%.{decimals}f`, value) else tostring(math.round(value))
	end

	--%%%%%%%%%%%%%%%%%%%% Paint

	--[[
		Places the fill and knob and writes the formatted value.
	]]
	local function paint()
		--[[ Local Variables ]]

		local ratio: number = if maximum > minimum then (value - minimum) / (maximum - minimum) else 0
		local shown: string = getNumberText()

		--[[ Applying ]]

		-- The knob stays inside the track: centered half a knob in from each end
		fill.Size = UDim2.new(ratio, (0.5 - ratio) * knobSize, 1, 0)
		knob.Position = UDim2.new(ratio, (0.5 - ratio) * knobSize, 0.5, 0)
		-- While typing, the field keeps the user's text
		if valueText:IsFocused() then
			return
		end

		if node.Format == "Percent" then
			valueText.Text = `{math.round(value * 100)}%`
		else
			valueText.Text = string.gsub(node.Format or "{}", "{}", shown)
		end
	end

	--[[ Handle ]]

	local handle = { Instance = slider, Changed = ctx.Signal.new(), Restore = title.Restore } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Set Modified

	--[[
		Marks the label as changed from its preset or default, with a restore button.
	]]
	function handle.SetModified(modified: boolean)
		title.SetModified(modified)
	end

	--%%%%%%%%%%%%%%%%%%%% Set

	--[[
		Sets the value (clamped and snapped) without firing Changed.
	]]
	function handle.Set(newValue: number)
		--[[ Applying ]]

		value = math.clamp(if step then math.round(newValue / step) * step else newValue, minimum, maximum)
		paint()
	end

	--%%%%%%%%%%%%%%%%%%%% Get

	--[[
		Returns the value.
	]]
	--- @return number
	function handle.Get()
		return value
	end

	--%%%%%%%%%%%%%%%%%%%% Drag To

	--[[
		Moves the value under the pointer and fires Changed when it moved.
	]]
	local function dragTo(position: Vector2)
		--[[ Local Variables ]]

		local previous: number = value
		local ratio: number = math.clamp((position.X - area.AbsolutePosition.X - knobSize / 2) / math.max(area.AbsoluteSize.X - knobSize, 1), 0, 1)

		--[[ Applying ]]

		handle.Set(minimum + ratio * (maximum - minimum))
		if value ~= previous then
			handle.Changed:Fire(value)
		end
	end

	--[[ Theme ]]

	paint()

	--[[ Connections ]]

	if ctx.Interactive then
		ctx.Connect(area.InputBegan, function(input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				ctx.Capture(dragTo, nil, area)
			end
		end)

		-- Typing: the plain number while focused, the first number typed when done
		ctx.Connect(valueText.Focused, function()
			boxStroke.Color = ctx.ResolveColor(style.ValueStrokeFocused)
			valueText.Text = if node.Format == "Percent" then tostring(math.round(value * 100)) else getNumberText()
		end)
		ctx.Connect(valueText.FocusLost, function()
			boxStroke.Color = ctx.ResolveColor(style.ValueStroke)

			local typed: number? = tonumber(string.match(valueText.Text, "%-?%d*%.?%d+"))
			local previous: number = value
			if typed then
				handle.Set(if node.Format == "Percent" then typed / 100 else typed)
			end
			paint()
			if value ~= previous then
				handle.Changed:Fire(value)
			end
		end)
	end

	--[[ Returning ]]

	return handle
end

return Module
