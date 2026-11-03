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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Info Cache ]]

local infoCacheTime: number = 300
local cachedInfo = {} --- @type { [string]: Badge_CachedInfo }

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
	--------- REGISTRY ---------
	----------------------------

	if I.Env.IsClient then
		--- @Network
		I.Network.GetEvent("Badge_Awarded", { "string" })
	end

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.G_Badge = {

		--[[ Methods ]]

		GetInfo = Module.GetInfo,
		Owns = Module.Owns,
		OwnsMany = Module.OwnsMany,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Info

--[[
	Returns a copy of the badge info from the Roblox API.
	Info read in the last 5 minutes is returned without a new request.
]]
--- @return Badge_BadgeInfo | nil
function Module.GetInfo(badgeName: string)
	--[[ Getting Data ]]

	--- @type Badge_BadgesTableEntry
	local badgeData = badgesData[badgeName]
	if not badgeData then
		warn(`[{_localName}::{script.Name}]: ({badgeName}) is not a valid (badgeName)!`)
		return nil
	end

	--[[ Cache ]]

	--- @type Badge_CachedInfo?
	local cached = cachedInfo[badgeName]

	-- Return info read recently
	if cached and os.clock() - cached.Time < infoCacheTime then
		return table.clone(cached.Info)
	end

	--[[ Getting Info ]]

	local success: boolean
	local badgeInfo --- @type Badge_BadgeInfo | string
	success, badgeInfo = pcall(BadgeService.GetBadgeInfoAsync, BadgeService, badgeData.Id)

	-- Check if the info was read
	if not success or type(badgeInfo) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Failed to get info for Badge ({badgeName})! - {badgeInfo}`)
		return nil
	end

	--[[ Saving ]]

	cachedInfo[badgeName] = { Info = badgeInfo, Time = os.clock() }

	--[[ Returning ]]

	return table.clone(badgeInfo)
end

--%%%%%%%%%%%%%%%%%%%% Owns

--[[
	Returns a boolean indicating whether the player owns a certain badge.
]]
--- @return boolean
function Module.Owns(playerId: number, badgeName: string)
	--[[ Getting Data ]]

	--- @type Badge_BadgesTableEntry
	local badgeData = badgesData[badgeName]
	if not badgeData then
		warn(`[{_localName}::{script.Name}]: ({badgeName}) is not a valid (badgeName)!`)
		return false
	end

	local success: boolean, hasBadge: boolean = pcall(BadgeService.UserHasBadgeAsync, BadgeService, playerId, badgeData.Id)

	--[[ Returning ]]

	if success then
		return hasBadge == true
	else
		warn(`[{_localName}::{script.Name}]: Failed to get ownership of Badge ({badgeName}) for ({playerId})! - {hasBadge}`)
		return false
	end
end

--%%%%%%%%%%%%%%%%%%%% Owns Many

--[[
	Returns, for each badge name, whether the user owns it, checking up to 10 badges per request.
	Returns nil when a request fails. On the client it only works for the local player.
]]
--- @param badgeNames { string }
--- @return { [string]: boolean }?
function Module.OwnsMany(userId: number, badgeNames)
	--[[ Local Variables ]]

	local owned = {} --- @type { [string]: boolean }
	local namesById = {} --- @type { [number]: string }
	local badgeIds = {} --- @type { number }

	--[[ Finding Ids ]]

	for _: number, badgeName: string in ipairs(badgeNames) do
		--- @type Badge_BadgesTableEntry?
		local badgeData = badgesData[badgeName]

		-- Skip names that aren't in Badges.lua
		if not badgeData then
			warn(`[{_localName}::{script.Name}]: ({badgeName}) is not a valid (badgeName)!`)
			continue
		end

		owned[badgeName] = false
		namesById[badgeData.Id] = badgeName
		table.insert(badgeIds, badgeData.Id)
	end

	--[[ Requesting ]]

	for startIndex: number = 1, #badgeIds, 10 do
		local chunk = table.move(badgeIds, startIndex, math.min(startIndex + 9, #badgeIds), 1, {}) --- @type { number }

		local success: boolean
		local result: any | string?
		success, result = pcall(BadgeService.CheckUserBadgesAsync, BadgeService, userId, chunk)

		-- Check if the request succeeded
		if not success then
			warn(`[{_localName}::{script.Name}]: Failed to check Badges for ({userId})! - {result}`)
			return nil
		end

		--[[ Saving ]]

		for _: number, ownedId: number in ipairs(result) do
			-- Skip ids that weren't asked for
			if not namesById[ownedId] then
				continue
			end

			owned[namesById[ownedId]] = true
		end
	end

	--[[ Returning ]]

	return owned
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
