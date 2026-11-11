--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Console"

--- @type Console_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Binds = require(script.Parent:FindFirstChild("Binds")) --- @type Console_Client_Binds

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Icons ]]

-- Every gamepad icon image, to the icon style and button it shows on either pad, so a hint's icon can be swapped
local iconStyles = {} --- @type { [string]: string }
local iconButtons = {} --- @type { [string]: string }

--[[ State ]]

local playStationPad: boolean = false

--[[
	Hints whose hidden attribute is followed, so each is connected once, and those already warned about. Weak, so a
	destroyed hint goes
]]
local watchedHints = setmetatable({}, { __mode = "k" }) --- @type { [Instance]: boolean }
local warnedHints = setmetatable({}, { __mode = "k" }) --- @type { [Instance]: boolean }

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

--- @class Console_Client_Hints
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Indexing ]]

	Module._indexIcons()
	playStationPad = Module.IsPlayStationPad()
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Connections ]]

	Module._connectHints()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Index Icons

--[[
	Maps every gamepad icon image in the settings to its icon style and button, for both pads.
]]
function Module._indexIcons()
	--[[ Indexing ]]

	--- @param styles { [string]: { [string]: string } }
	for _pad: string, styles in pairs(_settings.GAMEPAD_ICONS) do
		--- @param buttons { [string]: string }
		for style: string, buttons in pairs(styles) do
			for button: string, image: string in pairs(buttons) do
				iconStyles[image] = style
				iconButtons[image] = button
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Connect Hints

--[[
	Shows every hint for the current platform and pad now, on every hint added later, and again whenever the platform
	or the connected pad changes.
]]
function Module._connectHints()
	--[[ Applying ]]

	Module.RefreshHints()

	--[[ Connections ]]

	I.S.CollectionService:GetInstanceAddedSignal(_settings.HINT_TAG):Connect(Module._applyHint)
	for _index: number, hint: Instance in ipairs(I.S.CollectionService:GetTagged(_settings.HINT_TAG)) do
		Module._watchHint(hint)
	end
	I.Topic.Subscribe("Platform_Changed", function(_platform: string)
		Module.RefreshHints()
	end)
	I.S.UserInputService.GamepadConnected:Connect(Module._refreshPad)
	I.S.UserInputService.LastInputTypeChanged:Connect(Module._refreshPad)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh Hints

--[[
	**CLIENT** |
	Shows every hint on Console and hides it elsewhere, with its gamepad icons for the player's pad.
]]
function Module.RefreshHints()
	--[[ Applying ]]

	for _index: number, hint: Instance in ipairs(I.S.CollectionService:GetTagged(_settings.HINT_TAG)) do
		Module._applyHint(hint)
	end
end

--%%%%%%%%%%%%%%%%%%%% Apply Hint

--[[
	Shows a hint only on Console and swaps its gamepad icons, and those inside it, to the player's pad. A hint naming
	an action (Console_Action) shows that action's first button in HINT_STYLE, and the action's hint in its texts.
]]
function Module._applyHint(hint: Instance)
	--[[ Checks ]]

	-- Skip tagged instances that are not gui elements
	if not hint:IsA("GuiObject") then
		return
	end

	--[[ Visibility ]]

	-- A module hides a hint with nothing to show even on Console (BackpackPlus's bumpers over an empty toolbar)
	Module._watchHint(hint)
	hint.Visible = I.Platform.Current == "Console" and hint:GetAttribute(_settings.HINT_HIDDEN_ATTRIBUTE) ~= true

	--[[ Data ]]

	local actionName: string? = hint:GetAttribute(_settings.HINT_ACTION_ATTRIBUTE)
	local action = if actionName then Binds.GetAction(actionName) else nil --- @type Console_Action?

	--[[ Local Variables ]]

	local pad: string = if playStationPad then "PlayStation" else "Xbox"
	local parts = hint:GetDescendants() --- @type { Instance }
	table.insert(parts, hint)

	--[[ Checking ]]

	-- A Gui action's hint sits on a button its first button presses: warn once when the gui gave it another key
	local button: GuiButton? = if hint:IsA("GuiButton") then hint else hint:FindFirstAncestorWhichIsA("GuiButton")
	local key: string? = if button then button:GetAttribute("Utils_GamepadKey") else nil
	if action and action.Gui and key and key ~= action.Keys[1].Name and not warnedHints[hint] then
		warnedHints[hint] = true
		warn(`[{_localName}::{script.Name}]: Hint ({actionName}) is on a button pressed by ({key}), not ({action.Keys[1].Name})! -`, hint)
	end

	--[[ Icons ]]

	for _index: number, part: Instance in ipairs(parts) do
		-- An action's texts say what it does
		if action and part:IsA("TextLabel") then
			part.Text = action.Hint
			continue
		end

		-- Skip anything but images showing a gamepad icon
		if not (part:IsA("ImageLabel") or part:IsA("ImageButton")) or not iconStyles[part.Image] then
			continue
		end

		local style: string = if action then _settings.HINT_STYLE else iconStyles[part.Image]
		local name: string = if action then action.Keys[1].Name else iconButtons[part.Image]
		part.Image = _settings.GAMEPAD_ICONS[pad][style][name] or part.Image
	end
end

--%%%%%%%%%%%%%%%%%%%% Watch Hint

--[[
	Shows or hides a hint again whenever a module sets its hidden attribute, once per hint.
]]
function Module._watchHint(hint: Instance)
	--[[ Checks ]]

	-- Skip hints already followed
	if watchedHints[hint] then
		return
	end

	--[[ Connections ]]

	watchedHints[hint] = true
	hint:GetAttributeChangedSignal(_settings.HINT_HIDDEN_ATTRIBUTE):Connect(function()
		Module._applyHint(hint)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Refresh Pad

--[[
	Swaps every hint's icons when the player's pad changed between Xbox and PlayStation.
]]
function Module._refreshPad()
	--[[ Checks ]]

	-- Skip when the pad kind is the same
	if Module.IsPlayStationPad() == playStationPad then
		return
	end

	--[[ Applying ]]

	playStationPad = not playStationPad
	Module.RefreshHints()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Icon

--[[
	**CLIENT** |
	Returns a gamepad button's icon for the player's pad, in an icon style of the settings (Color by default).
]]
--- @return string?
function Module.GetIcon(keyCode: Enum.KeyCode, style: string?)
	--[[ Local Variables ]]

	local pad: string = if playStationPad then "PlayStation" else "Xbox"

	--[[ Returning ]]

	return _settings.GAMEPAD_ICONS[pad][style or "Color"][keyCode.Name]
end

--%%%%%%%%%%%%%%%%%%%% Get Button Name

--[[
	**CLIENT** |
	Returns what a text calls an action's first button on the player's pad ("RT" or "R2"), for texts that name one.
]]
--- @return string
function Module.GetButtonName(action: string)
	--[[ Data ]]

	local row = Binds.GetAction(action) --- @type Console_Action?
	if not row then
		return ""
	end

	--[[ Returning ]]

	return _settings.BUTTON_NAMES[if playStationPad then "PlayStation" else "Xbox"][row.Keys[1].Name] or row.Keys[1].Name
end

--%%%%%%%%%%%%%%%%%%%% Is PlayStation Pad

--[[
	**CLIENT** |
	Returns whether the player's gamepad is a PlayStation one: Roblox then names ButtonA "ButtonCross".
]]
--- @return boolean
function Module.IsPlayStationPad()
	return I.S.UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonA) == "ButtonCross"
end

return Module
