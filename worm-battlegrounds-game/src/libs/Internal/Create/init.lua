--[[
    Created By:     Nari
]]

local _localName = "Create"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local PropertyIndex = require(_scripts:FindFirstChild("PropertyIndex")) --- @type Create_PropertyIndex
local ValueMatchesProperty = require(_scripts:FindFirstChild("ValueMatchesProperty")) --- @type Create_ValueMatchesProperty

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Create Factory

--[[
	Returns a factory that creates `class`, applies attributes, then validated properties.
	Called through the library: `I.Create("Part")({ Anchored = true }, { Tagged = true })`.
	Unknown, read-only, or mismatched properties warn and are skipped. `Parent` is applied last.
]]
--- @return Create_Factory
local function createFactory(_self, class: string)
	--[[ Data ]]

	local propertyIndex = PropertyIndex.GetPropertyIndex(class) --- @type { [string]: Create_PropertyInfo }?

	--[[ Checks ]]

	-- Check if the class could be read
	if not propertyIndex then
		error(`[{_localName}::{script.Name}]: Unknown class ({class})!`, 2)
	end

	--%%%%%%%%%%%%%%%%%%%% Factory

	--[[
		Creates the instance with the given properties and attributes.
	]]
	--- @param properties { [string]: any }?
	--- @param attributes { [string]: any }?
	--- @return Instance
	local function factory(properties, attributes)
		--[[ Creating ]]

		local instance: any = Instance.new(class)
		local parent: Instance? = nil

		--[[ Attributes ]]

		for attributeName: string, value: any in pairs(attributes or {}) do
			instance:SetAttribute(attributeName, value)
		end

		--[[ Properties ]]

		for propertyName: string, value: any in pairs(properties or {}) do
			local info = propertyIndex[propertyName] --- @type Create_PropertyInfo?

			-- Check if the property exists
			if not info then
				warn(`[{_localName}::{script.Name}]: Unknown property ({propertyName}) for class ({class})!`)
				continue
			end

			-- Check if the property is writable
			if not info.Writable then
				warn(`[{_localName}::{script.Name}]: Property ({propertyName}) is not writable on ({class})!`)
				continue
			end

			-- Check if the value has the expected type
			if not ValueMatchesProperty.Matches(info, value) then
				warn(`[{_localName}::{script.Name}]: Invalid type for ({propertyName}) on ({class}), expected ({info.ScriptType}), got ({typeof(value)})!`)
				continue
			end

			-- Hold Parent so it is applied after every other property
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

		--[[ Returning ]]

		return instance
	end

	--[[ Returning ]]

	return factory
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

--- @class Ume_Library_Create : Ume_Library
local Create = setmetatable({}, {
	__call = createFactory,
})

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Assigns this library onto Ume.
]]
--- @param umeInstance Ume
function Create._injectUme(umeInstance)
	--- @type Ume
	local I = umeInstance

	--[[ Assigning ]]

	I.Create = Create --- @type Ume_Library_Create
end

return Create
