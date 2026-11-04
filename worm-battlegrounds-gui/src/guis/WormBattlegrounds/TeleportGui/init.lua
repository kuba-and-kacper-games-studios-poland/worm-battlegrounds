--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- ume's Teleport clones it from ServerStorage.Ume.UtilityGuis into each teleported player's PlayerGui
	Name = "TeleportGui",
	Theme = "WormBattlegrounds",
	-- Shown as soon as it's cloned, over everything, edge to edge
	Screen = { DisplayOrder = 100, Enabled = true, ResetOnSpawn = false, ScreenInsets = Enum.ScreenInsets.None },

	--[[ Tree ]]

	Root = {
		Primitive = "Folder",
		Children = {
			-- Covers the game while the teleport happens
			{
				Primitive = "Frame",
				Id = "U_Backdrop",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(38, 34, 62),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
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
					Size = UDim2.fromOffset(560, 0),
				},
				Children = {
					{ Control = "Picture", Id = "S_Image", Style = "Thumbnail" },
					-- "Heading to the match…" or "Back to the lobby…"
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
}

return _gui
