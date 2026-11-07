--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- The status line over the bar, left-aligned, with the ink outline
	Default = { StatusAlign = "Left", TextStroke = "Ink", TextStrokeThickness = "Text" },

	--[[ Bars ]]

	-- A snail's health: the number big and centred over the bar
	Health = { StatusAlign = "Center", TextSize = "Heading" },
}

return _styles
