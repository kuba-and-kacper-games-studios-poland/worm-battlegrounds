--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	Name = "Scraper",
	Theme = "System",
	-- Plugin widgets follow the Studio theme
	Modes = { "Night", "Light" },
	-- Example size for the Gui tool's preview: the widget this gui is drawn in
	Preview = { Width = 380, Height = 728 },

	--[[ Tree ]]

	Root = {
		Control = "Panel",
		Children = {
			{
				Control = "Stack",
				Id = "U_Toolbar",
				Style = "Bar",
				Children = {
					{
						Control = "Stack",
						Direction = "Horizontal",
						Fill = true,
						Style = "Buttons",
						Children = {
							{ Control = "IconButton", Id = "S_AutoApply", Icon = "check", Text = "Auto apply", Style = { "Builder", "Wide" } },
							{ Control = "IconButton", Id = "S_Layout", Icon = "grid", Text = "Layout", Style = { "Builder", "Wide" } },
							{ Control = "IconButton", Id = "S_Favorites", Icon = "heart", Text = "Favorites", Style = { "Builder", "Wide" } },
						},
					},
					{
						Control = "Stack",
						Direction = "Horizontal",
						Style = "Buttons",
						Children = {
							{ Control = "Dropdown", Id = "S_Place", Options = { "All Places" }, Value = "All Places", Grow = 1, Style = "Small" },
							{ Control = "Input", Id = "S_Search", Icon = "magnifying-glass", Placeholder = "Search assets", Grow = 2, Style = "Small" },
						},
					},
					{ Control = "Chips", Id = "S_Categories", Options = { "All" }, Value = "All" },
				},
			},
			{ Control = "Divider" },
			-- Cards are built from the template into the grid; its cell width follows the layout (small or large)
			{
				Control = "Scroll",
				Id = "U_Assets",
				Style = { "List", "Overlay" },
				Children = {
					{ Control = "Grid", Id = "U_Grid", MinCellWidth = 120, Style = "Tight" },
				},
			},
			{
				Control = "EmptyState",
				Id = "U_Empty",
				Text = "No assets yet. Press Scrape place to collect the images this place uses.",
				Icon = "magnifying-glass",
				Visible = false,
			},
			{
				Control = "Footer",
				Children = {
					{
						Control = "Stack",
						Id = "U_Scan",
						Direction = "Horizontal",
						Style = "Buttons",
						Visible = false,
						Children = {
							{ Control = "Progress", Id = "S_Bar", Value = 0, Text = "Preparing scan...", Grow = 1 },
							{ Control = "IconButton", Id = "S_Cancel", Icon = "x", Style = { "Builder", Size = "ControlSmall" } },
						},
					},
					{
						Control = "Stack",
						Direction = "Horizontal",
						Style = "Buttons",
						Children = {
							{ Control = "IconButton", Id = "U_Services", Icon = "gear", Style = { "Builder", Size = "Control" } },
							{ Control = "Button", Id = "U_Scrape", Text = "Scrape place", Style = "Primary", Grow = 1 },
						},
					},
				},
			},
		},
	},

	--[[ Templates ]]

	Templates = {
		-- One asset card in the grid
		["PREFAB | AssetTile"] = { Control = "Thumb", Parent = "U_Grid", Text = "Asset", Subtext = "", Favorite = false, Style = "Caption" },

		-- Built into the gui root when needed, then destroyed once answered
		["PREFAB | ConfirmDialog"] = { Control = "Dialog", Title = "Are you sure?", ConfirmText = "Confirm", Danger = true },
		["PREFAB | NameDialog"] = { Control = "Dialog", Title = "Name", Input = "", ConfirmText = "Save" },
		["PREFAB | PlaceDialog"] = {
			Control = "Dialog",
			Title = "Which place is this?",
			Text = "Scraped assets are kept per place. Link this place to a saved entry, or name a new one.",
			Input = "",
			Placeholder = "Name for a new entry",
			ConfirmText = "Continue",
			Children = {
				{ Control = "Dropdown", Id = "S_Existing", Label = "Entry", Options = { "Create new" }, Value = "Create new" },
			},
		},
		["PREFAB | CategoryDialog"] = {
			Control = "Dialog",
			Title = "Set category",
			ConfirmText = "Save",
			Children = {
				{ Control = "Dropdown", Id = "S_Category", Options = { "Images" }, Value = "Images" },
			},
		},
		["PREFAB | DetailsDialog"] = {
			Control = "Dialog",
			Title = "Asset",
			ConfirmText = "Apply to selection",
			CancelText = "Close",
			Children = {
				{ Control = "Thumb", Id = "S_Preview", AspectRatio = 1.6 },
				{ Control = "Input", Id = "S_Id", Label = "Asset id", Value = "" },
				{ Control = "Label", Id = "S_Info", Text = "", Style = { "Small", "Dim" } },
				{ Control = "Label", Text = "Sources", Style = "Caption" },
				{
					Primitive = "ScrollingFrame",
					Props = {
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						CanvasSize = UDim2.new(),
						ScrollBarThickness = 4,
						ScrollingDirection = Enum.ScrollingDirection.Y,
						Size = UDim2.new(1, 0, 0, 120),
						VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
					},
					Children = {
						{ Control = "Label", Id = "S_Sources", Text = "", Style = { "Small", "Dim", "Fixed" } },
					},
				},
			},
		},
		["PREFAB | ServicesDialog"] = {
			Control = "Dialog",
			Title = "Services",
			Text = "Scraping only looks inside the services turned on here.",
			ConfirmText = "Done",
			Children = {
				{
					Primitive = "ScrollingFrame",
					Id = "S_List",
					Props = {
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						CanvasSize = UDim2.new(),
						ScrollBarThickness = 4,
						ScrollingDirection = Enum.ScrollingDirection.Y,
						Size = UDim2.new(1, 0, 0, 240),
						VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
					},
					Children = {
						{ Primitive = "UIListLayout", Props = { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder } },
						-- Keeps the toggles clear of the scroll bar
						{ Primitive = "UIPadding", Props = { PaddingRight = UDim.new(0, 8) } },
					},
				},
			},
		},
		["PREFAB | ServiceToggle"] = { Control = "Toggle", Label = "Service", Value = true, OffText = "", OnText = "" },
	},
}

return _gui
