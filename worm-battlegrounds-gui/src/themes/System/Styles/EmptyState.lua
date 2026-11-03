--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	Default = {
		-- Large faded icon behind the message
		IconSize = 96,
		Icon = "TextDim",
		IconTransparency = 0.8,
		-- Message, as a share of the width
		TextStyle = { "Small", "Dim" },
		TextWidth = 0.8,
	},
}

return _styles
