--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Component"

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

--- @class Component_CommandBar_Global
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
	--%%%%%%%%%%%%%%%%%%%% Control Functions

	local function register(compName: string)
		--[[ Checks ]]

		if not I.Component._componentsModules[compName] then
			return false, `Invalid Component name: $|cr$|{compName}#|`
		end

		if I.Component.IsRegistered(`{compName}`) then
			return true, `Component $|cr$|{compName}#| is already registered`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Component.Register(compName, I.Component._componentsModules[compName])

		-- Returning
		if value then
			return true, `Component $|cr$|{compName}#| registered successfully`
		else
			return false, `Failed to register component $|cr$|{compName}#|`
		end
	end

	local function unregister(compName: string)
		--[[ Checks ]]

		if not I.Component._componentsModules[compName] then
			return false, `Invalid Component name: $|cr$|{compName}#|`
		end

		if not I.Component.IsRegistered(`{compName}`) then
			return false, `Component $|cr$|{compName}#| is not registered`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Component.Unregister(compName)

		-- Returning
		if value then
			return true, `Component $|cr$|{compName}#| unregistered successfully`
		else
			return false, `Failed to unregister component $|cr$|{compName}#|`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Methods Functions

	local function isRegistered(compName: string)
		-- Getting value
		local value: boolean = I.Component.IsRegistered(`{compName}`)

		-- Returning
		if value then
			return true, `Component $|cr$|{compName}#| is registered`
		else
			return false, `Component $|cr$|{compName}#| is not registered`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {
		{
			Aliases = { "register" },
			Args = {
				{ name = "compName", types = { "string" }, dict = `Component_ComponentName_{I.Env.Key}_Unregistered`, requireDict = true },
			},
			Callback = register,
		},
		{
			Aliases = { "unregister" },
			Args = {
				{ name = "compName", types = { "string" }, dict = `Component_ComponentName_{I.Env.Key}_Registered`, requireDict = true },
			},
			Callback = unregister,
		},
		{
			Aliases = { "is_registered" },
			Args = {
				{ name = "compName", types = { "string" }, dict = `Component_ComponentName_{I.Env.Key}_All`, requireDict = true },
			},
			Callback = isRegistered,
		},
	}

	--[[ Client ]]

	if I.Env.IsClient then
		I.AdminPanel_CommandBar.Register("Component_Client", {
			Aliases = { "component" },
			PermissionLevel = 255,

			Variants = variants,
		})
	end

	--[[ Server ]]

	if I.Env.IsServer then
		I.AdminPanel_CommandBar.Register("Component_Server", {
			Aliases = { "s_component" },
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

	local allCompNames = {} --- @type { string }

	for tag: string, _comp: table in pairs(I.Component._registeredComponents) do
		table.insert(allCompNames, tag)
	end

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary(`Component_ComponentName_{I.Env.Key}_All`, allCompNames, 255)
	I.AdminPanel_CommandBar.SetDictionary(`Component_ComponentName_{I.Env.Key}_Registered`, allCompNames, 255)
	I.AdminPanel_CommandBar.SetDictionary(`Component_ComponentName_{I.Env.Key}_Unregistered`, {}, 255)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
