--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "BackpackPlus"

--- @type BackpackPlus_Settings
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
	_pt["BackpackPlus"] = {
		ToolbarSlots = {}, --- @type { [string]: string }
		LastPlatform = nil, --- @type string?
	}

	--- @type Player_SessionData
	local _st = I.Player.SessionTemplate
	_st["BackpackPlus"] = {
		ToolbarResolved = false, --- @type boolean
		NewPlatform = nil, --- @type string?
	}

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Subscribe("Platform_Changed", Module._onPlatformChanged)

	--- @Network
	I.Network.GetEvent("_backpackPlus_UpdateSavedToolbarSlots", { "Player", { Type = "table" } }, { RateLimit = 5, Per = 1 })
	I.Network.Fired("_backpackPlus_UpdateSavedToolbarSlots", Module._updateSavedToolbarSlots)

	I.Network.GetFunction("_backpackPlus_GetSavedToolbarslots", { "Player", { Type = "string", Optional = true } }, { RateLimit = 5, Per = 1 })
	I.Network.OnInvoke("_backpackPlus_GetSavedToolbarslots", Module._getSavedToolbarSlots)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Platform Changed

--[[
	Tracks platform changes until Toolbar data is resolved, then updates LastPlatform.
]]
function Module._onPlatformChanged(player: Player, platform: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["BackpackPlus"]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["BackpackPlus"]

	--[[ Updating ]]

	if not moduleSessionData.ToolbarResolved then
		moduleSessionData.NewPlatform = platform
	else
		moduleData.LastPlatform = platform
	end
end

--%%%%%%%%%%%%%%%%%%%% Update Saved Toolbar Slots

--[[
    Updates slots saved on toolbar, within the last platform's slot count; saved slots above it are kept.
    An entry sent back unchanged is kept as it is.
]]
--- @param newSlotsIds { [string]: string }
function Module._updateSavedToolbarSlots(player: Player, newSlotsIds)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["BackpackPlus"]

	--[[ Checks ]]

	-- Invalid table
	if type(newSlotsIds) ~= "table" then
		return
	end

	--[[ Local Variables ]]

	local toolbarSlotCount: number = _settings.TOOLBAR_SLOTS[moduleData.LastPlatform] or _settings.TOOLBAR_SLOTS["Default"]

	--[[ Updating Slots ]]

	for count: number = 1, toolbarSlotCount do
		--[[ Getting SlotId ]]

		local slotId: string? = newSlotsIds[`{count}`]

		-- Clearing if slot is empty
		if not slotId or type(slotId) ~= "string" then
			moduleData.ToolbarSlots[`{count}`] = nil
			continue
		end

		-- Keeping an entry sent back unchanged (its Tool has not arrived on the client yet)
		if slotId == moduleData.ToolbarSlots[`{count}`] then
			continue
		end

		-- Passed slotId is too long
		if #slotId > 256 then
			continue
		end

		--[[ Tool Check ]]

		local toolUUID: string? = slotId:split("___")[1]

		-- Missing Tool
		if not toolUUID or not I.Tool.Has(player, `{toolUUID}`) then
			moduleData.ToolbarSlots[`{count}`] = nil
			continue
		end

		--[[ Updating ]]

		moduleData.ToolbarSlots[`{count}`] = slotId
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Saved Toolbar Slots

--[[
    Returns player saved Toolbar Slots data and the previous platform.
]]
--- @return { [string]: any }?
function Module._getSavedToolbarSlots(player: Player, currentPlatform: string?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Checks ]]

	-- Ignoring a client platform the Platform module doesn't list
	if currentPlatform and not table.find(I.Settings["Platform"].PLATFORMS, currentPlatform) then
		currentPlatform = nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["BackpackPlus"]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["BackpackPlus"]

	--[[ Capturing Previous Platform ]]

	local lastPlatform: string? = moduleData.LastPlatform

	--[[ Resolving Platform ]]

	local resolvedPlatform: string? = moduleSessionData.NewPlatform or currentPlatform
	if resolvedPlatform then
		moduleData.LastPlatform = resolvedPlatform
	end

	moduleSessionData.ToolbarResolved = true
	moduleSessionData.NewPlatform = nil

	--[[ Returning ]]

	return {
		ToolbarSlots = moduleData.ToolbarSlots,
		LastPlatform = lastPlatform,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
