--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- White text with a dark outline reads on every panel
	Default = { TextStrokeThickness = "Text" },

	--[[ Tones ]]

	-- Quiet text is brown, with no outline
	Caption = { TextStrokeThickness = "None" },
	Dim = { TextStrokeThickness = "None" },
	Muted = { TextStrokeThickness = "None" },
}

return _styles
