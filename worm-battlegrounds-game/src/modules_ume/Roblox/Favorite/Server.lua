--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Favorite"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Read Prompt Result

--[[
	Returns the client's answer to an invoked prompt when it is a known result, false otherwise.
]]
--- @return boolean | string
local function readPromptResult(result: any)
	--[[ Checks ]]

	-- Check if the answer is a known result
	if result ~= true and result ~= "AlreadyFavorited" then
		return false
	end

	--[[ Returning ]]

	return result
end

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
	--------- REGISTRY ---------
	----------------------------

	--- @Network

	--[[ Events ]]

	I.Network.GetEvent("Favorite_PromptSetFavorite")
	I.Network.GetEvent("Favorite_PromptGameSetFavorite")

	--[[ Functions ]]

	I.Network.GetFunction("Favorite_PromptSetFavorite-Return")
	I.Network.GetFunction("Favorite_PromptGameSetFavorite-Return")

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Favorite = {

		--[[ Control ]]

		PromptSetFavorite = Module.PromptSetFavorite,
		PromptGameSetFavorite = Module.PromptGameSetFavorite,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Prompt Set Favorite

--[[
	Prompts `SetFavorite` for the given `assetId`.
	With `invoke`, waits for the client's answer: true, false or "AlreadyFavorited", reported by the client and not trusted.
]]
--- @return boolean | string
function Module.PromptSetFavorite(player: Player, assetId: number, itemType: Enum.AvatarItemType?, invoke: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Prompting ]]

	-- Fire without waiting unless asked to invoke
	if not invoke then
		I.Network.Fire("Favorite_PromptSetFavorite", player, assetId, itemType)
		return true
	end

	--[[ Invoking ]]

	local result: any = I.Network.Invoke("Favorite_PromptSetFavorite-Return", player, assetId, itemType)

	--[[ Returning ]]

	return readPromptResult(result)
end

--%%%%%%%%%%%%%%%%%%%% Prompt Game Set Favorite

--[[
	Prompts `SetFavorite` for the current `PlaceId`.
	With `invoke`, waits for the client's answer: true, false or "AlreadyFavorited", reported by the client and not trusted.
]]
--- @return boolean | string
function Module.PromptGameSetFavorite(player: Player, invoke: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Prompting ]]

	-- Fire without waiting unless asked to invoke
	if not invoke then
		I.Network.Fire("Favorite_PromptGameSetFavorite", player)
		return true
	end

	--[[ Invoking ]]

	local result: any = I.Network.Invoke("Favorite_PromptGameSetFavorite-Return", player)

	--[[ Returning ]]

	return readPromptResult(result)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
