--- @class Core_Controller_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Core Guis

	-- Core guis turned back on after loading; every other core gui stays hidden.
	--- @type { Enum.CoreGuiType }
	ENABLED_CORE_GUIS = {
		Enum.CoreGuiType.Captures,
		Enum.CoreGuiType.Chat,
		Enum.CoreGuiType.EmotesMenu,
		Enum.CoreGuiType.PlayerList,
	},

	-- Seconds after loading before those core guis are turned on.
	ENABLE_DELAY = 3,
}
return _settings
