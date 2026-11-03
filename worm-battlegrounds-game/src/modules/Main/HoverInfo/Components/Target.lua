--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "HoverInfo"

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

--- @class HoverInfo_Target : Component
--- @field Instance GuiObject
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
local Component = {}
Component.__index = Component

-- Only the live copy in PlayerGui shows the box, not the template in the assets
Component.IgnoreAncestors = { I.S.ReplicatedStorage, I.S.StarterGui }

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Initialization ]]

	self:CreateConnections()
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	-- Hide the box when it shows for this element
	I.HoverInfo.Hide(self.Instance)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Shows the box while the mouse is over the element, or while a finger holds it (a long press), and hides it when the
	mouse leaves or the finger lifts. A gamepad's pick is followed by the module itself.
]]
function Component:CreateConnections()
	--[[ Mouse ]]

	table.insert(
		self.Connections,
		self.Instance.MouseEnter:Connect(function()
			-- Skip the mouse events a tap sends, so a tap doesn't open the box
			if I.S.UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
				return
			end

			I.HoverInfo.Show(self.Instance, "Mouse")
		end)
	)
	table.insert(
		self.Connections,
		self.Instance.MouseLeave:Connect(function()
			I.HoverInfo.Hide(self.Instance)
		end)
	)

	--[[ Touch ]]

	table.insert(
		self.Connections,
		--- @param _positions { Vector2 }
		self.Instance.TouchLongPress:Connect(function(_positions, state: Enum.UserInputState)
			if state == Enum.UserInputState.Begin then
				I.HoverInfo.Show(self.Instance, "Touch")
			else
				I.HoverInfo.Hide(self.Instance)
			end
		end)
	)
end

return Component
