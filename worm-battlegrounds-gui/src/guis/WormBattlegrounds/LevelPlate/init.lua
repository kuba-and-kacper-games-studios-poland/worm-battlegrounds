--[[
	Created By: 	HungryN00B
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The replay of what the last matches gave over the lobby (the rank crest, the XP bar, the XP tiles), and a weapon reward's unlock
	Name = "LevelPlate",
	-- The Lobby module turns it on with the lobby's other screens (LOBBY_GUIS); off on the match place
	Screen = { DisplayOrder = 3, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	Root = {
		Primitive = "Folder",
		Children = {
			--[[
				The replay of what the last matches gave, over the lobby (the owner, 2026-11-25: "needs to feel like leveling up in
				a high end competition"): the lobby darkens, the rank crest stands in the middle on its rays and glow, which grow
				richer with each prestige tier, the XP bar fills toward the next reward's card, and the match's XP pops in as
				tiles under it
			]]
			{
				Primitive = "Frame",
				Id = "U_Replay",
				Visible = false,
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
				},
				Children = {
					{
						Primitive = "Frame",
						Id = "S_Dim",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(8, 8, 14),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(2, 2),
							ZIndex = 1,
						},
					},
					--[[
						The stage, its own scope: the crest, its rank, LEVEL UP!, the bar with the next reward's card at its end,
						and the XP tiles. Laid out by its height (0.74 of the screen, 1.2 times as wide)
					]]
					{
						Primitive = "Frame",
						Id = "U_Plate",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.52),
							Size = UDim2.fromScale(1, 0.74),
							Visible = false,
							ZIndex = 5,
						},
						Children = {
							{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1.2, DominantAxis = Enum.DominantAxis.Height } },
							{ Primitive = "UIScale", Id = "S_Pop", Props = { Scale = 0 } },
							-- The crate result's rays behind the crest, in the tier's colour (set by the game), turning both ways
							{
								Primitive = "ImageLabel",
								Id = "S_RaysBack",
								Tags = { Utils_UISpin = { Utils_SpinSpeed = -1.35 } },
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.33),
									Rotation = 15,
									Size = UDim2.fromScale(1.15, 1.15),
									SizeConstraint = Enum.SizeConstraint.RelativeYY,
									ZIndex = 5,
									Image = "rbxassetid://109967588890262",
									ImageColor3 = Color3.fromRGB(255, 200, 80),
									ImageTransparency = 0.8,
									ScaleType = Enum.ScaleType.Fit,
								},
							},
							{
								Primitive = "ImageLabel",
								Id = "S_Rays",
								Tags = { Utils_UISpin = { Utils_SpinSpeed = 2.3 } },
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.33),
									Size = UDim2.fromScale(0.9, 0.9),
									SizeConstraint = Enum.SizeConstraint.RelativeYY,
									ZIndex = 5,
									Image = "rbxassetid://109967588890262",
									ImageColor3 = Color3.fromRGB(255, 200, 80),
									ImageTransparency = 0.55,
									ScaleType = Enum.ScaleType.Fit,
								},
							},
							{
								Primitive = "ImageLabel",
								Id = "S_Glow",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.33),
									Size = UDim2.fromScale(0.72, 0.72),
									SizeConstraint = Enum.SizeConstraint.RelativeYY,
									ZIndex = 6,
									Image = "rbxassetid://124537809204603",
									ImageColor3 = Color3.fromRGB(255, 200, 80),
									ImageTransparency = 0.35,
									ScaleType = Enum.ScaleType.Fit,
								},
							},
							--[[
								The rank crest: a rim in the tier's colours (I.G_Progression.ApplyFrame) with a light sweeping over it,
								round a dark middle holding the level
							]]
							{
								Primitive = "Frame",
								Id = "S_Badge",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.33),
									Size = UDim2.fromScale(0.4, 0.4),
									SizeConstraint = Enum.SizeConstraint.RelativeYY,
									ZIndex = 7,
								},
								Children = {
									{ Primitive = "UIScale", Id = "S_BadgeScale", Props = { Scale = 1 } },
									{
										Primitive = "Frame",
										Id = "S_Rim",
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundColor3 = Color3.fromRGB(255, 255, 255),
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.5, 0.5),
											Rotation = 45,
											Size = UDim2.fromScale(0.7, 0.7),
											ZIndex = 7,
										},
										Children = {
											{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.16, 0) } },
											{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 5 } },
											{
												Primitive = "UIGradient",
												Id = "S_TierGradient",
												Props = {
													Color = ColorSequence.new({
														ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 243, 160)),
														ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255, 176, 0)),
														ColorSequenceKeypoint.new(0.7, Color3.fromRGB(168, 100, 0)),
														ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 224, 102)),
													}),
													Rotation = 45,
												},
											},
										},
									},
									-- A light running across the rim, as the unlock's diamond
									{
										Primitive = "Frame",
										Props = {
											Name = "Sheen",
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundColor3 = Color3.fromRGB(255, 255, 255),
											BackgroundTransparency = 0.35,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.5, 0.5),
											Rotation = 45,
											Size = UDim2.fromScale(0.7, 0.7),
											ZIndex = 8,
										},
										Children = {
											{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.16, 0) } },
											{
												Primitive = "UIGradient",
												Tags = { Utils_Motion = { Utils_MotionKind = "Sweep", Utils_MotionSpeed = 1.2 } },
												Props = {
													Rotation = 45,
													Transparency = NumberSequence.new({
														NumberSequenceKeypoint.new(0, 1),
														NumberSequenceKeypoint.new(0.4, 1),
														NumberSequenceKeypoint.new(0.5, 0.2),
														NumberSequenceKeypoint.new(0.6, 1),
														NumberSequenceKeypoint.new(1, 1),
													}),
												},
											},
										},
									},
									-- The dark middle, lit from the top
									{
										Primitive = "Frame",
										Props = {
											Name = "Core",
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundColor3 = Color3.fromRGB(255, 255, 255),
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.5, 0.5),
											Rotation = 45,
											Size = UDim2.fromScale(0.56, 0.56),
											ZIndex = 9,
										},
										Children = {
											{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.14, 0) } },
											{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 4 } },
											{
												Primitive = "UIGradient",
												Props = {
													Color = ColorSequence.new(Color3.fromRGB(52, 54, 74), Color3.fromRGB(20, 20, 30)),
													Rotation = 45,
												},
											},
										},
									},
									-- The level, inside the middle (its box fits the turned square, three digits too)
									{
										Primitive = "TextLabel",
										Id = "S_LevelNum",
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											BorderSizePixel = 0,

											-- A hair left of the middle: the italic digits lean right
											Position = UDim2.fromScale(0.49, 0.5),
											Size = UDim2.fromScale(0.42, 0.36),
											ZIndex = 10,
											FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
											Text = "25",
											TextColor3 = Color3.fromRGB(255, 255, 255),
											RichText = true,
											TextScaled = true,
										},
										Children = {
											{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
											{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.06 } },
										},
									},
								},
							},
							-- LEVEL UP!, slammed across the crest's lower tip
							{
								Primitive = "TextLabel",
								Id = "S_LevelUp",
								Tags = { TextCase_Upper = {} },
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(0.72, 0.13),
									ZIndex = 12,
									FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
									Text = "Level up!",
									TextColor3 = Color3.fromRGB(255, 255, 255),
									RichText = true,
									TextScaled = true,
								},
								Children = {
									{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
									{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.06 } },
									{
										Primitive = "UIGradient",
										Props = {
											Color = ColorSequence.new({
												ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 246, 192)),
												ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 194, 26)),
												ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 138, 0)),
											}),
											Rotation = 90,
										},
									},
									{ Primitive = "UIScale", Id = "S_LevelUpScale", Props = { Scale = 0 } },
								},
							},
							-- The rank: one pip a tier, lit up to the player's (by the game), and the tier's name in its colours
							{
								Primitive = "Frame",
								Id = "S_Pips",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.6),
									Size = UDim2.fromScale(0.4, 0.03),
									ZIndex = 7,
								},
								Children = {
									{
										Primitive = "UIListLayout",
										Props = {
											FillDirection = Enum.FillDirection.Horizontal,
											HorizontalAlignment = Enum.HorizontalAlignment.Center,
											VerticalAlignment = Enum.VerticalAlignment.Center,
											SortOrder = Enum.SortOrder.LayoutOrder,
											Padding = UDim.new(0.035, 0),
										},
									},
									{
										Primitive = "Frame",
										Props = {
											Name = "Pip",
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 1,
											Size = UDim2.fromScale(1, 1),
											SizeConstraint = Enum.SizeConstraint.RelativeYY,
											ZIndex = 7,
										},
										Children = {
											{
												Primitive = "Frame",
												Props = {
													Name = "Gem",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundColor3 = Color3.fromRGB(255, 255, 255),
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.5, 0.5),
													Rotation = 45,
													Size = UDim2.fromScale(0.7, 0.7),
													ZIndex = 7,
												},
												Children = { { Primitive = "UIStroke", Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } } },
											},
										},
									},
									{
										Primitive = "Frame",
										Props = {
											Name = "Pip",
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 2,
											Size = UDim2.fromScale(1, 1),
											SizeConstraint = Enum.SizeConstraint.RelativeYY,
											ZIndex = 7,
										},
										Children = {
											{
												Primitive = "Frame",
												Props = {
													Name = "Gem",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundColor3 = Color3.fromRGB(255, 255, 255),
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.5, 0.5),
													Rotation = 45,
													Size = UDim2.fromScale(0.7, 0.7),
													ZIndex = 7,
												},
												Children = { { Primitive = "UIStroke", Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } } },
											},
										},
									},
									{
										Primitive = "Frame",
										Props = {
											Name = "Pip",
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 3,
											Size = UDim2.fromScale(1, 1),
											SizeConstraint = Enum.SizeConstraint.RelativeYY,
											ZIndex = 7,
										},
										Children = {
											{
												Primitive = "Frame",
												Props = {
													Name = "Gem",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundColor3 = Color3.fromRGB(255, 255, 255),
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.5, 0.5),
													Rotation = 45,
													Size = UDim2.fromScale(0.7, 0.7),
													ZIndex = 7,
												},
												Children = { { Primitive = "UIStroke", Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } } },
											},
										},
									},
									{
										Primitive = "Frame",
										Props = {
											Name = "Pip",
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 4,
											Size = UDim2.fromScale(1, 1),
											SizeConstraint = Enum.SizeConstraint.RelativeYY,
											ZIndex = 7,
										},
										Children = {
											{
												Primitive = "Frame",
												Props = {
													Name = "Gem",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundColor3 = Color3.fromRGB(255, 255, 255),
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.5, 0.5),
													Rotation = 45,
													Size = UDim2.fromScale(0.7, 0.7),
													ZIndex = 7,
												},
												Children = { { Primitive = "UIStroke", Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } } },
											},
										},
									},
									{
										Primitive = "Frame",
										Props = {
											Name = "Pip",
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 5,
											Size = UDim2.fromScale(1, 1),
											SizeConstraint = Enum.SizeConstraint.RelativeYY,
											ZIndex = 7,
										},
										Children = {
											{
												Primitive = "Frame",
												Props = {
													Name = "Gem",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundColor3 = Color3.fromRGB(70, 72, 92),
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.5, 0.5),
													Rotation = 45,
													Size = UDim2.fromScale(0.7, 0.7),
													ZIndex = 7,
												},
												Children = { { Primitive = "UIStroke", Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } } },
											},
										},
									},
									{
										Primitive = "Frame",
										Props = {
											Name = "Pip",
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 6,
											Size = UDim2.fromScale(1, 1),
											SizeConstraint = Enum.SizeConstraint.RelativeYY,
											ZIndex = 7,
										},
										Children = {
											{
												Primitive = "Frame",
												Props = {
													Name = "Gem",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundColor3 = Color3.fromRGB(70, 72, 92),
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.5, 0.5),
													Rotation = 45,
													Size = UDim2.fromScale(0.7, 0.7),
													ZIndex = 7,
												},
												Children = { { Primitive = "UIStroke", Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } } },
											},
										},
									},
									{
										Primitive = "Frame",
										Props = {
											Name = "Pip",
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 7,
											Size = UDim2.fromScale(1, 1),
											SizeConstraint = Enum.SizeConstraint.RelativeYY,
											ZIndex = 7,
										},
										Children = {
											{
												Primitive = "Frame",
												Props = {
													Name = "Gem",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundColor3 = Color3.fromRGB(70, 72, 92),
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.5, 0.5),
													Rotation = 45,
													Size = UDim2.fromScale(0.7, 0.7),
													ZIndex = 7,
												},
												Children = { { Primitive = "UIStroke", Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } } },
											},
										},
									},
								},
							},
							{
								Primitive = "TextLabel",
								Id = "S_TierName",
								Tags = { TextCase_Upper = {} },
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.66),
									Size = UDim2.fromScale(0.5, 0.065),
									ZIndex = 7,
									FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
									Text = "Gold",
									TextColor3 = Color3.fromRGB(255, 255, 255),
									RichText = true,
									TextScaled = true,
								},
								Children = {
									{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
									{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.06 } },
									{
										Primitive = "UIGradient",
										Id = "S_TierNameGradient",
										Props = {
											Color = ColorSequence.new(Color3.fromRGB(255, 243, 160), Color3.fromRGB(255, 176, 0)),
											Rotation = 90,
										},
									},
									{ Primitive = "UIScale", Id = "S_TierNameScale", Props = { Scale = 1 } },
								},
							},
							--[[
								The bar, thin and sharp (the owner, 2026-11-25: "the current one feels too bubbly"): a dark slot with the grey line,
								cut in five by faint ticks, the fill in the rank's own metal (I.G_Progression.ApplyFrame: its shine from Gold, its
								colours turning at Mythic) with a bright leading edge, a glow riding its end while it fills, and the XP over its end
							]]
							{
								Primitive = "Frame",
								Id = "S_Track",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundColor3 = Color3.fromRGB(13, 13, 20),
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.45, 0.785),
									Size = UDim2.fromScale(0.74, 0.034),
									ZIndex = 7,
								},
								Children = {
									{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.2, 0) } },
									{
										Primitive = "UIStroke",
										Tags = { Utils_UIStroke = {} },
										Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 3 },
									},
									{
										Primitive = "UIStroke",
										Tags = { Utils_UIStroke = {} },
										Props = {
											Name = "UIStroke_Inner",
											BorderStrokePosition = Enum.BorderStrokePosition.Inner,
											Color = Color3.fromRGB(130, 130, 130),
											Thickness = 2,
											Transparency = 0.4,
										},
									},
									{
										Primitive = "Frame",
										Id = "S_Fill",
										Props = {
											AnchorPoint = Vector2.new(0, 0.5),
											BackgroundColor3 = Color3.fromRGB(255, 255, 255),
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0, 0.5),
											Size = UDim2.fromScale(0.62, 1),
											ZIndex = 8,
										},
										Children = {
											{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.2, 0) } },
											{
												Primitive = "UIGradient",
												Id = "S_FillGradient",
												Props = {
													Color = ColorSequence.new({
														ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 243, 160)),
														ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255, 176, 0)),
														ColorSequenceKeypoint.new(0.7, Color3.fromRGB(168, 100, 0)),
														ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 224, 102)),
													}),
												},
											},
											-- A darker lower half, so the fill reads as a lit strip, not a tube
											{
												Primitive = "Frame",
												Props = {
													Name = "Shade",
													AnchorPoint = Vector2.new(0.5, 1),
													BackgroundColor3 = Color3.fromRGB(0, 0, 0),
													BackgroundTransparency = 0.78,
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.5, 1),
													Size = UDim2.fromScale(1, 0.45),
													ZIndex = 9,
												},
											},
											{
												Primitive = "Frame",
												Props = {
													Name = "Edge",
													AnchorPoint = Vector2.new(1, 0.5),
													BackgroundColor3 = Color3.fromRGB(255, 255, 255),
													BackgroundTransparency = 0.1,
													BorderSizePixel = 0,
													Position = UDim2.fromScale(1, 0.5),
													Size = UDim2.new(0, 3, 1, 0),
													ZIndex = 9,
												},
											},
										},
									},
									{
										Primitive = "Frame",
										Props = {
											Name = "Tick",
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundColor3 = Color3.fromRGB(255, 255, 255),
											BackgroundTransparency = 0.82,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.2, 0.5),
											Size = UDim2.new(0, 2, 1, 0),
											ZIndex = 10,
										},
									},
									{
										Primitive = "Frame",
										Props = {
											Name = "Tick",
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundColor3 = Color3.fromRGB(255, 255, 255),
											BackgroundTransparency = 0.82,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.4, 0.5),
											Size = UDim2.new(0, 2, 1, 0),
											ZIndex = 10,
										},
									},
									{
										Primitive = "Frame",
										Props = {
											Name = "Tick",
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundColor3 = Color3.fromRGB(255, 255, 255),
											BackgroundTransparency = 0.82,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.6, 0.5),
											Size = UDim2.new(0, 2, 1, 0),
											ZIndex = 10,
										},
									},
									{
										Primitive = "Frame",
										Props = {
											Name = "Tick",
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundColor3 = Color3.fromRGB(255, 255, 255),
											BackgroundTransparency = 0.82,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.8, 0.5),
											Size = UDim2.new(0, 2, 1, 0),
											ZIndex = 10,
										},
									},
									{
										Primitive = "ImageLabel",
										Id = "S_Head",
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.62, 0.5),
											Size = UDim2.fromScale(4, 4),
											SizeConstraint = Enum.SizeConstraint.RelativeYY,
											ZIndex = 11,
											Image = "rbxassetid://124537809204603",
											ImageColor3 = Color3.fromRGB(255, 240, 190),
											ImageTransparency = 1,
										},
									},
									-- The XP into the level, over the bar's right end
									{
										Primitive = "TextLabel",
										Id = "S_Xp",
										Props = {
											AnchorPoint = Vector2.new(1, 1),
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											Position = UDim2.new(1, 0, 0, -6),
											Size = UDim2.fromScale(0.4, 1.5),
											ZIndex = 11,
											FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
											Text = "180 / 292 XP",
											TextColor3 = Color3.fromRGB(255, 255, 255),
											TextXAlignment = Enum.TextXAlignment.Right,
											RichText = true,
											TextScaled = true,
										},
										Children = {
											{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
											{
												Primitive = "UIStroke",
												Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.07 },
											},
										},
									},
								},
							},
							--[[
								The next reward, a card at the bar's end: its picture (a weapon, a skin, an emote, or the player's own face
								in the frame the level opens), a glow in its colour, the level under it and a NEXT tag over it, which
								turns UNLOCKED when the bar reaches it
							]]
							{
								Primitive = "Frame",
								Id = "S_Next",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.915, 0.755),
									Size = UDim2.fromScale(0.18, 0.18),
									SizeConstraint = Enum.SizeConstraint.RelativeYY,
									ZIndex = 7,
								},
								Children = {
									{ Primitive = "UIScale", Id = "S_NextScale", Props = { Scale = 1 } },
									{
										Primitive = "ImageLabel",
										Id = "S_NextGlow",
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.5, 0.5),
											Size = UDim2.fromScale(2, 2),
											ZIndex = 7,
											Image = "rbxassetid://124537809204603",
											ImageColor3 = Color3.fromRGB(255, 200, 80),
											ImageTransparency = 0.55,
										},
									},
									-- The card: the dialogs' dark panel
									{
										Primitive = "Frame",
										Props = {
											Name = "Card",
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundColor3 = Color3.fromRGB(25, 25, 35),
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.5, 0.5),
											Size = UDim2.fromScale(1, 1),
											ZIndex = 8,
										},
										Children = {
											{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.18, 0) } },
											{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } },
											{
												Primitive = "UIStroke",
												Tags = { Utils_UIStroke = {} },
												Props = {
													Name = "UIStroke_Inner",
													BorderStrokePosition = Enum.BorderStrokePosition.Inner,
													Color = Color3.fromRGB(130, 130, 130),
													Thickness = 3,
												},
											},
											{
												Primitive = "UIGradient",
												Props = {
													Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 150, 165)),
													Rotation = 90,
												},
											},
										},
									},
									-- A Shiny reward's holo foil, the loadout cards' S_Foil on this card's rounded panel: the drifting holo, a sheen, sparkles
									{
										Primitive = "Frame",
										Id = "S_NextFoil",
										Props = {
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											Size = UDim2.fromScale(1, 1),
											Visible = false,
											ZIndex = 8,
										},
										Children = {
											{
												Primitive = "Frame",
												Props = {
													Name = "Holo",
													BackgroundColor3 = Color3.fromRGB(255, 255, 255),
													BackgroundTransparency = 0.55,
													BorderSizePixel = 0,
													Size = UDim2.fromScale(1, 1),
													ZIndex = 8,
												},
												Children = {
													{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.18, 0) } },
													{
														Primitive = "UIGradient",
														Tags = { Utils_UIGradientMove = { Utils_MoveSpeed = 0.25 } },
														Props = {
															Color = ColorSequence.new({
																ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 150, 220)),
																ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 235, 150)),
																ColorSequenceKeypoint.new(0.5, Color3.fromRGB(140, 255, 220)),
																ColorSequenceKeypoint.new(0.75, Color3.fromRGB(140, 190, 255)),
																ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 150, 255)),
															}),
															Rotation = 35,
														},
													},
												},
											},
											{
												Primitive = "Frame",
												Props = {
													Name = "Sheen",
													BackgroundColor3 = Color3.fromRGB(255, 255, 255),
													BackgroundTransparency = 0.25,
													BorderSizePixel = 0,
													Size = UDim2.fromScale(1, 1),
													ZIndex = 8,
												},
												Children = {
													{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.18, 0) } },
													{
														Primitive = "UIGradient",
														Tags = { Utils_Motion = { Utils_MotionKind = "Sweep", Utils_MotionSpeed = 1 } },
														Props = {
															Rotation = 25,
															Transparency = NumberSequence.new({
																NumberSequenceKeypoint.new(0, 1),
																NumberSequenceKeypoint.new(0.38, 1),
																NumberSequenceKeypoint.new(0.5, 0.1),
																NumberSequenceKeypoint.new(0.62, 1),
																NumberSequenceKeypoint.new(1, 1),
															}),
														},
													},
												},
											},
											{
												Primitive = "Frame",
												Props = {
													Name = "Sparkle",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													Position = UDim2.fromScale(0.16, 0.62),
													Size = UDim2.fromScale(0.2, 0.2),
													SizeConstraint = Enum.SizeConstraint.RelativeYY,
													ZIndex = 8,
												},
												Tags = { Utils_Motion = { Utils_MotionKind = "Twinkle", Utils_MotionSpeed = 1.3 } },
												Children = {
													{
														Primitive = "Frame",
														Props = {
															Name = "Across",
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 235, 250),
															BorderSizePixel = 0,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(1, 0.16),
															ZIndex = 8,
														},
														Children = {
															{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
															{
																Primitive = "UIGradient",
																Props = {
																	Transparency = NumberSequence.new({
																		NumberSequenceKeypoint.new(0, 1),
																		NumberSequenceKeypoint.new(0.5, 0),
																		NumberSequenceKeypoint.new(1, 1),
																	}),
																},
															},
														},
													},
													{
														Primitive = "Frame",
														Props = {
															Name = "Down",
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 235, 250),
															BorderSizePixel = 0,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(0.16, 1),
															ZIndex = 8,
														},
														Children = {
															{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
															{
																Primitive = "UIGradient",
																Props = {
																	Rotation = 90,
																	Transparency = NumberSequence.new({
																		NumberSequenceKeypoint.new(0, 1),
																		NumberSequenceKeypoint.new(0.5, 0),
																		NumberSequenceKeypoint.new(1, 1),
																	}),
																},
															},
														},
													},
												},
											},
											{
												Primitive = "Frame",
												Props = {
													Name = "Sparkle",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													Position = UDim2.fromScale(0.86, 0.36),
													Size = UDim2.fromScale(0.15, 0.15),
													SizeConstraint = Enum.SizeConstraint.RelativeYY,
													ZIndex = 8,
												},
												Tags = { Utils_Motion = { Utils_MotionKind = "Twinkle", Utils_MotionSpeed = 0.9 } },
												Children = {
													{
														Primitive = "Frame",
														Props = {
															Name = "Across",
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 235, 250),
															BorderSizePixel = 0,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(1, 0.16),
															ZIndex = 8,
														},
														Children = {
															{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
															{
																Primitive = "UIGradient",
																Props = {
																	Transparency = NumberSequence.new({
																		NumberSequenceKeypoint.new(0, 1),
																		NumberSequenceKeypoint.new(0.5, 0),
																		NumberSequenceKeypoint.new(1, 1),
																	}),
																},
															},
														},
													},
													{
														Primitive = "Frame",
														Props = {
															Name = "Down",
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 235, 250),
															BorderSizePixel = 0,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(0.16, 1),
															ZIndex = 8,
														},
														Children = {
															{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
															{
																Primitive = "UIGradient",
																Props = {
																	Rotation = 90,
																	Transparency = NumberSequence.new({
																		NumberSequenceKeypoint.new(0, 1),
																		NumberSequenceKeypoint.new(0.5, 0),
																		NumberSequenceKeypoint.new(1, 1),
																	}),
																},
															},
														},
													},
												},
											},
										},
									},
									-- A Golden reward's rim, the loadout cards' S_Gold on this card's rounded panel: a gold wash, a sheen, a glinting gold rim, sparkles
									{
										Primitive = "Frame",
										Id = "S_NextGold",
										Props = {
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											Size = UDim2.fromScale(1, 1),
											Visible = false,
											ZIndex = 8,
										},
										Children = {
											{
												Primitive = "Frame",
												Props = {
													Name = "Wash",
													BackgroundColor3 = Color3.fromRGB(255, 196, 60),
													BackgroundTransparency = 0.8,
													BorderSizePixel = 0,
													Size = UDim2.fromScale(1, 1),
													ZIndex = 8,
												},
												Children = { { Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.18, 0) } } },
											},
											{
												Primitive = "Frame",
												Props = {
													Name = "Sheen",
													BackgroundColor3 = Color3.fromRGB(255, 240, 190),
													BackgroundTransparency = 0.35,
													BorderSizePixel = 0,
													Size = UDim2.fromScale(1, 1),
													ZIndex = 8,
												},
												Children = {
													{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.18, 0) } },
													{
														Primitive = "UIGradient",
														Tags = { Utils_Motion = { Utils_MotionKind = "Sweep", Utils_MotionSpeed = 1 } },
														Props = {
															Rotation = 25,
															Transparency = NumberSequence.new({
																NumberSequenceKeypoint.new(0, 1),
																NumberSequenceKeypoint.new(0.38, 1),
																NumberSequenceKeypoint.new(0.5, 0.1),
																NumberSequenceKeypoint.new(0.62, 1),
																NumberSequenceKeypoint.new(1, 1),
															}),
														},
													},
												},
											},
											{
												Primitive = "Frame",
												Props = {
													Name = "Rim",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													Size = UDim2.fromScale(1, 1),
													ZIndex = 10,
												},
												Children = {
													{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.18, 0) } },
													{
														Primitive = "UIStroke",
														Tags = { Utils_UIStroke = {} },
														Props = { BorderStrokePosition = Enum.BorderStrokePosition.Inner, Color = Color3.fromRGB(255, 255, 255), Thickness = 4 },
														Children = {
															{
																Primitive = "UIGradient",
																Tags = { Utils_Motion = { Utils_MotionKind = "Glint", Utils_MotionSpeed = 1 } },
																Props = {
																	Color = ColorSequence.new({
																		ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 110, 20)),
																		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 200, 60)),
																		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 240, 170)),
																		ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 200, 60)),
																		ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 110, 20)),
																	}),
																	Rotation = 45,
																},
															},
														},
													},
												},
											},
											{
												Primitive = "Frame",
												Props = {
													Name = "Sparkle",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													Position = UDim2.fromScale(0.16, 0.62),
													Size = UDim2.fromScale(0.22, 0.22),
													SizeConstraint = Enum.SizeConstraint.RelativeYY,
													ZIndex = 8,
												},
												Tags = { Utils_Motion = { Utils_MotionKind = "Twinkle", Utils_MotionSpeed = 1.3 } },
												Children = {
													{
														Primitive = "Frame",
														Props = {
															Name = "Across",
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 240, 190),
															BorderSizePixel = 0,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(1, 0.16),
															ZIndex = 8,
														},
														Children = {
															{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
															{
																Primitive = "UIGradient",
																Props = {
																	Transparency = NumberSequence.new({
																		NumberSequenceKeypoint.new(0, 1),
																		NumberSequenceKeypoint.new(0.5, 0),
																		NumberSequenceKeypoint.new(1, 1),
																	}),
																},
															},
														},
													},
													{
														Primitive = "Frame",
														Props = {
															Name = "Down",
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 240, 190),
															BorderSizePixel = 0,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(0.16, 1),
															ZIndex = 8,
														},
														Children = {
															{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
															{
																Primitive = "UIGradient",
																Props = {
																	Rotation = 90,
																	Transparency = NumberSequence.new({
																		NumberSequenceKeypoint.new(0, 1),
																		NumberSequenceKeypoint.new(0.5, 0),
																		NumberSequenceKeypoint.new(1, 1),
																	}),
																},
															},
														},
													},
												},
											},
											{
												Primitive = "Frame",
												Props = {
													Name = "Sparkle",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													Position = UDim2.fromScale(0.86, 0.36),
													Size = UDim2.fromScale(0.16, 0.16),
													SizeConstraint = Enum.SizeConstraint.RelativeYY,
													ZIndex = 8,
												},
												Tags = { Utils_Motion = { Utils_MotionKind = "Twinkle", Utils_MotionSpeed = 0.9 } },
												Children = {
													{
														Primitive = "Frame",
														Props = {
															Name = "Across",
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 240, 190),
															BorderSizePixel = 0,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(1, 0.16),
															ZIndex = 8,
														},
														Children = {
															{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
															{
																Primitive = "UIGradient",
																Props = {
																	Transparency = NumberSequence.new({
																		NumberSequenceKeypoint.new(0, 1),
																		NumberSequenceKeypoint.new(0.5, 0),
																		NumberSequenceKeypoint.new(1, 1),
																	}),
																},
															},
														},
													},
													{
														Primitive = "Frame",
														Props = {
															Name = "Down",
															AnchorPoint = Vector2.new(0.5, 0.5),
															BackgroundColor3 = Color3.fromRGB(255, 240, 190),
															BorderSizePixel = 0,
															Position = UDim2.fromScale(0.5, 0.5),
															Size = UDim2.fromScale(0.16, 1),
															ZIndex = 8,
														},
														Children = {
															{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
															{
																Primitive = "UIGradient",
																Props = {
																	Rotation = 90,
																	Transparency = NumberSequence.new({
																		NumberSequenceKeypoint.new(0, 1),
																		NumberSequenceKeypoint.new(0.5, 0),
																		NumberSequenceKeypoint.new(1, 1),
																	}),
																},
															},
														},
													},
												},
											},
										},
									},
									{
										Primitive = "ImageLabel",
										Id = "S_NextIcon",
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.5, 0.45),
											Size = UDim2.fromScale(0.66, 0.66),
											ZIndex = 9,
											Image = "rbxassetid://121731184312632",
											ScaleType = Enum.ScaleType.Fit,
										},
										Children = {
											-- Round only for a frame reward (the player's face in it)
											{ Primitive = "UICorner", Id = "S_NextRound", Props = { CornerRadius = UDim.new(0, 0) } },
										},
									},
									-- A frame reward's rim round the player's face, in the frame's colours
									{
										Primitive = "Frame",
										Id = "S_NextRing",
										Visible = false,
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.5, 0.45),
											Size = UDim2.fromScale(0.66, 0.66),
											ZIndex = 10,
										},
										Children = {
											{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
											{
												Primitive = "UIStroke",
												Tags = { Utils_UIStroke = {} },
												Props = { Color = Color3.fromRGB(255, 255, 255), Thickness = 5 },
												Children = {
													{
														Primitive = "UIGradient",
														Id = "S_NextRingGradient",
														Props = { Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(154, 167, 184)), Rotation = 45 },
													},
												},
											},
										},
									},
									{
										Primitive = "TextLabel",
										Id = "S_NextLevel",
										Tags = { TextCase_Upper = {} },
										Props = {
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.5, 0.86),
											Size = UDim2.fromScale(0.8, 0.2),
											ZIndex = 11,
											FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
											Text = "Lv 30",
											TextColor3 = Color3.fromRGB(255, 255, 255),
											RichText = true,
											TextScaled = true,
										},
										Children = {
											{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
											{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.07 } },
										},
									},
									-- NEXT or UNLOCKED, on the crate card's BEST tag over the card's top
									{
										Primitive = "Frame",
										Props = {
											Name = "Tag",
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundColor3 = Color3.fromRGB(255, 255, 255),
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.5, 0),
											Rotation = -4,
											Size = UDim2.fromScale(0.86, 0.24),
											ZIndex = 12,
										},
										Children = {
											{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.3, 0) } },
											{ Primitive = "UIStroke", Props = { Color = Color3.fromRGB(20, 20, 28), Thickness = 3 } },
											{
												Primitive = "UIGradient",
												Id = "S_NextTagGradient",
												Props = {
													Color = ColorSequence.new(Color3.fromRGB(150, 156, 178), Color3.fromRGB(96, 100, 122)),
													Rotation = 90,
												},
											},
											{
												Primitive = "TextLabel",
												Id = "S_NextTag",
												Tags = { TextCase_Upper = {} },
												Props = {
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.5, 0.5),
													Size = UDim2.fromScale(0.84, 0.76),
													ZIndex = 13,
													FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
													Text = "Next",
													TextColor3 = Color3.fromRGB(255, 255, 255),
													RichText = true,
													TextScaled = true,
												},
												Children = {
													{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
													{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.07 } },
												},
											},
										},
									},
								},
							},
							-- The match's XP, one tile each, popping in along the bottom
							{
								Primitive = "Frame",
								Id = "S_Lines",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.93),
									Size = UDim2.fromScale(0.96, 0.13),
									ZIndex = 7,
								},
								Children = {
									{
										Primitive = "UIListLayout",
										Props = {
											FillDirection = Enum.FillDirection.Horizontal,
											HorizontalAlignment = Enum.HorizontalAlignment.Center,
											VerticalAlignment = Enum.VerticalAlignment.Center,
											SortOrder = Enum.SortOrder.LayoutOrder,
											Padding = UDim.new(0.02, 0),
										},
									},
								},
							},
						},
					},
					-- The diamonds a match paid, popped up over the player's snail on the stage by code before they fly into the diamonds
					{
						Primitive = "Frame",
						Id = "S_Gain",
						Props = {
							AnchorPoint = Vector2.new(0.5, 1),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.4),
							Size = UDim2.fromScale(0.16, 0.075),
							Visible = false,
							ZIndex = 7,
						},
						Children = {
							{ Primitive = "UIScale", Id = "S_GainScale", Props = { Scale = 0 } },
							{
								Primitive = "UIListLayout",
								Props = {
									FillDirection = Enum.FillDirection.Horizontal,
									HorizontalAlignment = Enum.HorizontalAlignment.Center,
									VerticalAlignment = Enum.VerticalAlignment.Center,
									SortOrder = Enum.SortOrder.LayoutOrder,
									Padding = UDim.new(0.02, 0),
								},
							},
							{
								Primitive = "TextLabel",
								Id = "S_GainText",
								Props = {
									AutomaticSize = Enum.AutomaticSize.X,
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 0,
									Size = UDim2.fromScale(0, 1),
									ZIndex = 8,
									FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
									Text = "+100",
									TextColor3 = Color3.fromRGB(86, 184, 255),
									RichText = true,
									TextScaled = true,
								},
								Children = {
									{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
									{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.06 } },
								},
							},
							-- The diamonds' own picture, set by code (the Currency module's icon)
							{
								Primitive = "ImageLabel",
								Id = "S_GainIcon",
								Props = {
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 1,
									Size = UDim2.fromScale(1, 1),
									SizeConstraint = Enum.SizeConstraint.RelativeYY,
									ZIndex = 8,
									ScaleType = Enum.ScaleType.Fit,
								},
							},
						},
					},
					-- A new rank's white flash over the stage
					{
						Primitive = "Frame",
						Id = "S_Flash",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(2, 2),
							ZIndex = 9,
						},
					},
					-- The replay's particles (sparks into the bar, the level-up burst, the flying diamonds) are drawn here, over everything
					{
						Primitive = "Frame",
						Id = "S_Particles",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1, 1),
							ZIndex = 10,
						},
					},
				},
			},
			--[[
				The level at rest, under the diamonds (the owner's pick, 2026-11-25, "under the diamonds", "longer and thinner than
				the diamond one", "make it this bar to keep it consistent": the replay's bar; the menu and the loadout column lowered
				to make room): a copy of the Currency gui's U_Bar row (its box, its right-aligned list, invisible stand-ins sized as
				the diamonds plate and the +), so it lines up on every screen shape; under it the replay's thin bar from the
				diamonds plate's left edge to the +'s right edge, in the middle of the gap down to the menu, its fill in the tier's
				colours and the rank crest on its left end (set by the game). Hidden while the replay plays
			]]
			{
				Primitive = "Frame",
				Id = "U_Rest",
				Props = {
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.95, 0.0315),
					Size = UDim2.fromScale(0.2461, 0.0502),
					ZIndex = 2,
				},
				Children = {
					{
						Primitive = "UIListLayout",
						Props = {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Right,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0.0169, 0),
						},
					},
					-- The diamonds plate's stand-in (its size and aspect), holding the bar under it from its left edge
					{
						Primitive = "Frame",
						Props = {
							Name = "Diamonds",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 2,
							Size = UDim2.fromScale(0.4148, 1),
							ZIndex = 2,
						},
						Children = {
							{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 3.6134 } },
							--[[
								The replay's bar (its slot, ticks, fill, shade and edge), as wide as the diamonds plate, the gap and the +
								together (1.3698 of the plate), 0.4 of the plate high, its middle 1.57 plates down, so the crest on it
								keeps clear of the plate and the menu
							]]
							{
								Primitive = "Frame",
								Id = "S_RestTrack",
								Props = {
									AnchorPoint = Vector2.new(0, 0.5),
									BackgroundColor3 = Color3.fromRGB(13, 13, 20),
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0, 1.57),
									Size = UDim2.fromScale(1.3698, 0.4),
									ZIndex = 2,
								},
								Children = {
									{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.2, 0) } },
									{
										Primitive = "UIStroke",
										Tags = { Utils_UIStroke = {} },
										Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 3 },
									},
									{
										Primitive = "UIStroke",
										Tags = { Utils_UIStroke = {} },
										Props = {
											Name = "UIStroke_Inner",
											BorderStrokePosition = Enum.BorderStrokePosition.Inner,
											Color = Color3.fromRGB(130, 130, 130),
											Thickness = 2,
											Transparency = 0.4,
										},
									},
									{
										Primitive = "Frame",
										Id = "S_RestFill",
										Props = {
											AnchorPoint = Vector2.new(0, 0.5),
											BackgroundColor3 = Color3.fromRGB(255, 255, 255),
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0, 0.5),
											Size = UDim2.fromScale(0.62, 1),
											ZIndex = 3,
										},
										Children = {
											{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.2, 0) } },
											{
												Primitive = "UIGradient",
												Id = "S_RestFillGradient",
												Props = {
													Color = ColorSequence.new({
														ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 243, 160)),
														ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255, 176, 0)),
														ColorSequenceKeypoint.new(0.7, Color3.fromRGB(168, 100, 0)),
														ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 224, 102)),
													}),
												},
											},
											{
												Primitive = "Frame",
												Props = {
													Name = "Shade",
													AnchorPoint = Vector2.new(0.5, 1),
													BackgroundColor3 = Color3.fromRGB(0, 0, 0),
													BackgroundTransparency = 0.78,
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.5, 1),
													Size = UDim2.fromScale(1, 0.45),
													ZIndex = 4,
												},
											},
											{
												Primitive = "Frame",
												Props = {
													Name = "Edge",
													AnchorPoint = Vector2.new(1, 0.5),
													BackgroundColor3 = Color3.fromRGB(255, 255, 255),
													BackgroundTransparency = 0.1,
													BorderSizePixel = 0,
													Position = UDim2.fromScale(1, 0.5),
													Size = UDim2.new(0, 2, 1, 0),
													ZIndex = 4,
												},
											},
										},
									},
									{
										Primitive = "Frame",
										Props = {
											Name = "Tick",
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundColor3 = Color3.fromRGB(255, 255, 255),
											BackgroundTransparency = 0.82,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.36, 0.5),
											Size = UDim2.new(0, 2, 1, 0),
											ZIndex = 5,
										},
									},
									{
										Primitive = "Frame",
										Props = {
											Name = "Tick",
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundColor3 = Color3.fromRGB(255, 255, 255),
											BackgroundTransparency = 0.82,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.57, 0.5),
											Size = UDim2.new(0, 2, 1, 0),
											ZIndex = 5,
										},
									},
									{
										Primitive = "Frame",
										Props = {
											Name = "Tick",
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundColor3 = Color3.fromRGB(255, 255, 255),
											BackgroundTransparency = 0.82,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.785, 0.5),
											Size = UDim2.new(0, 2, 1, 0),
											ZIndex = 5,
										},
									},
									-- The crest, the replay's small, on the bar's left end
									{
										Primitive = "Frame",
										Props = {
											Name = "Crest",
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.05, 0.5),
											Size = UDim2.fromScale(1.95, 1.95),
											SizeConstraint = Enum.SizeConstraint.RelativeYY,
											ZIndex = 7,
										},
										Children = {
											{
												Primitive = "Frame",
												Props = {
													Name = "Rim",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundColor3 = Color3.fromRGB(255, 255, 255),
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.5, 0.5),
													Rotation = 45,
													Size = UDim2.fromScale(0.74, 0.74),
													ZIndex = 7,
												},
												Children = {
													{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.16, 0) } },
													{
														Primitive = "UIStroke",
														Tags = { Utils_UIStroke = {} },
														Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 3 },
													},
													{
														Primitive = "UIGradient",
														Id = "S_RestTierGradient",
														Props = {
															Color = ColorSequence.new({
																ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 243, 160)),
																ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255, 176, 0)),
																ColorSequenceKeypoint.new(0.7, Color3.fromRGB(168, 100, 0)),
																ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 224, 102)),
															}),
															Rotation = 45,
														},
													},
												},
											},
											{
												Primitive = "Frame",
												Props = {
													Name = "Core",
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundColor3 = Color3.fromRGB(255, 255, 255),
													BorderSizePixel = 0,
													Position = UDim2.fromScale(0.5, 0.5),
													Rotation = 45,
													Size = UDim2.fromScale(0.56, 0.56),
													ZIndex = 8,
												},
												Children = {
													{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.14, 0) } },
													{
														Primitive = "UIStroke",
														Tags = { Utils_UIStroke = {} },
														Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 },
													},
													{
														Primitive = "UIGradient",
														Props = {
															Color = ColorSequence.new(Color3.fromRGB(52, 54, 74), Color3.fromRGB(20, 20, 30)),
															Rotation = 45,
														},
													},
												},
											},
											-- The level, its box inside the turned middle (three digits too)
											{
												Primitive = "TextLabel",
												Id = "S_RestLevel",
												Props = {
													AnchorPoint = Vector2.new(0.5, 0.5),
													BackgroundTransparency = 1,
													BorderSizePixel = 0,

													-- A hair left of the middle: the italic digits lean right
													Position = UDim2.fromScale(0.49, 0.5),
													Size = UDim2.fromScale(0.42, 0.36),
													ZIndex = 9,
													FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
													Text = "25",
													TextColor3 = Color3.fromRGB(255, 255, 255),
													RichText = true,
													TextScaled = true,
												},
												Children = {
													{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
													{
														Primitive = "UIStroke",
														Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.07 },
													},
												},
											},
										},
									},
								},
							},
						},
					},
					-- The + button's stand-in (its width)
					{
						Primitive = "Frame",
						Props = {
							Name = "Add",
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 3,
							Size = UDim2.fromScale(0.1365, 1),
						},
					},
				},
			},
			--[[
				A level's weapon reward (Shiny at 10, 20 and 30, Golden at 60, 75 and 90), over the replay once its LEVEL UP!
				shows: the screen darkens, the level's diamond rattles and swells with light, flashes open into the crate
				result's card in its Shiny foil or Golden rim on turning rays, then SHINY! or GOLDEN! slams in over the name
			]]
			{
				Primitive = "Frame",
				Id = "U_Unlock",
				Visible = false,
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					ZIndex = 20,
				},
				Children = {
					-- The dark behind it all, deeper than the replay's dim
					{
						Primitive = "Frame",
						Id = "S_Shade",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(4, 5, 10),
							BackgroundTransparency = 0.12,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(2, 2),
							ZIndex = 20,
						},
					},
					-- The crate result's glow and rays, in the reward's colour (set by the game), turning (about 14° a second), the back rays the other way
					{
						Primitive = "ImageLabel",
						Id = "S_Glow",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.42),
							Size = UDim2.fromScale(1, 0.95),
							ZIndex = 21,
							Image = "rbxassetid://124537809204603",
							ImageColor3 = Color3.fromRGB(255, 196, 60),
							ImageTransparency = 0.15,
							ScaleType = Enum.ScaleType.Fit,
						},
						Children = {
							{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1, DominantAxis = Enum.DominantAxis.Height } },
						},
					},
					{
						Primitive = "ImageLabel",
						Id = "S_RaysBack",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.42),
							Rotation = 15,
							Size = UDim2.fromScale(1, 1.6),
							ZIndex = 21,
							Image = "rbxassetid://109967588890262",
							ImageColor3 = Color3.fromRGB(255, 200, 80),
							ImageTransparency = 0.78,
							ScaleType = Enum.ScaleType.Fit,
						},
						Tags = { Utils_UISpin = { Utils_SpinSpeed = -1.35 } },
						Children = {
							{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1, DominantAxis = Enum.DominantAxis.Height } },
						},
					},
					{
						Primitive = "ImageLabel",
						Id = "S_Rays",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.42),
							Size = UDim2.fromScale(1, 1.25),
							ZIndex = 22,
							Image = "rbxassetid://109967588890262",
							ImageColor3 = Color3.fromRGB(255, 200, 80),
							ImageTransparency = 0.4,
							ScaleType = Enum.ScaleType.Fit,
						},
						Tags = { Utils_UISpin = { Utils_SpinSpeed = 2.3 } },
						Children = {
							{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1, DominantAxis = Enum.DominantAxis.Height } },
						},
					},
					-- What the reward is for, over it all: "Level 90 reward"
					{
						Primitive = "TextLabel",
						Id = "S_Kicker",
						Tags = { TextCase_Upper = {} },
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.155),
							Size = UDim2.fromScale(0.4, 0.05),
							ZIndex = 27,
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
							Text = "Level 90 reward",
							TextColor3 = Color3.fromRGB(255, 233, 168),
							RichText = true,
							TextScaled = true,
						},
						Children = {
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
							{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.07 } },
							{ Primitive = "UIScale", Id = "S_KickerScale", Props = { Scale = 1 } },
						},
					},
					--[[
						The level's diamond (the plate's S_Diamond, big), holding the reward until it flashes open: its fill in the
						reward's colours, the level over it, a glow swelling behind it
					]]
					{
						Primitive = "Frame",
						Id = "S_Orb",
						Visible = false,
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.42),
							Size = UDim2.fromScale(0.26, 0.26),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							ZIndex = 23,
						},
						Children = {
							{ Primitive = "UIScale", Id = "S_OrbScale", Props = { Scale = 1 } },
							{
								Primitive = "ImageLabel",
								Id = "S_OrbGlow",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(2.4, 2.4),
									ZIndex = 23,
									Image = "rbxassetid://124537809204603",
									ImageColor3 = Color3.fromRGB(255, 220, 120),
									ImageTransparency = 0.35,
								},
							},
							{
								Primitive = "Frame",
								Id = "S_OrbDiamond",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.5),
									Rotation = 45,
									Size = UDim2.fromScale(0.68, 0.68),
									ZIndex = 24,
								},
								Children = {
									{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.2, 0) } },
									{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 5 } },
									{
										Primitive = "UIGradient",
										Id = "S_OrbGradient",
										Props = {
											Color = ColorSequence.new({
												ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 246, 192)),
												ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 194, 26)),
												ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 138, 0)),
											}),
											Rotation = 45,
										},
									},
								},
							},
							-- A light running across the diamond while it waits, as the gold rim's glint
							{
								Primitive = "Frame",
								Id = "S_OrbSheen",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									BackgroundTransparency = 0.3,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.5),
									Rotation = 45,
									Size = UDim2.fromScale(0.68, 0.68),
									ZIndex = 25,
								},
								Children = {
									{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.2, 0) } },
									{
										Primitive = "UIGradient",
										Props = {
											Rotation = 45,
											Transparency = NumberSequence.new({
												NumberSequenceKeypoint.new(0, 1),
												NumberSequenceKeypoint.new(0.38, 1),
												NumberSequenceKeypoint.new(0.5, 0.1),
												NumberSequenceKeypoint.new(0.62, 1),
												NumberSequenceKeypoint.new(1, 1),
											}),
										},
										Tags = { Utils_Motion = { Utils_MotionKind = "Sweep", Utils_MotionSpeed = 1.6 } },
									},
								},
							},
							{
								Primitive = "TextLabel",
								Id = "S_OrbLevel",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,

									-- A hair left of the middle: the italic digits lean right
									Position = UDim2.fromScale(0.49, 0.5),
									Size = UDim2.fromScale(0.44, 0.3),
									ZIndex = 26,
									FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
									Text = "90",
									TextColor3 = Color3.fromRGB(255, 255, 255),
									RichText = true,
									TextScaled = true,
								},
								Children = {
									{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
									{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.06 } },
								},
							},
						},
					},
					--[[
						The reward's card: the crate result's big card (its pictures and sizes), in the Shiny foil or the Golden rim
						the loadout's cards wear, the weapon's picture with a sheen running over it (gilded when Golden), its name
						along the bottom and the level on a tag at the top, as the crate card's BEST tag
					]]
					{
						Primitive = "Frame",
						Id = "S_CardSlot",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.42),
							Size = UDim2.fromScale(1, 0.4),
							ZIndex = 24,
						},
						Children = {
							{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 1.1169, DominantAxis = Enum.DominantAxis.Height } },
							{ Primitive = "UIScale", Id = "S_CardScale", Props = { Scale = 1 } },
							{
								Primitive = "Frame",
								Props = {
									Name = "Background",
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(-0.0058, -0.0385),
									Size = UDim2.fromScale(1.0116, 1.0769),
									ZIndex = 24,
								},
								Children = {
									{
										Primitive = "ImageLabel",
										Props = {
											Name = "Main",
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 0,
											Position = UDim2.fromScale(0.0057, 0.0357),
											Size = UDim2.fromScale(0.9885, 0.9286),
											ZIndex = 24,
											Image = "rbxassetid://111365905871167",
											ImageColor3 = Color3.fromRGB(25, 25, 35),
											ScaleType = Enum.ScaleType.Fit,
										},
									},
									{
										Primitive = "ImageLabel",
										Props = {
											Name = "MainFill",
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 1,
											Position = UDim2.fromScale(0.0057, 0.0357),
											Size = UDim2.fromScale(0.9885, 0.9286),
											ZIndex = 24,
											Image = "rbxassetid://111365905871167",
											ImageColor3 = Color3.fromRGB(25, 25, 35),
											ScaleType = Enum.ScaleType.Fit,
										},
									},
									{
										Primitive = "ImageLabel",
										Props = {
											Name = "MainFill",
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 2,
											Position = UDim2.fromScale(0.0057, 0.0357),
											Size = UDim2.fromScale(0.9885, 0.9286),
											ZIndex = 24,
											Image = "rbxassetid://111365905871167",
											ImageColor3 = Color3.fromRGB(25, 25, 35),
											ScaleType = Enum.ScaleType.Fit,
										},
									},
									-- The reward's colour rising from the card's bottom (set by the game), as a crate card's rarity glow
									{
										Primitive = "ImageLabel",
										Id = "S_CardGlow",
										Props = {
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 3,
											Position = UDim2.fromScale(0.0057, 0.0357),
											Size = UDim2.fromScale(0.9885, 0.9286),
											ZIndex = 24,
											Image = "rbxassetid://111365905871167",
											ImageColor3 = Color3.fromRGB(255, 200, 40),
											ImageTransparency = 0.2,
											ScaleType = Enum.ScaleType.Fit,
										},
										Children = {
											{
												Primitive = "UIGradient",
												Props = {
													Rotation = -90,
													Transparency = NumberSequence.new({
														NumberSequenceKeypoint.new(0, 0.35),
														NumberSequenceKeypoint.new(0.6, 1),
														NumberSequenceKeypoint.new(1, 1),
													}),
												},
											},
										},
									},
									{
										Primitive = "ImageLabel",
										Props = {
											Name = "Stroke2",
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 4,
											Size = UDim2.fromScale(1, 1),
											ZIndex = 24,
											Image = "rbxassetid://76134696210650",
											ImageColor3 = Color3.fromRGB(25, 25, 35),
											ScaleType = Enum.ScaleType.Fit,
										},
									},
									{
										Primitive = "ImageLabel",
										Id = "S_CardStroke",
										Props = {
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 5,
											Position = UDim2.fromScale(0.0115, 0.0143),
											Size = UDim2.fromScale(0.977, 0.9714),
											ZIndex = 24,
											Image = "rbxassetid://92579798166886",
											ImageColor3 = Color3.fromRGB(255, 200, 40),
											ScaleType = Enum.ScaleType.Fit,
										},
									},
									-- The Shiny card's holo foil: the loadout card's S_Foil on this card's pictures
									{
										Primitive = "Frame",
										Id = "S_Foil",
										Props = {
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 6,
											Size = UDim2.fromScale(1, 1),
											Visible = false,
											ZIndex = 25,
										},
										Children = {
											{
												Primitive = "ImageLabel",
												Props = {
													Name = "Holo",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 0,
													Position = UDim2.fromScale(0.0057, 0.0357),
													Size = UDim2.fromScale(0.9885, 0.9286),
													ZIndex = 25,
													Image = "rbxassetid://111365905871167",
													ImageTransparency = 0.55,
													ScaleType = Enum.ScaleType.Fit,
												},
												Children = {
													{
														Primitive = "UIGradient",
														Props = {
															Color = ColorSequence.new({
																ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 150, 220)),
																ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 235, 150)),
																ColorSequenceKeypoint.new(0.5, Color3.fromRGB(140, 255, 220)),
																ColorSequenceKeypoint.new(0.75, Color3.fromRGB(140, 190, 255)),
																ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 150, 255)),
															}),
															Rotation = 35,
														},
														Tags = { Utils_UIGradientMove = { Utils_MoveSpeed = 0.25 } },
													},
												},
											},
											{
												Primitive = "ImageLabel",
												Props = {
													Name = "Sheen",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 1,
													Position = UDim2.fromScale(0.0057, 0.0357),
													Size = UDim2.fromScale(0.9885, 0.9286),
													ZIndex = 26,
													Image = "rbxassetid://111365905871167",
													ImageTransparency = 0.25,
													ScaleType = Enum.ScaleType.Fit,
												},
												Children = {
													{
														Primitive = "UIGradient",
														Props = {
															Rotation = 25,
															Transparency = NumberSequence.new({
																NumberSequenceKeypoint.new(0, 1),
																NumberSequenceKeypoint.new(0.38, 1),
																NumberSequenceKeypoint.new(0.5, 0.1),
																NumberSequenceKeypoint.new(0.62, 1),
																NumberSequenceKeypoint.new(1, 1),
															}),
														},
														Tags = { Utils_Motion = { Utils_MotionKind = "Sweep", Utils_MotionSpeed = 1 } },
													},
												},
											},
										},
									},
									-- The Golden card's rim: the loadout card's S_Gold on this card's pictures
									{
										Primitive = "Frame",
										Id = "S_Gold",
										Props = {
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 7,
											Size = UDim2.fromScale(1, 1),
											Visible = false,
											ZIndex = 25,
										},
										Children = {
											{
												Primitive = "ImageLabel",
												Props = {
													Name = "Wash",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 0,
													Position = UDim2.fromScale(0.0057, 0.0357),
													Size = UDim2.fromScale(0.9885, 0.9286),
													ZIndex = 25,
													Image = "rbxassetid://111365905871167",
													ImageColor3 = Color3.fromRGB(255, 196, 60),
													ImageTransparency = 0.8,
													ScaleType = Enum.ScaleType.Fit,
												},
											},
											{
												Primitive = "ImageLabel",
												Props = {
													Name = "Sheen",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 1,
													Position = UDim2.fromScale(0.0057, 0.0357),
													Size = UDim2.fromScale(0.9885, 0.9286),
													ZIndex = 26,
													Image = "rbxassetid://111365905871167",
													ImageColor3 = Color3.fromRGB(255, 240, 190),
													ImageTransparency = 0.35,
													ScaleType = Enum.ScaleType.Fit,
												},
												Children = {
													{
														Primitive = "UIGradient",
														Props = {
															Rotation = 25,
															Transparency = NumberSequence.new({
																NumberSequenceKeypoint.new(0, 1),
																NumberSequenceKeypoint.new(0.38, 1),
																NumberSequenceKeypoint.new(0.5, 0.1),
																NumberSequenceKeypoint.new(0.62, 1),
																NumberSequenceKeypoint.new(1, 1),
															}),
														},
														Tags = { Utils_Motion = { Utils_MotionKind = "Sweep", Utils_MotionSpeed = 1 } },
													},
												},
											},
											{
												Primitive = "ImageLabel",
												Props = {
													Name = "Rim",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 2,
													Position = UDim2.fromScale(0.0115, 0.0143),
													Size = UDim2.fromScale(0.977, 0.9714),
													ZIndex = 27,
													Image = "rbxassetid://92579798166886",
													ScaleType = Enum.ScaleType.Fit,
												},
												Children = {
													{
														Primitive = "UIGradient",
														Props = {
															Color = ColorSequence.new({
																ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 110, 20)),
																ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 200, 60)),
																ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 240, 170)),
																ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 200, 60)),
																ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 110, 20)),
															}),
															Rotation = 45,
														},
														Tags = { Utils_Motion = { Utils_MotionKind = "Glint", Utils_MotionSpeed = 1 } },
													},
												},
											},
										},
									},
								},
							},
							-- The weapon's picture (set by the game)
							{
								Primitive = "ImageLabel",
								Id = "S_Icon",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.39),
									Size = UDim2.fromScale(0.66, 0.58),
									ZIndex = 28,
									Image = "rbxassetid://89888640314244",
									ScaleType = Enum.ScaleType.Fit,
								},
							},
							-- The weapon's model, turning (filled by the game, gilded when Golden as Combat gilds a held one); the picture shows until it's in
							{
								Primitive = "ViewportFrame",
								Id = "S_Model",
								Visible = false,
								Tags = { Utils_Motion = { Utils_MotionKind = "Turn", Utils_MotionAmount = 45 } },
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.4),
									Size = UDim2.fromScale(0.86, 0.62),
									ZIndex = 29,
									Ambient = Color3.fromRGB(150, 150, 158),
									LightColor = Color3.fromRGB(255, 250, 235),
									LightDirection = Vector3.new(-5, -9, 7),
								},
							},
							{
								Primitive = "TextLabel",
								Id = "S_CardName",
								Props = {
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.06, 0.705),
									Size = UDim2.fromScale(0.74, 0.18),
									ZIndex = 31,
									FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.ExtraBold, Enum.FontStyle.Italic),
									Text = "Bazooka",
									TextColor3 = Color3.fromRGB(255, 255, 255),
									RichText = true,
									TextScaled = true,
								},
								Children = {
									{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.07 } },
									{
										Primitive = "UIPadding",
										Props = {
											PaddingLeft = UDim.new(0.04, 0),
											PaddingRight = UDim.new(0.04, 0),
											PaddingTop = UDim.new(0.06, 0),
											PaddingBottom = UDim.new(0.06, 0),
										},
									},
									{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
								},
							},
							-- The level on a tag over the card's top, the crate card's BEST tag
							{
								Primitive = "Frame",
								Id = "S_LevelTag",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, -0.01),
									Rotation = -4,
									Size = UDim2.fromScale(0.44, 0.16),
									ZIndex = 32,
								},
								Children = {
									{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.3, 0) } },
									{ Primitive = "UIStroke", Props = { Color = Color3.fromRGB(20, 20, 28), Thickness = 3 } },
									{
										Primitive = "UIGradient",
										Id = "S_LevelTagGradient",
										Props = {
											Color = ColorSequence.new(Color3.fromRGB(255, 224, 102), Color3.fromRGB(255, 181, 31)),
											Rotation = 90,
										},
									},
									{
										Primitive = "TextLabel",
										Id = "S_LevelTagText",
										Tags = { TextCase_Upper = {} },
										Props = {
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											Position = UDim2.fromScale(0.1, 0.12),
											Size = UDim2.fromScale(0.8, 0.76),
											ZIndex = 33,
											FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
											Text = "Level 90",
											TextColor3 = Color3.fromRGB(255, 255, 255),
											RichText = true,
											TextScaled = true,
										},
										Children = {
											{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
											{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.07 } },
										},
									},
								},
							},
						},
					},
					-- SHINY! or GOLDEN!, slammed in under the card in LEVEL UP!'s look, its gradient the reward's (set by the game)
					{
						Primitive = "TextLabel",
						Id = "S_Title",
						Tags = { TextCase_Upper = {} },
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.705),
							Size = UDim2.fromScale(0.5, 0.12),
							ZIndex = 34,
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
							Text = "GOLDEN!",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							RichText = true,
							TextScaled = true,
						},
						Children = {
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
							{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.06 } },
							{
								Primitive = "UIGradient",
								Id = "S_TitleGradient",
								Props = {
									Color = ColorSequence.new({
										ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 246, 192)),
										ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 194, 26)),
										ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 138, 0)),
									}),
									Rotation = 90,
								},
							},
							{ Primitive = "UIScale", Id = "S_TitleScale", Props = { Scale = 1 } },
						},
					},
					-- What was unlocked, and what it does in a match
					{
						Primitive = "TextLabel",
						Id = "S_Name",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.785),
							Size = UDim2.fromScale(0.6, 0.055),
							ZIndex = 34,
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
							Text = "Golden Bazooka unlocked",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							RichText = true,
							TextScaled = true,
						},
						Children = {
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
							{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.07 } },
							{ Primitive = "UIScale", Id = "S_NameScale", Props = { Scale = 1 } },
						},
					},
					{
						Primitive = "TextLabel",
						Id = "S_Perk",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.835),
							Size = UDim2.fromScale(0.6, 0.036),
							ZIndex = 34,
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.ExtraBold, Enum.FontStyle.Italic),
							Text = "+5% damage, and the pros' solid gold in every match",
							TextColor3 = Color3.fromRGB(230, 232, 239),
							RichText = true,
							TextScaled = true,
						},
						Children = {
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
							{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.07 } },
							{ Primitive = "UIScale", Id = "S_PerkScale", Props = { Scale = 1 } },
						},
					},
					-- The crate opening's TAP TO OPEN, pulsing, once it's all in
					{
						Primitive = "TextLabel",
						Id = "S_Tap",
						Tags = { TextCase_Upper = {} },
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.915),
							Size = UDim2.fromScale(0.3, 0.042),
							ZIndex = 34,
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
							Text = "Tap to continue",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							RichText = true,
							TextScaled = true,
						},
						Children = {
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
							{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.07 } },
							{ Primitive = "UIScale", Tags = { Utils_Motion = { Utils_MotionKind = "Pulse" } }, Props = { Scale = 1 } },
						},
					},
					-- The reward's particles (the light drawn into the diamond, the bursts, the rising sparkles), over it all
					{
						Primitive = "Frame",
						Id = "S_Fx",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1, 1),
							ZIndex = 36,
						},
					},
					-- The white flash the diamond opens with
					{
						Primitive = "Frame",
						Id = "S_Flash",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(2, 2),
							ZIndex = 38,
						},
					},
				},
			},
		},
	},

	--[[ Templates ]]

	Templates = {
		-- One XP tile of the replay: the dialogs' dark panel, its picture on the left, the XP in gold and what it was for under it
		["PREFAB | XpLine"] = {
			Primitive = "Frame",
			Parent = "U_Plate",
			Props = {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0.3, 1),
				ZIndex = 7,
			},
			Children = {
				{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 2.3, DominantAxis = Enum.DominantAxis.Height } },
				{ Primitive = "UIScale", Id = "S_Scale", Props = { Scale = 1 } },
				{
					Primitive = "Frame",
					Props = {
						Name = "Card",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(25, 25, 35),
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
						ZIndex = 7,
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.22, 0) } },
						{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 2 } },
						{
							Primitive = "UIStroke",
							Tags = { Utils_UIStroke = {} },
							Props = {
								Name = "UIStroke_Inner",
								BorderStrokePosition = Enum.BorderStrokePosition.Inner,
								Color = Color3.fromRGB(130, 130, 130),
								Thickness = 3,
							},
						},
					},
				},
				-- The source's picture (set by the game, Progression's XP_ICONS), in a soft gold light
				{
					Primitive = "ImageLabel",
					Props = {
						Name = "Light",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.22, 0.5),
						Size = UDim2.fromScale(1.1, 1.1),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						ZIndex = 8,
						Image = "rbxassetid://124537809204603",
						ImageColor3 = Color3.fromRGB(255, 200, 80),
						ImageTransparency = 0.7,
					},
				},
				{
					Primitive = "ImageLabel",
					Id = "S_Icon",
					Props = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.22, 0.5),
						Size = UDim2.fromScale(0.62, 0.62),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						ZIndex = 9,
						Image = "rbxassetid://103399252005394",
						ScaleType = Enum.ScaleType.Fit,
					},
				},
				{
					Primitive = "TextLabel",
					Id = "S_Amount",
					Props = {
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.42, 0.4),
						Size = UDim2.fromScale(0.52, 0.46),
						ZIndex = 9,
						FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
						Text = "+50",
						TextColor3 = Color3.fromRGB(255, 210, 63),
						TextXAlignment = Enum.TextXAlignment.Left,
						RichText = true,
						TextScaled = true,
					},
					Children = {
						{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
						{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.07 } },
					},
				},
				{
					Primitive = "TextLabel",
					Id = "S_Label",
					Tags = { TextCase_Upper = {} },
					Props = {
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.42, 0.74),
						Size = UDim2.fromScale(0.52, 0.24),
						ZIndex = 9,
						FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
						Text = "Victory",
						TextColor3 = Color3.fromRGB(200, 200, 205),
						TextXAlignment = Enum.TextXAlignment.Left,
						RichText = true,
						TextScaled = true,
					},
					Children = {
						{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
						{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.07 } },
					},
				},
			},
		},
	},
}

return _gui
