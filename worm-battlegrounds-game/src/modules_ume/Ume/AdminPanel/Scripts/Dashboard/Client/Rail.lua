--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Panels = require(script.Parent:FindFirstChild("Panels")) --- @type AdminPanel_Dashboard_Client_Panels

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local PLAYER_PAGE: string = "Player"

local dashboardGui: ScreenGui
local body: Frame
local onResult: (success: boolean, label: string, message: string) -> ()

--[[ State ]]

local pages = {} --- @type { AdminPanel_DashboardPageInfo }
local built = {} --- @type { GuiObject }
local connections = {} --- @type { RBXScriptConnection }
local scrolls = {} --- @type { [string]: Vector2 }
local buildToken: number = 0

--- @type AdminPanel_DashboardState
local state = { Kind = "Player", PlayerUserId = 0, PageId = "", Query = "" }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Headshot

--[[
	Returns a player's headshot image.
]]
--- @return string
local function getHeadshot(userId: number)
	return `rbxthumb://type=AvatarHeadShot&id={userId}&w=150&h=150`
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

--- @class AdminPanel_Dashboard_Client_Rail
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Bind

--[[
	Finds the dashboard's body and close button, takes its prefabs, and rebuilds an open dashboard when the server says
	its page changed or a player joins or leaves. `resultCallback` gets every block's result.
]]
function Module.Bind(gui: ScreenGui, resultCallback: (success: boolean, label: string, message: string) -> ())
	--[[ Elements ]]

	local dashboard: Frame = gui:FindFirstChild("U_Dashboard", true)
	local closeButton: ImageButton = dashboard:FindFirstChild("S_CloseButton", true)
	dashboardGui = gui
	body = dashboard:FindFirstChild("S_Body", true)
	onResult = resultCallback
	gui.Enabled = false

	--[[ Prefabs ]]

	Panels.Bind(gui)

	--[[ Connections ]]

	closeButton.Activated:Connect(Module.Close)
	I.S.Players.PlayerAdded:Connect(Module._onPlayersChanged)
	I.S.Players.PlayerRemoving:Connect(function(player: Player)
		-- Leave a page whose player left
		if state.Kind == "Player" and state.PlayerUserId == player.UserId then
			state.PlayerUserId = I.Env.LocalPlayer.UserId
		end

		Module._onPlayersChanged()
	end)

	--[[ Network ]]

	I.Network.GetEvent("_AdminPanel_Dashboard_PageChanged", { "string" })
	I.Network.Fired("_AdminPanel_Dashboard_PageChanged", Module._onPageChanged)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Open

--[[
	Opens the dashboard on the players (`"Players"`), on the modules (`"Modules"`: the last module shown, else the
	first, else the search), or where it was last left (nil). Asks the server which pages the player may see first.
]]
function Module.Open(page: string?)
	--[[ Data ]]

	pages = I.Network.Invoke("_AdminPanel_Dashboard_GetPages") or {}

	--[[ Picking ]]

	-- Show the local player when the picked player is gone
	if not I.S.Players:GetPlayerByUserId(state.PlayerUserId) then
		state.PlayerUserId = I.Env.LocalPlayer.UserId
	end

	-- Show the first module page when the last one is gone
	if not Module._getPageIndex(state.PageId) then
		state.PageId = if pages[1] then pages[1].Id else ""
	end

	if page == "Players" then
		state.Kind = "Player"
	elseif page == "Modules" or (state.Kind == "Module" and state.PageId == "") then
		state.Kind = if state.PageId ~= "" then "Module" else "Search"
	end

	--[[ Showing ]]

	dashboardGui.Enabled = true
	Module.Build()
end

--%%%%%%%%%%%%%%%%%%%% Close

--[[
	Hides the dashboard and removes what it built.
]]
function Module.Close()
	--[[ Hiding ]]

	dashboardGui.Enabled = false
	Module._clear()
end

--%%%%%%%%%%%%%%%%%%%% Build

