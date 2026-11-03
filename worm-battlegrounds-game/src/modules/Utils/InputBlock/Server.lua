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

--- @type { [Player]: { [string]: boolean } }
local blockedBy = {}

--[[ Auto Release ]]

--- @type { [Player]: { [string]: thread } }
local releaseTimers = {}

--[[ Server Enforcement ]]

local enforcedHumanoids = {} --- @type { [Player]: InputBlock_EnforcedHumanoid }
local ENFORCED_PROPERTIES = { "WalkSpeed", "JumpPower", "JumpHeight" } --- @type { string }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Cancel Release

--[[
	Cancels the pending auto release of one lock id in a player's timers, or of every lock id when none is given.
]]
--- @param timers { [string]: thread }?
local function cancelRelease(timers, id: string?)
	--[[ Checks ]]

	-- Skip a player without timers
	if not timers then
		return
	end

	--[[ Cancelling ]]

	for timerId: string, timer: thread in pairs(timers) do
		-- Skip other lock ids when one is given
		if id and timerId ~= id then
			continue
		end

		task.cancel(timer)
		timers[timerId] = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Release Humanoid

--[[
	Stops enforcing a lock on a humanoid and gives back its walk speed and jump values.
]]
--- @param state InputBlock_EnforcedHumanoid
local function releaseHumanoid(state)
	--[[ Disconnecting ]]

	for _index: number, connection: RBXScriptConnection in ipairs(state.Connections) do
		connection:Disconnect()
	end

	--[[ Restoring ]]

	for _index: number, propertyName: string in ipairs(ENFORCED_PROPERTIES) do
		state.Humanoid[propertyName] = state[propertyName]
	end
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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	--[[ Player Events ]]

	I.G_Player.OnPlayerRemoving(I.Priority.Default, Module._clearPlayer)
	I.G_Player.OnCharacterAdded(I.Priority.Default, Module._refreshEnforcement)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("InputBlock_SetLock")

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.InputBlock = {

		--[[ Control ]]

		Block = Module.Block,
		Unblock = Module.Unblock,
		Clear = Module.Clear,

		--[[ Methods ]]

		IsBlocked = Module.IsBlocked,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Clear Player

--[[
	Drops stored locks, timers and enforcement for a leaving player. Does not Fire — the client is gone.
]]
function Module._clearPlayer(player: Player)
	--[[ Clearing ]]

	blockedBy[player] = nil

	cancelRelease(releaseTimers[player])
	releaseTimers[player] = nil

	-- Stop enforcing on the leaving character
	if enforcedHumanoids[player] then
		releaseHumanoid(enforcedHumanoids[player])
		enforcedHumanoids[player] = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Refresh Enforcement

--[[
	With `SERVER_ENFORCED`, zeroes the character's walk speed and jump while the player holds any lock.
	Gives the values back when the last lock is released; a new character is enforced again while locks remain.
]]
function Module._refreshEnforcement(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Checks ]]

	-- Skip when server enforcement is off
	if not _settings.SERVER_ENFORCED then
		return
	end

	--[[ Data ]]

	local character: Model? = player.Character
	local humanoid: Humanoid? = character and character:FindFirstChildOfClass("Humanoid")
	local state = enforcedHumanoids[player] --- @type InputBlock_EnforcedHumanoid?

	--[[ Local Variables ]]

	local shouldEnforce: boolean = blockedBy[player] ~= nil and humanoid ~= nil

	--[[ Releasing ]]

	-- Release a humanoid that no longer needs it, or one a respawn replaced
	if state and (not shouldEnforce or state.Humanoid ~= humanoid) then
		releaseHumanoid(state)
		enforcedHumanoids[player] = nil
		state = nil
	end

	--[[ Checks ]]

	-- Skip when nothing needs enforcing or it already is
	if not shouldEnforce or state then
		return
	end

	--[[ Enforcing ]]

	--- @type InputBlock_EnforcedHumanoid
	local newState = {
		Humanoid = humanoid,
		Connections = {},
		WalkSpeed = humanoid.WalkSpeed,
		JumpPower = humanoid.JumpPower,
		JumpHeight = humanoid.JumpHeight,
	}
	enforcedHumanoids[player] = newState

	-- Hold each value at zero, keeping what other code writes meanwhile for the restore
	for _index: number, propertyName: string in ipairs(ENFORCED_PROPERTIES) do
		humanoid[propertyName] = 0
		table.insert(
			newState.Connections,
			humanoid:GetPropertyChangedSignal(propertyName):Connect(function()
				-- Skip the zero written here
				if humanoid[propertyName] == 0 then
					return
				end

				newState[propertyName] = humanoid[propertyName]
				humanoid[propertyName] = 0
			end)
		)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Block

