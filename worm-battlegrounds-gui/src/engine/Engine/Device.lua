--[[
	Created By: 	Nari
]]

local _localName: string = "Device"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Engine

local Primitives = require(script.Parent.Parent:FindFirstChild("Primitives")) --- @type UmeGui_Primitives

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Devices ]]

-- The platforms the framework tells apart (`I.Platform.Current`), in the order tools list them
local DEVICES = { "Desktop", "Mobile", "Console", "VR" } --- @type { UmeGui_Device }
-- Every gui supports it
local DEFAULT_DEVICE: string = "Desktop"
-- The only device console key hints show on
local HINT_DEVICE: string = "Console"

--[[ Pads ]]

-- The gamepads a console shows icons for (the theme's `Gamepad.lua`); guis are built with the first one's icons
local PADS = { "Xbox", "PlayStation" } --- @type { UmeGui_Pad }

--[[ Tags ]]

local SIZE_TAG: string = "Utils_PlatformSize"
local SCALE_TAG: string = "Utils_PlatformScale"
local VISIBILITY_TAG: string = "Utils_HideOnPlatform"
local HINT_TAG: string = "Console_Hint"
-- A hint with this attribute set to true stays hidden on Console too, as ume's Console module keeps it
local HINT_HIDDEN_ATTRIBUTE: string = "Console_HintHidden"
-- Each platform component reads one attribute per device, `Utils_<Device><Suffix>`
local ATTRIBUTE_SUFFIXES = { [SIZE_TAG] = "Size", [SCALE_TAG] = "Scale", [VISIBILITY_TAG] = "Visibility" } --- @type { [string]: string }

--[[ Saved ]]

-- Each view's instances as built, saved the first time a device rule changes them. Weak by view, so they go with it
local viewDefaults = setmetatable({}, { __mode = "k" }) --- @type { [UmeGui_View]: { [Instance]: UmeGui_DeviceDefaults } }
-- Each theme's gamepad icons by image, built once per `Gamepad.lua` table
local themeIcons = setmetatable({}, { __mode = "k" }) --- @type { [UmeGui_Gamepad]: { [string]: UmeGui_GamepadIcon } }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Rule

--[[
	Returns what a platform component does on an instance for one device: the size or scale it sets (nil when the
	attribute is missing or zero, which keeps the built one), or whether the element may show (unless its attribute
	is false, as the framework's HideOnPlatform reads it).
]]
--- @return any
local function getRule(instance: Instance, tag: string, device: string)
	--[[ Data ]]

	local value: any = instance:GetAttribute(`Utils_{device}{ATTRIBUTE_SUFFIXES[tag]}`)

	--[[ Returning ]]

	if tag == VISIBILITY_TAG then
		return value ~= false
	elseif tag == SIZE_TAG then
		return if typeof(value) == "UDim2" and value ~= UDim2.new() then value else nil
	end
	return if type(value) == "number" and value ~= 0 then value else nil
end

--%%%%%%%%%%%%%%%%%%%% Get Tree

--[[
	Returns an instance and every descendant of it.
]]
--- @return { Instance }
local function getTree(root: Instance)
	--[[ Collecting ]]

	local instances = root:GetDescendants() --- @type { Instance }
	table.insert(instances, 1, root)

	--[[ Returning ]]

	return instances
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--   __       __                  __            __
--  /  \     /  |                /  |          /  |
--  $$  \   /$$ |  ______    ____$$ | __    __ $$ |  ______
--  $$$  \ /$$$ | /      \  /    $$ |/  |  /  |$$ | /      \
--  $$$$  /$$$$ |/$$$$$$  |/$$$$$$$ |$$ |  $$ |$$ |/$$$$$$  |
--  $$ $$ $$/$$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |$$    $$ |
--  $$ |$$$/ $$ |$$ \__$$ |$$ \__$$ |$$ \__$$ |$$ |$$$$$$$$/
--  $$ | $/  $$ |$$    $$/ $$    $$ |$$    $$/ $$ |$$       |
--  $$/      $$/  $$$$$$/   $$$$$$$/  $$$$$$/  $$/  $$$$$$$/
--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--- @class UmeGui_Engine_Device
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Shows a whole view, prefab clones included, as the game does on a device, with `pad`'s icons on Console (Xbox
	when nil). Keeps both for clones built into the view later. Instances without device rules are left alone.
]]
--- @param view UmeGui_View
--- @param device UmeGui_Device
--- @param pad UmeGui_Pad | nil
function Module.Apply(view, device, pad)
	--[[ Checks ]]

	-- Check if the device is one the framework knows
	if not table.find(DEVICES, device) then
		error(`[{_localName}]: Unknown device ({tostring(device)})! Expected one of: {table.concat(DEVICES, ", ")}`, 3)
	end

	-- Check if the pad is one the gamepad icons have
	if pad ~= nil and not table.find(PADS, pad) then
		error(`[{_localName}]: Unknown pad ({tostring(pad)})! Expected one of: {table.concat(PADS, ", ")}`, 3)
	end

	--[[ Applying ]]

	view.Device = device
	view.Pad = pad or PADS[1]
	Module._applyTree(view, view.Root)
