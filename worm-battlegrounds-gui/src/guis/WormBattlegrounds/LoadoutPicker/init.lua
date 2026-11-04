--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- Loadout draws it on WidgetManager_Opened as I.UserInterface.UI["LoadoutPicker"]
	Name = "LoadoutPicker",
	Theme = "WormBattlegrounds",
	Screen = { DisplayOrder = 1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- Every weapon and utility the player owns, to put in the slot that opened it
	Root = {
		Control = "Widget",
		Id = "U_Widget",
		Title = "Pick an item",
		Style = "Large",
		Children = {
			{
				Control = "Label",
				Id = "S_Slot",
				Text = "Slot 2: tap an item to put it in. Each item fits one slot.",
				Align = "Center",
				Style = "Dim",
			},
			-- Owned items (PREFAB | ItemTile); items already in another slot are greyed out
			{ Control = "Cells", Id = "U_Items", Style = "Grid" },
			{ Control = "Button", Id = "S_Empty", Text = "Empty slot", Style = "Danger" },
		},
	},

	--[[ Prefabs ]]

	Templates = {
		-- An owned item: icon, name, uses and cooldown, rarity (outline and corner), copies to shiny. HoverInfo shows its details
		["PREFAB | ItemTile"] = {
			Control = "Item",
			Parent = "U_Items",
			Text = "Grenade",
			Subtext = "3 uses · 1 turn cooldown",
			Children = {
				{
					Control = "Label",
					Id = "S_Rarity",
					Text = "Rare",
					Style = "Small",
					Props = { Position = UDim2.fromOffset(10, 6) },
				},
				{
					Control = "Label",
					Id = "S_Copies",
					Text = "7 / 10",
					Align = "Right",
					Style = { "Small", "Dim" },
					Props = {
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.new(1, -10, 0, 6),
						Size = UDim2.fromScale(0.5, 0),
					},
				},
			},
		},
	},
}

return _gui