--[[
	Adds a lock id for the player and tells their client to sink movement.
	With a `duration`, the lock releases itself after that many seconds unless it is blocked again or released first.
]]
function Module.Block(player: Player, lockId: string?, duration: number?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Resolve Id ]]

	local id: string = Module._resolveLockId(lockId)

	--[[ Storing ]]

	--- @type { [string]: boolean }?
	local set = blockedBy[player]

	-- Create the player's lock set on the first lock
	if not set then
		set = {}
		blockedBy[player] = set
	end
	set[id] = true

	--[[ Auto Release ]]

	cancelRelease(releaseTimers[player], id)

	-- Schedule the release when a duration is given
	if typeof(duration) == "number" and duration > 0 then
		--- @type { [string]: thread }
		local timers = releaseTimers[player] or {}
		releaseTimers[player] = timers

		timers[id] = task.delay(duration, function()
			timers[id] = nil
			Module.Unblock(player, id)
		end)
	end

	--[[ Enforcing ]]

	Module._refreshEnforcement(player)

	--[[ Notifying ]]

	I.Network.Fire("InputBlock_SetLock", player, id, true)
end

--%%%%%%%%%%%%%%%%%%%% Unblock

--[[
	Removes a lock id for the player and tells their client to release it.
]]
function Module.Unblock(player: Player, lockId: string?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Resolve Id ]]

	local id: string = Module._resolveLockId(lockId)

	--[[ Storing ]]

	--- @type { [string]: boolean }?
	local set = blockedBy[player]

	-- Remove the id, dropping the set once it is empty
	if set then
		set[id] = nil
		if next(set) == nil then
			blockedBy[player] = nil
		end
	end

	--[[ Auto Release ]]

	cancelRelease(releaseTimers[player], id)

	--[[ Enforcing ]]

	Module._refreshEnforcement(player)

	--[[ Notifying ]]

	I.Network.Fire("InputBlock_SetLock", player, id, false)
end

--%%%%%%%%%%%%%%%%%%%% Clear

--[[
	**SERVER** |
	Removes every lock for the player and tells their client to release each one.
]]
function Module.Clear(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Checks ]]

	--- @type { [string]: boolean }?
	local set = blockedBy[player]

	-- Skip a player without locks
	if not set then
		return
	end

	--[[ Clearing ]]

	for id: string, _held: boolean in pairs(set) do
		I.Network.Fire("InputBlock_SetLock", player, id, false)
	end

	blockedBy[player] = nil

	cancelRelease(releaseTimers[player])

	--[[ Enforcing ]]

	Module._refreshEnforcement(player)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Blocked

--[[
	Returns whether the player has any lock, or the given lock id when provided.
]]
--- @return boolean
function Module.IsBlocked(player: Player, lockId: string?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type { [string]: boolean }?
	local set = blockedBy[player]
	if not set then
		return false
	end

	--[[ Checks ]]

	if typeof(lockId) == "string" and #lockId > 0 then
		return set[lockId] == true
	end

	--[[ Returning ]]

	return next(set) ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Resolve Lock Id

--[[
	Returns lockId, or the default Settings id when it is missing.
]]
--- @return string
function Module._resolveLockId(lockId: string?)
	--[[ Checks ]]

	if typeof(lockId) ~= "string" or #lockId == 0 then
		return _settings.DEFAULT_LOCK_ID
	end

	--[[ Returning ]]

	return lockId
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
