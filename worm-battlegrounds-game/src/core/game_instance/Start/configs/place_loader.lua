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
local MATCH_ONLY = { "Arena", "Worms", "WormControl", "Combat", "Match", "Bots", "MatchCamera", "MatchHud", "MatchRewards" } --- @type { string }

-- Off on the Match map
local LOBBY_ONLY = { "Lobby", "MatchBoard", "Party", "Crates" } --- @type { string }

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

--- @class Ume_Config_PlaceLoader
local _config = {

	--%%%%%%%%%%%%%%%%%%%% General

	--[[
		Id of the default starting place (where players join the game and where the main lobby is located).
		You should point it to a specific place if the game works across multiple places.
	]]
	DefaultPlaceId = game.PlaceId,

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
		[game.PlaceId] = {
			-- In Studio, the Workspace attribute Ume_StudioMapId ("Match") boots a match to test without teleports
			DefaultMapId = (game:GetService("RunService"):IsStudio() and workspace:GetAttribute("Ume_StudioMapId")) or "Lobby",
			LobbyId = "UmeLobby",

			MapConfigs = {
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
					ReturnPlaceId = game.PlaceId,
				},
			},
		},
	},
}

return _config
