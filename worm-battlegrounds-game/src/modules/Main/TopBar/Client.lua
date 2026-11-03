--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "TopBar"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _components = script:FindFirstAncestor(_localName):FindFirstChild("Components")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Components

local ButtonComponent = require(_components:FindFirstChild("Button")) --- @type TopBar_Button

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance | GuiObject }
local prefabs = {} --- @type { [string]: Instance | GuiObject }

--[[ General ]]

local moduleGui: ScreenGui

--[[ State ]]

local shown: boolean = true

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

	Module._getElements()
	Module._createConnections()
	Module._updateBarPosition()

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.TopBar = {

		--[[ Control ]]

		Show = Module.Show,
		Hide = Module.Hide,
		AddButton = Module.AddButton,

		--[[ Methods ]]

		IsShown = Module.IsShown,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing the top bar elements and the button prefab.
]]
function Module._getElements()
	moduleGui = I.UserInterface.UI["TopBar"]

	--[[ General ]]

	elems["Bar"] = moduleGui:FindFirstChild("U_Bar", true) --- @type Frame
	elems["Left"] = moduleGui:FindFirstChild("U_Left", true) --- @type Frame
	elems["Right"] = moduleGui:FindFirstChild("U_Right", true) --- @type Frame

	--[[ Prefab ]]

	prefabs["Button"] = moduleGui:FindFirstChild("PREFAB | Button", true) --- @type ImageButton
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Follows Roblox's top bar inset and hides the top bar while the Roblox menu is open.
]]
function Module._createConnections()
	--[[ Inset ]]

	I.S.GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(Module._updateBarPosition)

	--[[ Menu ]]

	I.S.GuiService.MenuOpened:Connect(function()
		moduleGui.Enabled = false
	end)
	I.S.GuiService.MenuClosed:Connect(function()
		moduleGui.Enabled = shown
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	**CLIENT** |
	Shows the top bar (once the Roblox menu closes, when it is open).
]]
function Module.Show()
	--[[ Applying ]]

	shown = true
	moduleGui.Enabled = not I.S.GuiService.MenuIsOpen
end

--%%%%%%%%%%%%%%%%%%%% Hide

--[[
	**CLIENT** |
	Hides the top bar.
]]
function Module.Hide()
	--[[ Applying ]]

	shown = false
	moduleGui.Enabled = false
end

--%%%%%%%%%%%%%%%%%%%% Add Button

--[[
	**CLIENT** |
	Adds a blank button to the `Left` or `Right` side of the top bar (Left when the side is invalid) and returns it.
]]
--- @return TopBar_Button
function Module.AddButton(side: "Left" | "Right")
	--[[ Checks ]]

	-- Check if the side is valid
	if side ~= "Left" and side ~= "Right" then
		warn(`[{_localName}::{script.Name}]: Invalid (side) value. Expected ("Left" | "Right"), got ({side}: {typeof(side)})!`)
		side = "Left"
	end

	--[[ Cloning ]]

	local newButton: ImageButton = prefabs["Button"]:Clone()
	newButton.Name = "Button"
	newButton.Visible = true
	newButton.Parent = elems[side]

	--[[ Component ]]

	local button = ButtonComponent.new(newButton) --- @type TopBar_Button
	button:Init()

	--[[ Returning ]]

	return button
end

--%%%%%%%%%%%%%%%%%%%% Update Bar Position

--[[
	Puts the bottom of the bar on the bottom of Roblox's top bar inset.
]]
function Module._updateBarPosition()
	--[[ Applying ]]

	elems["Bar"].Position = UDim2.new(elems["Bar"].Position.X, UDim.new(0, I.S.GuiService.TopbarInset.Height - elems["Bar"].Size.Y.Offset))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Shown

--[[
	**CLIENT** |
	Returns whether the top bar is shown (it still hides while the Roblox menu is open).
]]
--- @return boolean
function Module.IsShown()
	return shown
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
