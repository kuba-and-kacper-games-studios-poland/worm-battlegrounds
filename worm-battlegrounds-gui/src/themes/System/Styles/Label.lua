--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	Default = { Font = "Body", TextSize = "Body", Text = "Text", Upper = false, Fixed = false },

	--[[ Roles ]]

	-- Label above a field (Intensity, Aim, Light color)
	Field = { Font = "Body", TextSize = "Body" },
	-- Small upper-case caption (WHOLE PLACE, SCENE COST)
	Caption = { Font = "Hint", TextSize = "Caption", Text = "TextDim", Upper = true },
	Heading = { Font = "Title", TextSize = "Heading" },
	Title = { Font = "Title", TextSize = "Title" },
	Strong = { Font = "Title" },
	Small = { Font = "Hint", TextSize = "Small" },
	-- Never shrinks below its token size; the box grows with the text instead (long text in a Scroll)
	Fixed = { Fixed = true },

	--[[ Tones ]]

	Dim = { Text = "TextDim" },
	Muted = { Text = "TextMuted" },
	Success = { Text = "Success" },
	Danger = { Text = "Danger" },
	Warning = { Text = "Warning" },
}

return _styles
