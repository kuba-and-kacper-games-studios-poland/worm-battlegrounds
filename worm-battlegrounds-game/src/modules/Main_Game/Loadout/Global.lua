--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Loadout"

--- @type Loadout_Settings
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
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.G_Loadout = {

		--[[ Methods ]]

		GetBestLook = Module.GetBestLook,
		GetWornLook = Module.GetWornLook,
		GetLookRank = Module.GetLookRank,
		GetLookUnlock = Module.GetLookUnlock,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Best Look

--[[
	Returns the best look a player has for a weapon or utility: "Golden" (GOLDEN_COPIES or a level reward), "Shiny"
	(SHINY_COPIES or a level reward) or "Normal". Copies count on the server and on the player's own screen; the
	Bazooka has none, so its level alone counts.
]]
--- @return string
function Module.GetBestLook(player: Player, itemId: string)
	-- Check if player is valid | SERVER
	if I.Env.IsServer and not I.Player.Valid(player) then
		return "Normal"
	end

	--[[ Local Variables ]]

	local copies: number = 0
	local reward: string? = I.G_Progression.GetPlayerWeaponVariant(player, itemId)

	--[[ Counting ]]

	if itemId ~= _settings.BASIC_WEAPON then
		if I.Env.IsServer then
			copies = tonumber(I.Inventory.GetItem(player, itemId)) or 0
		elseif player == I.S.Players.LocalPlayer then
			copies = tonumber(I.Inventory.Items and I.Inventory.Items.Standard and I.Inventory.Items.Standard[itemId]) or 0
		end
	end

	--[[ Returning ]]

	if copies >= _settings.GOLDEN_COPIES or reward == "Golden" then
		return "Golden"
	end
	return if copies >= _settings.SHINY_COPIES or reward ~= nil then "Shiny" else "Normal"
end

--%%%%%%%%%%%%%%%%%%%% Get Worn Look

--[[
	Returns the look a player's weapon wears: the one they picked (Profile Loadout.Looks, "Look:Best", and the
	WeaponLooks Player attribute on clients) while no better look opened since, else their best.
]]
--- @return string
function Module.GetWornLook(player: Player, itemId: string)
	-- Check if player is valid | SERVER
	if I.Env.IsServer and not I.Player.Valid(player) then
		return "Normal"
	end

	--[[ Data ]]

	local looks = {} --- @type { [string]: string }
	if I.Env.IsServer then
		looks = I.Player.GetProfile(player).Data["Loadout"]["Looks"]
	else
		local success: boolean
		local result: any | string?
		success, result = pcall(I.S.HttpService.JSONDecode, I.S.HttpService, player:GetAttribute("WeaponLooks") or "{}")
		looks = if success and type(result) == "table" then result else {}
	end

	--[[ Local Variables ]]

	local best: string = Module.GetBestLook(player, itemId)
	local choice = string.split(looks[itemId] or "", ":") --- @type { string }

	--[[ Returning ]]

	if choice[2] == best and Module.GetLookRank(choice[1]) > 0 and Module.GetLookRank(choice[1]) < Module.GetLookRank(best) then
		return choice[1]
	end
	return best
end

--%%%%%%%%%%%%%%%%%%%% Get Look Rank

--[[
	Returns a look's place in LOOKS (Normal 1, Shiny 2, Golden 3), or 0 for an unknown one.
]]
--- @return number
function Module.GetLookRank(look: string)
	return table.find(_settings.LOOKS, look) or 0
end

--%%%%%%%%%%%%%%%%%%%% Get Look Unlock

--[[
	Returns how a look not had yet opens for a weapon, in a few words: the level that gives it (Progression's
	WEAPON_REWARDS: "Level 90"), else its copies ("100 copies").
]]
--- @return string
function Module.GetLookUnlock(itemId: string, look: string)
	--[[ Searching ]]

	--- @param reward Progression_WeaponReward
	for level: number, reward in pairs(I.Settings["Progression"].WEAPON_REWARDS) do
		if reward.Item == itemId and reward.Variant == look then
			return `Level {level}`
		end
	end

	--[[ Returning ]]

	return `{if look == "Golden" then _settings.GOLDEN_COPIES else _settings.SHINY_COPIES} copies`
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
}
