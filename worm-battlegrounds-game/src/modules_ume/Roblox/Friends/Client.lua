--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Friends"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local SocialService = I.S.SocialService
local HttpService = I.S.HttpService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local friendsRep: Folder

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Can Send Game Invite

--[[
	Checks if player can send a game invite to other players.
]]
--- @return boolean
local function canSendGameInvite(sendingPlayer: Player)
	local success: boolean, canSend: boolean = pcall(SocialService.CanSendGameInviteAsync, SocialService, sendingPlayer)
	return success and canSend
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
	------ INITIALIZATION ------
	----------------------------

	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("Friends_PromptGameInvite", { { Type = "table", Optional = true } })
	I.Network.Fired("Friends_PromptGameInvite", Module.PromptGameInvite)

	I.Network.GetFunction("Friends_PromptGameInvite-Return", { { Type = "table", Optional = true } })
	I.Network.OnInvoke("Friends_PromptGameInvite-Return", Module.PromptGameInvite)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Friends = {

		--[[ Control ]]

		PromptGameInvite = Module.PromptGameInvite,

		--[[ Methods ]]

		IsFriendsWith = Module.IsFriendsWith,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Looks up the Friends replicator folder and saves it.
]]
function Module._connectReplicator()
	friendsRep = I.Replicator.GetFolder(_localName)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Prompt Game Invite

--[[
	Opens the Roblox game invite prompt.
	Takes an `ExperienceInviteOptions` made on the client or the options table the server sends.
]]
--- @param inviteOptions Friends_InviteOptions | ExperienceInviteOptions | nil
--- @return boolean
function Module.PromptGameInvite(inviteOptions)
	--[[ Checks ]]

	-- Check if the local player can send invites
	if not canSendGameInvite(I.Env.LocalPlayer) then
		return false
	end

	--[[ Building Options ]]

	-- Build the options instance from a table sent by the server
	if type(inviteOptions) == "table" then
		inviteOptions = Module._buildInviteOptions(inviteOptions)
	end

	--[[ Prompting ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(SocialService.PromptGameInvite, SocialService, I.Env.LocalPlayer, inviteOptions)
	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to prompt Friends Invite! - {result}`)
	end

	--[[ Returning ]]

	return success
end

--%%%%%%%%%%%%%%%%%%%% Build Invite Options

--[[
	Creates an `ExperienceInviteOptions` from an options table, copying each field that has the right type.
]]
--- @param options Friends_InviteOptions
--- @return ExperienceInviteOptions
function Module._buildInviteOptions(options)
	--[[ Creating ]]

	local experienceInviteOptions: ExperienceInviteOptions = Instance.new("ExperienceInviteOptions")

	--[[ Applying ]]

	-- Copy the prompt message when it is a string
	if type(options.PromptMessage) == "string" then
		experienceInviteOptions.PromptMessage = options.PromptMessage
	end

	-- Copy the invited user when it is a positive whole user id
	if type(options.InviteUser) == "number" and options.InviteUser > 0 and options.InviteUser % 1 == 0 then
		experienceInviteOptions.InviteUser = options.InviteUser
	end

	-- Copy the invite message id when it is a string
	if type(options.InviteMessageId) == "string" then
		experienceInviteOptions.InviteMessageId = options.InviteMessageId
	end

	-- Copy the launch data when it is a string
	if type(options.LaunchData) == "string" then
		experienceInviteOptions.LaunchData = options.LaunchData
	end

	--[[ Returning ]]

	return experienceInviteOptions
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Friends With

--[[
	Returns whether the local player is friends with `player` based on the replicated in-server friends list.
]]
--- @return boolean
function Module.IsFriendsWith(player: Player)
	--[[ Checks ]]

	-- Check if a player other than the local player was passed and the list is connected
	if not player or player == I.Env.LocalPlayer or not friendsRep then
		return false
	end

	--[[ Data ]]

	local rawList: string? = friendsRep:GetAttribute("ActiveList")
	if not rawList then
		return false
	end

	--[[ Decoding List ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(HttpService.JSONDecode, HttpService, rawList)

	-- Check if the list decoded into a table
	if not success or type(result) ~= "table" then
		return false
	end

	--[[ Returning ]]

	return table.find(result, tostring(player.UserId)) ~= nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
