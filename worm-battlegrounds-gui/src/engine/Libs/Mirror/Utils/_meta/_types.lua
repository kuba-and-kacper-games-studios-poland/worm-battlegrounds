--%%%%%%%%%%%%%%%%%%%% Button Scale

--- @class UmeGui_Utils_ButtonScaleAnimation
---
--- # Phases #
---
--- @field Hover { UmeGui_Utils_ButtonScaleStep }
--- @field Leave { UmeGui_Utils_ButtonScaleStep }
--- @field Press { UmeGui_Utils_ButtonScaleStep }
--- @field Release { UmeGui_Utils_ButtonScaleStep }
local _utils_ButtonScaleAnimation = {}

--- @class UmeGui_Utils_ButtonScaleStep
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

--- @alias UmeGui_Utils_ButtonScalePhase "Hover" | "Leave" | "Press" | "Release"
local _utils_ButtonScalePhase = {}

--%%%%%%%%%%%%%%%%%%%% Button Transform

--- @class UmeGui_Utils_ButtonTransform_PositionEntry
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

--- @class UmeGui_Utils_GuiVisibilityConnection
--- @field Disconnect (self: UmeGui_Utils_GuiVisibilityConnection) -> ()
local _utils_GuiVisibilityConnection = {}

--%%%%%%%%%%%%%%%%%%%% Button Press

--- @class UmeGui_Utils_ButtonPressConnection
--- @field Disconnect (self: UmeGui_Utils_ButtonPressConnection) -> ()
local _utils_ButtonPressConnection = {}

--- @alias UmeGui_Utils_ButtonPressPhase "Down" | "Up" | "Activated"
local _utils_ButtonPressPhase = {}

--%%%%%%%%%%%%%%%%%%%% Letter Text

--- @class UmeGui_Utils_LetterTextLetter
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

--- @class UmeGui_Utils_LetterTextSparkle
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

--- @class UmeGui_Utils_LetterTextMote
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
