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

--[[ Targets ]]

--[[
	Where the selection goes while no widget is open: a module's focus (and what B does there), else the screen's home
	button
]]
local focus: GuiObject? = nil
local focusBack: (() -> ())? = nil
local home: GuiObject? = nil

--[[ State ]]

--[[
	The element selected last, and the one selected before the first widget opened (the selection comes back to it),
	when B was last pressed (os.clock), and whether the next cleared selection is this module's own
]]
local lastSelected: GuiObject? = nil
local returnTo: GuiObject? = nil
local lastBack: number = 0
local clearing: boolean = false

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

--- @class Console_Client_Selection
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Binding ]]

	-- View starts and ends the selection where this module says, instead of where Roblox would
	I.S.GuiService.AutoSelectGuiEnabled = false
	Binds.Bind("Navigate", Module._onNavigate)

	--[[ Connections ]]

	I.S.GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(Module._onSelectionChanged)
	I.S.UserInputService.InputBegan:Connect(function(input: InputObject)
		if Binds.IsAction("Back", input.KeyCode) then
			lastBack = os.clock()
		end
	end)
	I.Topic.Subscribe("WidgetManager_Opened", Module._onWidgetOpened)
	I.Topic.Subscribe("WidgetManager_Closed", Module._onWidgetClosed)
	I.Topic.Subscribe("Platform_Changed", function(_platform: string)
		Module._select()
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Focus

--[[
	**CLIENT** |
	On Console, keeps the gamepad's selection in a container while it shows and no widget is open (a pick list, a
	panel): B there calls onBack, or keeps the selection when there is none. Its A button (Utils_ButtonKey) is selected
	first.
]]
function Module.Focus(container: GuiObject, onBack: (() -> ())?)
	--[[ Checks ]]

	-- Skip a container already focused
	if focus == container then
		return
	end

	--[[ Saving ]]

	focus = container
	focusBack = onBack

	--[[ Selecting ]]

	Module._select()
end

--%%%%%%%%%%%%%%%%%%%% Unfocus

--[[
	**CLIENT** |
	Lets the selection leave a focused container, for the widget or home button under it.
]]
function Module.Unfocus(container: GuiObject)
	--[[ Checks ]]

	-- Skip a container that isn't the focus
	if focus ~= container then
		return
	end

	--[[ Saving ]]

	focus = nil
	focusBack = nil

	--[[ Selecting ]]

	Module._select()
end

--%%%%%%%%%%%%%%%%%%%% Set Home

