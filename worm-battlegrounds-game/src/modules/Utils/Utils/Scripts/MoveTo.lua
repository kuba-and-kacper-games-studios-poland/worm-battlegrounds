--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local CollectionService = I.S.CollectionService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Constants ]]

local MOVETO_TAG = "Utils_MoveTo"
local MOVECHILDTO_TAG = "Utils_MoveChildTo"

local MOVETO_ELEM_NAME = "Utils_Destination"

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

--- @class Utils_MoveTo
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._moveTagged(MOVETO_TAG, Module._moveRegular)
	Module._moveTagged(MOVECHILDTO_TAG, Module._moveChildren)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Move Tagged

--[[
	Moves every instance with `tag` now and every instance tagged later, each in its own `pcall`.
]]
function Module._moveTagged(tag: string, moveFunction: (elem: Instance) -> ())
	--[[ Existing ]]

	for _index: number, elem: Instance in ipairs(CollectionService:GetTagged(tag)) do
		Module._moveSafely(tag, moveFunction, elem)
	end

	--[[ Connections ]]

	CollectionService:GetInstanceAddedSignal(tag):Connect(function(elem: Instance)
		Module._moveSafely(tag, moveFunction, elem)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Move Safely

--[[
	Runs one element's move and warns with the element when it errors, so one bad destination doesn't stop the rest.
]]
function Module._moveSafely(tag: string, moveFunction: (elem: Instance) -> (), elem: Instance)
	--[[ Moving ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(moveFunction, elem)

	-- Warn with the element when the move errored
	if not success then
		warn(`[{_localName}::{script.Name}]: ({elem.Name}) ({tag}) move failed! - ({result}) -`, elem)
	end
end

--%%%%%%%%%%%%%%%%%%%% Move Regular

--[[
	Moves one tagged instance to its destination.
]]
function Module._moveRegular(elem: Instance)
	--[[ Data ]]

	local destination: Instance? = elem:FindFirstChild(MOVETO_ELEM_NAME)

	--[[ Checks ]]

	-- Check if the destination ObjectValue exists
	if not destination or not destination:IsA("ObjectValue") or not destination.Value then
		warn(`[{_localName}::{script.Name}]: ({elem.Name}) (MoveTo) Instance is missing its (Destination) ObjectValue! -`, elem)
		return
	end

	-- Warn about a name already used in the destination
	if destination.Value:FindFirstChild(elem.Name) then
		warn(`[{_localName}::{script.Name}]: ({elem.Name}) (MoveTo) Instance is duplicated in the ({destination.Value.Name}) (Destination)! -`, elem)
	end

	--[[ Moving ]]

	elem.Parent = destination.Value
	destination:Destroy()
end

--%%%%%%%%%%%%%%%%%%%% Move Children

--[[
	Moves the children of one tagged instance to its destination, merging into children with the same name.
]]
function Module._moveChildren(elem: Instance)
	--[[ Data ]]

	local destination: Instance? = elem:FindFirstChild(MOVETO_ELEM_NAME)

	--[[ Checks ]]

	-- Check if the destination ObjectValue exists
	if not destination or not destination:IsA("ObjectValue") or not destination.Value then
		warn(`[{_localName}::{script.Name}]: ({elem.Name}) (MoveChildTo) Instance is missing its (Destination) ObjectValue! -`, elem)
		return
	end

	--[[ Moving ]]

	for _index: number, toMove: Instance in ipairs(elem:GetChildren()) do
		-- Skip the destination ObjectValue itself
		if toMove == destination then
			continue
		end

		local existingChild: Instance? = destination.Value:FindFirstChild(toMove.Name)

		-- Merge into a child with the same name instead of moving the whole instance
		if existingChild then
			for _childIndex: number, child: Instance in ipairs(toMove:GetChildren()) do
				-- Warn about a name already used under that child
				if existingChild:FindFirstChild(child.Name) then
					warn(`[{_localName}::{script.Name}]: Child ({child.Name}) of ({elem.Name}) (MoveChildTo) Instance is duplicated in the ({destination.Value.Name}) (Destination)! -`, elem)
				end

				child.Parent = existingChild
			end
			continue
		end

		toMove.Parent = destination.Value
	end

	--[[ Cleaning ]]

	destination:Destroy()

	-- Remove the emptied instance unless it opts out
	if elem:GetAttribute("Utils_RemoveAfterMove") ~= false then
		elem:Destroy()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
