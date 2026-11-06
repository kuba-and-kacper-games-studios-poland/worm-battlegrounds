--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- A template: Worms clones it over every worm's head
	Name = "WormTag",
	Kind = "Billboard",
	Theme = "WormBattlegroundsBrawl",
	-- The billboard's size at design scale: the tag's own, which code scales with the screen
	Preview = { Width = 240, Height = 240 },

	--[[ Tree ]]

	Root = {
		Primitive = "Frame",
		Id = "U_Tag",
		Props = { BackgroundTransparency = 1, Size = UDim2.fromOffset(240, 240) },
		Children = {
			-- Set with the billboard's size by ScreenScale, so the tag is as big for the screen as the hud
			{ Primitive = "UIScale", Id = "S_ScreenScale" },
			-- Stacks up from the billboard's bottom edge, the health bar nearest the worm
			{
				Control = "Stack",
				Align = "Center",
				Style = "None",
				Props = { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1) },
				Children = {
					-- Over the worm whose turn it is: a marker (the turn's seconds are on the turn panel)
					{
						Control = "Stack",
						Id = "S_Active",
						Direction = "Horizontal",
						Align = "Center",
						Style = "None",
						Children = {
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
					-- Health number (big, centred) and bar, green to yellow to red with health; worms start at 200
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