--[[
	Builds the dashboard's body, after removing the last build: the rail of icons down the left edge (search, the
	players, then each module page), then the search page, the player list with the picked player's page, or a module's
	page.
]]
function Module.Build()
	--[[ Cleaning ]]

	Module._clear()

	--[[ Local Variables ]]

	local kind: string = state.Kind
	local rail: GuiObject = Module._clone("Rail", body)
	local railWidth: number = rail.Size.X.Offset
	local left: number = railWidth + 1

	--[[ Rail ]]

	local search: GuiObject = Module._railButton(rail, "Search", _settings.DASHBOARD_SEARCH_ICON, nil, false, kind == "Search", 1, function()
		Module._select("Search", nil)
	end)
	local searchIcon: ImageLabel = search:FindFirstChild("S_Icon", true)
	searchIcon.BackgroundTransparency = 1
	searchIcon.ImageColor3 = _settings.DASHBOARD_COLORS.SearchIcon
	searchIcon.Size = UDim2.fromOffset(20, 20)

	Module._railButton(rail, "Players", getHeadshot(I.Env.LocalPlayer.UserId), nil, true, kind == "Player", 2, function()
		Module._select("Player", nil)
	end)

	local gap: GuiObject = Module._clone("Divider", rail)
	gap.Size = UDim2.fromOffset(24, 1)
	gap.LayoutOrder = 3

	--- @param page AdminPanel_DashboardPageInfo
	for index: number, page in ipairs(pages) do
		Module._railButton(rail, page.Name, page.Icon, page.Color, false, kind == "Module" and state.PageId == page.Id, index + 3, function()
			Module._select("Module", page.Id)
		end)
	end

	Module._divider(UDim2.fromOffset(railWidth, 0))

	--[[ Search ]]

	if kind == "Search" then
		Module._launcher(UDim2.fromOffset(left, 0), UDim2.new(1, -left, 1, 0))
		return
	end

	--[[ Players ]]

	-- The player list sits beside the rail
	if kind == "Player" then
		local column: GuiObject = Module._clone("ListColumn", body)
		local columnSearch: TextBox = column:FindFirstChild("S_Search", true)
		column.Position = UDim2.fromOffset(left, 0)
		column.Size = UDim2.new(0, _settings.DASHBOARD_LIST_WIDTH, 1, 0)
		columnSearch.PlaceholderText = "Search players"
		Module._search(columnSearch, column:FindFirstChild("S_Empty", true), Module._playerRows(column:FindFirstChild("S_List", true)))
		Module._divider(UDim2.fromOffset(left + _settings.DASHBOARD_LIST_WIDTH, 0))
		left += _settings.DASHBOARD_LIST_WIDTH + 1
	end

	--[[ Page ]]

	Module._content(UDim2.fromOffset(left, 0), UDim2.new(1, -left, 1, 0))
end

--%%%%%%%%%%%%%%%%%%%% Clear

--[[
	Removes what the last build made and the page in it, and disconnects everything made for them.
]]
function Module._clear()
	--[[ Cleaning ]]

	Panels.Clear()
	buildToken += 1

	for _index: number, connection: RBXScriptConnection in ipairs(connections) do
		connection:Disconnect()
	end
	table.clear(connections)

	for _index: number, instance: GuiObject in ipairs(built) do
		instance:Destroy()
	end
	table.clear(built)
end

--%%%%%%%%%%%%%%%%%%%% Select

--[[
	Picks what the dashboard shows (a player by user id, or a module page by id; nil keeps the current one), then
	rebuilds it.
]]
function Module._select(kind: string, value: (number | string)?)
	--[[ Saving ]]

	state.Kind = kind

	-- The value belongs to the kind picked
	if kind == "Player" and type(value) == "number" then
		state.PlayerUserId = value
	elseif kind == "Module" and type(value) == "string" then
		state.PageId = value
	end

	--[[ Building ]]

	Module.Build()
end

--%%%%%%%%%%%%%%%%%%%% Clone

--[[
	Clones a prefab into a parent and keeps it, so the next build removes it.
]]
--- @return GuiObject
function Module._clone(name: string, parent: Instance)
	--[[ Cloning ]]

	local copy: GuiObject = Panels.Clone(name, parent)
	table.insert(built, copy)

	--[[ Returning ]]

	return copy
end

--%%%%%%%%%%%%%%%%%%%% Divider

--[[
	Puts a full-height hairline in the body at a position.
]]
function Module._divider(position: UDim2)
	--[[ Building ]]

	local divider: GuiObject = Module._clone("Divider", body)
	divider.Position = position
	divider.Size = UDim2.new(0, 1, 1, 0)
