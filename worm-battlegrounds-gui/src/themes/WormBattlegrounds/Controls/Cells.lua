--[[
	Created By: 	Nari
]]

local _localName: string = "Cells"

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

--- @class UmeGui_Themes_WormBattlegrounds_Controls_Cells
local Module = {

	--[[ Schema ]]

	Children = true,
	Params = {
		Direction = "string?",
		Scroll = "boolean?",
	},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(node, style, ctx)
	--[[ Local Variables ]]

	local horizontal: boolean = node.Direction == "Horizontal"
	local gap: number = ctx.Number("Spacing", style.Gap)
	local container: GuiObject

	--[[ Building ]]

	-- A list game code clones rows into: Roblox's own layout places them, so clones line up in game too
	if node.Scroll == false then
		container = ctx.Create("Frame", { Size = UDim2.fromScale(1, 1) })
	else
		container = ctx.Create("ScrollingFrame", {
			AutomaticCanvasSize = if horizontal then Enum.AutomaticSize.X else Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(),
			ScrollBarImageTransparency = 0,
			ScrollBarThickness = ctx.Number("Size", style.ScrollBarThickness),
			ScrollingDirection = if horizontal then Enum.ScrollingDirection.X else Enum.ScrollingDirection.Y,
			Size = UDim2.fromScale(1, 1),
		})
		ctx.Color(container, "ScrollBarImageColor3", style.ScrollBar)
	end
	ctx.Padding(container, style.Padding)

	-- Rows in a column (or a row), or cells in a grid
	if style.Grid then
		ctx.Create("UIGridLayout", {
			CellPadding = UDim2.fromOffset(gap, gap),
			CellSize = UDim2.fromOffset(ctx.Number("Size", style.CellWidth), ctx.Number("Size", style.CellHeight)),
			FillDirection = if horizontal then Enum.FillDirection.Vertical else Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = container,
		})
	else
		local list: UIListLayout = ctx.List(container, if horizontal then "Horizontal" else "Vertical", style.Gap)
		list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	end

	-- Take the height the parent column leaves free
	if style.Flex then
		ctx.Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill, Parent = container })
	end

	--[[ Returning ]]

	return { Instance = container, Slot = container }
end

return Module
