--- @class Matchmaking_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Store

	--[[
		The MemoryStore sorted maps that hold the open public matches of every server in the experience, one per mode
		(this name, then the mode). A new name starts over with an empty store
	]]
	STORE_NAME = "PublicLobbies_1_",

	-- How long an open match stays in the store without its server refreshing it, so a server that stopped drops out
	OPEN_SECONDS = 30,

	-- The least time a match's waiting room stays open once its server is up, so players still on their way get in
	MIN_ROOM_SECONDS = 8,

	-- How long a started match stays in the store, closed, so a join that comes late sees it closed
	CLOSED_SECONDS = 30,

	-- The most open matches read for a mode
	LIST_COUNT = 100,

	-- How many times a store call that failed is tried, and the seconds before the next try (times the try)
	RETRIES = 3,
	RETRY_DELAY = 0.5,

	--%%%%%%%%%%%%%%%%%%%% Joining

	-- A match this close to its start takes no more joins: they'd arrive after it started
	MIN_SECONDS_LEFT = 5,
}

return _settings
