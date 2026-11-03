--[[
	Created By: 	Nari
]]

local _localName: string = "RangeSlider"

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

--- @class UmeGui_Controls_RangeSlider
local Module = {

	--[[ Schema ]]

	Params = {
		Label = "string?",
		Value = "NumberRange",
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
	local low: number = math.clamp(node.Value.Min, minimum, maximum)
	local high: number = math.clamp(node.Value.Max, low, maximum)
	local knobSize: number = ctx.Number("Size", style.KnobSize)
	local decimals: number = if step then math.max(0, -math.floor(math.log10(step) + 1e-9)) else 0

	--[[ Building ]]

	local slider: Frame = ctx.Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
	})
	ctx.List(slider, "Vertical", style.Gap)

	-- Label row: the title, then the low and high fields on the right
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

	local fields = {} --- @type { TextBox }
	local strokes = {} --- @type { UIStroke }
	for order: number, fieldName: string in ipairs({ "Low", "High" }) do
		local box = ctx.Surface(UDim2.new(0, ctx.Number("Size", style.ValueWidth), 1, 0)) --- @type UmeGui_Surface
		box.Root.Name = `{fieldName}Box`
		box.Root.LayoutOrder = 1 + order
		box.Root.Parent = labelRow
		ctx.Color(box.Background, "BackgroundColor3", style.ValueFill)
		ctx.Corner(box.Background, style.ValueRadius)
		table.insert(strokes, ctx.Stroke(box.Background, style.ValueStroke, style.ValueStrokeThickness))
		ctx.Padding(box.Content, "None", style.ValuePadding)

		local field: TextBox = ctx.Create("TextBox", {
			Name = fieldName,
			AnchorPoint = Vector2.new(0.5, 0.5),
			ClearTextOnFocus = false,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			TextEditable = ctx.Interactive,
			Parent = box.Content,
		})
		ctx.Typography(field, style.ValueFont, style.ValueSize, true)
		ctx.Color(field, "TextColor3", style.Value)
		table.insert(fields, field)
	end

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

	local knobs = {} --- @type { Frame }
	for _index: number, knobName: string in ipairs({ "LowKnob", "HighKnob" }) do
		local knob: Frame = ctx.Create("Frame", {
			Name = knobName,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0,
			Size = UDim2.fromOffset(knobSize, knobSize),
			Parent = area,
		})
		ctx.Color(knob, "BackgroundColor3", style.Knob)
		ctx.Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = knob })
		ctx.Stroke(knob, style.KnobStroke, style.KnobStrokeThickness)
		table.insert(knobs, knob)
	end

	--%%%%%%%%%%%%%%%%%%%% Snap

	--[[
		Returns a value snapped to the step and clamped to the slider's range.
	]]
	--- @return number
	local function snap(rawValue: number)
		return math.clamp(if step then math.round(rawValue / step) * step else rawValue, minimum, maximum)
	end

	--%%%%%%%%%%%%%%%%%%%% Get Ratio

	--[[
		Returns where a value sits along the track, from 0 to 1.
	]]
	--- @return number
	local function getRatio(rawValue: number)
		return if maximum > minimum then (rawValue - minimum) / (maximum - minimum) else 0
	end

	--%%%%%%%%%%%%%%%%%%%% Get Number Text

	--[[
		Returns a value as plain number text, with the decimals the step allows (percents for "Percent").
	]]
	--- @return string
	local function getNumberText(rawValue: number)
		--[[ Checks ]]

		-- Percent fields show whole percents
		if node.Format == "Percent" then
			return tostring(math.round(rawValue * 100))
		end

		--[[ Returning ]]

		return if decimals > 0 then string.format(`%.{decimals}f`, rawValue) else tostring(math.round(rawValue))
	end

	--%%%%%%%%%%%%%%%%%%%% Paint

	--[[
		Places the fill and both knobs and writes the formatted ends.
	]]
	local function paint()
		--[[ Local Variables ]]

		local lowRatio: number = getRatio(low)
		local highRatio: number = getRatio(high)

		--[[ Track ]]

		-- Knobs stay inside the track: centered half a knob in from each end
		knobs[1].Position = UDim2.new(lowRatio, (0.5 - lowRatio) * knobSize, 0.5, 0)
		knobs[2].Position = UDim2.new(highRatio, (0.5 - highRatio) * knobSize, 0.5, 0)
		fill.Position = UDim2.new(lowRatio, (0.5 - lowRatio) * knobSize, 0, 0)
		fill.Size = UDim2.new(highRatio - lowRatio, (lowRatio - highRatio) * knobSize, 1, 0)

		--[[ Fields ]]

		for index: number, rawValue: number in ipairs({ low, high }) do
			-- While typing, a field keeps the user's text
			if fields[index]:IsFocused() then
				continue
			end

			fields[index].Text = if node.Format == "Percent" then `{getNumberText(rawValue)}%` else string.gsub(node.Format or "{}", "{}", getNumberText(rawValue))
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
		Sets the range (each end clamped and snapped) without firing Changed.
	]]
	function handle.Set(range: NumberRange)
		--[[ Applying ]]

		low = snap(range.Min)
		high = math.max(snap(range.Max), low)
		paint()
	end

	--%%%%%%%%%%%%%%%%%%%% Get

	--[[
		Returns the range.
	]]
	--- @return NumberRange
	function handle.Get()
		return NumberRange.new(low, high)
	end

	--%%%%%%%%%%%%%%%%%%%% Set End

	--[[
		Moves one end (1 low, 2 high), kept from passing the other, and fires Changed when the range moved.
	]]
	local function setEnd(index: number, rawValue: number)
		--[[ Local Variables ]]

		local previousLow: number = low
		local previousHigh: number = high

		--[[ Applying ]]

		if index == 1 then
			low = math.min(snap(rawValue), high)
		else
			high = math.max(snap(rawValue), low)
		end
		paint()

		--[[ Notifying ]]

		if low ~= previousLow or high ~= previousHigh then
			handle.Changed:Fire(NumberRange.new(low, high))
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Get Pointer Value

	--[[
		Returns the value under the pointer along the track.
	]]
	--- @return number
	local function getPointerValue(position: Vector2)
		--[[ Local Variables ]]

		local ratio: number = math.clamp((position.X - area.AbsolutePosition.X - knobSize / 2) / math.max(area.AbsoluteSize.X - knobSize, 1), 0, 1)

		--[[ Returning ]]

		return minimum + ratio * (maximum - minimum)
	end

	--[[ Theme ]]

	paint()

	--[[ Connections ]]

	if ctx.Interactive then
		-- A press drags the nearer knob; on top of each other, the side pressed decides
		ctx.Connect(area.InputBegan, function(input: InputObject)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			-- Picked on the first move, which Capture reports at once in its own pointer space
			local dragged: number? = nil
			ctx.Capture(function(position: Vector2)
				local pointed: number = getPointerValue(position)
				if not dragged then
					dragged = if math.abs(pointed - low) < math.abs(pointed - high) or (low == high and pointed < low) then 1 else 2
				end
				setEnd(dragged, pointed)
			end, nil, area)
		end)

		-- Typing: the plain number while focused, the first number typed when done
		for index: number, field: TextBox in ipairs(fields) do
			ctx.Connect(field.Focused, function()
				strokes[index].Color = ctx.ResolveColor(style.ValueStrokeFocused)
				field.Text = getNumberText(if index == 1 then low else high)
			end)
			ctx.Connect(field.FocusLost, function()
				strokes[index].Color = ctx.ResolveColor(style.ValueStroke)

				local typed: number? = tonumber(string.match(field.Text, "%-?%d*%.?%d+"))
				if typed then
					setEnd(index, if node.Format == "Percent" then typed / 100 else typed)
				end
				paint()
			end)
		end
	end

	--[[ Returning ]]

	return handle
end

return Module
