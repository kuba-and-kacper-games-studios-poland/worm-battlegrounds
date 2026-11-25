--%%%%%%%%%%%%%%%%%%%% Metadata

--- @class Match_RosterEntry
---
--- # General #
---
--- @field UserId number
--- @field Guest number?
---
--- # Team #
---
--- @field Team number?
--- @field PartyId string?
---
--- # Seat #
---
--- @field Card Matchmaking_Card?
local _match_RosterEntry = {}

--- @class Match_Metadata
---
--- # General #
---
--- @field MatchId string
--- @field Kind "Public" | "Solo" | "Party" | "Custom" | "Tutorial" | "Local"
--- @field Mode "Deathmatch" | "Duo" | "Trio" | "Quads" | "Teams"
--- @field Size number
--- @field MapId string
--- @field Difficulty "Easy" | "Medium" | "Hard" | "Nightmare" | "Tutorial" | "None"
--- @field Wind boolean?
---
--- # Display #
---
--- @field ModeName string?
--- @field ModeIcon string?
--- @field MapName string?
---
--- # Players #
---
--- @field Roster { Match_RosterEntry }
--- @field AccessCode string?
--- @field LobbyId string?
local _match_Metadata = {}

--%%%%%%%%%%%%%%%%%%%% Waiting Room

--- @class Match_RoomSeat
---
--- # General #
---
--- @field UserId number
--- @field Name string
---
--- # State #
---
--- @field Ready boolean
--- @field Here boolean
local _match_RoomSeat = {}

--%%%%%%%%%%%%%%%%%%%% Participants

--- @class Match_Participant : Snails_Participant
---
--- # Match #
---
--- @field Loadout { string }
--- @field Difficulty string?
--- @field Connected boolean
--- @field Out boolean
--- @field ShinyItems { [string]: boolean }?
--- @field GoldenItems { [string]: boolean }?
--- @field ItemLooks { [string]: string }?
--- @field Guest number?
local _match_Participant = {}

--- @class Match_Placement
---
--- # General #
---
--- @field ParticipantId string
--- @field Place number
local _match_Placement = {}

--%%%%%%%%%%%%%%%%%%%% Stats

--- @class Match_Stats
---
--- # Totals #
---
--- @field Damage number
--- @field Knockouts number
--- @field Rounds number
---
--- # Best #
---
--- @field BestShot number
local _match_Stats = {}

--%%%%%%%%%%%%%%%%%%%% Turns

--- @class Match_Team
---
--- # General #
---
--- @field Team number
--- @field Members { string }
--- @field Next number
local _match_Team = {}

--- @class Match_TeamStyle
---
--- # General #
---
--- @field Name string
--- @field Color Color3
local _match_TeamStyle = {}
