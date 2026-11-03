--%%%%%%%%%%%%%%%%%%%% Data

--- @class Settings_Section
---
--- # General #
---
--- @field Text string
--- @field LayoutOrder number
---
--- # Looks #
---
--- @field Colors { Color3 }
local _settings_Section = {}

--- @class Settings_Setting
---
--- # General #
---
--- @field Section string
--- @field Text string
--- @field Detail string
--- @field LayoutOrder number
---
--- # Value #
---
--- @field Default boolean | number
---
--- # Sound #
---
--- @field SoundGroups { string }?
local _settings_Setting = {}
