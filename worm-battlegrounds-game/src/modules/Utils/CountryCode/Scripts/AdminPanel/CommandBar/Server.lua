--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "CountryCode"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Players = I.S.Players

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

--- @class CountryCode_CommandBar_Server
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
	--%%%%%%%%%%%%%%%%%%%% Control Functions

	local function update(player: Player, force: boolean?)
		-- Getting value
		local value: boolean = I.CountryCode.SavePlayerCountry(player, force)

		-- Returning
		if value then
			return true, `Updated $|cr$|{player.Name}#|'s CountryData`
		else
			return false, `Failed to update $|cr$|{player.Name}#|'s CountryData`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Get Functions

	local function getByPlayer(player: Player)
		-- Getting value
		local value = I.CountryCode.GetPlayerCountryData(player)

		-- Returning
		if value then
			return true, { `Retrieving $|cr$|{player.Name}#|'s CountryData`, `$|cr$|{player.Name}#| - {value.Emoji} $|cr$|{value.Name}#| ($|cr$|{value.Code}#|)`, "_multilineOutput" }
		else
			return false, `Failed to retrieve $|cr$|{player.Name}#|'s CountryData`
		end
	end

	local function getByName(playerName: string)
		--[[ Getting Data ]]

		-- Getting name
		local success: boolean, playerId: number = pcall(function()
			return Players:GetUserIdFromNameAsync(playerName)
		end)
		if not success or not playerId then
			return false, `Failed to retrieve $|cr$|{playerName}#|'s userId`
		end

		--[[ Executing ]]

		-- Getting value
		local value = I.CountryCode.GetPlayerCountryDataById(playerId)

		-- Returning
		if value then
			return true, { `Retrieving $|cr$|{playerName}#|'s CountryData`, `$|cr$|{playerName}#| - {value.Emoji} $|cr$|{value.Name}#| ($|cr$|{value.Code}#|)`, "_multilineOutput" }
		else
			return false, `Failed to retrieve $|cr$|{playerName}#|'s CountryData`
		end
	end

	local function getById(playerId: number)
		--[[ Getting Data ]]

		-- Getting name
		local success: boolean, playerName: string = pcall(function()
			return Players:GetNameFromUserIdAsync(playerId)
		end)
		if not success or not playerName then
			playerName = playerId
		end

		--[[ Executing ]]

		-- Getting value
		local value = I.CountryCode.GetPlayerCountryDataById(playerId)

		-- Returning
		if value then
			return true, { `Retrieving $|cr$|{playerName}#|'s CountryData`, `$|cr$|{playerName}#| - {value.Emoji} $|cr$|{value.Name}#| ($|cr$|{value.Code}#|)`, "_multilineOutput" }
		else
			return false, `Failed to retrieve $|cr$|{playerName}#|'s CountryData`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "update" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "force", types = { "boolean" }, optional = true },
			},
			Callback = update,
		},

		--[[ Get ]]

		{
			Aliases = { "get" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = getByPlayer,
		},
		{
			Aliases = { "get_by_name" },
			Args = {
				{ name = "playerName", types = { "string" } },
			},
			Callback = getByName,
		},
		{
			Aliases = { "get_by_id" },
			Args = {
				{ name = "playerId", types = { "number" } },
			},
			Callback = getById,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("CountryCode_Server", {
		Aliases = { "country_code" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
