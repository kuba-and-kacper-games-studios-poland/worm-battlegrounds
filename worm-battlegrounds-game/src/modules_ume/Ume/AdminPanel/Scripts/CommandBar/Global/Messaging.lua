--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local MessagingService = I.S.MessagingService
local HttpService = I.S.HttpService
local Players = I.S.Players

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local shared --- @type AdminPanel_CommandBar_GlobalShared
local state --- @type AdminPanel_CommandBar_GlobalState

local utils --- @type AdminPanel_CommandBar_Utils

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Subscribe With Retry

--[[
	Subscribes `callback` to a MessagingService topic, retrying with a growing delay while the subscribe fails.
	Gives up with a warn after `GLOBAL_SUBSCRIBE_ATTEMPTS` attempts.
]]
local function subscribeWithRetry(topic: string, callback: (message: any) -> ())
	for attempt: number = 1, _settings.GLOBAL_SUBSCRIBE_ATTEMPTS do
		--[[ Subscribing ]]

		local success: boolean
		local result: any | string?
		success, result = pcall(MessagingService.SubscribeAsync, MessagingService, topic, callback)

		-- Stop once subscribed
		if success then
			return
		end

		--[[ Retrying ]]

		-- Give up after the last attempt
		if attempt == _settings.GLOBAL_SUBSCRIBE_ATTEMPTS then
			warn(`[{_localName}::{script.Name}]: Failed to subscribe to ({topic}) after {attempt} attempts, global commands are off on this server! - ({result})`)
			return
		end

		-- Warn once, on the first failure
		if attempt == 1 then
			warn(`[{_localName}::{script.Name}]: Failed to subscribe to ({topic}), retrying! - ({result})`)
		end

		task.wait(math.min(2 ^ attempt, 60))
	end
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

--- @class AdminPanel_CommandBar_Global_Messaging
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _shared AdminPanel_CommandBar_GlobalShared
function Module.Init(_shared)
	shared = _shared
	state = _shared.state

	utils = _shared.utils
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Messaging

--%%%%%%%%%%%%%%%%%%%% Listen For Global Commands

