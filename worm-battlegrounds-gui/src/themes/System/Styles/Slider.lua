--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	Default = {
		Gap = "XS",
		Font = "Body",
		TextSize = "Body",
		Label = "Text",

		-- Value field on the right of the label row
		ValueFont = "Body",
		ValueSize = "Small",
		Value = "Text",
		ValueWidth = 64,
		ValueHeight = "IconButton",
		ValuePadding = "XS",
		ValueFill = "Background",
		ValueRadius = "Control",
		ValueStroke = "Border",
		ValueStrokeFocused = "BorderStrong",
		ValueStrokeThickness = "Thick",
		TrackHeight = "Track",
		KnobSize = "Knob",
		KnobStrokeThickness = "Thick",
		Track = "Track",
		Fill = "Inverse",
		Knob = "Knob",
		KnobStroke = "KnobStroke",
	},
}

return _styles
