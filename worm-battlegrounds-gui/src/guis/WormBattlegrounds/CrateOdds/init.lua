--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- Crates draws it on WidgetManager_Opened as I.UserInterface.UI["CrateOdds"]
	Name = "CrateOdds",
	Theme = "WormBattlegroundsBrawl",
	Screen = { DisplayOrder = 1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- What a crate can drop and the chance of each, adding up to 100%: Roblox requires it before a paid random item
	Root = {
		Control = "Widget",
		Id = "U_Widget",
		Title = "Details",
		Children = {
			{ Control = "Label", Id = "S_Crate", Text = "Weapon crate", Align = "Center", Style = "Heading" },
			{
				Control = "Label",
				Id = "S_Price",
				Text = "100 coins · 10 for 900 coins",
				Align = "Center",
				Style = "Coin",
			},
			{
				Control = "Stack",
				Direction = "Horizontal",
				Children = {
					{ Control = "Label", Text = "Item", Grow = 1, Style = "Caption" },
					-- Fixed columns, so the rows' texts line up under them whatever code writes
					{ Control = "Label", Text = "Rarity", Style = "Caption", Props = { Size = UDim2.fromOffset(200, 32) } },
					{ Control = "Label", Text = "Chance", Align = "Right", Style = "Caption", Props = { Size = UDim2.fromOffset(140, 32) } },
				},
			},
			-- One row per item (PREFAB | OddsRow)
			{ Control = "Cells", Id = "U_Odds" },
			{ Control = "Label", Id = "S_Total", Text = "Total: 100%", Align = "Right", Style = "Dim" },
		},
	},

	--[[ Prefabs ]]

	Templates = {
		["PREFAB | OddsRow"] = {
			Control = "Stack",
			Parent = "U_Odds",
			Direction = "Horizontal",
			Children = {
				{ Control = "Picture", Id = "S_Icon", Style = "Glyph" },
				{ Control = "Label", Id = "S_Name", Text = "Grenade", Grow = 1 },
				{ Control = "Label", Id = "S_Rarity", Text = "Rare", Style = "Dim", Props = { Size = UDim2.fromOffset(200, 36) } },
				{
					Control = "Label",
					Id = "S_Chance",
					Text = "12.5%",
					Align = "Right",
					Style = "Strong",
					Props = { Size = UDim2.fromOffset(140, 36) },
				},
			},
		},
	},
}

return _gui
