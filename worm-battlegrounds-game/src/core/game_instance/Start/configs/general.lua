--[[
	General Configuration.
]]
--- @class Ume_Config_General
local _config = {

	--%%%%%%%%%%%%%%%%%%%% General

	-- Current version of the Ume framework.
	_umeVersion = "2.0.0",

	-- Name of the boolean used to check the player's status.
	_clientStatusBoolName = "__Ume_ClientStarted",

	--%%%%%%%%%%%%%%%%%%%% Game

	-- Current version of the game.
	GameVersion = "1.0.0",

	--[[
		Indicates whether the game is in a production/live state.
		When set to `true`, the game will use the production/live store names.
	]]
	IsProductionReady = false,
}

return _config
