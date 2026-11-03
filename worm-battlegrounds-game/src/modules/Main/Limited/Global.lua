--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Limited"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _data = script:FindFirstAncestor(_localName):FindFirstChild("Data")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Cache ]]

local cachedData = {} --- @type { [string]: Limited_LimitedData }

--[[ Validation ]]

local attributeTester: Folder = Instance.new("Folder")

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

	Module._cacheLimited()

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.G_Limited = {

		--[[ Cached ]]

		Data = cachedData,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Cache Limited

--[[
	Caches data for all limited entries.
]]
function Module._cacheLimited()
	for _, elem: ModuleScript | Folder | Instance in ipairs(_data:FindFirstChild("Limited"):GetDescendants()) do
		--[[ Checks ]]

		if not elem:IsA("ModuleScript") then
			continue
		end

		-- Duplicate
		if cachedData[elem.Name] then
			warn(`[{_localName}::{script.Name}]: Data for Limited ({elem.Name}) is duplicated!`)
			continue
		end

		--[[ Requiring ]]

		local success: boolean
		local result --- @type Limited_LimitedData | string
		success, result = pcall(function()
			return require(elem)
		end)

		-- Require failed
		if not success then
			warn(`[{_localName}::{script.Name}]: Failed to require ({elem.Name}) Limited Data! - ({result})`)
			continue
		end

		success = pcall(attributeTester.SetAttribute, attributeTester, `{elem.Name}_Sold`, 0)

		-- Skip a name that can't be part of an attribute name (`<limitedId>_Sold`)
		if not success then
			warn(`[{_localName}::{script.Name}]: Limited ({elem.Name}) has a name that can't be used in an attribute name!`)
			continue
		end

		--%%%%%%%%%%%%%%%%%%%% Validating

		local data = result --- @type Limited_LimitedData
		local invalid: boolean = false

		-- Name
		if typeof(data.Name) ~= "string" or #data.Name == 0 then
			warn(`[{_localName}::{script.Name}]: Limited ({elem.Name}) is missing a valid (Name)!`)
			invalid = true
		end

		-- ProductId
		if typeof(data.ProductId) ~= "string" or #data.ProductId == 0 then
			warn(`[{_localName}::{script.Name}]: Limited ({elem.Name}) is missing a valid (ProductId)!`)
			invalid = true
		end

		-- MaximumAmount
		if typeof(data.MaximumAmount) ~= "number" or data.MaximumAmount < 0 or data.MaximumAmount ~= math.floor(data.MaximumAmount) then
			warn(`[{_localName}::{script.Name}]: Limited ({elem.Name}) is missing a valid (MaximumAmount)!`)
			invalid = true
		end

		-- Reward
		if typeof(data.Reward) ~= "function" then
			warn(`[{_localName}::{script.Name}]: Limited ({elem.Name}) is missing a valid (Reward) function!`)
			invalid = true
		end

		-- AmountPerPlayer
		if typeof(data.AmountPerPlayer) ~= "number" or data.AmountPerPlayer < -1 or data.AmountPerPlayer ~= math.floor(data.AmountPerPlayer) then
			warn(`[{_localName}::{script.Name}]: Limited ({elem.Name}) is missing a valid (AmountPerPlayer)!`)
			invalid = true
		end

		if invalid then
			continue
		end

		--%%%%%%%%%%%%%%%%%%%% Saving

		cachedData[elem.Name] = data
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
