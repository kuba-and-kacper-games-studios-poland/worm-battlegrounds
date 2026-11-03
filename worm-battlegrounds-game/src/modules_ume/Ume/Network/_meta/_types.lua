--%%%%%%%%%%%%%%%%%%%% Remote Options

--- @class Network_RemoteOptions
---
--- # Rate Limit #
---
--- @field RateLimit number?
--- @field Per number?
local _network_RemoteOptions = {}

--%%%%%%%%%%%%%%%%%%%% Player State

--- @class Network_RateWindow
--- @field Start number
--- @field Count number
local _network_RateWindow = {}

--- @class Network_RejectWarn
--- @field Last number
--- @field Dropped number
local _network_RejectWarn = {}

--%%%%%%%%%%%%%%%%%%%% Stats

--- @class Network_RemoteStats
---
--- # Calls #
---
--- @field In number
--- @field Out number
---
--- # Bytes #
---
--- @field InBytes number
--- @field OutBytes number
local _network_RemoteStats = {}
