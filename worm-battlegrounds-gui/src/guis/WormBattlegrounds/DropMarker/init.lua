--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- A template: Match clones it over each player's chosen landing spot in the drop phase
	Name = "DropMarker",
	Kind = "Billboard",
	Theme = "WormBattlegrounds",
	Preview = { Width = 200, Height = 90 },

	--[[ Tree ]]

	Root = {
		Primitive = "Frame",
		Id = "U_Marker",
		Props = { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) },
		Children = {
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
