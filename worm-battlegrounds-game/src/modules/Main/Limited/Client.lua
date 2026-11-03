--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Limited"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _components = script:FindFirstAncestor(_localName):FindFirstChild("Components")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Replicator ]]

local globalRepFolder: Folder

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

	Module._getGlobalReplicator()

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Component
	I.Component.RegisterOnLoaded("Limited_Slot", _components.Slot)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Limited = {

		--[[ Methods ]]

		GetSold = Module.GetSold,
		GetMax = Module.GetMax,
		GetRemaining = Module.GetRemaining,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Global Replicator

--[[
	Waits for the shared Limited folder in `I.Dirs.Storage` without blocking Init.
]]
function Module._getGlobalReplicator()
	task.spawn(function()
		globalRepFolder = I.Dirs.Storage:WaitForChild(_localName, 30)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Sold

--[[
	**CLIENT** |
	Returns total copies of `limitedId` sold globally.
]]
--- @return number
function Module.GetSold(limitedId: string)
	if not globalRepFolder then
		return 0
	end

	return tonumber(globalRepFolder:GetAttribute(`{limitedId}_Sold`)) or 0
end

--%%%%%%%%%%%%%%%%%%%% Get Max

--[[
	**CLIENT** |
	Returns maximum copies of `limitedId` available.
]]
--- @return number
function Module.GetMax(limitedId: string)
	if not globalRepFolder then
		return 0
	end

	return tonumber(globalRepFolder:GetAttribute(`{limitedId}_Max`)) or 0
end

--%%%%%%%%%%%%%%%%%%%% Get Remaining

--[[
	Returns remaining copies of `limitedId` available.
]]
--- @return number
function Module.GetRemaining(limitedId: string)
	return math.max(0, Module.GetMax(limitedId) - Module.GetSold(limitedId))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
