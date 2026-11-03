--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Favorite"

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

--- @class Favorite_CommandBar_Server
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
	--%%%%%%%%%%%%%%%%%%%% Prompt Id

	--[[
		Prompts SetFavorite for an asset on the player's client and reports the client's answer.
	]]
	--- @return boolean
	--- @return string
	local function promptId(player: Player, assetId: number)
		--[[ Prompting ]]

		local result: boolean | string = I.Favorite.PromptSetFavorite(player, assetId, Enum.AvatarItemType.Asset, true)

		--[[ Checks ]]

		-- Report an asset the player already favorited
		if result == "AlreadyFavorited" then
			return true, `$|cr$|{player.Name}#| already favorited Asset $|cr$|{assetId}#|`
		end

		-- Report a prompt that didn't open
		if not result then
			return false, `Failed to prompt $|cr$|SetFavorite#| for Asset $|cr$|{assetId}#| for $|cr$|{player.Name}#|`
		end

		--[[ Returning ]]

		return true, `Prompted $|cr$|SetFavorite#| for Asset $|cr$|{assetId}#| for $|cr$|{player.Name}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Prompt Game

	--[[
		Prompts SetFavorite for this place on the player's client and reports the client's answer.
	]]
	--- @return boolean
	--- @return string
	local function promptGame(player: Player)
		--[[ Prompting ]]

		local result: boolean | string = I.Favorite.PromptGameSetFavorite(player, true)

		--[[ Checks ]]

		-- Report a place the player already favorited
		if result == "AlreadyFavorited" then
			return true, `$|cr$|{player.Name}#| already favorited the $|cr$|Current Place#|`
		end

		-- Report a prompt that didn't open
		if not result then
			return false, `Failed to prompt $|cr$|SetFavorite#| for $|cr$|Current Place#| for $|cr$|{player.Name}#|`
		end

		--[[ Returning ]]

		return true, `Prompted $|cr$|SetFavorite#| for $|cr$|Current Place#| for $|cr$|{player.Name}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "prompt_id" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "assetId", types = { "number" } },
			},
			Callback = promptId,
		},
		{
			Aliases = { "prompt_game" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = promptGame,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Favorite_Server", {
		Aliases = { "favorite" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
