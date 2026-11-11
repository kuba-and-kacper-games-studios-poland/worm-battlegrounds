--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- MatchHud opens it at the end of a match, as I.UserInterface.UI["Results"]
	Name = "Results",
	Theme = "WormBattlegroundsBrawl",
	Screen = { DisplayOrder = 1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	--[[
		The end of a match: placings, what the player earned, the match stats, Rematch or back to the lobby.
		No close button: it can't be closed (PreventClosing, set after export)
	]]
	Root = {
		Control = "Widget",
		Id = "U_Widget",
		Title = "Match over",
		Close = false,
		Style = "Large",
		Children = {
			{ Control = "Label", Id = "S_Result", Text = "You placed 2nd!", Align = "Center", Style = "Title" },
			-- Every player's place, in team colours, side by side (PREFAB | Placing)
			{ Control = "Cells", Id = "U_Placings", Style = "Players" },
			-- What the player earned, then their match stats
			{
				Control = "Box",
				Id = "U_Earned",
				Children = {
					{
						Control = "Stack",
						Direction = "Horizontal",
						Align = "Center",
						Style = "Loose",
						Children = {
							{ Control = "Label", Text = "You earned", Style = "Heading" },
							{ Control = "Label", Id = "S_Coins", Text = "+50 coins", Style = { "Heading", "Coin" } },
							{ Control = "Label", Id = "S_Xp", Text = "+120 XP", Style = "Heading" },
							{
								Control = "Label",
								Id = "S_LevelUp",
								Text = "Level up! Level 13",
								Visible = false,
								Style = { "Heading", "Success" },
							},
						},
					},
					{
						Control = "Stack",
						Direction = "Horizontal",
						Align = "Center",
						Style = "Loose",
						Children = {
							{ Control = "Label", Id = "S_Damage", Text = "Damage dealt: 340" },
							{ Control = "Label", Id = "S_Knockouts", Text = "Knockouts: 2" },
							{ Control = "Label", Id = "S_BestShot", Text = "Best shot: 95 with the Bazooka" },
						},
					},
				},
			},
			{
				Control = "Stack",
				Direction = "Horizontal",
				Fill = true,
				Style = "Buttons",
				Children = {
					-- Votes and the time left to vote are in its text
					{
						Control = "Button",
						Id = "S_Rematch",
						Text = "Rematch  2 / 4  0:15",
						Style = "Primary",
						Hint = "Confirm",
						Tags = { Utils_ButtonKey = { Utils_GamepadKey = "ButtonA" } },
					},
					{
						Control = "Button",
						Id = "S_Lobby",
						Text = "Back to lobby",
						Hint = "Back",
						Tags = { Utils_ButtonKey = { Utils_GamepadKey = "ButtonB" } },
					},
				},
			},
		},
	},

	--[[ Prefabs ]]

	Templates = {
		-- One player's card in the lineup: place, avatar, name in their team's colour, and the coins it paid
		["PREFAB | Placing"] = {
			Control = "Box",
			Parent = "U_Placings",
			-- A person, so a slate card (the kit keeps cards for people and places)
			Style = "Card",
			Children = {
				{
					Control = "Stack",
					Align = "Center",
					Style = "Tight",
					Children = {
						{ Control = "Label", Id = "S_Place", Text = "1st", Align = "Center", Style = "Heading" },
						{ Control = "Picture", Id = "S_Avatar", Style = "Avatar" },
						-- The name with the player's badges after it, as tall as a Strong label (36 px text, 45 px line)
						{
							Primitive = "Frame",
							Props = {
								Name = "NameRow",
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								Size = UDim2.new(1, 0, 0, 45),
							},
							Children = {
								{ Control = "Label", Id = "S_Name", Text = "PlayerName", Align = "Center", Style = "Strong" },
								-- PlayerBadges clones PREFAB | Badge per badge and lays them out
								{
									Primitive = "Frame",
									Id = "S_Badges",
									Props = {
										AnchorPoint = Vector2.new(0, 0.5),
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										Visible = false,
									},
									Children = {
										{
											Primitive = "ImageLabel",
											Props = {
												Name = "PREFAB | Badge",
												BackgroundTransparency = 1,
												BorderSizePixel = 0,
												Size = UDim2.fromScale(1, 1),
												Visible = false,
												ScaleType = Enum.ScaleType.Fit,
											},
											Children = {
												-- Roblox's own verified badge and Premium icon: glyphs in its text, as big as the pictures
												{
													Primitive = "TextLabel",
													Id = "S_Glyph",
													Props = {
														AnchorPoint = Vector2.new(0.5, 0.5),
														BackgroundTransparency = 1,
														BorderSizePixel = 0,
														Position = UDim2.fromScale(0.5, 0.5),
														Size = UDim2.fromScale(1.25, 1.25),
														Text = "",
														TextColor3 = Color3.fromRGB(255, 255, 255),
														TextSize = 20,
														FontFace = Font.new("rbxassetid://113086061264643", Enum.FontWeight.Heavy, Enum.FontStyle.Normal),
														RichText = true,
														TextScaled = true,
													},
													Children = {
														{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
														{
															Primitive = "UIStroke",
															Props = {
																ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
																Color = Color3.fromRGB(25, 25, 42),
																Thickness = 0.08,
																StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
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
						{ Control = "Label", Id = "S_Coins", Text = "+60 coins", Align = "Center", Style = "Coin" },
					},
				},
			},
		},
	},
}

return _gui
