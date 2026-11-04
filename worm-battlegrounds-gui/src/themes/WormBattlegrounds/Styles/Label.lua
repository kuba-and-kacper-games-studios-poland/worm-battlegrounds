--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- How many lines tall the label is, and the outline around its text
	Default = { Lines = 1, TextStroke = "BorderStrong", TextStrokeThickness = "None" },

	--[[ Roles ]]

	-- Headings are upper-case and outlined, like the header bars
	Heading = { Upper = true, TextStrokeThickness = "Text" },
	Title = { Upper = true, TextStrokeThickness = "Text" },
	-- Big numbers: the turn timer, countdowns, damage pops
	Display = { Font = "Title", TextSize = "Display", TextStrokeThickness = "Text" },
	-- A few lines of text (a game pass's benefits)
	Paragraph = { Lines = 4 },
	-- An outline around the text, for badges over pictures (Shiny)
	Outlined = { TextStrokeThickness = "Text" },

	--[[ Tones ]]

	Coin = { Text = "Coin" },
	Diamond = { Text = "Diamond" },
}

return _styles
