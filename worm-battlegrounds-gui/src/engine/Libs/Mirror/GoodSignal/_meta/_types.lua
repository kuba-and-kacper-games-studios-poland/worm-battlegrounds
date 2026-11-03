--%%%%%%%%%%%%%%%%%%%% Connection

--- @class UmeGui_Signal_Connection
---
--- # State #
---
--- @field _connected boolean
--- @field _signal UmeGui_Signal
--- @field _fn function
--- @field _next UmeGui_Signal_Connection | boolean
---
--- # Methods #
---
--- @field __index UmeGui_Signal_Connection
--- @field new (signal: UmeGui_Signal, callback: function) -> UmeGui_Signal_Connection
--- @field Disconnect (self: UmeGui_Signal_Connection) -> ()
local _signal_Connection = {}

--%%%%%%%%%%%%%%%%%%%% Signal

--- @class UmeGui_Signal : Ume_Library
---
--- # State #
---
--- @field _handlerListHead UmeGui_Signal_Connection | boolean
---
--- # Methods #
---
--- @field __index UmeGui_Signal
--- @field new () -> UmeGui_Signal
--- @field Connect (self: UmeGui_Signal, callback: function) -> UmeGui_Signal_Connection
--- @field DisconnectAll (self: UmeGui_Signal) -> ()
--- @field Fire (self: UmeGui_Signal) -> nil
--- @field Wait (self: UmeGui_Signal) -> any
--- @field Once (self: UmeGui_Signal, callback: function) -> UmeGui_Signal_Connection
local _signal = {}
