--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "HideOnPlay"

--- @type HideOnPlay_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local CollectionService = I.S.CollectionService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Restore Whitelist ]]

local _allowedRestorePropertyNames: { [string]: boolean } = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Merged Hide Properties

--[[
	Builds a merged table of hide properties for this instance, applying matching classes in configured order so overlapping properties resolve deterministically.
]]
--- @return { [string]: any }?
local function GetMergedHideProperties(instance: Instance)
	local combined = {} --- @type { [string]: any }

	--[[ Match Configured Classes ]]

	for _, className: string in ipairs(_settings.HIDE_PROPERTY_CLASS_ORDER) do
		--- @type { [string]: any }?
		local loopTable = _settings.HIDE_PROPERTIES[className]

		if loopTable and instance:IsA(className) then
			--[[ Apply Class Properties ]]

			for propertyName: string, propertyValue: any in pairs(loopTable) do
				combined[propertyName] = propertyValue
			end
		end
	end

	--[[ Return Result ]]

	if next(combined) == nil then
		return nil
	end
	return combined
end

--%%%%%%%%%%%%%%%%%%%% Hide Parts

--[[
	Hides all instances in the provided table; a Model or Folder hides its descendants instead of itself.
	Only instances passed directly warn when their class has no hide properties.
]]
--- @param t { Instance }
local function HideParts(t, fromContainer: boolean?)
	--[[ Process Instances ]]

	for _, instance: Instance in ipairs(t) do
		--[[ Descend into Containers ]]

		-- Walk a container's descendants once; nested containers are already in that list
		if instance:IsA("Model") or instance:IsA("Folder") then
			if not fromContainer then
				HideParts(instance:GetDescendants(), true)
			end
			continue
		end

		--[[ Skip Server-only Hidden ]]

		-- Skip server-hidden instances on the client
		if I.Env.IsClient and instance:HasTag(_settings.HIDE_TAGS["Server"]) then
			continue
		end

		--[[ Merge Hide Properties ]]

		-- Uses fixed class order so overlapping classes always resolve the same way.
		local propertiesTable = GetMergedHideProperties(instance) --- @type { [string]: any }?

		-- Skip classes with no hide properties, warning only for instances passed directly
		if not propertiesTable then
			if not fromContainer then
				warn(`[{_localName}::{script.Name}]: Properties table not found for ({instance.ClassName})! -`, instance)
			end
			continue
		end

		--[[ Apply Hide Properties ]]

		for propertyName: string, propertyValue: any in pairs(propertiesTable) do
			--[[ Check Property ]]

			local success: boolean
			local result: any | string?
			success, result = pcall(function()
				return instance[propertyName] ~= nil
			end)

			-- Skip properties this instance doesn't have
			if not success or not result then
				continue
			end

			--[[ Apply Hidden Value ]]

			local attributeName: string = `{I.Env.Key}_HideOnPlay_{propertyName}`
			local originalValue: any = instance[propertyName]
			success, result = pcall(function()
				instance[propertyName] = propertyValue
			end)

			--[[ Save Original ]]

			-- Repeated hides must not overwrite the first saved value.
			if success then
				if instance:GetAttribute(attributeName) == nil then
					instance:SetAttribute(attributeName, originalValue)
				end
			else
				warn(`[{_localName}::{script.Name}]: Failed to hide ({propertyName})! - {result} -`, instance)
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Show Parts

--[[
	Shows all instances in the provided table, restoring saved attributes and clearing them after successful writes.
	A Model or Folder shows its descendants instead of itself.
]]
--- @param t { Instance }
local function ShowParts(t, fromContainer: boolean?)
	--[[ Process Instances ]]

	for _, instance: Instance in ipairs(t) do
		--[[ Skip Server-only Hidden ]]

		-- Skip server-hidden instances on the client
		if I.Env.IsClient and instance:HasTag(_settings.HIDE_TAGS["Server"]) then
			continue
		end

		--[[ Descend into Containers ]]

		-- Walk a container's descendants once; nested containers are already in that list
		if instance:IsA("Model") or instance:IsA("Folder") then
			if not fromContainer then
				ShowParts(instance:GetDescendants(), true)
			end
			continue
		end

		--[[ Restore Saved Properties ]]

		for attName: string, attValue: any in pairs(instance:GetAttributes()) do
			--[[ Parse Attribute ]]

			--- @type { string }
			local strParts = string.split(attName, "_HideOnPlay_")

			-- Skip attributes this side's hide didn't write
			if strParts[1] ~= I.Env.Key or not strParts[2] then
				continue
			end

			-- Drop saved values for properties the settings no longer hide
			if not _allowedRestorePropertyNames[strParts[2]] then
				instance:SetAttribute(attName, nil)
				continue
			end

			--[[ Restore Property ]]

			local success: boolean
			local result: any | string?
			success, result = pcall(function()
				instance[strParts[2]] = attValue
			end)

			--[[ Clear Attribute ]]

			-- Keep the saved value when the restore failed
			if success then
				instance:SetAttribute(attName, nil)
			else
				warn(`[{_localName}::{script.Name}]: Failed to restore ({strParts[2]})! - {result} -`, instance)
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Check Parts

