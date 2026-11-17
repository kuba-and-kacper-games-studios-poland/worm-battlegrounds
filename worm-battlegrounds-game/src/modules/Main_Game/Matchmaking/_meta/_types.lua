--%%%%%%%%%%%%%%%%%%%% Matches

--- @class Matchmaking_Card
---
--- # Player #
---
--- @field DisplayName string
--- @field Vip boolean
--- @field Level number
---
--- # Match #
---
--- @field Loadout { string }
--- @field ShinyItems { [string]: boolean }
--- @field GoldenItems { [string]: boolean }
--- @field Skin string
--- @field Shiny boolean
local _matchmaking_Card = {}

--- @class Matchmaking_Lobby
---
--- # General #
---
--- @field Id string
--- @field AccessCode string?
--- @field Open boolean
--- @field EndsAt number
---
--- # Match #
---
--- @field Mode string
--- @field Size number
--- @field TeamSize number
--- @field MapId string
--- @field Roster { Match_RosterEntry }
local _matchmaking_Lobby = {}

--- @class Matchmaking_LocalEntry
---
--- # General #
---
--- @field Value string
--- @field ExpiresAt number
local _matchmaking_LocalEntry = {}
