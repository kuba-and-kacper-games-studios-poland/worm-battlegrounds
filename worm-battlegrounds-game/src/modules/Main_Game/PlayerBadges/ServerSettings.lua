--- @class PlayerBadges_ServerSettings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% The Snail Studio

	-- The studio's group, The Snail Studio, which owns the game
	STUDIO_GROUP = 566704940,

	-- Its owner's rank wears the crown (and in a game a user owns, that user)
	OWNER_RANK = 255,

	-- The lowest rank in the studio's group that wears the developer's wrench (Admin 254, the owner 255)
	DEVELOPER_RANK = 254,

	--[[
		The studio's roles, by name, that wear the crown and the wrench whatever their rank: on 2026-11-10 Member, Tester,
		Build, Management and LEAD are all rank 1, as a plain member, so ranks alone can't tell them apart (the owner's
		pick, 2026-11-10). Tester wears neither
	]]
	--- @type { string }
	OWNER_ROLES = { "LEAD" },

	--- @type { string }
	DEVELOPER_ROLES = { "LEAD", "Management", "Build" },

	--%%%%%%%%%%%%%%%%%%%% Roblox

	-- Groups.lua's names for Roblox's official group (its members are Roblox staff) and Roblox Video Stars
	STAFF_GROUP = "Roblox",
	STAR_GROUP = "RobloxStars",
}

return _settings
