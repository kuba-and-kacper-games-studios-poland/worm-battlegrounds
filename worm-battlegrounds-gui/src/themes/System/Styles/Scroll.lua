--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- PaddingX is the inset on the sides, Padding on top and bottom. ScrollBarInset "ScrollBar" narrows the content while
	-- the bar shows; "None" draws the bar over it
	Default = { Padding = "L", PaddingX = "L", Gap = "L", ScrollBar = "Border", ScrollBarThickness = 4, ScrollBarInset = "ScrollBar" },

	--[[ Variants ]]

	Tight = { Gap = "M" },
	Flush = { Padding = "None", PaddingX = "None", Gap = "None" },
	-- Rows of a list: a small inset, almost no gap
	List = { Padding = "S", PaddingX = "S", Gap = "XS" },
	-- Sides inset like a Bar stack, so rows line up with a card in a Bar above (list it after List)
	Inset = { PaddingX = "L" },
	-- The bar takes no space: the content keeps its width whether it scrolls or not (every plugin widget's page)
	Overlay = { ScrollBarInset = "None" },
}

return _styles
