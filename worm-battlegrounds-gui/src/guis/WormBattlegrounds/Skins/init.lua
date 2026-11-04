--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- Cosmetics draws it on WidgetManager_Opened as I.UserInterface.UI["Skins"]
	Name = "Skins",
	Theme = "WormBattlegroundsBrawl",
	Screen = { DisplayOrder = 1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- The worm skins the player owns, each in a 3D preview
	Root = {
		Control = "Widget",
		Id = "U_Widget",
		Title = "Skins",
		Style = "Large",
		Children = {
			-- Owned skins (PREFAB | SkinTile)
			{ Control = "Cells", Id = "U_Skins", Style = "Tiles" },
		},
	},

	--[[ Prefabs ]]

	Templates = {
		-- A skin: Cosmetics puts the worm model in S_Preview's ViewportFrame; Equip (Equipped when worn)
		["PREFAB | SkinTile"] = {
			Control = "Box",
			Parent = "U_Skins",
			Style = "Fixed",
			Children = {
				{ Control = "Viewport", Id = "S_Preview", Text = "Classic", Subtext = "3 / 10 to shiny" },
				-- Blue: a grid of skins has no one next step
				{ Control = "Button", Id = "S_Equip", Text = "Equip", Style = "Small" },
			},
		},
	},
}

return _gui
