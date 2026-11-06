--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- ume's Teleport clones it from ServerStorage.Ume.UtilityGuis into each teleported player's PlayerGui
	Name = "TeleportGui",
	Theme = "WormBattlegroundsBrawl",
	-- Shown as soon as it's cloned, over everything, edge to edge
	Screen = { DisplayOrder = 100, Enabled = true, ResetOnSpawn = false, ScreenInsets = Enum.ScreenInsets.None },

	--[[ Tree ]]

	Root = {
		Primitive = "Folder",
		Children = {
			-- Covers the game while the teleport happens; the Transition module slides it, card and all
			{
				Primitive = "Frame",
				Id = "U_Backdrop",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
				},
				Children = {
					-- The sea gradient from the kit's library, top to bottom
					{
						Primitive = "UIGradient",
						Props = {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 74, 90)),
								ColorSequenceKeypoint.new(0.5, Color3.fromRGB(23, 105, 122)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(42, 138, 150)),
							}),
							Rotation = 90,
						},
					},
					{
						Control = "Box",
						Id = "U_Card",
						Screen = true,
						Style = "Panel",
						Props = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromOffset(720, 0),
						},
						Children = {
							{ Control = "Picture", Id = "S_Image", Style = "Thumbnail" },
							-- "Heading to <map>…", "Back to the lobby…"
							{
								Control = "Label",
								Id = "S_Text",
								Text = "Heading to the match…",
								Align = "Center",
								Style = "Title",
							},
						},
					},
				},
			},
			-- ume's Teleport waits this long after showing the card, so its slide plays before the teleport
			{ Primitive = "NumberValue", Props = { Name = "GuiAnimDuration", Value = 0.45 } },
		},
	},
}

return _gui
