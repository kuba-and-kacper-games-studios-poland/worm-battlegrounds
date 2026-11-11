--- @class Cosmetics_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Owned

	-- What every player owns from the start, given on their first join
	--- @type { string }
	STARTER_ITEMS = { "Skin_Classic", "Emote_Wave" },

	-- The skin worn until the player equips another
	DEFAULT_SKIN = "Skin_Classic",

	-- Copies of a skin that make it shiny
	SHINY_COPIES = 10,

	--%%%%%%%%%%%%%%%%%%%% Emotes

	-- Seconds a player waits between two emotes
	EMOTE_COOLDOWN = 5,

	-- How long an emote plays on the snail and its bubble shows beside a name in the lobby, in seconds
	EMOTE_SECONDS = 3,

	-- The gap between a name on a lobby party card and the emote bubble beside it, in design px
	CARD_BUBBLE_GAP = 8,

	-- How far from the wheel's centre its emotes sit, as a share of its size
	WHEEL_RADIUS = 0.38,

	--%%%%%%%%%%%%%%%%%%%% Previews

	-- How far the skin preview's camera stands from the snail's middle, in the model's sizes (0.6 fills a tile's preview)
	PREVIEW_DISTANCE = 0.6,

	--%%%%%%%%%%%%%%%%%%%% Gui

	SKINS_GUI_NAME = "Skins",
	EMOTE_SHOP_GUI_NAME = "EmoteShop",

	--[[
		The guis that show emotes: the lobby's emote row, the match's emote wheel, and the party list emotes show over
		in the lobby
	]]
	LOADOUT_GUI_NAME = "Loadout",
	MATCH_HUD_GUI_NAME = "MatchHud",
	PARTY_GUI_NAME = "Party",
}

return _settings
