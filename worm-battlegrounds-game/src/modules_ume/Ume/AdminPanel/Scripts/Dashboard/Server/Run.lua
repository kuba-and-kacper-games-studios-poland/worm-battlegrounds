--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Permissions = require(_scripts:FindFirstChild("Global"):FindFirstChild("Permissions")) --- @type AdminPanel_Global_Permissions
local Registry = require(script.Parent:FindFirstChild("Registry")) --- @type AdminPanel_Dashboard_Server_Registry

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

--- @class AdminPanel_Dashboard_Server_Run
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetFunction("_AdminPanel_Dashboard_Run", { "Player", "string", "number", "string", { Type = "table" }, { Type = "number", Optional = true } }, { RateLimit = 10, Per = 1 })
	I.Network.OnInvoke("_AdminPanel_Dashboard_Run", Module.RunBlock)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Run Block

--[[
	Runs a pressed block's callback for an admin, after checking they may use its panel, with the values of every block
	in its section and, on a player's page, that player. Returns whether it worked and a message for the admin.
]]
--- @param values { [string]: any }
--- @return boolean
--- @return string
function Module.RunBlock(player: Player, panelId: string, sectionIndex: number, blockId: string, values, targetUserId: number?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false, "Invalid player"
	end

	--[[ Checks ]]

	-- Check if the player may open the dashboard
	if not Permissions.CanOpenDashboard(player) then
		return false, "Insufficient permissions"
	end

	-- Check if the player is pressing too fast
	if I.Debounce.Run("AdminPanel_DashboardRun", _settings.DASHBOARD_RUN_DEBOUNCE, player) then
		return false, "You are pressing too fast!"
	end

	--[[ Data ]]

	local panel = Registry.GetPanel(panelId) --- @type AdminPanel_DashboardPanel?

	--[[ Checks ]]

	-- Check if the panel exists and the player may use it
	if not panel or Permissions.GetPermissionLevel(player) < panel.PermissionLevel then
		return false, `Unknown panel {panelId}`
	end

	--[[ Finding ]]

	local section = panel.Setup.Sections[sectionIndex] --- @type AdminPanel_DashboardSectionSetup?
	local block --- @type AdminPanel_DashboardBlockSetup?

	-- Check if the section exists
	if not section then
		return false, `Unknown section {sectionIndex}`
	end

	--- @param sectionBlock AdminPanel_DashboardBlockSetup
	for _index: number, sectionBlock in ipairs(section.Blocks) do
		if sectionBlock.Id == blockId then
			block = sectionBlock
			break
		end
	end

	-- Check if the block exists and runs something
	if not block or not block.Callback then
		return false, `Unknown block {blockId}`
	end

	--[[ Target ]]

	local target: Player? = nil

	-- A player panel acts on the page's player, who must be in this server
	if panel.Setup.Scope == "Player" then
		target = if targetUserId then I.S.Players:GetPlayerByUserId(targetUserId) else nil

		if not target then
			return false, "That player left"
		end
	end

	--[[ Running ]]

	local success: boolean
	local result: any | string?
	local message: any
	success, result, message = pcall(block.Callback, player, Module._getCleanValues(section, values, target), target)

	-- Report a callback that errored
	if not success then
		warn(`[{_localName}::{script.Name}]: Block ({panelId}/{blockId}) failed! - ({result})`)
		return false, "Something went wrong"
	end

	--[[ Returning ]]

	return result == true, if type(message) == "string" then message else ""
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Clean Values

--[[
	Returns the values a client sent for a section, by block id, each kept only in the shape its block's type sends
	(`_getCleanValue`).
]]
--- @param section AdminPanel_DashboardSectionSetup
--- @param values { [string]: any }
--- @return { [string]: any }
function Module._getCleanValues(section, values, target: Player?)
	--[[ Local Variables ]]

	local clean = {} --- @type { [string]: any }

	--[[ Cleaning ]]

	--- @param block AdminPanel_DashboardBlockSetup
	for _index: number, block in ipairs(section.Blocks) do
		clean[block.Id] = Module._getCleanValue(block, values[block.Id], target)
	end

	--[[ Returning ]]

	return clean
end

--%%%%%%%%%%%%%%%%%%%% Get Clean Value

--[[
	Returns a block's value as its type sends it: a Toggle's boolean, a Slider's number on its Step between its Min and
	Max, an Input's text, one of a Choice's Options, a Give block's `{ Item, Amount }` with one of its Items and a whole
	amount of at least 1. Nil for anything else, and for Buttons and Info lines.
]]
--- @param block AdminPanel_DashboardBlockSetup
--- @return any
function Module._getCleanValue(block, value: any, target: Player?)
	--[[ Toggle ]]

	if block.Type == "Toggle" then
		return if type(value) == "boolean" then value else nil
	end

	--[[ Slider ]]

	if block.Type == "Slider" then
		-- Check if the slider sent a number
		if type(value) ~= "number" then
			return nil
		end

		local step: number = block.Step or 1
		return math.clamp(math.round(value / step) * step, block.Min, block.Max)
	end

	--[[ Input ]]

	if block.Type == "Input" then
		return if type(value) == "string" then value else nil
	end

	--[[ Choice ]]

	if block.Type == "Choice" then
		local options = Registry.GetResolvedValue(block.Options, target) or {} --- @type { string }
		return if type(value) == "string" and table.find(options, value) then value else nil
	end

	--[[ Give ]]

	if block.Type == "Give" then
		-- Check if the amount is a whole number of at least 1
		if type(value) ~= "table" or type(value.Item) ~= "string" or type(value.Amount) ~= "number" or value.Amount < 1 or value.Amount % 1 ~= 0 then
			return nil
		end

		local items = Registry.GetResolvedValue(block.Items, target) or {} --- @type { AdminPanel_DashboardItem }

		--- @param item AdminPanel_DashboardItem
		for _index: number, item in ipairs(items) do
			-- Keep an item the block offers
			if item.Name == value.Item then
				return { Item = value.Item, Amount = value.Amount }
			end
		end

		return nil
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
