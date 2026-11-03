--%%%%%%%%%%%%%%%%%%%% Data

--- @class Limited_LimitedData
---
--- # General #
---
--- @field Name string
---
--- # Limits #
---
--- @field ProductId string
--- @field MaximumAmount number
--- @field AmountPerPlayer number
---
--- # Reward #
---
--- @field Reward (player: Player) -> boolean?
local _limited_LimitedData = {}

--%%%%%%%%%%%%%%%%%%%% Messaging

--- @class Limited_SaleMessage
---
--- # Message #
---
--- @field Data any
--- @field Sent number
local _limited_SaleMessage = {}
