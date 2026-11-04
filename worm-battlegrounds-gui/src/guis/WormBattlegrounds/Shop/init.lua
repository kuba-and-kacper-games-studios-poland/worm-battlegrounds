--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- Shop draws it on WidgetManager_Opened as I.UserInterface.UI["Shop"]
	Name = "Shop",
	Theme = "WormBattlegroundsBrawl",
	Screen = { DisplayOrder = 1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- Diamond packs and game passes, prices read live from Roblox
	Root = {
		Control = "Widget",
		Id = "U_Widget",
		Title = "Shop",
		Style = "Screen",
		Children = {
			{ Control = "Label", Text = "Diamonds", Style = "Heading" },
			-- The 5 diamond packs (PREFAB | Pack)
			{
				Control = "Cells",
				Id = "U_Packs",
				Direction = "Horizontal",
				Style = "Fixed",
				Props = { Size = UDim2.new(1, 0, 0, 240) },
			},
			{ Control = "Label", Text = "Game passes", Style = "Heading" },
			-- The 4 game passes (PREFAB | Pass)
			{ Control = "Cells", Id = "U_Passes", Style = { "Tiles", CellWidth = 340, CellHeight = 376 } },
		},
	},

	--[[ Prefabs ]]

	Templates = {
		-- A diamond pack; a press prompts the purchase
		["PREFAB | Pack"] = {
			Control = "Item",
			Parent = "U_Packs",
			Text = "Handful",
			Image = "wb-diamond",
			Subtext = "250 diamonds",
			Style = { Width = 200, Height = 240 },
			Children = {
				{
					Control = "Label",
					Id = "S_Price",
					Text = "99 R$",
					Align = "Center",
					Style = { "Strong", "Price" },
					Props = { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 8) },
				},
			},
		},
		-- A game pass: name, every benefit, price, Buy (or Owned)
		["PREFAB | Pass"] = {
			Control = "Box",
			Parent = "U_Passes",
			Style = "Fixed",
			Children = {
				{ Control = "Label", Id = "S_Name", Text = "VIP", Align = "Center", Style = "Heading" },
				{
					Control = "Label",
					Id = "S_Benefits",
					Text = "A gold name and VIP tag in chat, an exclusive VIP worm skin, and one free skin crate every day",
					Style = { "Small", "Dim", "Paragraph" },
				},
				-- The price beside a green Buy: a price is green, and the shop has no one next step
				{
					Control = "Stack",
					Direction = "Horizontal",
					Align = "Center",
					Style = "Buttons",
					Children = {
						{ Control = "Label", Id = "S_Price", Text = "199 R$", Style = { "Heading", "Price" } },
						{ Control = "Button", Id = "S_Buy", Text = "Buy", AutoWidth = true, Style = "Price" },
					},
				},
			},
		},
	},
}

return _gui
