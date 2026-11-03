--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	Name = "SessionLock",
	Theme = "System",
	-- Plugin widgets follow the Studio theme
	Modes = { "Night", "Light" },
	-- Example size for the Gui tool's preview: the widget this gui is drawn in
	Preview = { Width = 460, Height = 470 },

	--[[ Tree ]]

	-- A view of the Ume window (Plugin/Ume), which draws the header
	Root = {
		Control = "Panel",
		Children = {
			{
				Control = "Scroll",
				Style = "Overlay",
				Children = {
					{
						Control = "Stack",
						Id = "U_Owner",
						Direction = "Horizontal",
						Children = {
							{
								Primitive = "ImageLabel",
								Id = "S_Avatar",
								Props = { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromOffset(56, 56), ScaleType = Enum.ScaleType.Fit },
								Children = {
									{ Primitive = "UICorner", Props = { CornerRadius = UDim.new(1, 0) } },
								},
							},
							{
								Control = "Stack",
								Style = "Tight",
								Grow = 1,
								Children = {
									{ Control = "Label", Text = "Session owner", Style = "Caption" },
									{ Control = "Label", Id = "S_Name", Text = "No owner", Style = "Heading" },
								},
							},
						},
					},
					{ Control = "Card", Id = "U_Session", Caption = "Session", Text = "Team Create", Status = "Unclaimed" },
				},
			},
			{
				Control = "Footer",
				Children = {
					{ Control = "Label", Id = "U_Hint", Text = "", Style = { "Small", "Dim" } },
					{ Control = "Button", Id = "U_Claim", Text = "Claim", Style = "Primary" },
				},
			},
		},
	},

	--[[ Templates ]]

	Templates = {
		-- Built into the gui root when needed, then destroyed once answered
		["PREFAB | ConfirmDialog"] = { Control = "Dialog", Title = "Are you sure?", ConfirmText = "Confirm", Danger = true },
	},
}

return _gui
