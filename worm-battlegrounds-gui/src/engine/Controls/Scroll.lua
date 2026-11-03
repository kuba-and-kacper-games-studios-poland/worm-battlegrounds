--[[
	Created By: 	Nari
]]

local _localName: string = "Scroll"

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

--- @class UmeGui_Controls_Scroll
local Module = {

	--[[ Schema ]]

	Children = true,
	Params = {},
}

--%%%%%%%%%%%%%%%%%%%% Build

--- @param _node UmeGui_Node
--- @param style UmeGui_Style
--- @param ctx UmeGui_Context
--- @return UmeGui_Handle
function Module.Build(_node, style, ctx)
	--[[ Building ]]

	local scroll: ScrollingFrame = ctx.Create("ScrollingFrame", {
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollBarImageTransparency = 0,
		ScrollBarThickness = ctx.Number("Size", style.ScrollBarThickness),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Size = UDim2.fromScale(1, 1),
		VerticalScrollBarInset = Enum.ScrollBarInset[style.ScrollBarInset],
	})
	ctx.Color(scroll, "ScrollBarImageColor3", style.ScrollBar)
	ctx.Padding(scroll, style.Padding, style.PaddingX)
	ctx.List(scroll, "Vertical", style.Gap)

	-- Take the height the parent column leaves free
	ctx.Create("UIFlexItem", {
		FlexMode = Enum.UIFlexMode.Fill,
		Parent = scroll,
	})

	--[[ Returning ]]

	return { Instance = scroll, Slot = scroll }
end

return Module
