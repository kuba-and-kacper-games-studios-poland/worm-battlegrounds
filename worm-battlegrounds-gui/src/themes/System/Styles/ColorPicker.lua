--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	Default = {
		Gap = "S",
		BarGap = "M",
		BarsPadding = "S",
		Font = "Body",
		TextSize = "Body",
		LetterFont = "Hint",
		LetterSize = "Caption",
		Label = "Text",
		Letter = "TextDim",
		LetterWidth = 16,
		ChipWidth = "Swatch",
		ChipHeight = 22,
		-- Hex / RGB fields (the Inputs param); the chip takes their height
		InputStyle = "Small",
		InputHeight = "ControlSmall",
		HexWidth = 80,
		RgbWidth = 104,
		ChipRadius = "Control",
		ChipStroke = "BorderStrong",
		ChipStrokeThickness = "Thick",
		BarHeight = "Bar",
		KnobSize = "Knob",
		KnobStrokeThickness = "Thick",
		Knob = "Knob",
		KnobStroke = "KnobStroke",
	},
}

return _styles
