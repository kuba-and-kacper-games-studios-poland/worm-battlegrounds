--%%%%%%%%%%%%%%%%%%%% Shots

--- @class Combat_Shot
---
--- # General #
---
--- @field ParticipantId string
--- @field ItemId string
--- @field Row Arsenal_WeaponData
--- @field Shiny boolean
---
--- # Aim #
---
--- @field Origin Vector3
--- @field Direction Vector3
--- @field Angle number
--- @field Power number
--- @field Facing number
--- @field Target Vector3?
---
--- # Result #
---
--- @field Damage number
--- @field Shooter Model
local _combat_Shot = {}

--- @class Combat_Behavior
---
--- # General #
---
--- @field Run (shot: Combat_Shot) -> ()
local _combat_Behavior = {}
