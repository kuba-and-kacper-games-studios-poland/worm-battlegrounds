--[[
	Created By: 	Nari
]]

local _localName: string = "UmeGui"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local Engine: Folder = script:FindFirstChild("Engine")
local Guis: Folder = script:FindFirstChild("Guis")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Engine

local Build = require(Engine:FindFirstChild("Build")) --- @type UmeGui_Engine_Build
local Device = require(Engine:FindFirstChild("Device")) --- @type UmeGui_Engine_Device
local Primitives = require(script:FindFirstChild("Primitives")) --- @type UmeGui_Primitives
local Theme = require(Engine:FindFirstChild("Theme")) --- @type UmeGui_Engine_Theme
local Validate = require(Engine:FindFirstChild("Validate")) --- @type UmeGui_Engine_Validate

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

--- @class UmeGui
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Build

--[[
	Builds a gui (a path under `Guis/` or a gui table) and returns its View. Nothing is parented.
]]
--- @param gui string | UmeGui_Gui
--- @param options UmeGui_BuildOptions | nil
--- @return UmeGui_View
function Module.Build(gui, options)
	return Build.Gui(Module._resolve(gui), options)
end

--%%%%%%%%%%%%%%%%%%%% Export

--[[
	Builds a static copy of a gui inside a ScreenGui named after it: no engine behaviour,
	only instances and the framework tags that animate them in game. Every prefab ships hidden as "PREFAB | Name"
	inside its template's Parent element (or the ScreenGui), for game scripts to clone. The gui's `Screen` props and
	`ScreenTags` go on the ScreenGui, and the elements in the view's Root Folder go straight into it.
]]
--- @param gui string | UmeGui_Gui
--- @param mode UmeGui_Mode | nil
--- @return ScreenGui
function Module.Export(gui, mode)
	--[[ Data ]]

	local guiTable = Module._resolve(gui) --- @type UmeGui_Gui
	local view = Build.Gui(guiTable, { Mode = mode, Interactive = false }) --- @type UmeGui_View
	local name: string = guiTable.Name or (if type(gui) == "string" then string.match(gui, "[^/]+$") else "Gui")

	--[[ Wrapping ]]

	local screenGui: ScreenGui = Primitives.Create("ScreenGui", { Name = name })
	Primitives.Apply(screenGui, guiTable.Screen, "Screen")

	--- @param attributes { [string]: any }
	for tag: string, attributes in pairs(guiTable.ScreenTags or {}) do
		screenGui:AddTag(tag)
		for attributeName: string, value: any in pairs(attributes) do
			screenGui:SetAttribute(attributeName, value)
		end
	end

	-- The view's Root Folder stays behind: its elements go straight into the ScreenGui
	for _index: number, child: Instance in ipairs(view.Root:GetChildren()) do
		child.Parent = screenGui
	end

	-- Instances the root control keeps beside itself in the ScreenGui (a widget's MouseLockFix)
	for _index: number, sibling: Instance in ipairs(view.RootHandle.Siblings or {}) do
		sibling.Parent = screenGui
	end

	--[[ Prefabs ]]

	--- @param template UmeGui_Node
	for templateName: string, template in pairs(guiTable.Templates or {}) do
		local prefab = view:Build(templateName, screenGui) --- @type UmeGui_Subview
		local holder = if template.Parent then view:Get(template.Parent) else nil --- @type UmeGui_Handle?
		local instance: GuiObject = prefab.Root.Instance

		-- Straight into the holder's slot: the holder's own placement logic is for live rows
		instance.Name = templateName
		instance.Visible = false
		instance.Parent = if holder then holder.Slot or holder.Instance else screenGui
	end

	--[[ Returning ]]

	return screenGui
end

--%%%%%%%%%%%%%%%%%%%% Apply Device

--[[
	Shows a built view the way the game does on a device ("Desktop", "Mobile", "Console" or "VR"): sizes, scales and
	visibility from the framework's platform tags and console key hints. On Console its gamepad icons show `pad`
	("Xbox", the default, or "PlayStation"). Prefab clones built into the view later show on it too, and applying
	another device restores what this one changed. Exports never change.
]]
--- @param view UmeGui_View
--- @param device UmeGui_Device
--- @param pad UmeGui_Pad | nil
function Module.ApplyDevice(view, device, pad)
	--[[ Applying ]]

	Device.Apply(view, device, pad)
end

--%%%%%%%%%%%%%%%%%%%% Resolve

--[[
	Returns the gui table for a path, or the table itself.
]]
--- @param gui string | UmeGui_Gui
--- @return UmeGui_Gui
function Module._resolve(gui)
	return if type(gui) == "string" then Module.GetGui(gui) else gui
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Gui

--[[
	Returns the table a gui module under `Guis/` returns, by its path ("Plugin/Ume").
]]
--- @return UmeGui_Gui
function Module.GetGui(path: string)
	return require(Module._find(path))
end

--%%%%%%%%%%%%%%%%%%%% Get Preview

--[[
	Returns what a gui's `Preview` child module returns (the Gui tool's preview settings for it), or nil when it has none.
]]
--- @return UmeGui_PreviewModule?
function Module.GetPreview(path: string)
	--[[ Data ]]

	local preview: Instance? = Module._find(path):FindFirstChild("Preview")

	--[[ Checks ]]

	-- Check if the gui has a preview module
	if not preview or not preview:IsA("ModuleScript") then
		return nil
	end

	--[[ Returning ]]

	return require(preview)
