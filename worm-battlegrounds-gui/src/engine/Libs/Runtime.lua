--[[
	Created By: 	Nari
]]

local _localName: string = "Runtime"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Libs

local Scope = require(script.Parent:FindFirstChild("Scope")) --- @type UmeGui_Libs_Scope

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- CollectionService is scoped, so the mirrored scripts only see tagged instances in guis UmeGui binds
local services = { CollectionService = Scope.CollectionService } --- @type { [string]: any }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Service

--[[
	Returns a service by name and caches it, so `I.S.TweenService` works like in the framework.
]]
--- @return any
local function getService(_self, serviceName: string)
	--[[ Checks ]]

	-- Reuse a service that was already looked up
	if services[serviceName] then
		return services[serviceName]
	end

	--[[ Saving ]]

	services[serviceName] = game:GetService(serviceName)

	--[[ Returning ]]

	return services[serviceName]
end

--%%%%%%%%%%%%%%%%%%%% Get Environment

--[[
	Returns live environment values. Only `Camera` is read by the mirrored code.
]]
--- @return Camera?
local function getEnvironment(_self, key: string)
	--[[ Checks ]]

	-- Warn on keys the shim does not provide
	if key ~= "Camera" then
		warn(`[{_localName}]: Env ({key}) is not available in UmeGui!`)
		return nil
	end

	--[[ Returning ]]

	return workspace.CurrentCamera
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

--- @class UmeGui_Runtime
local Module = {

	--[[ Framework ]]

	S = setmetatable({}, { __index = getService }),
	Env = setmetatable({}, { __index = getEnvironment }),

	--[[ Stubs ]]

	Topic = { Subscribe = function() end },
	Platform = { Current = "PC" },
}

return Module
