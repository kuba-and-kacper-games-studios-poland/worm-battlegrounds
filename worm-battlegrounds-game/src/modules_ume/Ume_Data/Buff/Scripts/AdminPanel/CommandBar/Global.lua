--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Buff"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type Buff_Buffs
local buffsData = require(I.Dirs.GlobalData.Buff.Buff)

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

--- @class Buff_CommandBar_Global
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
	Module._registerCommandDictionaries()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers commands used for controlling module.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Client Functions

	--[[ Set ]]

	local function c_set(buffName: string, valueName: string, amount: number | string)
		--[[ Checks ]]

		if not buffsData["Client"][buffName] then
			return false, `Invalid Buff name: $|cr$|{buffName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Buff.Set(buffName, valueName, amount)

		-- Formatting value
		local formattedAmount: string = I.Format.Text(amount)

		-- Returning
		if value then
			-- Formatting value
			local formattedValue: string | number = I.Format.Text(I.Buff.GetSum(buffName))

			return true, `Set Buff $|cr$|{buffName}#| Value $|cr$|{valueName}#| value to: $|cr$|{formattedAmount}#|. New sum: $|cr$|{formattedValue}#|`
		else
			return false, `Failed to set Buff $|cr$|{buffName}#| Value $|cr$|{valueName}#| value to: $|cr$|{formattedAmount}#|`
		end
	end

	--[[ Get ]]

	local function c_get_sum(buffName: string, formatting: string?)
		--[[ Checks ]]

		if not buffsData["Client"][buffName] then
			return false, `Invalid Buff name: $|cr$|{buffName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: number | string | nil = I.Buff.GetSum(buffName)

		-- Returning
		if value then
			-- Formatting value
			value = I.Format.Text(value, formatting)

			return true, `Buff $|cr$|{buffName}#| sum is: $|cr$|{value}#|`
		else
			return false, `Failed to get Buff $|cr$|{buffName}#| sum`
		end
	end

	local function c_get_value(buffName: string, valueName: string, formatting: string?)
		--[[ Checks ]]

		if not buffsData["Client"][buffName] then
			return false, `Invalid Buff name: $|cr$|{buffName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: number | string | nil = I.Buff.GetValue(buffName, valueName)

		-- Returning
		if value then
			-- Formatting value
			value = I.Format.Text(value, formatting)

			return true, `Buff $|cr$|{buffName}#| Value $|cr$|{valueName}#| value is: $|cr$|{value}#|`
		else
			return false, `Failed to get Buff $|cr$|{buffName}#| Value $|cr$|{valueName}#| value`
		end
	end

	local function c_get_values(buffName: string, formatting: string?)
		--[[ Checks ]]

		if not buffsData["Client"][buffName] then
			return false, `Invalid Buff name: $|cr$|{buffName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: table | nil = I.Buff.GetValues(buffName)

		-- Returning
		if value then
			-- Formatting value
			I.Format.Table(value, formatting)

			return true, { `Getting Buff $|cr$|{buffName}#| values...`, value, "_multilineOutput" }
		else
			return false, `Failed to get Buff $|cr$|{buffName}#| values`
		end
	end

	--[[ Get All ]]

	local function c_get_all(formatting: string?)
		-- Getting value
		local value: table | nil = I.Buff.GetAll()

		-- Returning
		if value then
			-- Formatting value
			I.Format.Table(value, formatting)

			return true, { `Getting local Buff data...`, value, "_multilineOutput" }
		else
			return false, `Failed to get local Buff data`
		end
	end

	local function c_get_all_sums(formatting: string?)
		-- Getting value
		local value: table | nil = I.Buff.GetAllSums()

		-- Returning
		if value then
			-- Formatting value
			I.Format.Table(value, formatting)

			return true, { `Getting local Buff sums...`, value, "_multilineOutput" }
		else
			return false, `Failed to get local Buff sums`
		end
	end

	local function c_get_all_values(formatting: string?)
		-- Getting value
		local value: table | nil = I.Buff.GetAllValues()

		-- Returning
		if value then
			-- Formatting value
			I.Format.Table(value, formatting)

			return true, { `Getting Buff values...`, value, "_multilineOutput" }
		else
			return false, `Failed to get Buff values`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Server Functions

	--[[ Set ]]

	local function s_set(player: Player, buffName: string, valueName: string, amount: number | string)
		--[[ Checks ]]

		if not buffsData["Server"][buffName] then
			return false, `Invalid Buff name: $|cr$|{buffName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Buff.Set(buffName, valueName, amount, player)

		-- Formatting value
		local formattedAmount: string = I.Format.Text(amount)

		-- Returning
		if value then
			-- Formatting value
			local formattedValue: string | number = I.Format.Text(I.Buff.GetSum(buffName, player))

			return true, `Set $|cr$|{player.Name}#|'s Buff $|cr$|{buffName}#| Value $|cr$|{valueName}#| value to: $|cr$|{formattedAmount}#|. New sum: $|cr$|{formattedValue}#|`
		else
			return false, `Failed to set $|cr$|{player.Name}#|'s Buff $|cr$|{buffName}#| Value $|cr$|{valueName}#| value to: $|cr$|{formattedAmount}#|`
		end
	end

	--[[ Get ]]

	local function s_get_sum(player: Player, buffName: string, formatting: string?)
		--[[ Checks ]]

		if not buffsData["Server"][buffName] then
			return false, `Invalid Buff name: $|cr$|{buffName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: number | string | nil = I.Buff.GetSum(buffName, player)

		-- Returning
		if value then
			-- Formatting value
			value = I.Format.Text(value, formatting)

			return true, `$|cr$|{player.Name}#|'s Buff $|cr$|{buffName}#| sum is: $|cr$|{value}#|`
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s Buff $|cr$|{buffName}#| sum`
		end
	end

	local function s_get_value(player: Player, buffName: string, valueName: string, formatting: string?)
		--[[ Checks ]]

		if not buffsData["Server"][buffName] then
			return false, `Invalid Buff name: $|cr$|{buffName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: number | string | nil = I.Buff.GetValue(buffName, valueName, player)

		-- Returning
		if value then
			-- Formatting value
			value = I.Format.Text(value, formatting)

			return true, `$|cr$|{player.Name}#|'s Buff $|cr$|{buffName}#| Value $|cr$|{valueName}#| value is: $|cr$|{value}#|`
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s Buff $|cr$|{buffName}#| Value $|cr$|{valueName}#| value`
		end
	end

	local function s_get_values(player: Player, buffName: string, formatting: string?)
		--[[ Checks ]]

		if not buffsData["Server"][buffName] then
			return false, `Invalid Buff name: $|cr$|{buffName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: table | nil = I.Buff.GetValues(buffName, player)

		-- Returning
		if value then
			-- Formatting value
			I.Format.Table(value, formatting)

			return true, { `Getting $|cr$|{player.Name}#|'s Buff $|cr$|{buffName}#| values...`, value, "_multilineOutput" }
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s Buff $|cr$|{buffName}#| values`
		end
	end

	--[[ Get All ]]

	local function s_get_all(player: Player, formatting: string?)
		-- Getting value
		local value: table | nil = I.Buff.GetAll(player)

		-- Returning
		if value then
			-- Formatting value
			I.Format.Table(value, formatting)

			return true, { `Getting $|cr$|{player.Name}#|'s Buff data...`, value, "_multilineOutput" }
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s Buff data`
		end
	end

	local function s_get_all_sums(player: Player, formatting: string?)
		-- Getting value
		local value: table | nil = I.Buff.GetAllSums(player)

		-- Returning
		if value then
			-- Formatting value
			I.Format.Table(value, formatting)

			return true, { `Getting $|cr$|{player.Name}#|'s Buff sums...`, value, "_multilineOutput" }
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s Buff sums`
		end
	end

	local function s_get_all_values(player: Player, formatting: string?)
		-- Getting value
		local value: table | nil = I.Buff.GetAllValues(player)

		-- Returning
		if value then
			-- Formatting value
			I.Format.Table(value, formatting)

			return true, { `Getting $|cr$|{player.Name}#|'s Buff values...`, value, "_multilineOutput" }
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s Buff values`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Server-Client Functions

	--[[ Set ]]

	local function sc_set(player: Player, buffName: string, valueName: string, amount: number | string)
		--[[ Checks ]]

		if not buffsData["Client"][buffName] then
			return false, `Invalid Buff name: $|cr$|{buffName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Network.Invoke("Buff_Set", player, buffName, valueName, amount)

		-- Formatting value
		local formattedAmount: string = I.Format.Text(amount)

		-- Returning
		if value then
			-- Formatting value
			local formattedValue: string | number = I.Format.Text(I.Network.Invoke("Buff_GetSum", player, buffName))

			return true, `Set $|cr$|{player.Name}#|'s local Buff $|cr$|{buffName}#| Value $|cr$|{valueName}#| value to: $|cr$|{formattedAmount}#|. New sum: $|cr$|{formattedValue}#|`
		else
			return false, `Failed to set $|cr$|{player.Name}#|'s local Buff $|cr$|{buffName}#| Value $|cr$|{valueName}#| value to: $|cr$|{formattedAmount}#|`
		end
	end

	--[[ Get ]]

	local function sc_get_sum(player: Player, buffName: string, formatting: string?)
		--[[ Checks ]]

		if not buffsData["Client"][buffName] then
			return false, `Invalid Buff name: $|cr$|{buffName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: string | number | nil = I.Network.Invoke("Buff_GetSum", player, buffName)

		-- Returning
		if value then
			-- Formatting value
			value = I.Format.Text(value, formatting)

			return true, `$|cr$|{player.Name}#|'s local Buff $|cr$|{buffName}#| sum is: $|cr$|{value}#|`
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s local Buff $|cr$|{buffName}#| sum`
		end
	end

	local function sc_get_value(player: Player, buffName: string, valueName: string, formatting: string?)
		--[[ Checks ]]

		if not buffsData["Client"][buffName] then
			return false, `Invalid Buff name: $|cr$|{buffName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: string | number | nil = I.Network.Invoke("Buff_GetValue", player, buffName, valueName)

		-- Returning
		if value then
			-- Formatting value
			value = I.Format.Text(value, formatting)

			return true, `$|cr$|{player.Name}#|'s local Buff $|cr$|{buffName}#| Value $|cr$|{valueName}#| value is: $|cr$|{value}#|`
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s local Buff $|cr$|{buffName}#| Value $|cr$|{valueName}#| value`
		end
	end

	local function sc_get_values(player: Player, buffName: string, formatting: string?)
		--[[ Checks ]]

		if not buffsData["Client"][buffName] then
			return false, `Invalid Buff name: $|cr$|{buffName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: table | nil = I.Network.Invoke("Buff_GetValues", player, buffName)

		-- Returning
		if value then
			-- Formatting value
			I.Format.Table(value, formatting)

			return true, { `Getting $|cr$|{player.Name}#|'s local Buff $|cr$|{buffName}#| values...`, value, "_multilineOutput" }
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s local Buff $|cr$|{buffName}#| values`
		end
	end

	--[[ Get All ]]

	local function sc_get_all(player: Player, formatting: string?)
		-- Getting value
		local value: table | nil = I.Network.Invoke("Buff_GetAll", player)

		-- Returning
		if value then
			-- Formatting value
			I.Format.Table(value, formatting)

			return true, { `Getting $|cr$|{player.Name}#|'s local Buff data...`, value, "_multilineOutput" }
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s local Buff data`
		end
	end

	local function sc_get_all_sums(player: Player, formatting: string?)
		-- Getting value
		local value: table | nil = I.Network.Invoke("Buff_GetAllSums", player)

		-- Returning
		if value then
			-- Formatting value
			I.Format.Table(value, formatting)

			return true, { `Getting $|cr$|{player.Name}#|'s local Buff sums...`, value, "_multilineOutput" }
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s local Buff sums`
		end
	end

	local function sc_get_all_values(player: Player, formatting: string?)
		-- Getting value
		local value: table | nil = I.Network.Invoke("Buff_GetAllValues", player)

		-- Returning
		if value then
			-- Formatting value
			I.Format.Table(value, formatting)

			return true, { `Getting $|cr$|{player.Name}#|'s local Buff values...`, value, "_multilineOutput" }
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s local Buff values`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Client ]]

	if I.Env.IsClient then
		I.AdminPanel_CommandBar.Register("Buff_Client", {
			Aliases = { "buff" },
			PermissionLevel = 255,

			Variants = {
				--[[ Set ]]

				{
					Aliases = { "set" },
					Args = {
						{ name = "buffName", types = { "string" }, dict = "Buff_BuffNames_Client", requireDict = true },
						{ name = "valueName", types = { "string" }, dict = "Buff_BuffValues-$|arg:-1#|", requireDict = false },
						{ name = "value", types = { "number", "BigNum" }, optional = true },
					},
					Callback = c_set,
				},

				--[[ Get ]]

				{
					Aliases = { "get_sum" },
					Args = {
						{ name = "buffName", types = { "string" }, dict = "Buff_BuffNames_Client", requireDict = true },
						{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
					},
					Callback = c_get_sum,
				},
				{
					Aliases = { "get_value" },
					Args = {
						{ name = "buffName", types = { "string" }, dict = "Buff_BuffNames_Client", requireDict = true },
						{ name = "valueName", types = { "string" }, dict = "Buff_BuffValues-$|arg:-1#|", requireDict = true },
						{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
					},
					Callback = c_get_value,
				},
				{
					Aliases = { "get_values" },
					Args = {
						{ name = "buffName", types = { "string" }, dict = "Buff_BuffNames_Client", requireDict = true },
						{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
					},
					Callback = c_get_values,
				},

				--[[ Get All ]]

				{
					Aliases = { "get_all" },
					Args = {
						{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
					},
					Callback = c_get_all,
				},
				{
					Aliases = { "get_all_sums" },
					Args = {
						{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
					},
					Callback = c_get_all_sums,
				},
				{
					Aliases = { "get_all_values" },
					Args = {
						{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
					},
					Callback = c_get_all_values,
				},
			},
		})
	end

	--[[ Server ]]

	if I.Env.IsServer then
		I.AdminPanel_CommandBar.Register("Buff_Server", {
			Aliases = { "s_buff" },
			PermissionLevel = 255,

			Variants = {
				--[[ Set ]]

				{
					Aliases = { "set" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "buffName", types = { "string" }, dict = "Buff_BuffNames_Server", requireDict = true },
						{ name = "valueName", types = { "string" }, dict = "Buff_BuffValues-$|arg:-2#|-$|arg:-1#|", requireDict = false },
						{ name = "value", types = { "number", "BigNum" }, optional = true },
					},
					Callback = s_set,
				},

				--[[ Get ]]

				{
					Aliases = { "get_sum" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "buffName", types = { "string" }, dict = "Buff_BuffNames_Server", requireDict = true },
						{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
					},
					Callback = s_get_sum,
				},
				{
					Aliases = { "get_value" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "buffName", types = { "string" }, dict = "Buff_BuffNames_Server", requireDict = true },
						{ name = "valueName", types = { "string" }, dict = "Buff_BuffValues-$|arg:-2#|-$|arg:-1#|", requireDict = false },
						{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
					},
					Callback = s_get_value,
				},
				{
					Aliases = { "get_values" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "buffName", types = { "string" }, dict = "Buff_BuffNames_Server", requireDict = true },
						{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
					},
					Callback = s_get_values,
				},

				--[[ Get All ]]

				{
					Aliases = { "get_all" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
					},
					Callback = s_get_all,
				},
				{
					Aliases = { "get_all_sums" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
					},
					Callback = s_get_all_sums,
				},
				{
					Aliases = { "get_all_values" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
					},
					Callback = s_get_all_values,
				},

				--[[ Client ]]

				{
					Aliases = { "from_client" },
					Variants = {
						--[[ Set ]]

						{
							Aliases = { "set" },
							Args = {
								{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
								{ name = "buffName", types = { "string" }, dict = "Buff_BuffNames_Client", requireDict = true },
								{ name = "valueName", types = { "string" } },
								{ name = "value", types = { "number", "BigNum" }, optional = true },
							},
							Callback = sc_set,
						},

						--[[ Get ]]

						{
							Aliases = { "get_sum" },
							Args = {
								{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
								{ name = "buffName", types = { "string" }, dict = "Buff_BuffNames_Client", requireDict = true },
								{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
							},
							Callback = sc_get_sum,
						},
						{
							Aliases = { "get_value" },
							Args = {
								{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
								{ name = "buffName", types = { "string" }, dict = "Buff_BuffNames_Client", requireDict = true },
								{ name = "valueName", types = { "string" } },
								{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
							},
							Callback = sc_get_value,
						},
						{
							Aliases = { "get_values" },
							Args = {
								{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
								{ name = "buffName", types = { "string" }, dict = "Buff_BuffNames_Client", requireDict = true },
								{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
							},
							Callback = sc_get_values,
						},

						--[[ Get All ]]

						{
							Aliases = { "get_all" },
							Args = {
								{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
								{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
							},
							Callback = sc_get_all,
						},
						{
							Aliases = { "get_all_sums" },
							Args = {
								{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
								{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
							},
							Callback = sc_get_all_sums,
						},
						{
							Aliases = { "get_all_values" },
							Args = {
								{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
								{ name = "formatting", types = { "string" }, dict = "Ume_FormatTypes", requireDict = true, optional = true },
							},
							Callback = sc_get_all_values,
						},
					},
				},
			},
		})
	end
end

--%%%%%%%%%%%%%%%%%%%% Register Command Dictionaries

--[[
	Registers dictionaries used by module commands.
]]
function Module._registerCommandDictionaries()
	if not I.Env.IsClient then
		return
	end

	--[[ Getting Values ]]

	local allClientBuffNames = {} --- @type { string }
	local allServerBuffNames = {} --- @type { string }

	--- @param buffData Buff_BuffData
	for name: string, _buffData in pairs(buffsData.Client) do
		table.insert(allClientBuffNames, name)

		-- Buff values for client only
		I.AdminPanel_CommandBar.SetDictionary(`Buff_BuffValues-{name}`, { "Standard" }, 255)
	end

	--- @param buffData Buff_BuffData
	for name: string, _buffData in pairs(buffsData.Server) do
		table.insert(allServerBuffNames, name)
	end

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary(`Buff_BuffNames_Client`, allClientBuffNames, 255)
	I.AdminPanel_CommandBar.SetDictionary(`Buff_BuffNames_Server`, allServerBuffNames, 255)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
