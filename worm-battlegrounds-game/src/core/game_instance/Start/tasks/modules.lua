--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type { [string]: { [string]: ModuleScript } }
local storedModules = {}

--- @type { [string]: ModuleScript }
local storedSettings = {}

--- @type { string }
local ADMIN_PANEL_TOOLS = { "CommandBar", "Dashboard" }

--- @type { [string]: { [string]: { [string]: ModuleScript } } }
local storedAdminPanel = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Find Child Ignore Case

--[[
	Finds the first child whose name matches, ignoring case.
]]
--- @return Instance?
local function findChildIgnoreCase(parent: Instance, wantedName: string)
	--[[ Finding ]]

	local wantedLower: string = string.lower(wantedName)

	for _: number, child: Instance in ipairs(parent:GetChildren()) do
		--[[ Checks ]]

		-- Check if the child name matches
		if string.lower(child.Name) == wantedLower then
			return child
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Admin Panel Folders

--[[
	Returns the AdminPanel tool folders a module has under `Scripts/AdminPanel`, by tool name.
]]
--- @return { [string]: Instance }
local function getAdminPanelFolders(moduleFolder: Instance)
	--[[ Local Variables ]]

	local toolFolders = {} --- @type { [string]: Instance }
	local scriptsFolder: Instance? = findChildIgnoreCase(moduleFolder, "Scripts")
	local adminPanelFolder: Instance? = if scriptsFolder then findChildIgnoreCase(scriptsFolder, "AdminPanel") else nil

	--[[ Checks ]]

	-- Skip a module without an AdminPanel folder
	if not adminPanelFolder then
		return toolFolders
	end

	--[[ Finding ]]

	for _: number, toolName: string in ipairs(ADMIN_PANEL_TOOLS) do
		toolFolders[toolName] = findChildIgnoreCase(adminPanelFolder, toolName)
	end

	--[[ Returning ]]

	return toolFolders
end

--%%%%%%%%%%%%%%%%%%%% Rename Scope Scripts

--[[
	Renames the Global, Server, and Client scripts in a folder.
]]
--- @param renameFunc (scope: string) -> string
local function renameScopeScripts(folder: Instance, renameFunc)
	--[[ Local Variables ]]

	--- @type { [string]: Instance }
	local toRename = {
		["Global"] = findChildIgnoreCase(folder, "Global"),
		["Server"] = findChildIgnoreCase(folder, "Server"),
		["Client"] = findChildIgnoreCase(folder, "Client"),
	}

	--[[ Renaming ]]

	for scope: string, elem: Instance? in pairs(toRename) do
		--[[ Checks ]]

		-- Skip a missing scope script
		if not elem then
			continue
		end

		-- Check if the scope script is a ModuleScript
		if not elem:IsA("ModuleScript") then
			warn(`[Ume::{script.Name}]: Script ({elem.Name}) in Module ({folder.Name}) is not a ModuleScript!`)
			continue
		end

		--[[ Renaming ]]

		elem.Name = renameFunc(scope)
	end
end

--%%%%%%%%%%%%%%%%%%%% Resolve Module Name

