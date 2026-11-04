--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- Rows game code clones in, one under another
	Default = {
		Grid = false,
		Flex = true,
		Gap = "S",
		Padding = "XS",
		CellWidth = "Item",
		CellHeight = "ItemTall",
		ScrollBar = "TextDim",
		ScrollBarThickness = 8,
	},

	--[[ Variants ]]

	-- Cards in a grid, each CellWidth × CellHeight
	Grid = { Grid = true },
	-- Square cards in a grid (loadout slots, picker)
	Squares = { Grid = true, CellHeight = "Item" },
	-- Big cards in a grid (skins, game passes)
	Tiles = { Grid = true, CellWidth = "Tile", CellHeight = "TileTall" },
	-- Keeps the size its node gives instead of filling its column (a row of a set height)
	Fixed = { Flex = false },
}

return _styles
