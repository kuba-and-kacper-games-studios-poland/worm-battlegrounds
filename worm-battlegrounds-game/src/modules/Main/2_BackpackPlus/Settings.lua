--- @class BackpackPlus_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% General

	-- Visible Toolbar slot counts by platform. Missing platforms fall back to Default.
	--- @type { [string]: number }
	TOOLBAR_SLOTS = {
		["Default"] = 10,
		["Mobile"] = 6,
	},

	-- KeyCode to Toolbar slot index mappings.
	--- @type { [Enum.KeyCode]: number }
	TOOLBAR_KEY_MAPPINGS = {
		[Enum.KeyCode.One] = 1,
		[Enum.KeyCode.Two] = 2,
		[Enum.KeyCode.Three] = 3,
		[Enum.KeyCode.Four] = 4,
		[Enum.KeyCode.Five] = 5,
		[Enum.KeyCode.Six] = 6,
		[Enum.KeyCode.Seven] = 7,
		[Enum.KeyCode.Eight] = 8,
		[Enum.KeyCode.Nine] = 9,
		[Enum.KeyCode.Zero] = 10,
	},

	--%%%%%%%%%%%%%%%%%%%% Toolbar

	-- Should the Toolbar order be saved across sessions.
	TOOLBAR_SAVE = true,

	-- Delay after which Toolbar Slots order is being loaded from server after character creation.
	TOOLBAR_FILL_DELAY = 1,

	-- Only fills the Toolbar when no saved slots were moved. With TOOLBAR_SAVE off the Toolbar always fills.
	TOOLBAR_FILL_ONLY_WHEN_EMPTY = true,

	-- Fills remaining Toolbar slots once when joining with more slots than the previous platform.
	TOOLBAR_FILL_ON_PLATFORM_CHANGED = true,

	--%%%%%%%%%%%%%%%%%%%% Favorite

	-- UIGradient name used while favorite mode is active.
	FAVORITE_GRADIENT_NAME = "Gold",

	-- Elastic pop-in for the slot favorite icon.
	FAVORITE_ICON_SHOW_TWEEN = TweenInfo.new(0.45, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),

	-- Hide tween for the slot favorite icon.
	FAVORITE_ICON_HIDE_TWEEN = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),

	--%%%%%%%%%%%%%%%%%%%% Display

	VIEWPORT_CAMERA_FOV = 7.5,
	VIEWPORT_CAMERA_CFRAME = CFrame.lookAt(Vector3.new(0, 0, -10), Vector3.new(0, 0, 0)),

	--[[
		Table with custom display updates functions, initialized by setting `BackpackPlus_DisplayType` Attribute on Tool.
		Loaded from Data/DisplayType modules on the client.
	]]
	--- @type { [string]: (slotData: BackpackPlus_SlotData, viewportCamera: Camera, isEquipped: boolean, equippedSlotId: number | nil) -> () }
	CUSTOM_DISPLAY_UPDATES = {},
}

return _settings
