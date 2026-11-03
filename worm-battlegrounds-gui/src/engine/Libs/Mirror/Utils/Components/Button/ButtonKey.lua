--[[
	Created By: 	Nari
]]

-- --- @type Ume
-- local I = require(script:FindFirstAncestor("Libs"):FindFirstChild("Runtime"))
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local ButtonPress = require(_scripts:FindFirstChild("ButtonPress")) --- @type UmeGui_Utils_ButtonPress
local GuiVisibility = require(_scripts:FindFirstChild("GuiVisibility")) --- @type UmeGui_Utils_GuiVisibility

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The attributes that name the button's keys, by input
local KEY_ATTRIBUTES = { "Utils_GamepadKey", "Utils_KeyboardKey" } --- @type { string }

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

--- @class UmeGui_Utils_ButtonKey : Component
--- @field Instance ImageButton | TextButton
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Keys #
---
--- @field KeyCodes { Enum.KeyCode }
---
--- # State #
---
--- @field Shown boolean
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ State ]]

	-- No keys until they are read, so a tagged instance that isn't a button binds none
	self.KeyCodes = {}
	self.Shown = false

	--[[ Checks ]]

	-- Check if the instance is a button
	if not self.Instance:IsA("ImageButton") and not self.Instance:IsA("TextButton") then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is not a (Button)! -`, self.Instance)
		return
	end

	--[[ Reading ]]

	self:GetAttributes()

	-- Warn about a button with no key yet; one set later still binds
	if #self.KeyCodes == 0 then
		warn(`[{_localName}::{script.Name}]: ({self.Instance}) has no (Utils_GamepadKey) or (Utils_KeyboardKey)! -`, self.Instance)
	end

	--[[ Connections ]]

	self:ConnectAttributes()
	self:ConnectVisibility()
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	-- The keys stop pressing the button
	ButtonPress.Remove(self.Instance)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Reads the button's keys from its key attributes, warning on a name that isn't a KeyCode.
]]
function Component:GetAttributes()
	--[[ Reading ]]

	self.KeyCodes = {}

	for _index: number, attribute: string in ipairs(KEY_ATTRIBUTES) do
		local keyName: string = self.Instance:GetAttribute(attribute) or ""

		-- Skip an input with no key
		if keyName == "" then
			continue
		end

		local keyCode: Enum.KeyCode? = Enum.KeyCode:FromName(keyName)

		-- Check if the name is a KeyCode
		if not keyCode then
			warn(`[{_localName}::{script.Name}]: ({attribute}) ({keyName}) is not a KeyCode! -`, self.Instance)
			continue
		end

		table.insert(self.KeyCodes, keyCode)
	end
end

--%%%%%%%%%%%%%%%%%%%% Connect Attributes

--[[
	Re-binds the keys whenever a key attribute changes.
]]
function Component:ConnectAttributes()
	--[[ Connections ]]

	for _index: number, attribute: string in ipairs(KEY_ATTRIBUTES) do
		table.insert(
			self.Connections,
			self.Instance:GetAttributeChangedSignal(attribute):Connect(function()
				self:GetAttributes()
				self:Refresh()
			end)
		)
	end
end

--%%%%%%%%%%%%%%%%%%%% Connect Visibility

--[[
	Lets the keys press the button only while it is shown.
]]
function Component:ConnectVisibility()
	--[[ Connections ]]

	table.insert(
		self.Connections,
		GuiVisibility.Watch(self.Instance, function(shown: boolean)
			self.Shown = shown
			self:Refresh()
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Binds the button's current keys while it is shown, and none while it is hidden.
]]
function Component:Refresh()
	--[[ Removing ]]

	ButtonPress.Remove(self.Instance)

	--[[ Adding ]]

	-- Skip a hidden button or one with no key
	if not self.Shown or #self.KeyCodes == 0 then
		return
	end

	ButtonPress.Add(self.Instance, self.KeyCodes)
end

return Component
