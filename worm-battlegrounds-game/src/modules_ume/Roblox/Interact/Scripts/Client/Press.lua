--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Interact"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Keys ]]

-- Keys run before the default bindings (the backpack's), so a key on an open widget's button wins
local KEY_PRIORITY: number = Enum.ContextActionPriority.High.Value
local boundKeys = {} --- @type { [Enum.KeyCode]: boolean }

--[[ Callbacks ]]

local pressCallbacks = {} --- @type { [GuiButton]: { () -> () } }

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

--- @class Interact_Client_Press
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Keys ]]

	--- @param component Utils_ButtonKey
	for _index: number, component in ipairs(I.Component.GetAll("Utils_ButtonKey")) do
		Module._bindKeys(component.KeyCodes)
	end

	--[[ Connections ]]

	--- @param component Utils_ButtonKey
	I.Component.GetAddedSignal("Utils_ButtonKey"):Connect(function(component)
		Module._bindKeys(component.KeyCodes)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Bind Keys

--[[
	Binds the keys a button has (Utils_ButtonKey) that aren't bound yet; a key stays bound once a button used it.
]]
--- @param keyCodes { Enum.KeyCode }
function Module._bindKeys(keyCodes)
	--[[ Binding ]]

	for _index: number, keyCode: Enum.KeyCode in ipairs(keyCodes) do
		-- Skip keys that are already bound
		if boundKeys[keyCode] then
			continue
		end

		boundKeys[keyCode] = true
		I.S.ContextActionService:BindActionAtPriority(`Interact_Key_{keyCode.Name}`, Module._onKey, false, KEY_PRIORITY, keyCode)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Press

--[[
	**CLIENT** |
	Calls `callback` when the button is activated (clicked, tapped or picked with a gamepad), and when its key
	(Utils_ButtonKey) presses it, as a click would.
]]
--- @return Interact_PressConnection
function Module.OnPress(button: GuiButton, callback: () -> ())
	--[[ Saving ]]

	-- Create the button's list on its first callback, dropped with the button
	if not pressCallbacks[button] then
		pressCallbacks[button] = {}
		button.Destroying:Once(function()
			pressCallbacks[button] = nil
		end)
	end

	table.insert(pressCallbacks[button], callback)

	--[[ Connections ]]

	local clickConnection: RBXScriptConnection = button.Activated:Connect(callback)

	--%%%%%%%%%%%%%%%%%%%% Disconnect

	--[[
		Stops calling `callback` on activations and key presses.
	]]
	local function disconnect()
		--[[ Disconnecting ]]

		clickConnection:Disconnect()

		--[[ Checks ]]

		local callbacks = pressCallbacks[button] --- @type { () -> () }?
		local index: number? = callbacks and table.find(callbacks, callback)

		-- Skip a callback that was already removed
		if not callbacks or not index then
			return
		end

		--[[ Removing ]]

		table.remove(callbacks, index)
	end

	--[[ Returning ]]

	return { Disconnect = disconnect }
end

--%%%%%%%%%%%%%%%%%%%% On Key

--[[
	Presses the shown button with the key on its press and lets it go on the release (I.Utils.PressKey), calling its
	callbacks when the release activates it. Sinks the key when a button took it, so it does nothing else.
]]
--- @return Enum.ContextActionResult
function Module._onKey(_actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
	--[[ Checks ]]

	-- Skip anything but the press and the release
	if inputState ~= Enum.UserInputState.Begin and inputState ~= Enum.UserInputState.End then
		return Enum.ContextActionResult.Pass
	end

	--[[ Pressing ]]

	local button: GuiButton?
	local activated: boolean
	button, activated = I.Utils.PressKey(inputObject.KeyCode, inputState == Enum.UserInputState.Begin)

	-- Pass the key on when no button took it
	if not button then
		return Enum.ContextActionResult.Pass
	end

	--[[ Calling ]]

	-- Each in its own thread, as a click's handlers are
	if activated and pressCallbacks[button] then
		for _index: number, callback: () -> () in ipairs(table.clone(pressCallbacks[button])) do
			task.spawn(callback)
		end
	end

	--[[ Returning ]]

	return Enum.ContextActionResult.Sink
end

return Module
