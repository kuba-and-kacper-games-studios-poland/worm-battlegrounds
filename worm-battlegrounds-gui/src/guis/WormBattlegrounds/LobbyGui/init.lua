--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- ume's transit lobby moves it from ServerStorage.Ume.UtilityGuis to ReplicatedFirst, shown during the hop
	Name = "LobbyGui",
	Theme = "WormBattlegrounds",
	Screen = { DisplayOrder = 100, Enabled = true, ResetOnSpawn = false, ScreenInsets = Enum.ScreenInsets.None },

	--[[ Tree ]]

	-- TeleportGui's card, for the transit hop
	Root = {
		Primitive = "Folder",
		Children = {
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
					{
						Control = "Label",
						Id = "S_Text",
						Text = "Getting things ready…",
						Align = "Center",
						Style = "Title",
					},
				},
			},
		},
	},
}

return _gui
