--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Platform"

--- @type Platform_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type { [Player]: string }
local platforms = {}

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

	I.G_Player.OnPlayerRemoving(I.Priority.Late, Module._clearPlatform)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Platform_Changed", { "Player", "string" })

	--- @Network
	I.Network.GetEvent("Platform_Changed", { "Player", "string" }, { RateLimit = 5, Per = 1 })
	I.Network.Fired("Platform_Changed", Module._changed)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Platform = {

		--[[ Methods ]]

		Get = Module.Get,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Clear Platform

--[[
	Forgets a leaving player's platform.
]]
function Module._clearPlatform(player: Player)
	--[[ Clearing ]]

	platforms[player] = nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Changed

--[[
	Saves the platform a player's client reported and publishes it when it changed.
]]
function Module._changed(player: Player, platform: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Checks ]]

	-- Check if the platform is a listed one
	if not platform or not table.find(_settings.PLATFORMS, platform) then
		return
	end

	-- Skip when the platform did not change
	if platforms[player] == platform then
		return
	end

	--[[ Saving ]]

	platforms[player] = platform

	--[[ Publishing ]]

	I.Topic.Publish("Platform_Changed", player, platform)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	**SERVER** |
	Returns the platform the player's client last reported, `Desktop` until it has reported one.
]]
--- @return "Desktop" | "Mobile" | "Console" | "VR"
function Module.Get(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return "Desktop"
	end

	--[[ Returning ]]

	return platforms[player] or "Desktop"
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
