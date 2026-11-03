--[[
	Created By: 	Nari
]]

local _localName: string = "Build"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local Engine: Folder = script.Parent
local UmeGui: ModuleScript = Engine.Parent
local Controls: Folder = UmeGui:FindFirstChild("Controls")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local RunService: RunService = game:GetService("RunService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Engine

local Context = require(Engine:FindFirstChild("Context")) --- @type UmeGui_Engine_Context
local Device = require(Engine:FindFirstChild("Device")) --- @type UmeGui_Engine_Device
local Primitives = require(UmeGui:FindFirstChild("Primitives")) --- @type UmeGui_Primitives
local Style = require(Engine:FindFirstChild("Style")) --- @type UmeGui_Engine_Style
local Theme = require(Engine:FindFirstChild("Theme")) --- @type UmeGui_Engine_Theme
local Validate = require(Engine:FindFirstChild("Validate")) --- @type UmeGui_Engine_Validate
local Signal = require(UmeGui:FindFirstChild("Libs"):FindFirstChild("Mirror"):FindFirstChild("GoodSignal")) --- @type UmeGui_Signal

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local DEFAULT_THEME: string = "System"
local DEFAULT_MODE: string = "Night"

local controlModules = {} --- @type { [ModuleScript]: UmeGui_Control }

-- Instance names that mark a prefab nested inside another prefab
local PREFAB_NAME_PATTERN: string = "^PREFAB | "

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

--- @class UmeGui_Engine_Build
local Module = {}

--- @class UmeGui_Engine_View
local View = {}
View.__index = View

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Gui

--[[
	Validates and builds a gui table. Errors list every schema problem with its node path.
]]
--- @param gui UmeGui_Gui
--- @param options UmeGui_BuildOptions | nil
--- @return UmeGui_View
function Module.Gui(gui, options)
	--[[ Data ]]

	local buildOptions = options or {} --- @type UmeGui_BuildOptions
	local theme = Theme.Get(type(gui) == "table" and gui.Theme or DEFAULT_THEME) --- @type UmeGui_Theme

	--[[ Checks ]]

	local errors = Validate.GetGuiErrors(gui, theme, Module.FindControl) --- @type { string }

	-- Check if the gui table is valid
	if #errors > 0 then
		error(table.concat(errors, "\n"), 0)
	end

	--[[ View ]]

	local view = setmetatable({ --- @type UmeGui_View
		Gui = gui,
		Theme = theme,
		Ids = {},
		Scoped = {},
		Mode = buildOptions.Mode or gui.Mode or DEFAULT_MODE,
		Interactive = buildOptions.Interactive ~= false,
		Tokens = table.clone(buildOptions.Tokens or {}),
		ModeChanged = Signal.new(),
		_scopes = {},
	}, View)

	--[[ Building ]]

	local scope = Module._createScope(view) --- @type UmeGui_Scope
	local rootHandle = Module.Node(view, scope, gui.Root, "Root", view.Ids, 0) --- @type UmeGui_Handle
	local rootFolder: Instance = rootHandle.Instance

	-- Every gui sits in a Folder named Root: a Folder root becomes it, any other root goes inside a new one
	if not rootFolder:IsA("Folder") then
		rootFolder = Primitives.CreatePlain("Folder")
		rootHandle.Instance.Parent = rootFolder
	end
	rootFolder.Name = "Root"
	view.Root = rootFolder
	view.RootHandle = rootHandle

	--[[ Returning ]]

	return view
end

--%%%%%%%%%%%%%%%%%%%% Node

--[[
	Builds one node and its children inside a scope. U_ Ids are registered in `ids`, and each U_ element gets its own
	table in `view.Scoped` for the S_ Ids under it; S_ Ids go into `scoped`, the table of the nearest U_ element or
	prefab. A node named "PREFAB | Name" inside a prefab is a nested prefab with its own S_ scope.
]]
--- @param view UmeGui_View
--- @param scope UmeGui_Scope
--- @param node UmeGui_Node
--- @param ids { [string]: UmeGui_Handle }
--- @param scoped { [string]: UmeGui_Handle } | nil
--- @return UmeGui_Handle
function Module.Node(view, scope, node, path: string, ids, layoutOrder: number, scoped)
	--[[ Building ]]

	local handle --- @type UmeGui_Handle

	-- A primitive is a plain Roblox instance: its Props hold every value
	if node.Primitive then
		local instance: Instance = Primitives.CreatePlain(node.Primitive)
		handle = { Instance = instance, Slot = instance }
	else
		local control = Module.FindControl(node.Control, view.Theme) --- @type UmeGui_Control
		local style = Style.Resolve(view.Theme, node.Control, node.Style) --- @type UmeGui_Style

		local success: boolean
		local result: any | string?
		success, result = pcall(control.Build, node, style, scope.Context)

		-- Name the node when its control fails to build
		if not success then
			error(`{path}{if node.Id then ` ({node.Id})` else ""}: {result}`, 0)
		end

		handle = result
	end

	--[[ Common Keys ]]

	local instance: GuiObject = handle.Instance
	instance.Name = node.Id or node.Control or node.Primitive

	-- UI modifiers (UICorner, UIStroke, …) have no layout order or visibility
	if instance:IsA("GuiObject") then
		instance.LayoutOrder = layoutOrder
		instance.Visible = node.Visible ~= false
	end

	local childScoped = scoped --- @type { [string]: UmeGui_Handle }?
	if node.Id and string.sub(node.Id, 1, 2) == "U_" then
		ids[node.Id] = handle
		childScoped = {}
		view.Scoped[node.Id] = childScoped
	elseif node.Id and scoped then
		scoped[node.Id] = handle
	end
	if node.Grow then
		Primitives.Create("UIFlexItem", {
			FlexMode = Enum.UIFlexMode.Custom,
			GrowRatio = node.Grow,
			ShrinkRatio = node.Grow,
			Parent = instance,
		})
	end

	Primitives.Apply(instance, node.Props, path)

	-- Framework tags go on the pressable part of a control that has one, so they animate the button
	if node.Tags then
		scope.Context.Tag(handle.Button or instance, node.Tags)
	end
	for attributeName: string, value: any in pairs(node.Attributes or {}) do
		instance:SetAttribute(attributeName, value)
	end

	-- A prefab nested inside another prefab keeps the S_ Ids under it to itself
	if scoped and string.match(instance.Name, PREFAB_NAME_PATTERN) then
		childScoped = {}
	end

	--[[ Children ]]

	--- @param childNode UmeGui_Node
	for index: number, childNode in ipairs(node.Children or {}) do
		local childHandle = Module.Node(view, scope, childNode, `{path}.Children[{index}]`, ids, index, childScoped) --- @type UmeGui_Handle

		-- Let the control place the child, or drop it into its slot
		if handle.AddChild then
			handle.AddChild(childHandle, childNode)
		else
			childHandle.Instance.Parent = handle.Slot
		end
	end

	--[[ Returning ]]

	return handle
end

--%%%%%%%%%%%%%%%%%%%% Create Scope

--[[
	Creates a build scope: the refreshers and connections owned by one view or subview, with its own context.
]]
--- @param view UmeGui_View
--- @return UmeGui_Scope
function Module._createScope(view)
	--[[ Creating ]]

	local scope = { Refreshers = {}, Connections = {}, Destroyed = false, Settled = false } --- @type UmeGui_Scope
	scope.Context = Context.Create(view, scope, Module.Node)

	--[[ Saving ]]

	view._scopes[scope] = true

	--[[ Settling ]]

	-- Everything set during the build frame (defaults, restored state) is written at once; animations start after it
	RunService.Heartbeat:Once(function()
		scope.Settled = true
	end)

	--[[ Returning ]]

	return scope
end

--%%%%%%%%%%%%%%%%%%%% Destroy Scope

--[[
	Disconnects a scope's connections and drops its refreshers.
]]
--- @param view UmeGui_View
--- @param scope UmeGui_Scope
function Module._destroyScope(view, scope)
	--[[ Disconnecting ]]

	--- @param connection RBXScriptConnection | UmeGui_Signal_Connection
	for _index: number, connection in ipairs(scope.Connections) do
		connection:Disconnect()
	end

	--[[ Clearing ]]

	table.clear(scope.Connections)
	table.clear(scope.Refreshers)
	scope.Destroyed = true
	view._scopes[scope] = nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Find Control

--[[
	Returns a control module by name: from the theme's own Controls folders first, then the shared `Controls`.
	Nil when none has it.
]]
--- @param theme UmeGui_Theme | nil
--- @return UmeGui_Control?
function Module.FindControl(controlName: string, theme)
	--[[ Finding ]]

	local controlModule: Instance? = nil
	for _index: number, folder: Instance in ipairs(theme and theme.Controls or {}) do
		controlModule = folder:FindFirstChild(controlName)

		-- Stop at the first theme that has it
		if controlModule then
			break
		end
	end
	controlModule = controlModule or Controls:FindFirstChild(controlName)

	--[[ Checks ]]

	-- Check if the control exists
	if not controlModule or not controlModule:IsA("ModuleScript") then
		return nil
	end

	--[[ Saving ]]

	-- Cached per module, so a theme's control never shadows the shared one for other themes
	if not controlModules[controlModule] then
		controlModules[controlModule] = require(controlModule)
	end

	--[[ Returning ]]

	return controlModules[controlModule]
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% View

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns the handle of a U_ element, or with `scopedId` the handle of that S_ element under it.
]]
--- @return UmeGui_Handle
function View:Get(id: string, scopedId: string?)
	--[[ Checks ]]

	-- Check if the U_ element exists
	if not self.Ids[id] then
		error(`[{_localName}]: Gui has no element with Id ({id})!`, 2)
	end

	--[[ Scoped ]]

	if scopedId then
		local scoped = self.Scoped[id] --- @type { [string]: UmeGui_Handle }

		-- Check if the S_ element exists under it
		if not scoped[scopedId] then
			error(`[{_localName}]: {id} has no element with Id ({scopedId})!`, 2)
		end

		return scoped[scopedId]
	end

	--[[ Returning ]]

	return self.Ids[id]
