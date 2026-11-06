--%%%%%%%%%%%%%%%%%%%% Metadata

--- @class Match_RosterEntry
---
--- # General #
---
--- @field UserId number
---
--- # Team #
---
--- @field Team number?
--- @field PartyId string?
local _match_RosterEntry = {}

--- @class Match_Metadata
---
--- # General #
---
--- @field MatchId string
--- @field Kind "Public" | "Solo" | "Party" | "Custom" | "Tutorial"
--- @field Mode "Deathmatch" | "Duo" | "Trio" | "Quads" | "Teams"
--- @field Size number
--- @field MapId string
--- @field Difficulty "Easy" | "Medium" | "Hard" | "Tutorial" | "None"
---
--- # Players #
---
--- @field Roster { Match_RosterEntry }
--- @field AccessCode string?
local _match_Metadata = {}

--%%%%%%%%%%%%%%%%%%%% Participants

--- @class Match_Participant : Worms_Participant
---
--- # Match #
---
--- @field Loadout { string }
--- @field Difficulty string?
--- @field Connected boolean
--- @field Out boolean
--- @field ShinyItems { [string]: boolean }?
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
