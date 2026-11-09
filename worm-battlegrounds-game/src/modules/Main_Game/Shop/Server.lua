--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Shop"

--- @type Shop_Settings
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

	-- The UTC day (os.time() // 86400) the player last opened VIP's free crate
	--- @type Player_ProfileData
	local _pt = I.Player.ProfileTemplate
	_pt["Shop"] = {
		VipCrateDay = 0,
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnPlayerAdded(I.Priority.Replicator, Module._createReplicator)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Shop = {

		--[[ Control ]]

		ClaimVipCrate = Module.ClaimVipCrate,

		--[[ Methods ]]

		IsVip = Module.IsVip,
		CanClaimVipCrate = Module.CanClaimVipCrate,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	I.Topic.Subscribe(`Marketplace_GamePassPurchaseSucceeded-{_settings.VIP_PASS}`, Module._publish)
	Module._mainLoop()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Main Loop

--[[
	Checks every player now and then, so a new day's free crate shows without rejoining.
]]
function Module._mainLoop()
	I.DoEvery.Every(_settings.VIP_CHECK_SECONDS, function()
		for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
			local success: boolean
			local result: any | string?
			success, result = pcall(Module._publish, player)
			if not success then
				warn(`[{_localName}::{script.Name}]: Failed to update player for ({player.Name})! - ({result})`)
			end
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Create Replicator

--[[
	Makes a joining player's Shop folder, then marks them VIP on a thread of its own, since the pass check is a web
	call that would hold up the player's load.
]]
function Module._createReplicator(player: Player)
	--[[ Publishing ]]

	I.Replicator.CreateFolder(player, _localName)
	task.spawn(Module._publish, player)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Claim VIP Crate

--[[
	**SERVER** |
	Uses up today's free VIP crate. Returns false when it isn't ready.
]]
--- @return boolean
function Module.ClaimVipCrate(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Shop"]

	--[[ Checks ]]

	-- Check if today's crate is still unopened
	if not Module.CanClaimVipCrate(player) then
		return false
	end

	--[[ Saving ]]

	moduleData["VipCrateDay"] = os.time() // 86400

	--[[ Publishing ]]

	Module._publish(player)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Publish

--[[
	Writes whether the player is VIP (the Vip attribute every client reads) and whether today's free crate waits
	(VipCrateReady in their Shop folder).
]]
function Module._publish(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	local vip: boolean = Module.IsVip(player)

	--[[ Publishing ]]

	player:SetAttribute("Vip", vip)
	I.Replicator.Set(player, _localName, "VipCrateReady", vip and Module.CanClaimVipCrate(player))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is VIP

--[[
	**SERVER** |
	Returns whether the player owns the VIP pass.
]]
--- @return boolean
function Module.IsVip(player: Player)
	return I.G_Marketplace.PlayerOwnsGamePass(player, _settings.VIP_PASS)
end

--%%%%%%%%%%%%%%%%%%%% Can Claim VIP Crate

--[[
	**SERVER** |
	Returns whether a VIP player hasn't opened today's free crate yet.
]]
--- @return boolean
function Module.CanClaimVipCrate(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Shop"]

	--[[ Returning ]]

	return Module.IsVip(player) and moduleData["VipCrateDay"] < os.time() // 86400
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
