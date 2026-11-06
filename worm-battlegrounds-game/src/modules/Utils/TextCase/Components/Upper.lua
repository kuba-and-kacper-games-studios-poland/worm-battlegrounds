--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "TextCase"

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

--- @class TextCase_Upper : Component
--- @field Instance TextLabel
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
local Component = {}
Component.__index = Component

-- Exported guis carry the tag: only the live copies build, not the templates
Component.IgnoreAncestors = { I.S.ReplicatedStorage, I.S.StarterGui }

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Type Check ]]

	if not self.Instance:IsA("TextLabel") then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is not a (TextLabel)! -`, self.Instance)
		return
	end

	--[[ Connecting ]]

	table.insert(
		self.Connections,
		self.Instance:GetPropertyChangedSignal("Text"):Connect(function()
			self:Apply()
		end)
	)

	--[[ Applying ]]

	self:Apply()
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Puts the label's text in capitals, as the kit's capitals styles show it when the gui is built.
]]
function Component:Apply()
	--[[ Local Variables ]]

	local text: string = self.Instance.Text
	local upper: string = Component._getUpper(text)

	--[[ Applying ]]

	-- Skip a text already in capitals, so writing it doesn't fire this again
	if upper ~= text then
		self.Instance.Text = upper
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Upper

--[[
	Returns a rich text in capitals: only the words outside its tags, with its escapes (&lt;) back in lower case.
]]
--- @return string
function Component._getUpper(text: string)
	--[[ Local Variables ]]

	local upper: string = string.gsub(text, "([^<]*)(<?[^>]*>?)", function(words: string, tag: string)
		return string.upper(words) .. tag
	end)

	--[[ Returning ]]

	return (string.gsub(upper, "&(%u+);", function(name: string)
		return `&{string.lower(name)};`
	end))
end

return Component
