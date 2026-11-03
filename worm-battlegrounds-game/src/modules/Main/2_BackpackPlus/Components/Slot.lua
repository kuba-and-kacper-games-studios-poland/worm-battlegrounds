--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "BackpackPlus"

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

--- @class BackpackPlus_Slot : Component
--- @field Instance Frame
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Elements #
---
--- @field SlotButton ImageButton
---
--- # Layout #
---
--- @field DefaultSize UDim2
--- @field DefaultAbsoluteSize Vector2
---
--- # Drag #
---
--- @field Drag boolean @ Indicates if the Item is being dragged
--- @field DidDrag boolean @ Indicates if the current press completed a drag (blocks the following Click)
--- @field DragConnection RBXScriptConnection?
--- @field DragEndConnection RBXScriptConnection? @ Ends the drag on a release anywhere
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Initialization ]]

	self:GetElements()
	if not self.SlotButton then
		return
	end

	--[[ Properties ]]

	self:UpdateDefaultSize()

	self.Drag = false
	self.DidDrag = false

	--[[ Connections ]]

	self:CreateConnections()
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	if self.DragConnection then
		self.DragConnection:Disconnect()
	end

	--[[ Drag Cleanup ]]

	-- Disconnecting the release listener of an unfinished press
	if self.DragEndConnection then
		self.DragEndConnection:Disconnect()
	end

	-- Destroying a button a drag left under the backpack gui
	if self.SlotButton and self.SlotButton.Parent ~= self.Instance then
		self.SlotButton:Destroy()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing key elements.
]]
function Component:GetElements()
	self.SlotButton = self.Instance:FindFirstChild("S_SlotButton", true) --- @type ImageButton
end

--%%%%%%%%%%%%%%%%%%%% Update Default Size

