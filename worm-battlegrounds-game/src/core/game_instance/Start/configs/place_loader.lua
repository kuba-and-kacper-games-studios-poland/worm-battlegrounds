--[[
	Place Loader Configuration.
]]

--[[ Disabled Modules ]]

-- Off on every map: the template's modules the game doesn't use
local ALWAYS_OFF = {
	"2_BackpackPlus",
	"Limited",
	"CharacterAnimation",
	"AFKTeleport",
	"Fall_Controller",
	"WalkSpeed_Controller",
	"GlobalLeaderboard_Controller",
	"CountryCode",
	"Friends_Controller",
	"Group_Controller",
	"Premium_Controller",
	"Tool",
} --- @type { string }

-- Off on the Lobby map
local MATCH_ONLY = { "Arena", "Snails", "SnailControl", "Combat", "Match", "Bots", "MatchCamera", "MatchHud", "MatchRewards" } --- @type { string }

-- Off on the Match map
local LOBBY_ONLY = { "Lobby", "MatchBoard", "Party", "Crates" } --- @type { string }

--[[ Places ]]

--[[
	The experience's two places, copies of one file: players join the lobby place, and matches run in reserved servers
	of the match place (Arena). Each boots its own map, so Roblox's analytics count the lobby and the matches apart.
]]
local LOBBY_PLACE_ID: number = 83410278033601
local MATCH_PLACE_ID: number = 118265066788984

--%%%%%%%%%%%%%%%%%%%% Concat

