--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

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

--- @class Combat_CommandBar_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers the commands that give weapons and utilities mid-match and fill their uses, for testing (each acts on the
	invoker's own snail unless it names another by its name, its player's username or its id), and `aimbot`, which turns a player's aim guide on or off.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Get Snail Id

	--[[
		Returns the participant id and the name of the snail a command acts on: the one it names (by its name, its
		player's username or its id), or the invoker's own. Text that names no snail comes back as both.
	]]
	--- @return string, string
	local function getSnailId(invoker: Player | number, snail: string?)
		--[[ Data ]]

		local query: string = snail or `P_{if typeof(invoker) == "Instance" then invoker.UserId else invoker}`
		local participant = I.Match.FindParticipant(query) --- @type Match_Participant?

		--[[ Returning ]]

		if participant then
			return participant.Id, participant.DisplayName
		end
		return query, query
	end

	--%%%%%%%%%%%%%%%%%%%% Control Functions

	local function give(invoker: Player | number, itemId: string, snail: string?)
		--[[ Local Variables ]]

		local id: string
		local name: string
		id, name = getSnailId(invoker, snail)

		--[[ Executing ]]

		-- Check if the item was given
		if not I.Combat.Give(id, itemId) then
			return false, `No snail $|cr$|{name}#| in play, or $|cr$|{itemId}#| isn't an item`
		end

		--[[ Returning ]]

		return true, `Gave $|cr$|{itemId}#| to $|cr$|{name}#|`
	end

	local function refill(invoker: Player | number, snail: string?)
		--[[ Local Variables ]]

		local id: string
		local name: string
		id, name = getSnailId(invoker, snail)

		--[[ Executing ]]

		-- Check if the uses were filled
		if not I.Combat.Refill(id) then
			return false, `No snail $|cr$|{name}#| in play`
		end

		--[[ Returning ]]

		return true, `Filled every use of $|cr$|{name}#| and cleared its cooldowns`
	end

	local function aimbot(player: Player)
		--[[ Checks ]]

		-- Check if the player is in a match
		if not player:GetAttribute("InMatch") then
			return false, `$|cr$|{player.Name}#| isn't in a match`
		end

		--[[ Saving ]]

		-- Only for this match: it goes off when the player leaves it
		local on: boolean = not player:GetAttribute("Aimbot")
		player:SetAttribute("Aimbot", on or nil)
		if on then
			player:GetAttributeChangedSignal("InMatch"):Once(function()
				player:SetAttribute("Aimbot", nil)
			end)
		end

		--[[ Returning ]]

		return true, `Aimbot $|cr$|{if on then "on" else "off"}#| for $|cr$|{player.Name}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Dictionaries ]]

	-- Weapons and utilities (the jetpack, potions, heals), so either can be given for testing
	local itemIds = {} --- @type { string }
	local weapons = {} --- @type { [string]: Arsenal_WeaponData }
	local utilities = {} --- @type { [string]: Arsenal_UtilityData }
	weapons, utilities = I.G_Arsenal.GetAll()
	--- @param _row Arsenal_WeaponData
	for itemId: string, _row in pairs(weapons) do
		table.insert(itemIds, itemId)
	end
	--- @param _row Arsenal_UtilityData
	for itemId: string, _row in pairs(utilities) do
		table.insert(itemIds, itemId)
	end
	table.sort(itemIds)
	I.AdminPanel_CommandBar.SetDictionary("Combat_ItemIds", itemIds, 255)

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "give" },
			Args = {
				{ name = "itemId", types = { "string" }, dict = "Combat_ItemIds", requireDict = true },
				{ name = "snail", types = { "string" }, dict = "Match_Snails", optional = true },
			},
			PassInvoker = true,
			Callback = give,
		},
		{
			Aliases = { "refill" },
			Args = {
				{ name = "snail", types = { "string" }, dict = "Match_Snails", optional = true },
			},
			PassInvoker = true,
			Callback = refill,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Combat_Server", {
		Aliases = { "combat" },
		PermissionLevel = 255,

		Variants = variants,
	})
	I.AdminPanel_CommandBar.Register("Combat_Aimbot", {
		Aliases = { "aimbot" },
		PermissionLevel = 255,

		Args = {
			{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
		},
		Callback = aimbot,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
