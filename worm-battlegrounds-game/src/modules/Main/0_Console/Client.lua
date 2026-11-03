--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Console"

--- @type Console_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Icons ]]

-- Every gamepad icon image, to the icon style and button it shows on either pad, so a hint's icon can be swapped
local iconStyles = {} --- @type { [string]: string }
local iconButtons = {} --- @type { [string]: string }

--[[ State ]]

local playStationPad: boolean = false
-- Hints whose hidden attribute is followed, so each is connected once. Weak, so a destroyed hint goes
local watchedHints = setmetatable({}, { __mode = "k" }) --- @type { [Instance]: boolean }

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._indexIcons()
	playStationPad = Module.IsPlayStationPad()

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Console = {

		--[[ Control ]]

		RefreshHints = Module.RefreshHints,

		--[[ Methods ]]

		GetIcon = Module.GetIcon,
		IsPlayStationPad = Module.IsPlayStationPad,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Module._bindBackpackPlus()
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

--%%%%%%%%%%%%%%%%%%%% Bind BackpackPlus

--[[
	Binds the gamepad controls of BackpackPlus: the bumpers equip the previous or next toolbar Tool, D-pad up opens
	the backpack view and B (Circle) closes it, and while it is open D-pad up and down select the category above or
	below. While it is closed, D-pad down unequips the equipped Tool. Open and close pass the input on when they have nothing to do.
]]
function Module._bindBackpackPlus()
	--[[ Toolbar ]]

	I.S.ContextActionService:BindAction("Console_BackpackPrevious", function(_actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
		-- Skip anything but the press
		if inputState ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		I.BackpackPlus.CycleToolbar(-1)
		return Enum.ContextActionResult.Sink
	end, false, _settings.BACKPACK_PREVIOUS)

	I.S.ContextActionService:BindAction("Console_BackpackNext", function(_actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
		-- Skip anything but the press
		if inputState ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		I.BackpackPlus.CycleToolbar(1)
		return Enum.ContextActionResult.Sink
	end, false, _settings.BACKPACK_NEXT)

	--[[ Backpack ]]

	I.S.ContextActionService:BindAction("Console_BackpackOpen", function(_actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
		-- Skip anything but the press, and an open or locked backpack
		if inputState ~= Enum.UserInputState.Begin or I.BackpackPlus.GetState() or I.BackpackPlus.IsLocked() then
			return Enum.ContextActionResult.Pass
		end

		I.BackpackPlus.Toggle()
		return Enum.ContextActionResult.Sink
	end, false, _settings.BACKPACK_OPEN)

	I.S.ContextActionService:BindAction("Console_BackpackUnequip", function(_actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
		-- Skip anything but the press, an open backpack, and nothing equipped
		if inputState ~= Enum.UserInputState.Begin or I.BackpackPlus.GetState() or not I.BackpackPlus.Unequip() then
			return Enum.ContextActionResult.Pass
		end

		return Enum.ContextActionResult.Sink
	end, false, _settings.BACKPACK_UNEQUIP)

	I.S.ContextActionService:BindAction("Console_BackpackClose", function(_actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
		-- Skip anything but the press, and a closed backpack
		if inputState ~= Enum.UserInputState.Begin or not I.BackpackPlus.GetState() then
			return Enum.ContextActionResult.Pass
		end

		I.BackpackPlus.Toggle()
		return Enum.ContextActionResult.Sink
	end, false, _settings.BACKPACK_CLOSE)

	--[[ Categories ]]

	-- Above the keyed buttons' binds (Interact, High), so D-pad up moves the category instead of pressing the top bar's
	-- backpack button while the backpack is open
	local categoryPriority: number = Enum.ContextActionPriority.High.Value + 1

	I.S.ContextActionService:BindActionAtPriority("Console_BackpackCategoryPrevious", function(_actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
		-- Skip anything but the press, and a closed backpack
		if inputState ~= Enum.UserInputState.Begin or not I.BackpackPlus.GetState() then
			return Enum.ContextActionResult.Pass
		end

		I.BackpackPlus.CycleCategory(-1)
		return Enum.ContextActionResult.Sink
	end, false, categoryPriority, _settings.BACKPACK_CATEGORY_PREVIOUS)

	I.S.ContextActionService:BindActionAtPriority("Console_BackpackCategoryNext", function(_actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
		-- Skip anything but the press, and a closed backpack
		if inputState ~= Enum.UserInputState.Begin or not I.BackpackPlus.GetState() then
			return Enum.ContextActionResult.Pass
		end

		I.BackpackPlus.CycleCategory(1)
		return Enum.ContextActionResult.Sink
	end, false, categoryPriority, _settings.BACKPACK_CATEGORY_NEXT)
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
	Shows a hint only on Console and swaps its gamepad icons, and those inside it, to the player's pad.
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

	--[[ Icons ]]

	local pad: string = if playStationPad then "PlayStation" else "Xbox"
	local images = hint:GetDescendants() --- @type { Instance }
	table.insert(images, hint)

	for _index: number, image: Instance in ipairs(images) do
		-- Skip anything but images showing a gamepad icon
		if not (image:IsA("ImageLabel") or image:IsA("ImageButton")) or not iconStyles[image.Image] then
			continue
		end

		image.Image = _settings.GAMEPAD_ICONS[pad][iconStyles[image.Image]][iconButtons[image.Image]]
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

--%%%%%%%%%%%%%%%%%%%% Is PlayStation Pad

--[[
	**CLIENT** |
	Returns whether the player's gamepad is a PlayStation one: Roblox then names ButtonA "ButtonCross".
]]
--- @return boolean
function Module.IsPlayStationPad()
	return I.S.UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonA) == "ButtonCross"
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
