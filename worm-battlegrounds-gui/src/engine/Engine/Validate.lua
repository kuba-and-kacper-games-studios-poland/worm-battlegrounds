--[[
	Created By: 	Nari
]]

local _localName: string = "Validate"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Engine

local Primitives = require(script.Parent.Parent:FindFirstChild("Primitives")) --- @type UmeGui_Primitives

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Schema ]]

-- Keys every node may use, whatever its control
local COMMON_KEYS = { --- @type { [string]: string }
	Control = "string?",
	Primitive = "string?",
	Id = "string?",
	Style = "string|table?",
	Props = "table?",
	Children = "table?",
	Grow = "number?",
	Visible = "boolean?",
	Tags = "table?",
	Attributes = "table?",
}

-- Keys of the table a gui module returns
local GUI_KEYS = { --- @type { [string]: string }
	Name = "string?",
	Kind = "string?",
	Mappings = "string?",
	Theme = "string?",
	Mode = "string?",
	Modes = "table?",
	Devices = "table?",
	Root = "table",
	Templates = "table?",
	Preview = "table?",
	Screen = "table?",
	ScreenTags = "table?",
}

local MODES = { Night = true, Light = true } --- @type { [string]: boolean }
-- What a gui is drawn on: a ScreenGui, a SurfaceGui on a part, a BillboardGui over a part, a ProximityPrompt's look
local KINDS = { Default = true, Surface = true, Billboard = true, Prompt = true } --- @type { [string]: boolean }
-- The platforms the framework tells apart (`I.Platform.Current`)
local DEVICES = { Desktop = true, Mobile = true, Console = true, VR = true } --- @type { [string]: boolean }

--[[ Names ]]

-- `U_Name`: unique in the whole gui. `S_Name`: unique under its nearest U_ element or prefab
local ID_PATTERN: string = "^([US])_[%a][%w_%-]*$"
-- Template keys, which also name the exported prefab
local PREFAB_PATTERN: string = "^PREFAB | [%a][%w_%-]*$"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Matches Type

--[[
	Returns whether a value fits a type spec such as `"string"`, `"string?"` or `"string|table?"`.
]]
--- @return boolean
local function matchesType(spec: string, value: any)
	--[[ Local Variables ]]

	local optional: boolean = string.sub(spec, -1) == "?"
	local types: string = if optional then string.sub(spec, 1, -2) else spec

	--[[ Checks ]]

	-- Optional keys may be left out
	if value == nil then
		return optional
	end

	--[[ Matching ]]

	for typeName: string in string.gmatch(types, "[^|]+") do
		if typeof(value) == typeName then
			return true
		end
	end

	--[[ Returning ]]

	return false
end

--%%%%%%%%%%%%%%%%%%%% Sorted Keys

--[[
	Returns a table's string keys, sorted, for readable error hints.
]]
--- @param source { [string]: any }
--- @return string
local function sortedKeys(source)
	--[[ Local Variables ]]

	local keys = {} --- @type { string }

	--[[ Collecting ]]

	for key: string, _value: any in pairs(source) do
		table.insert(keys, key)
	end
	table.sort(keys)

	--[[ Returning ]]

	return table.concat(keys, ", ")
end

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

--- @class UmeGui_Engine_Validate
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Gui Errors

