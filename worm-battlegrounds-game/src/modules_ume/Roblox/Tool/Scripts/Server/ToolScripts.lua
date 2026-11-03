--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Tool"

--- @type Tool_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local toolsData: Folder = I.Dirs.GlobalData.Tool

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local toolScripts = {} --- @type { [string]: Tool_ToolModule_Server }
local allScriptNames = {} --- @type { string }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Is Dead

--[[
	Returns whether the player's character has a Humanoid with no health left.
]]
--- @return boolean
local function isDead(player: Player)
	--[[ Finding ]]

	local character: Model? = player.Character
	local humanoid: Humanoid? = character and character:FindFirstChildOfClass("Humanoid")

	--[[ Returning ]]

	return humanoid ~= nil and humanoid.Health <= 0
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

--- @class Tool_Server_ToolScripts
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerScripts()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Register Scripts

--[[
	Requires all existing environmental tool scripts, initializes and saves them.
]]
function Module._registerScripts()
	--[[ Registering Scripts ]]

	for _, toolDataFolder: Folder in ipairs(toolsData:GetChildren()) do
		--[[ Getting Any Script ]]

		local toolScript: ModuleScript? = toolDataFolder:FindFirstChild("Client") or toolDataFolder:FindFirstChild("Server")

		-- List folders that have a script on either side
		if toolScript then
			table.insert(allScriptNames, toolDataFolder.Name)
		end

		--[[ Getting Environmental Script ]]

		local envScript: ModuleScript? = toolDataFolder:FindFirstChild(I.Env.Key)

		-- Skip folders without a script for this side
		if not envScript then
			continue
		end

		--[[ Require Module ]]

		local success: boolean
		local result: any | string?
		success, result = pcall(require, envScript)

		-- Skip scripts that fail to load
		if not success then
			warn(`[{_localName}::{script.Name}]: Error when loading the ({toolDataFolder.Name}\\{envScript.Name}) module! -`, envScript)
			warn(result)
			continue
		end

		--[[ Initialization ]]

		--- @type Tool_ToolModule_Server
		local required = result

		-- Run the script's Init when it has one
		if required["Init"] then
			required.Init()
		end

		--[[ Registering ]]

		toolScripts[toolDataFolder.Name] = required
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set Scripts

--[[
	**SERVER** |
	Set scripts for the tool.
]]
--- @param scriptsNames { string }?
--- @return boolean
function Module.SetScripts(player: Player, toolUUID: string, scriptsNames)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Tool"]

	--[[ Getting Tool ]]

	local tool: Tool? = moduleSessionData.CreatedTools[toolUUID]
	if not tool then
		return false
	end

	--[[ Updating Attribute ]]

	local scriptsString: string? = scriptsNames and type(scriptsNames) == "table" and table.concat(scriptsNames, ", ")

	-- Keep the current scripts when no list is given
	if scriptsString then
		tool:SetAttribute("Tool_Scripts", scriptsString)
	end

	--[[ Updating ]]

	return Module._updateToolScripts(player, toolUUID)
end

--%%%%%%%%%%%%%%%%%%%% Add Scripts

--[[
	**SERVER** |
	Adds scripts to the tool.
]]
--- @param scriptsNames { string }
--- @return boolean
function Module.AddScripts(player: Player, toolUUID: string, scriptsNames)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Tool"]

	--[[ Getting Tool ]]

	local tool: Tool? = moduleSessionData.CreatedTools[toolUUID]
	if not tool then
		return false
	end

	--[[ Getting Scripts ]]

	--- @type { string }
	local currentScripts = Module.GetScripts(player, toolUUID)

	for _, scriptName: string in ipairs(scriptsNames) do
		-- Skip scripts the tool already has
		if table.find(currentScripts, scriptName) then
			continue
		end

		table.insert(currentScripts, scriptName)
	end

	--[[ Updating ]]

	return Module.SetScripts(player, toolUUID, currentScripts)
end

--%%%%%%%%%%%%%%%%%%%% Remove Scripts

--[[
	**SERVER** |
	Removes scripts from the tool.
]]
--- @param scriptsNames { string }
--- @return boolean
function Module.RemoveScripts(player: Player, toolUUID: string, scriptsNames)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Tool"]

	--[[ Getting Tool ]]

	local tool: Tool? = moduleSessionData.CreatedTools[toolUUID]
	if not tool then
		return false
	end

	--[[ Getting Scripts ]]

	--- @type { string }
	local currentScripts = Module.GetScripts(player, toolUUID)

	for _, scriptName: string in ipairs(scriptsNames) do
		local existingId: number? = table.find(currentScripts, scriptName)

		-- Remove scripts the tool has
		if existingId then
			table.remove(currentScripts, existingId)
		end
	end

	--[[ Updating ]]

	return Module.SetScripts(player, toolUUID, currentScripts)
