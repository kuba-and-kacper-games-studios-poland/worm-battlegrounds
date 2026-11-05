--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The lobby's Modes button opens it; MatchBoard fills its rows as I.UserInterface.UI["PlayModes"]
	Name = "PlayModes",
	Theme = "WormBattlegroundsBrawl",
	Screen = { DisplayOrder = 1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- Every way to play besides the quick match: solo against a bot, a custom lobby, then the open public matches
	Root = {
		Control = "Widget",
		Id = "U_Widget",
		Title = "Modes",
		Children = {
			-- Purple, as modes are; the window has no one next step, so no yellow
			{
				Control = "Stack",
				Direction = "Horizontal",
				Fill = true,
				Style = "Buttons",
				Children = {
					{
						Control = "Button",
						Id = "U_Solo",
						Text = "Play solo",
						Style = { "Event", "Large" },
						Tags = {
							Interact_Button = {
								Interact_ModuleName = "WidgetManager",
								Interact_Function = "Open",
								Interact_Arg1 = "SoloSetup",
							},
						},
					},
					{
						Control = "Button",
						Id = "U_Custom",
						Text = "Custom lobby",
						Style = { "Event", "Large" },
						Tags = {
							Interact_Button = {
								Interact_ModuleName = "WidgetManager",
								Interact_Function = "Open",
								Interact_Arg1 = "CustomLobby",
							},
						},
					},
				},
			},
			{ Control = "Label", Text = "Public matches", Style = "Heading" },
			-- The open public matches, refreshed as they start (PREFAB | Row)
			{ Control = "Cells", Id = "U_Rows" },
		},
	},

	--[[ Prefabs ]]

	Templates = {
		--[[
			One open public match on a purple card: map picture, mode and map, players and the 30-second timer, then Join
			(or Join teams), blue since a list of matches has no one next step
		]]
		["PREFAB | Row"] = {
			Control = "Box",
			Parent = "U_Rows",
			Style = { "Card", "Event" },
			Children = {
				{
					Control = "Stack",
					Direction = "Horizontal",
					Children = {
						{ Control = "Picture", Id = "S_Thumbnail", Style = { "Thumbnail", Width = 160, Height = 90 } },
						{
							Control = "Stack",
							Grow = 1,
							Style = "None",
							Children = {
								{ Control = "Label", Id = "S_Mode", Text = "Deathmatch", Style = "Strong" },
								{ Control = "Label", Id = "S_Map", Text = "Fluffy Fallout", Style = { "Small", "Map" } },
								{
									Control = "Stack",
									Direction = "Horizontal",
									Children = {
										{ Control = "Label", Id = "S_Players", Text = "3 / 8", Style = "Small" },
										{ Control = "Label", Id = "S_Timer", Text = "0:30", Style = { "Small", "Warning" } },
									},
								},
							},
						},
						{ Control = "Button", Id = "S_Join", Text = "Join", AutoWidth = true },
					},
				},
			},
		},
	},
}

return _gui