end

--%%%%%%%%%%%%%%%%%%%% Content

--[[
	Puts a content area in the body, asks the server for the picked player's or module's page, and shows it there,
	scrolled where that page was last left. A newer build drops an older answer.
]]
function Module._content(position: UDim2, size: UDim2)
	--[[ Building ]]

	local content: ScrollingFrame = Module._clone("Content", body)
	local token: number = buildToken
	local pageId: string = if state.Kind == "Player" then PLAYER_PAGE else state.PageId
	local targetUserId: number? = if state.Kind == "Player" then state.PlayerUserId else nil
	local scrollKey: string = `{pageId}/{targetUserId or 0}`
	content.Position = position
	content.Size = size

	--[[ Keeping Scroll ]]

	table.insert(
		connections,
		content:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			scrolls[scrollKey] = content.CanvasPosition
		end)
	)

	--[[ Fetching ]]

	task.spawn(function()
		local page = I.Network.Invoke("_AdminPanel_Dashboard_GetPage", pageId, targetUserId) --- @type AdminPanel_DashboardPage?

		-- Drop an answer a newer build replaced, or a page the player may not see
		if token ~= buildToken or not page then
			return
		end

		--- @param section AdminPanel_DashboardPageSection
		--- @param block AdminPanel_DashboardPageBlock
		--- @param values { [string]: any }
		Panels.Show(content, page, function(section, block, values)
			Module._run(section, block, values, targetUserId)
		end)
		content.CanvasPosition = scrolls[scrollKey] or Vector2.zero
	end)
end

--%%%%%%%%%%%%%%%%%%%% Run

--[[
	Asks the server to run a pressed block with its section's values, reports the result, then shows the page again
	with its new values.
]]
--- @param section AdminPanel_DashboardPageSection
--- @param block AdminPanel_DashboardPageBlock
--- @param values { [string]: any }
function Module._run(section, block, values, targetUserId: number?)
	--[[ Running ]]

	local success: boolean
	local message: string?
	success, message = I.Network.Invoke("_AdminPanel_Dashboard_Run", section.PanelId, section.Index, block.Id, values, targetUserId)

	--[[ Reporting ]]

	onResult(success == true, block.Text, if message and message ~= "" then message else if success then "Done" else "Failed")

	--[[ Refreshing ]]

	-- Show the page's new values while the dashboard is open
	if dashboardGui.Enabled then
		Module.Build()
	end
end

--%%%%%%%%%%%%%%%%%%%% Rail Button

--[[
	Puts an icon button in the rail: an image (round for the players) or a swatch with the page's initial, filled and
	marked with the accent bar while picked.
]]
--- @return GuiObject
function Module._railButton(rail: GuiObject, name: string, image: string?, color: Color3?, round: boolean, picked: boolean, order: number, callback: () -> ())
	--[[ Elements ]]

	local root: GuiObject = Module._clone("RailButton", rail)
	local button: ImageButton = root:FindFirstChild("S_Button", true)
	local icon: ImageLabel = root:FindFirstChild("S_Icon", true)
	local bar: Frame = root:FindFirstChild("S_SelectedBar", true)

	--[[ Applying ]]

	icon.Image = image or ""
	icon.BackgroundColor3 = color or _settings.DASHBOARD_COLORS.Swatch
	icon:FindFirstChildOfClass("UICorner").CornerRadius = if round then UDim.new(1, 0) else UDim.new(0, 8)
	Panels.PaintLetter(icon, name)
	button.BackgroundTransparency = if picked then 0.9 else 1
	bar.BackgroundColor3 = _settings.DASHBOARD_ACCENT
	bar.Visible = picked
	root.LayoutOrder = order
	table.insert(connections, button.Activated:Connect(callback))

	--[[ Returning ]]

	return root
end

--%%%%%%%%%%%%%%%%%%%% Launcher

