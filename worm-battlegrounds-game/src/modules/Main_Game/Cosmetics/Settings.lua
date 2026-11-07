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

	-- How long an emote's placeholder label shows over the snail, in seconds
	EMOTE_SECONDS = 2.5,

	-- How far from the wheel's centre its emotes sit, as a share of its size
	WHEEL_RADIUS = 0.38,

	--%%%%%%%%%%%%%%%%%%%% Previews

	-- How far the skin preview's camera stands from the snail, in the model's sizes
	PREVIEW_DISTANCE = 1.6,

	--%%%%%%%%%%%%%%%%%%%% Gui

	SKINS_GUI_NAME = "Skins",
	EMOTE_SHOP_GUI_NAME = "EmoteShop",

	--[[
		The guis that show emotes and the equipped skin: the lobby's emote row and skin button, the match's emote
		wheel, and the party list emotes show over in the lobby
	]]
	LOADOUT_GUI_NAME = "Loadout",
	LOBBY_GUI_NAME = "Lobby",
	MATCH_HUD_GUI_NAME = "MatchHud",
	PARTY_GUI_NAME = "Party",
}

return _settings
