--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Replicator"

--- @type Replicator_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type { [Player]: Replicator_PlayerTable }
local playersReplicators = {}

--- @type { [string]: boolean }
local validAttributeNames = {}

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
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnPlayerAdded(I.Priority.First, Module._createReplicator)
	I.G_Player.OnPlayerRemoving(I.Priority.Last, Module._clearReplicator)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("Replicator_Move")

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Replicator = {

		--[[ Control ]]

		CreateFolder = Module.CreateFolder,
		Set = Module.Set,

		--[[ Methods ]]

		Get = Module.Get,
		GetFolder = Module.GetFolder,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Replicator

--[[
	Creates new replicator for the player.
]]
function Module._createReplicator(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Getting PlayerGui ]]

	local playerGui: PlayerGui? = player:FindFirstChild("PlayerGui")
	if not playerGui then
		return
	end

	--[[ Already Exists ]]

	local existingRepliactor: Instance? = playerGui:FindFirstChild(_settings.REPLICATOR_STORAGE_NAME)
	if existingRepliactor then
		warn(`[{_localName}::{script.Name}]: Instance ({_settings.REPLICATOR_STORAGE_NAME}) already exists under PlayerGui!`)

		--[[ Saving ]]

		if not playersReplicators[player] then
			playersReplicators[player] = {
				Replicator = existingRepliactor,
				CreatedFolders = {},
			}
		end

		return
	end

	--[[ Creating ]]

	local replicator: ScreenGui = I.Create("ScreenGui")({
		Name = _settings.REPLICATOR_STORAGE_NAME,
		Enabled = false,
		ResetOnSpawn = false,
		Parent = playerGui,
	})

	--[[ Saving ]]

	playersReplicators[player] = {
		Replicator = replicator,
		CreatedFolders = {},
	}

	--[[ Moving ]]

	I.Network.Fire("Replicator_Move", player)
end

--%%%%%%%%%%%%%%%%%%%% Clear Replicator

--[[
	Removes player replicator.
]]
function Module._clearReplicator(player: Player)
	if playersReplicators[player] then
		playersReplicators[player] = nil
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Create Folder

--[[
	**SERVER** |
	Creates new directory inside player's replicator and returns it.
]]
--- @return Folder?
function Module.CreateFolder(player: Player, folderName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Getting Replicator ]]

	local replicator: ScreenGui? = Module.Get(player)
	if not replicator then
		return nil
	end

	--[[ Folder Exists ]]

	local existingFolder: Folder? = replicator:FindFirstChild(folderName)
	if existingFolder then
		warn(`[{_localName}::{script.Name}]: Folder ({folderName}) is already created in the Replicator!`)

		--[[ Saving ]]

		if not playersReplicators[player].CreatedFolders[folderName] then
			playersReplicators[player].CreatedFolders[folderName] = existingFolder
		end

		--[[ Returning ]]

		return existingFolder
	end

	--[[ Creating Folder ]]

	local newFolder: Folder? = I.Create("Folder")({
		Name = folderName,
		Parent = replicator,
	})

	playersReplicators[player].CreatedFolders[folderName] = newFolder

	--[[ Returning Folder ]]

	return newFolder
end

--%%%%%%%%%%%%%%%%%%%% Set

--[[
	**SERVER** |
	Sets an attribute on one of the player's Replicator folders. Errors with the attribute name when Roblox rejects it
	(checked once per name), and skips a value that didn't change.
]]
--- @return boolean
function Module.Set(player: Player, folderName: string, name: string, value: any)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	local folder: Folder? = Module.GetFolder(player, folderName)
	if not folder then
		return false
	end

	--[[ Checks ]]

	-- Skip a value that didn't change
	if validAttributeNames[name] and folder:GetAttribute(name) == value then
		return true
	end

	--[[ Saving ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(folder.SetAttribute, folder, name, value)

	-- Check if Roblox accepted the attribute name and value
	if not success then
		error(`[{_localName}::{script.Name}]: Attribute ({name}) on folder ({folderName}) can't be set! - ({result})`, 2)
	end

	validAttributeNames[name] = true

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns player's replicator.
]]
--- @return ScreenGui?
function Module.Get(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Checks ]]

	-- Replicator is missing
	if not playersReplicators[player] or not playersReplicators[player].Replicator then
		warn(`[{_localName}::{script.Name}]: Replicator for ({player.Name}) is missing!`)
		return nil
	end

	--[[ Returning Replicator ]]

	return playersReplicators[player].Replicator
end

--%%%%%%%%%%%%%%%%%%%% Get Folder

--[[
	Returns `folderName` folder from player's replicator.
]]
--- @return Folder?
function Module.GetFolder(player: Player, folderName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Getting Replicator ]]

	-- Replicator is missing
	if not playersReplicators[player] or not playersReplicators[player].Replicator then
		warn(`[{_localName}::{script.Name}]: Replicator for ({player.Name}) is missing!`)
		return nil
	end

	-- Folder is missing
	if not playersReplicators[player].CreatedFolders[folderName] then
		warn(`[{_localName}::{script.Name}]: Folder ({folderName}) is not created in the Replicator!`)
		return nil
	end

	--[[ Returning Folder ]]

	return playersReplicators[player].CreatedFolders[folderName]
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
