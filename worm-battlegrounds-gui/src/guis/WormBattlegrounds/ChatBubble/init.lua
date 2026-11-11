--[[
	Created By: 	HungryN00B
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	--[[
		A template: ChatBubbles clones it over a snail whose player chats, in a match or on the lobby's stage, and stacks
		a bubble per message in it (the owner's pick, 2026-11-10: style B, a white rounded bubble with an ink outline
		and a tail)
	]]
	Name = "ChatBubble",
	Kind = "Billboard",
	Theme = "WormBattlegroundsBrawl",
	-- The billboard's size at design scale, scaled with the screen by code: room for three long messages
	Preview = { Width = 260, Height = 600 },

	--[[ Tree ]]

	Root = {
		Primitive = "Frame",
		Id = "U_Bubbles",
		Props = {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(260, 600),
		},
		Children = {
			-- Set with the billboard's size by ScreenScale
			{ Primitive = "UIScale", Id = "S_ScreenScale" },
			-- The bubbles stack up from the bottom, the newest lowest; code lifts them over the snail's tag here
			{ Primitive = "UIPadding", Id = "S_Clearance" },
			{
				Primitive = "UIListLayout",
				Props = {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Bottom,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 4),
				},
			},
		},
	},

	--[[ Prefabs ]]

	Templates = {
		--[[
			One message: the body sized to its text by code, and under the newest one the tail, a square on its corner
			half hidden behind the body, whose outline runs on from the body's through the joint
		]]
		["PREFAB | Bubble"] = {
			Parent = "U_Bubbles",
			Primitive = "Frame",
			Props = {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(104, 49),
			},
			Children = {
				-- Pops the bubble in from its tail
				{ Primitive = "UIScale", Id = "S_Pop" },
				{
					Primitive = "Frame",
					Id = "S_Tail",
					Props = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						Position = UDim2.new(0.5, 0, 1, -12),
						Rotation = 45,
						Size = UDim2.fromOffset(10, 10),
						ZIndex = 1,
					},
					Children = {
						{
							Primitive = "UIStroke",
							Props = { Color = Color3.fromRGB(25, 25, 42), Thickness = 3 },
						},
					},
				},
				-- Bottom edge 12 px over the bubble's, the room the tail takes; 3 px when it has no tail
				{
					Primitive = "Frame",
					Id = "S_Body",
					Props = {
						AnchorPoint = Vector2.new(0.5, 1),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						Position = UDim2.new(0.5, 0, 1, -12),
						Size = UDim2.fromOffset(98, 34),
						ZIndex = 2,
					},
					Children = {
						{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0, 14) } },
						{
							Primitive = "UIStroke",
							Props = { Color = Color3.fromRGB(25, 25, 42), Thickness = 3 },
						},
						-- Measured at its TextSize, 170 px wide at most, by code
						{
							Primitive = "TextLabel",
							Id = "S_Text",
							Props = {
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								Size = UDim2.fromScale(1, 1),
								ZIndex = 3,
								Text = "Nice shot!",
								TextColor3 = Color3.fromRGB(25, 25, 42),
								TextSize = 17,
								TextWrapped = true,
								FontFace = Font.new("rbxassetid://113086061264643", Enum.FontWeight.Heavy, Enum.FontStyle.Normal),
								RichText = true,
								TextScaled = true,
							},
							Children = {
								{
									Primitive = "UIPadding",
									Props = {
										PaddingTop = UDim.new(0, 7),
										PaddingBottom = UDim.new(0, 7),
										PaddingLeft = UDim.new(0, 12),
										PaddingRight = UDim.new(0, 12),
									},
								},
								-- In screen pixels, so it grows with the screen's scale: the box holds the design size
								{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
							},
						},
						-- A picture in place of the text (an emote's icon), shown by code
						{
							Primitive = "ImageLabel",
							Id = "S_Icon",
							Props = {
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.new(1, -8, 1, -8),
								ZIndex = 3,
								ScaleType = Enum.ScaleType.Fit,
								Visible = false,
							},
						},
					},
				},
				-- Covers the body's outline where the tail meets it
				{
					Primitive = "Frame",
					Id = "S_Joint",
					Props = {
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						Position = UDim2.new(0.5, 0, 1, -13),
						Size = UDim2.fromOffset(8, 4),
						ZIndex = 3,
					},
				},
			},
		},
		--[[
			An emote's icon in a thought cloud (the owner, 2026-11-11, from Worms' thought bubble): white puffs with the
			bubbles' ink outline round them all, the icon in the middle, and under the newest a trail of two puffs down to
			the snail's head. The outline is the same puffs 3 px bigger in ink behind the white ones, so it runs only round
			the cloud's edge
		]]
		["PREFAB | Thought"] = {
			Parent = "U_Bubbles",
			Primitive = "Frame",
			Props = {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(96, 104),
			},
			Children = {
				-- Pops the cloud in from its trail
				{ Primitive = "UIScale", Id = "S_Pop" },
				{
					Primitive = "Frame",
					Props = { Name = "Cloud", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromOffset(96, 72) },
					Children = {
						-- The ink behind: each puff 6 px bigger
						{
							Primitive = "Frame",
							Props = {
								Name = "Ink",
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = Color3.fromRGB(25, 25, 42),
								BorderSizePixel = 0,
								Position = UDim2.fromOffset(48, 48),
								Size = UDim2.fromOffset(90, 46),
								ZIndex = 1,
							},
							Children = { { Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } } },
						},
						{
							Primitive = "Frame",
							Props = {
								Name = "Ink",
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = Color3.fromRGB(25, 25, 42),
								BorderSizePixel = 0,
								Position = UDim2.fromOffset(28, 34),
								Size = UDim2.fromOffset(40, 40),
								ZIndex = 1,
							},
							Children = { { Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } } },
						},
						{
							Primitive = "Frame",
							Props = {
								Name = "Ink",
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = Color3.fromRGB(25, 25, 42),
								BorderSizePixel = 0,
								Position = UDim2.fromOffset(50, 25),
								Size = UDim2.fromOffset(48, 48),
								ZIndex = 1,
							},
							Children = { { Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } } },
						},
						{
							Primitive = "Frame",
							Props = {
								Name = "Ink",
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = Color3.fromRGB(25, 25, 42),
								BorderSizePixel = 0,
								Position = UDim2.fromOffset(72, 33),
								Size = UDim2.fromOffset(38, 38),
								ZIndex = 1,
							},
							Children = { { Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } } },
						},
						-- The white puffs: a long one along the bottom and three over it
						{
							Primitive = "Frame",
							Props = {
								Name = "Puff",
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BorderSizePixel = 0,
								Position = UDim2.fromOffset(48, 48),
								Size = UDim2.fromOffset(84, 40),
								ZIndex = 2,
							},
							Children = { { Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } } },
						},
						{
							Primitive = "Frame",
							Props = {
								Name = "Puff",
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BorderSizePixel = 0,
								Position = UDim2.fromOffset(28, 34),
								Size = UDim2.fromOffset(34, 34),
								ZIndex = 2,
							},
							Children = { { Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } } },
						},
						{
							Primitive = "Frame",
							Props = {
								Name = "Puff",
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BorderSizePixel = 0,
								Position = UDim2.fromOffset(50, 25),
								Size = UDim2.fromOffset(42, 42),
								ZIndex = 2,
							},
							Children = { { Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } } },
						},
						{
							Primitive = "Frame",
							Props = {
								Name = "Puff",
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BorderSizePixel = 0,
								Position = UDim2.fromOffset(72, 33),
								Size = UDim2.fromOffset(32, 32),
								ZIndex = 2,
							},
							Children = { { Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } } },
						},
						-- The emote's icon, set by code
						{
							Primitive = "ImageLabel",
							Id = "S_Icon",
							Props = {
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								Position = UDim2.fromOffset(48, 42),
								Size = UDim2.fromOffset(44, 44),
								ZIndex = 3,
								ScaleType = Enum.ScaleType.Fit,
							},
						},
					},
				},
				-- Two small puffs down to the snail's head, under the newest cloud only
				{
					Primitive = "Frame",
					Id = "S_Trail",
					Props = { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
					Children = {
						{
							Primitive = "Frame",
							Props = {
								Name = "Puff",
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BorderSizePixel = 0,
								Position = UDim2.fromOffset(44, 82),
								Size = UDim2.fromOffset(14, 14),
								ZIndex = 2,
							},
							Children = {
								{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
								{ Primitive = "UIStroke", Props = { Color = Color3.fromRGB(25, 25, 42), Thickness = 3 } },
							},
						},
						{
							Primitive = "Frame",
							Props = {
								Name = "Puff",
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BorderSizePixel = 0,
								Position = UDim2.fromOffset(37, 97),
								Size = UDim2.fromOffset(8, 8),
								ZIndex = 2,
							},
							Children = {
								{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
								{ Primitive = "UIStroke", Props = { Color = Color3.fromRGB(25, 25, 42), Thickness = 3 } },
							},
						},
					},
				},
			},
		},
	},
}

return _gui
