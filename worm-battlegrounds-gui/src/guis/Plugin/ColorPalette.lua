--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	Name = "ColorPalette",
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
							{ Control = "IconButton", Id = "S_Transparency", Icon = "eye", Text = "Transparency", Style = { "Builder", "Wide" } },
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
							{ Control = "Input", Id = "S_Search", Icon = "magnifying-glass", Placeholder = "Search gradients", Grow = 2, Style = "Small" },
						},
					},
					{ Control = "Chips", Id = "S_Categories", Options = { "All" }, Value = "All", Add = true },
				},
			},
			{ Control = "Divider" },
			-- Groups are built from the templates; New group stays after them
			{
				Control = "Scroll",
				Id = "U_Groups",
				Style = { "List", "Overlay" },
				Children = {
					{ Control = "Button", Id = "U_NewGroup", Text = "New group", Style = { "Ghost", "Small" } },
				},
			},
			{
				Control = "EmptyState",
				Id = "U_Empty",
				Text = "No gradients yet. Press Scrape gradients to collect the UIGradients this place uses.",
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
							{ Control = "Button", Id = "U_Scrape", Text = "Scrape gradients", Style = "Primary", Grow = 1 },
						},
					},
				},
			},
		},
	},

	--[[ Templates ]]

	Templates = {
		-- One group: its swatches go into a grid inside it
		["PREFAB | Group"] = { Control = "Section", Parent = "U_Groups", Text = "Group", Count = 0, Style = { "Plain", ContentGap = "None", PaddingTop = "XS", PaddingBottom = "S" } },
		["PREFAB | GradientGrid"] = { Control = "Grid", Style = "Tight" },
		["PREFAB | Gradient"] = { Control = "Thumb", Text = "", Favorite = false },

		-- Shown over the whole widget while a swatch or group is dragged: blocks the gui, carries a see-through copy
		-- under the pointer (a CanvasGroup fades the copy as one image) and marks where it drops
		["PREFAB | DragLayer"] = {
			Primitive = "ImageButton",
			Props = {
				Active = true,
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = "",
				ImageTransparency = 1,
				Interactable = true,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 50,
			},
			Children = {
				{ Control = "DropMarker", Id = "S_Indicator", Visible = false },
				{
					Primitive = "CanvasGroup",
					Id = "S_Ghost",
					Props = { AnchorPoint = Vector2.new(0.5, 0.5), AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, BorderSizePixel = 0, GroupTransparency = 0.4 },
					Children = {
						-- Room for the copy's outline, which the group would clip at its edges
						{ Primitive = "UIPadding", Props = { PaddingBottom = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2), PaddingTop = UDim.new(0, 2) } },
						{ Control = "Thumb", Id = "S_Proxy", Text = "" },
					},
				},
			},
		},

		-- Built into the gui root when needed, then destroyed once answered
		["PREFAB | ConfirmDialog"] = { Control = "Dialog", Title = "Are you sure?", ConfirmText = "Confirm", Danger = true },
		["PREFAB | NameDialog"] = { Control = "Dialog", Title = "Name", Input = "", ConfirmText = "Save" },
		["PREFAB | PlaceDialog"] = {
			Control = "Dialog",
			Title = "Which place is this?",
			Text = "Gradients are kept per place. Link this place to a saved entry, or name a new one.",
			Input = "",
			Placeholder = "Name for a new entry",
			ConfirmText = "Continue",
			Children = {
				{ Control = "Dropdown", Id = "S_Existing", Label = "Entry", Options = { "Create new" }, Value = "Create new" },
			},
		},
		["PREFAB | PickDialog"] = {
			Control = "Dialog",
			Title = "Pick",
			ConfirmText = "Save",
			Children = {
				{ Control = "Dropdown", Id = "S_Choice", Options = { "None" }, Value = "None" },
			},
		},
		["PREFAB | DetailsDialog"] = {
			Control = "Dialog",
			Title = "Gradient",
			ConfirmText = "Apply to selection",
			CancelText = "Close",
			Children = {
				{ Control = "Thumb", Id = "S_Preview", AspectRatio = 4 },
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
