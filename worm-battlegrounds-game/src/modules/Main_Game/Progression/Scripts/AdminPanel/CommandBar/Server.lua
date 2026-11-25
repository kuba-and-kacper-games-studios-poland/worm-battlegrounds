--[[
	Created By: 	HungryN00B
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

--- @class Progression_CommandBar_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Module._setDictionaries()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers the commands that add levels to a player by hand, for testing (the XP those levels take, so each level's
	rewards and toast come as they do after a match, and the lobby plays them back as after a match), that play a
	match's XP lines over a number of levels, and that give a player a weapon's look or the Golden starter weapons.
]]
function Module._registerCommands()
	--[[ Local Variables ]]

	local settings = I.Settings["Progression"] --- @type Progression_Settings

	--%%%%%%%%%%%%%%%%%%%% Add Level

	--[[
		Takes a player up a number of levels (the highest level at most), queues them for the lobby's replay (their
		level-ups and weapon unlocks), and says the level they're at now.
	]]
	local function addLevel(player: Player, levels: number)
		--[[ Checks ]]

		-- Check if levels is a whole number above 0
		if levels < 1 or levels % 1 ~= 0 then
			return false, `Invalid Levels: $|cr$|{levels}#| must be a whole number above $|cr$|0#|`
		end

		--[[ Executing ]]

		local before = I.Progression.GetProgress(player) --- @type Progression_Progress
		local beforeXP: number = tonumber(I.Statistic.Get(player, "XP")) or 0
		local level: number
		local leveledUp: boolean
		level, leveledUp = I.Progression.AddLevels(player, levels)

		--[[ Replay ]]

		if leveledUp then
			I.Progression.SetReplay(player, {
				Lines = { { Key = "Admin", Label = "Levels added", Count = 1, Amount = (tonumber(I.Statistic.Get(player, "XP")) or 0) - beforeXP } },
				Before = before,
				After = I.Progression.GetProgress(player),
				Costs = {},
			})
		end

		--[[ Returning ]]

		if not leveledUp then
			return false, `$|cr$|{player.Name}#| is already at the highest level ($|cr$|{level}#|)`
		end
		return true, `$|cr$|{player.Name}#| is now level $|cr$|{level}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Match XP

	--[[
		Plays a match's XP in the lobby, as after a round: takes a player up a number of levels (0 for none) and partway
		into the next, split into a match's lines (played, victory, knockouts), and queues the replay that fills the bar
		with them, level-ups and weapon unlocks included.
	]]
	local function matchXp(player: Player, levels: number)
		--[[ Checks ]]

		-- Check if levels is a whole number, 0 or more
		if levels < 0 or levels % 1 ~= 0 then
			return false, `Invalid Levels: $|cr$|{levels}#| must be a whole number, $|cr$|0#| or more`
		end

		--[[ Executing ]]

		local before = I.Progression.GetProgress(player) --- @type Progression_Progress
		local beforeXP: number = tonumber(I.Statistic.Get(player, "XP")) or 0
		if levels > 0 then
			I.Progression.AddLevels(player, levels)
		end

		-- Partway into the next level, so the bar ends between levels as after a real match
		local reached = I.Progression.GetProgress(player) --- @type Progression_Progress
		if reached.For > 0 then
			I.Progression.AddXP(player, math.floor(reached.For * 0.4))
		end
		local total: number = (tonumber(I.Statistic.Get(player, "XP")) or 0) - beforeXP

		-- Check if any XP was given
		if total <= 0 then
			return false, `$|cr$|{player.Name}#| is already at the highest level`
		end

		--[[ Replay ]]

		local win: number = math.floor(total * 0.3)
		local knockouts: number = math.floor(total * 0.2)
		I.Progression.SetReplay(player, {
			Lines = {
				{ Key = "Played", Label = "Match played", Count = 1, Amount = total - win - knockouts },
				{ Key = "Win", Label = "Victory", Count = 1, Amount = win },
				{ Key = "Knockouts", Label = "3 knockouts", Count = 3, Amount = knockouts },
			},
			Before = before,
			After = I.Progression.GetProgress(player),
			Costs = {},
		})

		--[[ Returning ]]

		return true, `$|cr$|{player.Name}#| gets $|cr$|{total}#| XP (level $|cr$|{I.Progression.GetLevel(player)}#|); the lobby plays it back`
	end

	--%%%%%%%%%%%%%%%%%%%% Weapon Look

	--[[
		Gives a player a weapon's or utility's look (Shiny or Golden), or takes the given one away (None), and tells them.
	]]
	local function weaponLook(player: Player, itemId: string, look: string)
		--[[ Checks ]]

		-- Check if the look is one of Shiny, Golden or None
		if look ~= "None" and not settings.UNLOCK_LOOKS[look] then
			return false, `Invalid Look: $|cr$|{look}#| must be $|cr$|Shiny#|, $|cr$|Golden#| or $|cr$|None#|`
		end

		--[[ Executing ]]

		if not I.Progression.SetWeaponVariant(player, itemId, if look == "None" then nil else look) then
			return false, `$|cr$|{itemId}#| isn't a weapon or a utility`
		end
		if look ~= "None" then
			I.Notify.ShowNotification(player, `You got the {look} {I.G_Arsenal.Get(itemId).Name}!`)
		end

		--[[ Returning ]]

		return true, `$|cr$|{player.Name}#|'s $|cr$|{itemId}#| look is now $|cr$|{look}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Golden Weapons

	--[[
		Gives a player every level reward's weapon in Golden (the Bazooka, the Grenade and the Shotgun) at once, and tells them.
	]]
	local function goldenWeapons(player: Player)
		--[[ Executing ]]

		local given = {} --- @type { string }
		--- @param reward Progression_WeaponReward
		for _level: number, reward in pairs(settings.WEAPON_REWARDS) do
			if not table.find(given, reward.Item) then
				I.Progression.SetWeaponVariant(player, reward.Item, "Golden")
				table.insert(given, reward.Item)
			end
		end
		table.sort(given)
		I.Notify.ShowNotification(player, "You got the Golden starter weapons!")

		--[[ Returning ]]

		return true, `$|cr$|{player.Name}#| has the Golden $|cr$|{table.concat(given, ", ")}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "add_level" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "levels", types = { "number" } },
			},
			Callback = addLevel,
		},
		{
			Aliases = { "match_xp" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "levels", types = { "number" } },
			},
			Callback = matchXp,
		},
		{
			Aliases = { "weapon_look" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "itemId", types = { "string" }, dict = "Progression_Items", requireDict = true },
				{ name = "look", types = { "string" }, dict = "Progression_Looks", requireDict = true },
			},
			Callback = weaponLook,
		},
		{
			Aliases = { "golden_weapons" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = goldenWeapons,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Progression_Server", {
		Aliases = { "progression" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%% Set Dictionaries

--[[
	Lists every weapon and utility, and the looks, for the weapon_look command's arguments (once Arsenal has its rows).
]]
function Module._setDictionaries()
	--[[ Local Variables ]]

	local weapons: { [string]: any }
	local utilities: { [string]: any }
	weapons, utilities = I.G_Arsenal.GetAll()
	local itemIds = {} --- @type { string }

	--[[ Collecting ]]

	--- @param rows { [string]: any }
	for _index: number, rows in ipairs({ weapons, utilities }) do
		for itemId: string in pairs(rows) do
			table.insert(itemIds, itemId)
		end
	end
	table.sort(itemIds)

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary("Progression_Items", itemIds, 255)
	I.AdminPanel_CommandBar.SetDictionary("Progression_Looks", { "Golden", "Shiny", "None" }, 255)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
