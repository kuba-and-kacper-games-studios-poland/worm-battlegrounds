--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Badge"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local BadgeService = I.S.BadgeService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type Badge_Badges
local badgesData = require(I.Dirs.GlobalData.Badge.Badges)

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
	_pt["Badge"] = {
		RewardsClaimed = {}, --- @type { [string]: number }
	}

	--- @type Player_SessionData
	local _st = I.Player.SessionTemplate
	_st["Badge"] = {
		RewardsClaimed = {}, --- @type { [string]: number }
		Owned = {}, --- @type { [string]: boolean }
		Awarding = {}, --- @type { [string]: boolean }
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnCharacterAdded(I.Priority.Late, function(player: Player, _character: Model)
		task.spawn(function() -- Wrapping to avoid yielding
			Module.RewardForAll(player)
		end)
	end)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Badge_Awarded", { "Player", "string" })

	--- @Network
	I.Network.GetEvent("Badge_Awarded")

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Badge = {

		--[[ Awarding Control ]]

		Award = Module.Award,

		--[[ Rewarding Control ]]

		RewardFor = Module.RewardFor,
		RewardForAll = Module.RewardForAll,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Awarding Control

--%%%%%%%%%%%%%%%%%%%% Award

--[[
	**SERVER** |
	Awards a badge using the Roblox API to the given player.
	Also returns why: `"Awarded"`, `"AlreadyOwned"`, `"Disabled"`, `"WrongPlace"` or `"Failed"`.
]]
--- @return boolean
--- @return Badge_AwardResult
function Module.Award(player: Player, badgeName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false, "Failed"
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Badge"]

	--- @type Badge_BadgesTableEntry
	local badgeData = badgesData[badgeName]
	if not badgeData then
		warn(`[{_localName}::{script.Name}]: ({badgeName}) is not a valid (badgeName)!`)
		return false, "Failed"
	end

	--[[ Checks ]]

	-- Check if badge can be awarded in the current place/map
	if badgeData["AwardPlaces"] and not Module._isPlaceAllowed(badgeData["AwardPlaces"]) then
		return false, "WrongPlace"
	end

	-- Check if the session already knows the player owns it
	if moduleSessionData.Owned[badgeName] == true then
		return false, "AlreadyOwned"
	end

	-- Check if the same badge is already being awarded
	if moduleSessionData.Awarding[badgeName] then
		return false, "Failed"
	end

	--[[ Awarding ]]

	moduleSessionData.Awarding[badgeName] = true

	local awarded: boolean
	local reason --- @type Badge_AwardResult
	awarded, reason = Module._awardBadge(player, badgeName, badgeData)

	moduleSessionData.Awarding[badgeName] = nil

	--[[ Returning ]]

	return awarded, reason
end

--%%%%%%%%%%%%%%%%%%%% Award Badge

--[[
	Makes the web calls of `Award`: the badge info, ownership when the session doesn't know it, and the award itself.
	Grants the rewards and publishes on success.
]]
--- @param badgeData Badge_BadgesTableEntry
--- @return boolean
--- @return Badge_AwardResult
function Module._awardBadge(player: Player, badgeName: string, badgeData)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false, "Failed"
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Badge"]

	--- @type Badge_BadgeInfo?
	local badgeInfo = I.G_Badge.GetInfo(badgeName)
	if not badgeInfo then
		return false, "Failed"
	end

	--[[ Checks ]]

	-- Check if the badge is enabled
	if not badgeInfo.IsEnabled then
		print(`[{_localName}::{script.Name}]: ({badgeName}) badge is disabled!`)
		return false, "Disabled"
	end

	-- Check ownership when the session doesn't know it yet
	if moduleSessionData.Owned[badgeName] == nil and I.G_Badge.Owns(player.UserId, badgeName) then
		moduleSessionData.Owned[badgeName] = true
		return false, "AlreadyOwned"
	end

	--[[ Awarding ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(BadgeService.AwardBadgeAsync, BadgeService, player.UserId, badgeData.Id)

	-- Check if the badge was awarded
	if not success or not result then
		warn(`[{_localName}::{script.Name}]: Error while awarding ({badgeName}) for ({player.Name}) - {result}`)
		return false, "Failed"
	end

	moduleSessionData.Owned[badgeName] = true

	-- Check if player is still valid | SERVER
	if not I.Player.Valid(player) then
		return false, "Failed"
	end

	--[[ Rewarding ]]

	Module.RewardFor(player, badgeName)

	--[[ Publishing ]]

	I.Topic.Publish("Badge_Awarded", player, badgeName)
	I.Network.Fire("Badge_Awarded", player, badgeName)

	--[[ Returning ]]

	return true, "Awarded"
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Rewarding Control

--%%%%%%%%%%%%%%%%%%%% Reward For All

--[[
	**SERVER** |
	Awards rewards for all badges player owns.
	Ownership the session doesn't know yet is read in batches of 10 badges, only for badges with a reward to run here.
]]
--- @return { [string]: { string } }?
function Module.RewardForAll(player: Player, rewardType: "Single" | "Session" | "Character"?, forceReward: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Badge"]

	--[[ Reading Ownership ]]

	-- Forced rewards skip ownership
	if not forceReward then
		local unknownNames = {} --- @type { string }

		--- @param badgeData Badge_BadgesTableEntry
		for badgeName: string, badgeData in pairs(badgesData) do
			-- Skip badges whose ownership is known or that have nothing to run here
			if moduleSessionData.Owned[badgeName] ~= nil or not Module._canReward(badgeData, rewardType) then
				continue
			end

			table.insert(unknownNames, badgeName)
		end

		--- @type { [string]: boolean }?
		local ownedNames = if #unknownNames > 0 then I.G_Badge.OwnsMany(player.UserId, unknownNames) else nil

		for badgeName: string, isOwned: boolean in pairs(ownedNames or {}) do
			moduleSessionData.Owned[badgeName] = isOwned
		end
	end

	--[[ Rewarding ]]

	local rewarded = {} --- @type { [string]: { string } }

	for badgeName: string, _ in pairs(badgesData) do
		-- Skip badges the player doesn't own or whose ownership couldn't be read
		if not forceReward and moduleSessionData.Owned[badgeName] ~= true then
			continue
		end

		local success: boolean
		local grantedRewardTypes --- @type { string }?
		success, grantedRewardTypes = Module.RewardFor(player, badgeName, rewardType, forceReward)
		if success then
			rewarded[badgeName] = grantedRewardTypes
		end
	end

	--[[ Returning ]]

	return rewarded
end

--%%%%%%%%%%%%%%%%%%%% Reward For

--[[
	**SERVER** |
	Awards badge rewards for player.
	Returns false before any web call when the badge has no reward of that type or can't be rewarded here.
]]
--- @return boolean
--- @return { string }?
function Module.RewardFor(player: Player, badgeName: string, rewardType: "Single" | "Session" | "Character"?, forceReward: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Badge Data ]]

	--- @type Badge_BadgesTableEntry
	local badgeData = badgesData[badgeName]
	if not badgeData then
		warn(`[{_localName}::{script.Name}]: ({badgeName}) is not a valid (badgeName)!`)
		return false
	end

	--[[ Checks ]]

	-- Check if the badge has a reward of that type and can be rewarded in the current place/map
	if not Module._canReward(badgeData, rewardType) then
		return false
	end

	-- Player owns check
	forceReward = forceReward == true
	if not forceReward and not Module._owns(player, badgeName) then
		return false
	end

	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Badge"]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local sessionModuleData = sessionData["Badge"]

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Rewarding

	local grantedRewardTypes = {} --- @type { string }

	-- Single Reward
	if badgeData.SingleReward and (rewardType == nil or rewardType == "Single") then
		local previousVersion: number? = moduleData.RewardsClaimed[badgeName]
		local rewardedVersion: number = previousVersion or 0

		if rewardedVersion < badgeData.Version or forceReward then
			-- Saving the claim first so a second call can't grant it twice
			moduleData.RewardsClaimed[badgeName] = badgeData.Version

			-- Executing reward function
			local success: boolean
			local result: any | string?
			success, result = pcall(badgeData.SingleReward, player)

			-- Keep the claim only when the reward ran and didn't return false
			if success and result ~= false then
				table.insert(grantedRewardTypes, "Single")
			else
				moduleData.RewardsClaimed[badgeName] = previousVersion

				-- Warn when the reward errored
				if not success then
					warn(`[{_localName}::{script.Name}]: Failed to grant (SingleReward) for Badge ({badgeName}) for ({player.Name}) - {result}`)
				end
			end
		end
	end

	-- Session Reward
	if badgeData.SessionReward and (rewardType == nil or rewardType == "Session") then
		local previousVersion: number? = sessionModuleData.RewardsClaimed[badgeName]
		local rewardedVersion: number = previousVersion or 0

		if rewardedVersion < badgeData.Version or forceReward then
			-- Saving the claim first so a second call can't grant it twice
			sessionModuleData.RewardsClaimed[badgeName] = badgeData.Version

			-- Executing reward function
			local success: boolean
			local result: any | string?
			success, result = pcall(badgeData.SessionReward, player)

			-- Keep the claim only when the reward ran and didn't return false
			if success and result ~= false then
				table.insert(grantedRewardTypes, "Session")
			else
				sessionModuleData.RewardsClaimed[badgeName] = previousVersion

				-- Warn when the reward errored
				if not success then
					warn(`[{_localName}::{script.Name}]: Failed to grant (SessionReward) for Badge ({badgeName}) for ({player.Name}) - {result}`)
				end
			end
		end
	end

	-- Character Reward
	if badgeData.CharacterReward and (rewardType == nil or rewardType == "Character") then
		-- Executing reward function
		local success: boolean, errorMessage: string = pcall(function()
			return badgeData.CharacterReward(player)
		end)

		-- Saving / Printing error
		if success then
			table.insert(grantedRewardTypes, "Character")
		else
			warn(`[{_localName}::{script.Name}]: Failed to grant (CharacterReward) for Badge ({badgeName}) for ({player.Name}) - {errorMessage}`)
		end
	end

	return true, grantedRewardTypes
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Owns

--[[
	Returns whether the player owns the badge, from the session when it's known there,
	otherwise from one ownership request whose answer is kept for the session.
]]
--- @return boolean
function Module._owns(player: Player, badgeName: string)
	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Badge"]

	--[[ Checks ]]

	-- Return ownership the session already knows
	if moduleSessionData.Owned[badgeName] ~= nil then
		return moduleSessionData.Owned[badgeName]
	end

	--[[ Requesting ]]

	--- @type { [string]: boolean }?
	local ownedNames = I.G_Badge.OwnsMany(player.UserId, { badgeName })

	-- Return false without saving when ownership couldn't be read
	if not ownedNames then
		return false
	end

	--[[ Saving ]]

	moduleSessionData.Owned[badgeName] = ownedNames[badgeName] == true

	--[[ Returning ]]

	return moduleSessionData.Owned[badgeName]
end

--%%%%%%%%%%%%%%%%%%%% Can Reward

--[[
	Returns whether the badge has a reward of `rewardType` (any type when nil) and can be rewarded in the current place or map.
]]
--- @param badgeData Badge_BadgesTableEntry
--- @return boolean
function Module._canReward(badgeData, rewardType: string?)
	--[[ Local Variables ]]

	local hasReward: boolean
	if rewardType == "Single" then
		hasReward = badgeData.SingleReward ~= nil
	elseif rewardType == "Session" then
		hasReward = badgeData.SessionReward ~= nil
	elseif rewardType == "Character" then
		hasReward = badgeData.CharacterReward ~= nil
	else
		hasReward = badgeData.SingleReward ~= nil or badgeData.SessionReward ~= nil or badgeData.CharacterReward ~= nil
	end

	--[[ Checks ]]

	-- Check if the badge has a reward to run
	if not hasReward then
		return false
	end

	--[[ Returning ]]

	return badgeData.RewardPlaces == nil or Module._isPlaceAllowed(badgeData.RewardPlaces)
end

--%%%%%%%%%%%%%%%%%%%% Is Place Allowed

--[[
	Returns whether the current place (`PlaceId`) or place and map (`PlaceId_MapId`) is in the list.
]]
--- @param places { string }
--- @return boolean
function Module._isPlaceAllowed(places)
	--[[ Local Variables ]]

	local placeId: string = `{I.Config.PlaceLoader.PlaceId}`
	local placeMapId: string = `{I.Config.PlaceLoader.PlaceId}_{I.Config.PlaceLoader.MapId}`

	--[[ Returning ]]

	return table.find(places, placeId) ~= nil or table.find(places, placeMapId) ~= nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
