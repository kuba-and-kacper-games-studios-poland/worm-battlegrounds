--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The exported ScreenGui's name: ume's Currency slots find it as I.UserInterface.UI["Currency"]
	Name = "Currency",
	-- Drawn under the game's other guis. Built disabled; the UserInterface server enables it at start (PreventHiding)
	Screen = {
		DisplayOrder = -999,
		Enabled = false,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
	},
	ScreenTags = { UserInterface_PreventHiding = {} },

	--[[ Tree ]]

	-- The area currency orbs fly in: a Currency slot with SpawnOrbs on emits its orbs here
	Root = {
		Primitive = "Frame",
		Id = "U_OrbsContainer",
		Props = { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.8, 0.8) },
	},
}

return _gui
