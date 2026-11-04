--[[
	Created By: 	Nari
]]

--- @type UmeGui_Gui
local _gui = {

	--[[ General ]]

	-- The Party module turns it on, on the Lobby map, as I.UserInterface.UI["Party"]
	Name = "Party",
	Theme = "WormBattlegrounds",
	Screen = { DisplayOrder = 0, Enabled = false, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets },

	--[[ Tree ]]

	-- Top left: up to 4 players who join matches together
	Root = {
		Control = "Box",
		Id = "U_Party",
		Title = "Party",
		Screen = true,
		Style = { "Panel", "Fixed" },
		Props = {
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.fromOffset(24, 96),
			Size = UDim2.fromOffset(400, 420),
		},
		Children = {
			-- The party's players (PREFAB | Member)
			{ Control = "Cells", Id = "U_Members" },
			-- Invite players in this server
			{ Control = "Button", Id = "U_Invite", Text = "Invite players" },
			-- Roblox's friend invite prompt
			{ Control = "Button", Id = "U_InviteFriends", Text = "Invite friends", Style = "Primary" },
			{ Control = "Button", Id = "U_Leave", Text = "Leave party", Style = { "Danger", "Small" } },
		},
	},

	--[[ Prefabs ]]

	Templates = {
		-- A party member: avatar, name, level, the leader's crown, and Kick (leader only)
		["PREFAB | Member"] = {
			Control = "Stack",
			Parent = "U_Members",
			Direction = "Horizontal",
			Children = {
				{ Control = "Picture", Id = "S_Avatar", Style = "Avatar" },
				{
					Control = "Stack",
					Grow = 1,
					Style = "None",
					Children = {
						{ Control = "Label", Id = "S_Name", Text = "PlayerName", Style = "Strong" },
						{ Control = "Label", Id = "S_Level", Text = "Level 12", Style = { "Small", "Dim" } },
					},
				},
				{ Control = "Picture", Id = "S_Crown", Image = "wb-crown", Style = "Glyph" },
				{ Control = "Button", Id = "S_Kick", Text = "Kick", AutoWidth = true, Style = { "Danger", "Small" } },
			},
		},
	},
}

return _gui
