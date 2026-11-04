--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- Every text has the ink outline
	Default = { TextStroke = "Ink", TextStrokeThickness = "Text" },

	--[[ Roles ]]

	Heading = { TextStrokeThickness = "Text" },
	Title = { TextStrokeThickness = "Text" },
	-- The biggest title (a match's result): white capitals with a heavy outline
	Hero = { Font = "Title", TextSize = "Hero", Upper = true, TextStrokeThickness = "Heavy" },

	--[[ Tones ]]

	Accent = { Text = "Accent" },
	Map = { Text = "Map" },
	Cream = { Text = "Cream" },
	Gold = { Text = "Gold" },
	Price = { Text = "Price" },
}

return _styles