--[[
	**CLIENT** |
	Sets the button the selection rests on, on Console, while nothing else wants it (the lobby's SOLO VS BOTS), so a
	pad always has something selected there.
]]
function Module.SetHome(button: GuiObject)
	--[[ Saving ]]

	home = button

	--[[ Selecting ]]

	Module._select()
end

--%%%%%%%%%%%%%%%%%%%% Select

--[[
	Puts the selection where the player is, on Console: in the open widget when it has buttons no key presses (a widget
	whose every button has a key is left to its keys), else in the focus, else on the home button. With nowhere to go,
	or off Console, it clears it, unless forced (Navigate), which then tries NAVIGATION_GUIS.
]]
function Module._select(forced: boolean?)
	--[[ Local Variables ]]

	local current: GuiObject? = I.S.GuiService.SelectedObject
	local target: Instance? = if I.Platform.Current == "Console" or forced then Module._getTarget(forced == true) else nil

	--[[ Checks ]]

	-- Keep a selection that is already in the target
	if target and current and Module._isInside(current, target) and Module._isShown(current) then
		return
	end

	--[[ Selecting ]]

	local first: GuiObject? = if target then Module._getFirst(target) else nil
	if first then
		I.S.GuiService.SelectedObject = first
	elseif current then
		clearing = true
		I.S.GuiService.SelectedObject = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Back

--[[
	Backs out the way B would without a selection: the widget's B button closes it when that button is WidgetManager's
	(or else is selected, so A presses it), the focus calls its onBack, and anywhere else the selection comes back.
]]
function Module._back(widget: ScreenGui?)
	--[[ Checks ]]

	-- Skip a widget already closed by its own B button
	if widget and I.WidgetManager.GetCurrent() ~= widget then
		return
	end

	--[[ Widget ]]

	if widget then
		local backButton: GuiButton? = Module._getKeyButton(widget, Binds.GetAction("Back").Keys[1].Name)
		if backButton and backButton:GetAttribute("Interact_ModuleName") == "WidgetManager" then
			I.WidgetManager.Close(widget.Name)
		elseif backButton then
			I.S.GuiService.SelectedObject = backButton
		else
			Module._select()
		end
		return
	end

	--[[ Focus ]]

	if focus and focusBack and Module._isShown(focus) then
		focusBack()
		return
	end

	--[[ Selecting ]]

	Module._select()
end

--%%%%%%%%%%%%%%%%%%%% On Navigate

--[[
	View: ends the selection, or starts it where the player is, in NAVIGATION_GUIS when nothing else wants it.
]]
--- @return Enum.ContextActionResult
function Module._onNavigate(_action: string, state: Enum.UserInputState, _input: InputObject)
	--[[ Checks ]]

	-- Act on presses only
	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Sink
	end

	--[[ Toggling ]]

	if I.S.GuiService.SelectedObject then
		clearing = true
		I.S.GuiService.SelectedObject = nil
	else
		Module._select(true)
	end

	--[[ Returning ]]

	return Enum.ContextActionResult.Sink
end

--%%%%%%%%%%%%%%%%%%%% On Selection Changed

--[[
	When a selection ends: B (Roblox clears the selection on B before scripts see the press) backs out, and a selected
	element that went away (a refreshed list, a closed panel) has the selection put back where the player is.
]]
function Module._onSelectionChanged()
	--[[ Local Variables ]]

	local selected: GuiObject? = I.S.GuiService.SelectedObject
	local previous: GuiObject? = lastSelected
	local widget: ScreenGui? = I.WidgetManager.GetCurrent()
	lastSelected = selected

	--[[ Checks ]]

	-- Skip a new selection, and a selection this module ended
	if selected then
		return
	end
	if clearing then
		clearing = false
		return
	end

	--[[ Backing Out ]]

	-- After this frame's input, so the B press is seen
	task.defer(function()
		local backHeld: boolean = Binds.IsHeld("Back") or os.clock() - lastBack <= _settings.BACK_WINDOW
		if previous and Module._isShown(previous) then
			if backHeld then
				Module._back(widget)
			end
			return
		end
		Module._select()
	end)
end

--%%%%%%%%%%%%%%%%%%%% On Widget Opened

--[[
	Moves the selection into a widget that opened, remembering what was selected before the first one.
]]
function Module._onWidgetOpened(_widgetName: string)
	--[[ Saving ]]

	if not returnTo then
		returnTo = lastSelected
	end

	--[[ Selecting ]]

	-- Once WidgetManager has shown it
	task.defer(Module._select)
end

--%%%%%%%%%%%%%%%%%%%% On Widget Closed

--[[
	Puts the selection back where the player is when a widget closed: the next widget, or what was selected before the
	first one opened.
]]
function Module._onWidgetClosed(_widgetName: string)
	--[[ Selecting ]]

	-- Once WidgetManager has hidden it, and opened any queued one
	task.defer(function()
		Module._select()
		if not I.WidgetManager.GetCurrent() then
			returnTo = nil
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Target

--[[
	Returns where the selection belongs now: the open widget (when it needs one, or always when forced), the focus, what
	was selected before the widgets opened, the home button, or when forced the first shown gui of NAVIGATION_GUIS.
]]
--- @return Instance?
function Module._getTarget(forced: boolean)
	--[[ Widget ]]

	local widget: ScreenGui? = I.WidgetManager.GetCurrent()
	if widget then
		return if forced or Module._needsSelection(widget) then widget else nil
	end

	--[[ Focus And Home ]]

	if focus and Module._isShown(focus) then
		return focus
	end
	if returnTo and Module._isShown(returnTo) then
		return returnTo
	end
	if home and Module._isShown(home) then
		return home
	end

	--[[ Navigation ]]

	if forced then
		for _index: number, guiName: string in ipairs(_settings.NAVIGATION_GUIS) do
			local gui: ScreenGui? = I.UserInterface.UI[guiName]
			if gui and gui.Enabled then
				return gui
			end
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get First

--[[
	Returns what to select in a target: the target itself when it's a button, else its shown A button
	(Utils_ButtonKey), else its first shown selectable button.
]]
--- @return GuiObject?
function Module._getFirst(target: Instance)
	--[[ Checks ]]

	-- Select a button target itself
	if target:IsA("GuiButton") then
		return target
	end

	--[[ Finding ]]

	local confirmButton: GuiButton? = Module._getKeyButton(target, Binds.GetAction("Confirm").Keys[1].Name)
	if confirmButton then
		return confirmButton
	end

	for _index: number, part: Instance in ipairs(target:GetDescendants()) do
		if part:IsA("GuiButton") and part.Selectable and Module._isShown(part) then
			return part
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Key Button

--[[
	Returns a shown button in a container that a gamepad key presses (its Utils_GamepadKey).
]]
--- @return GuiButton?
function Module._getKeyButton(container: Instance, keyName: string)
	--[[ Finding ]]

	for _index: number, part: Instance in ipairs(container:GetDescendants()) do
		if part:IsA("GuiButton") and part:GetAttribute("Utils_GamepadKey") == keyName and Module._isShown(part) then
			return part
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Is Shown

--[[
	Returns whether a gui element shows: it and every GuiObject above it Visible, and its ScreenGui Enabled.
]]
--- @return boolean
function Module._isShown(element: Instance)
	return I.Utils.IsGuiShown(element) and element:IsDescendantOf(I.S.Players.LocalPlayer.PlayerGui)
end

--%%%%%%%%%%%%%%%%%%%% Is Inside

--[[
	Returns whether an element is a container or inside it.
]]
--- @return boolean
function Module._isInside(element: Instance, container: Instance)
	return element == container or element:IsDescendantOf(container)
end

--%%%%%%%%%%%%%%%%%%%% Needs Selection

--[[
	Returns whether a widget has a shown selectable button that no gamepad key presses, so only a selection reaches it.
]]
--- @return boolean
function Module._needsSelection(widget: ScreenGui)
	--[[ Finding ]]

	for _index: number, part: Instance in ipairs(widget:GetDescendants()) do
		if part:IsA("GuiButton") and part.Selectable and (part:GetAttribute("Utils_GamepadKey") or "") == "" and Module._isShown(part) then
			return true
		end
	end

	--[[ Returning ]]

	return false
end

return Module