--[[
	Re-hides client-tagged instances after the server hide tag is removed, keeping client-only hidden objects hidden.
]]
--- @param t { Instance }
local function CheckParts(t)
	--[[ Check Environment ]]

	if not I.Env.IsClient then
		return
	end

	--[[ Check Tagged Instances ]]

	for _, instance: Instance in ipairs(t) do
		--[[ Tag Checks ]]

		-- Skip if server tag exists
		if instance:HasTag(_settings.HIDE_TAGS["Server"]) then
			continue
		end

		-- Ensure it stays hidden even if showed by server
		if instance:HasTag(_settings.HIDE_TAGS["Client"]) then
			HideParts({ instance })
		end
	end
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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	--[[ Init State ]]

	-- Prepare restore validation before any tagged instances are processed.
	Module._buildRestorePropertyWhitelist()
	Module._validateHidePropertySettings()

	--[[ Hide Existing ]]

	Module.Hide(CollectionService:GetTagged(_settings.HIDE_TAGS[I.Env.Key]))

	--[[ Connect Tags ]]

	CollectionService:GetInstanceAddedSignal(_settings.HIDE_TAGS[I.Env.Key]):Connect(function(instance: Instance)
		HideParts({ instance })
	end)
	CollectionService:GetInstanceRemovedSignal(_settings.HIDE_TAGS[I.Env.Key]):Connect(function(instance: Instance)
		ShowParts({ instance })
	end)

	--[[ Opposite Env Check ]]

	-- When server tag is removed - check if client tag exists then hide the element so it stays hidden
	if I.Env.IsClient then
		CollectionService:GetInstanceRemovedSignal(_settings.HIDE_TAGS["Server"]):Connect(function(instance: Instance)
			CheckParts({ instance })
		end)
	end

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.HideOnPlay = {

		--[[ Control ]]

		Hide = Module.Hide,
		Show = Module.Show,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Build Restore Property Whitelist

--[[
	Builds the property-name whitelist used when restoring hidden instances.
	It is rebuilt during init so setting changes are reflected before hiding starts.
]]
function Module._buildRestorePropertyWhitelist()
	table.clear(_allowedRestorePropertyNames)

	for _, className: string in ipairs(_settings.HIDE_PROPERTY_CLASS_ORDER) do
		--[[ Find Properties ]]

		--- @type { [string]: any }?
		local props = _settings.HIDE_PROPERTIES[className]

		--[[ Missing Config ]]

		-- Missing entries mean the order list and property map are out of sync.
		if not props then
			warn(`[{_localName}::{script.Name}]: HIDE_PROPERTIES missing entry for class ({className}) in HIDE_PROPERTY_CLASS_ORDER`)
			continue
		end

		for propertyName: string in pairs(props) do
			--[[ Allow Restore ]]

			-- ShowParts may restore this property from saved attributes.
			_allowedRestorePropertyNames[propertyName] = true
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Validate Hide Property Settings

--[[
	Validates that hide-property settings can be merged safely.
	Every configured class must have one explicit position in the merge order.
]]
function Module._validateHidePropertySettings()
	--- @type { [string]: boolean }
	local seenInOrder = {}

	for _, className: string in ipairs(_settings.HIDE_PROPERTY_CLASS_ORDER) do
		--[[ Track Class ]]

		-- Remember each ordered class so duplicate entries can be detected.
		if seenInOrder[className] then
			warn(`[{_localName}::{script.Name}]: Duplicate class in HIDE_PROPERTY_CLASS_ORDER: {className}`)
		end

		--[[ Save Order ]]

		-- The next loop uses this to verify every property map key has order.
		seenInOrder[className] = true
	end

	for className: string in pairs(_settings.HIDE_PROPERTIES) do
		--[[ Check Orphans ]]

		-- A property map key without order would make merge precedence unclear.
		if not seenInOrder[className] then
			warn(`[{_localName}::{script.Name}]: HIDE_PROPERTIES key ({className}) is not listed in HIDE_PROPERTY_CLASS_ORDER`)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Hide

--[[
	Hides all instances in the provided table through the public module API.
]]
--- @param instances { Instance }
function Module.Hide(instances)
	HideParts(instances)
end

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	Shows all instances in the provided table through the public module API.
]]
--- @param instances { Instance }
function Module.Show(instances)
	ShowParts(instances)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
