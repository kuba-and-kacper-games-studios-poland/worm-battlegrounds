--[[
    Created By:     Nari 
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Interact"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Press = require(_scripts:FindFirstChild("Client"):FindFirstChild("Press")) --- @type Interact_Client_Press

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

--- @class Interact_Button : Component
--- @field Instance ImageButton | TextButton
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field ModuleName string
--- @field FunctionName string
--- @field Args table
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Type Check ]]

	if not self.Instance:IsA("ImageButton") and not self.Instance:IsA("TextButton") then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is not a Button! -`, self.Instance)
		return
	end

	--[[ Connecting ]]

	table.insert(
		self.Connections,
		Press.OnPress(self.Instance, function()
			self:Call()
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Call

--[[
	Calls `I[Interact_ModuleName][Interact_Function]` with the `Interact_Arg*` attributes, in order.
]]
function Component:Call()
	--[[ Attributes ]]

	local moduleName: any = self.Instance:GetAttribute("Interact_ModuleName")
	local functionName: any = self.Instance:GetAttribute("Interact_Function")

	--[[ Checks ]]

	-- Skip a button that names no function
	if typeof(moduleName) ~= "string" or moduleName == "" or typeof(functionName) ~= "string" or functionName == "" then
		return
	end

	--[[ Arguments ]]

	local args = {} --- @type { any }
	local count: number = 0

	while true do
		count += 1

		local arg: any = self.Instance:GetAttribute(`Interact_Arg{count}`)

		-- Stop at the first missing argument
		if arg == nil then
			break
		end

		table.insert(args, arg)
	end

	--[[ Checks ]]

	local callback: any = I[moduleName] and I[moduleName][functionName]

	-- Skip a module or function that doesn't exist
	if typeof(callback) ~= "function" then
		return
	end

	--[[ Calling ]]

	callback(table.unpack(args))
end

return Component
