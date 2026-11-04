--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The Loadout and Cosmetics modules turn it on, on the Lobby map, as I.UserInterface.UI["Loadout"]
	Name = "Loadout",
	Theme = "WormBattlegroundsBrawl",
	Screen = { DisplayOrder = 0, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- Bottom left: the emotes row, then the items the player takes into the next match
	Root = {
		Control = "Box",
		Id = "U_Loadout",
		Title = "Loadout",
		Screen = true,
		-- On phones and tablets: shorter, its slots scrolling instead, and drawn at 0.9 so a whole row of slots shows
		Style = { "Panel", "Fixed", PlatformScale = { Utils_MobileScale = 0.9 } },
		Tags = { Utils_PlatformSize = { Utils_MobileSize = UDim2.fromOffset(500, 420) } },
		Props = {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0.0125, 0.978),
			Size = UDim2.fromOffset(520, 580),
		},
		Children = {
			-- The smiley expands the row of owned emotes (PREFAB | Emote); + opens the emote shop
			{
				Control = "Cells",
				Id = "U_Emotes",
				Direction = "Horizontal",
				Style = "Fixed",
				Props = { Size = UDim2.new(1, 0, 0, 112) },
				Children = {
					{
						Control = "Item",
						Id = "S_Smiley",
						Image = "wb-smiley",
						Style = "Small",
						Props = { LayoutOrder = -1 },
					},
					{
						Control = "Item",
						Id = "S_Shop",
						Image = "plus-large",
						Style = "Small",
						Props = { LayoutOrder = 999 },
						Tags = {
							Interact_Button = {
								Interact_ModuleName = "WidgetManager",
								Interact_Function = "Toggle",
								Interact_Arg1 = "EmoteShop",
							},
						},
					},
				},
			},
			-- The Bazooka (always there, no slot), then one box per slot, 3 to 5 (PREFAB | Slot)
			{
				Control = "Cells",
				Id = "U_Slots",
				Style = { "Squares", CellWidth = 128, CellHeight = 128 },
				Children = {
					{
						Control = "Item",
						Id = "S_Bazooka",
						Text = "Bazooka",
						Image = "wb-bazooka",
						Style = { "Square", Padding = "XS" },
						Props = { LayoutOrder = -1 },
					},
				},
			},
		},
	},

	--[[ Prefabs ]]

	Templates = {
		-- An emote the player owns; a press plays it
		["PREFAB | Emote"] = { Control = "Item", Parent = "U_Emotes", Style = "Small" },
		-- A loadout slot: the item's icon and name, its outline in the item's rarity; a press opens LoadoutPicker
		["PREFAB | Slot"] = {
			Control = "Item",
			Parent = "U_Slots",
			Text = "Empty",
			Style = { "Square", Padding = "XS" },
			Children = {
				-- Shown on a shiny item (10 copies)
				{
					Control = "Label",
					Id = "S_Shiny",
					Text = "Shiny",
					Visible = false,
					Style = { "Small", "Strong", "Warning", "Outlined" },
					Props = { AnchorPoint = Vector2.new(0, 0), Position = UDim2.fromOffset(8, 4) },
				},
				-- Covers slots 4 and 5 until they're unlocked
				{
					Control = "Box",
					Id = "S_Lock",
					Visible = false,
					-- A darker slot over the item, so the lock reads on its own
					Style = { "Fixed", Slab = { FillTransparency = 0.2, Fade = 0 } },
					Props = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
					},
					Children = {
						{ Control = "Label", Text = "Locked", Align = "Center", Style = "Strong" },
						{
							Control = "Label",
							Id = "S_Price",
							Text = "2,500 coins or 149 R$",
							Align = "Center",
							Style = { "Small", "Coin" },
						},
					},
				},
			},
		},
	},
}

return _gui
