--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "BackpackPlus"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _data = script:FindFirstAncestor(_localName):FindFirstChild("Data")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local ctx = nil --- @type BackpackPlus_ClientContext

--[[ Contents ]]

-- Each display type's hover info, by the Data/HoverInfo file named after it
local contents = {} --- @type { [string]: (tool: Tool) -> HoverInfo_Content? }

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

--- @class BackpackPlus_Client_HoverInfo
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param context BackpackPlus_ClientContext
function Module.Init(context)
	--[[ Saving ]]

	ctx = context

	--[[ Loading ]]

	for _index: number, contentModule: Instance in ipairs(_data:FindFirstChild("HoverInfo"):GetChildren()) do
		contents[contentModule.Name] = require(contentModule)
	end
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Registering ]]

	I.HoverInfo.RegisterProvider(_localName, Module._getContent)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Content

--[[
	Returns the hover info of a slot's tool, from the Data/HoverInfo file of its `BackpackPlus_DisplayType`; nil for a
	tool whose display type has none.
]]
--- @return HoverInfo_Content?
function Module._getContent(target: GuiObject)
	--[[ Data ]]

	local slotData = ctx.CreatedSlots.BySlot[target] --- @type BackpackPlus_SlotData?
	if not slotData then
		return nil
	end

	local content = contents[slotData.Tool:GetAttribute("BackpackPlus_DisplayType") or ""] --- @type ((tool: Tool) -> HoverInfo_Content?)?

	--[[ Returning ]]

	return if content then content(slotData.Tool) else nil
end

return Module
