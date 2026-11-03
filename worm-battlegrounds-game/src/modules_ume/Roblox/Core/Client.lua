--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Core"

--- @type Core_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local StarterGui = I.S.StarterGui
local RunService = I.S.RunService

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
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Core = {

		--[[ Control ]]

		Call = Module.Call,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Call

--[[
	**CLIENT** |
	Calls the passed StarterGui core method in a separate thread, retrying until it succeeds.
	Retries every frame at first, then every SLOW_RETRY_INTERVAL seconds, and gives up after MAX_RETRY_SECONDS.
]]
function Module.Call(method: string, ...: any)
	--[[ Local Variables ]]

	local args = table.pack(...) --- @type { [any]: any }
	local startTime: number = os.clock()

	--[[ Calling ]]

	task.spawn(function()
		local hasFailed: boolean = false

		while true do
			--[[ Calling ]]

			local success: boolean
			local result: any | string?
			success, result = pcall(StarterGui[method], StarterGui, table.unpack(args, 1, args.n))

			-- Stop once the call succeeded
			if success then
				return
			end

			--[[ Logging ]]

			local elapsed: number = os.clock() - startTime

			-- Print only the first failure
			if not hasFailed and _settings.FAILED_CALL_LOG and I.Env.IsStudio then
				print(`[{_localName}::{script.Name}]: Call ({method}) failed, retrying! - {result}`)
			end
			hasFailed = true

			-- Give up after MAX_RETRY_SECONDS
			if elapsed >= _settings.MAX_RETRY_SECONDS then
				warn(`[{_localName}::{script.Name}]: Call ({method}) still failed after {_settings.MAX_RETRY_SECONDS} seconds, giving up! - ({result})`)
				return
			end

			--[[ Waiting ]]

			-- Retry every frame first, then back off
			if elapsed < _settings.FAST_RETRY_SECONDS then
				RunService.Heartbeat:Wait()
			else
				task.wait(_settings.SLOW_RETRY_INTERVAL)
			end
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
