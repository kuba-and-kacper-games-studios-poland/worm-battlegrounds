--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	Default = {
		-- Row
		Radius = "Control",
		Padding = "S",
		Gap = "S",
		Fill = "Surface",
		IconSize = "Symbol",

		-- Name over its path
		Font = "Body",
		TextSize = "Small",
		Text = "Text",
		SubFont = "Hint",
		SubSize = "Caption",
		Subtext = "TextDim",

		-- Lines added and removed
		CountFont = "Body",
		CountSize = "Small",
		Added = "Success",
		Removed = "Danger",

		-- Status badge, tinted with its tone
		StatusFont = "Body",
		StatusSize = "Caption",
		Status = "TextDim",
		BadgeTransparency = 0.84,
		BadgeRadius = "Control",
		BadgePaddingY = 2,
		BadgePaddingX = "XS",
	},
}

return _styles
