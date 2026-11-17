--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Progression"

--- @type Progression_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--- @type Progression_ServerSettings
local _serverSettings = require(script:FindFirstAncestor(_localName):FindFirstChild("ServerSettings"))

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

	-- The last matches' XP the lobby hasn't played back yet (a JSON Progression_Replay, "" when there's none)
	--- @type Player_ProfileData
	local _pt = I.Player.ProfileTemplate
	_pt["Progression"] = {
		Replay = "",
	}

	I.G_Player.OnPlayerAdded(I.Priority.Replicator, function(player: Player)
		I.Replicator.CreateFolder(player, _localName)
	end)
	I.G_Player.OnPlayerAdded(I.Priority.Setup, Module._setupPlayer)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Progression_LevelUp", { "Player", "number" })

	--- @Network
	I.Network.GetEvent("Progression_ReplaySeen", { "Player" })
	I.Network.Fired("Progression_ReplaySeen", Module._onReplaySeen)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Progression = {

		--[[ Control ]]

		AddXP = Module.AddXP,
		AddLevels = Module.AddLevels,
		SetReplay = Module.SetReplay,

		--[[ Methods ]]

		GetLevel = Module.GetLevel,
		GetProgress = Module.GetProgress,
		GetReplay = Module.GetReplay,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Setup Player

--[[
	Shows a joining player's level: the Level attribute, their Progression folder (with any XP replay still to play)
	and the player list.
]]
function Module._setupPlayer(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Publishing ]]

	I.Leaderstats.AddValue(player, "Level", Module.GetLevel(player), "IntValue", 2)
	Module._publish(player)
	I.Replicator.Set(player, _localName, "Replay", I.Player.GetProfile(player).Data["Progression"]["Replay"])
end

--%%%%%%%%%%%%%%%%%%%% On Replay Seen

--[[
	Forgets a player's XP replay once their lobby has played it.
]]
function Module._onReplaySeen(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Progression"]

	--[[ Saving ]]

	moduleData["Replay"] = ""

	--[[ Publishing ]]

	I.Replicator.Set(player, _localName, "Replay", "")
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

--%%%%%%%%%%%%%%%%%%%% Add Levels

--[[
	**SERVER** |
	Gives a player the XP that takes them up a number of levels (MAX_LEVEL at most), through AddXP, so each level's
	rewards, Topic and toast come as they do after a match. Returns the level they're at now and whether it went up.
]]
--- @return number, boolean
function Module.AddLevels(player: Player, levels: number)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return 0, false
	end

	--[[ Local Variables ]]

	local target: number = math.clamp(Module.GetLevel(player) + math.floor(levels), 1, _serverSettings.MAX_LEVEL)

	--[[ Returning ]]

	return Module.AddXP(player, Module._getTotalFor(target) - Module._getXP(player))
end

--%%%%%%%%%%%%%%%%%%%% Set Replay

--[[
	**SERVER** |
	Saves the XP a player's matches gave since their lobby last played it back (the lines, their level and XP before
	and after, and what each level on the way costs), and hands it to their client, which plays it in the lobby and
	then asks to forget it.
]]
--- @param replay Progression_Replay
function Module.SetReplay(player: Player, replay)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Progression"]

	--[[ Costs ]]

	-- Each level's cost on the way, so the client fills the bar without knowing the curve
	replay.Costs = {}
	for level: number = replay.Before.Level, replay.After.Level do
		table.insert(replay.Costs, if level >= _serverSettings.MAX_LEVEL then 0 else _serverSettings.LEVEL_BASE_XP + _serverSettings.LEVEL_STEP_XP * level)
	end

	--[[ Saving ]]

	moduleData["Replay"] = I.S.HttpService:JSONEncode(replay)

	--[[ Publishing ]]

	I.Replicator.Set(player, _localName, "Replay", moduleData["Replay"])
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
	local cost: number = if level >= _serverSettings.MAX_LEVEL then 0 else _serverSettings.LEVEL_BASE_XP + _serverSettings.LEVEL_STEP_XP * level

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

	while level < _serverSettings.MAX_LEVEL and xp >= Module._getTotalFor(level + 1) do
		level += 1
	end

	--[[ Returning ]]

	return level
end

--%%%%%%%%%%%%%%%%%%%% Get Progress

--[[
	**SERVER** |
	Returns a player's level, the XP they have into it and the XP it takes (0 at MAX_LEVEL).
]]
--- @return Progression_Progress
function Module.GetProgress(player: Player)
	--[[ Local Variables ]]

	local level: number = Module.GetLevel(player)

	--[[ Returning ]]

	return {
		Level = level,
		Into = Module._getXP(player) - Module._getTotalFor(level),
		For = if level >= _serverSettings.MAX_LEVEL then 0 else _serverSettings.LEVEL_BASE_XP + _serverSettings.LEVEL_STEP_XP * level,
	}
end

--%%%%%%%%%%%%%%%%%%%% Get Replay

--[[
	**SERVER** |
	Returns the XP replay a player's lobby hasn't played yet, or nil.
]]
--- @return Progression_Replay?
function Module.GetReplay(player: Player)
	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local saved: string = profileData["Progression"]["Replay"]

	--[[ Checks ]]

	-- Check if there's a replay waiting
	if saved == "" then
		return nil
	end

	--[[ Decoding ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(I.S.HttpService.JSONDecode, I.S.HttpService, saved)

	--[[ Returning ]]

	return if success then result else nil
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

	return _serverSettings.LEVEL_BASE_XP * steps + _serverSettings.LEVEL_STEP_XP * steps * (steps + 1) / 2
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
