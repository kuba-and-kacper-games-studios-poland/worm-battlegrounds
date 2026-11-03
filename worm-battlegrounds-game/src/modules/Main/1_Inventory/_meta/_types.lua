--%%%%%%%%%%%%%%%%%%%% Item Module

--- @class Inventory_ItemData : Inventory_UseData
---
--- # Identity #
---
--- @field Name string
--- @field IconId string
---
--- # Classification #
---
--- @field Rarity string
--- @field Category string
--- @field RemoveByClientRequest boolean?
--- @field UseByClientRequest boolean?
---
--- # Setup #
---
--- @field _setupFunction () -> ()
local _inventory_ItemData = {}

--- @class Inventory_UseData
--- @field Use (player: Player, quantity: string) -> boolean
--- @field UseRequirements (player: Player, quantity: string) -> boolean
local _inventory_UseData = {}

--%%%%%%%%%%%%%%%%%%%% Inventory Item

--- @class Inventory_UniqueItem
--- @field Id string
--- @field Metadata Inventory_UniqueMetadata
local _inventory_UniqueItem = {}

--- @class Inventory_UniqueMetadata
--- @field _q string
--- @field _cts number
--- @field _fo number
local _inventory_UniqueMetadata = {}

--%%%%%%%%%%%%%%%%%%%% Inventory Data

--- @alias Inventory_DataType "Standard" | "Unique" | "Locked" | "UniqueAmount"
--- @alias Inventory_Data { [string]: string } | { [string]: boolean } | table | number
--- @alias Inventory_NetworkData { [string]: string } | { [string]: Inventory_UniqueItem } | { string } | number

--- @alias Inventory_NetworkChanges { [string]: string | Inventory_UniqueItem | boolean }
local _inventory_NetworkChanges = {}

--%%%%%%%%%%%%%%%%%%%% Profile Data

--- @class Player_ProfileData_Inventory
--- @field Standard { [string]: string }
--- @field Unique { [string]: Inventory_UniqueItem }
--- @field Locked { string }
--- @field UniqueAmount number
local _player_ProfileData_Inventory = {}
