--[[
	Created By: 	HungryN00B
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The lobby's level plate at the top centre, and the replay of what the last matches gave over the lobby
	Name = "LevelPlate",
	-- The Lobby module turns it on with the lobby's other screens (LOBBY_GUIS); off on the match place
	Screen = { DisplayOrder = 3, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	Root = {
		Primitive = "Folder",
		Children = {
			-- The replay's backdrop: the lobby dims behind the plate while it plays
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
						},
					},
					-- The match's XP, one line each, popping in under the plate
					{
						Primitive = "Frame",
						Id = "S_Lines",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(0.3, 0.22),
							ZIndex = 3,
						},
						Children = {
							{
								Primitive = "UIListLayout",
								Props = {
									HorizontalAlignment = Enum.HorizontalAlignment.Center,
									Padding = UDim.new(0.04, 0),
									SortOrder = Enum.SortOrder.LayoutOrder,
								},
							},
						},
					},
					-- LEVEL UP!, in gold, over the plate
					{
						Primitive = "TextLabel",
						Id = "S_LevelUp",
						Tags = { TextCase_Upper = {} },
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.19),
							Size = UDim2.fromScale(0.5, 0.12),
							ZIndex = 6,
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
							Text = "LEVEL UP!",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							RichText = true,
							TextScaled = true,
						},
						Children = {
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
							{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.08 } },
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
					-- What the level opened: a frame, an emote, a skin
					{
						Primitive = "Frame",
						Id = "S_Reward",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(25, 25, 35),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.82),
							Size = UDim2.fromScale(0.34, 0.075),
							ZIndex = 6,
						},
						Children = {
							{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.25, 0) } },
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
								Primitive = "TextLabel",
								Id = "S_RewardText",
								Tags = { TextCase_Upper = {} },
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(0.9, 0.62),
									ZIndex = 7,
									FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
									Text = "NEW FRAME: SILVER",
									TextColor3 = Color3.fromRGB(255, 255, 255),
									RichText = true,
									TextScaled = true,
								},
								Children = {
									{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
									{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.1 } },
								},
							},
							{ Primitive = "UIScale", Id = "S_RewardScale", Props = { Scale = 0 } },
						},
					},
					-- The replay's particles (sparks into the bar, the level-up burst) are drawn here, over everything
					{
						Primitive = "Frame",
						Id = "S_Particles",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1, 1),
							ZIndex = 8,
						},
					},
				},
			},
			-- The plate (the currency slots' plate): the level in a diamond in the player's frame colour on its left end, LEVEL and the XP bar in it, the next unlock under it
			{
				Primitive = "Frame",
				Id = "U_Plate",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0.018),
					Size = UDim2.fromScale(0.125, 0.085),
					ZIndex = 5,
				},
				Children = {
					{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 2.6017 } },
					{ Primitive = "UIScale", Id = "S_Pop", Props = { Scale = 1 } },
					-- The currency slots' dark slanted plate, over the top 72 % (the next unlock under it)
					{
						Primitive = "Frame",
						Props = { Name = "Background", BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 0, Size = UDim2.fromScale(1, 0.72), ZIndex = 5 },
						Children = {
							{
								Primitive = "ImageLabel",
								Props = {
									Name = "Main",
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 0,
									Position = UDim2.fromScale(0.0034, 0.061),
									Size = UDim2.fromScale(0.9931, 0.878),
									ZIndex = 5,
									Image = "rbxassetid://132693594544527",
									ImageColor3 = Color3.fromRGB(25, 25, 35),
									ScaleType = Enum.ScaleType.Fit,
								},
								Attributes = { _ImageName = "1018_489__Gacha__Main_gray" },
							},
							{
								Primitive = "ImageLabel",
								Props = {
									Name = "Stroke2",
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									ClipsDescendants = true,
									LayoutOrder = 1,
									Size = UDim2.fromScale(1, 1),
									ZIndex = 5,
									Image = "rbxassetid://110464716728942",
									ImageColor3 = Color3.fromRGB(25, 25, 35),
									ScaleType = Enum.ScaleType.Fit,
								},
								Attributes = { _ImageName = "1126_52__Gacha__Stroke2_gray" },
							},
							{
								Primitive = "ImageLabel",
								Props = {
									Name = "Stroke",
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									ClipsDescendants = true,
									LayoutOrder = 2,
									Position = UDim2.fromScale(0.0068, 0.0244),
									Size = UDim2.fromScale(0.9865, 0.9512),
									ZIndex = 5,
									Image = "rbxassetid://129410270943519",
									ImageColor3 = Color3.fromRGB(130, 130, 130),
									ScaleType = Enum.ScaleType.Fit,
								},
								Attributes = { _ImageName = "1126_53__Gacha__Stroke_gray" },
							},
						},
					},
					-- The diamond: a square turned 45°, the frame's colours on its fill, the level over it, standing on the plate's left end as the coin does
					{
						Primitive = "Frame",
						Id = "S_Badge",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.16, 0.36),
							Size = UDim2.fromScale(0.86, 0.86),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							ZIndex = 6,
						},
						Children = {
							{
								Primitive = "Frame",
								Id = "S_Diamond",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.5),
									Rotation = 45,
									Size = UDim2.fromScale(0.68, 0.68),
									ZIndex = 6,
								},
								Children = {
									{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.2, 0) } },
									{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Color = Color3.fromRGB(25, 25, 35), Thickness = 3 } },
									{
										Primitive = "UIGradient",
										Id = "S_TierGradient",
										Props = {
											Color = ColorSequence.new(Color3.fromRGB(150, 150, 165), Color3.fromRGB(70, 70, 82)),
											Rotation = 45,
										},
									},
								},
							},
							{
								Primitive = "TextLabel",
								Id = "S_LevelNum",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.5, 0.52),
									Size = UDim2.fromScale(0.6, 0.44),
									ZIndex = 7,
									FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
									Text = "14",
									TextColor3 = Color3.fromRGB(255, 255, 255),
									RichText = true,
									TextScaled = true,
								},
								Children = {
									{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
									{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.12 } },
								},
							},
						},
					},
					-- LEVEL n, in the plate's top half
					{
						Primitive = "TextLabel",
						Id = "S_Title",
						Tags = { TextCase_Upper = {} },
						Props = {
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.3, 0.09),
							Size = UDim2.fromScale(0.6, 0.26),
							ZIndex = 6,
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
							Text = "LEVEL 14",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextXAlignment = Enum.TextXAlignment.Left,
							RichText = true,
							TextScaled = true,
						},
						Children = {
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
							{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.1 } },
						},
					},
					-- The bar, in the plate's bottom half: a dark slot with the grey line, the gold fill, a glow riding its end while it fills
					{
						Primitive = "Frame",
						Id = "S_Track",
						Props = {
							BackgroundColor3 = Color3.fromRGB(13, 13, 20),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.3, 0.39),
							Size = UDim2.fromScale(0.6, 0.2),
							ZIndex = 6,
						},
						Children = {
							{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
							{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Color = Color3.fromRGB(130, 130, 130), Thickness = 2 } },
							{
								Primitive = "Frame",
								Id = "S_Fill",
								Props = {
									AnchorPoint = Vector2.new(0, 0.5),
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0, 0.5),
									Size = UDim2.fromScale(0.38, 1),
									ZIndex = 7,
								},
								Children = {
									{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
									{
										Primitive = "UIGradient",
										Props = {
											Color = ColorSequence.new({
												ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 226, 122)),
												ColorSequenceKeypoint.new(0.55, Color3.fromRGB(255, 176, 0)),
												ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 138, 0)),
											}),
											Rotation = 90,
										},
									},
								},
							},
							{
								Primitive = "ImageLabel",
								Id = "S_Head",
								Props = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									Position = UDim2.fromScale(0.38, 0.5),
									Size = UDim2.fromScale(2.6, 2.6),
									SizeConstraint = Enum.SizeConstraint.RelativeYY,
									ZIndex = 9,
									Image = "rbxassetid://124537809204603",
									ImageColor3 = Color3.fromRGB(255, 240, 190),
									ImageTransparency = 1,
								},
							},
						},
					},
					-- The XP into the level, written over the bar
					{
						Primitive = "TextLabel",
						Id = "S_Xp",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.6, 0.49),
							Size = UDim2.fromScale(0.56, 0.17),
							ZIndex = 10,
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
							Text = "60 / 156 XP",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							RichText = true,
							TextScaled = true,
						},
						Children = {
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
							{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.14 } },
						},
					},
					-- What the next level opens, under the plate as the turn timer's banner is under its plate
					{
						Primitive = "TextLabel",
						Id = "S_Next",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.5, 0.75),
							Size = UDim2.fromScale(1.3, 0.22),
							ZIndex = 6,
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
							Text = "Next unlock: Silver frame at level 15",
							TextColor3 = Color3.fromRGB(255, 233, 168),
							RichText = true,
							TextScaled = true,
						},
						Children = {
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
							{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.12 } },
						},
					},
				},
			},
		},
	},

	--[[ Templates ]]

	Templates = {
		-- One XP line of the replay: what it was for on the left, the XP in gold on the right
		["PREFAB | XpLine"] = {
			Primitive = "Frame",
			Parent = "U_Replay",
			Props = {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 0.26),
				ZIndex = 4,
			},
			Children = {
				{ Primitive = "UIScale", Id = "S_Scale", Props = { Scale = 1 } },
				{
					Primitive = "TextLabel",
					Id = "S_Label",
					Props = {
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0, 0.5),
						Size = UDim2.fromScale(0.72, 1),
						ZIndex = 4,
						FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
						Text = "Victory",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextXAlignment = Enum.TextXAlignment.Left,
						RichText = true,
						TextScaled = true,
					},
					Children = {
						{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
						{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.1 } },
					},
				},
				{
					Primitive = "TextLabel",
					Id = "S_Amount",
					Props = {
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.fromScale(1, 0.5),
						Size = UDim2.fromScale(0.28, 1),
						ZIndex = 4,
						FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
						Text = "+50",
						TextColor3 = Color3.fromRGB(255, 210, 63),
						TextXAlignment = Enum.TextXAlignment.Right,
						RichText = true,
						TextScaled = true,
					},
					Children = {
						{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
						{ Primitive = "UIStroke", Props = { StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize, Thickness = 0.1 } },
					},
				},
			},
		},
	},
}

return _gui