--[[
	Puts the search page in the body: a search box over a group of tiles for the module pages and one for the players.
	Typing filters both (hiding a group with nothing left); pressing a tile opens its page. What was typed stays while
	the game runs.
]]
function Module._launcher(position: UDim2, size: UDim2)
	--[[ Elements ]]

	local launcher: GuiObject = Module._clone("Launcher", body)
	local search: TextBox = launcher:FindFirstChild("S_Search", true)
	local results: ScrollingFrame = launcher:FindFirstChild("S_Results", true)
	local empty: TextLabel = launcher:FindFirstChild("S_Empty", true)
	launcher.Position = position
	launcher.Size = size

	--[[ Local Variables ]]

	local entries = {} --- @type { AdminPanel_DashboardSearchEntry }
	local modules: GuiObject = Module._group(results, "Modules", 1)
	local players: GuiObject = Module._group(results, "Players", 2)
	local moduleTiles: Frame = modules:FindFirstChild("S_Blocks", true)
	local playerTiles: Frame = players:FindFirstChild("S_Blocks", true)

	--[[ Modules ]]

	--- @param page AdminPanel_DashboardPageInfo
	for index: number, page in ipairs(pages) do
		local tile: GuiObject = Module._tile(moduleTiles, page.Name, page.Icon, page.Color, false, index, function()
			Module._select("Module", page.Id)
		end)
		table.insert(entries, { Row = tile, Text = string.lower(`{page.Name} {page.Description}`), Group = modules })
	end

	--[[ Players ]]

	for index: number, player: Player in ipairs(Module._getPlayers()) do
		local tile: GuiObject = Module._tile(playerTiles, player.DisplayName, getHeadshot(player.UserId), _settings.DASHBOARD_COLORS.Swatch, true, index, function()
			Module._select("Player", player.UserId)
		end)
		table.insert(entries, { Row = tile, Text = string.lower(`{player.DisplayName} {player.Name}`), Group = players })
	end

	--[[ Search ]]

	search.Text = state.Query
	table.insert(
		connections,
		search:GetPropertyChangedSignal("Text"):Connect(function()
			state.Query = search.Text
		end)
	)
	Module._search(search, empty, entries)
end

--%%%%%%%%%%%%%%%%%%%% Group

--[[
	Puts a titled group of tiles in the search page.
]]
--- @return GuiObject
function Module._group(parent: Instance, title: string, order: number)
	--[[ Building ]]

	local group: GuiObject = Module._clone("Section", parent)
	group:FindFirstChild("S_Title", true).Text = string.upper(title)
	group.LayoutOrder = order

	--[[ Returning ]]

	return group
end

--%%%%%%%%%%%%%%%%%%%% Tile

--[[
	Puts a tile in a search group: an image (round for a player) or a swatch with the page's initial, over its name.
]]
--- @return GuiObject
function Module._tile(parent: Instance, name: string, image: string?, color: Color3?, round: boolean, order: number, callback: () -> ())
	--[[ Elements ]]

	local tile: GuiObject = Module._clone("LauncherTile", parent)
	local icon: ImageLabel = tile:FindFirstChild("S_Icon", true)

	--[[ Applying ]]

	icon.Image = image or ""
	icon.BackgroundColor3 = color or icon.BackgroundColor3
	icon:FindFirstChildOfClass("UICorner").CornerRadius = if round then UDim.new(1, 0) else UDim.new(0, 14)
	Panels.PaintLetter(icon, name)
	tile:FindFirstChild("S_Name", true).Text = name
	tile.LayoutOrder = order
	table.insert(connections, tile:FindFirstChild("S_Button", true).Activated:Connect(callback))

	--[[ Returning ]]

	return tile
end

--%%%%%%%%%%%%%%%%%%%% Player Rows

--[[
	Fills the player list with a row per player, the picked one filled. Pressing a row shows that player. Returns the
	search entries.
]]
--- @return { AdminPanel_DashboardSearchEntry }
function Module._playerRows(list: Instance)
	--[[ Local Variables ]]

	local entries = {} --- @type { AdminPanel_DashboardSearchEntry }

	--[[ Building ]]

	for index: number, player: Player in ipairs(Module._getPlayers()) do
		local row: GuiObject = Module._clone("PlayerRow", list)
		local bar: Frame = row:FindFirstChild("S_SelectedBar", true)
		local picked: boolean = state.PlayerUserId == player.UserId
		row:FindFirstChild("S_Headshot", true).Image = getHeadshot(player.UserId)
		row:FindFirstChild("S_DisplayName", true).Text = player.DisplayName
		row:FindFirstChild("S_Username", true).Text = `@{player.Name}`
		row:FindFirstChild("S_YouBadge", true).Visible = player == I.Env.LocalPlayer
		row.LayoutOrder = index
		row.BackgroundTransparency = if picked then 0.9 else 1
		bar.BackgroundColor3 = _settings.DASHBOARD_ACCENT
		bar.Visible = picked
		table.insert(
			connections,
			row.Activated:Connect(function()
				Module._select("Player", player.UserId)
			end)
		)
		table.insert(entries, { Row = row, Text = string.lower(`{player.DisplayName} {player.Name}`) })
	end

	--[[ Returning ]]

	return entries
