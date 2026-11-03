--- @class Notify_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Notification

	DEFAULT_NOTIFICATION_DURATION = 3,
	DEFAULT_NOTIFICATION_SOUND = "Notification",
	NOTIFICATION_DISPLAY_LIMIT = 15,

	--%%%%%%%%%%%%%%%%%%%% Message

	DEFAULT_MESSAGE_DURATION = 6,
	DEFAULT_MESSAGE_SOUND = "Notification",
	MESSAGE_DISPLAY_LIMIT = 6,

	--%%%%%%%%%%%%%%%%%%%% Username

	DEFAULT_USERNAME_COLOR = Color3.fromRGB(200, 200, 200),

	--- @type { [number]: Color3 }
	USERNAME_COLORS = {
		[4771447297] = Color3.fromRGB(210, 130, 255),
	},
}
return _settings