--[[
	Subscribes this server to the global command topic and its output topic.
	A failed subscribe is retried with a growing delay.
]]
function Module.ListenForGlobalCommands()
	--[[ Data ]]

	local aliases = state.aliases --- @type { [string]: AdminPanel_CommandBar_CommandData_Global }
	local callbacks = state.callbacks --- @type { [string]: function }

	--[[ Global Command ]]

	subscribeWithRetry(Module.GetGlobalTopic(), function(dataTable: table)
		--[[ Getting Data ]]

		--- @type AdminPanel_CommandBar_GlobalMessage_SendData
		local receivedData = dataTable.Data and HttpService:JSONDecode(dataTable.Data)
		if not receivedData or type(receivedData) ~= "table" then
			return
		end

		local timePassed: number = os.time() - dataTable.Sent

		--[[ Checks ]]

		-- Return if the maximum allowed time has passed
		if timePassed > _settings.GLOBAL_VALIDITY_PERIOD then
			return
		end

		-- Invalid data
		if not receivedData.alias or not receivedData.args then
			return
		end

		--[[ Running Command ]]

		local success: boolean, message: string | table, globalReturnArgs: table? = shared.Run.RunCommand(receivedData.invoker, receivedData.alias, receivedData.args, true)

		--[[ Returning Global ]]

		--- @type AdminPanel_CommandBar_CommandData_Global
		local commandData = aliases[receivedData.alias]
		if not commandData or type(commandData) ~= "table" then
			return
		end

		--- @param variantData AdminPanel_CommandBar_VariantData
		local variantSuccess: boolean, variantData, _newArgs: { any } = utils.GetVariantDataFromArgs(commandData, receivedData.args)
		if not variantSuccess then
			return
		end

		if globalReturnArgs and type(globalReturnArgs) ~= "table" then
			globalReturnArgs = { `{globalReturnArgs}` }
		end

		-- Send if there's a message and global output is enabled
		if message and commandData and variantData.globalOutput then
			Module._publishOutput({
				alias = receivedData.alias,
				args = receivedData.args,

				success = success,
				message = message,

				invoker = receivedData.invoker,
				globalReturnArgs = globalReturnArgs,
			})
		end
	end)

	--[[ Output Received ]]

	subscribeWithRetry(`{Module.GetGlobalTopic()}_Output`, function(dataTable: table)
		--[[ Getting Data ]]

		--- @type AdminPanel_CommandBar_GlobalMessage_OutputData
		local receivedData = dataTable.Data and HttpService:JSONDecode(dataTable.Data)
		if not receivedData or type(receivedData) ~= "table" then
			return
		end

		local timePassed: number = os.time() - dataTable.Sent

		--[[ Checks ]]

		-- Return if the maximum allowed time has passed
		if timePassed > _settings.GLOBAL_VALIDITY_PERIOD then
			return
		end

		-- Invalid data
		if not receivedData.alias or not receivedData.invoker then
			return
		end

		--[[ Getting Invoker ]]

		local invoker: Player = tonumber(receivedData.invoker) and Players:GetPlayerByUserId(tonumber(receivedData.invoker))
		if not invoker then
			return
		end

		--[[ Printing ]]

		local sendMessage: string = receivedData.message or (receivedData.success and _settings.DEBUG_MESSAGES.Success or _settings.DEBUG_MESSAGES.Failure)
		I.Network.Fire("_AdminPanel_CommandBar_PrintToOutput", invoker, receivedData.success, `g!{receivedData.alias}`, sendMessage)

		--[[ Global Return Callback ]]

		if receivedData.globalReturnArgs then
			--[[ Getting Variant ]]

			--- @type AdminPanel_CommandBar_CommandData_Global
			local commandData = aliases[receivedData.alias]
			if not commandData or type(commandData) ~= "table" then
				return
			end

			--- @param variantData AdminPanel_CommandBar_VariantData
			local variantSuccess: boolean, variantData, _newArgs: { any } = utils.GetVariantDataFromArgs(commandData, receivedData.args)
			if not variantSuccess then
				return
			end

			--[[ Running Callback ]]

			if variantData.callbackUUID_globalReturn and callbacks[variantData.callbackUUID_globalReturn] then
				--[[ Getting Args Unpack Table ]]

				local toUnpack = {} --- @type { any }
				local unpackCount: number = 0

				-- Invoker
				unpackCount += 1
				toUnpack[unpackCount] = invoker

				-- Return arguments, as many as the variant declares
				if variantData.globalReturnArgsCount then
					for count: number = 1, variantData.globalReturnArgsCount do
						unpackCount += 1
						toUnpack[unpackCount] = receivedData.globalReturnArgs[count]
					end
				end

				--[[ Running Function ]]

				local runSuccess: boolean
				local runResult: string | boolean
				local runMessage: string?
				runSuccess, runResult, runMessage = pcall(function()
					return callbacks[variantData.callbackUUID_globalReturn](table.unpack(toUnpack, 1, unpackCount))
				end)

				--[[ Output ]]

				local success: boolean, output: string?

				if runResult then
					if type(runResult) == "boolean" then
						if runMessage then
							success = runResult
							output = runMessage
						else
							success = runResult
						end
					else
						success = runSuccess
						output = runResult
					end
				else
					success = false
				end

				--[[ Printing ]]

				-- Skip an empty output
				if output ~= "" then
					task.spawn(function()
						task.wait(_settings.GLOBAL_MESSAGE_DISPLAY_DELAY)

						if success then
							I.Network.Fire("_AdminPanel_CommandBar_PrintToOutput", invoker, success, `g!{receivedData.alias}`, output or _settings.DEBUG_MESSAGES.Success)
						else
							I.Network.Fire("_AdminPanel_CommandBar_PrintToOutput", invoker, success, `g!{receivedData.alias}`, output or _settings.DEBUG_MESSAGES.Failure)
						end
					end)
				end
			end
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Publish Output

--[[
	Publishes this server's result of a global command back to the invoker's server.
	An output over `GLOBAL_MESSAGE_SIZE_LIMIT` is replaced by a short marker so the invoker still gets a line.
]]
--- @param outputData AdminPanel_CommandBar_GlobalMessage_OutputData
function Module._publishOutput(outputData)
	--[[ Encoding ]]

	local encodedData: string = HttpService:JSONEncode(outputData)

	-- Replace an output too large for one message with a marker
	if #encodedData > _settings.GLOBAL_MESSAGE_SIZE_LIMIT then
		outputData.message = _settings.DEBUG_MESSAGES.GlobalOutputTooLarge
		encodedData = HttpService:JSONEncode(outputData)
	end

	--[[ Publishing ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(MessagingService.PublishAsync, MessagingService, `{Module.GetGlobalTopic()}_Output`, encodedData)

	-- Warn when the output did not reach the topic
	if not success then
		warn(`[{_localName}::{script.Name}]: Global output publish failed for alias ({outputData.alias})! - ({result})`)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Global Topic

--[[
	Returns the MessagingService topic for global commands.
	Studio sessions use their own topic, so they never run commands from live servers or send commands to them.
]]
--- @return string
function Module.GetGlobalTopic()
	return if I.Env.IsStudio then `{_settings.GLOBAL_TOPIC}_Studio` else _settings.GLOBAL_TOPIC
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
