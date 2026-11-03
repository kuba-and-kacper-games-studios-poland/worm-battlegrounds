--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	Name = "TagListPlus",
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
				Control = "Header",
				Id = "U_Header",
				Text = "TagList+",
				-- A tag with a plus in TagList+'s green (ume-branding upload/logos/TagListPlus.png)
				Logo = "rbxassetid://75801830376040",
				Children = {
					{ Control = "IconButton", Id = "S_Tags", Icon = "tag", Text = "Tags", Style = "Builder" },
					{ Control = "IconButton", Id = "S_Overview", Icon = "chart-pie", Text = "Overview", Style = "Builder" },
				},
			},
			{
				Primitive = "Frame",
				Id = "U_Pages",
				Grow = 1,
				Props = { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 0) },
				Children = {
					--[[ Tags ]]

					{
						Control = "Panel",
						Id = "U_TagsPage",
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
											{ Control = "IconButton", Id = "S_Hidden", Icon = "eye", Text = "Hidden tags", Style = { "Builder", "Wide" } },
											{ Control = "IconButton", Id = "S_Collapse", Icon = "dual-arrows-vertical", Text = "Expand all", Style = { "Builder", "Wide" } },
										},
									},
									{ Control = "Input", Id = "S_Search", Icon = "magnifying-glass", Placeholder = "Search", Style = "Small" },
									{ Control = "Chips", Id = "S_Categories", Options = { "All" }, Value = "All", Add = true },
								},
							},
							{ Control = "Divider" },
							-- Display groups and their tags are built from the templates
							{ Control = "Scroll", Id = "U_List", Style = { "List", "Overlay" } },
							{
								Control = "EmptyState",
								Id = "U_Empty",
								Text = "No tags to show.",
								Icon = "tag",
								Visible = false,
							},
							{
								Control = "Footer",
								Children = {
									{
										Control = "Stack",
										Direction = "Horizontal",
										Fill = true,
										Style = "Buttons",
										Children = {
											{ Control = "Button", Id = "U_LoadTags", Text = "Load tags" },
											{ Control = "Button", Id = "U_ApplyExisting", Text = "Apply existing" },
										},
									},
								},
							},
						},
					},

					--[[ Overview ]]

					{
						Control = "Panel",
						Id = "U_OverviewPage",
						Visible = false,
						Children = {
							{
								Control = "Stack",
								Id = "U_OverviewBar",
								Style = "Bar",
								Children = {
									{
										Control = "Stack",
										Direction = "Horizontal",
										Style = "Buttons",
										Children = {
											{ Control = "Segmented", Id = "S_Mode", Options = { "Tags", "Attributes" }, Value = "Tags", Grow = 1, Style = "Small" },
											{ Control = "IconButton", Id = "S_Services", Icon = "gear", Style = { "Builder", Size = "ControlSmall" } },
											{ Control = "Button", Id = "S_Fetch", Text = "Fetch", AutoWidth = true, Style = { "Primary", "Small" } },
										},
									},
									{ Control = "Input", Id = "S_Filter", Icon = "magnifying-glass", Placeholder = "Filter results", Style = "Small" },
								},
							},
							{ Control = "Divider" },
							{ Control = "Scroll", Id = "U_Results", Style = { "List", "Overlay", Padding = "M", PaddingX = "M", Gap = "S" } },
							{
								Control = "EmptyState",
								Id = "U_ResultsEmpty",
								Text = "Pick what to list, then press Fetch.",
								Icon = "chart-pie",
								Visible = false,
							},
							{
								Control = "Footer",
								Children = {
									{ Control = "Label", Id = "U_OverviewStatus", Text = "", Style = { "Small", "Dim" } },
								},
							},
						},
					},
				},
			},
		},
	},

	--[[ Templates ]]

	Templates = {
		-- Built into the gui root when needed, then destroyed once answered
		["PREFAB | ConfirmDialog"] = { Control = "Dialog", Title = "Are you sure?", ConfirmText = "Confirm", Danger = true },
		["PREFAB | NameDialog"] = { Control = "Dialog", Title = "Name", Input = "", ConfirmText = "Save" },
		["PREFAB | ServicesDialog"] = {
			Control = "Dialog",
			Title = "Services",
			Text = "Fetch only looks inside the services turned on here.",
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

		-- One display group, holding its tags
		["PREFAB | Group"] = { Control = "Section", Parent = "U_List", Text = "Group", Count = 0, Style = { "Plain", ContentGap = "None", PaddingTop = "None", PaddingBottom = "XS" } },
		-- One tag, built into its group; its details are built into it while expanded
		["PREFAB | Tag"] = { Control = "CheckItem", Text = "Tag", Style = { ShowChevron = false, DetailsGap = "XS" } },
		-- A part of a tag's details: SETTINGS, ATTRIBUTES, OBJECTS
		["PREFAB | DetailHeading"] = { Control = "Label", Text = "Heading", Style = "Caption" },
		-- One entry: its name, its value, then its value type in a fixed column so values line up
		["PREFAB | Detail"] = {
			Control = "Stack",
			Direction = "Horizontal",
			Style = "Snug",
			Children = {
				{ Control = "Label", Id = "S_Key", Text = "Key", Grow = 1, Style = "Small" },
				{ Control = "Label", Id = "S_Value", Text = "Value", Align = "Right", Grow = 1, Style = { "Small", "Dim" } },
				{ Control = "Label", Id = "S_Type", Text = "", Style = { "Small", "Muted" }, Props = { Size = UDim2.fromOffset(64, 0) } },
			},
		},

		-- One fetched tag or attribute
		["PREFAB | Result"] = {
			Control = "ListCard",
			Parent = "U_Results",
			Text = "Name",
			Subtext = "0 instances",
			Actions = { "Select" },
			Style = { Fill = "Surface", StrokeThickness = "None", Padding = "S" },
		},
	},
}

return _gui
