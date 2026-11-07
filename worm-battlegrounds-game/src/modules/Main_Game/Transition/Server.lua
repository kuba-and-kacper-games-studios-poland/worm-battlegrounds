--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Transition"

--- @type Transition_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- How many times each player's current teleport was tried again
local retries = {} --- @type { [Player]: number }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--   __      __                  __            __
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

	I.Network.GetEvent("Transition_Destination")

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Transition = {

		--[[ Control ]]

		SetDestination = Module.SetDestination,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Connections ]]

	I.S.TeleportService.TeleportInitFailed:Connect(Module._onTeleportFailed)
	I.S.Players.PlayerRemoving:Connect(function(player: Player)
		retries[player] = nil
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set Destination

--[[
	**SERVER** |
	Tells players where their next teleport takes them, for the teleport card: call it right before the teleport.
]]
--- @param players { Player }
function Module.SetDestination(players, text: string, image: string)
	--[[ Sending ]]

	for _index: number, player: Player in ipairs(players) do
		I.Network.Fire("Transition_Destination", player, text, image)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Teleport Failed

--[[
	A teleport Roblox had accepted failed on the way: tries it again a few times, then takes the card off the player's
	screen and tells them, so they aren't left on it.
]]
function Module._onTeleportFailed(player: Player, result: Enum.TeleportResult, message: string, placeId: number, options: TeleportOptions)
	--[[ Retrying ]]

	local count: number = (retries[player] or 0) + 1
	retries[player] = count
	if count <= _settings.TELEPORT_RETRIES and table.find(_settings.TELEPORT_RETRY_RESULTS, result) then
		task.wait(_settings.TELEPORT_RETRY_DELAY)

		local success: boolean
		local retryResult: any | string?
		success, retryResult = pcall(function()
			return I.S.TeleportService:TeleportAsync(placeId, { player }, options)
		end)
		if success then
			return
		end
		warn(`[{_localName}::{script.Name}]: Retrying the teleport for ({player.Name}) failed! - ({retryResult})`)
	end

	--[[ Giving Up ]]

	warn(`[{_localName}::{script.Name}]: Teleport for ({player.Name}) to ({placeId}) failed! - ({result.Name}: {message})`)
	retries[player] = nil

	-- The player may have left while it retried
	local playerGui: PlayerGui? = player:FindFirstChildOfClass("PlayerGui")
	if not playerGui then
		return
	end

	--[[ Removing ]]

	for _index: number, gui: Instance in ipairs(playerGui:GetChildren()) do
		if gui.Name == _settings.GUI_NAME then
			gui:Destroy()
		end
	end

	--[[ Telling ]]

	I.Notify.ShowNotification(player, _settings.TELEPORT_FAILED_MESSAGE)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
