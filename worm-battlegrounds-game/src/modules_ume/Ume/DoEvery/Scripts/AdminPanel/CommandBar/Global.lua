--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "DoEvery"

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

--- @class DoEvery_CommandBar_Global
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
	Module._registerCommandDictionaries()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers commands used for controlling module.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Trigger Function

	local function trigger(interval: string)
		--[[ Checks ]]

		if not I.DoEvery._registeredEvents[interval] then
			return false, `Invalid Interval: $|cr$|{interval}#|`
		end

		--[[ Executing ]]

		I.DoEvery._registeredEvents[interval].Signal:Fire(I.DoEvery._registeredEvents[interval].Interval, 1)
		return true, `Triggered Interval $|cr$|{interval}#|`
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {
		{
			Aliases = { "trigger" },
			Args = {
				{ name = "interval", types = { "string" }, dict = `DoEvery_Intervals_{I.Env.Key}`, requireDict = true },
			},
			Callback = trigger,
		},
	}

	--[[ Client ]]

	if I.Env.IsClient then
		I.AdminPanel_CommandBar.Register("DoEvery_Client", {
			Aliases = { "doevery" },
			PermissionLevel = 255,

			Variants = variants,
		})
	end

	--[[ Server ]]

	if I.Env.IsServer then
		I.AdminPanel_CommandBar.Register("DoEvery_Server", {
			Aliases = { "s_doevery" },
			PermissionLevel = 255,

			Variants = variants,
		})
	end
end

--%%%%%%%%%%%%%%%%%%%% Register Command Dictionaries

--[[
	Registers dictionaries used by module commands.
]]
function Module._registerCommandDictionaries()
	--[[ Getting Values ]]

	local allIntervals = {} --- @type { string }

	--- @param _delayTable DoEvery_EventTable
	for key: string, _delayTable in pairs(I.DoEvery._registeredEvents) do
		table.insert(allIntervals, key)
	end

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary(`DoEvery_Intervals_{I.Env.Key}`, allIntervals, 255)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
