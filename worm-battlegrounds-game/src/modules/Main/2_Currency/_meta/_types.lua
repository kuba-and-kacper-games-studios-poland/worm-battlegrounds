--%%%%%%%%%%%%%%%%%%%% Settings

--- @class Currency_CurrencySettings
---
--- # Defaults #
---
--- @field DefaultValue string
--- @field IconId string
---
--- # Limits #
---
--- @field MinValue string
--- @field MaxValue string
--- @field RespectMinValue boolean
--- @field RespectMaxValue boolean
---
--- # Updates #
---
--- @field ServerUpdate boolean
--- @field ServerUpdateIndividual boolean
--- @field ClientUpdate boolean
--- @field ClientUpdateIndividual boolean
local _currency_CurrencySettings = {}

--- @class Currency_Conversion
---
--- # Currencies #
---
--- @field From string
--- @field To string
---
--- # Rate #
---
--- @field Per string
local _currency_Conversion = {}

--%%%%%%%%%%%%%%%%%%%% Server

--- @class Currency_CurrencyData
--- @field Amount string
--- @field TotalEarned string
--- @field TotalSpent string
--- @field HighestOwned string
local _currency_CurrencyData = {}
