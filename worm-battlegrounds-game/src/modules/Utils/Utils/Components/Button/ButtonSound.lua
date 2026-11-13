--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local ButtonPress = require(_scripts:FindFirstChild("ButtonPress")) --- @type Utils_ButtonPress

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Defaults ]]

-- The sound each kind plays when its name attribute is missing; an empty name plays nothing
local DEFAULT_SOUNDS = { --- @type { [string]: string }
	["Click"] = "Button_Click",
}

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

--- @class Utils_ButtonSound : Component
--- @field Instance ImageButton | TextButton
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field ClickPlayTable Sound_Params
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Checks ]]

	-- Check if the instance is a button
	if not self.Instance:IsA("ImageButton") and not self.Instance:IsA("TextButton") then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is not a (Button)! -`, self.Instance)
		return
	end

	--[[ Setup ]]

	self:GetAttributes()

	--[[ Connections ]]

	self:ConnectInput()
	self:ConnectAttributes()
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Reads the click sound from its `ClickSound_` attributes. Hover plays nothing (the testers, 2026-11-13: hover
	sounds in the lobby were annoying), so `HoverSound_` attributes are ignored.
]]
function Component:GetAttributes()
	--[[ Reading ]]

	self.ClickPlayTable = self:GetPlayTable("Click")
end

--%%%%%%%%%%%%%%%%%%%% Connect Input

--[[
	Plays the click sound on a click and when a key activates the button (Utils_ButtonKey).
]]
function Component:ConnectInput()
	--[[ Click Sound ]]

	table.insert(
		self.Connections,
		self.Instance.MouseButton1Click:Connect(function()
			self:PlaySound(self.ClickPlayTable)
		end)
	)
	table.insert(
		self.Connections,
		ButtonPress.Connect(self.Instance, "Activated", function()
			self:PlaySound(self.ClickPlayTable)
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%% Connect Attributes

--[[
	Re-reads the click sound whenever one of its attributes changes.
]]
function Component:ConnectAttributes()
	--[[ Connections ]]

	table.insert(
		self.Connections,
		self.Instance.AttributeChanged:Connect(function(attribute: string)
			-- Skip attributes that aren't the click sound's
			if not attribute:match("^ClickSound_") then
				return
			end

			self:GetAttributes()
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Play Sound

--[[
	Plays one of the button's sounds, unless its name is empty.
]]
--- @param playTable Sound_Params
function Component:PlaySound(playTable)
	--[[ Checks ]]

	-- Skip a sound turned off with an empty name
	if playTable.Name == "" then
		return
	end

	--[[ Playing ]]

	I.Sound.Play(playTable)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Play Table

--[[
	Returns the `I.Sound.Play` params of one kind (`Click`), from its `<kind>Sound_` attributes. No pitch
	effect is added while both pitches stay at 1.
]]
--- @return Sound_Params
function Component:GetPlayTable(kind: string)
	--[[ Local Variables ]]

	local prefix: string = `{kind}Sound_`
	local pitchMin: number = self.Instance:GetAttribute(`{prefix}PitchMin`) or 1
	local pitchMax: number = self.Instance:GetAttribute(`{prefix}PitchMax`) or 1
	local pitchFixed: boolean = pitchMin == 1 and pitchMax == 1

	--[[ Returning ]]

	return {
		Name = self.Instance:GetAttribute(`{prefix}Name`) or DEFAULT_SOUNDS[kind],
		Volume = self.Instance:GetAttribute(`{prefix}Volume`) or 1,
		SoundGroup = self.Instance:GetAttribute(`{prefix}SoundGroup`) or "UI",
		PlaybackSpeed = self.Instance:GetAttribute(`{prefix}PlaybackSpeed`) or 1,
		TimePosition = self.Instance:GetAttribute(`{prefix}TimePosition`) or 0,
		PitchMin = if pitchFixed then nil else pitchMin,
		PitchMax = if pitchFixed then nil else pitchMax,
	}
end

return Component