--[[
	Returns the lists' names in one list.
]]
--- @param first { string }
--- @param second { string }
--- @return { string }
local function concat(first, second)
	--[[ Local Variables ]]

	local names = table.clone(first) --- @type { string }

	--[[ Returning ]]

	table.move(second, 1, #second, #names + 1, names)
	return names
end

--[[ Maps ]]

-- Both places load the same maps; each place's DefaultMapId picks the one it boots
--- @type { [string]: Ume_PlaceLoader_MapSettings }
local MAP_CONFIGS = {
	["Lobby"] = {
		-- Data
		ProfileStoreName = "UmeTesting_-1",
		LeaderboardStoreName = "UmeTesting_-1",

		-- Accessibility
		VRSupport = false,

		-- Directories
		GameDirs = {
			Workspace_Ume = { "Default", "Lobby" },
			ReplicatedStorage_Ume = { "Default", "Lobby" },
			ServerStorage_Ume = { "Default", "Lobby" },

			StarterGui = { "Default", "Lobby" },
			StarterPack = { "Default", "Lobby" },
			StarterPlayer = { "Default", "Lobby" },

			Assets = { "Default", "Shared", "Lobby" },
			SAssets = { "Default", "Lobby" },
		},

		-- Modules
		ModulesDirs = {
			-- Ume
			"Ume",
			"Ume_Data",
			"Roblox",

			-- Game
			"Utils",
			"Main",
			"Main_Game",
			"Main_Controllers",
		},
		DisabledModules = concat(ALWAYS_OFF, MATCH_ONLY),
		LoadingOrder = {},

		-- Other
		ReturnPlaceId = nil,
	},
	["Match"] = {
		-- Data
		ProfileStoreName = "UmeTesting_-1",
		LeaderboardStoreName = "UmeTesting_-1",

		-- Accessibility
		VRSupport = false,

		-- Directories
		GameDirs = {
			Workspace_Ume = { "Default", "Match" },
			ReplicatedStorage_Ume = { "Default", "Match" },
			ServerStorage_Ume = { "Default", "Match" },

			StarterGui = { "Default", "Match" },
			StarterPack = { "Default", "Match" },
			StarterPlayer = { "Default", "Match" },

			Assets = { "Default", "Shared", "Match" },
			SAssets = { "Default", "Match" },
		},

		-- Modules
		ModulesDirs = {
			-- Ume
			"Ume",
			"Ume_Data",
			"Roblox",

			-- Game
			"Utils",
			"Main",
			"Main_Game",
			"Main_Controllers",
		},
		DisabledModules = concat(ALWAYS_OFF, LOBBY_ONLY),
		LoadingOrder = {},

		-- Other
		ReturnPlaceId = nil,
	},
	["Studio"] = {
		-- Data
		ProfileStoreName = "UmeTesting_-1",
		LeaderboardStoreName = "UmeTesting_-1",

		-- Accessibility
		VRSupport = false,

		-- Directories
		GameDirs = {
			Workspace_Ume = { "Default", "Lobby", "Match" },
			ReplicatedStorage_Ume = { "Default", "Lobby", "Match" },
			ServerStorage_Ume = { "Default", "Lobby", "Match" },

			StarterGui = { "Default", "Lobby", "Match" },
			StarterPack = { "Default", "Lobby", "Match" },
			StarterPlayer = { "Default", "Lobby", "Match" },

			Assets = { "Default", "Shared", "Lobby", "Match" },
			SAssets = { "Default", "Lobby", "Match" },
		},

		-- Modules
		ModulesDirs = {
			-- Ume
			"Ume",
			"Ume_Data",
			"Roblox",

			-- Game
			"Utils",
			"Main",
			"Main_Game",
			"Main_Controllers",
		},
		DisabledModules = ALWAYS_OFF,
		LoadingOrder = {},

		-- Other
		ReturnPlaceId = nil,
	},
	["UmeLobby"] = {
		-- Data
		ProfileStoreName = "UmeTesting_-1",
		LeaderboardStoreName = "UmeTesting_-1",

		-- Accessibility
		VRSupport = false,

		-- Directories
		GameDirs = {
			Workspace_Ume = { "UmeLobby" },
			ReplicatedStorage_Ume = { "UmeLobby" },
			ServerStorage_Ume = { "UmeLobby" },

			StarterGui = { "UmeLobby" },
			StarterPack = { "UmeLobby" },
			StarterPlayer = { "UmeLobby" },

			Assets = { "UmeLobby" },
			SAssets = { "UmeLobby" },
		},

		-- Modules
		ModulesDirs = {
			-- Ume
			"Ume",
			"Ume_Data",
			"Roblox",

			-- Game
			"Utils",
			"Main",
			"Main_Game",
			"Main_Controllers",
		},
		DisabledModules = {},
		LoadingOrder = {},

		-- Other
		ReturnPlaceId = LOBBY_PLACE_ID,
	},
}

--- @class Ume_Config_PlaceLoader
local _config = {

	--%%%%%%%%%%%%%%%%%%%% General

	--[[
		Id of the default starting place (where players join the game and where the main lobby is located).
		You should point it to a specific place if the game works across multiple places.
	]]
	DefaultPlaceId = LOBBY_PLACE_ID,

	--%%%%%%%%%%%%%%%%%%%% Map Loader / Persistent Lobby

	-- Id used by `MemoryStoreService` to identify the currently loaded map.
	_mapStoreId = "__Ume_MapId",

	-- Id used by `DataStore` to check and update state of the persistent lobby.
	_lobbyStoreId = "__Ume_PersistentLobby",

	-- Determines whether the persistent lobby should also load in Studio.
	PersistentLobbyInStudio = true,

	-- List of private server Ids excluded from the persistent lobby.
	PersistentLobbyExcludedServers = {}, --- @type { string }

	--%%%%%%%%%%%%%%%%%%%% Places/Maps Configs

	-- Current PlaceId. Set by the `place_loader` task.
	PlaceId = nil, --- @type number

	-- Current MapId. Set by the `place_loader` task.
	MapId = nil, --- @type string

	--[[
		Table with place configuration indexed by their placeId.
	]]
	--- @type { [number]: Ume_PlaceLoader_PlaceSettings }
	PlaceConfigs = {
		[LOBBY_PLACE_ID] = {
			--[[
				In Studio the Studio map plays the lobby and its matches in one server; the Workspace attribute
				Ume_StudioMapId ("Lobby" or "Match") boots one map alone instead, and "Lobby" teleports to the match place
				(Studio runs that place as last saved to Roblox)
			]]
			DefaultMapId = if game:GetService("RunService"):IsStudio() then workspace:GetAttribute("Ume_StudioMapId") or "Studio" else "Lobby",
			LobbyId = "UmeLobby",
			MapConfigs = MAP_CONFIGS,
		},
		[MATCH_PLACE_ID] = {
			-- A Studio test of this place plays like the lobby place's; a teleport into it boots the map it sends
			DefaultMapId = if game:GetService("RunService"):IsStudio() then workspace:GetAttribute("Ume_StudioMapId") or "Studio" else "Match",
			LobbyId = "UmeLobby",
			MapConfigs = MAP_CONFIGS,
		},
	},
}

return _config
