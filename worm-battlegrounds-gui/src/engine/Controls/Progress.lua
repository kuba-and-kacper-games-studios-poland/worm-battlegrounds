--[[
	Created By: 	Nari
]]

local _localName: string = "Progress"

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

--- @class UmeGui_Controls_Progress
local Module = {

	--[[ Schema ]]

	Params = {
		Value = "number?",
		Text = "string?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local value: number = math.clamp(node.Value or 0, 0, 1)

	--[[ Building ]]

	local root: Frame = ctx.Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
	})
	ctx.List(root, "Vertical", style.Gap)

	local label: TextLabel = ctx.Create("TextLabel", {
		Name = "Status",
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 0,
		Size = UDim2.fromScale(1, 0),
		Text = node.Text or "",
		TextTruncate = Enum.TextTruncate.AtEnd,
		Visible = (node.Text or "") ~= "",
		Parent = root,
	})
	ctx.Text(label, style.Font, style.TextSize, style.Text)

	local track: Frame = ctx.Create("Frame", {
		Name = "Track",
		BackgroundTransparency = 0,
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, ctx.Number("Size", style.BarHeight)),
		Parent = root,
	})
	ctx.Color(track, "BackgroundColor3", style.Track)
	ctx.Corner(track, style.Radius)

	local fill: Frame = ctx.Create("Frame", {
		Name = "Fill",
		BackgroundTransparency = 0,
		Size = UDim2.fromScale(value, 1),
		Parent = track,
	})
	ctx.Color(fill, "BackgroundColor3", style.Fill)
	ctx.Corner(fill, style.Radius)

	--[[ Handle ]]

	local handle = { Instance = root } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Set

	--[[
		Moves the fill to a done fraction (clamped to 0..1).
	]]
	function handle.Set(newValue: number)
		--[[ Applying ]]

		value = math.clamp(newValue, 0, 1)
		ctx.Animate(fill, { Size = UDim2.fromScale(value, 1) })
	end

	--%%%%%%%%%%%%%%%%%%%% Get

	--[[
		Returns the done fraction.
	]]
	--- @return number
	function handle.Get()
		return value
	end

	--%%%%%%%%%%%%%%%%%%%% Set Text

	--[[
		Replaces the status line; empty hides it.
	]]
	function handle.SetText(text: string)
		label.Text = text
		label.Visible = text ~= ""
	end

	--[[ Returning ]]

	return handle
end

return Module