--[[
	Returns every problem in a gui module's table, including its templates.
]]
--- @param gui UmeGui_Gui
--- @param theme UmeGui_Theme
--- @param findControl (controlName: string, theme: UmeGui_Theme | nil) -> UmeGui_Control?
--- @return { string }
function Module.GetGuiErrors(gui, theme, findControl)
	--[[ Local Variables ]]

	local errors = {} --- @type { string }

	--[[ Checks ]]

	-- Check if the module returned a table
	if type(gui) ~= "table" then
		return { `gui module must return a table, got {typeof(gui)}` }
	end

	--[[ Keys ]]

	for key: any, value: any in pairs(gui) do
		-- Check if the key is part of the gui schema
		if not GUI_KEYS[key] then
			table.insert(errors, `unknown gui key "{tostring(key)}" (expected one of: {sortedKeys(GUI_KEYS)})`)
		elseif not matchesType(GUI_KEYS[key], value) then
			table.insert(errors, `gui key "{key}" expects {GUI_KEYS[key]}, got {typeof(value)}`)
		end
	end

	-- Check if Root is present
	if gui.Root == nil then
		table.insert(errors, `gui is missing "Root"`)
	end

	-- Check if Kind is a known kind
	if gui.Kind ~= nil and not KINDS[gui.Kind] then
		table.insert(errors, `gui Kind must be "Default", "Surface", "Billboard" or "Prompt", got "{tostring(gui.Kind)}"`)
	end

	-- Check if Mappings is only on a Prompt gui
	if gui.Mappings ~= nil and gui.Kind ~= "Prompt" then
		table.insert(errors, `gui Mappings is only for Prompt guis (Kind = "Prompt")`)
	end

	-- Check if Mode is a known mode
	if gui.Mode ~= nil and not MODES[gui.Mode] then
		table.insert(errors, `gui Mode must be "Night" or "Light", got "{tostring(gui.Mode)}"`)
	end

	-- Check if Modes lists known modes, and holds Mode
	if type(gui.Modes) == "table" then
		-- Check if Modes lists any mode
		if #gui.Modes == 0 then
			table.insert(errors, `gui Modes must list at least one mode`)
		end

		for index: number, mode: any in ipairs(gui.Modes) do
			-- Check if the mode is known
			if not MODES[mode] then
				table.insert(errors, `gui Modes[{index}] must be "Night" or "Light", got "{tostring(mode)}"`)
			end
		end

		-- Check if the default Mode is one of them
		if gui.Mode ~= nil and not table.find(gui.Modes, gui.Mode) then
			table.insert(errors, `gui Mode "{tostring(gui.Mode)}" is not in Modes`)
		end
	end

	-- Check if Devices lists known devices
	if type(gui.Devices) == "table" then
		-- Check if Devices lists any device
		if #gui.Devices == 0 then
			table.insert(errors, `gui Devices must list at least one device`)
		end

		for index: number, device: any in ipairs(gui.Devices) do
			-- Check if the device is known
			if not DEVICES[device] then
				table.insert(errors, `gui Devices[{index}] must be "Desktop", "Mobile", "Console" or "VR", got "{tostring(device)}"`)
			end
		end
	end

	-- Check if Preview gives a positive Width and Height
	if type(gui.Preview) == "table" then
		for _index: number, side: string in ipairs({ "Width", "Height" }) do
			local value: any = gui.Preview[side]
			if type(value) ~= "number" or value <= 0 then
				table.insert(errors, `gui Preview.{side} must be a number above 0, got {tostring(value)}`)
			end
		end
	end

	--[[ Tree ]]

	local unique = {} --- @type { [string]: string }
	if type(gui.Root) == "table" then
		Module.CollectNodeErrors(gui.Root, "Root", theme, findControl, { Unique = unique, Prefab = false }, errors)
	end

	--[[ Templates ]]

	--- @param template UmeGui_Node
	for templateName: any, template in pairs(type(gui.Templates) == "table" and gui.Templates or {}) do
		local path: string = `Templates["{tostring(templateName)}"]`

		-- Check if the template is named as a prefab
		if type(templateName) ~= "string" or not string.match(templateName, PREFAB_PATTERN) then
			table.insert(errors, `{path}: template keys are prefab names, "PREFAB | <Name>"`)
		end

		-- Skip the node checks for something that is not a node
		if type(template) ~= "table" then
			table.insert(errors, `{path}: template must be a table, got {typeof(template)}`)
			continue
		end

		-- The prefab root is named by its key
		if template.Id ~= nil then
			table.insert(errors, `{path}: a prefab root takes no Id; it is named by its template key`)
		end

		-- Parent names the U_ element the exported prefab sits in (and runtime builds default to)
		if template.Parent ~= nil and (type(template.Parent) ~= "string" or not unique[template.Parent]) then
			table.insert(errors, `{path}: Parent must be the Id of a U_ element in Root, got {tostring(template.Parent)}`)
		end

		local node = table.clone(template) --- @type UmeGui_Node
		node.Parent = nil
		node.Id = nil
		Module.CollectNodeErrors(node, path, theme, findControl, { Unique = {}, Local = {}, Owner = tostring(templateName), Prefab = true }, errors)
	end

	--[[ Returning ]]

	return errors
end

--%%%%%%%%%%%%%%%%%%%% Collect Node Errors

