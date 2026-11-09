--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	--[[
		A template: Snails clones it where a snail is hit, rises and fades it (only with the DamageNumbers setting on).
		The studio's HUD design (World.Damage, ported 1:1 on 2026-11-09): a yellow-to-red number over its shadow
	]]
	Name = "DamagePop",
	Kind = "Billboard",
	Theme = "WormBattlegroundsBrawl",
	-- The billboard's size at design scale, scaled with the screen by code
	Preview = { Width = 180, Height = 82 },

	--[[ Tree ]]

	Root = {
		Primitive = "Frame",
		Id = "U_Pop",
		Props = {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(180, 82),
		},
		Children = {
			-- Set with the billboard's size by ScreenScale
			{ Primitive = "UIScale", Id = "S_ScreenScale" },
			{
				Primitive = "TextLabel",
				Id = "S_Shadow",
				Props = {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 0,
					Position = UDim2.fromScale(0, 0.0732),
					Size = UDim2.fromScale(1, 0.9268),
					Text = "-35",
					TextColor3 = Color3.fromRGB(0, 0, 0),
					TextTransparency = 0.6,
					TextSize = 76,
					TextWrapped = true,
					FontFace = Font.new("rbxasset://fonts/families/LuckiestGuy.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
					RichText = true,
					TextScaled = true,
				},
				Children = {
					{
						Primitive = "UIStroke",
						Props = {
							Thickness = 0.0789,
							Transparency = 0.6,
							StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
						},
					},
				},
			},
			{
				Primitive = "TextLabel",
				Id = "S_Amount",
				Props = {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 1,
					Size = UDim2.fromScale(1, 0.9268),
					ZIndex = 2,
					Text = "-35",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 76,
					TextWrapped = true,
					FontFace = Font.new("rbxasset://fonts/families/LuckiestGuy.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
					RichText = true,
					TextScaled = true,
				},
				Children = {
					{
						Primitive = "UIStroke",
						Props = {
							Thickness = 0.0789,
							StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
						},
					},
					{
						Primitive = "UIGradient",
						Props = {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 242, 122)),
								ColorSequenceKeypoint.new(0.035, Color3.fromRGB(255, 242, 122)),
								ColorSequenceKeypoint.new(0.353, Color3.fromRGB(255, 161, 46)),
								ColorSequenceKeypoint.new(0.67, Color3.fromRGB(255, 61, 46)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 61, 46)),
							}),
							Rotation = 90,
						},
					},
				},
			},
		},
	},
}

return _gui
