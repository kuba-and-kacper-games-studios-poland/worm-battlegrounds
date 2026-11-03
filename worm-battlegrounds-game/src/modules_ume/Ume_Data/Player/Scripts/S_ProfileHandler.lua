--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Player"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Players = I.S.Players

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Constants ]]

local KICK_MESSAGE = "ERROR - Data issue, try again shortly!"

--[[ Profiles ]]

local profileStores = {} --- @type { [string]: ProfileStore }

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

--- @class Player_ProfileHandler
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Register Profile

--[[
	Creates and stores a `ProfileStore` for a profile namespace.
]]
function Module.Register(namespace: string, template: table)
	profileStores[namespace] = I.ProfileStore.New("PlayerProfiles", template)
end

--%%%%%%%%%%%%%%%%%%%% Create Profile

--[[
	Loads a saved player profile using the `ProfileStore` module.
]]
--- @return boolean
function Module.Create(player: Player, namespace: string, profilesTable: table, internalProfilesTable: table)
	--- @type ProfileStore
	local profileStore = profileStores[namespace]
	--- @type Player_Profile
	local profile = profileStore:StartSessionAsync(`PlayerProfile_{player.UserId}_{namespace}_{I.Config.Map.ProfileStoreName}`, {
		Cancel = function()
			return not player:IsDescendantOf(Players)
		end,
	})

	if profile then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile.OnSessionEnd:Connect(function()
			if profilesTable[player] then
				profilesTable[player][namespace] = nil
			end
			if internalProfilesTable[player] then
				internalProfilesTable[player][namespace] = nil
			end

			-- Skip the kick when the server is closing or the player already left
			if I.ProfileStore.IsClosing or not player:IsDescendantOf(Players) then
				return
			end

			player:Kick(KICK_MESSAGE)
		end)

		if player and player:IsDescendantOf(Players) == true then
			profilesTable[player] = profilesTable[player] or {}
			internalProfilesTable[player] = internalProfilesTable[player] or {}
			profilesTable[player][namespace] = profile.Data
			internalProfilesTable[player][namespace] = profile
			return true
		else
			profile:EndSession()
		end
	else
		--[[
			The profile could not be loaded, possibly due to it being accessed
			by another Roblox server at the same time.
		]]

		-- Skip the kick when the server is closing
		if not I.ProfileStore.IsClosing then
			player:Kick(KICK_MESSAGE)
		end
	end

	return false
end

--%%%%%%%%%%%%%%%%%%%% Release Profile

--[[
	Releases the `Profile` and removes the session lock using the `ProfileStore.EndSession` method.
]]
function Module.Release(player: Player, profilesTable: table, internalProfilesTable: table)
	if internalProfilesTable[player] ~= nil then
		for _, profile in pairs(internalProfilesTable[player]) do
			profile:EndSession()
		end
	end

	profilesTable[player] = nil
	internalProfilesTable[player] = nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