--[[
	Checks one node and its children, appending problems to `errors`. `scope` holds the Ids already used: the U_ Ids
	of the whole gui and the S_ Ids of the nearest U_ element or prefab.
]]
--- @param node UmeGui_Node
--- @param theme UmeGui_Theme
--- @param findControl (controlName: string, theme: UmeGui_Theme | nil) -> UmeGui_Control?
--- @param scope UmeGui_IdScope
--- @param errors { string }
function Module.CollectNodeErrors(node, path: string, theme, findControl, scope, errors)
	--[[ Checks ]]

	-- Check if the node is a table
	if type(node) ~= "table" then
		table.insert(errors, `{path}: node must be a table, got {typeof(node)}`)
		return
	end

	--[[ Local Variables ]]

	local label: string = `{path}{if type(node.Id) == "string" then ` ({node.Id})` else ""}`
	local control = if type(node.Control) == "string" then findControl(node.Control, theme) else nil --- @type UmeGui_Control?

	--[[ Kind ]]

	-- Check if the node names exactly one control or primitive
	if (node.Control == nil) == (node.Primitive == nil) then
		table.insert(errors, `{label}: set exactly one of "Control" or "Primitive"`)
	elseif node.Control ~= nil and not control then
		table.insert(errors, `{label}: unknown Control "{tostring(node.Control)}"`)
	elseif type(node.Primitive) == "string" and Primitives.GetForbiddenReason(node.Primitive) then
		table.insert(errors, `{label}: Primitive "{node.Primitive}" is not allowed: {Primitives.GetForbiddenReason(node.Primitive)}`)
	elseif type(node.Primitive) == "string" and not pcall(Instance.new, node.Primitive) then
		table.insert(errors, `{label}: unknown Primitive class "{node.Primitive}"`)
	end

	--[[ Keys ]]

	local params = if control then control.Params else {} --- @type { [string]: string }
	for key: any, value: any in pairs(node) do
		local spec: string? = COMMON_KEYS[key] or params[key]

		-- Check if the key is known for this node
		if not spec then
			local known: string = if control then `{sortedKeys(params)}, ` else ""
			table.insert(errors, `{label}: unknown param "{tostring(key)}" (known: {known}{sortedKeys(COMMON_KEYS)})`)
		elseif not matchesType(spec, value) then
			table.insert(errors, `{label}: "{key}" expects {spec}, got {typeof(value)}`)
		end
	end

	--[[ Required ]]

	for key: string, spec: string in pairs(params) do
		-- Check if a required param is missing
		if string.sub(spec, -1) ~= "?" and node[key] == nil then
			table.insert(errors, `{label}: missing required param "{key}" ({spec})`)
		end
	end

	--[[ Id ]]

	local childScope = scope --- @type UmeGui_IdScope
	if type(node.Id) == "string" then
		local kind: string? = string.match(node.Id, ID_PATTERN)

		-- Check if the Id is a U_ or S_ name
		if not kind then
			table.insert(errors, `{label}: Id must be "U_<Name>" (unique in the gui) or "S_<Name>" (unique under its U_ element or prefab)`)

		-- A U_ Id is unique in the gui and opens a scope for the S_ Ids under it
		elseif kind == "U" then
			if scope.Prefab then
				table.insert(errors, `{label}: U_ Ids cannot be inside a prefab, since every clone would repeat them; use S_`)
			elseif scope.Unique[node.Id] then
				table.insert(errors, `{label}: Id "{node.Id}" is already used at {scope.Unique[node.Id]}`)
			else
				scope.Unique[node.Id] = path
			end
			childScope = { Unique = scope.Unique, Local = {}, Owner = node.Id, Prefab = scope.Prefab }

		-- An S_ Id is unique under its U_ element or prefab
		elseif not scope.Local then
			table.insert(errors, `{label}: S_ Ids must be inside a U_ element or a prefab`)
		elseif scope.Local[node.Id] then
			table.insert(errors, `{label}: Id "{node.Id}" is already used under {scope.Owner} at {scope.Local[node.Id]}`)
		else
			scope.Local[node.Id] = path
		end
	end

	-- A node named as a prefab inside a prefab is a nested prefab, with its own scope for the S_ Ids under it
	local props: any = node.Props
	if scope.Prefab and type(props) == "table" and type(props.Name) == "string" and string.match(props.Name, PREFAB_PATTERN) then
		childScope = { Unique = scope.Unique, Local = {}, Owner = props.Name, Prefab = true }
	end

	--[[ Tags ]]

	if type(node.Tags) == "table" then
		for tag: any, attributes: any in pairs(node.Tags) do
			-- Check if each tag maps to its attributes
			if type(tag) ~= "string" or type(attributes) ~= "table" then
				table.insert(errors, `{label}: Tags maps a tag name to a table of its attributes, got {tostring(tag)} = {typeof(attributes)}`)
			end
		end
	end

	--[[ Style ]]

	if control and node.Style ~= nil then
		Module.CollectStyleErrors(node.Style, node.Control, label, theme, errors)
	end

	--[[ Children ]]

	if type(node.Children) == "table" then
		-- Check if the control can hold children
		if control and not control.Children then
			table.insert(errors, `{label}: {node.Control} does not take Children`)
		end

		for index: number, child: any in ipairs(node.Children) do
			Module.CollectNodeErrors(child, `{path}.Children[{index}]`, theme, findControl, childScope, errors)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Collect Style Errors

--[[
	Checks a node's `Style`: every variant must exist and every override key must be a key of the control's Default style.
]]
--- @param spec string | { [any]: any }
--- @param theme UmeGui_Theme
--- @param errors { string }
function Module.CollectStyleErrors(spec, controlName: string, label: string, theme, errors)
	--[[ Data ]]

	local variants = theme.Styles[controlName] --- @type { [string]: UmeGui_Style }?

	-- Check if the theme styles this control
	if not variants or not variants.Default then
		table.insert(errors, `{label}: theme "{theme.Name}" has no styles for {controlName}`)
		return
	end

	--[[ Local Variables ]]

	local variantNames = if type(spec) == "string" then { spec } else spec --- @type { [any]: any }

	--[[ Checking ]]

	for key: any, value: any in pairs(variantNames) do
		-- Check if a listed variant exists
		if type(key) == "number" and not variants[value] then
			table.insert(errors, `{label}: {controlName} has no style variant "{tostring(value)}" (variants: {sortedKeys(variants)})`)

		-- Check if an override key is part of the style
		elseif type(key) == "string" and variants.Default[key] == nil then
			table.insert(errors, `{label}: {controlName} style has no key "{key}" (keys: {sortedKeys(variants.Default)})`)
		end
	end
end

return Module
