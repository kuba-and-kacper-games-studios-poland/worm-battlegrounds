--%%%%%%%%%%%%%%%%%%%% Action

--- @class Console_Action
---
--- # Buttons #
---
--- @field Keys { Enum.KeyCode }
--- @field Priority number?
--- @field Gui boolean?
---
--- # Hint #
---
--- @field Hint string
local _console_Action = {}

--- @alias Console_ActionCallback (action: string, state: Enum.UserInputState, input: InputObject) -> Enum.ContextActionResult?
local _console_ActionCallback = {}
