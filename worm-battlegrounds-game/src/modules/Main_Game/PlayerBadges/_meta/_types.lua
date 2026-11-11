--%%%%%%%%%%%%%%%%%%%% Badges

--- @class PlayerBadges_Badge
---
--- # General #
---
--- @field Id string
---
--- # Look #
---
--- @field Image string?
--- @field Glyph string?
local _playerBadges_Badge = {}

--%%%%%%%%%%%%%%%%%%%% Labels

--- @class PlayerBadges_Label
---
--- # General #
---
--- @field UserId number
--- @field PlayerConnection RBXScriptConnection?
---
--- # Layout #
---
--- @field Size UDim2
--- @field Position UDim2
--- @field Frame Frame
--- @field Badges { ImageLabel }
---
--- # Text #
---
--- @field Constraint UITextSizeConstraint
--- @field MaxTextSize number
--- @field Width number?
local _playerBadges_Label = {}
