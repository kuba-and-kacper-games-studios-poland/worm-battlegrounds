--[[
	Created By: 	Nari
]]

local _localName: string = "Toggle"

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

--- @class UmeGui_Controls_Toggle
local Module = {

	--[[ Schema ]]

	Params = {
		Label = "string?",
		Value = "boolean?",
		OffText = "string?",
		OnText = "string?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local value: boolean = node.Value == true
	local height: number = ctx.Number("Size", style.Height)
	local trackWidth: number = ctx.Number("Size", style.TrackWidth)
	local trackHeight: number = ctx.Number("Size", style.TrackHeight)
	local inset: number = ctx.Number("Spacing", style.KnobInset)
	local knobSize: number = trackHeight - inset * 2

	--[[ Building ]]

	-- Only the pill is pressable; the label and Off/On words are plain text
	local row: Frame = ctx.Create("Frame", {
		AutomaticSize = if node.Label then Enum.AutomaticSize.None else Enum.AutomaticSize.X,
		Size = if node.Label then UDim2.new(1, 0, 0, height) else UDim2.fromOffset(0, height),
	})
	ctx.List(row, "Horizontal", style.Gap)

	-- Label, with the switch pushed to the right
	local title = ctx.FieldTitle(node.Label or "", style.Font, style.TextSize, style.Label) --- @type UmeGui_FieldTitle
	if node.Label then
		title.Row.LayoutOrder = -1
		title.Row.Parent = row

		local spacer: Frame = ctx.Create("Frame", {
			Name = "Spacer",
			LayoutOrder = 0,
			Size = UDim2.fromScale(0, 1),
			Parent = row,
		})
		ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Grow, Parent = spacer })
	end

	-- Off / On words around the pill
	local offText: TextLabel = ctx.Create("TextLabel", {
		Name = "Off",
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 1,
		Size = UDim2.fromScale(0, 1),
		Text = node.OffText or "Off",
		Visible = node.OffText ~= "",
		Parent = row,
	})
	ctx.Typography(offText, style.HintFont, style.HintSize)

	local pill = ctx.Pressable(UDim2.fromOffset(trackWidth, trackHeight)) --- @type UmeGui_Pressable
	pill.Container.Name = "Pill"
	pill.Container.LayoutOrder = 2
	pill.Container.Parent = row
	local track: Frame = pill.Background
	ctx.Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = track })

	local knob: Frame = ctx.Create("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 0,
		Size = UDim2.fromOffset(knobSize, knobSize),
		Parent = pill.Content,
	})
	ctx.Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = knob })

	local onText: TextLabel = ctx.Create("TextLabel", {
		Name = "On",
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 3,
		Size = UDim2.fromScale(0, 1),
		Text = node.OnText or "On",
		Visible = node.OnText ~= "",
		Parent = row,
	})
	ctx.Typography(onText, style.HintFont, style.HintSize)

	--%%%%%%%%%%%%%%%%%%%% Paint

	--[[
		Moves the knob and colors the pill and words for the current value.
	]]
	local function paint(instant: boolean)
		--[[ Local Variables ]]

		local knobPosition: UDim2 = UDim2.new(0, if value then trackWidth - inset - knobSize else inset, 0.5, 0)
		local trackColor: Color3 = ctx.ResolveColor(if value then style.TrackOn else style.TrackOff)
		local knobColor: Color3 = ctx.ResolveColor(if value then style.KnobOn else style.KnobOff)

		--[[ Applying ]]

		offText.TextColor3 = ctx.ResolveColor(if value then style.Hint else style.HintActive)
		onText.TextColor3 = ctx.ResolveColor(if value then style.HintActive else style.Hint)
		ctx.Animate(knob, { Position = knobPosition, BackgroundColor3 = knobColor }, instant)
		ctx.Animate(track, { BackgroundColor3 = trackColor }, instant)
	end

	--[[ Theme ]]

	paint(true)
	ctx.Refresh(function()
		paint(true)
	end)

	--[[ Handle ]]

	local handle = { Instance = row, Button = pill.Button, Changed = ctx.Signal.new(), Restore = title.Restore } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Set Modified

	--[[
		Marks the label as changed from its preset or default, with a restore button.
	]]
	function handle.SetModified(modified: boolean)
		title.SetModified(modified)
	end

	--%%%%%%%%%%%%%%%%%%%% Set Icon

	--[[
		Shows an image before the label (a sprite with `rectOffset` and `rectSize`), or hides it with nil.
	]]
	function handle.SetIcon(image: string?, rectOffset: Vector2?, rectSize: Vector2?)
		title.SetIcon(image, rectOffset, rectSize)
	end

	--%%%%%%%%%%%%%%%%%%%% Set

	--[[
		Sets the value without firing Changed.
	]]
	function handle.Set(newValue: boolean)
		--[[ Checks ]]

		-- Skip when nothing changes
		if value == newValue then
			return
		end

		--[[ Applying ]]

		value = newValue
		paint(false)
	end

	--%%%%%%%%%%%%%%%%%%%% Get

	--[[
		Returns the value.
	]]
	--- @return boolean
	function handle.Get()
		return value
	end

	--[[ Connections ]]

	ctx.Connect(pill.Button.Activated, function()
		handle.Set(not value)
		handle.Changed:Fire(value)
	end)

	--[[ Returning ]]

	return handle
end

return Module
