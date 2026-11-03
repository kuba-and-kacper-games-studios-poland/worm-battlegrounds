--[[
	Created By: 	Nari
]]

-- --- @type Ume
-- local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Interact"

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

--- @class Interact_Args
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns the instance's Interact_Arg1, Interact_Arg2, … attributes in order, up to the first one that isn't set.
]]
--- @return { any }
function Module.Get(instance: Instance)
	--[[ Reading ]]

	local args = {} --- @type { any }
	local count: number = 0

	while true do
		count += 1

		local arg: any = instance:GetAttribute(`Interact_Arg{count}`)

		-- Stop at the first argument that isn't set
		if arg == nil then
			break
		end

		table.insert(args, arg)
	end

	--[[ Returning ]]

	return args
end

--%%%%%%%%%%%%%%%%%%%% Get With Player

--[[
	Returns a copy of the arguments with the player inserted at the given position, clamped to the list.
]]
--- @param args { any }
--- @return { any }
function Module.GetWithPlayer(args, player: Player, position: number)
	--[[ Building ]]

	local newArgs = table.clone(args) --- @type { any }
	table.insert(newArgs, math.clamp(position, 1, #newArgs + 1), player)

	--[[ Returning ]]

	return newArgs
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
