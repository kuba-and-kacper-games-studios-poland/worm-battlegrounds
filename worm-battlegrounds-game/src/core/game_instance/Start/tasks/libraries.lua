--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type { Ume_Library }
local libraries = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task

--- @class Ume_Task_Libraries
local _task = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Load

--[[
	Loads all libraries for injection into the Ume instance.
]]
function _task.Load(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	--[[
		Requires each library module in a folder and stores it for injection.
	]]
	local function loadFolder(folder: Folder)
		--[[ Sorting ]]

		--- @type { Instance }
		local children = folder:GetChildren()
		table.sort(children, function(a: Instance, b: Instance)
			return a.Name < b.Name
		end)

		--[[ Requiring ]]

		for _index: number, child: Instance in ipairs(children) do
			--[[ Checks ]]

			-- Skip instances that are not library modules
			if not child:IsA("ModuleScript") then
				continue
			end

			--[[ Requiring ]]

			local success: boolean
			local result: any | string?
			success, result = pcall(require, child)

			--[[ Checks ]]

			-- Check if the require succeeded
			if not success then
				error(`[Ume::{script.Name}]: Failed to load library ({child.Name})! - ({result})`, 2)
			end

			-- Check if the module returned a table
			if type(result) ~= "table" then
				error(`[Ume::{script.Name}]: Invalid library ({child.Name})! Expected (table), got ({typeof(result)})!`, 2)
			end

			-- Check if the module can assign itself
			if type(result._injectUme) ~= "function" then
				error(`[Ume::{script.Name}]: Invalid library ({child.Name})! Expected (_injectUme) function, got ({typeof(result._injectUme)})!`, 2)
			end

			--[[ Storing ]]

			table.insert(libraries, result)
		end
	end

	--%%%%%%%%%%%%%%%%%%%%

	table.clear(libraries)

	--[[ Folders ]]

	local internalLibsFolder: Folder = I._dirs.Libs:FindFirstChild("Internal")
	local externalLibsFolder: Folder = I._dirs.Libs:FindFirstChild("External")

	--[[ Requiring ]]

	loadFolder(internalLibsFolder)
	loadFolder(externalLibsFolder)
end

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Injects the Ume instance into every loaded library.
]]
function _task.InjectUme(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	--[[ Injecting ]]

	--- @param libraryTable Ume_Library
	for _index: number, libraryTable in ipairs(libraries) do
		libraryTable._injectUme(I)
	end
end

return _task
