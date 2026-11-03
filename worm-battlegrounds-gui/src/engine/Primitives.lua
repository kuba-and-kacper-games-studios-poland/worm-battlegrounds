--[[
	Created By: 	Nari
]]

local _localName: string = "Primitives"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local CreateDir: ModuleScript = script.Parent:FindFirstChild("Libs"):FindFirstChild("Mirror"):FindFirstChild("Create")
local CreateScripts: Folder = CreateDir:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Libs

local PropertyIndex = require(CreateScripts:FindFirstChild("PropertyIndex")) --- @type Create_PropertyIndex
local ValueMatchesProperty = require(CreateScripts:FindFirstChild("ValueMatchesProperty")) --- @type Create_ValueMatchesProperty

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Defaults ]]

local GUI_OBJECT = { BackgroundTransparency = 1, BorderSizePixel = 0 } --- @type { [string]: any }
local TEXT = { BackgroundTransparency = 1, BorderSizePixel = 0, RichText = true, Text = "", TextScaled = true, TextXAlignment = Enum.TextXAlignment.Left } --- @type { [string]: any }

-- Classes the gui rules forbid, with what to use instead
local FORBIDDEN = { --- @type { [string]: string }
	TextButton = "use an ImageButton with a TextLabel inside (the button structure in the gui rules)",
}

-- Properties every instance of a class starts with, before the caller's own
local DEFAULTS = { --- @type { [string]: { [string]: any } }
	Frame = GUI_OBJECT,
	CanvasGroup = GUI_OBJECT,
	ScrollingFrame = GUI_OBJECT,
	ImageLabel = { BackgroundTransparency = 1, BorderSizePixel = 0, Image = "" },
	ViewportFrame = GUI_OBJECT,
	ImageButton = { BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false, Image = "" },
	TextLabel = TEXT,
	TextBox = { BackgroundTransparency = 1, BorderSizePixel = 0, ClearTextOnFocus = false, RichText = true, Text = "", TextScaled = true, TextXAlignment = Enum.TextXAlignment.Left },
	ScreenGui = { IgnoreGuiInset = true, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling },
	UIListLayout = { SortOrder = Enum.SortOrder.LayoutOrder },
	UIGridLayout = { SortOrder = Enum.SortOrder.LayoutOrder },
	UIStroke = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border },
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

--- @class UmeGui_Primitives
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Create

--[[
	Creates an instance of the class with its defaults, then the given properties. `Parent` is applied last.
]]
--- @param props { [string]: any } | nil
--- @return Instance
function Module.Create(className: string, props)
	--[[ Checks ]]

	-- Check if the gui rules allow the class
	if FORBIDDEN[className] then
		error(`{className} is not allowed: {FORBIDDEN[className]}`, 0)
	end

	--[[ Creating ]]

	local instance: Instance = Instance.new(className)

	--[[ Applying ]]

	Module.Apply(instance, DEFAULTS[className], className)
	Module.Apply(instance, props, className)

	--[[ Checks ]]

	-- Text always scales and accepts rich text, so it can be formatted later
	if (instance:IsA("TextLabel") or instance:IsA("TextBox")) and not (instance.TextScaled and instance.RichText) then
		error(`{className} must keep TextScaled and RichText on (the text rule in the gui rules)`, 0)
	end

	--[[ Returning ]]

	return instance
end

--%%%%%%%%%%%%%%%%%%%% Create Plain

--[[
	Creates an instance of the class with Roblox's own defaults only, for a gui's Primitive nodes: their Props hold every
	value, and nothing else is added (no transparent background, no scaled text).
]]
--- @return Instance
function Module.CreatePlain(className: string)
	--[[ Checks ]]

	-- Check if the gui rules allow the class
	if FORBIDDEN[className] then
		error(`{className} is not allowed: {FORBIDDEN[className]}`, 0)
	end

	--[[ Returning ]]

	return Instance.new(className)
end

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Writes properties onto an instance after checking each one exists, is writable and has the right type.
	`where` prefixes errors so a gui author can find the node. `Parent` is applied last.
]]
--- @param props { [string]: any } | nil
function Module.Apply(instance: Instance, props, where: string)
	--[[ Checks ]]

	-- Nothing to write
	if not props then
		return
	end

	--[[ Data ]]

	local propertyIndex = PropertyIndex.GetPropertyIndex(instance.ClassName) --- @type { [string]: Create_PropertyInfo }
	local parent: Instance? = nil

	--[[ Applying ]]

	for propertyName: string, value: any in pairs(props) do
		local info = propertyIndex[propertyName] --- @type Create_PropertyInfo?

		-- Check if the property exists
		if not info then
			error(`{where}: "{propertyName}" is not a property of {instance.ClassName}`, 0)
		end

		-- Check if the property can be written
		if not info.Writable then
			error(`{where}: "{propertyName}" is read-only on {instance.ClassName}`, 0)
		end

		-- Check if the value has the expected type
		if not ValueMatchesProperty.Matches(info, value) then
			error(`{where}: "{propertyName}" expects {info.EnumType or info.ScriptType}, got {typeof(value)}`, 0)
		end

		-- Hold Parent until every other property is set
		if propertyName == "Parent" then
			parent = value
			continue
		end

		instance[propertyName] = value
	end

	--[[ Parenting ]]

	if parent then
		instance.Parent = parent
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Forbidden Reason

--[[
	Returns why the gui rules forbid a class, or nil when it is allowed.
]]
--- @return string?
function Module.GetForbiddenReason(className: string)
	return FORBIDDEN[className]
end

return Module
