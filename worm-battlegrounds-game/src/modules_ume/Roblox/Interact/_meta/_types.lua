--%%%%%%%%%%%%%%%%%%%% Prompt Style

--- @class Interact_PromptStyle
--- @field CreatePrompt (prompt: ProximityPrompt, inputType: Enum.ProximityPromptInputType, gui: ScreenGui) -> (() -> ())
local _interact_PromptStyle = {}

--%%%%%%%%%%%%%%%%%%%% Mapping

--- @class Interact_Mapping
---
--- # Gamepad #
---
--- @field GamepadButtonImage { [Enum.KeyCode]: string }
--- @field PlayStationButtonImage { [Enum.KeyCode]: string }
---
--- # Keyboard #
---
--- @field KeyboardButtonImage { [Enum.KeyCode]: string }
--- @field KeyboardButtonIconMapping { [string]: string }
--- @field KeyCodeToTextMapping { [Enum.KeyCode]: string }
---
--- # Prompt #
---
--- @field KeyCapImage string
--- @field TouchTapImage string
--- @field RadialFillImage string
local _interact_Mapping = {}

--%%%%%%%%%%%%%%%%%%%% Press

--- @class Interact_PressConnection
--- @field Disconnect (self: Interact_PressConnection) -> ()
local _interact_PressConnection = {}
