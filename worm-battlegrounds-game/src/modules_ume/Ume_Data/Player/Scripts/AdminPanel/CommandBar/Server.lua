--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Player"

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

--- @class Player_CommandBar_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers commands used for controlling module.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Reset Data

	local function resetData(player: Player, key: string?)
		--[[ Generating Reset Key ]]

		if not key then
			-- Generating Key
			local newKey: string = `{I.Obfuscate.GetRandomString(4, "Numbers")}-{I.Obfuscate.GetRandomString(4, "Numbers")}`
			I.Player._dataResetKeys[player] = newKey
			I.AdminPanel_CommandBar.UpdateDictionary(`Player_DataResetKeys-{player.Name}`, { newKey }, nil, 255, { BoundTo = player.UserId })

			-- Returning
			return true, {
				`Generating new data reset key for $|cr$|{player.Name}#|...`,
				`Generated data reset key: $|cr$|{newKey}#|`,
				"_multilineOutput",
			}
		end

		--[[ Resetting ]]

		-- Key was provided but player has no keys created for them
		if not I.Player._dataResetKeys[player] then
			return false, `No data reset keys assigned for $|cr$|{player.Name}#|`
		end

		-- Valid key -> Resetting data
		if I.Player._dataResetKeys[player] == key then
			I.AdminPanel_CommandBar.SetDictionary(`Player_DataResetKeys-{player.Name}`, nil)
			I.Player.ResetData(player, true)
			return true, `Resetting data for $|cr$|{player.Name}#|`
		end

		--[[ Failed ]]

		return false, `Data reset key $|cr$|{key}#| is not valid for $|cr$|{player.Name}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {
		{
			Aliases = { "reset_data" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "key", types = { "string" }, dict = "Player_DataResetKeys-$|arg:-1#|", optional = true },
			},
			Callback = resetData,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Player_Server", {
		Aliases = { "player" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
