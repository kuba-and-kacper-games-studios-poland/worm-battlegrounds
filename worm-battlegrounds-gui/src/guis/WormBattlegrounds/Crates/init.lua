--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The Crates module turns it on, on the Lobby map, as I.UserInterface.UI["Crates"]
	Name = "Crates",
	Theme = "WormBattlegrounds",
	Screen = { DisplayOrder = 0, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- Right: the 4 crates (PREFAB | CrateCard), the tutorial crate, and the skins button
	Root = {
		Control = "Box",
		Id = "U_Crates",
		Title = "Crates",
		Screen = true,
		Style = { "Panel", "Fixed" },
		Props = {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -24, 0.55, 0),
			Size = UDim2.fromOffset(540, 880),
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
		-- One crate: picture, name, the price in each currency it takes (the selected one pays), Open, Open 10, Details
		["PREFAB | CrateCard"] = {
			Control = "Box",
			Parent = "U_CrateList",
			Children = {
				{
					Control = "Stack",
					Direction = "Horizontal",
					Children = {
						{ Control = "Picture", Id = "S_Picture" },
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
								{
									Control = "Stack",
									Direction = "Horizontal",
									Style = "Buttons",
									Children = {
										{
											Control = "Button",
											Id = "S_PayCoins",
											Text = "100 coins",
											AutoWidth = true,
											Selected = true,
											Style = "Small",
										},
										{
											Control = "Button",
											Id = "S_PayDiamonds",
											Text = "200 diamonds",
											AutoWidth = true,
											Style = "Small",
										},
									},
								},
								{
									Control = "Stack",
									Direction = "Horizontal",
									Style = "Buttons",
									Children = {
										{
											Control = "Button",
											Id = "S_Open",
											Text = "Open",
											AutoWidth = true,
											Style = { "Primary", "Small" },
										},
										{
											Control = "Button",
											Id = "S_Open10",
											Text = "Open 10",
											AutoWidth = true,
											Style = { "Primary", "Small" },
										},
										-- The odds, required before buying (opens CrateOdds)
										{
											Control = "Button",
											Id = "S_Details",
											Text = "Details",
											AutoWidth = true,
											Style = "Small",
										},
									},
								},
							},
						},
					},
				},
			},
		},
	},
}

return _gui
