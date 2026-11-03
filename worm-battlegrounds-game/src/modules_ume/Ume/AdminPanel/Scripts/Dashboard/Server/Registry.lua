--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Permissions = require(_scripts:FindFirstChild("Global"):FindFirstChild("Permissions")) --- @type AdminPanel_Global_Permissions

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local PLAYER_PAGE: string = "Player"
local DEFAULT_PERMISSION_LEVEL: number = 255

--[[ Panels ]]

local panels = {} --- @type { [string]: AdminPanel_DashboardPanel }
local panelOrder = {} --- @type { string }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--   __       __                 __            __
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

--- @class AdminPanel_Dashboard_Server_Registry
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetFunction("_AdminPanel_Dashboard_GetPages", { "Player" }, { RateLimit = 5, Per = 1 })
	I.Network.OnInvoke("_AdminPanel_Dashboard_GetPages", Module.GetPages)

	I.Network.GetFunction("_AdminPanel_Dashboard_GetPage", { "Player", "string", { Type = "number", Optional = true } }, { RateLimit = 10, Per = 1 })
	I.Network.OnInvoke("_AdminPanel_Dashboard_GetPage", Module.GetPage)

	I.Network.GetEvent("_AdminPanel_Dashboard_PageChanged")
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Register

--[[
	**SERVER** |
	Adds a panel to the dashboard: a page on the rail (`Scope` "Game"), or sections on every player's page (`Scope`
	"Player"). Registering an id again replaces it. Returns false when the setup is invalid.
]]
--- @param setup AdminPanel_DashboardPanelSetup
--- @return boolean
function Module.Register(panelId: string, setup)
	--[[ Checks ]]

	-- Check if the scope is known
	if setup.Scope ~= "Game" and setup.Scope ~= "Player" then
		warn(`[{_localName}::{script.Name}]: Panel ({panelId}) has an unknown Scope ({setup.Scope})!`)
		return false
	end

	-- Check if the panel has sections
	if type(setup.Sections) ~= "table" or #setup.Sections == 0 then
		warn(`[{_localName}::{script.Name}]: Panel ({panelId}) has no Sections!`)
		return false
	end

	-- Check that no panel is named like the player page
	if panelId == PLAYER_PAGE then
		warn(`[{_localName}::{script.Name}]: Panel id ({PLAYER_PAGE}) is taken by the player page!`)
		return false
	end

	--[[ Saving ]]

	-- Keep a replaced panel's place in the order
	if not panels[panelId] then
		table.insert(panelOrder, panelId)
	end

	panels[panelId] = {
		Id = panelId,
		Setup = setup,
		PermissionLevel = setup.PermissionLevel or DEFAULT_PERMISSION_LEVEL,
	}

	--[[ Refreshing ]]

	Module.Refresh(panelId)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Unregister

--[[
	**SERVER** |
	Removes a panel from the dashboard.
]]
function Module.Unregister(panelId: string)
	--[[ Checks ]]

	-- Check if the panel exists
	if not panels[panelId] then
		warn(`[{_localName}::{script.Name}]: Panel ({panelId}) is missing!`)
		return
	end

	--[[ Refreshing ]]

	Module.Refresh(panelId)

	--[[ Removing ]]

	panels[panelId] = nil
	table.remove(panelOrder, table.find(panelOrder, panelId))
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	**SERVER** |
	Tells every admin's dashboard that a panel's page changed, so an open one fetches it again.
]]
function Module.Refresh(panelId: string)
	--[[ Data ]]

	local panel = panels[panelId] --- @type AdminPanel_DashboardPanel?

	--[[ Checks ]]

	-- Check if the panel exists
	if not panel then
		warn(`[{_localName}::{script.Name}]: Panel ({panelId}) is missing!`)
		return
	end

	--[[ Sending ]]

	local pageId: string = if panel.Setup.Scope == "Player" then PLAYER_PAGE else panelId

	for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		-- Tell only the players who may open the dashboard
		if Permissions.CanOpenDashboard(player) then
			I.Network.Fire("_AdminPanel_Dashboard_PageChanged", player, pageId)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Pages

--[[
	Returns the Game pages a player may see, in the order they were registered, with what the rail and the search show
	for each. Empty for a player who may not open the dashboard.
]]
--- @return { AdminPanel_DashboardPageInfo }
function Module.GetPages(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return {}
	end

	--[[ Checks ]]

	-- Check if the player may open the dashboard
	if not Permissions.CanOpenDashboard(player) then
		return {}
	end

	--[[ Local Variables ]]

	local level: number = Permissions.GetPermissionLevel(player)
	local pages = {} --- @type { AdminPanel_DashboardPageInfo }

	--[[ Collecting ]]

	for _index: number, panelId: string in ipairs(panelOrder) do
		local panel = panels[panelId] --- @type AdminPanel_DashboardPanel

		-- Skip player panels and panels above the player's level
		if panel.Setup.Scope ~= "Game" or level < panel.PermissionLevel then
			continue
		end

		table.insert(pages, {
			Id = panelId,
			Name = panel.Setup.Name,
			Description = panel.Setup.Description or "",
			Icon = panel.Setup.Icon,
			Color = panel.Setup.Color,
		})
	end

	--[[ Returning ]]

	return pages
end

--%%%%%%%%%%%%%%%%%%%% Get Page

--[[
	Returns one page as a player sees it now: a Game panel's page, or (`pageId` "Player") the page of the player with
	`targetUserId`, made of every Player panel's sections. Nil when the player may not see it.
]]
--- @return AdminPanel_DashboardPage?
function Module.GetPage(player: Player, pageId: string, targetUserId: number?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Checks ]]

	-- Check if the player may open the dashboard
	if not Permissions.CanOpenDashboard(player) then
		return nil
	end

	--[[ Player Page ]]

	if pageId == PLAYER_PAGE then
		local target: Player? = if targetUserId then I.S.Players:GetPlayerByUserId(targetUserId) else nil

		-- Check if the target player is in this server
		if not target then
			return nil
		end

		return Module._getPlayerPage(player, target)
	end

	--[[ Data ]]

	local panel = panels[pageId] --- @type AdminPanel_DashboardPanel?

	--[[ Checks ]]

	-- Check if the panel exists and the player may see it
	if not panel or panel.Setup.Scope ~= "Game" or Permissions.GetPermissionLevel(player) < panel.PermissionLevel then
		return nil
	end

	--[[ Returning ]]

	return {
		Id = pageId,
		Name = panel.Setup.Name,
		Description = panel.Setup.Description or "",
		Icon = panel.Setup.Icon,
		Color = panel.Setup.Color,
		Stats = Module.GetResolvedValue(panel.Setup.Stats, nil),
		Sections = Module._getSections(panel, nil),
	}