end

--%%%%%%%%%%%%%%%%%%%% Remove All Scripts

--[[
	**SERVER** |
	Removes all scripts from the tool.
]]
--- @return boolean
function Module.RemoveAllScripts(player: Player, toolUUID: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Tool"]

	--[[ Getting Tool ]]

	local tool: Tool? = moduleSessionData.CreatedTools[toolUUID]
	if not tool then
		return false
	end

	--[[ Updating Attribute ]]

	tool:SetAttribute("Tool_Scripts", nil)

	--[[ Updating ]]

	Module._updateToolScripts(player, toolUUID)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Clear Connections For Tool

--[[
	Disconnects every script of the tool and the tool's own connections, and clears its scripts dictionary.
]]
function Module.ClearConnectionsForTool(player: Player, toolUUID: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Tool"]

	--[[ Getting Tool ]]

	local tool: Tool? = moduleSessionData.CreatedTools[toolUUID]
	if not tool then
		return
	end

	--[[ Disconnecting ]]

	-- Copy names first so disconnecting can change the table
	local connectedNames = {} --- @type { string }

	for connectedName: string in pairs(moduleSessionData.ToolsConnections[toolUUID]) do
		table.insert(connectedNames, connectedName)
	end

	for _, connectedName: string in ipairs(connectedNames) do
		Module._disconnectScript(player, tool, toolUUID, connectedName)
	end

	--[[ Updating Dictionaries ]]

	I.AdminPanel_CommandBar.SetDictionary(`Tool_ToolScripts-{player.Name}-{toolUUID}`, nil)
end

--%%%%%%%%%%%%%%%%%%%% Update Tool Scripts

--[[
	Connects new and disconnects old scripts from the given tool based on its attributes.
]]
--- @return boolean
function Module._updateToolScripts(player: Player, toolUUID: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Tool"]

	--[[ Getting Tool ]]

	local tool: Tool? = moduleSessionData.CreatedTools[toolUUID]
	if not tool then
		return false
	end

	--[[ Scripts ]]

	local scriptsString: string? = tool:GetAttribute("Tool_Scripts")
	local scriptsNames = scriptsString and type(scriptsString) == "string" and scriptsString:split(", ") or {} --- @type { string }
	local toolConnections = moduleSessionData.ToolsConnections[toolUUID] --- @type { [string]: { [string]: RBXScriptConnection } }

	--%%%%%%%%%%%%%%%%%%%% Removing Scripts

	local scriptsToRemove = {} --- @type { string }

	for scriptName: string in pairs(toolConnections) do
		-- Skip listed scripts and the tool's own connections
		if table.find(scriptsNames, scriptName) or scriptName == "__ume" then
			continue
		end

		table.insert(scriptsToRemove, scriptName)
	end

	for _, scriptName: string in ipairs(scriptsToRemove) do
		Module._disconnectScript(player, tool, toolUUID, scriptName)
	end

	--%%%%%%%%%%%%%%%%%%%% Connecting Scripts

	for _, scriptName: string in ipairs(scriptsNames) do
		--[[ Checks ]]

		-- Skip scripts that are already connected
		if toolConnections[scriptName] then
			continue
		end

		--- @type Tool_ToolModule_Server?
		local toolScript = toolScripts[scriptName]

		-- Skip scripts without a server module
		if not toolScript then
			continue
		end

		--[[ Script State ]]

		local connections = {} --- @type { [string]: RBXScriptConnection }
		local isEquipped: boolean = false
		local isActivated: boolean = false
		local lastActivated: number = 0

		toolConnections[scriptName] = connections

		--%%%%%%%%%%%%%%%%%%%% Equip

		--[[
			Runs the script's Equipped while the player is alive.
		]]
		local function equip()
			--[[ Checks ]]

			-- Skip while the player is dead
			if isDead(player) then
				return
			end

			-- Skip when the script is already equipped
			if isEquipped then
				return
			end

			--[[ Equipping ]]

			if toolScript["Equipped"] then
				toolScript.Equipped(player, tool, toolUUID)
			end

			isEquipped = true
		end

		--[[ Connecting ]]

		-- Equipped
		connections["Equipped"] = tool.Equipped:Connect(equip)

		-- Unequipped
		connections["Unequipped"] = tool.Unequipped:Connect(function()
			--[[ Deactivating ]]

			if isActivated then
				isActivated = false

				if toolScript["Deactivated"] then
					toolScript.Deactivated(player, tool, toolUUID)
				end
			end

			--[[ Unequipping ]]

			if toolScript["Unequipped"] and isEquipped then
				toolScript.Unequipped(player, tool, toolUUID)
			end

			isEquipped = false

			--[[ Alive Check ]]

			-- Disconnect this script when the player died
			if isDead(player) then
				Module._disconnectScript(player, tool, toolUUID, scriptName)
			end
		end)

		-- Activated
		connections["Activated"] = tool.Activated:Connect(function()
			--[[ Checks ]]

			-- Skip while the player is dead
			if isDead(player) then
				return
			end

			-- Skip when the script is already activated
			if isActivated then
				return
			end

			local now: number = os.clock()

			-- Skip activations that come sooner than the script's cooldown
			if now - lastActivated < (toolScript.Cooldown or _settings.DEFAULT_ACTIVATION_COOLDOWN) then
				return
			end

			--[[ Activating ]]

			isActivated = true
			lastActivated = now

			if toolScript["Activated"] then
				toolScript.Activated(player, tool, toolUUID)
			end
		end)

		-- Deactivated
		connections["Deactivated"] = tool.Deactivated:Connect(function()
			--[[ Checks ]]

			-- Skip when the script isn't activated
			if not isActivated then
				return
			end

			--[[ Deactivating ]]

			isActivated = false

			if toolScript["Deactivated"] then
				toolScript.Deactivated(player, tool, toolUUID)
			end
		end)

		--[[ Equipping ]]

		-- Run Equipped for a script added to a tool already in hand
		if tool.Parent == player.Character then
			equip()
		end
	end

	--[[ Updating Dictionaries ]]

	I.AdminPanel_CommandBar.SetDictionary(`Tool_ToolScripts-{player.Name}-{toolUUID}`, scriptsNames, 255, { BoundTo = player.UserId })

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Disconnect Script

--[[
	Disconnects one script (or the tool's own `__ume` connections) from the tool and runs the script's Destroy.
]]
function Module._disconnectScript(player: Player, tool: Tool, toolUUID: string, scriptName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Tool"]

	--- @type { [string]: RBXScriptConnection }?
	local connections = moduleSessionData.ToolsConnections[toolUUID][scriptName]
	if not connections then
		return
	end

	--[[ Disconnecting ]]

	for _connectionName: string, connection: RBXScriptConnection in pairs(connections) do
		connection:Disconnect()
	end

	moduleSessionData.ToolsConnections[toolUUID][scriptName] = nil

	--[[ Destroy Function ]]

	-- Run the script's Destroy when it has one
	if toolScripts[scriptName] and toolScripts[scriptName]["Destroy"] then
		toolScripts[scriptName].Destroy(player, tool, toolUUID)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Scripts

--[[
	**SERVER** |
	Returns table containing all scripts assigned to the tool.
]]
--- @return { string }?
function Module.GetScripts(player: Player, toolUUID: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Tool"]

	--[[ Getting Tool ]]

	local tool: Tool? = moduleSessionData.CreatedTools[toolUUID]
	if not tool then
		return nil
	end

	--[[ Getting Scripts ]]

	local scriptsString: string? = tool:GetAttribute("Tool_Scripts")
	local scriptsNames = scriptsString and type(scriptsString) == "string" and scriptsString:split(", ") or {} --- @type { string }

	-- Drop the single empty name an empty list splits into
	if #scriptsNames == 1 and scriptsNames[1] == "" then
		scriptsNames[1] = nil
	end

	--[[ Returning ]]

	return scriptsNames
end

--%%%%%%%%%%%%%%%%%%%% Get All Scripts

--[[
	**SERVER** |
	Returns every tool UUID of the player with that tool's scripts.
]]
--- @return { [string]: { string } }?
function Module.GetAllScripts(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Tool"]

	--[[ Getting ]]

	--- @type { [string]: { string } }
	local toReturn = {}

	for toolUUID: string, _toolModel: Tool in pairs(moduleSessionData.CreatedTools) do
		toReturn[toolUUID] = Module.GetScripts(player, toolUUID)
	end

	--[[ Returning ]]

	return toReturn
end

--%%%%%%%%%%%%%%%%%%%% Get All Script Names

--[[
	Returns the names of every tool script folder (filled by Init).
]]
--- @return { string }
function Module.GetAllScriptNames()
	return allScriptNames
end

return Module
