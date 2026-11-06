--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The Tutorial module turns it on and places the bubble, as I.UserInterface.UI["TutorialHint"]
	Name = "TutorialHint",
	Theme = "WormBattlegroundsBrawl",
	Screen = { DisplayOrder = 0, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	--[[
		A speech bubble at the top middle, under a match's turn panel and above the lobby's Play panel; the arrow
		turns toward what it points at
	]]
	Root = {
		Control = "Box",
		Id = "U_Hint",
		Screen = true,
		-- Smaller on phones and tablets, so it fits between the turn panel and the lobby's Play panel there too (16 px text on a phone)
		Style = { "Panel", PlatformScale = { Utils_MobileScale = 0.75 } },
		Props = {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.27),
			Size = UDim2.fromOffset(640, 0),
		},
		Children = {
			{
				Control = "Label",
				Id = "S_Text",
				Text = "Hold to charge, let go to shoot!",
				Align = "Center",
				Style = "Heading",
			},
			{ Control = "Picture", Id = "S_Arrow", Image = "chevron-small-down", Style = "Glyph" },
		},
	},
}

return _gui
