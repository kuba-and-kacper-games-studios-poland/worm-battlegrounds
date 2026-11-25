--[[
	Created By: 	HungryN00B
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	--[[
		A template: the lobby's stage clones it over each snail standing on a pod, the player's level in the rank crest
		(the lobby's level bar's, 2026-11-25) and their display name over their @username (the studio's Nameplate,
		2026-11-24). It replaces the names on the
		party cards and the level plate at the top
	]]
	Name = "Nameplate",
	Kind = "Billboard",
	-- The billboard's size in studs on the stage (BillboardGui Size 6 × 1.1 studs, scaled with the snails by code)
	Preview = { Width = 600, Height = 110 },

	--[[ Tree ]]

	Root = {
		Primitive = "Frame",
		Id = "U_Nameplate",
		Props = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
		},
		Children = {
			{
				Primitive = "UIListLayout",
				Props = {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0.0133, 0),
				},
			},
			-- The level: the rank crest of the lobby's level bar and the XP replay (a rim in the tier's colours, set by code, round a dark middle)
			{
				Primitive = "Frame",
				Props = {
					Name = "LevelNumber",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 0,
					Size = UDim2.fromScale(0.6, 0.6),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
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
						},
						Children = {
							{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.16, 0) } },
							{
								Primitive = "UIStroke",
								Props = {
									Color = Color3.fromRGB(25, 25, 35),
									StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
									Thickness = 0.07,
								},
							},
							{
								Primitive = "UIGradient",
								Id = "S_LevelGradient",
								Props = {
									Color = ColorSequence.new(Color3.fromRGB(255, 170, 60), Color3.fromRGB(230, 120, 25)),
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
							ZIndex = 2,
						},
						Children = {
							{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(0.14, 0) } },
							{
								Primitive = "UIStroke",
								Props = {
									Color = Color3.fromRGB(25, 25, 35),
									StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
									Thickness = 0.06,
								},
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
						Id = "S_Level",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,

							-- A hair left of the middle: the italic digits lean right
							Position = UDim2.fromScale(0.49, 0.5),
							Size = UDim2.fromScale(0.42, 0.36),
							ZIndex = 3,
							Text = "1",
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextScaled = true,
							RichText = true,
						},
						Children = {
							{
								Primitive = "UIStroke",
								Props = { Thickness = 0.07, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize },
							},
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 100 } },
						},
					},
				},
			},
			-- The display name over the @username, as wide as they need
			{
				Primitive = "Frame",
				Props = {
					Name = "Names",
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 1,
					Size = UDim2.fromScale(0, 0.545),
					ZIndex = 2,
				},
				Children = {
					{ Primitive = "UIListLayout", Props = { SortOrder = Enum.SortOrder.LayoutOrder } },
					{
						Primitive = "TextLabel",
						Id = "S_Name",
						Props = {
							AutomaticSize = Enum.AutomaticSize.X,
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 0,
							Size = UDim2.fromScale(0, 0.6),
							Text = "DisplayName",
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Bold, Enum.FontStyle.Italic),
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextSize = 30,
							TextScaled = true,
							RichText = true,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
						},
						Children = {
							{
								Primitive = "UIStroke",
								Props = { Thickness = 0.07, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize },
							},
							{
								Primitive = "UIPadding",
								Props = { PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2) },
							},
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 60, MinTextSize = 6 } },
						},
					},
					{
						Primitive = "TextLabel",
						Id = "S_Username",
						Props = {
							AutomaticSize = Enum.AutomaticSize.X,
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 1,
							Size = UDim2.fromScale(0, 0.4),
							ZIndex = 2,
							Text = "@username",
							FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Bold, Enum.FontStyle.Italic),
							TextColor3 = Color3.fromRGB(200, 200, 205),
							TextSize = 20,
							TextScaled = true,
							RichText = true,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
						},
						Children = {
							{
								Primitive = "UIStroke",
								Props = { Thickness = 0.07, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize },
							},
							{
								Primitive = "UIPadding",
								Props = { PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2) },
							},
							{ Primitive = "UITextSizeConstraint", Props = { MaxTextSize = 40, MinTextSize = 6 } },
						},
					},
				},
			},
			{ Primitive = "UIAspectRatioConstraint", Props = { AspectRatio = 5.4545 } },
		},
	},
}

return _gui
