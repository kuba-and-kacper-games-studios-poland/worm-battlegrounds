--%%%%%%%%%%%%%%%%%%%% Content

--[[
	What the box shows for one hovered element. Only `Name` is needed; a part left out is hidden.
]]
--- @class HoverInfo_Content
---
--- # General #
---
--- @field Name string
--- @field Rarity string?
--- @field Tier number?
---
--- # Parts #
---
--- @field Stats { HoverInfo_Stat }?
--- @field Level HoverInfo_Level?
--- @field Enchantments { HoverInfo_Enchantment }?
local _hoverInfo_Content = {}

--- @class HoverInfo_Stat
---
--- # General #
---
--- @field Label string
--- @field Value string
---
--- # Look #
---
--- @field Color Color3?
--- @field Badge HoverInfo_Badge?
local _hoverInfo_Stat = {}

--[[
	A short mark in a column after a stat's label (a stat's grade): its text, its gradient top to bottom (three
	colours) and its outline.
]]
--- @class HoverInfo_Badge
---
--- # General #
---
--- @field Text string
---
--- # Look #
---
--- @field Colors { Color3 }
--- @field Stroke Color3
local _hoverInfo_Badge = {}

--[[
	A level row: `Xp` is the text right of the level ("340 / 1,200 XP", "Max"), `Progress` (0 to 1) fills the XP bar.
]]
--- @class HoverInfo_Level
---
--- # General #
---
--- @field Level string
---
--- # Progress #
---
--- @field Xp string
--- @field Progress number
local _hoverInfo_Level = {}

--- @class HoverInfo_Enchantment
---
--- # General #
---
--- @field Name string
--- @field Level number
local _hoverInfo_Enchantment = {}

--%%%%%%%%%%%%%%%%%%%% Providers

--- @alias HoverInfo_Provider (target: GuiObject) -> HoverInfo_Content?
local _hoverInfo_Provider = {}

--[[
	How the shown box is placed: by the mouse, or above the element for a finger or a gamepad's pick.
]]
--- @alias HoverInfo_Input "Mouse" | "Touch" | "Gamepad"
local _hoverInfo_Input = {}