end

--%%%%%%%%%%%%%%%%%%%% Apply Clone

--[[
	Shows a prefab clone just built into a view on the view's device, before any script changes it. Does nothing
	until a device was applied to the view (exports, plugin widgets).
]]
--- @param view UmeGui_View
function Module.ApplyClone(view, root: Instance)
	--[[ Checks ]]

	-- Skip views no device was applied to
	if not view.Device then
		return
	end

	--[[ Applying ]]

	Module._applyTree(view, root)
end

--%%%%%%%%%%%%%%%%%%%% Apply Tree

--[[
	Applies the view's device to an instance and its descendants, after forgetting the defaults of instances that
	left the view (destroyed prefab clones).
]]
--- @param view UmeGui_View
function Module._applyTree(view, root: Instance)
	--[[ Data ]]

	local defaults = viewDefaults[view] or {} --- @type { [Instance]: UmeGui_DeviceDefaults }
	viewDefaults[view] = defaults

	--[[ Forgetting ]]

	--- @param _saved UmeGui_DeviceDefaults
	for instance: Instance, _saved in pairs(defaults) do
		-- Drop instances that are no longer in the view
		if instance ~= view.Root and not instance:IsDescendantOf(view.Root) then
			defaults[instance] = nil
		end
	end

	--[[ Applying ]]

	local icons = Module._getIcons(view.Theme) --- @type { [string]: UmeGui_GamepadIcon }
	for _index: number, instance: Instance in ipairs(getTree(root)) do
		Module._applyInstance(view, defaults, icons, instance)
	end
end

--%%%%%%%%%%%%%%%%%%%% Apply Instance

--[[
	Applies the view's device to one instance. A console hint shows on Console even when built hidden, the way the
	game's Console_Hint does; an element a platform rule allows shows as built; both are hidden elsewhere. A missing
	or zero size or scale keeps the built one. A gamepad icon shows the view's pad on Console and as built elsewhere.
]]
--- @param view UmeGui_View
--- @param defaults { [Instance]: UmeGui_DeviceDefaults }
--- @param icons { [string]: UmeGui_GamepadIcon }
function Module._applyInstance(view, defaults, icons, instance: Instance)
	--[[ Local Variables ]]

	local device: string = view.Device
	local hasSize: boolean = instance:HasTag(SIZE_TAG)
	local hasScale: boolean = instance:HasTag(SCALE_TAG)
	local hasVisibility: boolean = instance:HasTag(VISIBILITY_TAG)
	local isHint: boolean = instance:HasTag(HINT_TAG)
	local isImage: boolean = instance:IsA("ImageLabel") or instance:IsA("ImageButton")
	local icon = if isImage then icons[defaults[instance] and defaults[instance].Image or instance.Image] else nil --- @type UmeGui_GamepadIcon?

	--[[ Checks ]]

	-- Skip instances without device rules
	if not hasSize and not hasScale and not hasVisibility and not isHint and not icon then
		return
	end

	--[[ Data ]]

	local saved = defaults[instance] or Module._saveDefaults(defaults, instance) --- @type UmeGui_DeviceDefaults

	--[[ Scale ]]

	if hasScale then
		Module._setScale(saved, instance, getRule(instance, SCALE_TAG, device) or saved.Scale)
	end

	--[[ Checks ]]

	-- Size, visibility and images are GuiObject properties
	if not instance:IsA("GuiObject") then
		return
	end

	--[[ Size ]]

	if hasSize then
		instance.Size = getRule(instance, SIZE_TAG, device) or saved.Size
	end

	--[[ Visibility ]]

	-- Hidden where the platform rule says so; a console hint is forced on Console unless a module hid it, anything else
	-- shows as built
	if hasVisibility or isHint then
		local allowed: boolean = not hasVisibility or getRule(instance, VISIBILITY_TAG, device)
		local hintShown: boolean = device == HINT_DEVICE and instance:GetAttribute(HINT_HIDDEN_ATTRIBUTE) ~= true
		instance.Visible = allowed and (if isHint then hintShown else saved.Visible)
	end

	--[[ Icon ]]

	-- The same icon style and key in the picked pad's art, when the theme has it
	if icon then
		local padIcons = (view.Theme.Gamepad or {})[view.Pad] --- @type { [string]: { [string]: string } }?
		local swapped: string? = padIcons and padIcons[icon.Style] and padIcons[icon.Style][icon.Key]
		instance.Image = if device == HINT_DEVICE and swapped then swapped else saved.Image
	end
