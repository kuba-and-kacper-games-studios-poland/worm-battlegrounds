--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The Crates module turns it on, on the Lobby map, as I.UserInterface.UI["Crates"]
	Name = "Crates",
	Theme = "WormBattlegroundsBrawl",
	Screen = { DisplayOrder = 0, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- Right: the 4 crates (PREFAB | CrateCard), the tutorial crate, and the skins button
	Root = {
		Control = "Box",
		Id = "U_Crates",
		Title = "Crates",
		Screen = true,
		-- On phones and tablets: shorter, its list scrolling instead, and drawn at 0.9 so the buttons keep their room
		Style = { "Panel", "Fixed", PlatformScale = { Utils_MobileScale = 0.9 } },
		Tags = { Utils_PlatformSize = { Utils_MobileSize = UDim2.fromOffset(520, 820) } },
		Props = {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.fromScale(0.9875, 0.978),
			Size = UDim2.fromOffset(560, 900),
		},
		Children = {
			-- The new player's free crate (Grenade and Shotgun), shown once by Tutorial in place of the list
			{
				Control = "Box",
				Id = "U_TutorialCrate",
				Visible = false,
				Children = {
					{ Control = "Label", Text = "Your first crate is free!", Align = "Center", Style = "Heading" },
					{ Control = "Button", Id = "S_Open", Text = "Open", Style = "Primary" },
				},
			},
			{ Control = "Cells", Id = "U_CrateList" },
			-- Opens the Skins widget; shows the equipped skin
			{
				Control = "Item",
				Id = "U_Skins",
				Text = "Skins",
				Subtext = "Classic",
				Style = "Square",
				Tags = {
					Interact_Button = {
						Interact_ModuleName = "WidgetManager",
						Interact_Function = "Toggle",
						Interact_Arg1 = "Skins",
					},
				},
			},
		},
	},

	--[[ Prefabs ]]

	Templates = {
		--[[
			One crate on a slot: picture and name, then which currency pays (the selected tab), then Open, Open 10 and
			Details. Prices are green; the window's one yellow is the tutorial's free crate
		]]
		["PREFAB | CrateCard"] = {
			Control = "Box",
			Parent = "U_CrateList",
			Children = {
				{
					Control = "Stack",
					Direction = "Horizontal",
					Children = {
						{ Control = "Picture", Id = "S_Picture", Style = { "Icon", Width = 128, Height = 128 } },
						{
							Control = "Stack",
							Grow = 1,
							Style = "Snug",
							Children = {
								{ Control = "Label", Id = "S_Name", Text = "Weapon crate", Style = "Heading" },
								-- The skin crate's daily free crate, for VIPs
								{
									Control = "Label",
									Id = "S_Free",
									Text = "Free with VIP today!",
									Visible = false,
									Style = { "Small", "Success" },
								},
							},
						},
					},
				},
				-- The currency that pays: a tab each, the picked one blue
				{
					Control = "Stack",
					Direction = "Horizontal",
					Fill = true,
					Style = "Buttons",
					Children = {
						{ Control = "Button", Id = "S_PayCoins", Text = "100 coins", Selected = true, Style = { "Tab", "Small" } },
						{ Control = "Button", Id = "S_PayDiamonds", Text = "200 diamonds", Style = { "Tab", "Small" } },
					},
				},
				{
					Control = "Stack",
					Direction = "Horizontal",
					Fill = true,
					Style = "Buttons",
					Children = {
						{ Control = "Button", Id = "S_Open", Text = "Open", Style = { "Price", "Small" } },
						{ Control = "Button", Id = "S_Open10", Text = "Open 10", Style = { "Price", "Small" } },
						-- The odds, required before buying (opens CrateOdds)
						{ Control = "Button", Id = "S_Details", Text = "Details", Style = "Small" },
					},
				},
			},
		},
	},
}

return _gui