end

--%%%%%%%%%%%%%%%%%%%% Get Devices

--[[
	Returns the devices a built view's gui supports: its `Devices`, or else Desktop plus every device its platform
	rules treat differently from Desktop. A gui with more than one looks different per device.
]]
--- @param view UmeGui_View
--- @return { UmeGui_Device }
function Module.GetDevices(view)
	return Device.GetDevices(view)
end

--%%%%%%%%%%%%%%%%%%%% Get Gui Names

--[[
	Returns the path of every gui module under `Guis/`, sorted.
]]
--- @return { string }
function Module.GetGuiNames()
	--[[ Local Variables ]]

	local names = {} --- @type { string }

	--[[ Finding ]]

	for _index: number, descendant: Instance in ipairs(Guis:GetDescendants()) do
		-- Skip folders, and modules inside a gui module (its Preview)
		if not descendant:IsA("ModuleScript") or descendant.Parent:IsA("ModuleScript") then
			continue
		end

		local relative: string = string.sub(descendant:GetFullName(), #Guis:GetFullName() + 2)
		table.insert(names, (string.gsub(relative, "%.", "/")))
	end

	--[[ Returning ]]

	table.sort(names)
	return names
end

--%%%%%%%%%%%%%%%%%%%% Get Errors

--[[
	Returns every schema problem in a gui without building it. Empty when the gui is valid.
]]
--- @param gui string | UmeGui_Gui
--- @return { string }
function Module.GetErrors(gui)
	--[[ Data ]]

	local guiTable = Module._resolve(gui) --- @type UmeGui_Gui
	local theme = Theme.Get(type(guiTable) == "table" and guiTable.Theme or "System") --- @type UmeGui_Theme

	--[[ Returning ]]

	return Validate.GetGuiErrors(guiTable, theme, Build.FindControl)
end

--%%%%%%%%%%%%%%%%%%%% Get Theme Names

--[[
	Returns the name of every theme.
]]
--- @return { string }
function Module.GetThemeNames()
	return Theme.GetNames()
end

--%%%%%%%%%%%%%%%%%%%% Get Version

--[[
	Returns this UmeGui's version.
]]
--- @return string
function Module.GetVersion()
	return script:FindFirstChild("Version").Value
end

--%%%%%%%%%%%%%%%%%%%% Find

--[[
	Returns the gui module under `Guis/` at a path ("Plugin/Ume").
]]
--- @return ModuleScript
function Module._find(path: string)
	--[[ Local Variables ]]

	local current: Instance = Guis

	--[[ Finding ]]

	for part: string in string.gmatch(path, "[^/]+") do
		local child: Instance? = current:FindFirstChild(part)

		-- Check if this part of the path exists
		if not child then
			error(`[{_localName}]: Gui ({path}) does not exist in Guis!`, 3)
		end

		current = child
	end

	-- Check if the path ends on a gui module
	if not current:IsA("ModuleScript") then
		error(`[{_localName}]: Gui ({path}) is not a ModuleScript!`, 3)
	end

	--[[ Returning ]]

	return current
end

return Module
