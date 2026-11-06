--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The Party panel's Invite button opens it; Party fills it on WidgetManager_Opened as I.UserInterface.UI["PartyInvite"]
	Name = "PartyInvite",
	Theme = "WormBattlegroundsBrawl",
	Screen = { DisplayOrder = 1, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- Everyone in this server who isn't in a party, each with Invite; friends elsewhere through Roblox's invite
	Root = {
		Control = "Widget",
		Id = "U_Widget",
		Title = "Invite players",
		Style = "Small",
		Children = {
			{
				Control = "Label",
				Id = "S_Empty",
				Text = "Everyone here is in a party already. Invite your friends instead!",
				Align = "Center",
				Style = "Dim",
			},
			-- Who can be invited (PREFAB | Invitable)
			{ Control = "Cells", Id = "U_Players" },
			{ Control = "Button", Id = "S_InviteFriends", Text = "Invite friends" },
		},
	},

	--[[ Prefabs ]]

	Templates = {
		-- One player who can be invited; Invite turns to Sent once pressed
		["PREFAB | Invitable"] = {
			Control = "Stack",
			Parent = "U_Players",
			Direction = "Horizontal",
			Children = {
				{ Control = "Picture", Id = "S_Avatar", Style = "Avatar" },
				{ Control = "Label", Id = "S_Name", Text = "PlayerName", Grow = 1 },
				{ Control = "Button", Id = "S_Invite", Text = "Invite", AutoWidth = true, Style = "Small" },
			},
		},
	},
}

return _gui
