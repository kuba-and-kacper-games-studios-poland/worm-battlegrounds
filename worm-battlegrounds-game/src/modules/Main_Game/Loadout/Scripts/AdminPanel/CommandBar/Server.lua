--[[
	Created By: 	Nari
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

--- @class Loadout_CommandBar_Server
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
	Registers the commands that give a player every weapon and utility they don't own yet, and open every loadout slot.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Unlock Weapons

	--[[
		Gives a player one copy of every weapon and utility a slot takes that they don't own yet.
	]]
	local function unlockWeapons(player: Player)
		--[[ Local Variables ]]

		local categories = I.Settings["Loadout"].SLOT_CATEGORIES --- @type { string }
		local added: number = 0

		--[[ Adding ]]

		--- @param item Inventory_ItemData
		for itemId: string, item in pairs(I.G_Inventory.Items) do
			if table.find(categories, item.Category) and not I.Inventory.HasItem(player, itemId) and I.Inventory.AddItem(player, itemId, "1", true) then
				added += 1
			end
		end

		--[[ Returning ]]

		return true, `Gave $|cr$|{player.Name}#| $|cr$|{added}#| weapons and utilities they didn't own`
	end

	--%%%%%%%%%%%%%%%%%%%% Unlock Slots

	--[[
		Opens every loadout slot for a player, for good, whatever passes they own.
	]]
	local function unlockSlots(player: Player)
		--[[ Checks ]]

		-- Check if the slots opened
		if not I.Loadout.OpenAllSlots(player) then
			return false, `Failed to open $|cr$|{player.Name}#|'s loadout slots`
		end

		--[[ Returning ]]

		return true, `Opened all $|cr$|{I.Loadout.GetUnlocked(player)}#| loadout slots for $|cr$|{player.Name}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "unlock_weapons" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = unlockWeapons,
		},
		{
			Aliases = { "unlock_slots" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = unlockSlots,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Loadout_Server", {
		Aliases = { "loadout" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