--[[
	Strips a numeric load prefix on the server and rebuilds the old script name on the client.
]]
--- @param I Ume
--- @return string
--- @return string
local function resolveModuleName(moduleFolder: Folder, I)
	--[[ Local Variables ]]

	local originalName: string = moduleFolder.Name
	local truncatedName: string = moduleFolder.Name

	--[[ Server ]]

	if I.Env.IsServer then
		local splitParts = string.split(originalName, "_") --- @type { string }
		local prefix: number? = if #splitParts > 1 then tonumber(splitParts[1]) else nil

		-- Strip a numeric load prefix and keep it for sorting
		if prefix then
			truncatedName = string.sub(originalName, #`{prefix}` + 2)
			moduleFolder:SetAttribute("Ume_PrefixSortOrder", prefix)
		end
	end

	--[[ Client ]]

	if I.Env.IsClient then
		local prefixIndex = moduleFolder:GetAttribute("Ume_PrefixSortOrder")

		-- Rebuild the prefixed name so script renames still match
		if prefixIndex then
			originalName = `{prefixIndex}_{truncatedName}`
		end
	end

	--[[ Renaming ]]

	moduleFolder.Name = truncatedName

	--[[ Returning ]]

	return originalName, truncatedName
end

--%%%%%%%%%%%%%%%%%%%% Store Scope Scripts

--[[
	Stores the Global and environment scripts from a folder and renames them to the stored module name.
]]
--- @return { [string]: ModuleScript }
--- @return boolean
local function storeScopeScripts(parent: Instance, originalName: string, truncatedName: string, envKey: string)
	--[[ Local Variables ]]

	local bucket = {} --- @type { [string]: ModuleScript }
	local hasAny: boolean = false
	local envNeedle: string = `ume || {string.lower(envKey)}`

	--[[ Storing ]]

	for _: number, elem: Instance in ipairs(parent:GetChildren()) do
		--[[ Checks ]]

		-- Skip instances that are not ModuleScripts
		if not elem:IsA("ModuleScript") then
			continue
		end

		--[[ Global ]]

		-- Check if this is the global script
		if string.find(string.lower(elem.Name), "ume || global", 1) then
			bucket["Global"] = elem
			elem.Name = string.gsub(elem.Name, originalName, truncatedName)
			hasAny = true
			continue
		end

		--[[ Environment ]]

		-- Check if this is the environment script
		if string.find(string.lower(elem.Name), envNeedle, 1) then
			bucket[envKey] = elem
			elem.Name = string.gsub(elem.Name, originalName, truncatedName)
			hasAny = true
			continue
		end
	end

	--[[ Returning ]]

	return bucket, hasAny
end

--%%%%%%%%%%%%%%%%%%%% Run Module Function

--[[
	Requires a module script and runs one function on the table it returns.
]]
local function runModuleFunction(module: ModuleScript, functionName: string)
	--[[ Requiring ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(require, module)

	--[[ Checks ]]

	-- Check if the module returned a table
	if not success or not result or type(result) ~= "table" then
		warn(`[Ume::{script.Name}]: Error while loading module [{module.Parent.Name}::{module.Name}]`)
		warn(result)
		return
	end

	--[[ Running ]]

	-- Skip a module that does not define this function
	if not result[functionName] then
		return
	end

	-- Check if the value is a function
	if type(result[functionName]) ~= "function" then
		warn(`[Ume::{script.Name}]: Function [{module.Parent.Name}::{module.Name}.{functionName}] is not a (function) but a ({result[functionName]}: {typeof(result[functionName])})!`)
		return
	end

	--[[ Executing ]]

	local moduleFunction = result[functionName]
	success, result = pcall(moduleFunction)

	-- Check if the function executed
	if not success then
		warn(`[Ume::{script.Name}]: Error while executing function [{module.Parent.Name}::{module.Name}.{functionName}()]`)
		warn(result)
	end
end

--%%%%%%%%%%%%%%%%%%%% Get Exec Label

--[[
	Builds the execution-time label for one module function.
]]
--- @return string
local function getExecLabel(moduleName: string, scopeKey: string, functionName: string, execTimeKind: string?)
	--[[ Checks ]]

	-- Use the plain label when no kind is set
	if not execTimeKind then
		return `{moduleName}::{scopeKey}.{functionName}`
	end

	--[[ Returning ]]

	return `{moduleName}::{execTimeKind}.{scopeKey}.{functionName}`
end

--%%%%%%%%%%%%%%%%%%%% Loop Through Modules

--[[
	Runs one function on each stored scope script and records how long it took.
	Loads module settings when this pass asks for them.
]]
--- @param I Ume
--- @param sortedModules { Folder }
--- @param executionTime { Ume_ModuleExecEntry }
--- @param storedTable { [string]: { [string]: ModuleScript } }
local function loopThroughModules(I, functionName: string, functionIdentifier: string, sortedModules, executionTime, storedTable, execTimeKind: string?, loadSettings: boolean)
	--[[ Running ]]

	for _: number, moduleFolder: Folder in ipairs(sortedModules) do
		--[[ Checks ]]

		-- Skip a module that was not stored
		if not storedTable[moduleFolder.Name] then
			continue
		end

		--[[ Local Variables ]]

		local scopeTable = storedTable[moduleFolder.Name] --- @type { [string]: ModuleScript }
		local globalScript: ModuleScript? = scopeTable["Global"]
		local environmentScript: ModuleScript? = scopeTable[I.Env.Key]

		--[[ Global ]]

		-- Run the global script when this module has one
		if globalScript then
			local startTime: number = os.clock()
			runModuleFunction(globalScript, functionName)

			table.insert(executionTime, {
				FunctionName = getExecLabel(moduleFolder.Name, "Global", functionName, execTimeKind),
				ExecTime = os.clock() - startTime,
			})
		end

		--[[ Environment ]]

		-- Run the environment script when this module has one
		if environmentScript then
			local startTime: number = os.clock()
			runModuleFunction(environmentScript, functionName)

			table.insert(executionTime, {
				FunctionName = getExecLabel(moduleFolder.Name, I.Env.Key, functionName, execTimeKind),
				ExecTime = os.clock() - startTime,
			})
		end

		--[[ Settings ]]

		-- Load settings when this pass asks for them
		if loadSettings then
			local settingsModule: ModuleScript? = storedSettings[moduleFolder.Name]

			-- Load settings that are not stored yet
			if settingsModule and not I.Settings[moduleFolder.Name] then
				local success: boolean
				local result: any | string?
				success, result = pcall(require, settingsModule)

				-- Check if the settings module loaded
				if success then
					I.Settings[moduleFolder.Name] = result
				else
					warn(`[Ume::{script.Name}]: Error while loading settings module [{moduleFolder.Name}::Settings]`)
					warn(result)
				end
			end
		end
	end

	--[[ Saving ]]

	I.Modules[functionIdentifier] = true
end

--%%%%%%%%%%%%%%%%%%%% Warn If Duplicated

--[[
	Warns when two module folders share a name, and stops startup in Studio.
]]
--- @param I Ume
local function warnIfDuplicated(I)
	--[[ Checks ]]

	-- Skip the duplicate scan on the client
	if not I.Env.IsServer then
		return
	end

	--[[ Local Variables ]]

	local moduleNames = {} --- @type { string }
	local duplicatedFound: boolean = false

	--[[ Finding ]]

	for _: number, dirFolder: Folder in ipairs(I._dirs.Modules:GetChildren()) do
		for _index: number, moduleFolder: Folder in ipairs(dirFolder:GetChildren()) do
			--[[ Checks ]]

			-- Check if this module name was already seen
			if table.find(moduleNames, moduleFolder.Name) then
				warn(`[Ume::{script.Name}]: Module ({moduleFolder.Name}) is duplicated!`)
				duplicatedFound = true
				continue
			end

			--[[ Saving ]]

			table.insert(moduleNames, moduleFolder.Name)
		end
	end

	--[[ Checks ]]

	-- Stop startup in Studio when a duplicate was found
	if duplicatedFound and I.Env.IsStudio then
		error("Ume framework cannot start when there are duplicated modules!", 2)
	end
end

--%%%%%%%%%%%%%%%%%%%% Get Sorted Modules

--[[
	Returns module folders in directory order, prefix order, then loading order.
]]
--- @param I Ume
--- @return { Folder }
local function getSortedModules(I)
	--[[ Directories ]]

	--- @type { [string]: { Folder } }
	local sortedByDirectory = {}

	for _: number, dirName: string in ipairs(I.Config.Map.ModulesDirs) do
		--[[ Finding ]]

		local dirFolder: Folder? = I._dirs.Modules:FindFirstChild(dirName)

		--[[ Checks ]]

		-- Skip a directory that is not in the place
		if not dirFolder then
			continue
		end

		--[[ Saving ]]

		-- Create the directory bucket on the first visit
		if not sortedByDirectory[dirName] then
			sortedByDirectory[dirName] = {}
		end

		--[[ Inserting ]]

		for _index: number, moduleFolder: Folder in ipairs(dirFolder:GetChildren()) do
			table.insert(sortedByDirectory[dirName], moduleFolder)
		end
	end

	--[[ Prefix Sort ]]

	--- @param dirModules { Folder }
	for _dirName: string, dirModules in pairs(sortedByDirectory) do
		table.sort(dirModules, function(a: Folder, b: Folder)
			local aPrefixPos: number? = a:GetAttribute("Ume_PrefixSortOrder")
			local bPrefixPos: number? = b:GetAttribute("Ume_PrefixSortOrder")

			-- Missing prefixes sort after numbered ones
			return (aPrefixPos or (#dirModules + 1)) < (bPrefixPos or (#dirModules + 1))
		end)
	end

	--[[ Directory Order ]]

	--- @type { Folder }
	local sortedModules = {}

	for _: number, dirName: string in ipairs(I.Config.Map.ModulesDirs) do
		--[[ Checks ]]

		-- Skip a directory that was not collected
		if not sortedByDirectory[dirName] then
			continue
		end

		--[[ Saving ]]

		for _index: number, moduleFolder: Folder in ipairs(sortedByDirectory[dirName]) do
			table.insert(sortedModules, moduleFolder)
		end
	end

	--[[ Loading Order ]]

	local savedOrder = table.clone(sortedModules) --- @type { Folder }
	local loadingOrder = table.clone(I.Config.Modules.LoadingOrder) --- @type { string }

	-- Append map loading order after the core list
	if I.Config.Map.LoadingOrder then
		for _: number, moduleName: string in ipairs(I.Config.Map.LoadingOrder) do
			--[[ Checks ]]

			-- Skip a name that is already listed
			if table.find(loadingOrder, moduleName) then
				continue
			end

			--[[ Saving ]]

			table.insert(loadingOrder, moduleName)
		end
	end

	--[[ Sorting ]]

	table.sort(sortedModules, function(a: Folder, b: Folder)
		local aGeneralPos: number? = table.find(loadingOrder, a.Name)
		local bGeneralPos: number? = table.find(loadingOrder, b.Name)
		local maxGeneralPos: number = #loadingOrder + 1

		-- Prefer LoadingOrder when either module is listed
		if aGeneralPos or bGeneralPos then
			return (aGeneralPos or maxGeneralPos) < (bGeneralPos or maxGeneralPos)
		end

		return table.find(savedOrder, a) < table.find(savedOrder, b)
	end)

	--[[ Returning ]]

	return sortedModules
end

--%%%%%%%%%%%%%%%%%%%% Report Execution Time

--[[
	Sorts module execution times, prints them in Studio, and stores them on the Ume instance.
]]
--- @param I Ume
--- @param executionTime { Ume_ModuleExecEntry }
local function reportExecutionTime(I, executionTime)
	--[[ Sorting ]]

	--- @param a Ume_ModuleExecEntry
	--- @param b Ume_ModuleExecEntry
	table.sort(executionTime, function(a, b)
		return a.ExecTime > b.ExecTime
	end)

	--[[ Local Variables ]]

	local displayTable = {} --- @type { string }
	local totalTime: number = 0

	--[[ Formatting ]]

	--- @param execEntry Ume_ModuleExecEntry
	for _: number, execEntry in ipairs(executionTime) do
		--[[ Applying ]]

		table.insert(displayTable, ("[%.3fs] - [%s]"):format(execEntry.ExecTime, execEntry.FunctionName))
		totalTime += execEntry.ExecTime
	end

	--[[ Printing ]]

	-- Print the sorted times in Studio
	if I.Env.IsStudio then
		local loadingTimeFormatted: string = ("%.3fs"):format(totalTime)
		print(`🧩 {I.Env.Key} Modules Execution Time [{loadingTimeFormatted}] -`, displayTable)
	end

	--[[ Saving ]]

	-- Total execution time for loading and running all modules.
	--- @type number
	I._modulesExecutionTime_Total = totalTime

	-- Sorted list of modules functions execution times.
	--- @type { string }
	I._modulesExecutionTime = displayTable
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task

--- @class Ume_Task_Modules
local _task = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Prepare For Loading

--[[
	Prepares module folders on the server by merging containers, removing unused directories, and renaming scope scripts.
]]
function _task.PrepareForLoading(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started or not I.Env.IsServer then
		return
	end

	--%%%%%%%%%%%%%%%%%%%% Containers

	--[[ Collecting ]]

	--- @type { [string]: Instance }
	local modulesContainers = {}

	for _: number, modulesContainer: Instance in ipairs(I._dirs.Instance:GetChildren()) do
		--[[ Checks ]]

		-- Keep containers whose name includes Modules
		if string.find(modulesContainer.Name, "Modules") then
			modulesContainers[modulesContainer.Name] = modulesContainer
		end
	end

	--[[ Creating ]]

	-- Create the default container when it is missing
	if not modulesContainers["Modules"] then
		local newContainer: Sparkles = Instance.new("Sparkles")
		newContainer.Name = "Modules"
		newContainer.Enabled = false
		newContainer.Parent = I._dirs.Instance
		modulesContainers["Modules"] = newContainer
	end

	--[[ Moving ]]

	local initialDir: Instance = modulesContainers["Modules"]

	-- Keep the default container out of the move loop
	modulesContainers["Modules"] = nil

	for _dirName: string, modulesContainer: Instance in pairs(modulesContainers) do
		--[[ Reparenting ]]

		for _: number, elem: Instance in ipairs(modulesContainer:GetChildren()) do
			elem.Parent = initialDir
		end

		--[[ Removing ]]

		modulesContainer:Destroy()
	end

	--%%%%%%%%%%%%%%%%%%%% Directories

	--[[ Filtering ]]

	--- @type { string }
	local placeDirsNames = table.clone(I.Config.Map.ModulesDirs)

	-- Walk backwards so removals do not shift later indexes
	for index: number = #placeDirsNames, 1, -1 do
		--[[ Checks ]]

		local dirName: string = placeDirsNames[index]

		-- Remove a directory that is not in the place
		if not I._dirs.Modules:FindFirstChild(dirName) then
			warn(`[Ume::{script.Name}]: Place Modules Directory ({dirName}) doesn't exist!`)
			table.remove(placeDirsNames, index)
		end
	end

	--[[ Removing ]]

	for _: number, dirFolder: Folder in ipairs(I._dirs.Modules:GetChildren()) do
		--[[ Checks ]]

		-- Remove a directory that this place does not use
		if not table.find(placeDirsNames, dirFolder.Name) then
			dirFolder:Destroy()
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Modules

	for _: number, dirFolder: Folder in ipairs(I._dirs.Modules:GetChildren()) do
		for _index: number, moduleFolder: Folder in ipairs(dirFolder:GetChildren()) do
			--[[ Checks ]]

			-- Remove a disabled module
			if table.find(I.Config.Map.DisabledModules, moduleFolder.Name) then
				moduleFolder:Destroy()
				continue
			end

			--[[ Renaming ]]

			renameScopeScripts(moduleFolder, function(scope: string)
				return `Ume || {scope} - {moduleFolder.Name}`
			end)

			--[[ Admin Panel ]]

			for toolName: string, toolFolder: Instance in pairs(getAdminPanelFolders(moduleFolder)) do
				renameScopeScripts(toolFolder, function(scope: string)
					return `Ume || {scope} - {moduleFolder.Name}_{toolName}`
				end)
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Store All Modules

--[[
	Stores module, settings, and AdminPanel tool scripts for the loading passes.
]]
function _task.StoreAllModules(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	for _: number, dirFolder: Folder in ipairs(I._dirs.Modules:GetChildren()) do
		for _index: number, moduleFolder: Folder in ipairs(dirFolder:GetChildren()) do
			--[[ Name ]]

			local originalName: string, truncatedName: string = resolveModuleName(moduleFolder, I)

			--[[ Modules ]]

			--- @type { [string]: ModuleScript }
			local scopeScripts = storeScopeScripts(moduleFolder, originalName, truncatedName, I.Env.Key)
			storedModules[truncatedName] = scopeScripts

			--[[ Settings ]]

			for _childIndex: number, elem: Instance in ipairs(moduleFolder:GetChildren()) do
				--[[ Checks ]]

				-- Skip instances that are not ModuleScripts
				if not elem:IsA("ModuleScript") then
					continue
				end

				--[[ Saving ]]

				-- Store a settings module
				if string.lower(elem.Name) == "settings" then
					storedSettings[truncatedName] = elem
				end
			end

			--[[ Admin Panel ]]

			for toolName: string, toolFolder: Instance in pairs(getAdminPanelFolders(moduleFolder)) do
				local toolScripts --- @type { [string]: ModuleScript }
				local hasTool: boolean
				toolScripts, hasTool = storeScopeScripts(toolFolder, originalName, truncatedName, I.Env.Key)

				-- Skip a tool folder without a scope script
				if not hasTool then
					continue
				end

				-- Create the tool bucket on the first visit
				if not storedAdminPanel[toolName] then
					storedAdminPanel[toolName] = {}
				end

				storedAdminPanel[toolName][truncatedName] = toolScripts
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Run

--[[
	Sorts modules, runs their init and start functions, and records execution time.
]]
function _task.Run(umeInstance)
	--- @type Ume
	local I = umeInstance

	if I.Started then
		return
	end

	--%%%%%%%%%%%%%%%%%%%%

	warnIfDuplicated(I)

	--- @type { Folder }
	local sortedModules = getSortedModules(I)

	--[[ State ]]

	-- List of all module functions that have execution.
	I.Modules = {
		["Initialized"] = false,
		["Started"] = false,
		["Initialized_CommandBar"] = false,
		["Started_CommandBar"] = false,
		["Initialized_Dashboard"] = false,
		["Started_Dashboard"] = false,
	} --- @type { [string]: boolean }

	-- Table containing settings for all modules.
	I.Settings = {} --- @type { [string]: table }

	--[[ Running ]]

	--- @type { Ume_ModuleExecEntry }
	local executionTime = {}

	loopThroughModules(I, "_init", "Initialized", sortedModules, executionTime, storedModules, nil, true)
	loopThroughModules(I, "_start", "Started", sortedModules, executionTime, storedModules, nil, true)

	--[[ Admin Panel ]]

	for _: number, toolName: string in ipairs(ADMIN_PANEL_TOOLS) do
		local toolScripts = storedAdminPanel[toolName] or {} --- @type { [string]: { [string]: ModuleScript } }

		loopThroughModules(I, "_init", `Initialized_{toolName}`, sortedModules, executionTime, toolScripts, toolName, false)
		loopThroughModules(I, "_start", `Started_{toolName}`, sortedModules, executionTime, toolScripts, toolName, false)
	end

	--[[ Execution Time ]]

	reportExecutionTime(I, executionTime)
end

return _task
