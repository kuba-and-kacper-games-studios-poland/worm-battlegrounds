--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Tutorial"

--- @type Tutorial_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The funnel steps logged for each player in this server (weak, so players who left go)
local funnelLogged = setmetatable({}, { __mode = "k" }) --- @type { [Player]: { [number]: boolean } }

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
	I.G_Player.OnPlayerAdded(I.Priority.Default, Module._giveStarters)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("Tutorial_Step", { "Player", "string" }, { RateLimit = 5 })
	I.Network.Fired("Tutorial_Step", Module._onStep)
	I.Network.GetEvent("Tutorial_End", { "Player" }, { RateLimit = 1 })
	I.Network.Fired("Tutorial_End", Module._onEnd)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Tutorial = {

		--[[ Control ]]

		CompleteMatch = Module.CompleteMatch,
		Skip = Module.Skip,

		--[[ Methods ]]

		IsMatchDone = Module.IsMatchDone,
		IsDone = Module.IsDone,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	-- Matches end on the Match map
	if I.Topic.IsRegistered("Match_Ended") then
		I.Topic.Subscribe("Match_Ended", Module._onMatchEnded)
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
	Marks the tutorial match played and gives the starter weapons, once; the diamonds wait for the lobby's equip step.
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
	Module._giveStarters(player)

	--[[ Publishing ]]

	Module._publish(player)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Skip

--[[
	**SERVER** |
	Marks the whole tutorial done without playing it (no match, no diamonds, no weapons, no equip step), for Studio
	playtests that leave it off.
]]
function Module.Skip(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Tutorial"]

	--[[ Saving ]]

	moduleData["MatchDone"] = true
	moduleData["CrateOpened"] = true
	moduleData["Done"] = true

	--[[ Publishing ]]

	Module._publish(player)
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
		-- Skip players in the lobby (the Studio map plays both on one server)
		if not player:GetAttribute("InMatch") then
			continue
		end

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

--%%%%%%%%%%%%%%%%%%%% Give Starters

--[[
	Gives the starter weapons once the tutorial match is played (the testers, 2026-11-15: no crate opening in the
	tutorial) and marks them given (`CrateOpened`, named for the crate that gave them before), which moves the player on
	to equipping them. One who played the match before then and never opened the crate gets them on their next join.
]]
function Module._giveStarters(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Tutorial"]

	--[[ Checks ]]

	-- Check if the match is played and the weapons not given yet
	if not moduleData["MatchDone"] or moduleData["CrateOpened"] then
		return
	end

	--[[ Saving ]]

	for _index: number, itemId: string in ipairs(_settings.STARTER_WEAPONS) do
		I.Inventory.AddItem(player, itemId, "1", true)
	end
	moduleData["CrateOpened"] = true

	--[[ Publishing ]]

	Module._publish(player)
end

--%%%%%%%%%%%%%%%%%%%% On Step

--[[
	A client reports a tutorial step: a hint it showed for the first time goes to the funnel, and "Equipped" finishes
	the tutorial once a starter weapon is in the loadout (the owner, 2026-11-24: one equip, then the diamonds).
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

	--[[ Funnel ]]

	if not moduleData["Done"] and step ~= "Equipped" then
		Module._logFunnel(player, step)
	end

	--[[ Checks ]]

	-- Check if it's the equip step, after the weapons were given
	if step ~= "Equipped" or not moduleData["CrateOpened"] or moduleData["Done"] then
		return
	end

	-- Check if a starter weapon is equipped
	local items = I.Loadout.GetMatchLoadout(player) --- @type { string }
	local equipped: boolean = false
	for _index: number, itemId: string in ipairs(_settings.STARTER_WEAPONS) do
		equipped = equipped or table.find(items, itemId) ~= nil
	end
	if not equipped then
		return
	end

	--[[ Finishing ]]

	Module._logFunnel(player, "Equipped")
	Module._finish(player)
end

--%%%%%%%%%%%%%%%%%%%% On End

--[[
	END TUTORIAL in the tutorial match: ends the whole tutorial at once, with the starter weapons and the diamonds (they fly
	into the diamonds slot in the lobby) and no equip step, and saves it; the client then leaves the match.
]]
function Module._onEnd(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Tutorial"]

	--[[ Checks ]]

	-- Check if the player is in the tutorial match, and the tutorial isn't done
	if moduleData["Done"] or not player:GetAttribute("InMatch") or I.Match.GetMetadata().Kind ~= _settings.MATCH_KIND then
		return
	end

	--[[ Saving ]]

	moduleData["MatchDone"] = true
	Module._giveStarters(player)
	Module._finish(player)

	--[[ Persisting ]]

	task.spawn(function()
		local success: boolean
		local result: any | string?
		success, result = pcall(function()
			I.Player.GetProfile(player):Save()
		end)
		if not success then
			warn(`[{_localName}::{script.Name}]: Failed to save the ended tutorial for ({player.Name})! - ({result})`)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Finish

--[[
	Marks the whole tutorial done and pays its diamonds, which the lobby plays flying from the player's snail into the
	diamonds slot (Progression's replay).
]]
function Module._finish(player: Player)
	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Tutorial"]

	--[[ Saving ]]

	moduleData["Done"] = true
	I.Currency.Add(player, "Diamonds", _settings.MATCH_DIAMONDS)
	I.Progression.AddReplayDiamonds(player, _settings.MATCH_DIAMONDS)

	--[[ Publishing ]]

	Module._publish(player)
end

--%%%%%%%%%%%%%%%%%%%% Log Funnel

--[[
	Logs a tutorial step in the Roblox onboarding funnel, by its place in FUNNEL_STEPS, once per player in this server.
]]
function Module._logFunnel(player: Player, step: string)
	--[[ Local Variables ]]

	local index: number? = table.find(_settings.FUNNEL_STEPS, step)
	local logged = funnelLogged[player] or {} --- @type { [number]: boolean }

	--[[ Checks ]]

	-- Check if it's a funnel step not logged yet
	if not index or logged[index] then
		return
	end

	--[[ Logging ]]

	logged[index] = true
	funnelLogged[player] = logged
	local success: boolean
	local result: any | string?
	success, result = pcall(function()
		I.S.AnalyticsService:LogOnboardingFunnelStepEvent(player, index, step)
	end)
	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to log the funnel step ({step}) for ({player.Name})! - ({result})`)
	end
end

--%%%%%%%%%%%%%%%%%%%% Publish

--[[
	Writes where the player is in the tutorial into their Tutorial folder: MatchDone, EquipReady (the weapons wait to
	be equipped) and Done.
]]
function Module._publish(player: Player)
	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Tutorial"]

	--[[ Publishing ]]

	I.Replicator.Set(player, _localName, "MatchDone", moduleData["MatchDone"])
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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
