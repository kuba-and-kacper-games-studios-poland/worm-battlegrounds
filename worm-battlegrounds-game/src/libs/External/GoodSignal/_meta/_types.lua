--%%%%%%%%%%%%%%%%%%%% Connection

--- @class Signal_Connection
---
--- # State #
---
--- @field _connected boolean
--- @field _signal Signal
--- @field _fn function
--- @field _next Signal_Connection | boolean
---
--- # Methods #
---
--- @field __index Signal_Connection
--- @field new (signal: Signal, callback: function) -> Signal_Connection
--- @field Disconnect (self: Signal_Connection) -> ()
local _signal_Connection = {}

--%%%%%%%%%%%%%%%%%%%% Signal

--- @class Signal : Ume_Library
---
--- # State #
---
--- @field _handlerListHead Signal_Connection | boolean
---
--- # Methods #
---
--- @field __index Signal
--- @field new () -> Signal
--- @field Connect (self: Signal, callback: function) -> Signal_Connection
--- @field DisconnectAll (self: Signal) -> ()
--- @field Fire (self: Signal) -> nil
--- @field Wait (self: Signal) -> any
--- @field Once (self: Signal, callback: function) -> Signal_Connection
local _signal = {}
