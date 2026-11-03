--- @class InputBlock_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% General

	-- ContextActionService action name for the movement sink.
	ACTION_NAME = "InputBlock_Sink",

	-- Lock id used when Block / Unblock is called without one.
	DEFAULT_LOCK_ID = "Default",

	--%%%%%%%%%%%%%%%%%%%% Server Enforcement

	-- While a server lock is held, also zero the character's WalkSpeed, JumpPower and JumpHeight on the server.
	SERVER_ENFORCED = false,
}
return _settings
