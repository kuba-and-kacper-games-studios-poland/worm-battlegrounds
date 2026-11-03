--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "PlayerCollision"

--- @type PlayerCollision_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local PhysicsService = I.S.PhysicsService

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
	----------- DATA -----------
	----------------------------

	--- @type Player_SessionData
	local _st = I.Player.SessionTemplate
	_st["PlayerCollision"] = {
		CollisionGroup = _settings.DEFAULT_COLLISION_GROUP_NAME, --- @type string
		DescendantConnection = nil, --- @type RBXScriptConnection
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._createCollisionGroup()

	--[[ Player Events ]]

	I.G_Player.OnCharacterAdded(I.Priority.Default, Module._updateCharacterCollisions)

	I.G_Player.OnPlayerRemoving(I.Priority.Default, Module._clearDescendantConnection)
	I.G_Player.OnCharacterRemoving(I.Priority.Default, Module._clearDescendantConnection)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.PlayerCollision = {

		--[[ Control ]]

		Set = Module.Set,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Collision Group

--[[
	Registers the `_settings.DEFAULT_COLLISION_GROUP_NAME` group and each `IGNORED_COLLISION_GROUPS` group that is missing.
	Makes the default group non-collidable with every ignored group and leaves other pairs untouched.
]]
function Module._createCollisionGroup()
	--[[ Registering ]]

	-- Register the default group when the place doesn't have it yet
	if not PhysicsService:IsCollisionGroupRegistered(_settings.DEFAULT_COLLISION_GROUP_NAME) then
		PhysicsService:RegisterCollisionGroup(_settings.DEFAULT_COLLISION_GROUP_NAME)
	end

	--[[ Updating Collisions ]]

	for _index: number, groupName: string in ipairs(_settings.IGNORED_COLLISION_GROUPS) do
		-- Register an ignored group that isn't registered yet
		if not PhysicsService:IsCollisionGroupRegistered(groupName) then
			PhysicsService:RegisterCollisionGroup(groupName)
		end

		PhysicsService:CollisionGroupSetCollidable(_settings.DEFAULT_COLLISION_GROUP_NAME, groupName, false)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set

--[[
	**SERVER** |
	Updates player's collision group.
]]
--- @return boolean
function Module.Set(player: Player, collisionGroupName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleData = sessionData["PlayerCollision"]

	--[[ Collision Group Check ]]

	if not PhysicsService:IsCollisionGroupRegistered(collisionGroupName) then
		warn(`[{_localName}::{script.Name}]: CollisionGroup ({collisionGroupName}) is not registered!`)
		return false
	end

	--[[ Updating ]]

	moduleData.CollisionGroup = collisionGroupName

	if player.Character then
		Module._updateCharacterCollisions(player, player.Character)
	end

	return true
end

--%%%%%%%%%%%%%%%%%%%% Update Character Collisions

--[[
	Updates collision group of all parts inside the player character.
]]
function Module._updateCharacterCollisions(player: Player, character: Model)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleData = sessionData["PlayerCollision"]

	--[[ Update Descendants - Connection ]]

	if moduleData.DescendantConnection then
		Module._clearDescendantConnection(player)
	end

	moduleData.DescendantConnection = character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = moduleData.CollisionGroup
		end
	end)

	--[[ Update Existing BaseParts ]]

	for _, part: BasePart in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = moduleData.CollisionGroup
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Clear Descendant Connection

--[[
	Disconnects the `DescendantConnection` for the player.
]]
function Module._clearDescendantConnection(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleData = sessionData["PlayerCollision"]

	--[[ Disconnecting ]]

	if moduleData.DescendantConnection then
		moduleData.DescendantConnection:Disconnect()
		moduleData.DescendantConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
