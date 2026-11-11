--- @class PlayerBadges_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Badges

	-- The Player attribute the server writes: the player's badge ids, comma separated, in BADGES' order
	ATTRIBUTE = "Badges",

	--[[
		Every badge, in the order they show after a name: a picture (Image, from the art/badges kit, uploaded to The
		Snail Studio group) or one of Roblox's own glyphs, drawn as text (Glyph: the verified badge and the Premium icon)
	]]
	--- @type { PlayerBadges_Badge }
	BADGES = {
		{ Id = "Owner", Image = "rbxassetid://103399252005394" },
		{ Id = "Developer", Image = "rbxassetid://85832783383908" },
		{ Id = "Admin", Image = "rbxassetid://108039580969964" },
		{ Id = "Staff", Image = "rbxassetid://101046945125974" },
		{ Id = "Star", Image = "rbxassetid://120533067442932" },
		{ Id = "Verified", Glyph = "\u{E000}" },
		{ Id = "Premium", Glyph = "\u{E001}" },
	},

	--%%%%%%%%%%%%%%%%%%%% Layout

	-- A badge is BADGE_SIZE times its name label's height, BADGE_GAP times it from the name and the next badge
	BADGE_SIZE = 0.85,
	BADGE_GAP = 0.12,

	-- The badges take at most this share of the name's width: the name shrinks first, and past it they shrink too
	MAX_SHARE = 0.4,

	-- Scaled text draws about 5% wider than TextService measures it, so a name gets this much more room
	TEXT_ROOM = 1.06,
}

return _settings
