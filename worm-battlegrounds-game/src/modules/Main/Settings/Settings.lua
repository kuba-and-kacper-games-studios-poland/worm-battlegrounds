--- @class Settings_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Settings

	-- The groups the window lists the settings in: each one's heading, place and colours (light, then dark).
	--- @type { [string]: Settings_Section }
	SECTIONS = {
		Sound = {

			--[[ General ]]

			Text = "Sound",
			LayoutOrder = 1,

			--[[ Looks ]]

			Colors = { Color3.fromRGB(230, 205, 255), Color3.fromRGB(150, 110, 255) },
		},
	},

	--[[
		Every setting: its group, name, what it does ("" when the name says it all, which centres the name in its row),
		place in its group and default. A boolean default is a switch (on or off), for a game's own settings; a number default is a volume from 0 to
		VOLUME_MAX, stepped by VOLUME_STEP, that sets its SoundGroups' volume to the value over 100, times MASTER_VOLUME's
		over 100. A new key is a new setting: the profile template, the replicator and the window follow it.
	]]
	--- @type { [string]: Settings_Setting }
	SETTINGS = {
		Master = {

			--[[ General ]]

			Section = "Sound",
			Text = "Master",
			Detail = "",
			LayoutOrder = 1,

			--[[ Value ]]

			Default = 100,

			--[[ Sound ]]

			SoundGroups = { "Master" },
		},
		Music = {

			--[[ General ]]

			Section = "Sound",
			Text = "Music",
			Detail = "",
			LayoutOrder = 2,

			--[[ Value ]]

			Default = 50,

			--[[ Sound ]]

			SoundGroups = { "Music" },
		},
		SoundEffects = {

			--[[ General ]]

			Section = "Sound",
			Text = "Sound Effects",
			Detail = "",
			LayoutOrder = 3,

			--[[ Value ]]

			Default = 50,

			--[[ Sound ]]

			SoundGroups = { "SFX", "UI" },
		},
	},

	--%%%%%%%%%%%%%%%%%%%% Volumes

	-- A volume's highest value, and how much one chevron press changes it.
	VOLUME_MAX = 100,
	VOLUME_STEP = 10,

	-- The volume every other volume is multiplied by (Master 50 and Music 50 play the music at 0.25).
	MASTER_VOLUME = "Master",

	--%%%%%%%%%%%%%%%%%%%% Gui

	-- The settings window (the Settings gui's export in StarterGui).
	GUI_NAME = "Settings",

	-- Screen height the window is laid out for; S_ScreenScale is the screen's height over it.
	DESIGN_HEIGHT = 1080,

	-- Mobile screens shorter than this many pixels scale the window up by MOBILE_BOOST, so it stays tappable.
	SMALL_SCREEN = 500,
	MOBILE_BOOST = 1.3,

	-- A row's outline transparency, in its group's dark colour.
	ACCENT_TRANSPARENCY = 0.5,

	--[[
		The switch's gradient (bottom to top, on both its faces), green for On and red for Off, and its word in each
		(ume-gui's System/_Primitives_ButtonsColors: Accept, Cancel).
	]]
	--- @type { [boolean]: ColorSequence }
	SWITCH_LOOKS = {
		[true] = ColorSequence.new(Color3.fromRGB(50, 195, 24), Color3.fromRGB(154, 255, 23)),
		[false] = ColorSequence.new(Color3.fromRGB(186, 0, 0), Color3.fromRGB(255, 62, 62)),
	},

	--- @type { [boolean]: string }
	SWITCH_TEXTS = { [true] = "On", [false] = "Off" },

	--[[
		A volume's chevrons, the same way: blue while it can step that way, grey at the end it has reached (Blue, Gray).
		A volume at 0 shows SWITCH_TEXTS[false].
	]]
	--- @type { [boolean]: ColorSequence }
	CHEVRON_LOOKS = {
		[true] = ColorSequence.new(Color3.fromRGB(0, 195, 255), Color3.fromRGB(0, 251, 255)),
		[false] = ColorSequence.new(Color3.fromRGB(130, 143, 162), Color3.fromRGB(205, 220, 252)),
	},
}
return _settings
