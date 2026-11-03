--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Favorite"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local AvatarEditorService = I.S.AvatarEditorService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local isPromptActive: boolean = false

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
	------ INITIALIZATION ------
	----------------------------

	Module._createConnections()

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network

	--[[ Events ]]

	I.Network.GetEvent("Favorite_PromptSetFavorite", { "number", { Type = "EnumItem", Optional = true } })
	I.Network.Fired("Favorite_PromptSetFavorite", Module.PromptSetFavorite)

	I.Network.GetEvent("Favorite_PromptGameSetFavorite", {})
	I.Network.Fired("Favorite_PromptGameSetFavorite", Module.PromptGameSetFavorite)

	--[[ Functions ]]

	I.Network.GetFunction("Favorite_PromptSetFavorite-Return", { "number", { Type = "EnumItem", Optional = true } })
	I.Network.OnInvoke("Favorite_PromptSetFavorite-Return", Module.PromptSetFavorite)

	I.Network.GetFunction("Favorite_PromptGameSetFavorite-Return", {})
	I.Network.OnInvoke("Favorite_PromptGameSetFavorite-Return", Module.PromptGameSetFavorite)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Favorite = {

		--[[ Control ]]

		PromptSetFavorite = Module.PromptSetFavorite,
		PromptGameSetFavorite = Module.PromptGameSetFavorite,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Connects service signals for favorite prompt lifecycle.
]]
function Module._createConnections()
	AvatarEditorService.PromptSetFavoriteCompleted:Connect(function(_result: Enum.AvatarPromptResult)
		isPromptActive = false
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Prompt Set Favorite

--[[
	Prompts `SetFavorite` for the given `itemId`.
	Returns "AlreadyFavorited" without prompting when the player already favorited it.
]]
--- @return boolean | string
function Module.PromptSetFavorite(itemId: number, itemType: Enum.AvatarItemType?)
	--[[ Checks ]]

	-- Check if another prompt is open
	if isPromptActive then
		return false
	end

	--[[ Local Variables ]]

	local avatarItemType: Enum.AvatarItemType = itemType or Enum.AvatarItemType.Asset

	--[[ Locking ]]

	-- Block other prompts while this one checks and opens
	isPromptActive = true

	--[[ Favorite Check ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(AvatarEditorService.GetFavoriteAsync, AvatarEditorService, itemId, avatarItemType)

	-- Skip the prompt when the item is already favorited
	if success and result == true then
		isPromptActive = false
		return "AlreadyFavorited"
	end

	--[[ Prompting ]]

	success, result = pcall(AvatarEditorService.PromptSetFavorite, AvatarEditorService, itemId, avatarItemType, true)

	-- Check if the prompt opened
	if not success then
		isPromptActive = false
		warn(`[{_localName}::{script.Name}]: Failed to prompt SetFavorite for Asset ({itemId}) - {result}`)
		return false
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Prompt Game Set Favorite

--[[
	Prompts `SetFavorite` for the current `PlaceId`.
]]
--- @return boolean | string
function Module.PromptGameSetFavorite()
	return Module.PromptSetFavorite(I.Config.PlaceLoader.PlaceId, Enum.AvatarItemType.Asset)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
