--%%%%%%%%%%%%%%%%%%%% Data

--- @alias WidgetManager_PreTranslate (widget: Frame) -> ()

--- @class WidgetManager_TweenPreset
--- @field Info TweenInfo
--- @field PreTranslate WidgetManager_PreTranslate
--- @field PostTranslate table
local _widgetManager_TweenPreset = {}

--%%%%%%%%%%%%%%%%%%%% Client

--- @alias WidgetManager_ConfirmationCallback () -> ()

--- @class WidgetManager_QueueEntry
--- @field WidgetName string
--- @field TweenName string?
local _widgetManager_QueueEntry = {}

--- @class WidgetManager_ClientContext
---
--- # Widgets #
---
--- @field CurrentlyOpened ScreenGui?
--- @field PreviouslyOpened ScreenGui?
local _widgetManager_ClientContext = {}