end

--%%%%%%%%%%%%%%%%%%%% Build

--[[
	Builds a prefab ("PREFAB | Name") into a parent (a U_ Id, a handle or an instance; the template's own Parent when
	nil) with `params` laid over the template's keys. The clone is named after the prefab without its prefix and shows
	on the view's device, if one was applied. Returns a subview holding the S_ Ids under it, so clones of one prefab
	never clash.
]]
--- @param parent string | UmeGui_Handle | Instance | nil
--- @param params { [string]: any } | nil
--- @return UmeGui_Subview
function View:Build(templateName: string, parent, params)
	--[[ Data ]]

	local template = self.Gui.Templates and self.Gui.Templates[templateName] --- @type UmeGui_Node?

	-- Check if the template exists
	if not template then
		error(`[{_localName}]: Gui has no template ({templateName})!`, 2)
	end

	--[[ Node ]]

	local node = table.clone(template) --- @type UmeGui_Node
	for key: string, value: any in pairs(params or {}) do
		node[key] = value
	end
	node.Parent = nil

	local path: string = `Templates["{templateName}"]`
	local errors = {} --- @type { string }
	local idScope = { Unique = {}, Local = {}, Owner = templateName, Prefab = true } --- @type UmeGui_IdScope
	Validate.CollectNodeErrors(node, path, self.Theme, Module.FindControl, idScope, errors)

	-- Check if the filled template is valid
	if #errors > 0 then
		error(table.concat(errors, "\n"), 2)
	end

	--[[ Building ]]

	local view = self --- @type UmeGui_View
	local scope = Module._createScope(view) --- @type UmeGui_Scope
	local ids = {} --- @type { [string]: UmeGui_Handle }
	local handle = Module.Node(view, scope, node, path, {}, 0, ids) --- @type UmeGui_Handle
	handle.Instance.Name = string.gsub(templateName, "^PREFAB | ", "")

	--[[ Parenting ]]

	parent = parent or template.Parent
	local parentHandle = if type(parent) == "string" then view:Get(parent) elseif typeof(parent) == "Instance" then nil else parent --- @type UmeGui_Handle?
	local slot: Instance = if parentHandle then parentHandle.Slot else parent

	-- Append after the slot's existing children
	local lastOrder: number = 0
	for _index: number, sibling: Instance in ipairs(slot:GetChildren()) do
		if sibling:IsA("GuiObject") then
			lastOrder = math.max(lastOrder, sibling.LayoutOrder)
		end
	end
	handle.Instance.LayoutOrder = lastOrder + 1

	if parentHandle and parentHandle.AddChild then
		parentHandle.AddChild(handle, node)
	elseif parentHandle then
		handle.Instance.Parent = parentHandle.Slot
	else
		handle.Instance.Parent = parent
	end

	--[[ Device ]]

	-- A clone shows on the view's device from the start, before scripts change it
	Device.ApplyClone(view, handle.Instance)

	--[[ Subview ]]

	local subview = { Root = handle, Ids = ids } --- @type UmeGui_Subview

	--%%%%%%%%%%%%%%%%%%%% Get

	--[[
		Returns the handle of an element inside this subview.
	]]
	--- @return UmeGui_Handle
	function subview.Get(_self, id: string)
		--[[ Checks ]]

		-- Check if the Id exists in this subview
		if not ids[id] then
			error(`[{_localName}]: Template ({templateName}) has no element with Id ({id})!`, 2)
		end

		--[[ Returning ]]

		return ids[id]
	end

	--%%%%%%%%%%%%%%%%%%%% Destroy

	--[[
		Removes the subview's instances and connections.
	]]
	function subview.Destroy(_self)
		--[[ Destroying ]]

		Module._destroyScope(view, scope)
		handle.Instance:Destroy()
	end

	--[[ Returning ]]

	return subview
