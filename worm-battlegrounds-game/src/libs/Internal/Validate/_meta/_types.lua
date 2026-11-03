--%%%%%%%%%%%%%%%%%%%% Schema

--[[
	One argument slot of a schema. Exactly one of `Type` / `Types` is set.
]]
--- @class Validate_SchemaSpec
---
--- # Type #
---
--- @field Type string?
--- @field Types { string }?
--- @field ClassName string?
--- @field Optional boolean?
---
--- # Bounds #
---
--- @field Min number | string?
--- @field Max number | string?
---
--- # Table #
---
--- @field Length number?
--- @field MinLength number?
--- @field MaxLength number?
--- @field Elements { Validate_SchemaEntry }?
local _validate_SchemaSpec = {}

--- @alias Validate_SchemaEntry string | Validate_SchemaSpec
--- @alias Validate_ArgumentSchema { Validate_SchemaEntry }

--%%%%%%%%%%%%%%%%%%%% Internal

--[[
	Private table shared between the Validate scripts.
]]
--- @class Validate_Internal
---
--- # Scripts #
---
--- @field BigNum Validate_BigNum
--- @field Schema Validate_Schema
--- @field Match Validate_Match
--- @field Constraints Validate_Constraints
--- @field ValidateValue Validate_ValidateValue
local _validate_Internal = {}
