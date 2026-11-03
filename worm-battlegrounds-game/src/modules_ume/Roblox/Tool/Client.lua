--[[
    Created By:     Nari 
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Tool"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local toolsData: Folder = I.Dirs.GlobalData.Tool

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- All required tool scripts.
local toolScripts = {} --- @type { [string]: table }

-- Table for storing created tools to avoid registering them multiple times.
local createdTools = {} --- @type { Tool }

--[[ Connections ]]

local backpackConnections = {} --- @type { RBXScriptConnection }
local characterConnections = {} --- @type { RBXScriptConnection }
local localBackpack: Backpack? = nil

--- @type table
local toolsConnections = {
	--[[
		["ToolUUID"] = {
			["ScriptName"] = {
				["ConnectionName"]: RBXScriptConnection,
			},
		},
	]]
}

--- @type { [string]: RBXScriptConnection }
local toolsAttributeConnections = {}

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
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Tool_Added", { { Type = "Instance", ClassName = "Tool" }, "string" })
	I.Topic.Register("Tool_Removed", { { Type = "Instance", ClassName = "Tool" }, "string" })

	I.Topic.Register("Tool_Equipped", { { Type = "Instance", ClassName = "Tool" }, "string" })
	I.Topic.Register("Tool_Unequipped", { { Type = "Instance", ClassName = "Tool" }, "string" })

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnCharacterAdded(I.Priority.Default, Module._connectCharacter)

	Module._registerScripts()
	Module._connectBackpack()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Register Scripts

--[[
   Requires all existing environmental tool scripts initializes and saves them.
]]
function Module._registerScripts()
	for _, toolDataFolder: Folder in ipairs(toolsData:GetChildren()) do
		--[[ Getting Environmental Script ]]

		local envScript: ModuleScript = toolDataFolder:FindFirstChild(I.Env.Key)
		if not envScript then
			continue
		end

		--[[ Require Module ]]

		--- @param required Tool_ToolModule_Client | string
		local reqSuccess: boolean, required = pcall(require, envScript)
		if not reqSuccess then
			warn(`[{_localName}::{script.Name}]: Error when loading the ({toolDataFolder.Name}\\{envScript.Name}) module! -`, envScript)
			warn(required)
			continue
		end

		--[[ Initialization ]]

		if required["Init"] then
			required.Init()
		end

		--[[ Registering ]]

		toolScripts[toolDataFolder.Name] = required
	end
end

--%%%%%%%%%%%%%%%%%%%% Connect Backpack

--[[
    Tracks when a child is added or removed from the backpack, also tracks when a new backpack is added. 
]]
function Module._connectBackpack()
	local function bindBackpack(backpack: Instance)
		--[[ Checks ]]

		if not backpack:IsA("Backpack") then
			return
		end

		localBackpack = backpack

		--[[ Clearing Previous Connections ]]

		for _, connection: RBXScriptConnection in ipairs(backpackConnections) do
			connection:Disconnect()
		end
		table.clear(backpackConnections)

		--[[ Connections ]]

		local addedConnection: RBXScriptConnection = backpack.ChildAdded:Connect(Module._added)
		table.insert(backpackConnections, addedConnection)

		-- Adding existing (after ChildAdded so new tools use the same path; duplicates guarded in _added)
		for _, tool: Tool in ipairs(backpack:GetChildren()) do
			Module._added(tool)
		end

		-- Adding equipped
		local character: Model? = I.Env.LocalPlayer.Character
		local equipped: Tool? = character and character:FindFirstChildOfClass("Tool")
		if equipped then
			Module._added(equipped)
		end
	end

	I.Env.LocalPlayer.ChildAdded:Connect(bindBackpack)

	local existingBackpack: Backpack? = I.Env.LocalPlayer:FindFirstChildOfClass("Backpack")
	if existingBackpack then
		bindBackpack(existingBackpack)
	end
end

--%%%%%%%%%%%%%%%%%%%% Connect Character

--[[
	Creates connections for newly added character to track new items and health change.
]]
function Module._connectCharacter(character: Model)
	-- Clearing Previous
	for connectionName: string, connection: RBXScriptConnection in pairs(characterConnections) do
		connection:Disconnect()
		characterConnections[connectionName] = nil
	end

	-- New child connection
	characterConnections["ChildAdded"] = character.ChildAdded:Connect(Module._added)

	-- Health change connection
	task.spawn(function()
		local hum: Humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid", 5)
		if hum then
			characterConnections["Health"] = hum.HealthChanged:Connect(function()
				if hum.Health <= 0 then
					hum:UnequipTools()
				end
			end)
		end
	end)

	-- Equipped connection
	characterConnections["ToolEquipped"] = character.ChildAdded:Connect(function(child: Tool | any)
		--[[ Getting Humanoid ]]

		local hum: Humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid", 5)
		if not hum then
			return
		end

		--[[ Checks ]]

		-- Not a tool
		if not table.find(createdTools, child) or not child:IsA("Tool") then
			return
		end

		-- Skip if player is dead
		if hum.Health <= 0 then
			return
		end

		--[[ Publishing ]]

		I.Topic.Publish("Tool_Equipped", child, child:GetAttribute("Tool_ClientUUID"))
	end)

	-- Unequipped connection
	characterConnections["ToolUnequipped"] = character.ChildRemoved:Connect(function(child: Tool | any)
		--[[ Getting Humanoid ]]

		local hum: Humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid", 5)
		if not hum then
			return
		end

		--[[ Checks ]]

		-- Not a tool
		if not table.find(createdTools, child) or not child:IsA("Tool") then
			return
		end

		--[[ Publishing ]]

		I.Topic.Publish("Tool_Unequipped", child, child:GetAttribute("Tool_ClientUUID"))
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Added

--[[
    Registers new tool and initializes its scripts. 
]]
function Module._added(tool: Tool)
	--[[ Checks ]]

	-- Not a tool or already added
	if table.find(createdTools, tool) or not tool:IsA("Tool") then
		return
	end

	local character: Model = I.Env.LocalPlayer.Character
	local humanoid: Humanoid = character and character:FindFirstChildOfClass("Humanoid")

	-- Skip while the player is dead
	if humanoid and humanoid.Health <= 0 then
		humanoid:UnequipTools()
		return
	end

	-- Tool is inactive/destroying
	if tool:GetAttribute(`Tool_Inactive_{I.Env.Key}`) then
		return
	end

	--[[ Saving ]]

	-- Save to avoid duplicated connections
	table.insert(createdTools, tool)

	--[[ Getting UUID ]]

	-- Use the server's UUID, or a random one for a tool the server didn't create
	local toolUUID: string = tool:GetAttribute("Tool_ServerUUID") or `{I.Obfuscate.GetRandomString(4)}-{I.Obfuscate.GetRandomString(4)}-{I.Obfuscate.GetRandomString(4)}`
	tool:SetAttribute("Tool_ClientUUID", toolUUID)

	--[[ Scripts Update ]]

	Module._updateToolScripts(tool, toolUUID)

	toolsAttributeConnections[toolUUID] = tool:GetAttributeChangedSignal("Tool_Scripts"):Connect(function()
		Module._updateToolScripts(tool, toolUUID)
	end)

	--[[ Publishing ]]

	I.Topic.Publish("Tool_Added", tool, toolUUID)
end

--%%%%%%%%%%%%%%%%%%%% Removed

--[[
    Clears all connections for a tool when it's removed. 
]]
function Module._removed(tool: Tool, toolUUID: string)
	--[[ Removing Stored ]]

	local tableIndex: number = table.find(createdTools, tool)
	if tableIndex then
		table.remove(createdTools, tableIndex)
	end

	--[[ Clearing Connection ]]

	Module._clearConnectionsForTool(tool, toolUUID)

	--[[ Publishing ]]

	I.Topic.Publish("Tool_Removed", tool, toolUUID)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Connections

--%%%%%%%%%%%%%%%%%%%% Update Tool Scripts

--[[
	Connects new and disconnects old scripts from the given tool based on its attributes.
]]
function Module._updateToolScripts(tool: Tool, toolUUID: string)
	--[[ Scripts ]]

	local scriptsString: string? = tool:GetAttribute("Tool_Scripts")
	local scriptsNames = scriptsString and type(scriptsString) == "string" and scriptsString:split(", ") or {} --- @type { string }

	--[[ Tool Scripts Table ]]

	-- Connect the tool's own connections once
	if not toolsConnections[toolUUID] then
		toolsConnections[toolUUID] = {
			["__ume"] = {
				Equipped = tool.Equipped:Connect(function()
					--[[ Alive Check ]]

					local character: Model = I.Env.LocalPlayer.Character
					local humanoid: Humanoid = character and character:FindFirstChildOfClass("Humanoid")

					-- Unequip tools while the player is dead
					if humanoid and humanoid.Health <= 0 then
						humanoid:UnequipTools()
					end
				end),
				Unequipped = tool.Unequipped:Connect(function()
					--[[ Alive Check ]]

					local character: Model = I.Env.LocalPlayer.Character
					local humanoid: Humanoid = character and character:FindFirstChildOfClass("Humanoid")

					-- Remove the tool when the player died
					if humanoid and humanoid.Health <= 0 then
						tool:SetAttribute(`Tool_Inactive_{I.Env.Key}`, true)
						Module._removed(tool, toolUUID)
					end
				end),
				ParentChanged = tool.AncestryChanged:Connect(function()
					--[[ Checks ]]

					local toolParent: Instance? = tool.Parent

					-- Skip while the tool itself is in the backpack or the character
					if toolParent == localBackpack or toolParent == I.Env.LocalPlayer.Character then
						return
					end

					--[[ Removing ]]

					Module._removed(tool, toolUUID)
				end),
			},
		}
	end

	--%%%%%%%%%%%%%%%%%%%% Removing Scripts

	local scriptsToRemove = {} --- @type { string }

	for scriptName: string in pairs(toolsConnections[toolUUID]) do
		-- Collect scripts no longer listed, except the tool's own connections
		if not table.find(scriptsNames, scriptName) and scriptName ~= "__ume" then
			table.insert(scriptsToRemove, scriptName)
		end
	end

	for _, scriptName: string in ipairs(scriptsToRemove) do
		--- @type { [string]: RBXScriptConnection }?
		local connections = toolsConnections[toolUUID][scriptName]

		-- Skip scripts without connections
		if not connections then
			continue
		end

		--[[ Destroy Function ]]

		-- Run the script's Destroy when it has one
		if toolScripts[scriptName] and toolScripts[scriptName]["Destroy"] then
			toolScripts[scriptName].Destroy(tool, toolUUID)
		end

		--[[ Disconnecting ]]

		local connectionNames = {} --- @type { string }
		for connectionName: string in pairs(connections) do
			table.insert(connectionNames, connectionName)
		end
		for _, connectionName: string in ipairs(connectionNames) do
			local connection: RBXScriptConnection? = connections[connectionName]
			if connection then
				connection:Disconnect()
			end
			connections[connectionName] = nil
		end

		-- All connections cleared -> remove script table
		toolsConnections[toolUUID][scriptName] = nil
	end

	--%%%%%%%%%%%%%%%%%%%% Connecting Scripts

	for _, scriptName: string in ipairs(scriptsNames) do
		-- Continue if already connected
		if toolsConnections[toolUUID][scriptName] then
			continue
		end

		--[[ Getting Script ]]

		--- @type Tool_ToolModule_Client?
		local toolScript = toolScripts[scriptName]

		-- Skip scripts without a client module
		if not toolScript then
			continue
		end

		--[[ Script Connections table ]]

		if not toolsConnections[toolUUID][scriptName] then
			toolsConnections[toolUUID][scriptName] = {}
		end

		--%%%%%%%%%%%%%%%%%%%% Equip

		--[[
			Runs the script's Equipped while the local player is alive.
		]]
		local function equip()
			--[[ Checks ]]

			local character: Model? = I.Env.LocalPlayer.Character
			local humanoid: Humanoid? = character and character:FindFirstChildOfClass("Humanoid")

			-- Skip while the player is dead
			if humanoid and humanoid.Health <= 0 then
				return
			end

			-- Skip when the script is already equipped
			if tool:GetAttribute(`Tool_Equipped_{scriptName}_{I.Env.Key}`) then
				return
			end

			--[[ Equipping ]]

			if toolScript["Equipped"] then
				toolScript.Equipped(tool, toolUUID)
			end

			tool:SetAttribute(`Tool_Equipped_{scriptName}_{I.Env.Key}`, true)
		end

		--[[ Connecting ]]

		-- Equipped
		toolsConnections[toolUUID][scriptName]["Equipped"] = tool.Equipped:Connect(equip)

		-- Unequipped
		toolsConnections[toolUUID][scriptName]["Unequipped"] = tool.Unequipped:Connect(function()
			--[[ Deactivating ]]

			if tool:GetAttribute(`Tool_Activated_{scriptName}_{I.Env.Key}`) then
				tool:SetAttribute(`Tool_Activated_{scriptName}_{I.Env.Key}`, false)

				if toolScript["Deactivated"] then
					toolScript.Deactivated(tool, toolUUID)
				end
			end

			--[[ Unequipping ]]

			if toolScript["Unequipped"] and tool:GetAttribute(`Tool_Equipped_{scriptName}_{I.Env.Key}`) then
				toolScript.Unequipped(tool, toolUUID)
			end

			tool:SetAttribute(`Tool_Equipped_{scriptName}_{I.Env.Key}`, false)
		end)

		-- Activated
		toolsConnections[toolUUID][scriptName]["Activated"] = tool.Activated:Connect(function()
			--[[ Alive Check ]]

			local character: Model = I.Env.LocalPlayer.Character
			local humanoid: Humanoid = character and character:FindFirstChildOfClass("Humanoid")

			-- Skip while the player is dead
			if humanoid and humanoid.Health <= 0 then
				return
			end

			--[[ Activated Check ]]

			-- Skip when the script is already activated
			if tool:GetAttribute(`Tool_Activated_{scriptName}_{I.Env.Key}`) then
				return
			end
			tool:SetAttribute(`Tool_Activated_{scriptName}_{I.Env.Key}`, true)

			--[[ Activating ]]

			if toolScript["Activated"] then
				toolScript.Activated(tool, toolUUID)
			end
		end)

		-- Deactivated
		toolsConnections[toolUUID][scriptName]["Deactivated"] = tool.Deactivated:Connect(function()
			--[[ Activated Check ]]

			-- Skip when the script isn't activated
			if not tool:GetAttribute(`Tool_Activated_{scriptName}_{I.Env.Key}`) then
				return
			end
			tool:SetAttribute(`Tool_Activated_{scriptName}_{I.Env.Key}`, false)

			--[[ Deactivating ]]

			if toolScript["Deactivated"] then
				toolScript.Deactivated(tool, toolUUID)
			end
		end)

		--[[ Equipping ]]

		-- Run Equipped for a script added to a tool already in hand
		if tool.Parent == I.Env.LocalPlayer.Character then
			equip()
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Clear Connections For Tool

--[[
    Clears all connections for a tool by its UUID.
]]
function Module._clearConnectionsForTool(tool, toolUUID: string)
	-- Attribute Connection
	if toolsAttributeConnections[toolUUID] then
		toolsAttributeConnections[toolUUID]:Disconnect()
		toolsAttributeConnections[toolUUID] = nil
	end

	-- Scripts Connections
	if toolsConnections[toolUUID] then
		local scriptNames = {} --- @type { string }
		for scriptName: string in pairs(toolsConnections[toolUUID]) do
			table.insert(scriptNames, scriptName)
		end

		for _, scriptName: string in ipairs(scriptNames) do
			local connections = toolsConnections[toolUUID][scriptName]
			if connections then
				local connectionNames = {} --- @type { string }
				for connectionName: string in pairs(connections) do
					table.insert(connectionNames, connectionName)
				end
				for _, connectionName: string in ipairs(connectionNames) do
					local connection: RBXScriptConnection = connections[connectionName]
					if connection then
						connection:Disconnect()
					end
					connections[connectionName] = nil
				end
			end

			--[[ Equipped ]]

			local isEquipped = tool:GetAttribute(`Tool_Equipped_{scriptName}_{I.Env.Key}`)
			if isEquipped then
				if toolScripts[scriptName] and toolScripts[scriptName]["Unequipped"] then
					toolScripts[scriptName].Unequipped(tool, toolUUID)
				end
			end

			--[[ Clearing Attributes ]]

			tool:SetAttribute(`Tool_Equipped_{scriptName}_{I.Env.Key}`, nil)
			tool:SetAttribute(`Tool_Activated_{scriptName}_{I.Env.Key}`, nil)

			--[[ Destroy Function ]]

			if toolScripts[scriptName] and toolScripts[scriptName]["Destroy"] then
				toolScripts[scriptName].Destroy(tool, toolUUID)
			end

			-- All connections cleared -> remove script table
			toolsConnections[toolUUID][scriptName] = nil
		end

		tool:SetAttribute(`Tool_ClientUUID`, nil)
		toolsConnections[toolUUID] = nil
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
