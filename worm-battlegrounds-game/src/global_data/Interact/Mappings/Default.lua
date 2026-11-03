--[[
	Created By: 	Nari
]]

--- @type Interact_Mapping
local _data = {

	--[[ Gamepad ]]

	GamepadButtonImage = {

		--[[ Xbox: Face Buttons ]]

		[Enum.KeyCode.ButtonA] = "rbxasset://textures/ui/Controls/xboxA.png",
		[Enum.KeyCode.ButtonB] = "rbxasset://textures/ui/Controls/xboxB.png",
		[Enum.KeyCode.ButtonX] = "rbxasset://textures/ui/Controls/xboxX.png",
		[Enum.KeyCode.ButtonY] = "rbxasset://textures/ui/Controls/xboxY.png",

		--[[ Xbox: Bumpers And Triggers ]]

		[Enum.KeyCode.ButtonL1] = "rbxasset://textures/ui/Controls/xboxLB.png",
		[Enum.KeyCode.ButtonR1] = "rbxasset://textures/ui/Controls/xboxRB.png",
		[Enum.KeyCode.ButtonL2] = "rbxasset://textures/ui/Controls/xboxLT.png",
		[Enum.KeyCode.ButtonR2] = "rbxasset://textures/ui/Controls/xboxRT.png",

		--[[ Xbox: View And Menu ]]

		[Enum.KeyCode.ButtonSelect] = "rbxasset://textures/ui/Controls/xboxView.png",
		[Enum.KeyCode.ButtonStart] = "rbxasset://textures/ui/Controls/xboxmenu.png",

		--[[ Both Pads: D-Pad ]]

		[Enum.KeyCode.DPadLeft] = "rbxasset://textures/ui/Controls/dpadLeft.png",
		[Enum.KeyCode.DPadRight] = "rbxasset://textures/ui/Controls/dpadRight.png",
		[Enum.KeyCode.DPadUp] = "rbxasset://textures/ui/Controls/dpadUp.png",
		[Enum.KeyCode.DPadDown] = "rbxasset://textures/ui/Controls/dpadDown.png",

		--[[ Both Pads: Sticks ]]

		[Enum.KeyCode.ButtonL3] = "rbxasset://textures/ui/Controls/xboxLS.png",
		[Enum.KeyCode.ButtonR3] = "rbxasset://textures/ui/Controls/xboxRS.png",
		[Enum.KeyCode.Thumbstick1] = "rbxasset://textures/ui/Controls/xboxLSDirectional.png",
		[Enum.KeyCode.Thumbstick2] = "rbxasset://textures/ui/Controls/xboxRSDirectional.png",
	},

	--[[ PlayStation 5 (none: Roblox's default prompt shows the Xbox buttons on every pad) ]]

	PlayStationButtonImage = {},

	--[[ Keyboard ]]

	KeyboardButtonImage = {
		[Enum.KeyCode.Backspace] = "rbxasset://textures/ui/Controls/backspace.png",
		[Enum.KeyCode.Return] = "rbxasset://textures/ui/Controls/return.png",
		[Enum.KeyCode.LeftShift] = "rbxasset://textures/ui/Controls/shift.png",
		[Enum.KeyCode.RightShift] = "rbxasset://textures/ui/Controls/shift.png",
		[Enum.KeyCode.Tab] = "rbxasset://textures/ui/Controls/tab.png",
	},

	KeyboardButtonIconMapping = {
		["'"] = "rbxasset://textures/ui/Controls/apostrophe.png",
		[","] = "rbxasset://textures/ui/Controls/comma.png",
		["`"] = "rbxasset://textures/ui/Controls/graveaccent.png",
		["."] = "rbxasset://textures/ui/Controls/period.png",
		[" "] = "rbxasset://textures/ui/Controls/spacebar.png",
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

	KeyCapImage = "rbxasset://textures/ui/Controls/key_single.png",
	TouchTapImage = "rbxasset://textures/ui/Controls/TouchTapIcon.png",
	RadialFillImage = "rbxasset://textures/ui/Controls/RadialFill.png",
}

return _data
