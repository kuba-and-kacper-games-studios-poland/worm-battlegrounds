--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "SoftShutdown"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Players = I.S.Players

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local CLOSE_BUDGET = 29
local TELEPORT_BATCH_SIZE = 50
local TELEPORT_RETRY_DELAY = 2
local TELEPORT_GUI_NAME = "ShutdownTeleportGui"

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

	game:BindToClose(Module._onServerClosing)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Server Closing

--[[
    Teleports all active and incoming players to a lobby server due to a server restart, in batches,
	retrying failed teleports until the close budget runs out.
]]
function Module._onServerClosing()
	--[[ Checks ]]

	-- Return if in studio
	if I.Env.IsStudio then
		return
	end

	-- Return if there are no players left
	if #Players:GetPlayers() == 0 then
		return
	end

	--[[ Local Variables ]]

	local deadline: number = os.clock() + CLOSE_BUDGET

	--[[ Connections ]]

	-- Teleporting incoming players
	Players.PlayerAdded:Connect(function(player: Player)
		Module._teleportWithRetry({ player }, deadline)
	end)

	-- Retrying players whose teleport failed after it started
	I.S.TeleportService.TeleportInitFailed:Connect(function(player: Player, teleportResult: Enum.TeleportResult, errorMessage: string)
		-- Skip a player who left or a retry past the deadline
		if player.Parent ~= Players or os.clock() >= deadline then
			return
		end

		warn(`[{_localName}::{script.Name}]: Teleport of ({player.Name}) failed ({teleportResult.Name}) - retrying! - ({errorMessage})`)
		Module._teleportWithRetry({ player }, deadline)
	end)

	--[[ Teleporting ]]

	-- Teleporting all existing players, at most TELEPORT_BATCH_SIZE per call
	local playersList = Players:GetPlayers() --- @type { Player }
	for index: number = 1, #playersList, TELEPORT_BATCH_SIZE do
		local batch = table.move(playersList, index, math.min(index + TELEPORT_BATCH_SIZE - 1, #playersList), 1, {}) --- @type { Player }
		Module._teleportWithRetry(batch, deadline)
	end

	--[[
        Wait until the server is empty or ~30s elapses (Roblox BindToClose budget, shared with other handlers).
    ]]

	repeat
		task.wait(1)
	until #Players:GetPlayers() == 0 or os.clock() > deadline
end

--%%%%%%%%%%%%%%%%%%%% Teleport With Retry

--[[
	Teleports the players who are still in the server to the default lobby in a new thread, retrying until it succeeds
	or the deadline passes.
]]
--- @param playersList { Player }
function Module._teleportWithRetry(playersList, deadline: number)
	task.spawn(function()
		while os.clock() < deadline do
			--[[ Local Variables ]]

			local remaining = {} --- @type { Player }

			for _index: number, player: Player in ipairs(playersList) do
				-- Keep only players still in the server
				if player.Parent == Players then
					table.insert(remaining, player)
				end
			end

			--[[ Checks ]]

			-- Stop when everyone already left
			if #remaining == 0 then
				return
			end

			--[[ Teleporting ]]

			-- Stop once the teleport started
			if I.TeleportToDefaultLobby(remaining, TELEPORT_GUI_NAME) then
				return
			end

			task.wait(TELEPORT_RETRY_DELAY)
		end

		warn(`[{_localName}::{script.Name}]: Gave up teleporting ({#playersList}) players before the server closed!`)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
