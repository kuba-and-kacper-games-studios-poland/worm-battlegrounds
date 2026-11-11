--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Console"

--- @type Console_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

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

--- @class Console_Client_Binds
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Bind

--[[
	**CLIENT** |
	Binds an action's gamepad buttons (its ACTIONS row) at its priority: the callback gets the action's name, the
	input's state and the input, and returns whether it sinks the input (nil sinks it). Binding it again replaces it.
]]
--- @param callback Console_ActionCallback
function Module.Bind(action: string, callback)
	--[[ Data ]]

	local row = Module.GetAction(action) --- @type Console_Action?
	if not row then
		return
	end

	--[[ Checks ]]

	-- Check if the action is bound here, not pressed by gui buttons
	if row.Gui then
		warn(`[{_localName}::{script.Name}]: Action ({action}) is pressed by gui buttons (Gui), so it can't be bound!`)
		return
	end

	--[[ Binding ]]

	I.S.ContextActionService:BindActionAtPriority(`{_localName}_{action}`, function(_name: string, state: Enum.UserInputState, input: InputObject)
		return callback(action, state, input)
	end, false, row.Priority or _settings.DEFAULT_PRIORITY, table.unpack(row.Keys))
end

--%%%%%%%%%%%%%%%%%%%% Unbind

--[[
	**CLIENT** |
	Unbinds an action's gamepad buttons; an action that isn't bound does nothing.
]]
function Module.Unbind(action: string)
	--[[ Unbinding ]]

	I.S.ContextActionService:UnbindAction(`{_localName}_{action}`)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Action

--[[
	**CLIENT** |
	Returns an action's row in ACTIONS, warning when there is none.
]]
--- @return Console_Action?
function Module.GetAction(action: string)
	--[[ Checks ]]

	-- Check if the action is in the scheme
	if not _settings.ACTIONS[action] then
		warn(`[{_localName}::{script.Name}]: Action ({action}) is missing!`)
		return nil
	end

	--[[ Returning ]]

	return _settings.ACTIONS[action]
end

--%%%%%%%%%%%%%%%%%%%% Is Action

--[[
	**CLIENT** |
	Returns whether a key is one of an action's gamepad buttons, for input read from UserInputService's events.
]]
--- @return boolean
function Module.IsAction(action: string, keyCode: Enum.KeyCode)
	--[[ Data ]]

	local row = Module.GetAction(action) --- @type Console_Action?

	--[[ Returning ]]

	return row ~= nil and table.find(row.Keys, keyCode) ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Is Held

--[[
	**CLIENT** |
	Returns whether any of an action's gamepad buttons is held on the first gamepad.
]]
--- @return boolean
function Module.IsHeld(action: string)
	--[[ Data ]]

	local row = Module.GetAction(action) --- @type Console_Action?
	if not row then
		return false
	end

	--[[ Checking ]]

	for _index: number, keyCode: Enum.KeyCode in ipairs(row.Keys) do
		if I.S.UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, keyCode) then
			return true
		end
	end

	--[[ Returning ]]

	return false
end

return Module
