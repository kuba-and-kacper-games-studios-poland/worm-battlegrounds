--%%%%%%%%%%%%%%%%%%%% Rows

--- @class Cosmetics_SetData
---
--- # General #
---
--- @field Name string
--- @field LayoutOrder number
---
--- # Look #
---
--- @field Model string
---
--- # Owned #
---
--- @field Skin string
local _cosmetics_SetData = {}

--- @class Cosmetics_PieceData
---
--- # General #
---
--- @field Slot "Hat" | "Neck" | "Body" | "Shell"
--- @field Set string
local _cosmetics_PieceData = {}

--- @class Cosmetics_EmoteData
---
--- # Unlock #
---
--- @field Level number
--- @field Coins string
---
--- # Look #
---
--- @field AnimationId number
--- @field VoiceSound string
local _cosmetics_EmoteData = {}

--%%%%%%%%%%%%%%%%%%%% Outfit

--- @class Cosmetics_Outfit
---
--- # Pieces #
---
--- @field Hat string
--- @field Neck string
--- @field Body string
--- @field Shell string
local _cosmetics_Outfit = {}

--- @class Cosmetics_Shot
---
--- # Camera #
---
--- @field Height number
--- @field Distance number
--- @field Turn number
local _cosmetics_Shot = {}

--- @class Cosmetics_Focus
---
--- # Camera #
---
--- @field Yaw number
--- @field Pitch number
--- @field Zoom number
--- @field Height number
local _cosmetics_Focus = {}
