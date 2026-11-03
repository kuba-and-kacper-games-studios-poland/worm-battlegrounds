--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Notify"

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
	I.Network.GetEvent("Notify_ShowNotification")
	I.Network.GetEvent("Notify_ShowMessage")

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Notify = {

		--[[ Control ]]

		ShowNotification = Module.ShowNotification,
		ShowMessage = Module.ShowMessage,
		ShowUserMessage = Module.ShowUserMessage,

		--[[ Methods ]]

		FilterText = Module.FilterText,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show Notification

--[[
	Shows notification for player, or all players when player is nil.
]]
function Module.ShowNotification(player: Player?, message: string, gradientId: string?, duration: number?, soundId: string?)
	--[[ Showing ]]

	if player then
		-- Check if player is valid | SERVER
		if not I.Player.Valid(player) then
			return
		end

		I.Network.Fire("Notify_ShowNotification", player, message, gradientId, duration, soundId)
	else
		I.Network.FireAll("Notify_ShowNotification", message, gradientId, duration, soundId)
	end
end

--%%%%%%%%%%%%%%%%%%%% Show Message

--[[
	Shows a user message toast for player, or all players when player is nil.
]]
function Module.ShowMessage(player: Player?, userId: number, username: string, message: string, duration: number?, soundId: string?)
	--[[ Showing ]]

	if player then
		-- Check if player is valid | SERVER
		if not I.Player.Valid(player) then
			return
		end

		I.Network.Fire("Notify_ShowMessage", player, userId, username, message, duration, soundId)
	else
		I.Network.FireAll("Notify_ShowMessage", userId, username, message, duration, soundId)
	end
end

--%%%%%%%%%%%%%%%%%%%% Show User Message

--[[
	**SERVER** |
	Filters text a player wrote, then shows it as their user message toast to target, or all players when target is nil.
	Returns false and shows nothing when the text couldn't be filtered.
]]
--- @return boolean
function Module.ShowUserMessage(sender: Player, text: string, target: Player?, duration: number?, soundId: string?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(sender) then
		return false
	end

	--[[ Checks ]]

	-- Check if the target is valid when one is given
	if target and not I.Player.Valid(target) then
		return false
	end

	--[[ Filtering ]]

	local filteredText: string? = Module.FilterText(sender, text)

	-- Drop text that couldn't be filtered
	if not filteredText then
		return false
	end

	--[[ Showing ]]

	Module.ShowMessage(target, sender.UserId, sender.Name, filteredText, duration, soundId)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Filter Text

--[[
	**SERVER** |
	Returns text a player wrote, filtered by Roblox for every player to see.
	Returns nil when filtering fails; that text must not be shown. The sender has to be in this server.
]]
--- @return string?
function Module.FilterText(sender: Player, text: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(sender) then
		return nil
	end

	--[[ Filtering ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(function()
		local filterResult: TextFilterResult = I.S.TextService:FilterStringAsync(text, sender.UserId, Enum.TextFilterContext.PublicChat)
		return filterResult:GetNonChatStringForBroadcastAsync()
	end)

	--[[ Checks ]]

	-- Check if filtering succeeded
	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to filter text from ({sender.Name})! - ({result})`)
		return nil
	end

	--[[ Returning ]]

	return result
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
