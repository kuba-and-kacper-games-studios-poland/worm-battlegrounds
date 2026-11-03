--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The exported ScreenGui's name: ume's Notify module finds it as I.UserInterface.UI["Notify"]
	Name = "Notify",
	-- Drawn under the game's other guis. Built disabled; the UserInterface server enables it at start (PreventHiding)
	Screen = {
		DisplayOrder = -1,
		Enabled = false,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
	},
	ScreenTags = { UserInterface_PreventHiding = {} },

	--[[ Tree ]]

	-- Two stacks Notify fills with prefab clones: short notifications above the bottom edge, chat-style messages below
	-- the top edge. Plain instances that hold every value themselves, so no theme changes them
	Root = {
		Primitive = "Folder",
		Children = {
			-- Notifications, newest at the bottom
			{
				Primitive = "Frame",
				Id = "U_Container-Notification",
				Props = { AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.9), Size = UDim2.fromScale(0.6, 0.035) },
				Children = {
					{
						Primitive = "UIListLayout",
						Props = { Name = "ContainerLayout", HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom },
					},
				},
			},
			-- Messages, from the top down
			{
				Primitive = "Frame",
				Id = "U_Container-Message",
				Props = { AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.1), Size = UDim2.fromScale(0.6, 0.06) },
				Children = {
					{ Primitive = "UIListLayout", Props = { Name = "ContainerLayout", HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder } },
				},
			},
		},
	},

	--[[ Templates ]]

	Templates = {
		-- One notification line: Notify writes the text and colors its gradient (I.Gradient)
		["PREFAB | Notification"] = {
			Primitive = "Frame",
			Parent = "U_Container-Notification",
			Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
			Children = {
				{
					Primitive = "TextLabel",
					Id = "S_MessageText",
					Props = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Heavy),
						Position = UDim2.fromScale(0.5, 0.5),
						RichText = true,
						Size = UDim2.fromScale(1, 1),
						Text = "Notification Text ",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						TextWrapped = true,
					},
					Children = {
						{ Primitive = "UIGradient", Props = { Rotation = -90 } },
						{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 1.5 } },
					},
				},
				{ Primitive = "UIScale" },
			},
		},
		-- One message: the sender's headshot, then the text, over a band that fades out at both ends
		["PREFAB | Message"] = {
			Primitive = "Frame",
			Parent = "U_Container-Message",
			Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
			Children = {
				{
					Primitive = "Frame",
					Props = { Name = "Content", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), ZIndex = 2 },
					Children = {
						{
							Primitive = "UIListLayout",
							Props = {
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							},
						},
						{
							Primitive = "Frame",
							Props = { Name = "UserIconContainer", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, LayoutOrder = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.75, 0.75) },
							Children = {
								{ Primitive = "UIAspectRatioConstraint" },
								{
									Primitive = "ImageLabel",
									Id = "S_UserIcon",
									Props = {
										AnchorPoint = Vector2.new(0.5, 0.5),
										BackgroundColor3 = Color3.fromRGB(0, 0, 0),
										BackgroundTransparency = 0.5,
										BorderSizePixel = 0,
										Image = "rbxthumb://type=AvatarHeadShot&id=1&w=180&h=180",
										Position = UDim2.fromScale(0.5, 0.5),
										Size = UDim2.fromScale(1, 1),
									},
									Children = {
										{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
										{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 2, Transparency = 0.5 } },
										{ Primitive = "UIScale" },
									},
								},
							},
						},
						{
							Primitive = "Frame",
							Props = {
								Name = "MessageTextContainer",
								AutomaticSize = Enum.AutomaticSize.X,
								BackgroundTransparency = 1,
								LayoutOrder = 3,
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(0, 0.75),
							},
							Children = {
								{
									Primitive = "TextLabel",
									Id = "S_MessageText",
									Props = {
										AnchorPoint = Vector2.new(0, 0.5),
										AutomaticSize = Enum.AutomaticSize.X,
										BackgroundTransparency = 1,
										FontFace = Font.new("rbxassetid://12188570269", Enum.FontWeight.Heavy),
										LayoutOrder = 2,
										Position = UDim2.fromScale(0, 0.5),
										RichText = true,
										Size = UDim2.fromScale(0, 1),
										Text = "@username: message",
										TextColor3 = Color3.fromRGB(255, 255, 255),
										TextScaled = true,
										TextSize = 14,
										TextWrapped = true,
									},
									Children = {
										{ Primitive = "UIScale" },
										{ Primitive = "UIStroke", Tags = { Utils_UIStroke = {} }, Props = { Thickness = 1.5 } },
									},
								},
							},
						},
						{
							Primitive = "Frame",
							Props = { Name = "2 | Padding", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, LayoutOrder = 2, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1) },
							Children = {
								{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 0.125 } },
							},
						},
					},
				},
				{
					Primitive = "Frame",
					Id = "S_Background",
					Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(25, 40, 60), BorderSizePixel = 0, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 0.9) },
					Children = {
						{
							Primitive = "UIGradient",
							Props = {
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 1),
									NumberSequenceKeypoint.new(0.1, 0.9),
									NumberSequenceKeypoint.new(0.5, 0.5),
									NumberSequenceKeypoint.new(0.9, 0.9),
									NumberSequenceKeypoint.new(1, 1),
								}),
							},
						},
					},
				},
				{ Primitive = "UIScale" },
			},
		},
	},
}

return _gui
