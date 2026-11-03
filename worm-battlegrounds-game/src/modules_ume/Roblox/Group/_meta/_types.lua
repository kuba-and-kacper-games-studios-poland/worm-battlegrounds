--%%%%%%%%%%%%%%%%%%%% Data

--- @class Group_StoredData
--- @field IsMember boolean
--- @field Role string
--- @field Rank number
local _group_StoredData = {}

--- @class Group_ProxyRole
---
--- # Role #
---
--- @field Rank number
--- @field Role string
local _group_ProxyRole = {}

--%%%%%%%%%%%%%%%%%%%% Info

--- @class Group_GroupInfo
---
--- # Identity #
---
--- @field Name string
--- @field Description string
---
--- # Group Details #
---
--- @field Id number
--- @field EmblemUrl string
---
--- # Ownership #
---
--- @field Owner Group_OwnerTable?
--- @field Roles { Group_RoleTable }
local _group_GroupInfo = {}

--- @class Group_OwnerTable
--- @field Name string
--- @field Id number
local _group_OwnerTable = {}

--- @class Group_RoleTable
--- @field Name string
--- @field Rank number
local _group_RoleTable = {}
