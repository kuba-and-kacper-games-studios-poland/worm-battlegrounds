--- @class PlayerCollision_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% General

	-- Name of the default player `CollisionGroup`.
	DEFAULT_COLLISION_GROUP_NAME = "Player",

	-- List of `CollisionGroups` that should not collide with the player.
	IGNORED_COLLISION_GROUPS = { "Player" },

	-- Seconds between command dictionary refreshes (`PlayerCollision_CollisionGroupNames`, `I.DoEvery`).
	CMD_DICT_REFRESH_SEC = 30,
}
return _settings
