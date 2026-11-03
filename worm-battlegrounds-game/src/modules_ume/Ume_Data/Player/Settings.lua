--- @class Player_Settings
local _settings = {

	--[[ General ]]

	-- task.wait() to ensure that function executed properly and data loaded.
	TASK_WAIT_AFTER_PLAYER_FUNCTION = false,

	--[[
		Time (in seconds) after which the player's character is fully cleared after his death.
		Setting the value to 0 disables the feature.
	]]
	CHARACTER_DESTROY_DELAY = 30,

	-- Should player's character automatically load after joining.
	INITIAL_CHARACTER_AUTO_LOAD = true,

	--[[
		Time (in seconds) to wait for the client framework to report loaded before kicking the player.
	]]
	CLIENT_LOAD_TIMEOUT_SECONDS = 120,

	-- Seconds to wait for the leave callbacks before the player's data is released anyway.
	REMOVING_CALLBACKS_TIMEOUT = 10,

	-- Seconds to wait for each limb of a new character before warning about it.
	LIMB_WAIT_TIMEOUT = 10,

	-- List containing all limb names for the specified `HumanoidRigType`.
	LIMB_TREES = {
		[Enum.HumanoidRigType.R6] = {
			"Head",
			"HumanoidRootPart",
			"Left Arm",
			"Left Leg",
			"Right Arm",
			"Right Leg",
			"Torso",
		},
		[Enum.HumanoidRigType.R15] = {
			"Head",
			"LeftFoot",
			"LeftHand",
			"LeftLowerArm",
			"LeftLowerLeg",
			"LeftUpperArm",
			"LeftUpperLeg",
			"LowerTorso",
			"RightFoot",
			"RightHand",
			"RightLowerArm",
			"RightLowerLeg",
			"RightUpperArm",
			"RightUpperLeg",
			"UpperTorso",
			"HumanoidRootPart",
		},
	},

	--[[ Debugging ]]

	-- Track and log runtime of individual player functions.
	DEBUG_FUNCTIONS_RUNTIME = game:GetService("RunService"):IsStudio() == true,

	-- Time threshold (in seconds) after which a function's runtime is printed to the output.
	DEBUG_FUNCTIONS_THRESHOLD = 0.1,
}
return _settings
