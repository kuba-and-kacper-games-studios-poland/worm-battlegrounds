--[[
	Created By: 	Nari
]]

local _localName: string = "ColorPicker"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Hue bar colors, red around to red
local HUE_SEQUENCE: ColorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
	ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
	ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
	ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
	ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
	ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
	ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
})

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Parse Hex

--[[
	Returns the color of typed hex text (`#5b5b5b`, `5B5B5B` or `#555`), or nil when it is not one.
]]
--- @return Color3?
local function parseHex(text: string)
	--[[ Local Variables ]]

	local digits: string? = string.match(text, "^%s*#?(%x+)%s*$")

	--[[ Checks ]]

	-- Only 3 or 6 digits make a color
	if not digits or (#digits ~= 3 and #digits ~= 6) then
		return nil
	end

	--[[ Returning ]]

	-- Short form doubles every digit
	if #digits == 3 then
		digits = string.gsub(digits, "%x", "%0%0")
	end
	return Color3.fromHex(digits)
end

--%%%%%%%%%%%%%%%%%%%% Parse Rgb

--[[
	Returns the color of typed RGB text (three 0-255 numbers, any separators), or nil when it is not one.
]]
--- @return Color3?
local function parseRgb(text: string)
	--[[ Local Variables ]]

	local channels = {} --- @type { number }

	--[[ Collecting ]]

	for number: string in string.gmatch(text, "%d+%.?%d*") do
		table.insert(channels, math.clamp(tonumber(number) or 0, 0, 255))
	end

	--[[ Returning ]]

	return if #channels == 3 then Color3.fromRGB(channels[1], channels[2], channels[3]) else nil
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

--- @class UmeGui_Controls_ColorPicker
local Module = {

	--[[ Schema ]]

	Params = {
		Label = "string?",
		Value = "Color3?",
		Swatches = "string|table?",
		Inputs = "boolean?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local hue: number
	local saturation: number
	local brightness: number
	hue, saturation, brightness = (node.Value or Color3.new(1, 1, 1)):ToHSV()

	local knobSize: number = ctx.Number("Size", style.KnobSize)
	local barHeight: number = ctx.Number("Size", style.BarHeight)
	local letterWidth: number = ctx.Number("Size", style.LetterWidth)
	local bars = {} --- @type { [string]: { Bar: Frame, Knob: Frame, Gradient: UIGradient } }

	--[[ Building ]]

	local root: Frame = ctx.Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
	})
	ctx.List(root, "Vertical", style.Gap)

	-- Label above everything
	local title = ctx.FieldTitle(node.Label or "", style.Font, style.TextSize, style.Label) --- @type UmeGui_FieldTitle
	title.Row.LayoutOrder = -1
	title.Row.Visible = node.Label ~= nil
	title.Row.Parent = root

	-- Chip row: the preview chip, then the RGB / Hex fields sharing the rest of the width
	local header: Frame = ctx.Create("Frame", {
		Name = "Header",
		LayoutOrder = 0,
		Size = UDim2.new(1, 0, 0, ctx.Number("Size", if node.Inputs then style.InputHeight else style.ChipHeight)),
		Parent = root,
	})
	ctx.List(header, "Horizontal", style.Gap)

	local chip: Frame = ctx.Create("Frame", {
		Name = "Chip",
		BackgroundTransparency = 0,
		LayoutOrder = 0,
		Size = UDim2.new(0, ctx.Number("Size", style.ChipWidth), 1, 0),
		Parent = header,
	})

	-- Typed color fields
	local rgbInput = nil --- @type UmeGui_Handle?
	local hexInput = nil --- @type UmeGui_Handle?
	if node.Inputs then
		rgbInput = ctx.Build({ Control = "Input", Placeholder = "R, G, B", Style = style.InputStyle }, header)
		rgbInput.Instance.Name = "Rgb"
		rgbInput.Instance.LayoutOrder = 2
		rgbInput.Instance.Size = UDim2.fromOffset(ctx.Number("Size", style.RgbWidth), 0)
		ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Grow, Parent = rgbInput.Instance })

		hexInput = ctx.Build({ Control = "Input", Placeholder = "Hex", Style = style.InputStyle }, header)
		hexInput.Instance.Name = "Hex"
		hexInput.Instance.LayoutOrder = 3
		hexInput.Instance.Size = UDim2.fromOffset(ctx.Number("Size", style.HexWidth), 0)
		ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Grow, Parent = hexInput.Instance })
	end

	ctx.Corner(chip, style.ChipRadius)
	ctx.Stroke(chip, style.ChipStroke, style.ChipStrokeThickness)

	-- Swatches
	local swatches = nil --- @type UmeGui_Handle?
	if node.Swatches then
		swatches = ctx.Build({ Control = "Swatches", Colors = node.Swatches, Value = node.Value }, root)
		swatches.Instance.LayoutOrder = 1
	end

	--[[ Handle ]]

	local handle = { Instance = root, Changed = ctx.Signal.new(), Restore = title.Restore } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Set Modified

	--[[
		Marks the label as changed from its preset or default, with a restore button.
	]]
	function handle.SetModified(modified: boolean)
		title.SetModified(modified)
	end

	--%%%%%%%%%%%%%%%%%%%% Paint

	--[[
		Updates the chip, the bar gradients and the knob positions for the current color.
	]]
	local function paint()
		--[[ Chip ]]

		local color: Color3 = Color3.fromHSV(hue, saturation, brightness)
		chip.BackgroundColor3 = color

		--[[ Fields ]]

		if hexInput and rgbInput then
			hexInput.Set(`#{string.upper(color:ToHex())}`)
			rgbInput.Set(`{math.round(color.R * 255)}, {math.round(color.G * 255)}, {math.round(color.B * 255)}`)
		end

		--[[ Gradients ]]

		bars.H.Gradient.Color = HUE_SEQUENCE
		bars.S.Gradient.Color = ColorSequence.new(Color3.fromHSV(hue, 0, brightness), Color3.fromHSV(hue, 1, brightness))
		bars.B.Gradient.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(hue, saturation, 1))

		--[[ Knobs ]]

		-- Knobs stay inside the bar: centered half a knob in from each end
		bars.H.Knob.Position = UDim2.new(hue, (0.5 - hue) * knobSize, 0.5, 0)
		bars.S.Knob.Position = UDim2.new(saturation, (0.5 - saturation) * knobSize, 0.5, 0)
		bars.B.Knob.Position = UDim2.new(brightness, (0.5 - brightness) * knobSize, 0.5, 0)
	end

	--%%%%%%%%%%%%%%%%%%%% Set

	--[[
		Sets the color without firing Changed.
	]]
	function handle.Set(color: Color3)
		--[[ Applying ]]

		hue, saturation, brightness = color:ToHSV()
		if swatches then
			swatches.Set(color)
		end
		paint()
	end

	--%%%%%%%%%%%%%%%%%%%% Get

	--[[
		Returns the color.
	]]
	--- @return Color3
	function handle.Get()
		return Color3.fromHSV(hue, saturation, brightness)
	end

	--[[ Bars ]]

	local barsColumn: Frame = ctx.Create("Frame", {
		Name = "Bars",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Size = UDim2.fromScale(1, 0),
		Parent = root,
	})
	ctx.List(barsColumn, "Vertical", style.BarGap)

	-- Extra room between the swatches and the hue bar
	ctx.Create("UIPadding", {
		PaddingTop = UDim.new(0, ctx.Number("Spacing", style.BarsPadding)),
		Parent = barsColumn,
	})

	for index: number, channel: string in ipairs({ "H", "S", "B" }) do
		local row: Frame = ctx.Create("Frame", {
			Name = channel,
			LayoutOrder = index,
			Size = UDim2.new(1, 0, 0, knobSize),
			Parent = barsColumn,
		})

		local letter: TextLabel = ctx.Create("TextLabel", {
			Name = "Letter",
			Size = UDim2.new(0, letterWidth, 1, 0),
			Text = channel,
			Parent = row,
		})
		ctx.Text(letter, style.LetterFont, style.LetterSize, style.Letter)

		local area: ImageButton = ctx.Create("ImageButton", {
			Name = "Area",
			Position = UDim2.fromOffset(letterWidth, 0),
			Size = UDim2.new(1, -letterWidth, 1, 0),
			Parent = row,
		})

		local bar: Frame = ctx.Create("Frame", {
			Name = "Bar",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, 0, 0, barHeight),
			Parent = area,
		})
		ctx.Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = bar })
		local gradient: UIGradient = ctx.Create("UIGradient", { Parent = bar })

		local knob: Frame = ctx.Create("Frame", {
			Name = "Knob",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0,
			Size = UDim2.fromOffset(knobSize, knobSize),
			ZIndex = 2,
			Parent = area,
		})
		ctx.Color(knob, "BackgroundColor3", style.Knob)
		ctx.Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = knob })
		ctx.Stroke(knob, style.KnobStroke, style.KnobStrokeThickness)

		bars[channel] = { Bar = bar, Knob = knob, Gradient = gradient }

		--%%%%%%%%%%%%%%%%%%%% Drag To

		--[[
			Sets this channel from the pointer and fires Changed.
		]]
		local function dragTo(position: Vector2)
			--[[ Local Variables ]]

			local ratio: number = math.clamp((position.X - area.AbsolutePosition.X - knobSize / 2) / math.max(area.AbsoluteSize.X - knobSize, 1), 0, 1)

			--[[ Applying ]]

			if channel == "H" then
				hue = ratio
			elseif channel == "S" then
				saturation = ratio
			else
				brightness = ratio
			end
			if swatches then
				swatches.Set(handle.Get())
			end
			paint()
			handle.Changed:Fire(handle.Get())
		end

		-- Dragging
		if ctx.Interactive then
			ctx.Connect(area.InputBegan, function(input: InputObject)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					ctx.Capture(dragTo, nil, area)
				end
			end)
		end
	end

	--[[ Theme ]]

	paint()

	--[[ Connections ]]

	--%%%%%%%%%%%%%%%%%%%% Apply Typed

	--[[
		Sets the color typed into a field and fires Changed; text that is not a color puts the current one back.
	]]
	local function applyTyped(color: Color3?)
		--[[ Checks ]]

		-- Not a color: show the current one again
		if not color then
			paint()
			return
		end

		--[[ Applying ]]

		hue, saturation, brightness = color:ToHSV()
		if swatches then
			swatches.Set(color)
		end
		paint()
		handle.Changed:Fire(handle.Get())
	end

	if hexInput and rgbInput then
		ctx.Connect(hexInput.Changed, function(text: string)
			applyTyped(parseHex(text))
		end)
		ctx.Connect(rgbInput.Changed, function(text: string)
			applyTyped(parseRgb(text))
		end)
	end

	if swatches then
		ctx.Connect(swatches.Changed, function(color: Color3)
			hue, saturation, brightness = color:ToHSV()
			paint()
			handle.Changed:Fire(color)
		end)
	end

	--[[ Returning ]]

	return handle
end

return Module
