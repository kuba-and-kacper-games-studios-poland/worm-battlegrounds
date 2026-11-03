--[[
	Created By: 	Nari
]]

local _localName: string = "ListBox"

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

--- @class UmeGui_Controls_ListBox
local Module = {

	--[[ Schema ]]

	Children = true,
	Params = {
		Rows = "number?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local rows: number = node.Rows or style.Rows
	local rowHeight: number = ctx.Number("Size", style.RowHeight)
	local gap: number = ctx.Number("Spacing", style.Gap)
	local padding: number = 2 * ctx.Number("Spacing", style.Padding)

	--[[ Building ]]

	local surface = ctx.Surface(UDim2.fromScale(1, 0), true) --- @type UmeGui_Surface
	ctx.Color(surface.Background, "BackgroundColor3", style.Fill)
	ctx.Corner(surface.Background, style.Radius)
	ctx.Stroke(surface.Background, style.Stroke, style.StrokeThickness)

	local scroll: ScrollingFrame = ctx.Create("ScrollingFrame", {
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollBarImageTransparency = 0,
		ScrollBarThickness = ctx.Number("Size", style.ScrollBarThickness),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Size = UDim2.fromScale(1, 0),
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		Parent = surface.Content,
	})
	ctx.Color(scroll, "ScrollBarImageColor3", style.ScrollBar)
	ctx.Padding(scroll, style.Padding)
	local list: UIListLayout = ctx.List(scroll, "Vertical", style.Gap)

	--%%%%%%%%%%%%%%%%%%%% Fit

	--[[
		Sizes the box to its visible rows, from one row up to `rows` of them; past that it scrolls. Counted from the rows,
		not measured, so it also fits unparented and in exports (AutomaticSize ignores a UISizeConstraint).
	]]
	local function fit()
		--[[ Local Variables ]]

		local count: number = 0

		--[[ Counting ]]

		for _index: number, child: Instance in ipairs(scroll:GetChildren()) do
			if child:IsA("GuiObject") and child.Visible then
				count += 1
			end
		end

		--[[ Applying ]]

		local shown: number = math.clamp(count, 1, rows)
		scroll.Size = UDim2.new(1, 0, 0, shown * rowHeight + (shown - 1) * gap + padding)
	end

	--[[ Applying ]]

	fit()

	--[[ Connections ]]

	-- Destroying a row, or hiding one (which changes the layout's content size), refits after the change
	ctx.Connect(scroll.ChildRemoved, fit)
	ctx.Connect(list:GetPropertyChangedSignal("AbsoluteContentSize"), fit)

	--[[ Handle ]]

	local handle = { Instance = surface.Root, Slot = scroll } --- @type UmeGui_Handle

	--%%%%%%%%%%%%%%%%%%%% Add Child

	--[[
		Places a row and refits at once, so a build that is exported straight away (deferred signals) has the right
		height.
	]]
	--- @param child UmeGui_Handle
	function handle.AddChild(child)
		--[[ Parenting ]]

		child.Instance.Parent = scroll
		fit()
	end

	--[[ Returning ]]

	return handle
end

return Module