--[[
	Updates drag size values from the shared Toolbar slot size.
]]
function Component:UpdateDefaultSize()
	--[[ Getting Sizes ]]

	self.DefaultSize = I.BackpackPlus._getSlotSize()
	self.DefaultAbsoluteSize = I.BackpackPlus._getSlotAbsoluteSize()

	--[[ Updating Size ]]

	if self.SlotButton.Parent == self.Instance then
		self.SlotButton.Size = self.DefaultSize
	end
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Connects slot button click / drag input.
]]
function Component:CreateConnections()
	--[[ Toolbar Size ]]

	table.insert(
		self.Connections,
		I.Topic.Subscribe("BackpackPlus_ToolbarSizeChanged", function()
			self:UpdateDefaultSize()
		end)
	)

	--[[ Click ]]

	table.insert(
		self.Connections,
		self.SlotButton.MouseButton1Click:Connect(function()
			-- Return if this Click followed a drag release
			if self.DidDrag then
				self.DidDrag = false
				return
			end

			-- Return if dragged
			if self.Drag then
				return
			end

			-- Favorite mode: lock inventory items instead of equipping
			if I.BackpackPlus.IsFavoriteMode() and I.BackpackPlus.ToggleSlotFavorite(self.Instance) then
				return
			end

			-- Toggling the Tool
			I.BackpackPlus.ToggleItem(self.Instance)
		end)
	)

	--[[ Right Click ]]

	table.insert(
		self.Connections,
		self.SlotButton.MouseButton2Click:Connect(function()
			-- Return if this Click followed a drag release
			if self.DidDrag then
				self.DidDrag = false
				return
			end

			-- Return if dragged
			if self.Drag then
				return
			end

			-- Toggling inventory lock
			I.BackpackPlus.ToggleSlotFavorite(self.Instance)
		end)
	)

	--[[ Drag Begin ]]

	table.insert(
		self.Connections,
		self.SlotButton.MouseButton1Down:Connect(function()
			--[[ Checks ]]

			-- Return if already dragging
			if self.Drag then
				return
			end

			-- Return if backpack is closed
			if not I.BackpackPlus.GetState() then
				return
			end

			-- Return if this Slot is reservation-locked
			if I.BackpackPlus.IsSlotReservationLocked(self.Instance) then
				return
			end

			-- Resetting drag-click guard for this press
			self.DidDrag = false

			-- Clearing connections of a press that never ended
			self:DisconnectDrag()

			--[[ Drag Connection ]]

			local startMousePos: Vector2 = Vector2.new(I.Env.Mouse.X, I.Env.Mouse.Y)
			local moved: boolean = false

			self.DragConnection = I.S.RunService.Heartbeat:Connect(function(_deltaTime: number)
				--%%%%%%%%%%%%%%%%%%%% Drag Enable Check

				if not self.Drag then
					-- Calculating activation distance
					local itemSize: Vector2 = self.Instance.AbsoluteSize
					local dragActivateDistance: number = math.min(itemSize.X, itemSize.Y) / 5

					-- Calculating moved distance
					local currentMousePos: Vector2 = Vector2.new(I.Env.Mouse.X, I.Env.Mouse.Y)
					local distance: number = (startMousePos - currentMousePos).Magnitude

					-- Activating drag
					if distance >= dragActivateDistance then
						self.Drag = true
						self.DidDrag = true
					end

					return
				end

				--%%%%%%%%%%%%%%%%%%%% Drag Move

				-- Moving Item to the main Gui so it can be dragged
				if not moved then
					self.SlotButton.Size = UDim2.fromOffset(self.DefaultAbsoluteSize.X, self.DefaultAbsoluteSize.Y)
					self.SlotButton.Parent = I.UserInterface.UI["BackpackPlus"]
					moved = true
				end

				-- Updating Item position to follow mouse
				local mousePos: Vector2 = Vector2.new(I.Env.Mouse.X, I.Env.Mouse.Y)
				local insetSize: Rect = I.S.GuiService.TopbarInset
				self.SlotButton.Position = UDim2.fromOffset(mousePos.X, mousePos.Y + insetSize.Height)
			end)

			--[[ Drag End Connection ]]

			-- Ending the press on a release anywhere, not only over the button
			self.DragEndConnection = I.S.UserInputService.InputEnded:Connect(function(input: InputObject)
				-- Ignoring non-press input
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
					return
				end

				self:EndDrag(true)
			end)
		end)
	)

	--[[ Drag End ]]

	table.insert(
		self.Connections,
		self.SlotButton.MouseButton1Up:Connect(function()
			self:EndDrag(true)
		end)
	)

	--[[ Gui Disabled ]]

	table.insert(
		self.Connections,
		I.UserInterface.UI["BackpackPlus"]:GetPropertyChangedSignal("Enabled"):Connect(function()
			-- Cancelling the press when the backpack gui is disabled
			if not I.UserInterface.UI["BackpackPlus"].Enabled then
				self:EndDrag(false)
			end
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% End Drag

--[[
	Ends the current press. A dragged button goes back to its Slot, which is dropped under the mouse when `drop` is set.
]]
function Component:EndDrag(drop: boolean)
	--[[ Disconnecting ]]

	self:DisconnectDrag()

	--[[ Checks ]]

	-- Return if not being dragged
	if not self.Drag then
		return
	end

	--[[ Clearing ]]

	self.Drag = false
	self.DidDrag = true

	-- Moving Item to it's default parent
	self.SlotButton.Parent = self.Instance
	self.SlotButton.Size = self.DefaultSize
	self.SlotButton.Position = UDim2.fromScale(0.5, 0.5)

	--[[ Dropping ]]

	-- Dropping Item to move it
	if drop then
		I.BackpackPlus.DropSlot(self.Instance)
	end

	-- Click often does not fire after reparent; clear leftover DidDrag
	task.defer(function()
		self.DidDrag = false
	end)
end

--%%%%%%%%%%%%%%%%%%%% Disconnect Drag

--[[
	Disconnects the connections of the current press.
]]
function Component:DisconnectDrag()
	--[[ Disconnecting ]]

	-- Mouse follow
	if self.DragConnection then
		self.DragConnection:Disconnect()
		self.DragConnection = nil
	end

	-- Release listener
	if self.DragEndConnection then
		self.DragEndConnection:Disconnect()
		self.DragEndConnection = nil
	end
end

return Component
