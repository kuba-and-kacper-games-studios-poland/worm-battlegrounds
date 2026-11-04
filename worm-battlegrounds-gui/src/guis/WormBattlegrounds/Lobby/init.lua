--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The Lobby module turns it on, on the Lobby map, as I.UserInterface.UI["Lobby"]
	Name = "Lobby",
	Theme = "WormBattlegroundsBrawl",
	-- Under every other gui, over the whole screen
	Screen = { DisplayOrder = -1000, Enabled = false, ScreenInsets = Enum.ScreenInsets.None },

	--[[ Tree ]]

	Root = {
		Primitive = "Folder",
		Children = {
			-- The flat illustrated background; the art replaces the plain sky colour
			{
				Primitive = "ImageLabel",
				Id = "U_Background",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(110, 190, 240),
					BorderSizePixel = 0,
					Image = "",
					Position = UDim2.fromScale(0.5, 0.5),
					ScaleType = Enum.ScaleType.Crop,
					Size = UDim2.fromScale(1, 1),
				},
			},
			-- The tutorial's arrow layer: Tutorial moves S_Arrow over what the player should press
			{
				Primitive = "Frame",
				Id = "U_Pointer",
				Props = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					ZIndex = 10,
				},
				Children = {
					{
						Control = "Picture",
						Id = "S_Arrow",
						Image = "chevron-small-down",
						Style = "Glyph",
						Visible = false,
					},
				},
			},
		},
	},
}

return _gui
