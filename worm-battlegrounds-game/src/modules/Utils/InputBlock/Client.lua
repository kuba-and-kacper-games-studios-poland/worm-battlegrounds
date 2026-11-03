--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "InputBlock"

--- @type InputBlock_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Locks ]]

--- @type { [string]: boolean }
local lockedBy = {}
local SERVER_LOCK_PREFIX: string = "Server:"

--[[ Auto Release ]]

--- @type { [string]: thread }
local releaseTimers = {}

--[[ Controls ]]

local cachedControls = nil

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
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("InputBlock_SetLock", { "string", "boolean" })
	I.Network.Fired("InputBlock_SetLock", Module._onServerSetLock)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.InputBlock = {

		--[[ Control ]]

		Block = Module.Block,
		Unblock = Module.Unblock,

		--[[ Methods ]]

		IsBlocked = Module.IsBlocked,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Block

--[[
	Holds a client lock id so character movement stays sunk until every id is released.
	With a `duration`, the lock releases itself after that many seconds unless it is blocked again or released first.
]]
function Module.Block(lockId: string, duration: number?)
	--[[ Applying ]]

	Module._setLock(lockId, true)

	--[[ Auto Release ]]

	-- Schedule the release when a duration is given and the lock was taken
	if typeof(duration) == "number" and duration > 0 and lockedBy[lockId] then
		releaseTimers[lockId] = task.delay(duration, function()
			releaseTimers[lockId] = nil
			Module._setLock(lockId, nil)
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%% Unblock

--[[
	Releases a client lock id. Movement stays blocked while any other id is still held.
]]
function Module.Unblock(lockId: string)
	--[[ Applying ]]

	Module._setLock(lockId, nil)
end

--%%%%%%%%%%%%%%%%%%%% Set Lock

--[[
	Writes or clears a lock id, cancels its pending auto release and refreshes the movement sink.
]]
function Module._setLock(lockId: string, value: boolean?)
	--[[ Checks ]]

	-- Check if the lock id is a non-empty string
	if typeof(lockId) ~= "string" or #lockId == 0 then
		return
	end

	--[[ Auto Release ]]

	-- Cancel a pending auto release of this lock
	if releaseTimers[lockId] then
		task.cancel(releaseTimers[lockId])
		releaseTimers[lockId] = nil
	end

	--[[ Applying ]]

	lockedBy[lockId] = value or nil
	Module._refreshSink()
end

--%%%%%%%%%%%%%%%%%%%% On Server Set Lock

--[[
	Applies a server lock id under a reserved prefix so it cannot collide with a client id.
]]
function Module._onServerSetLock(lockId: string, isBlocked: boolean)
	--[[ Checks ]]

	if typeof(lockId) ~= "string" or #lockId == 0 then
		return
	end

	--[[ Applying ]]

	Module._setLock(SERVER_LOCK_PREFIX .. lockId, isBlocked and true or nil)
end

--%%%%%%%%%%%%%%%%%%%% Refresh Sink

--[[
	Binds or unbinds the PlayerActions sink and enables or disables PlayerModule controls.
]]
function Module._refreshSink()
	--[[ State ]]

	local hasAnyLock: boolean = next(lockedBy) ~= nil
	local bound = I.S.ContextActionService:GetBoundActionInfo(_settings.ACTION_NAME)

	--[[ Context Action ]]

	if hasAnyLock then
		if next(bound) == nil then
			I.S.ContextActionService:BindAction(_settings.ACTION_NAME, function()
				return Enum.ContextActionResult.Sink
			end, false, unpack(Enum.PlayerActions:GetEnumItems()))
		end
	else
		if next(bound) ~= nil then
			I.S.ContextActionService:UnbindAction(_settings.ACTION_NAME)
		end
	end

	--[[ Player Module ]]

	--- @type table?
	local controls = Module._getControls()
	if not controls then
		return
	end

	if hasAnyLock then
		controls:Disable()
	else
		controls:Enable()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Blocked

--[[
	Returns whether any lock id is active.
]]
--- @return boolean
function Module.IsBlocked()
	--[[ Returning ]]

	return next(lockedBy) ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Get Controls

--[[
	Returns the local PlayerModule Controls object, caching it after the first resolve.
]]
--- @return table?
function Module._getControls()
	--[[ Cache ]]

	if cachedControls then
		return cachedControls
	end

	--[[ Finding ]]

	local localPlayer: Player? = I.Env.LocalPlayer
	if not localPlayer then
		return nil
	end

	local playerScripts: Instance? = localPlayer:FindFirstChildOfClass("PlayerScripts")
	local playerModule: Instance? = playerScripts and playerScripts:FindFirstChild("PlayerModule")
	if not playerModule or not playerModule:IsA("ModuleScript") then
		return nil
	end

	--[[ Requiring ]]

	local ok: boolean
	local playerModuleApi --- @type table
	ok, playerModuleApi = pcall(require, playerModule)
	if not ok or typeof(playerModuleApi) ~= "table" then
		return nil
	end

	cachedControls = playerModuleApi:GetControls()

	--[[ Returning ]]

	return cachedControls
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
