--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Replicator"

--- @type Replicator_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local ReplicatedStorage = I.S.ReplicatedStorage

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local replicatorInstance: Folder | ScreenGui
local movedSignal = I.Signal.new() --- @type Signal

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

	--- @Network
	I.Network.GetEvent("Replicator_Move", {})
	I.Network.Fired("Replicator_Move", Module._moveToReplicatedStorage)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Replicator = {

		--[[ Methods ]]

		Get = Module.Get,
		GetFolder = Module.GetFolder,
		WaitForFolder = Module.WaitForFolder,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Move to Replicated Storage

--[[
	Moves replicator from `PlayerGui` to `ReplicatedStorage`.
]]
function Module._moveToReplicatedStorage()
	replicatorInstance = I.Env.PlayerGui:FindFirstChild(_settings.REPLICATOR_STORAGE_NAME) or I.Env.PlayerGui:WaitForChild(_settings.REPLICATOR_STORAGE_NAME, 60)

	if replicatorInstance then
		replicatorInstance.Parent = ReplicatedStorage
		movedSignal:Fire()
	else
		warn(`[{_localName}::{script.Name}]: Replicator instance not found under PlayerGui!`)
		I.Env.LocalPlayer:Kick("Oops! Something went wrong while loading the Replicator. Please try again!")
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns player's replicator.
]]
--- @return ScreenGui?
function Module.Get()
	return replicatorInstance
end

--%%%%%%%%%%%%%%%%%%%% Get Folder

--[[
	Returns `folderName` folder from player's replicator.
]]
--- @return Folder?
function Module.GetFolder(folderName: string)
	return replicatorInstance and replicatorInstance:FindFirstChild(folderName)
end

--%%%%%%%%%%%%%%%%%%%% Wait For Folder

--[[
	**CLIENT** |
	Returns `folderName` from the player's replicator, waiting for the replicator and then the folder. Returns nil after `timeout` seconds.
]]
--- @return Folder?
function Module.WaitForFolder(folderName: string, timeout: number?)
	--[[ Waiting ]]

	-- Wait for the replicator to move into ReplicatedStorage
	if not replicatorInstance then
		movedSignal:Wait()
	end

	--[[ Returning ]]

	return replicatorInstance:FindFirstChild(folderName) or replicatorInstance:WaitForChild(folderName, timeout)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
