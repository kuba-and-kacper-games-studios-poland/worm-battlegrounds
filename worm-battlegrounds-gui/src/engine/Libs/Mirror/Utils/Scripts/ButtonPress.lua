--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(script:FindFirstAncestor("Libs"):FindFirstChild("Runtime"))
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Buttons ]]

-- The shown buttons each key presses, to the order they were shown in
local shownButtons = {} --- @type { [Enum.KeyCode]: { [GuiButton]: number } }
local shownCount: number = 0

-- The button each held key went down on
local heldButtons = {} --- @type { [Enum.KeyCode]: GuiButton }

--[[ Listeners ]]

local listeners = {} --- @type { [GuiButton]: { [string]: { () -> () } } }

--[[ Played Presses ]]

-- How long a played press holds the button down before it lets go, as a quick tap does
local PLAYED_PRESS_TIME: number = 0.1

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

--- @class UmeGui_Utils_ButtonPress
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Press Key

--[[
	**CLIENT** |
	Presses or releases the button a key belongs to, as a click would: down presses the shown button with that key on
	the topmost gui, and the release lets it go and activates it when it is still shown and takes input.
]]
--- @return GuiButton?
--- @return boolean
function Module.PressKey(keyCode: Enum.KeyCode, down: boolean)
	--[[ Pressing ]]

	if down then
		local pressedButton: GuiButton? = Module._getTarget(keyCode)

		-- Skip a key no shown button takes
		if not pressedButton then
			return nil, false
		end

		heldButtons[keyCode] = pressedButton
		Module._fire(pressedButton, "Down")
		return pressedButton, false
	end

	--[[ Releasing ]]

	local button: GuiButton? = heldButtons[keyCode]

	-- Skip a release whose press no button took
	if not button then
		return nil, false
	end

	heldButtons[keyCode] = nil
	Module._fire(button, "Up")

	--[[ Activating ]]

	local activated: boolean = shownButtons[keyCode] ~= nil and shownButtons[keyCode][button] ~= nil and button.Interactable

	-- Activate only a button still shown and taking input, as a click released over it
	if activated then
		Module._fire(button, "Activated")
	end

	--[[ Returning ]]

	return button, activated
end

--%%%%%%%%%%%%%%%%%%%% Play Press

--[[
	**CLIENT** |
	Plays a press on a button for an input that acted on it without a key of its own (a gamepad cycling the toolbar):
	its click look, and a moment later the release with its click sound. Runs nothing the button does.
]]
function Module.PlayPress(button: GuiButton)
	--[[ Pressing ]]

	Module._fire(button, "Down")

	--[[ Releasing ]]

	task.delay(PLAYED_PRESS_TIME, function()
		Module._fire(button, "Up")
		Module._fire(button, "Activated")
	end)
end

--%%%%%%%%%%%%%%%%%%%% Add

--[[
	Lets the keys press a button while it is shown; the latest shown wins among buttons on the same gui layer.
]]
--- @param keyCodes { Enum.KeyCode }
function Module.Add(button: GuiButton, keyCodes)
	--[[ Saving ]]

	shownCount += 1

	for _index: number, keyCode: Enum.KeyCode in ipairs(keyCodes) do
		-- Create the key's set on its first button
		if not shownButtons[keyCode] then
			shownButtons[keyCode] = {}
		end

		shownButtons[keyCode][button] = shownCount
	end
end

--%%%%%%%%%%%%%%%%%%%% Remove

--[[
	Stops every key from pressing a button, when it hides or goes; a key held on it still releases it.
]]
function Module.Remove(button: GuiButton)
	--[[ Removing ]]

	for _keyCode: Enum.KeyCode, buttons: { [GuiButton]: number } in pairs(shownButtons) do
		buttons[button] = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Connect

--[[
	**CLIENT** |
	Calls `callback` each time a key presses the button (`Down`), lets it go (`Up`) or activates it (`Activated`).
]]
--- @param phase UmeGui_Utils_ButtonPressPhase
--- @return UmeGui_Utils_ButtonPressConnection
function Module.Connect(button: GuiButton, phase, callback: () -> ())
	--[[ Saving ]]

	-- Create the button's lists on its first listener
	if not listeners[button] then
		listeners[button] = {}
	end
	if not listeners[button][phase] then
		listeners[button][phase] = {}
	end

	table.insert(listeners[button][phase], callback)

	--%%%%%%%%%%%%%%%%%%%% Disconnect

	--[[
		Stops calling `callback`, and forgets the button once nothing listens to it.
	]]
	local function disconnect()
		--[[ Checks ]]

		local callbacks = listeners[button] and listeners[button][phase] --- @type { () -> () }?
		local index: number? = callbacks and table.find(callbacks, callback)

		-- Skip a callback that was already disconnected
		if not callbacks or not index then
			return
		end

		--[[ Removing ]]

		table.remove(callbacks, index)

		-- Forget the phase, then the button, once nothing listens
		if #callbacks == 0 then
			listeners[button][phase] = nil
		end
		if next(listeners[button]) == nil then
			listeners[button] = nil
		end
	end

	--[[ Returning ]]

	return { Disconnect = disconnect }
end

--%%%%%%%%%%%%%%%%%%%% Fire

--[[
	Calls the button's listeners of a phase, each in its own thread as a click's handlers are.
]]
--- @param phase UmeGui_Utils_ButtonPressPhase
function Module._fire(button: GuiButton, phase)
	--[[ Checks ]]

	-- Skip a button nothing listens to in this phase
	if not listeners[button] or not listeners[button][phase] then
		return
	end

	--[[ Calling ]]

	for _index: number, callback: () -> () in ipairs(table.clone(listeners[button][phase])) do
		task.spawn(callback)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Target

--[[
	Returns the shown button a key presses: the one on the gui with the highest DisplayOrder that takes input, and on
	a tie the one shown last. None while gamepad navigation has a selection, which presses the selected button itself.
]]
--- @return GuiButton?
function Module._getTarget(keyCode: Enum.KeyCode)
	--[[ Checks ]]

	-- Skip while gamepad navigation has a selection
	if I.S.GuiService.SelectedObject then
		return nil
	end

	-- Skip a key no shown button has
	if not shownButtons[keyCode] then
		return nil
	end

	--[[ Finding ]]

	local target: GuiButton? = nil
	local targetLayerOrder: number = 0
	local targetShownOrder: number = 0

	for button: GuiButton, shownOrder: number in pairs(shownButtons[keyCode]) do
		-- Skip buttons that don't take input
		if not button.Interactable then
			continue
		end

		local layer: LayerCollector? = button:FindFirstAncestorWhichIsA("LayerCollector")
		local layerOrder: number = if layer and layer:IsA("ScreenGui") then layer.DisplayOrder else 0

		-- Keep the button on the topmost gui, the one shown last on a tie
		if not target or layerOrder > targetLayerOrder or (layerOrder == targetLayerOrder and shownOrder > targetShownOrder) then
			target = button
			targetLayerOrder = layerOrder
			targetShownOrder = shownOrder
		end
	end

	--[[ Returning ]]

	return target
end

return Module
