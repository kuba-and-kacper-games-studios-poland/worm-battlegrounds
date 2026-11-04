--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- Cosmetics draws it on WidgetManager_Opened as I.UserInterface.UI["EmoteShop"]
	Name = "EmoteShop",
	Theme = "WormBattlegrounds",
	Screen = { DisplayOrder = 1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- Emotes bought with coins, from a level up
	Root = {
		Control = "Widget",
		Id = "U_Widget",
		Title = "Emotes",
		Children = {
			-- One row per emote (PREFAB | EmoteRow)
			{ Control = "Cells", Id = "U_Emotes" },
		},
	},

	--[[ Prefabs ]]

	Templates = {
		-- An emote: icon, name, the level it needs, its price, Buy (or Owned)
		["PREFAB | EmoteRow"] = {
			Control = "Box",
			Parent = "U_Emotes",
			Children = {
				{
					Control = "Stack",
					Direction = "Horizontal",
					Children = {
						{ Control = "Picture", Id = "S_Icon", Style = "Avatar" },
						{
							Control = "Stack",
							Grow = 1,
							Style = "None",
							Children = {
								{ Control = "Label", Id = "S_Name", Text = "Dance", Style = "Strong" },
								{ Control = "Label", Id = "S_Level", Text = "Level 10", Style = { "Small", "Dim" } },
							},
						},
						{ Control = "Label", Id = "S_Price", Text = "500 coins", Style = "Coin" },
						{ Control = "Button", Id = "S_Buy", Text = "Buy", AutoWidth = true, Style = "Primary" },
						{ Control = "Label", Id = "S_Owned", Text = "Owned", Visible = false, Style = "Success" },
					},
				},
			},
		},
	},
}

return _gui
