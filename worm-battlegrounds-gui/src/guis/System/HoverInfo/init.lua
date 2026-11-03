--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The exported ScreenGui's name: ume's HoverInfo module finds it as I.UserInterface.UI["HoverInfo"]
	Name = "HoverInfo",
	-- Over every window, so a hovered slot's info shows above the backpack and the shops
	Screen = { DisplayOrder = 50, Enabled = true, IgnoreGuiInset = true },
	-- Always on: the UserInterface server turns off every other ScreenGui at start
	ScreenTags = { UserInterface_PreventHiding = {} },
	Devices = { "Desktop", "Mobile" },

	--[[ Tree ]]

	-- WidgetManager_Message's dark panel with a line in the item's rarity colour along its top, the rarity and tier over
	-- the name, stats as label and value rows, the level with its XP bar, and the enchantments. Sized for a 1080 px tall
	-- screen; the driver sets S_ScreenScale to the screen's height / 1080, places U_HoverInfo by the pointer and sets
	-- its height to S_Content's (an AutomaticSize box would never shrink: the panel is sized by it)
	Root = {
		Primitive = "Folder",
		Children = {
			{
				Primitive = "Frame",
				Id = "U_HoverInfo",
				-- Hidden until something is hovered
				Visible = false,
				Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(340, 324) },
				Children = {
					{ Primitive = "UIScale", Id = "S_ScreenScale" },
					-- The panel: dark gradient, black outline and a white highlight along its top edge
					{
						Primitive = "Frame",
						Props = {
							Name = "Background",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1, 1),
						},
						Children = {
							{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 8) } },
							{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)), Rotation = -90, Transparency = NumberSequence.new(0.35, 0.65) } },
							{ Primitive = "UIStroke", Props = { Thickness = 3 } },
							{
								Primitive = "UIStroke",
								Props = {
									Name = "UIStroke_Highlight",
									BorderStrokePosition = Enum.BorderStrokePosition.Inner,
									Color = Color3.fromRGB(255, 255, 255),
									Thickness = 3,
									Transparency = 0.5,
								},
								Children = {
									{
										Primitive = "UIGradient",
										Props = { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.9003, 1), NumberSequenceKeypoint.new(1, 1) }) },
									},
								},
							},
						},
					},
					-- A line in the item's rarity colour just inside the panel's top edge (a driver tints it)
					{
						Primitive = "Frame",
						Id = "S_Accent",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0),
							BackgroundColor3 = Color3.fromRGB(0, 195, 255),
							BorderSizePixel = 0,
							Position = UDim2.new(0.5, 0, 0, 6),
							Size = UDim2.new(1, -24, 0, 4),
							ZIndex = 2,
						},
						Children = {
							{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 2) } },
						},
					},
					-- What the info shows, top to bottom; a driver hides the parts an item doesn't have
					{
						Primitive = "Frame",
						Id = "S_Content",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0),
							AutomaticSize = Enum.AutomaticSize.Y,
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(0.5, 0),
							Size = UDim2.fromScale(1, 0),
							ZIndex = 3,
						},
						Children = {
							{
								Primitive = "UIListLayout",
								Props = { HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder },
							},
							{
								Primitive = "UIPadding",
								Props = { PaddingBottom = UDim.new(0, 16), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), PaddingTop = UDim.new(0, 18) },
							},
							-- The rarity in its look with the tier beside it, the name under them; the top line hides when the item has
							-- neither, and a driver sets the name's height for the lines it wraps to
							{
								Primitive = "Frame",
								Id = "U_Header",
								Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.fromScale(1, 0) },
								Children = {
									{ Primitive = "UIListLayout", Props = { HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder } },
									{
										Primitive = "Frame",
										Id = "S_Top",
										Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 28) },
										Children = {
											-- The rarity's glow, behind it: ume's Rarity module shows it for the rarities that have one
											{
												Primitive = "TextLabel",
												Id = "S_RarityGlow",
												Visible = false,
												Props = {
													AnchorPoint = Vector2.new(0, 0.5),
													BackgroundTransparency = 1,
													FontFace = Font.new("rbxassetid://12187373327", Enum.FontWeight.ExtraBold),
													Position = UDim2.fromScale(0, 0.5),
													RichText = true,
													Size = UDim2.new(1, -100, 0, 28),
													Text = "Rare",
													TextColor3 = Color3.fromRGB(0, 195, 255),
													TextScaled = true,
													TextSize = 22,
													TextTransparency = 0.5,
													TextXAlignment = Enum.TextXAlignment.Left,
												},
												Children = {
													{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 22 } },
													{ Primitive = "UIStroke", Props = { Color = Color3.fromRGB(0, 195, 255), Thickness = 5, Transparency = 0.78 } },
												},
											},
											-- The rarity in its own look: ume's Rarity module writes its font, gradient and outline
											{
												Primitive = "TextLabel",
												Id = "S_Rarity",
												Props = {
													AnchorPoint = Vector2.new(0, 0.5),
													BackgroundTransparency = 1,
													FontFace = Font.new("rbxassetid://12187373327", Enum.FontWeight.ExtraBold),
													Position = UDim2.fromScale(0, 0.5),
													RichText = true,
													Size = UDim2.new(1, -100, 0, 28),
													Text = "Rare",
													TextColor3 = Color3.fromRGB(255, 255, 255),
													TextScaled = true,
													TextSize = 22,
													TextXAlignment = Enum.TextXAlignment.Left,
													ZIndex = 2,
												},
												Children = {
													{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 22 } },
													{
														Primitive = "UIGradient",
														Props = {
															Color = ColorSequence.new({
																ColorSequenceKeypoint.new(0, Color3.fromRGB(166, 240, 255)),
																ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 195, 255)),
																ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 120, 220)),
															}),
															Rotation = 90,
														},
													},
													{ Primitive = "UIStroke", Props = { Color = Color3.fromRGB(10, 28, 56), Thickness = 2.5 } },
												},
											},
											{
												Primitive = "TextLabel",
												Id = "S_Tier",
												Props = {
													AnchorPoint = Vector2.new(1, 0.5),
													BackgroundTransparency = 1,
													FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Heavy),
													Position = UDim2.fromScale(1, 0.5),
													RichText = true,
													Size = UDim2.fromOffset(100, 26),
													Text = "T\u{200A}I\u{200A}E\u{200A}R\u{200A} \u{200A}3",
													TextColor3 = Color3.fromRGB(200, 206, 214),
													TextScaled = true,
													TextSize = 22,
													TextXAlignment = Enum.TextXAlignment.Right,
												},
												Children = {
													{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 22 } },
													{ Primitive = "UIStroke", Props = { Thickness = 2 } },
												},
											},
										},
									},
									{
										Primitive = "TextLabel",
										Id = "S_Name",
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											FontFace = Font.new("rbxassetid://12187373327", Enum.FontWeight.ExtraBold),
											LayoutOrder = 2,
											RichText = true,
											Size = UDim2.new(1, 0, 0, 36),
											Text = "Golden Sword",
											TextColor3 = Color3.fromRGB(255, 255, 255),
											TextScaled = true,
											TextSize = 30,
											TextWrapped = true,
											TextXAlignment = Enum.TextXAlignment.Left,
										},
										Children = {
											{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 30 } },
											{ Primitive = "UIStroke", Props = { Thickness = 3 } },
										},
									},
								},
							},
							-- A faint line between the header and the rest
							{
								Primitive = "Frame",
								Id = "S_Divider",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									BackgroundTransparency = 0.85,
									BorderSizePixel = 0,
									LayoutOrder = 2,
									Size = UDim2.new(1, 0, 0, 2),
								},
							},
							-- One row per stat (PREFAB | Stat)
							{
								Primitive = "Frame",
								Id = "U_Stats",
								Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 3, Size = UDim2.fromScale(1, 0) },
								Children = {
									{ Primitive = "UIListLayout", Props = { HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder } },
								},
							},
							-- The item's level and its XP towards the next one over a bar as wide as the box
							{
								Primitive = "Frame",
								Id = "U_Level",
								Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, LayoutOrder = 4, Size = UDim2.new(1, 0, 0, 56) },
								Children = {
									-- The level takes the left third, so a long XP text fits on the right
									{
										Primitive = "TextLabel",
										Id = "S_Level",
										Props = {
											AnchorPoint = Vector2.new(0, 0.5),
											BackgroundTransparency = 1,
											FontFace = Font.new("rbxassetid://12187373327", Enum.FontWeight.ExtraBold),
											Position = UDim2.new(0, 0, 0.5, -14),
											RichText = true,
											Size = UDim2.new(0.35, 0, 0, 28),
											Text = "Level 12",
											TextColor3 = Color3.fromRGB(255, 255, 255),
											TextScaled = true,
											TextSize = 24,
											TextXAlignment = Enum.TextXAlignment.Left,
										},
										Children = {
											{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 24 } },
											{ Primitive = "UIStroke", Props = { Thickness = 2.5 } },
										},
									},
									{
										Primitive = "TextLabel",
										Id = "S_Xp",
										Props = {
											AnchorPoint = Vector2.new(1, 0.5),
											BackgroundTransparency = 1,
											FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Heavy),
											Position = UDim2.new(1, 0, 0.5, -14),
											RichText = true,
											Size = UDim2.new(0.65, 0, 0, 24),
											Text = "340 / 1,200 XP",
											TextColor3 = Color3.fromRGB(200, 206, 214),
											TextScaled = true,
											TextSize = 22,
											TextXAlignment = Enum.TextXAlignment.Right,
										},
										Children = {
											{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 22 } },
											{ Primitive = "UIStroke", Props = { Thickness = 2 } },
										},
									},
									-- The XP bar: the share of the way to the next level, in the System buttons' Accept green
									{
										Primitive = "Frame",
										Props = {
											Name = "Track",
											AnchorPoint = Vector2.new(0.5, 1),
											BackgroundColor3 = Color3.fromRGB(0, 0, 0),
											BackgroundTransparency = 0.45,
											BorderSizePixel = 0,
											Position = UDim2.new(0.5, 0, 1, -2),
											Size = UDim2.new(1, 0, 0, 20),
										},
										Children = {
											{ Primitive = "UIStroke", Props = { LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 3 } },
											{
												Primitive = "Frame",
												Id = "S_XpFill",
												Props = {
													AnchorPoint = Vector2.new(0, 0.5),
													BackgroundColor3 = Color3.fromRGB(255, 255, 255),
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0, 0.5),
													Size = UDim2.fromScale(0.28, 1),
												},
												Children = {
													{ Primitive = "UIGradient", Props = { Color = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)), Rotation = -90 } },
													-- The System buttons' white inner highlight
													{
														Primitive = "UIStroke",
														Props = {
															BorderStrokePosition = Enum.BorderStrokePosition.Inner,
															Color = Color3.fromRGB(255, 255, 255),
															LineJoinMode = Enum.LineJoinMode.Miter,
															Thickness = 2,
															Transparency = 0.7,
														},
													},
												},
											},
										},
									},
								},
							},
							-- One row per enchantment (PREFAB | Enchantment)
							{
								Primitive = "Frame",
								Id = "U_Enchantments",
								Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 5, Size = UDim2.fromScale(1, 0) },
								Children = {
									{ Primitive = "UIListLayout", Props = { HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder } },
								},
							},
						},
					},
				},
			},
		},
	},

	--[[ Templates ]]

	Templates = {
		-- One stat: its name in spaced capitals, an optional badge after it, its value on the right
		["PREFAB | Stat"] = {
			Primitive = "Frame",
			Parent = "U_Stats",
			Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30) },
			Children = {
				{
					Primitive = "TextLabel",
					Id = "S_Label",
					Props = {
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Heavy),
						Position = UDim2.fromScale(0, 0.5),
						RichText = true,
						Size = UDim2.new(0.55, 0, 0, 26),
						Text = "D\u{200A}A\u{200A}M\u{200A}A\u{200A}G\u{200A}E",
						TextColor3 = Color3.fromRGB(200, 206, 214),
						TextScaled = true,
						TextSize = 22,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Children = {
						{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 22 } },
						{ Primitive = "UIStroke", Props = { Thickness = 2 } },
					},
				},
				-- A short mark in its own gradient and outline after the label (a stat's grade); hidden unless the stat has one
				{
					Primitive = "TextLabel",
					Id = "S_Badge",
					Visible = false,
					Props = {
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxassetid://12187373327", Enum.FontWeight.ExtraBold),
						Position = UDim2.new(0, 112, 0.5, 0),
						RichText = true,
						Size = UDim2.fromOffset(52, 26),
						Text = "A",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						TextSize = 22,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 2,
					},
					Children = {
						{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 22 } },
						{
							Primitive = "UIGradient",
							Props = {
								Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 225, 255)),
									ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 160, 255)),
									ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 95, 200)),
								}),
								Rotation = 90,
							},
						},
						{ Primitive = "UIStroke", Props = { Color = Color3.fromRGB(8, 36, 80), Thickness = 2 } },
					},
				},
				{
					Primitive = "TextLabel",
					Id = "S_Value",
					Props = {
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxassetid://12187373327", Enum.FontWeight.ExtraBold),
						Position = UDim2.fromScale(1, 0.5),
						RichText = true,
						Size = UDim2.new(0.45, 0, 0, 26),
						Text = "500",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						TextSize = 22,
						TextXAlignment = Enum.TextXAlignment.Right,
					},
					Children = {
						{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 22 } },
						{ Primitive = "UIStroke", Props = { Thickness = 2.5 } },
					},
				},
			},
		},
		-- One enchantment: its name and its level in roman numerals, in violet
		["PREFAB | Enchantment"] = {
			Primitive = "Frame",
			Parent = "U_Enchantments",
			Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30) },
			Children = {
				{
					Primitive = "TextLabel",
					Id = "S_Name",
					Props = {
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxassetid://12187373327", Enum.FontWeight.ExtraBold),
						Position = UDim2.fromScale(0, 0.5),
						RichText = true,
						Size = UDim2.new(0.75, 0, 0, 26),
						Text = "Sharpness",
						TextColor3 = Color3.fromRGB(205, 170, 255),
						TextScaled = true,
						TextSize = 22,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Children = {
						{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 22 } },
						{ Primitive = "UIStroke", Props = { Color = Color3.fromRGB(34, 10, 59), Thickness = 2.5 } },
					},
				},
				{
					Primitive = "TextLabel",
					Id = "S_Level",
					Props = {
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxassetid://12187373327", Enum.FontWeight.ExtraBold),
						Position = UDim2.fromScale(1, 0.5),
						RichText = true,
						Size = UDim2.new(0.25, 0, 0, 26),
						Text = "III",
						TextColor3 = Color3.fromRGB(205, 170, 255),
						TextScaled = true,
						TextSize = 22,
						TextXAlignment = Enum.TextXAlignment.Right,
					},
					Children = {
						{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 22 } },
						{ Primitive = "UIStroke", Props = { Color = Color3.fromRGB(34, 10, 59), Thickness = 2.5 } },
					},
				},
			},
		},
	},
}

return _gui
