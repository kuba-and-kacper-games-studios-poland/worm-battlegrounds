--[[
	Created By: 	Nari
]]

--- @type Interact_Mapping
local _data = {

	--[[ Gamepad ]]

	GamepadButtonImage = {

		--[[ Xbox: Face Buttons ]]

		[Enum.KeyCode.ButtonA] = "rbxassetid://103071941845881",
		[Enum.KeyCode.ButtonB] = "rbxassetid://74076879938391",
		[Enum.KeyCode.ButtonX] = "rbxassetid://133383475364530",
		[Enum.KeyCode.ButtonY] = "rbxassetid://104537336041952",

		--[[ Xbox: Bumpers And Triggers ]]

		[Enum.KeyCode.ButtonL1] = "rbxassetid://80959482436349",
		[Enum.KeyCode.ButtonR1] = "rbxassetid://84528545812415",
		[Enum.KeyCode.ButtonL2] = "rbxassetid://106066166694007",
		[Enum.KeyCode.ButtonR2] = "rbxassetid://96098638212712",

		--[[ Xbox: View And Menu ]]

		[Enum.KeyCode.ButtonSelect] = "rbxassetid://113471370750151",
		[Enum.KeyCode.ButtonStart] = "rbxassetid://107183929542227",

		--[[ Both Pads: D-Pad ]]

		[Enum.KeyCode.DPadLeft] = "rbxassetid://92386343417710",
		[Enum.KeyCode.DPadRight] = "rbxassetid://99916724510689",
		[Enum.KeyCode.DPadUp] = "rbxassetid://107900852577789",
		[Enum.KeyCode.DPadDown] = "rbxassetid://124048932677015",

		--[[ Both Pads: Sticks ]]

		[Enum.KeyCode.ButtonL3] = "rbxassetid://122738465446085",
		[Enum.KeyCode.ButtonR3] = "rbxassetid://81303670549447",
		[Enum.KeyCode.Thumbstick1] = "rbxassetid://123044506019527",
		[Enum.KeyCode.Thumbstick2] = "rbxassetid://71815141965061",
	},

	PlayStationButtonImage = {

		--[[ PlayStation 5: Face Buttons (Cross, Circle, Square, Triangle) ]]

		[Enum.KeyCode.ButtonA] = "rbxassetid://131530513262582",
		[Enum.KeyCode.ButtonB] = "rbxassetid://135452612773255",
		[Enum.KeyCode.ButtonX] = "rbxassetid://85476248519625",
		[Enum.KeyCode.ButtonY] = "rbxassetid://137838206739844",

		--[[ PlayStation 5: L1, R1, L2, R2 ]]

		[Enum.KeyCode.ButtonL1] = "rbxassetid://73996831834050",
		[Enum.KeyCode.ButtonR1] = "rbxassetid://129746557480966",
		[Enum.KeyCode.ButtonL2] = "rbxassetid://74159896636516",
		[Enum.KeyCode.ButtonR2] = "rbxassetid://132038459956966",

		--[[ PlayStation 5: Create And Options ]]

		[Enum.KeyCode.ButtonSelect] = "rbxassetid://97981854163910",
		[Enum.KeyCode.ButtonStart] = "rbxassetid://83210153263155",
	},

	--[[ Keyboard ]]

	KeyboardButtonImage = {
		[Enum.KeyCode.Backspace] = "rbxassetid://119900925687895",
		[Enum.KeyCode.Return] = "rbxassetid://104887016533186",
		[Enum.KeyCode.LeftShift] = "rbxassetid://106265113096942",
		[Enum.KeyCode.RightShift] = "rbxassetid://106265113096942",
		[Enum.KeyCode.Tab] = "rbxassetid://114270946725163",
	},

	KeyboardButtonIconMapping = {
		["'"] = "rbxassetid://78899369255536",
		[","] = "rbxassetid://134882118607181",
		["`"] = "rbxassetid://108854068468385",
		["."] = "rbxassetid://138921363083977",
		[" "] = "rbxassetid://82988992201453",
	},

	KeyCodeToTextMapping = {
		[Enum.KeyCode.LeftControl] = "Ctrl",
		[Enum.KeyCode.RightControl] = "Ctrl",
		[Enum.KeyCode.LeftAlt] = "Alt",
		[Enum.KeyCode.RightAlt] = "Alt",
		[Enum.KeyCode.F1] = "F1",
		[Enum.KeyCode.F2] = "F2",
		[Enum.KeyCode.F3] = "F3",
		[Enum.KeyCode.F4] = "F4",
		[Enum.KeyCode.F5] = "F5",
		[Enum.KeyCode.F6] = "F6",
		[Enum.KeyCode.F7] = "F7",
		[Enum.KeyCode.F8] = "F8",
		[Enum.KeyCode.F9] = "F9",
		[Enum.KeyCode.F10] = "F10",
		[Enum.KeyCode.F11] = "F11",
		[Enum.KeyCode.F12] = "F12",
	},

	--[[ Prompt ]]

	KeyCapImage = "rbxassetid://102035766435747",
	TouchTapImage = "rbxassetid://111835512042556",
	RadialFillImage = "rbxassetid://126129840703497",
}

return _data
