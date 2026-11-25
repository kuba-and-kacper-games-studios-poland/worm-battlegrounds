--%%%%%%%%%%%%%%%%%%%% Progress

--- @class Progression_Progress
---
--- # Level #
---
--- @field Level number
--- @field Into number
--- @field For number
local _progression_Progress = {}

--%%%%%%%%%%%%%%%%%%%% Replay

--- @class Progression_XpLine
---
--- # General #
---
--- @field Key string
--- @field Label string
---
--- # Amount #
---
--- @field Count number
--- @field Amount number
local _progression_XpLine = {}

--- @class Progression_Replay
---
--- # Lines #
---
--- @field Lines { Progression_XpLine }
---
--- # Level #
---
--- @field Before Progression_Progress
--- @field After Progression_Progress
--- @field Costs { number }
---
--- # Diamonds #
---
--- @field Diamonds string?
local _progression_Replay = {}

--- @class Progression_PayoutLook
---
--- # Diamonds #
---
--- @field Icons number
---
--- # Sounds #
---
--- @field PopSound string
--- @field LandSound string
local _progression_PayoutLook = {}

--%%%%%%%%%%%%%%%%%%%% Weapon Rewards

--- @class Progression_WeaponReward
---
--- # General #
---
--- @field Item string
--- @field Variant string
---
--- # Unlock #
---
--- @field Line string
local _progression_WeaponReward = {}

--- @class Progression_UnlockLook
---
--- # Colours #
---
--- @field Accent Color3
--- @field Rays Color3
--- @field Gradient ColorSequence
--- @field Tag ColorSequence
--- @field Particles { Color3 }
---
--- # Sound #
---
--- @field Sound string
local _progression_UnlockLook = {}

--%%%%%%%%%%%%%%%%%%%% Frames

--- @class Progression_Tier
---
--- # General #
---
--- @field Name string
--- @field Level number
---
--- # Look #
---
--- @field Colors { Color3 }
--- @field Shine boolean
--- @field Spin boolean
local _progression_Tier = {}

--%%%%%%%%%%%%%%%%%%%% Replay Looks

--- @class Progression_ReplayTierLook
---
--- # Light #
---
--- @field Rays number
--- @field RaysBack number
--- @field Glow number
---
--- # Burst #
---
--- @field Stars number
local _progression_ReplayTierLook = {}

--- @class Progression_RewardLook
---
--- # General #
---
--- @field Icon string
--- @field Color Color3
---
--- # Kind #
---
--- @field Frame boolean
--- @field Variant string?
local _progression_RewardLook = {}
