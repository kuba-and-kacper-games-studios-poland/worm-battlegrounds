--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- A template: Match clones it over each player's chosen landing spot in the drop phase
	Name = "DropMarker",
	Kind = "Billboard",
	Theme = "WormBattlegroundsBrawl",
	-- The billboard's size at design scale, scaled with the screen by code
	Preview = { Width = 240, Height = 100 },

	--[[ Tree ]]

	Root = {
		Primitive = "Frame",
		Id = "U_Marker",
		Props = { BackgroundTransparency = 1, Size = UDim2.fromOffset(240, 100) },
		Children = {
			-- Set with the billboard's size by ScreenScale
			{ Primitive = "UIScale", Id = "S_ScreenScale" },
			{
				Control = "Stack",
				Align = "Center",
				Style = "None",
				Children = {
					-- The player's name and pin, in their colour
					{ Control = "Label", Id = "S_Name", Text = "PlayerName", Align = "Center", Style = "Strong" },
					{ Control = "Picture", Id = "S_Pin", Image = "chevron-small-down", Style = "Glyph" },
				},
			},
		},
	},
}

return _gui
