--# selene: allow(unused_variable)
--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Tool"

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

--- @type Tool_ToolModule_Client
local Tool = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Tool.Init()
	--[[ ... ]]
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Equipped

function Tool.Equipped(tool: Tool, toolUUID: string)
	--[[ Color Change ]]

	local handle: BasePart = tool.PrimaryPart or tool:FindFirstChild("Handle")
	if handle then
		handle.Color = Color3.fromRGB(84, 161, 255)
	end
end

--%%%%%%%%%%%%%%%%%%%% Unequipped

function Tool.Unequipped(tool: Tool, toolUUID: string)
	--[[ Color Change ]]

	local handle: BasePart = tool.PrimaryPart or tool:FindFirstChild("Handle")
	if handle then
		handle.Color = Color3.fromRGB(255, 84, 87)
	end
end

--%%%%%%%%%%%%%%%%%%%% Activated

function Tool.Activated(tool: Tool, toolUUID: string)
	--[[ Color Change ]]

	local handle: BasePart = tool.PrimaryPart or tool:FindFirstChild("Handle")
	if handle then
		handle.Color = Color3.fromRGB(130, 255, 53)
	end
end

--%%%%%%%%%%%%%%%%%%%% Deactivated

function Tool.Deactivated(tool: Tool, toolUUID: string)
	--[[ Color Change ]]

	local handle: BasePart = tool.PrimaryPart or tool:FindFirstChild("Handle")
	if handle then
		handle.Color = Color3.fromRGB(84, 161, 255)
	end
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Tool.Destroy(tool: Tool, toolUUID: string)
	--[[ Color Change ]]

	local handle: BasePart = tool.PrimaryPart or tool:FindFirstChild("Handle")
	if handle then
		handle.Color = Color3.fromRGB(255, 84, 87)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ###

--%%%%%%%%%%%%%%%%%%%% ###

return Tool
