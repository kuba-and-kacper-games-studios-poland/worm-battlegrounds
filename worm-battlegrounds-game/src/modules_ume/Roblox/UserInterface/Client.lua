--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "UserInterface"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[
	**CLIENT** |
    Table containing all GUIs.
]]
--- @type { [string]: ScreenGui }
local storedGUIs = {}

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

	Module._moveToPlayerGui(I.Dirs.UmeReplicated[_localName]:GetChildren())

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("UserInterface_UIAdded", { { Type = "Instance", ClassName = "ScreenGui" } })
	I.Topic.Register("UserInterface_UIRemoved", { "string" })

	--- @Network
	I.Network.GetEvent("UserInterface_ChangeVisibility", { "string", "boolean" })
	I.Network.Fired("UserInterface_ChangeVisibility", Module.ChangeVisibility)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.UserInterface = {

		--[[ Control ]]

		Add = Module.Add,
		Remove = Module.Remove,
		ChangeVisibility = Module.ChangeVisibility,

		--[[ Data ]]

		UI = storedGUIs,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Move To PlayerGui

--[[
	Moves all passed `ScreenGuis` to the PlayerGui and saves them under `I.UserInterface.UI`.
	Walks Folders and lists, and warns when a name is already stored for another gui.
]]
--- @param elems { Instance | { any } }
function Module._moveToPlayerGui(elems)
	--- @param gui Instance | { any }
	for _index: number, gui in ipairs(elems) do
		--[[ Checks ]]

		-- Walk a list
		if type(gui) == "table" then
			Module._moveToPlayerGui(gui)
			continue
		end

		-- Walk a Folder
		if gui:IsA("Folder") then
			Module._moveToPlayerGui(gui:GetChildren())
			continue
		end

		-- Skip anything else that isn't a ScreenGui
		if not gui:IsA("ScreenGui") then
			warn(`[{_localName}::{script.Name}]: ({gui.Name}) is not a ScreenGui!`)
			continue
		end

		-- Warn when another gui is already stored under this name
		if storedGUIs[gui.Name] and storedGUIs[gui.Name] ~= gui then
			warn(`[{_localName}::{script.Name}]: ({gui:GetFullName()}) replaces ({storedGUIs[gui.Name]:GetFullName()}) under the same name!`)
		end

		--[[ ScreenGui ]]

		-- Keep the gui through respawns
		gui.ResetOnSpawn = false
		gui.Parent = I.Env.LocalPlayer.PlayerGui
		storedGUIs[gui.Name] = gui

		--[[ Adding To Command Dictionary ]]

		-- Update the dictionary and publish once the framework has started
		if I.Started then
			I.AdminPanel_CommandBar.UpdateDictionary("UserInterface_GuiNames", { gui.Name })
			I.Topic.Publish("UserInterface_UIAdded", gui)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Add

--[[
	**CLIENT** |
	Moves all passed `ScreenGuis` to the PlayerGui and saves them under `I.UserInterface.UI`.
]]
function Module.Add(...: ScreenGui | Folder | table)
	Module._moveToPlayerGui(table.pack(...))
end

--%%%%%%%%%%%%%%%%%%%% Remove

--[[
	**CLIENT** |
	Removes saved `ScreenGui` and destroys it.
]]
function Module.Remove(guiName: string, destroy: boolean?)
	--[[ Checks ]]

	if not storedGUIs[guiName] then
		warn(`[{_localName}::{script.Name}]: ({guiName}) is not a valid ScreenGui name!`)
		return
	end

	--[[ Removing From Command Dictionary ]]

	I.AdminPanel_CommandBar.UpdateDictionary("UserInterface_GuiNames", nil, { guiName })
	I.Topic.Publish("UserInterface_UIRemoved", guiName)

	--[[ Removing ]]

	if storedGUIs[guiName] then
		if destroy then
			storedGUIs[guiName]:Destroy()
		end

		storedGUIs[guiName] = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Change Visibility

--[[
	**CLIENT** |
	Changes visibility of a ScreenGui.
]]
function Module.ChangeVisibility(guiName: string, state: boolean)
	if not storedGUIs[guiName] then
		return false
	end

	-- Updating visibility
	storedGUIs[guiName].Enabled = state == true

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
