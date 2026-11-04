--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Tutorial"

--- @type Tutorial_Settings
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
	----------- DATA -----------
	----------------------------

	--- @type Player_ProfileData
	local _pt = I.Player.ProfileTemplate
	_pt["Tutorial"] = {
		MatchDone = false,
		CrateOpened = false,
		Done = false,
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnPlayerAdded(I.Priority.Replicator, Module._createReplicator)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("Tutorial_Step", { "Player", "string" }, { RateLimit = 5 })
	I.Network.Fired("Tutorial_Step", Module._onStep)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Tutorial = {

		--[[ Control ]]

		CompleteMatch = Module.CompleteMatch,

		--[[ Methods ]]

		IsMatchDone = Module.IsMatchDone,
		IsDone = Module.IsDone,
		CanOpenCrate = Module.CanOpenCrate,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	-- Matches end on the Match map, and crates open on the Lobby map
	if I.Topic.IsRegistered("Match_Ended") then
		I.Topic.Subscribe("Match_Ended", Module._onMatchEnded)
	end
	if I.Topic.IsRegistered("Crates_Opened") then
		I.Topic.Subscribe("Crates_Opened", Module._onCrateOpened)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Create Replicator

--[[
	Makes a joining player's Tutorial folder.
]]
function Module._createReplicator(player: Player)
	--[[ Publishing ]]

	I.Replicator.CreateFolder(player, _localName)
	Module._publish(player)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Complete Match

--[[
	**SERVER** |
	Marks the tutorial match played and gives the coins for the tutorial crate, once.
]]
--- @return boolean
function Module.CompleteMatch(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Tutorial"]

	--[[ Checks ]]

	-- Check if the match isn't marked yet
	if moduleData["MatchDone"] then
		return false
	end

	--[[ Saving ]]

	moduleData["MatchDone"] = true
	I.Currency.Add(player, "Coins", _settings.MATCH_COINS)

	--[[ Publishing ]]

	Module._publish(player)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% On Match Ended

--[[
	Completes the tutorial for everyone in a tutorial match once it ends, and saves it before they travel back.
]]
--- @param metadata Match_Metadata
function Module._onMatchEnded(_placements: any, _stats: any, metadata)
	--[[ Checks ]]

	-- Check if it was the tutorial match
	if metadata.Kind ~= _settings.MATCH_KIND then
		return
	end

	--[[ Completing ]]

	for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		local success: boolean
		local result: any | string?
		success, result = pcall(function()
			if Module.CompleteMatch(player) then
				I.Player.GetProfile(player):Save()
			end
		end)
		if not success then
			warn(`[{_localName}::{script.Name}]: Failed to complete the tutorial for ({player.Name})! - ({result})`)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% On Crate Opened

--[[
	Marks the tutorial crate opened, which moves the player on to equipping its weapons.
]]
function Module._onCrateOpened(player: Player, crateId: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Tutorial"]

	--[[ Checks ]]

	-- Check if it's the tutorial crate
	if crateId ~= _settings.CRATE_ID then
		return
	end

	--[[ Saving ]]

	moduleData["CrateOpened"] = true

	--[[ Publishing ]]

	Module._publish(player)
end

--%%%%%%%%%%%%%%%%%%%% On Step

--[[
	A client reports a tutorial step: "Equipped" finishes the tutorial once both starter weapons are in the loadout.
]]
function Module._onStep(player: Player, step: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Tutorial"]

	--[[ Checks ]]

	-- Check if it's the equip step, after the crate
	if step ~= "Equipped" or not moduleData["CrateOpened"] or moduleData["Done"] then
		return
	end

	-- Check if both starter weapons are equipped
	local items = I.Loadout.GetMatchLoadout(player) --- @type { string }
	for _index: number, itemId: string in ipairs(_settings.STARTER_WEAPONS) do
		if not table.find(items, itemId) then
			return
		end
	end

	--[[ Saving ]]

	moduleData["Done"] = true

	--[[ Publishing ]]

	Module._publish(player)
end

--%%%%%%%%%%%%%%%%%%%% Publish

--[[
	Writes where the player is in the tutorial into their Tutorial folder: MatchDone, CrateReady (the crate waits),
	EquipReady (the weapons wait to be equipped) and Done.
]]
function Module._publish(player: Player)
	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Tutorial"]

	--[[ Publishing ]]

	I.Replicator.Set(player, _localName, "MatchDone", moduleData["MatchDone"])
	I.Replicator.Set(player, _localName, "CrateReady", moduleData["MatchDone"] and not moduleData["CrateOpened"])
	I.Replicator.Set(player, _localName, "EquipReady", moduleData["CrateOpened"] and not moduleData["Done"])
	I.Replicator.Set(player, _localName, "Done", moduleData["Done"])
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Match Done

--[[
	**SERVER** |
	Returns whether the player has played the tutorial match.
]]
--- @return boolean
function Module.IsMatchDone(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Tutorial"]

	--[[ Returning ]]

	return moduleData["MatchDone"]
end

--%%%%%%%%%%%%%%%%%%%% Is Done

--[[
	**SERVER** |
	Returns whether the player has finished the whole tutorial.
]]
--- @return boolean
function Module.IsDone(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Tutorial"]

	--[[ Returning ]]

	return moduleData["Done"]
end

--%%%%%%%%%%%%%%%%%%%% Can Open Crate

--[[
	**SERVER** |
	Returns whether the tutorial crate waits for the player: after the tutorial match, before it's opened.
]]
--- @return boolean
function Module.CanOpenCrate(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Tutorial"]

	--[[ Returning ]]

	return moduleData["MatchDone"] and not moduleData["CrateOpened"]
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
