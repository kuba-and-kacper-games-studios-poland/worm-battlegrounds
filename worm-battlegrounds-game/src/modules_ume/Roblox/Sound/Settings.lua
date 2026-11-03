--- @class Sound_Settings
local _settings = {

	--[[ General ]]

	-- Name of the default SoundGroup that will be used as the default.
	DEFAULT_SOUND_GROUP = "Master",

	--[[ Auto Remove ]]

	-- Seconds an AutoRemove sound may take to load before it is destroyed.
	AUTO_REMOVE_LOAD_TIMEOUT = 10,
}
return _settings
