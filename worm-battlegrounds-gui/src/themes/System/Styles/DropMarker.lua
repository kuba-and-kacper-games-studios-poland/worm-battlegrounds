--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	Default = {
		Fill = "Accent",
		-- Separates the bar from whatever it crosses
		Outline = "Background",
		OutlineThickness = "Thick",
		Thickness = 3,
		-- Share of the length at each end that fades out
		Fade = 0.3,
	},
}

return _styles