end

--%%%%%%%%%%%%%%%%%%%% Set Mode

--[[
	Switches every color in the view (and its subviews) to another mode's palette.
]]
--- @param mode UmeGui_Mode
function View:SetMode(mode)
	--[[ Checks ]]

	-- Skip when nothing changes
	if self.Mode == mode then
		return
	end

	--[[ Applying ]]

	self.Mode = mode
	self:_refresh()
	self.ModeChanged:Fire(mode)
end

--%%%%%%%%%%%%%%%%%%%% Set Token

--[[
	Overrides one palette color for this view in every mode (nil restores the theme's color), e.g. a user accent.
]]
function View:SetToken(tokenName: string, color: Color3?)
	--[[ Applying ]]

	self.Tokens[tokenName] = color
	self:_refresh()
end

--%%%%%%%%%%%%%%%%%%%% Destroy

--[[
	Destroys the view's instances and every connection it made.
]]
function View:Destroy()
	--[[ Scopes ]]

	--- @param scope UmeGui_Scope
	for scope, _active: boolean in pairs(self._scopes) do
		Module._destroyScope(self, scope)
	end

	--[[ Destroying ]]

	self.ModeChanged:DisconnectAll()
	self.Root:Destroy()
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Re-applies every token-driven property after a mode or token change.
]]
function View:_refresh()
	--- @param scope UmeGui_Scope
	for scope, _active: boolean in pairs(self._scopes) do
		for _index: number, refresher: () -> () in ipairs(scope.Refreshers) do
			refresher()
		end
	end
end

return Module
