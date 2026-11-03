--- @class HideOnPlay_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Tags

	-- Instances with these tags are hidden; tagged Models and Folders hide their descendants.
	HIDE_TAGS = {
		Client = "HideOnPlay",
		Server = "S_HideOnPlay",
	},

	--%%%%%%%%%%%%%%%%%%%% Merge Order

	-- Match classes from general to specific; later matches override earlier properties. List every HIDE_PROPERTIES key once.
	HIDE_PROPERTY_CLASS_ORDER = {

		--[[ Parts & Decals ]]

		"BasePart",
		"Decal",
		"Texture",

		--[[ Beams & VFX ]]

		"Beam",
		"ParticleEmitter",
		"Trail",

		--[[ Lights ]]

		"Light",

		--[[ Legacy Effects ]]

		"Fire",
		"Smoke",
		"Sparkles",

		--[[ GUI ]]

		"GuiObject",
		"CanvasGroup",
		"LayerCollector",
	},

	--%%%%%%%%%%%%%%%%%%%% Hide Properties

	-- Hide properties are grouped by class.
	HIDE_PROPERTIES = {

		--[[ Parts & Decals ]]

		["BasePart"] = {
			["Transparency"] = 1,
		},
		["Decal"] = {
			["Transparency"] = 1,
		},
		["Texture"] = {
			["Transparency"] = 1,
		},

		--[[ Beams & VFX ]]

		["Beam"] = {
			["Enabled"] = false,
		},
		["ParticleEmitter"] = {
			["Enabled"] = false,
		},
		["Trail"] = {
			["Enabled"] = false,
		},

		--[[ Lights ]]

		["Light"] = {
			["Enabled"] = false,
		},

		--[[ Legacy Effects ]]

		["Fire"] = {
			["Enabled"] = false,
		},
		["Smoke"] = {
			["Enabled"] = false,
		},
		["Sparkles"] = {
			["Enabled"] = false,
		},

		--[[ GUI ]]

		["GuiObject"] = {
			["Visible"] = false,
			["Interactable"] = false,
		},
		["CanvasGroup"] = {
			["GroupTransparency"] = 1,
		},
		["LayerCollector"] = {
			["Enabled"] = false,
		},
	},
}
return _settings
