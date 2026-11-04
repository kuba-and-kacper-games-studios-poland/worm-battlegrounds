--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- A template: Worms clones it over every worm's head
	Name = "WormTag",
	Kind = "Billboard",
	Theme = "WormBattlegrounds",
	Preview = { Width = 220, Height = 170 },

	--[[ Tree ]]

	Root = {
		Primitive = "Frame",
		Id = "U_Tag",
		Props = { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) },
		Children = {
			{
				Control = "Stack",
				Align = "Center",
				Style = "None",
				Children = {
					-- Over the worm whose turn it is: a marker and the turn timer
					{
						Control = "Stack",
						Id = "S_Active",
						Direction = "Horizontal",
						Align = "Center",
						Style = "None",
						Children = {
							{ Control = "Label", Id = "S_Timer", Text = "15", Style = "Heading" },
							{ Control = "Picture", Image = "chevron-small-down", Style = "Glyph" },
						},
					},
					-- In the team's colour (gold for VIP)
					{ Control = "Label", Id = "S_Name", Text = "PlayerName", Align = "Center", Style = "Strong" },
					{
						Control = "Label",
						Id = "S_Level",
						Text = "Level 12",
						Align = "Center",
						Style = { "Small", "Dim" },
					},
					-- Health number and bar, in the team's colour; worms start at 200
					{ Control = "Progress", Id = "S_Health", Text = "200", Value = 1, Style = "Health" },
				},
			},
			-- The emote playing, over the tag
			{
				Control = "Picture",
				Id = "S_Emote",
				Visible = false,
				Style = "Avatar",
				Props = { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 0) },
			},
		},
	},
}

return _gui