end

--%%%%%%%%%%%%%%%%%%%% Search

--[[
	Wires a search box to its rows: only the rows whose text holds what is typed (any case) show, a group hides with
	all its rows, and the empty line shows when nothing matches.
]]
--- @param entries { AdminPanel_DashboardSearchEntry }
function Module._search(search: TextBox, empty: TextLabel, entries)
	--%%%%%%%%%%%%%%%%%%%% Filter

	--[[
		Shows the rows that match the search box's text, the groups with a row showing, and the line that says nothing
		matches.
	]]
	local function filter()
		--[[ Local Variables ]]

		local query: string = string.lower(search.Text)
		local shown = {} --- @type { [Instance]: boolean }
		local count: number = 0

		--[[ Rows ]]

		--- @param entry AdminPanel_DashboardSearchEntry
		for _index: number, entry in ipairs(entries) do
			local visible: boolean = query == "" or string.find(entry.Text, query, 1, true) ~= nil
			entry.Row.Visible = visible
			count += if visible then 1 else 0

			-- A group stays while one of its rows shows
			if entry.Group and visible then
				shown[entry.Group] = true
			end
		end

		--[[ Groups ]]

		--- @param entry AdminPanel_DashboardSearchEntry
		for _index: number, entry in ipairs(entries) do
			-- Skip rows outside a group
			if not entry.Group then
				continue
			end
			entry.Group.Visible = shown[entry.Group] == true
		end

		--[[ Empty ]]

		empty.Visible = count == 0
	end

	--[[ Connections ]]

	table.insert(connections, search:GetPropertyChangedSignal("Text"):Connect(filter))
	filter()
end

--%%%%%%%%%%%%%%%%%%%% On Page Changed

--[[
	Rebuilds the open dashboard when the server says the page it shows changed.
]]
function Module._onPageChanged(pageId: string)
	--[[ Checks ]]

	-- Check if the dashboard is open
	if not dashboardGui.Enabled then
		return
	end

	-- Check if it shows that page
	if (pageId == PLAYER_PAGE and state.Kind ~= "Player") or (pageId ~= PLAYER_PAGE and state.PageId ~= pageId) then
		return
	end

	--[[ Building ]]

	Module.Build()
end

--%%%%%%%%%%%%%%%%%%%% On Players Changed

--[[
	Rebuilds the open dashboard when a player joins or leaves, while it lists players.
]]
function Module._onPlayersChanged()
	--[[ Checks ]]

	-- Check if the dashboard is open on a page that lists players
	if not dashboardGui.Enabled or state.Kind == "Module" then
		return
	end

	--[[ Building ]]

	Module.Build()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Players

--[[
	Returns the server's players, the local player first, then by display name.
]]
--- @return { Player }
function Module._getPlayers()
	--[[ Local Variables ]]

	local players = I.S.Players:GetPlayers() --- @type { Player }

	--[[ Sorting ]]

	table.sort(players, function(a: Player, b: Player)
		-- The local player comes first, and never before itself
		if a == I.Env.LocalPlayer or b == I.Env.LocalPlayer then
			return a == I.Env.LocalPlayer and b ~= I.Env.LocalPlayer
		end

		return string.lower(a.DisplayName) < string.lower(b.DisplayName)
	end)

	--[[ Returning ]]

	return players
end

--%%%%%%%%%%%%%%%%%%%% Get Page Index

--[[
	Returns where a module page sits in the rail, nil when the player may not see it.
]]
--- @return number?
function Module._getPageIndex(pageId: string)
	--[[ Finding ]]

	--- @param page AdminPanel_DashboardPageInfo
	for index: number, page in ipairs(pages) do
		if page.Id == pageId then
			return index
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
