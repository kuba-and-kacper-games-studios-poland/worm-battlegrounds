--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "BackpackPlus"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local backpackGui: ScreenGui

--[[ Lock ]]

local lockStates = {} --- @type { [string]: boolean }
local currentLocked: boolean? = nil

--[[ Shared ]]

--- @type BackpackPlus_ClientContext
local ctx

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

--- @class BackpackPlus_Client_Lock
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _ctx BackpackPlus_ClientContext
function Module.Init(_ctx)
	ctx = _ctx

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._getElements()
	Module._updateLock()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing the backpack ScreenGui.
]]
function Module._getElements()
	backpackGui = I.UserInterface.UI["BackpackPlus"]
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Lock Control

--%%%%%%%%%%%%%%%%%%%% Set Lock

--[[
	**CLIENT** |
	Sets lock state for given source. Any active lock disables the backpack GUI.
]]
function Module.SetLock(source: string, state: boolean)
	--[[ Local Variables ]]

	local previousState: boolean? = lockStates[`{source}`]
	local newState: boolean = state == true

	--[[ Updating ]]

	if previousState ~= newState then
		lockStates[`{source}`] = newState
		Module._updateLock()
	end
end

--%%%%%%%%%%%%%%%%%%%% Clear Lock

--[[
	**CLIENT** |
	Clears lock state for given source.
]]
function Module.ClearLock(source: string)
	--[[ Local Variables ]]

	local previousState: boolean? = lockStates[`{source}`]

	--[[ Updating ]]

	if previousState ~= nil then
		lockStates[`{source}`] = nil
		Module._updateLock()
	end
end

--%%%%%%%%%%%%%%%%%%%% Is Locked

--[[
	**CLIENT** |
	Returns whether the backpack GUI is currently locked.
]]
--- @return boolean
function Module.IsLocked()
	return currentLocked == true
end

--%%%%%%%%%%%%%%%%%%%% Update Lock

--[[
	Applies lock state to the backpack ScreenGui.
]]
function Module._updateLock()
	--[[ Getting New State ]]

	local newLocked: boolean = false
	for _source: string, state: boolean in pairs(lockStates) do
		if state then
			newLocked = true
			break
		end
	end

	-- Skip if state hasn't changed
	if currentLocked == newLocked then
		return
	end

	--[[ Updating ]]

	currentLocked = newLocked
	ctx.IsLocked = newLocked

	-- Closing backpack before disabling
	if newLocked and ctx.GetState() then
		ctx.ForceClose()
	end

	backpackGui.Enabled = not newLocked
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