end

--%%%%%%%%%%%%%%%%%%%% Get Panel

--[[
	Returns a registered panel.
]]
--- @return AdminPanel_DashboardPanel?
function Module.GetPanel(panelId: string)
	return panels[panelId]
end

--%%%%%%%%%%%%%%%%%%%% Get Resolved Value

--[[
	Returns a setup value as the viewer sees it: a function is called with the page's player (nil on a Game page), any
	other value is returned as it is. A function that errors warns and gives nil.
]]
--- @return any
function Module.GetResolvedValue(value: any, target: Player?)
	--[[ Checks ]]

	-- Return a plain value as it is
	if type(value) ~= "function" then
		return value
	end

	--[[ Calling ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(value, target)

	-- Warn when the value function failed
	if not success then
		warn(`[{_localName}::{script.Name}]: A dashboard value failed! - ({result})`)
		return nil
	end

	--[[ Returning ]]

	return result
end

--%%%%%%%%%%%%%%%%%%%% Get Player Page

--[[
	Returns a player's page: their headshot, name and username, every Player panel's stats on one line, then every
	Player panel's sections the viewer may see, in the order the panels were registered.
]]
--- @return AdminPanel_DashboardPage
function Module._getPlayerPage(viewer: Player, target: Player)
	--[[ Local Variables ]]

	local level: number = Permissions.GetPermissionLevel(viewer)
	local stats = {} --- @type { string }
	local sections = {} --- @type { AdminPanel_DashboardPageSection }

	--[[ Collecting ]]

	for _index: number, panelId: string in ipairs(panelOrder) do
		local panel = panels[panelId] --- @type AdminPanel_DashboardPanel

		-- Skip game panels and panels above the viewer's level
		if panel.Setup.Scope ~= "Player" or level < panel.PermissionLevel then
			continue
		end

		local panelStats: any = Module.GetResolvedValue(panel.Setup.Stats, target)

		-- Add the panel's stats when it has some
		if type(panelStats) == "string" and panelStats ~= "" then
			table.insert(stats, panelStats)
		end

		--- @param section AdminPanel_DashboardPageSection
		for _sectionIndex: number, section in ipairs(Module._getSections(panel, target)) do
			table.insert(sections, section)
		end
	end

	--[[ Returning ]]

	return {
		Id = `{PLAYER_PAGE}/{target.UserId}`,
		Name = target.DisplayName,
		Description = `@{target.Name}`,
		Icon = `rbxthumb://type=AvatarHeadShot&id={target.UserId}&w=150&h=150`,
		Round = true,
		Stats = if #stats > 0 then table.concat(stats, "   ·   ") else nil,
		Sections = sections,
	}
end

--%%%%%%%%%%%%%%%%%%%% Get Sections

--[[
	Returns a panel's sections as a viewer sees them: each block's values resolved for the page's player, and whether
	pressing it runs anything on the server.
]]
--- @param panel AdminPanel_DashboardPanel
--- @return { AdminPanel_DashboardPageSection }
function Module._getSections(panel, target: Player?)
	--[[ Local Variables ]]

	local sections = {} --- @type { AdminPanel_DashboardPageSection }

	--[[ Building ]]

	--- @param section AdminPanel_DashboardSectionSetup
	for sectionIndex: number, section in ipairs(panel.Setup.Sections) do
		local blocks = {} --- @type { AdminPanel_DashboardPageBlock }

		--- @param block AdminPanel_DashboardBlockSetup
		for _blockIndex: number, block in ipairs(section.Blocks) do
			table.insert(blocks, {
				Type = block.Type,
				Id = block.Id,
				Text = block.Text,
				Value = Module.GetResolvedValue(block.Value, target),
				Min = block.Min,
				Max = block.Max,
				Step = block.Step,
				Format = block.Format,
				Options = Module.GetResolvedValue(block.Options, target),
				Placeholder = block.Placeholder,
				Button = block.Button,
				Items = Module.GetResolvedValue(block.Items, target),
				Danger = block.Danger,
				Run = block.Callback ~= nil,
			})
		end

		table.insert(sections, {
			Title = section.Title,
			PanelId = panel.Id,
			Index = sectionIndex,
			Blocks = blocks,
		})
	end

	--[[ Returning ]]

	return sections
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
