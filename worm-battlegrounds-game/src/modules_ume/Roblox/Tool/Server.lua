--[[
    Created By:     Nari 
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Tool"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local StarterPack = I.S.StarterPack

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local ToolScripts = require(_scripts:FindFirstChild("Server"):FindFirstChild("ToolScripts")) --- @type Tool_Server_ToolScripts

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Saved tool models for quick access.
local toolsModels = {} --- @type { [string]: Model }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Tools Folder

--[[
    Finds or creates folder for storing all tools.
]]
--- @return Folder
local function getToolsFolder()
	return I.Dirs.UmeServer:FindFirstChild("Tools") or I.Create("Configuration")({
		Name = "Tools",
		Parent = I.Dirs.UmeServer,
	})
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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	----------- DATA -----------
	----------------------------

	--- @type Player_SessionData
	local _st = I.Player.SessionTemplate
	_st["Tool"] = {
		CurrentlyEquipped = nil,

		CreatedTools = {}, --- @type { [string]: Tool }
		ToolsData = {}, --- @type { [string]: table }

		--- @type table
		ToolsConnections = {
			--[[
				["ToolUUID"] = {
					["ScriptName"] = {
						["ConnectionName"]: RBXScriptConnection,
					},
				},
			]]
		},
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	--[[ Setup ]]

	Module._moveFromStarterPack()

	Module._registerTools()
	ToolScripts.Init()

	--[[ Player ]]

	I.G_Player.OnCharacterRemoving(I.Priority.Default, Module.RemoveAll)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Tool_Added", { "Player", { Type = "Instance", ClassName = "Tool" }, "string" })
	I.Topic.Register("Tool_Removed", { "Player", { Type = "Instance", ClassName = "Tool" }, "string" })

	I.Topic.Register("Tool_Equipped", { "Player", { Type = "Instance", ClassName = "Tool" }, "string" })
	I.Topic.Register("Tool_Unequipped", { "Player", { Type = "Instance", ClassName = "Tool" }, "string" })

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Tool = {

		--[[ Control ]]

		Add = Module.Add,
		Remove = Module.Remove,
		RemoveAll = Module.RemoveAll,

		--[[ Scripts Control ]]

		SetScripts = ToolScripts.SetScripts,
		AddScripts = ToolScripts.AddScripts,
		RemoveScripts = ToolScripts.RemoveScripts,
		RemoveAllScripts = ToolScripts.RemoveAllScripts,

		GetScripts = ToolScripts.GetScripts,

		--[[ Methods ]]

		GetEquipped = Module.GetEquipped,
		Get = Module.Get,
		GetAll = Module.GetAll,
		GetAllScripts = ToolScripts.GetAllScripts,

		Has = Module.Has,

		--[[ Private ]]

		_toolsModels = toolsModels,
		_allScriptNames = ToolScripts.GetAllScriptNames(),
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Move From StarterPack

--[[
	Moves all Tools from `StarterPack` to storage folder.
]]
function Module._moveFromStarterPack()
	local toolsFolder: Folder = getToolsFolder()

	--%%%%%%%%%%%%%%%%%%%% Move Tools From Folder

	--[[
		Moves all tools to the `StarterPack` from the given `dir`. 
	]]
	local function moveToolsFromFolder(dir: Folder)
		for _, elem: Instance in ipairs(dir:GetChildren()) do
			if elem:IsA("Folder") then
				moveToolsFromFolder(elem)
				continue
			end

			if elem:IsA("Tool") then
				elem.Parent = toolsFolder
				continue
			end

			elem:Destroy()
		end
	end

	--[[ Moving ]]

	moveToolsFromFolder(StarterPack)
	StarterPack:ClearAllChildren()
end

--%%%%%%%%%%%%%%%%%%%% Register Tools

--[[
	Caches all tools that are in the storage folder. 
]]
function Module._registerTools()
	for _, tool: Tool in ipairs(getToolsFolder():GetChildren()) do
		--[[ Checks ]]

		if not tool:IsA("Tool") then
			warn(`[{_localName}::{script.Name}]: ({tool.Name}) is not a Tool! -`, tool)
			continue
		end

		if toolsModels[tool.Name] then
			warn(`[{_localName}::{script.Name}]: Tool ({tool.Name}) is already registered! -`, tool)
			continue
		end

		--[[ Registering ]]

		toolsModels[tool.Name] = tool
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Add

--[[
	**SERVER** |
	Creates new tool or gives the passed one to the player.
]]
--- @param scriptsNames { string }?
--- @return string?
function Module.Add(player: Player, newTool: string | Tool, scriptsNames, setUUID: string?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Tool"]

	--[[ Getting Tool Model ]]

	local tool: Tool?

	if type(newTool) == "string" then
		tool = toolsModels[newTool] and toolsModels[newTool]:Clone()
	elseif typeof(newTool) == "Instance" and newTool:IsA("Tool") then
		tool = newTool
	end

	-- Check if the tool model exists
	if not tool then
		warn(`[{_localName}::{script.Name}]: ({newTool}) is not a valid Tool!`)
		return nil
	end

	--[[ Generating UUID ]]

	local toolUUID: string = type(setUUID) == "string" and setUUID or `{I.Obfuscate.GetRandomString(4)}-{I.Obfuscate.GetRandomString(4)}-{I.Obfuscate.GetRandomString(4)}`
	tool:SetAttribute("Tool_ServerUUID", toolUUID)

	--[[ Exist Check ]]

	-- Check if the player already has a tool with that UUID
	if moduleSessionData.CreatedTools[toolUUID] then
		return nil
	end

	--%%%%%%%%%%%%%%%%%%%%

	--[[ Creating Storage Tables ]]

	moduleSessionData.CreatedTools[toolUUID] = tool
	moduleSessionData.ToolsData[toolUUID] = {}
	moduleSessionData.ToolsConnections[toolUUID] = {}

	--[[ Connections ]]

	Module._connectTool(player, tool, toolUUID)

	--[[ Scripts ]]

	ToolScripts.SetScripts(player, toolUUID, scriptsNames)

	--[[ Adding/Saving ]]

	tool.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	tool.CanBeDropped = false
	tool.Parent = player:FindFirstChildOfClass("Backpack")

	-- Updating dictionaries
	I.AdminPanel_CommandBar.UpdateDictionary(`Tool_UUIDs-{player.Name}`, { toolUUID }, nil, 255, { BoundTo = player.UserId })

	--[[ Publishing ]]

	I.Topic.Publish("Tool_Added", player, tool, toolUUID)

	--[[ Returning ]]

	return toolUUID
end

--%%%%%%%%%%%%%%%%%%%% Remove

--[[
	**SERVER** |
	Removes Tool by its UUID from player backpack/character.
]]
--- @return boolean
function Module.Remove(player: Player, toolUUID: string)
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

	--[[ Unequipping ]]

	-- Clear the equipped tool here, since its Unequipped connection is about to go
	if moduleSessionData.CurrentlyEquipped == tool then
		moduleSessionData.CurrentlyEquipped = nil
		I.Topic.Publish("Tool_Unequipped", player, tool, toolUUID)
	end

	--[[ Removing ]]

	ToolScripts.ClearConnectionsForTool(player, toolUUID)
	tool:Destroy()

	moduleSessionData.CreatedTools[toolUUID] = nil
	moduleSessionData.ToolsData[toolUUID] = nil
	moduleSessionData.ToolsConnections[toolUUID] = nil

	-- Updating dictionaries
	I.AdminPanel_CommandBar.UpdateDictionary(`Tool_UUIDs-{player.Name}`, nil, { toolUUID }, 255, { BoundTo = player.UserId })

	--[[ Publishing ]]

	I.Topic.Publish("Tool_Removed", player, tool, toolUUID)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Remove All

--[[
	**SERVER** |
	Removes all Tools for player.
]]
--- @return boolean
--- @return { string }?
function Module.RemoveAll(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Tool"]

	--[[ Removing ]]

	local removedTools = {} --- @type { string }

	local toolUUIDs = {} --- @type { string }
	for toolUUID: string in pairs(moduleSessionData.CreatedTools) do
		table.insert(toolUUIDs, toolUUID)
	end
	for _, toolUUID: string in ipairs(toolUUIDs) do
		if Module.Remove(player, toolUUID) then
			table.insert(removedTools, toolUUID)
		end
	end

	return true, removedTools
end

--%%%%%%%%%%%%%%%%%%%% Connect Tool

--[[
	Connects the tool's own equip tracking and Topics, and removes the tool when it leaves the player.
]]
function Module._connectTool(player: Player, tool: Tool, toolUUID: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Tool"]

	--[[ Connecting ]]

	moduleSessionData.ToolsConnections[toolUUID]["__ume"] = {
		Equipped = tool.Equipped:Connect(function()
			--[[ Saving ]]

			moduleSessionData.CurrentlyEquipped = tool

			--[[ Checks ]]

			local character: Model? = player.Character
			local humanoid: Humanoid? = character and character:FindFirstChildOfClass("Humanoid")

			-- Skip the Topic while the player is dead
			if humanoid and humanoid.Health <= 0 then
				return
			end

			--[[ Publishing ]]

			I.Topic.Publish("Tool_Equipped", player, tool, toolUUID)
		end),
		Unequipped = tool.Unequipped:Connect(function()
			--[[ Saving ]]

			moduleSessionData.CurrentlyEquipped = nil

			--[[ Publishing ]]

			I.Topic.Publish("Tool_Unequipped", player, tool, toolUUID)
		end),
		ParentChanged = tool.AncestryChanged:Connect(function()
			--[[ Checks ]]

			local toolParent: Instance? = tool.Parent

			-- Skip while the tool itself is in the character or the backpack
			if toolParent == player.Character or toolParent == player:FindFirstChildOfClass("Backpack") then
				return
			end

			--[[ Removing ]]

			Module.Remove(player, toolUUID)
		end),
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Equipped

--[[
	**SERVER** |
	Returns the player's currently equipped tool.
]]
--- @return Tool
function Module.GetEquipped(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Tool"]

	--[[ Return ]]

	return moduleSessionData.CurrentlyEquipped or nil
end

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	**SERVER** |
	Returns player's tool by its UUID.
]]
--- @return Tool
function Module.Get(player: Player, toolUUID: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Tool"]

	--[[ Returning ]]

	return moduleSessionData.CreatedTools[toolUUID]
end

--%%%%%%%%%%%%%%%%%%%% Get All

--[[
	**SERVER** |
	Returns table containing all player's tool UUIDs.
]]
--- @return { string }
function Module.GetAll(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Tool"]

	--[[ Getting ]]

	local toReturn = {} --- @type { string }

	for toolUUID: string, _toolModel: Tool in pairs(moduleSessionData.CreatedTools) do
		table.insert(toReturn, toolUUID)
	end

	--[[ Returning ]]

	return toReturn
end

--%%%%%%%%%%%%%%%%%%%% Has

--[[
	**SERVER** |
	Checks if player has a tool by its UUID.
]]
--- @return boolean
function Module.Has(player: Player, toolUUID: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_SessionData
	local sessionData = I.Player.Sessions[player].Data
	local moduleSessionData = sessionData["Tool"]

	--[[ Returning ]]

	return moduleSessionData.CreatedTools[toolUUID] ~= nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
