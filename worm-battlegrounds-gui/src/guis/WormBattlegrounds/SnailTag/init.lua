--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	--[[
		A template: Snails clones it over every snail's head. The name and health bar are the studio's HUD design
		(World.Overhead, ported 1:1 on 2026-11-09); the turn marker, level and emote stay the theme's
	]]
	Name = "SnailTag",
	Kind = "Billboard",
	Theme = "WormBattlegroundsBrawl",
	-- The billboard's size at design scale: the tag's own, which code scales with the screen
	Preview = { Width = 240, Height = 240 },

	--[[ Tree ]]

	Root = {
		Primitive = "Frame",
		Id = "U_Tag",
		Props = { BackgroundTransparency = 1, Size = UDim2.fromOffset(240, 240) },
		Children = {
			-- Set with the billboard's size by ScreenScale, so the tag is as big for the screen as the hud
			{ Primitive = "UIScale", Id = "S_ScreenScale" },
			-- Stacks up from the billboard's bottom edge, the health bar nearest the snail
			{
				Control = "Stack",
				Align = "Center",
				Style = "None",
				Props = { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1) },
				Children = {
					-- Over the snail whose turn it is: a marker and the turn's seconds (hidden for its own player)
					{
						Control = "Stack",
						Id = "S_Active",
						Direction = "Horizontal",
						Align = "Center",
						Style = "None",
						Children = {
							{ Control = "Label", Id = "S_Timer", Text = "15", Style = "Strong" },
							{ Control = "Picture", Image = "chevron-small-down", Style = "Glyph" },
						},
					},
					{
						Control = "Label",
						Id = "S_Level",
						Text = "Level 12",
						Align = "Center",
						Style = { "Small", "Dim" },
					},
					-- The design's name over a health bar: name, bar outline and fill in the team's colour (gold name for VIP)
					{
						Primitive = "Frame",
						Props = {
							Name = "Overhead",
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Size = UDim2.fromOffset(240, 65),
						},
						Children = {
							{
								Primitive = "TextLabel",
								Id = "S_Name",
								Props = {
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 0,
									Size = UDim2.fromScale(1, 0.3692),
									Text = "TwentyOneCharacters",
									TextColor3 = Color3.fromRGB(77, 160, 255),
									TextSize = 20,
									TextWrapped = true,
									FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Bold, Enum.FontStyle.Italic),
									RichText = true,
									TextScaled = true,
								},
								Children = {
									{
										Primitive = "UIStroke",
										Props = {
											Thickness = 0.15,
											StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
										},
									},
								},
							},
							{
								Primitive = "Frame",
								Id = "S_Health",
								Props = {
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									LayoutOrder = 1,
									Position = UDim2.fromScale(0.072, 0.3846),
									Size = UDim2.fromScale(0.856, 0.6154),
									ZIndex = 2,
								},
								Children = {
									{
										Primitive = "Frame",
										Props = {
											Name = "Background",
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 0,
											Size = UDim2.fromScale(1, 1),
										},
										Children = {
											{
												Primitive = "ImageLabel",
												Props = {
													Name = "Main",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													LayoutOrder = 0,
													Position = UDim2.fromScale(0.0133, 0.125),
													Size = UDim2.fromScale(0.9735, 0.75),
													Image = "rbxassetid://109429734416947",
													ImageColor3 = Color3.fromRGB(25, 25, 35),
													ScaleType = Enum.ScaleType.Fit,
												},
											},
											{
												Primitive = "ImageLabel",
												Props = {
													Name = "Stroke2",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													ClipsDescendants = true,
													LayoutOrder = 1,
													Size = UDim2.fromScale(0.9951, 1),
													ZIndex = 2,
													Image = "rbxassetid://120012155004547",
													ImageColor3 = Color3.fromRGB(25, 25, 35),
													ScaleType = Enum.ScaleType.Fit,
												},
											},
											-- Tinted in the team's colour
											{
												Primitive = "ImageLabel",
												Props = {
													Name = "Stroke",
													BackgroundTransparency = 1,
													BorderSizePixel = 0,
													ClipsDescendants = true,
													LayoutOrder = 2,
													Position = UDim2.fromScale(0.0097, 0.05),
													Size = UDim2.fromScale(0.9805, 0.9),
													ZIndex = 3,
													Image = "rbxassetid://81786690142101",
													ImageColor3 = Color3.fromRGB(64, 140, 230),
													ScaleType = Enum.ScaleType.Fit,
												},
											},
										},
									},
									-- Tinted in the team's colour; its UIGradient cuts it at the health left, so the picture never squashes
									{
										Primitive = "ImageLabel",
										Id = "S_Fill",
										Props = {
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 1,
											Position = UDim2.fromScale(0.0383, 0.225),
											Size = UDim2.fromScale(0.9234, 0.55),
											ZIndex = 2,
											Image = "rbxassetid://78354089317839",
											ImageColor3 = Color3.fromRGB(77, 160, 255),
											ScaleType = Enum.ScaleType.Fit,
										},
										Children = {
											{ Primitive = "UIGradient", Props = {} },
										},
									},
									{
										Primitive = "TextLabel",
										Id = "S_HealthText",
										Props = {
											BackgroundTransparency = 1,
											BorderSizePixel = 0,
											LayoutOrder = 2,
											Position = UDim2.fromScale(0.0503, 0.2),
											Size = UDim2.fromScale(0.8994, 0.6),
											ZIndex = 3,
											Text = "100",
											TextColor3 = Color3.fromRGB(255, 255, 255),
											TextSize = 20,
											TextWrapped = true,
											FontFace = Font.new("rbxassetid://12187365977", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
											RichText = true,
											TextScaled = true,
										},
										Children = {
											{
												Primitive = "UIStroke",
												Props = {
													Thickness = 0.15,
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
			-- The emote playing, over the tag
			{
				Control = "Picture",
				Id = "S_Emote",
				Visible = false,
				Style = "Avatar",
				Props = { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 0) },
			},
		},
	},
}

return _gui
