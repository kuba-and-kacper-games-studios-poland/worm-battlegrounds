--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Notify"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Sender

--[[
	Returns the player who ran a command when they are in this server, so their text can be filtered.
]]
--- @return Player?
local function getSender(invoker: Player | number)
	return if typeof(invoker) == "Instance" then invoker else I.S.Players:GetPlayerByUserId(tonumber(invoker) or 0)
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

--- @class Notify_CommandBar_Server
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

	local function notification(invoker: Player | number, player: Player?, message: string, gradientId: string?, duration: number?, soundId: string?, _isGlobal: boolean?)
		--[[ Filtering ]]

		local sender: Player? = getSender(invoker)

		-- Check if the invoker is in this server
		if not sender then
			return false, `Can't filter the text of an invoker who isn't in this server`
		end

		local filteredMessage: string? = I.Notify.FilterText(sender, message)

		-- Check if the text was filtered
		if not filteredMessage then
			return false, `Failed to filter the notification text`
		end

		--[[ Executing ]]

		I.Notify.ShowNotification(player, filteredMessage, gradientId, duration, soundId)

		--[[ Returning ]]

		if player then
			return true, `Showed $|cr$|{filteredMessage}#| notification to player $|cr$|{player.Name}#|`
		end

		return true, `Showed $|cr$|{filteredMessage}#| notification to all players`
	end

	local function message(invoker: Player | number, text: string, duration: number?, soundId: string?, _isGlobal: boolean?)
		--[[ Invoker ]]

		local sender: Player? = getSender(invoker)

		-- Check if the invoker is in this server
		if not sender then
			return false, `Can't filter the text of an invoker who isn't in this server`
		end

		--[[ Executing ]]

		-- Check if the text was filtered and shown
		if not I.Notify.ShowUserMessage(sender, text, nil, duration, soundId) then
			return false, `Failed to filter the message from $|cr$|{sender.Name}#|`
		end

		--[[ Returning ]]

		return true, `Showed $|cr$|{text}#| message from $|cr$|{sender.Name}#| to all players`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "notification" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true, optional = true },
				{ name = "message", types = { "string" } },
				{ name = "gradientId", types = { "string" }, optional = true },
				{ name = "duration", types = { "number" }, optional = true },
				{ name = "soundId", types = { "string" }, optional = true },
			},
			EnableGlobally = true,
			PassInvoker = true,
			Callback = notification,
		},
		{
			Aliases = { "message" },
			Args = {
				{ name = "message", types = { "string" } },
				{ name = "duration", types = { "number" }, optional = true },
				{ name = "soundId", types = { "string" }, optional = true },
			},
			EnableGlobally = true,
			PassInvoker = true,
			Callback = message,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Notify_Server", {
		Aliases = { "notify" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
