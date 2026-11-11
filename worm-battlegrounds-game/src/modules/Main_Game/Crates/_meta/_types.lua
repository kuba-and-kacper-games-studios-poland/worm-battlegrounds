--%%%%%%%%%%%%%%%%%%%% Crates

--- @class Crates_CrateData
---
--- # General #
---
--- @field Name string
--- @field TabName string
--- @field LayoutOrder number
--- @field Hidden boolean
---
--- # Look #
---
--- @field Glow Color3
--- @field Accent Color3
--- @field Ambient Crates_Ambient
--- @field Premium boolean
--- @field Model string
---
--- # Contents #
---
--- @field Prices { [string]: Crates_Price }
--- @field OddsByCurrency { [string]: { [string]: number } }
--- @field Fixed { string }
local _crates_CrateData = {}

--- @class Crates_Price
---
--- # General #
---
--- @field One string
--- @field Three string
--- @field Ten string
local _crates_Price = {}

--- @class Crates_Result
---
--- # General #
---
--- @field ItemId string
--- @field Copies number
--- @field JustShiny boolean
local _crates_Result = {}

--- @alias Crates_Ambient "Embers" | "Glints" | "Bubbles" | "Sparkles"
local _crates_Ambient = {}

--%%%%%%%%%%%%%%%%%%%% Reels

--- @class Crates_Reel
---
--- # General #
---
--- @field Frame Frame
--- @field Strips { Frame }
--- @field WinCard Frame
--- @field Vertical boolean
--- @field Min Vector2
--- @field Max Vector2
---
--- # Motion #
---
--- @field Pitch number
--- @field Span number
--- @field Gap number
--- @field Middle number
--- @field From number
--- @field To number
--- @field Centre number
--- @field Position number
--- @field Start number
--- @field Delay number
--- @field Duration number
--- @field Ease (t: number) -> number
--- @field LastIndex number?
--- @field Done boolean
--- @field TickPitch number
local _crates_Reel = {}

--%%%%%%%%%%%%%%%%%%%% Stage

--- @class Crates_StageLayout
---
--- # Crates #
---
--- @field Spots { Vector3 }
--- @field Scale number
--- @field Yaw number
---
--- # Camera #
---
--- @field Camera Vector3
--- @field Focus Vector3
local _crates_StageLayout = {}

--- @class Crates_StageCrate
---
--- # Model #
---
--- @field Model Model
--- @field Parts { [string]: BasePart }
--- @field Rest { [string]: CFrame }
--- @field Orb Part?
--- @field Halo Part?
--- @field Home CFrame
--- @field Scale number
---
--- # Timing #
---
--- @field Phase number
--- @field Spin number
--- @field DropStart number
--- @field DropSeconds number
--- @field Landed boolean
--- @field OpenStart number?
--- @field Speed number
--- @field Hatched boolean
--- @field Burst boolean
---
--- # Pose #
---
--- @field Lift number?
--- @field Turn number?
--- @field Tilt CFrame?
--- @field Strain number?
--- @field Hatch number?
--- @field Wall number?
--- @field Light number?
--- @field LightHeight number?
local _crates_StageCrate = {}

--%%%%%%%%%%%%%%%%%%%% Effects

--- @alias Crates_Burst "Sparks" | "Stars" | "Coins" | "Confetti" | "Smileys" | "Bones" | "Flames" | "Bubbles" | "Ring"
local _crates_Burst = {}
