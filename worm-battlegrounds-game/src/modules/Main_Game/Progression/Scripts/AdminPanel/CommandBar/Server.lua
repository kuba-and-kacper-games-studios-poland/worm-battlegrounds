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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers the command that adds levels to a player by hand, for testing: it gives the XP those levels take, so
	each level's rewards and toast come as they do after a match.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Add Level

	--[[
		Takes a player up a number of levels (the highest level at most), and says the level they're at now.
	]]
	local function addLevel(player: Player, levels: number)
		--[[ Checks ]]

		-- Check if levels is a whole number above 0
		if levels < 1 or levels % 1 ~= 0 then
			return false, `Invalid Levels: $|cr$|{levels}#| must be a whole number above $|cr$|0#|`
		end

		--[[ Executing ]]

		local level: number
		local leveledUp: boolean
		level, leveledUp = I.Progression.AddLevels(player, levels)

		--[[ Returning ]]

		if not leveledUp then
			return false, `$|cr$|{player.Name}#| is already at the highest level ($|cr$|{level}#|)`
		end
		return true, `$|cr$|{player.Name}#| is now level $|cr$|{level}#|`
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
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Progression_Server", {
		Aliases = { "progression" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
