--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The exported ScreenGui's name: the game's main hud, found as I.UserInterface.UI["Main"]
	Name = "Main",
	-- The game's main hud, under every other gui, shown from the start (PreventHiding)
	Screen = { DisplayOrder = -999, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },
	ScreenTags = { UserInterface_PreventHiding = {} },

	--[[ Tree ]]

	-- Empty: a game adds its own corners and buttons in its copy. The root is a Folder, so they go straight into the
	-- exported ScreenGui
	Root = {
		Primitive = "Folder",
		Children = {},
	},
}

return _gui
