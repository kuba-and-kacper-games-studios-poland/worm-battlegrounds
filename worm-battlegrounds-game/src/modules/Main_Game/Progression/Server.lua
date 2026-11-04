--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Progression"

--- @type Progression_Settings
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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnPlayerAdded(I.Priority.Replicator, function(player: Player)
		I.Replicator.CreateFolder(player, _localName)
	end)
	I.G_Player.OnPlayerAdded(I.Priority.Setup, Module._setupPlayer)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Progression_LevelUp", { "Player", "number" })

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Progression = {

		--[[ Control ]]

		AddXP = Module.AddXP,

		--[[ Methods ]]

		GetLevel = Module.GetLevel,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Setup Player

--[[
	Shows a joining player's level: the Level attribute, their Progression folder and the player list.
]]
function Module._setupPlayer(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Publishing ]]

	I.Leaderstats.AddValue(player, "Level", Module.GetLevel(player), "IntValue", 2)
	Module._publish(player)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Add XP

--[[
	**SERVER** |
	Gives a player XP. Each level reached on the way gives its LEVEL_REWARDS item, publishes Progression_LevelUp and
	shows a toast. Returns the level they're at now and whether it went up.
]]
--- @return number, boolean
function Module.AddXP(player: Player, amount: number)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return 0, false
	end

	--[[ Local Variables ]]

	local before: number = Module.GetLevel(player)

	--[[ Saving ]]

	I.Statistic.Add(player, "XP", tostring(math.max(math.floor(amount), 0)))
	local after: number = Module.GetLevel(player)

	--[[ Rewarding ]]

	for level: number = before + 1, after do
		if _settings.LEVEL_REWARDS[level] then
			I.Inventory.AddItem(player, _settings.LEVEL_REWARDS[level])
		end
		I.Topic.Publish("Progression_LevelUp", player, level)
	end

	--[[ Publishing ]]

	Module._publish(player)
	if after > before then
		I.Leaderstats.SetValue(player, "Level", after)
		I.Notify.ShowNotification(player, `Level up! You're level {after}`)
	end

	--[[ Returning ]]

	return after, after > before
end

--%%%%%%%%%%%%%%%%%%%% Publish

--[[
	Writes a player's level where others read it: the Level attribute on the Player, and Level, XPIntoLevel and
	XPForLevel in their Progression folder.
]]
function Module._publish(player: Player)
	--[[ Local Variables ]]

	local level: number = Module.GetLevel(player)
	local into: number = Module._getXP(player) - Module._getTotalFor(level)
	local cost: number = if level >= _settings.MAX_LEVEL then 0 else _settings.LEVEL_BASE_XP + _settings.LEVEL_STEP_XP * level

	--[[ Saving ]]

	player:SetAttribute("Level", level)
	I.Replicator.Set(player, _localName, "Level", level)
	I.Replicator.Set(player, _localName, "XPIntoLevel", into)
	I.Replicator.Set(player, _localName, "XPForLevel", cost)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Level

--[[
	**SERVER** |
	Returns a player's level, worked out from their total XP (level 1 at 0 XP, MAX_LEVEL at most).
]]
--- @return number
function Module.GetLevel(player: Player)
	--[[ Local Variables ]]

	local xp: number = Module._getXP(player)
	local level: number = 1

	--[[ Calculating ]]

	while level < _settings.MAX_LEVEL and xp >= Module._getTotalFor(level + 1) do
		level += 1
	end

	--[[ Returning ]]

	return level
end

--%%%%%%%%%%%%%%%%%%%% Get XP

--[[
	Returns a player's total XP as a number.
]]
--- @return number
function Module._getXP(player: Player)
	return tonumber(I.Statistic.Get(player, "XP")) or 0
end

--%%%%%%%%%%%%%%%%%%%% Get Total For

--[[
	Returns the total XP it takes to reach a level from level 1.
]]
--- @return number
function Module._getTotalFor(level: number)
	--[[ Local Variables ]]

	local steps: number = level - 1

	--[[ Returning ]]

	return _settings.LEVEL_BASE_XP * steps + _settings.LEVEL_STEP_XP * steps * (steps + 1) / 2
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
