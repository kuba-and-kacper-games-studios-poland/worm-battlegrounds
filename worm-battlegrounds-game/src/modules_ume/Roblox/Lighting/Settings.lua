--- @class Lighting_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Presets

	-- Lighting Preset used as a template to validate other presets.
	TEMPLATE_LIGHTING_ID = "Roblox",

	-- Default Lighting preset Id, applied at start.
	DEFAULT_LIGHTING_ID = "Default",

	--[[
		Take presets from the place, over Lua presets with the same name: the Lighting Manager's when the place has
		them, else the place's own lighting as the default preset.
	]]
	OVERWRITE_DEFAULT_LIGHTING = true,

	--%%%%%%%%%%%%%%%%%%%% Place Presets

	--[[
		Names the Ume plugin's Lighting Manager uses in the place: the active preset is Lighting itself, named by the
		Id attribute of its config; stored presets are folders under the presets folder, each with its own config.
	]]
	PLACE_CONFIG_NAME = "__config",
	PLACE_PRESETS_FOLDER = "Presets",
	PLACE_ID_ATTRIBUTE = "Lighting_Id",
}
return _settings
