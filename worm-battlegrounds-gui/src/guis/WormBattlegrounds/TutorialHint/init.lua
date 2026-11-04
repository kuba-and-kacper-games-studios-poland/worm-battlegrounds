--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The Tutorial module turns it on and places the bubble, as I.UserInterface.UI["TutorialHint"]
	Name = "TutorialHint",
	Theme = "WormBattlegrounds",
	Screen = { DisplayOrder = 10, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- A speech bubble beside the element or spot it points at; the arrow turns toward it
	Root = {
		Control = "Box",
		Id = "U_Hint",
		Screen = true,
		Style = "Panel",
		Props = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.35),
			Size = UDim2.fromOffset(440, 0),
		},
		Children = {
			{
				Control = "Label",
				Id = "S_Text",
				Text = "Drag to aim, let go to shoot!",
				Align = "Center",
				Style = "Heading",
			},
			{ Control = "Picture", Id = "S_Arrow", Image = "chevron-small-down", Style = "Glyph" },
		},
	},
}

return _gui