end

--%%%%%%%%%%%%%%%%%%%% Save Defaults

--[[
	Saves an instance's size, visibility, image and scale as built, before any device rule changes them.
]]
--- @param defaults { [Instance]: UmeGui_DeviceDefaults }
--- @return UmeGui_DeviceDefaults
function Module._saveDefaults(defaults, instance: Instance)
	--[[ Data ]]

	local uiScale: UIScale? = instance:FindFirstChildOfClass("UIScale")
	local saved = { --- @type UmeGui_DeviceDefaults
		Scale = if uiScale then uiScale.Scale else 1,
		UIScale = uiScale,
		Added = false,
	}
	if instance:IsA("GuiObject") then
		saved.Size = instance.Size
		saved.Visible = instance.Visible
	end
	if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
		saved.Image = instance.Image
	end

	--[[ Saving ]]

	defaults[instance] = saved

	--[[ Returning ]]

	return saved
end

--%%%%%%%%%%%%%%%%%%%% Set Scale

--[[
	Sets the scale of an instance's UIScale. Like the game's component it adds one to an instance that has none, and
	removes that one again once the built scale is back.
]]
--- @param saved UmeGui_DeviceDefaults
function Module._setScale(saved, instance: Instance, scale: number)
	--[[ Restoring ]]

	-- The built scale of an instance built without a UIScale needs none
	if scale == saved.Scale and (not saved.UIScale or saved.Added) then
		if saved.UIScale then
			saved.UIScale:Destroy()
		end
		saved.UIScale = nil
		saved.Added = false
		return
	end

	--[[ Adding ]]

	if not saved.UIScale then
		saved.UIScale = Primitives.Create("UIScale", { Parent = instance })
		saved.Added = true
	end

	--[[ Applying ]]

	saved.UIScale.Scale = scale
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Devices

--[[
	Returns the devices a built view's gui supports: its `Devices` when it lists them, otherwise Desktop plus every
	device a platform rule treats differently from Desktop, and Console for console key hints.
]]
--- @param view UmeGui_View
--- @return { UmeGui_Device }
function Module.GetDevices(view)
	--[[ Checks ]]

	-- A gui that lists its devices is taken at its word
	if view.Gui.Devices then
		return table.clone(view.Gui.Devices)
	end

	--[[ Finding ]]

	local found = { [DEFAULT_DEVICE] = true } --- @type { [string]: boolean }
	for _index: number, instance: Instance in ipairs(getTree(view.Root)) do
		if instance:HasTag(HINT_TAG) then
			found[HINT_DEVICE] = true
		end

		for tag: string, _suffix: string in pairs(ATTRIBUTE_SUFFIXES) do
			-- Skip platform components the instance does not have
			if not instance:HasTag(tag) then
				continue
			end

			local desktop: any = getRule(instance, tag, DEFAULT_DEVICE)
			for _deviceIndex: number, device: string in ipairs(DEVICES) do
				if getRule(instance, tag, device) ~= desktop then
					found[device] = true
				end
			end
		end
	end

	--[[ Collecting ]]

	local devices = {} --- @type { UmeGui_Device }
	for _index: number, device: string in ipairs(DEVICES) do
		if found[device] then
			table.insert(devices, device)
		end
	end

	--[[ Returning ]]

	return devices
end

--%%%%%%%%%%%%%%%%%%%% Get Icons

--[[
	Returns a theme's gamepad icons by image: the icon style and KeyCode of each, whatever its pad. Empty for a theme
	without a `Gamepad.lua`.
]]
--- @param theme UmeGui_Theme
--- @return { [string]: UmeGui_GamepadIcon }
function Module._getIcons(theme)
	--[[ Checks ]]

	-- Themes without gamepad icons have nothing to swap
	if not theme.Gamepad then
		return {}
	end

	-- Reuse the icons of a gamepad table already read
	if themeIcons[theme.Gamepad] then
		return themeIcons[theme.Gamepad]
	end

	--[[ Collecting ]]

	local icons = {} --- @type { [string]: UmeGui_GamepadIcon }
	--- @param styles { [string]: { [string]: string } }
	for _pad: string, styles in pairs(theme.Gamepad) do
		--- @param keys { [string]: string }
		for style: string, keys in pairs(styles) do
			for key: string, image: string in pairs(keys) do
				icons[image] = { Style = style, Key = key }
			end
		end
	end

	--[[ Saving ]]

	themeIcons[theme.Gamepad] = icons

	--[[ Returning ]]

	return icons
end

return Module
