--%%%%%%%%%%%%%%%%%%%% Button Scale

--- @class Utils_ButtonScaleAnimation
---
--- # Phases #
---
--- @field Hover { Utils_ButtonScaleStep }
--- @field Leave { Utils_ButtonScaleStep }
--- @field Press { Utils_ButtonScaleStep }
--- @field Release { Utils_ButtonScaleStep }
local _utils_ButtonScaleAnimation = {}

--- @class Utils_ButtonScaleStep
---
--- # Goal #
---
--- @field Scale number
--- @field Rotation number?
---
--- # Timing #
---
--- @field Time number
--- @field EasingStyle Enum.EasingStyle
--- @field EasingDirection Enum.EasingDirection
local _utils_ButtonScaleStep = {}

--- @alias Utils_ButtonScalePhase "Hover" | "Leave" | "Press" | "Release"
local _utils_ButtonScalePhase = {}

--%%%%%%%%%%%%%%%%%%%% Button Transform

--- @class Utils_ButtonTransform_PositionEntry
---
--- # State #
---
--- @field State string
---
--- # Position #
---
--- @field StartPosition UDim2
--- @field TargetPosition UDim2
---
--- # Transition #
---
--- @field TransitionElapsed number
--- @field TransitionDuration number
--- @field EasingStyle Enum.EasingStyle
--- @field EasingDirection Enum.EasingDirection
---
--- # Hover #
---
--- @field ShouldHover boolean
local _utils_ButtonTransform_PositionEntry = {}

--%%%%%%%%%%%%%%%%%%%% Gui Visibility

--- @class Utils_GuiVisibilityConnection
--- @field Disconnect (self: Utils_GuiVisibilityConnection) -> ()
local _utils_GuiVisibilityConnection = {}

--%%%%%%%%%%%%%%%%%%%% Button Press

--- @class Utils_ButtonPressConnection
--- @field Disconnect (self: Utils_ButtonPressConnection) -> ()
local _utils_ButtonPressConnection = {}

--- @alias Utils_ButtonPressPhase "Down" | "Up" | "Activated"
local _utils_ButtonPressPhase = {}

--%%%%%%%%%%%%%%%%%%%% Letter Text

--- @class Utils_LetterTextLetter
---
--- # Instances #
---
--- @field Label TextLabel
--- @field Scale UIScale
--- @field Stroke UIStroke?
--- @field Guide TextLabel
--- @field Halo TextLabel?
--- @field HaloScale UIScale?
--- @field HaloStroke UIStroke?
--- @field Echo TextLabel?
--- @field EchoScale UIScale?
---
--- # Place #
---
--- @field X number
--- @field Y number
--- @field Width number
--- @field Height number
--- @field Along number
--- @field Color Color3
---
--- # Effects #
---
--- @field ShakeX number
--- @field ShakeY number
--- @field ShakeR number
--- @field Flash number
--- @field GlitchTime number
--- @field GlitchX number
--- @field GlitchColor Color3
local _utils_LetterTextLetter = {}

--- @class Utils_LetterTextSparkle
---
--- # Instances #
---
--- @field Holder Frame
--- @field Scale UIScale
--- @field Bars { Frame }
---
--- # Life #
---
--- @field Life number
--- @field Duration number
--- @field Delay number
local _utils_LetterTextSparkle = {}

--- @class Utils_LetterTextMote
---
--- # Instances #
---
--- @field Kind string
--- @field Frame Frame
--- @field Scale UIScale
--- @field Stroke UIStroke?
--- @field Parts { Frame }
---
--- # Life #
---
--- @field Life number
--- @field Duration number
--- @field Delay number
---
--- # Path #
---
--- @field X number
--- @field Y number
--- @field Sway number
local _utils_LetterTextMote = {}
